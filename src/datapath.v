`timescale 1ns / 1ps

module datapath(
    input clk,
    input rst,
    output [31:0] instruction,
    input [1:0] reg_ctrl,
    input [5:0] alu_ctrl, 
    input [2:0] imm_ctrl,
    input mem_write,
    input pc_ctrl
    //The last 4 bits are the ALU function, and the first two bits are select lines for ALU input MUXes.
    );
    
    wire [31:0] pc;
    wire [31:0] pc_next;
    reg id_pc_ctrl;
    
    reg [31:0] if_pc;
    reg [31:0] id_pc;
    
    wire [31:0] instr;
    reg [31:0] if_instr;
    
    wire [31:0] rs1;
    wire [31:0] rs2;
    
    reg [31:0] id_rs1;
    reg [31:0] id_rs2;
    reg [31:0] ex_rs2;
    
    wire [31:0] immediate;
    reg [31:0] id_immediate;
    
    wire [31:0] alu_result;
    reg [31:0] ex_alu_result;
   
    reg [31:0] mem_alu_result;
    
    wire [31:0] branch_target_pc = id_pc + id_immediate;
    
    reg [4:0] id_rd;
    reg [4:0] ex_rd;
    reg [4:0] mem_rd;
    
    reg [1:0]id_reg_ctrl;
    reg [1:0]ex_reg_ctrl;
    reg [1:0]mem_reg_ctrl;
    
    reg [5:0]id_alu_ctrl;
    
    wire [31:0] alu_in_2;
    
    reg id_mem_write;
    reg ex_mem_write;
    wire t_branch;
    
    assign instruction = if_instr;
    
    pc pc_inst (.clk(clk), .pc_write(1'b1), .pc_next(pc_next), .pc(pc), .rst(rst));
    
    assign pc_next = (id_pc_ctrl & t_branch)?branch_target_pc: pc + 32'd4;
    
    instrmem instrmem_inst(.address(pc), .data(instr));
    
    always @(posedge clk) begin
        if (rst) begin
            
            if_instr <= 32'h00000013; 
            if_pc <= 32'd0;
            
            id_rs1 <= 32'd0;
            id_rs2 <= 32'd0;
            id_immediate <= 32'd0;
            id_rd <= 5'd0;
            id_alu_ctrl <= 6'b0;
            id_reg_ctrl <= 2'b0;
            id_mem_write <= 1'b0;
            id_pc <= 32'd0;
            id_pc_ctrl <= 1'b0;
            
            ex_alu_result <= 32'd0;
            ex_rd <= 5'd0;
            ex_reg_ctrl <= 2'b0;
            ex_mem_write <= 1'b0;
            ex_rs2 <= 32'd0;
            
            mem_alu_result <= 32'd0;
            mem_rd <= 5'd0;
            mem_reg_ctrl <= 2'b0;
            mem_datamem_read <= 32'd0;
        end else begin
            
            if_instr <= instr;
            if_pc <= pc;
            
            id_rs1   <= rs1;
            id_rs2   <= rs2;
            id_immediate <= immediate;
            id_rd <= if_instr[11:7]; 
            id_alu_ctrl <= alu_ctrl;
            id_reg_ctrl <= reg_ctrl;
            id_mem_write <= mem_write;
            id_pc <= if_pc;
            id_pc_ctrl <= pc_ctrl;
            
            ex_alu_result <= alu_result;
            ex_rd <= id_rd;
            ex_reg_ctrl <= id_reg_ctrl;
            ex_mem_write <= id_mem_write;
            ex_rs2 <= id_rs2;
            
            mem_alu_result <= ex_alu_result;
            mem_rd <= ex_rd;
            mem_reg_ctrl <= ex_reg_ctrl;
            mem_datamem_read <= datamem_read;
        end
    end
    
    wire [31:0] datamem_read;
    reg [31:0] mem_datamem_read;
    wire [31:0] regfile_data_in;
    
    assign regfile_data_in = mem_reg_ctrl[1]?mem_datamem_read:mem_alu_result;
    
    regfile rf (.rs1(if_instr[19:15]), .rs2(if_instr[24:20]),
     .rd(mem_rd), .write_data_in(regfile_data_in), .reg_write(mem_reg_ctrl[0]), .clk(clk), .rs1_read_o(rs1), .rs2_read_o(rs2));
    
    immgen immgen_inst(.instr(if_instr), .imm_ctrl(imm_ctrl), .imm(immediate));
   
    
    assign alu_in_2 = id_alu_ctrl[4]?id_immediate:id_rs2; // This controls the value at second input of ALU, either rs2 or immediate from immediate generator
    
    alu alu_inst (.alu_ctrl(id_alu_ctrl[3:0]), .a(id_rs1), .b(alu_in_2), .alu_result(alu_result), .t_branch(t_branch));
    
    datamem dm (.address(ex_alu_result), .write_data(ex_rs2), .read_data(datamem_read), .clk(clk), .mem_write(ex_mem_write), .funct3(3'b010));

endmodule