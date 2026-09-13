`timescale 1ns / 1ps

module branch_tb();
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

        // Fill instruction memory with NOPs initially, 
        // because we do not have pipeline flushes or ways of dealing with control hazards.
        
        for (i = 0; i < 64; i = i + 1) begin
            dut.dp.instrmem_inst.mem_loc[i] = 32'h00000013; 
        end
        
        // Initialize Registers 
        dut.dp.rf.regs[1] = 32'd10;         // x1 = 10
        dut.dp.rf.regs[2] = 32'd10;         // x2 = 10
        dut.dp.rf.regs[3] = 32'd20;         // x3 = 20
        dut.dp.rf.regs[4] = 32'hFFFFFFFB;   // x4 = -5 
        
        
        // Test 1: BEQ (Branch if Equal)
        // x1 == x2 (10 == 10) -> TAKEN
        dut.dp.instrmem_inst.mem_loc[0] = 32'h00208A63; // beq x1, x2, 20
        dut.dp.instrmem_inst.mem_loc[5] = 32'h00100513; // addi x10, x0, 1 (Target at PC=20)
        
        // Test 2: BNE (Branch if Not Equal)
        // x1 != x3 (10 != 20) -> TAKEN
        dut.dp.instrmem_inst.mem_loc[10] = 32'h00309A63; // bne x1, x3, 20
        dut.dp.instrmem_inst.mem_loc[15] = 32'h00100593; // addi x11, x0, 1 (Target at PC=60)

        // Test 3: BLT (Branch if Less Than, Signed)
        // x4 < x1 (-5 < 10) -> TAKEN
        dut.dp.instrmem_inst.mem_loc[20] = 32'h00124A63; // blt x4, x1, 20
        dut.dp.instrmem_inst.mem_loc[25] = 32'h00100613; // addi x12, x0, 1 (Target at PC=100)

        // Test 4: BGE (Branch if Greater/Equal, Signed)
        // x1 >= x4 (10 >= -5) -> TAKEN
        dut.dp.instrmem_inst.mem_loc[30] = 32'h0040DA63; // bge x1, x4, 20
        dut.dp.instrmem_inst.mem_loc[35] = 32'h00100693; // addi x13, x0, 1 (Target at PC=140)

        // Test 5: BLTU (Branch if Less Than, Unsigned)
        // x1 < x4 (10 < 0xFFFFFFFB) -> TAKEN
        dut.dp.instrmem_inst.mem_loc[40] = 32'h0040EA63; // bltu x1, x4, 20
        dut.dp.instrmem_inst.mem_loc[45] = 32'h00100713; // addi x14, x0, 1 (Target at PC=180)

        // Test 6: BGEU (Branch if Greater/Equal, Unsigned)
        // x4 >= x1 (0xFFFFFFFB >= 10) -> TAKEN
        dut.dp.instrmem_inst.mem_loc[50] = 32'h00127A63; // bgeu x4, x1, 20
        dut.dp.instrmem_inst.mem_loc[55] = 32'h00100793; // addi x15, x0, 1 (Target at PC=220)


  
        // Clear target registers
        dut.dp.rf.regs[10] = 32'd0;
        dut.dp.rf.regs[11] = 32'd0;
        dut.dp.rf.regs[12] = 32'd0;
        dut.dp.rf.regs[13] = 32'd0;
        dut.dp.rf.regs[14] = 32'd0;
        dut.dp.rf.regs[15] = 32'd0;

  
        #15 rst = 0;

        #800;
        
        // If the branches were correctly taken, these registers should now hold '1'
        if (dut.dp.rf.regs[10] !== 32'd1) begin $display("BEQ failed: expected branch to hit, but x10 is %0d", dut.dp.rf.regs[10]); err_count = err_count + 1; end
        if (dut.dp.rf.regs[11] !== 32'd1) begin $display("BNE failed: expected branch to hit, but x11 is %0d", dut.dp.rf.regs[11]); err_count = err_count + 1; end
        if (dut.dp.rf.regs[12] !== 32'd1) begin $display("BLT failed: expected branch to hit, but x12 is %0d", dut.dp.rf.regs[12]); err_count = err_count + 1; end
        if (dut.dp.rf.regs[13] !== 32'd1) begin $display("BGE failed: expected branch to hit, but x13 is %0d", dut.dp.rf.regs[13]); err_count = err_count + 1; end
        if (dut.dp.rf.regs[14] !== 32'd1) begin $display("BLTU failed: expected branch to hit, but x14 is %0d", dut.dp.rf.regs[14]); err_count = err_count + 1; end
        if (dut.dp.rf.regs[15] !== 32'd1) begin $display("BGEU failed: expected branch to hit, but x15 is %0d", dut.dp.rf.regs[15]); err_count = err_count + 1; end

        if (err_count == 0) begin
            $display("Test finished. All Branch instructions passed!");
        end else begin
            $display("Test finished with %d errors.", err_count);
        end

        $finish;
    end
endmodule