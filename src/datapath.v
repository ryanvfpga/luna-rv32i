`timescale 1ns / 1ps

module datapath(
    input clk,
    input rst,
    output [31:0] instruction,
    input reg_write,
    input [3:0] alu_ctrl
    );
    
    wire [31:0] pc;
    wire [31:0] pc_next;
    
    wire [31:0] instr;
    reg [31:0] if_instr;
    
    wire [31:0] rs1;
    wire [31:0] rs2;
    
    reg [31:0] id_rs1;
    reg [31:0] id_rs2;
    
    wire [31:0] immediate;
    reg [31:0] id_immediate;
    
    wire [31:0] alu_result;
    reg [31:0] ex_alu_result;
   
    reg [31:0] mem_alu_result;
    
    reg [4:0] id_rd;
    reg [4:0] ex_rd;
    reg [4:0] mem_rd;
    
    reg id_reg_write;
    reg ex_reg_write;
    reg mem_reg_write;
    
    reg [3 :0]id_alu_ctrl;
    
    assign instruction = if_instr;
    
    pc pc_inst (.clk(clk), .pc_write(1'b1), .pc_next(pc_next), .pc(pc), .rst(rst));
    assign pc_next = pc + 32'd4;
    
    instrmem instrmem_inst(.address(pc), .data(instr));
    
    always @(posedge clk) begin
        if_instr <= instr;
        
        id_rs1   <= rs1;
        id_rs2   <= rs2;
        id_immediate <= immediate;
        id_rd <= if_instr[11:7];
        id_alu_ctrl <= alu_ctrl;
        id_reg_write <= reg_write;
        
        ex_alu_result <= alu_result;
        ex_rd <= id_rd;
        ex_reg_write <= id_reg_write;
        
        
        mem_alu_result <= ex_alu_result;
        mem_rd <= ex_rd;
        mem_reg_write <= ex_reg_write;
        
    end
    
    regfile rf (.rs1(if_instr[19:15]), .rs2(if_instr[24:20]),
     .rd(mem_rd), .write_data_in(mem_alu_result), .reg_write(mem_reg_write), .clk(clk), .rs1_read_o(rs1), .rs2_read_o(rs2));
    
    immgen immgen_inst(.instr(if_instr), .imm_ctrl(3'b000), .imm(immediate));
    
    alu alu_inst (.alu_ctrl(id_alu_ctrl), .a(id_rs1), .b(id_rs2), .alu_result(alu_result), .t_branch(4'b1010));
    
    

endmodule