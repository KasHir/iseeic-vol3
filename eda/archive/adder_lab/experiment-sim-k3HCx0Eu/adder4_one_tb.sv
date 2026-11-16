`timescale 1ns/1ps
module adder4_one_tb;
    reg [3:0] left_i, right_i;
    wire [4:0] sum_o;

    adder4 dut(.left_i(left_i), .right_i(right_i), .sum_o(sum_o));

    initial begin
        $dumpfile("adder4.vcd");
        $dumpvars(0, adder4_one_tb);
        left_i = 15;
        right_i = 1;
        #1;
        $display("15 + 1: expected=16 actual=%0d", sum_o);
        if (sum_o !== 5'd16)
            $fatal(1, "adder mismatch");
        $display("PASS: adder4 one check");
        $finish;
    end
endmodule
