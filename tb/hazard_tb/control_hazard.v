`timescale 1ns / 1ps

module control_hazard();
    reg clk;
    reg rst;
    integer err_count;

    cpu dut (.clk(clk), .rst(rst));

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        err_count = 0;

        dut.dp.rf.regs[1] = 32'd10;
        dut.dp.rf.regs[2] = 32'd10;
        dut.dp.rf.regs[3] = 32'd0;

        // Test 1: BEQ (Branch Taken - skips instruction at loc[1])
        dut.dp.instrmem_inst.mem_loc[0] = 32'h00208463; // beq x1, x2, 8
        dut.dp.instrmem_inst.mem_loc[1] = 32'h00500213; // addi x4, x0, 5 (flushed)
        dut.dp.instrmem_inst.mem_loc[2] = 32'h01400213; // addi x4, x0, 20 (executed)
        dut.dp.instrmem_inst.mem_loc[3] = 32'h00000013; // nop

        // Test 2: JAL (Unconditional Jump - skips instruction at loc[5])
        dut.dp.instrmem_inst.mem_loc[4] = 32'h008002ef; // jal x5, 8
        dut.dp.instrmem_inst.mem_loc[5] = 32'h00f00313; // addi x6, x0, 15 (flushed)
        dut.dp.instrmem_inst.mem_loc[6] = 32'h01e00313; // addi x6, x0, 30 (executed)
        dut.dp.instrmem_inst.mem_loc[7] = 32'h00000013; // nop

        // Test 3: JALR (Jump and Link Register - skips instruction at loc[9])
        dut.dp.rf.regs[7] = 32'd40; // Byte address corresponding to mem_loc[10]
        dut.dp.instrmem_inst.mem_loc[8]  = 32'h00038467; // jalr x8, x7, 0
        dut.dp.instrmem_inst.mem_loc[9]  = 32'h06300493; // addi x9, x0, 99 (flushed)
        dut.dp.instrmem_inst.mem_loc[10] = 32'h02800493; // addi x9, x0, 40 (target execution)

        // NOP padding to flush pipeline
        dut.dp.instrmem_inst.mem_loc[11] = 32'h00000013;
        dut.dp.instrmem_inst.mem_loc[12] = 32'h00000013;
        dut.dp.instrmem_inst.mem_loc[13] = 32'h00000013;
        dut.dp.instrmem_inst.mem_loc[14] = 32'h00000013;

        #15 rst = 0;
        #200;

        if (dut.dp.rf.regs[4] !== 32'd20) begin
            $display("Test 1 failed (BEQ flush): x4 expected 20, got %d", dut.dp.rf.regs[4]);
            err_count = err_count + 1;
        end
        if (dut.dp.rf.regs[6] !== 32'd30) begin
            $display("Test 2 failed (JAL flush): x6 expected 30, got %d", dut.dp.rf.regs[6]);
            err_count = err_count + 1;
        end
        if (dut.dp.rf.regs[9] !== 32'd40) begin
            $display("Test 3 failed (JALR flush): x9 expected 40, got %d", dut.dp.rf.regs[9]);
            err_count = err_count + 1;
        end

        if (err_count == 0) begin
            $display("All control hazard tests passed successfully.");
        end else begin
            $display("Tests failed with %d errors.", err_count);
        end

        $finish;
    end
endmodule