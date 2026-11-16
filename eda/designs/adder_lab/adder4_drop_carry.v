// Intentionally wrong alternative. Compile instead of adder4.v.
module adder4 (
    input wire [3:0] left_i, right_i,
    output wire [4:0] sum_o
);
    wire [3:0] low_sum;
    assign low_sum = left_i + right_i;
    assign sum_o = {1'b0, low_sum};
endmodule
