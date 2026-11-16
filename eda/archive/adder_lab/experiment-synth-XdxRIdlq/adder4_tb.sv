`timescale 1ns/1ps
module adder4_tb;
    reg [3:0] left_i, right_i;
    wire [4:0] sum_o;
    integer checks = 0;

    adder4 dut(.left_i(left_i), .right_i(right_i), .sum_o(sum_o));

    task check;
        input [3:0] left_value, right_value;
        input [4:0] expected;
        begin
            left_i = left_value;
            right_i = right_value;
            #1;
            $display("%0d + %0d: expected=%0d actual=%0d",
                     left_i, right_i, expected, sum_o);
            if (sum_o !== expected)
                $fatal(1, "adder mismatch");
            checks = checks + 1;
        end
    endtask

    initial begin
        $dumpfile("adder4.vcd");
        $dumpvars(0, adder4_tb);
        check(0, 0, 0);
        check(2, 3, 5);
        check(9, 0, 9);
        check(15, 1, 16);
        check(15, 15, 30);
        $display("PASS: adder4 %0d checks", checks);
        $finish;
    end
endmodule
