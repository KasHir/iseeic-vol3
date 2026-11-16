`timescale 1ns/1ps
module adder4_compare_tb;
    reg [3:0] left_i, right_i;
    wire [4:0] rtl_sum, cell_sum;
    reg [4:0] expected;
    integer left_value, right_value, checks = 0;

    adder4 rtl(.left_i(left_i), .right_i(right_i), .sum_o(rtl_sum));
    adder4_sky130 cells(.left_i(left_i), .right_i(right_i), .sum_o(cell_sum));

    initial begin
        for (left_value = 0; left_value < 16; left_value = left_value + 1)
            for (right_value = 0; right_value < 16; right_value = right_value + 1) begin
                left_i = left_value;
                right_i = right_value;
                expected = left_value + right_value;
                #1;
                if (rtl_sum !== expected || cell_sum !== expected)
                    $fatal(1, "%0d + %0d: expected=%0d rtl=%0d cells=%0d",
                           left_i, right_i, expected, rtl_sum, cell_sum);
                checks = checks + 1;
            end
        $display("PASS: RTL and SKY130 cells match expected sums for %0d inputs", checks);
        $finish;
    end
endmodule
