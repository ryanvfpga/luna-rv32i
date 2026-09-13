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
    output reg [1:0] reg_ctrl, //LSB is reg_write, and MSB is the select bit for data to be written into regfile either from ALU/or from memory.
    output reg [5:0] alu_ctrl,
    output reg [2:0] imm_ctrl,
    output reg mem_write,
    output reg pc_ctrl
  
    );
    
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    
    
    always @(*) begin
        
        pc_ctrl = 1'b0;
        mem_write = 1'b0;
        alu_ctrl = 6'b000000;
        reg_ctrl = 2'b00;
        imm_ctrl = 3'b000;
          
        case(opcode)
        
            7'b0110011: begin // R-type
                alu_ctrl = {1'b0, 1'b0, funct7[5], funct3};
                reg_ctrl = 2'b01;
                
            end
            
            7'b0010011: begin //I-type Arithmetic
                if (funct3 == 3'b101 && funct7[5] == 1)
                      alu_ctrl = {1'b0, 1'b1, 1'b1, funct3};
                 else
                      alu_ctrl = {1'b0, 1'b1, 1'b0, funct3};
                 reg_ctrl = 2'b01;
                 
                 
            end
            
            7'b0000011: begin //LW
                
                alu_ctrl = {1'b0, 1'b1, 4'b0000};
                reg_ctrl = 2'b11;
            
            end
            
            7'b0100011: begin //SW
                
                alu_ctrl = {1'b0, 1'b1, 4'b0000};
                reg_ctrl = 2'b00;
                imm_ctrl = 3'b001;
                mem_write = 1'b1;
                
            end
            
            7'b1100011: begin // Branch Instructions
                
                imm_ctrl = 3'b011;
                pc_ctrl = 1;
                
                
                case(funct3)
                        3'b000: alu_ctrl = 4'b001010; // BEQ
                        3'b001: alu_ctrl = 4'b001011; // BNE
                        3'b100: alu_ctrl = 4'b001100; // BLT
                        3'b101: alu_ctrl = 4'b001101; // BGE
                        3'b110: alu_ctrl = 4'b001110; // BLTU
                        3'b111: alu_ctrl = 4'b001111; // BGEU
                        
                        default: alu_ctrl = 4'b000000;
                        
                    endcase
                    
                
            end
            
            
           
        endcase
    
    
    end
    
    
    
    
    
    
    
endmodule
