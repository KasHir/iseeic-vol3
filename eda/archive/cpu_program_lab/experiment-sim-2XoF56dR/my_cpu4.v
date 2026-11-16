// TD4 functional core. Source: CPU no Tsukurikata, printed pp.211,243-244,267,275.
// External combinational program ROM. No discrete-IC propagation delays.
module td4_decode (
    input wire [3:0] op, input wire carry,
    output wire [1:0] select,
    output wire load_a, load_b, load_out, load_pc
);
    assign select = {op[1], op[0] | op[3]};
    assign load_a   = ~op[3] & ~op[2];
    assign load_b   = ~op[3] &  op[2];
    assign load_out =  op[3] & ~op[2];
    assign load_pc  =  op[3] &  op[2] & (op[0] | ~carry);
endmodule

module td4_datapath (
    input wire [1:0] select,
    input wire [3:0] a, b, in_port, immediate,
    output wire [4:0] sum
);
    wire [3:0] source;
    assign source = select == 2'd0 ? a :
                    select == 2'd1 ? b :
                    select == 2'd2 ? in_port : 4'd0;
    assign sum = {1'b0, source} + {1'b0, immediate};
endmodule

module my_cpu4 (
    input wire clk_i, input wire reset_n_i,
    input wire [7:0] instruction_i,
    input wire [3:0] in_port_i,
    output wire [3:0] program_addr_o,
    output reg [3:0] out_port_o
);
    reg [3:0] a, b, pc;
    reg carry;
    wire [1:0] select;
    wire [4:0] sum;
    wire load_a, load_b, load_out, load_pc;
    assign program_addr_o = pc;
    td4_decode decode(instruction_i[7:4], carry, select,
                      load_a, load_b, load_out, load_pc);
    td4_datapath datapath(select, a, b, in_port_i, instruction_i[3:0], sum);
    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            a <= 0; b <= 0; out_port_o <= 0; pc <= 0; carry <= 0;
        end else begin
            if (load_a) a <= sum[3:0];
            if (load_b) b <= sum[3:0];
            if (load_out) out_port_o <= sum[3:0];
            pc <= load_pc ? sum[3:0] : pc + 4'd1;
            carry <= sum[4];
        end
    end
endmodule
