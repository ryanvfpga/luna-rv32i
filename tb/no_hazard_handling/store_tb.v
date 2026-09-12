`timescale 1ns / 1ps

module store_tb();
    reg clk;
    reg rst;
    integer err_count;

    cpu dut (.clk(clk), .rst(rst));

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        err_count = 0;

      
        dut.dp.instrmem_inst.mem_loc[0] = 32'h0050a023; // sw x5, 0(x1)   -> store x5 to addr 0
        dut.dp.instrmem_inst.mem_loc[1] = 32'h0060a223; // sw x6, 4(x1)   -> store x6 to addr 4
        dut.dp.instrmem_inst.mem_loc[2] = 32'hfe712e23; // sw x7, -4(x2)  -> store x7 to addr 8 (12-4)
        dut.dp.instrmem_inst.mem_loc[3] = 32'h0081a023; // sw x8, 0(x3)   -> store x8 to addr 100

        // nops 
        dut.dp.instrmem_inst.mem_loc[4] = 32'h00000013;
        dut.dp.instrmem_inst.mem_loc[5] = 32'h00000013;
        dut.dp.instrmem_inst.mem_loc[6] = 32'h00000013;
        dut.dp.instrmem_inst.mem_loc[7] = 32'h00000013;
        dut.dp.instrmem_inst.mem_loc[8] = 32'h00000013;

        // init base registers for addressing
        dut.dp.rf.regs[1] = 32'd0;   // base addr 0
        dut.dp.rf.regs[2] = 32'd12;  // base addr 12
        dut.dp.rf.regs[3] = 32'd100; // base addr 100

        // init registers with data to be stored into memory
        dut.dp.rf.regs[5] = 32'h11223344; 
        dut.dp.rf.regs[6] = 32'h55667788; 
        dut.dp.rf.regs[7] = 32'h99aabbcc; 
        dut.dp.rf.regs[8] = 32'hdeadbeef;   
        
        //clearing datamemory for testing
        dut.dp.dm.regs[0]  = 32'd0;
        dut.dp.dm.regs[1]  = 32'd0;
        dut.dp.dm.regs[2]  = 32'd0;
        dut.dp.dm.regs[25] = 32'd0;

        #15 rst = 0;

        // wait for 4 instrs + 5 nops to clear the MEM stage
        #150;


        if (dut.dp.dm.regs[0]  !== 32'h11223344) begin $display("SW 1 failed: expected 11223344, got %h", dut.dp.dm.regs[0]);  err_count = err_count + 1; end
        if (dut.dp.dm.regs[1]  !== 32'h55667788) begin $display("SW 2 failed: expected 55667788, got %h", dut.dp.dm.regs[1]);  err_count = err_count + 1; end
        if (dut.dp.dm.regs[2]  !== 32'h99aabbcc) begin $display("SW 3 failed: expected 99aabbcc, got %h", dut.dp.dm.regs[2]);  err_count = err_count + 1; end
        if (dut.dp.dm.regs[25] !== 32'hdeadbeef) begin $display("SW 4 failed: expected deadbeef, got %h", dut.dp.dm.regs[25]); err_count = err_count + 1; end

        if (err_count == 0) begin
            $display("Test finished. All SW instructions passed.");
        end else begin
            $display("Test finished with %d errors.", err_count);
        end

        $finish;
    end
endmodule