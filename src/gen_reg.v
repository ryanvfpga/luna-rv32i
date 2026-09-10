module gen_reg(
    input en,
    input clk,
    output reg [31:0]out,
    input [31:0]in
    );
    
    always @(posedge clk)begin
        if(en)
            out <= in;

    end
    
    
endmodule