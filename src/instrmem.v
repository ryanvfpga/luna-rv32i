
`timescale 1ns / 1ps

module instrmem(
    input [31:0] address,
    output [31:0] data
);
    reg [31:0] mem_loc [0:1023];
    assign data = mem_loc[address[31:2]];
    
endmodule
