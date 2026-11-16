module adder4 (
    input wire [3:0] left_i, right_i,
    output wire [4:0] sum_o
);
    assign sum_o = {1'b0, left_i} + {1'b0, right_i};
endmodule
