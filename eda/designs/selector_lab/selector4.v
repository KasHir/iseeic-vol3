module selector4 (
    input wire [1:0] select,
    input wire [3:0] a, b, in_port,
    output wire [3:0] source
);
    assign source = select == 2'd0 ? a :
                    select == 2'd1 ? b :
                    select == 2'd2 ? in_port : 4'd0;
endmodule
