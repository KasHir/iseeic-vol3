`timescale 1ns/1ps
module selector4_tb;
    reg [1:0] select;
    reg [3:0] a, b, in_port;
    wire [3:0] source;
    selector4 dut (.select(select), .a(a), .b(b), .in_port(in_port), .source(source));

    task check(input [8*32-1:0] name, input [3:0] expected);
        begin
            #1;
            $display("%0s: select=%0d A=%0d B=%0d IN=%0d output=%0d expected=%0d",
                     name, select, a, b, in_port, source, expected);
            if (source !== expected) $fatal(1, "FAIL: %0s", name);
        end
    endtask

    initial begin
        $dumpfile("selector4.vcd");
        $dumpvars(0, selector4_tb);
        a=2; b=5; in_port=9;
        select=0; check("select A", 2);
        select=1; check("select B", 5);
        select=2; check("select input", 9);
        select=3; check("select zero", 0);
        select=1; check("B before change", 5);
        b=7; check("B after change", 7);
        a=6; in_port=12; check("unselected inputs change", 7);
        select=3; check("zero before change", 0);
        a=1; b=3; in_port=8; check("zero after change", 0);
        $display("PASS: selector4");
        $finish;
    end
endmodule
