`timescale 1ns / 1ps

module datamem(
    input [31:0] address,
    input [31:0] write_data,
    output [31:0] read_data,
    input clk,
    input mem_write,
    input [2:0] funct3
    );
    
    reg [31:0] regs [0:1023];
    
    assign read_data = regs[address[31:2]];
    
    always @(posedge clk) begin
        if (mem_write) begin
            case(funct3)
                3'b000: begin
                    case(address[1:0])
                        2'b00: regs[address[31:2]][7:0]   <= write_data[7:0];
                        2'b01: regs[address[31:2]][15:8]  <= write_data[7:0];
                        2'b10: regs[address[31:2]][23:16] <= write_data[7:0];
                        2'b11: regs[address[31:2]][31:24] <= write_data[7:0];
                    endcase
                end
                3'b001: begin
                    if(address[1])
                        regs[address[31:2]][31:16] <= write_data[15:0];
                    else
                        regs[address[31:2]][15:0]  <= write_data[15:0];
                end
                3'b010: begin
                    regs[address[31:2]] <= write_data;
                end
            endcase
        end
    end
    
endmodule