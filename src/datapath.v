`timescale 1ns / 1ps

module datapath(
    input clk,
    input rst,
    output [31:0] instruction,
    input [2:0] reg_ctrl, // The LSB is reg_write, and first two bits are for MUX that determine where the input data to regfile is coming from.
    input [6:0] alu_ctrl, // The last 4 bits are ALU function chooser, and first 2 bits are to select ALU inputs 1 and 2.
    input [2:0] imm_ctrl, // Control signal for immediate generator
    input mem_write,
    input pc_ctrl,
    input  jump_ctrl, // Control signals indicating JAL and JALR
    input jalr_ctrl
   
    );
    

    wire [31:0] pc;
    wire [31:0] pc_next;
    reg id_pc_ctrl; 
    
    reg [31:0] if_pc;
    reg [31:0] id_pc;
    reg [31:0] ex_pc;
    reg [31:0] mem_pc;
    
    wire [31:0] instr;
    reg [31:0] if_instr;
    
    wire [31:0] rs1;
    wire [31:0] rs2;
    
    reg [31:0] id_rs1;
    reg [31:0] id_rs2;
    reg [31:0] ex_rs2;
    
    reg id_jalr_ctrl;
    reg id_jump_ctrl;
    
    wire [31:0] immediate;
    reg [31:0] id_immediate;
    
    wire [31:0] alu_result;
    reg [31:0] ex_alu_result;
    reg [31:0] mem_alu_result;
   
  
    
    reg [4:0] id_rd;
    reg [4:0] ex_rd;
    reg [4:0] mem_rd;
    
    reg [2:0]id_reg_ctrl;
    reg [2:0]ex_reg_ctrl;
    reg [2:0]mem_reg_ctrl;
    
    reg [6:0]id_alu_ctrl;
    
    reg [31:0] alu_in_1;
    wire [31:0] alu_in_2;
    
    reg id_mem_write;
    reg ex_mem_write;
    wire t_branch;

    wire [31:0] datamem_read;
    reg [31:0] mem_datamem_read;

    reg [31:0] regfile_data_in;


    assign instruction = if_instr;
    
    instrmem instrmem_inst(.address(pc), .data(instr));
    pc pc_inst (.clk(clk), .pc_write(1'b1), .pc_next(pc_next), .pc(pc), .rst(rst));

    // t_branch indicates if a branch can be taken, id_jump_ctrl and id_jalr_ctrl are control signals for JAL and JALR instructions.
    // if id_pc_ctrl = 0, then pc_next = pc + 4, else pc is branch_target_pc
    
    wire [31:0] branch_target_pc = id_jalr_ctrl?(alu_result & 32'hFFFFFFFE):id_pc + id_immediate;
    assign pc_next = (id_pc_ctrl & (t_branch|id_jump_ctrl|id_jalr_ctrl))?branch_target_pc: pc + 32'd4;   

    // It selects between rs2 and immediate value (R and I type)
    assign alu_in_2 = id_alu_ctrl[4]?id_immediate:id_rs2; 

    // It selects between rs1 and 0, we use 0 because in LUI we need to store the immediate directly in register file (rd), so we can add 0 and imm.
    always @(*) begin

        case(id_alu_ctrl[6:5])

            2'b00: alu_in_1 = id_rs1;
            2'b01: alu_in_1 = 32'b0;
            2'b10: alu_in_1 = id_pc;
            default: alu_in_1 = id_rs1;
        endcase

    end


    // This is to control the register data input between the output of ALU (R/I type), output of data memory (Load) and PC + 4 (for Jump Instructions)
    always @(*) begin
        case(mem_reg_ctrl[2:1])
            2'b00: regfile_data_in = mem_alu_result;
            2'b01: regfile_data_in = mem_datamem_read;
            2'b10: regfile_data_in = mem_pc + 32'd4;
            default: regfile_data_in = 32'd0; 
        endcase
        
    end

    
    always @(posedge clk) begin
        if (rst) begin
            
            if_instr <= 32'h00000013; 
            if_pc <= 32'd0;
            
            id_rs1 <= 32'd0;
            id_rs2 <= 32'd0;
            id_immediate <= 32'd0;
            id_rd <= 5'd0;
            id_alu_ctrl <= 7'b0;
            id_reg_ctrl <= 3'b0;
            id_mem_write <= 1'b0;
            id_pc <= 32'd0;
            id_pc_ctrl <= 1'b0;
            id_jump_ctrl <= 1'b0;
            id_jalr_ctrl <= 1'b0;
            
            ex_alu_result <= 32'd0;
            ex_rd <= 5'd0;
            ex_reg_ctrl <= 3'b0;
            ex_mem_write <= 1'b0;
            ex_rs2 <= 32'd0;
            ex_pc <= 32'd0;
            
            mem_alu_result <= 32'd0;
            mem_rd <= 5'd0;
            mem_reg_ctrl <= 3'b0;
            mem_datamem_read <= 32'd0;
            mem_pc <= 32'd0;
            
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
            id_jump_ctrl <= jump_ctrl;
            id_jalr_ctrl <= jalr_ctrl;
            
            ex_alu_result <= alu_result;
            ex_rd <= id_rd;
            ex_reg_ctrl <= id_reg_ctrl;
            ex_mem_write <= id_mem_write;
            ex_rs2 <= id_rs2;
            ex_pc <= id_pc;
            
            mem_alu_result <= ex_alu_result;
            mem_rd <= ex_rd;
            mem_reg_ctrl <= ex_reg_ctrl;
            mem_datamem_read <= datamem_read;
            mem_pc <= ex_pc;
        end
    end
    
   
    
   
   
    regfile rf (.rs1(if_instr[19:15]), .rs2(if_instr[24:20]),
     .rd(mem_rd), .write_data_in(regfile_data_in), .reg_write(mem_reg_ctrl[0]), .clk(clk), .rs1_read_o(rs1), .rs2_read_o(rs2));
    
    immgen immgen_inst(.instr(if_instr), .imm_ctrl(imm_ctrl), .imm(immediate));
   
    alu alu_inst (.alu_ctrl(id_alu_ctrl[3:0]), .a(alu_in_1), .b(alu_in_2), .alu_result(alu_result), .t_branch(t_branch));
    
    datamem dm (.address(ex_alu_result), .write_data(ex_rs2), .read_data(datamem_read), .clk(clk), .mem_write(ex_mem_write), .funct3(3'b010));

endmodule