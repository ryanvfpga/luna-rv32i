`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.09.2026 11:50:01
// Design Name: 
// Module Name: control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module control(
    input [31:0] instr,
    output reg reg_write,
    output reg [3:0] alu_ctrl
    
    );
    
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    
    
    always @(*) begin
    
        case(opcode)
        
            7'b0110011: begin
                alu_ctrl = {funct7[5], funct3};
                reg_write = 1'b1;
            end
            
            default: begin
                
                alu_ctrl = 4'b0000;
                reg_write = 1'b0;
            
            end
        
        endcase
    
    
    end
    
    
    
    
    
    
    
endmodule
