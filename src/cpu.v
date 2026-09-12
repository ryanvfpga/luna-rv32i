`timescale 1ns / 1ps

module cpu(
    input clk, rst
    );
    
    wire [31:0] instruction;
    wire reg_write;
    wire [5:0] alu_ctrl;
    
    datapath dp (.clk(clk), .rst(rst), .instruction(instruction), .reg_write(reg_write), .alu_ctrl(alu_ctrl));
    control cu (.instr(instruction), .reg_write(reg_write), .alu_ctrl(alu_ctrl));
    
endmodule
