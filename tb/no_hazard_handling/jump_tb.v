`timescale 1ns / 1ps

module jump_tb();
    reg clk;
    reg rst;
    integer err_count;
    integer i;

    cpu dut (.clk(clk), .rst(rst));

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        err_count = 0;

        // Clear memory with NOPs
        for (i = 0; i < 64; i = i + 1) begin
            dut.dp.instrmem_inst.mem_loc[i] = 32'h00000013;
        end

        // JAL x1, 24 -> jumps from PC=0 to PC=24 (word 6), saves PC+4 (4) to x1
        dut.dp.instrmem_inst.mem_loc[0] = 32'h018000ef;

        // Target: addi x5, x0, 10
        dut.dp.instrmem_inst.mem_loc[6] = 32'h00a00293;

        // Clear regs used
        dut.dp.rf.regs[1] = 32'd0;
        dut.dp.rf.regs[5] = 32'd0;

        #15 rst = 0;

        // Wait for pipeline to finish
        #200;

        if (dut.dp.rf.regs[1] !== 32'd4) begin
            $display("JAL link failed: expected 4 in x1, got %0d", dut.dp.rf.regs[1]);
            err_count = err_count + 1;
        end

        if (dut.dp.rf.regs[5] !== 32'd10) begin
            $display("JAL target failed: expected 10 in x5, got %0d", dut.dp.rf.regs[5]);
            err_count = err_count + 1;
        end

        if (err_count == 0) begin
            $display("Test finished. JAL passed.");
        end else begin
            $display("Test finished with %0d errors.", err_count);
        end

        $finish;
    end
endmodule