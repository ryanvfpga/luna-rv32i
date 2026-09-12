`timescale 1ns / 1ps

module cpu(
    input clk, rst
    );
    
    wire [31:0] instruction;
    wire [1:0] reg_ctrl;
    wire [5:0] alu_ctrl;
    wire [2:0] imm_ctrl;
 
    datapath dp (.clk(clk), .rst(rst), .instruction(instruction), .reg_ctrl(reg_ctrl), .alu_ctrl(alu_ctrl), .imm_ctrl(imm_ctrl));
    control cu (.instr(instruction), .reg_ctrl(reg_ctrl), .alu_ctrl(alu_ctrl), .imm_ctrl(imm_ctrl));
    
endmodule
