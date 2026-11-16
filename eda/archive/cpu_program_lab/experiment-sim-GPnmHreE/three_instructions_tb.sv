`timescale 1ns/1ps
module three_instructions_tb;
    reg clk, reset_n;
    wire [3:0] pc, out_port;
    reg [7:0] rom [0:15];
    wire [7:0] instruction = rom[pc];
    reg [3:0] pc_before, b_before, out_before;
    reg [7:0] instruction_before;
    integer add_value, i, csv;
    my_cpu4 dut (.clk_i(clk), .reset_n_i(reset_n), .instruction_i(instruction),
                 .in_port_i(4'd0), .program_addr_o(pc), .out_port_o(out_port));

    task step(input integer number, input [7:0] expected_instruction,
              input [3:0] expected_b, expected_out, expected_pc);
        begin
            pc_before=pc; instruction_before=instruction;
            b_before=dut.b; out_before=out_port;
            if (pc_before !== number || instruction_before !== expected_instruction)
                $fatal(1, "FAIL: unexpected instruction before step %0d", number);
            #5 clk=1; #1;
            $fdisplay(csv, "%0d,%0d,%02h,%0d,%0d,%0d,%0d,%0d", number,
                      pc_before, instruction_before, b_before, out_before, dut.b, out_port, pc);
            $display("step=%0d pc=%0d instruction=%02h B=%0d OUT=%0d next_pc=%0d",
                     number, pc_before, instruction_before, dut.b, out_port, pc);
            if (dut.b !== expected_b || out_port !== expected_out || pc !== expected_pc)
                $fatal(1, "FAIL: step %0d", number);
            #4 clk=0;
        end
    endtask

    initial begin
        $dumpfile("three_instructions.vcd"); $dumpvars(0, three_instructions_tb);
        if (!$value$plusargs("ADD=%d", add_value) || (add_value != 3 && add_value != 4))
            $fatal(1, "ADD must be 3 or 4");
        for (i=0; i<16; i=i+1) rom[i]=8'h00;
        rom[0]=8'h72; rom[1]=8'h50 + add_value; rom[2]=8'h90;
        csv=$fopen("three_instructions.csv", "w");
        if (!csv) $fatal(1, "Cannot open CSV");
        $fdisplay(csv, "step,pc_before,instruction_hex,b_before,out_before,b_after,out_after,pc_after");
        clk=0; reset_n=1; #1 reset_n=0; #1;
        if (dut.b !== 0 || out_port !== 0 || pc !== 0) $fatal(1, "FAIL: reset");
        $display("reset: B=%0d OUT=%0d PC=%0d", dut.b, out_port, pc);
        reset_n=1;
        step(0, 8'h72, 2, 0, 1);
        if (add_value == 3) begin
            step(1, 8'h53, 5, 0, 2); step(2, 8'h90, 5, 5, 3);
        end else begin
            step(1, 8'h54, 6, 0, 2); step(2, 8'h90, 6, 6, 3);
        end
        $fclose(csv); $display("PASS: three instructions"); $finish;
    end
endmodule
