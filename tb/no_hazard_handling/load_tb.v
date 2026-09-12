`timescale 1ns / 1ps

module load_tb();
    reg clk;
    reg rst;
    integer err_count;

    cpu dut (.clk(clk), .rst(rst));

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        err_count = 0;

  
        dut.dp.instrmem_inst.mem_loc[0] = 32'h0000a283; // lw x5, 0(x1)   -> load from addr 0
        dut.dp.instrmem_inst.mem_loc[1] = 32'h0040a303; // lw x6, 4(x1)   -> load from addr 4
        dut.dp.instrmem_inst.mem_loc[2] = 32'hffc12383; // lw x7, -4(x2)  -> load from addr 4 (8-4)
        dut.dp.instrmem_inst.mem_loc[3] = 32'h0001a403; // lw x8, 0(x3)   -> load from addr 100


        dut.dp.rf.regs[1] = 32'd0;   // base addr 0
        dut.dp.rf.regs[2] = 32'd8;   // base addr 8
        dut.dp.rf.regs[3] = 32'd100; // base addr 100

  
        dut.dp.dm.regs[0]  = 32'h11223344; // addr 0
        dut.dp.dm.regs[1]  = 32'h55667788; // addr 4
        dut.dp.dm.regs[2]  = 32'h99aabbcc; // addr 8
        dut.dp.dm.regs[25] = 32'hdeadbeef; // addr 100 

        #15 rst = 0;

   
        #150;

        // check results
        if (dut.dp.rf.regs[5] !== 32'h11223344) begin $display("LW 1 failed: expected 11223344, got %h", dut.dp.rf.regs[5]); err_count = err_count + 1; end
        if (dut.dp.rf.regs[6] !== 32'h55667788) begin $display("LW 2 failed: expected 55667788, got %h", dut.dp.rf.regs[6]); err_count = err_count + 1; end
        if (dut.dp.rf.regs[7] !== 32'h55667788) begin $display("LW 3 failed: expected 55667788, got %h", dut.dp.rf.regs[7]); err_count = err_count + 1; end
        if (dut.dp.rf.regs[8] !== 32'hdeadbeef) begin $display("LW 4 failed: expected deadbeef, got %h", dut.dp.rf.regs[8]); err_count = err_count + 1; end

        if (err_count == 0) begin
            $display("Test finished. All LW instructions passed.");
        end else begin
            $display("Test finished with %d errors.", err_count);
        end

        $finish;
    end
endmodule