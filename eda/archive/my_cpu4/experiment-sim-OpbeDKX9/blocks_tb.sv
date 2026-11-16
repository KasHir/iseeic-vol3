`timescale 1ns/1ps
module blocks_tb;
    reg [3:0] op,a,b,inp,imm;
    reg carry;
    reg [1:0] sel;
    wire [1:0] decoded;
    wire la,lb,lo,lp;
    wire [4:0] sum;
    reg [5:0] expected;
    integer i,j,k,s,c,src,count=0;
    td4_decode d(op,carry,decoded,la,lb,lo,lp);
    td4_datapath p(sel,a,b,inp,imm,sum);
    initial begin
        // Literal table derived from the final schematic; {select,A,B,OUT,PC}.
        for(c=0;c<2;c=c+1) for(i=0;i<16;i=i+1) begin
            op=i; carry=c;
            case(i)
                0:expected=6'b001000; 1:expected=6'b011000;
                2:expected=6'b101000; 3:expected=6'b111000;
                4:expected=6'b000100; 5:expected=6'b010100;
                6:expected=6'b100100; 7:expected=6'b110100;
                8,9:expected=6'b010010; 10,11:expected=6'b110010;
                12:expected=c ? 6'b010000 : 6'b010001;
                13:expected=6'b010001;
                14:expected=c ? 6'b110000 : 6'b110001;
                15:expected=6'b110001;
            endcase
            #1;
            if({decoded,la,lb,lo,lp} !== expected) $fatal(1,"decoder op=%x C=%b",op,carry);
            count=count+1;
        end
        // Exhaustive combinational inputs, including unselected sources.
        for(s=0;s<4;s=s+1) for(i=0;i<16;i=i+1)
          for(j=0;j<16;j=j+1) for(k=0;k<16;k=k+1)
            for(c=0;c<16;c=c+1) begin
                sel=s; a=i; b=j; inp=k; imm=c;
                case(s) 0:src=i; 1:src=j; 2:src=k; 3:src=0; endcase
                #1;
                if(sum !== (src+c)) $fatal(1,"datapath");
                count=count+1;
            end
        $display("PASS: blocks %0d checks",count); $finish;
    end
endmodule
