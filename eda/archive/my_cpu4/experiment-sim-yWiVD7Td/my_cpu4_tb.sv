`timescale 1ns/1ps
module my_cpu4_tb;
    reg clk=0, reset_n=1;
    reg [7:0] instruction=0;
    reg [3:0] input_port=0;
    wire [3:0] pc_out, output_port;
    my_cpu4 dut(clk, reset_n, instruction, input_port, pc_out, output_port);
    integer checks=0, cycle=0, trace;
    integer ma,mb,mo,mp,mc, total, opcode, imm;
    integer ins, value, c, pc, n;
    reg [7:0] rom[0:15];
    // Independent instruction-by-instruction model, including physical aliases.
    // Does not reuse decoder Boolean equations or RTL combinational signals.
    task model_step;
        input [7:0] code;
        input integer inp;
        begin
            opcode=code/16; imm=code%16;
            case(opcode)
                0,4: total=ma+imm;
                1,5,8,9,12,13: total=mb+imm;
                2,6: total=inp+imm;
                default: total=imm;
            endcase
            case(opcode)
                0,1,2,3: ma=total%16;
                4,5,6,7: mb=total%16;
                8,9,10,11: mo=total%16;
            endcase
            case(opcode)
                12,14: if(mc==0) mp=total%16; else mp=(mp+1)%16;
                13,15: mp=total%16;
                default: mp=(mp+1)%16;
            endcase
            mc=total/16;
        end
    endtask
    task check_state;
        begin
            checks=checks+1;
            if(dut.a !== ma[3:0] || dut.b !== mb[3:0] ||
               output_port !== mo[3:0] || pc_out !== mp[3:0] || dut.carry !== mc[0])
                $fatal(1,"Mismatch code=%02x A=%x/%x B=%x/%x OUT=%x/%x PC=%x/%x C=%b/%b",
                       instruction,dut.a,ma,dut.b,mb,output_port,mo,pc_out,mp,dut.carry,mc);
        end
    endtask
    task tick;
        begin
            #5; model_step(instruction,input_port); clk=1;
            #1; check_state;
            if(trace) begin
                $fdisplay(trace,"%0d,%02x,%0d,%0d,%0d,%0d,%0d,%0d",cycle,instruction,input_port,dut.a,dut.b,output_port,pc_out,dut.carry);
                cycle=cycle+1;
            end
            #4; clk=0;
        end
    endtask
    task reset_core;
        begin
            clk=0; reset_n=1; #1; reset_n=0;
            ma=0; mb=0; mo=0; mp=0; mc=0;
            #1; check_state; // Reset must work without a clock edge.
            clk=1; #1; check_state; clk=0;
            reset_n=1; #1;
        end
    endtask
    initial begin
        trace=0;
        reset_core;
        // All 256 instruction bytes, all source values, both prior carries,
        // and every prior PC. State injection is test-only, at clock low.
        for(ins=0;ins<256;ins=ins+1)
          for(value=0;value<16;value=value+1)
            for(c=0;c<2;c=c+1)
              for(pc=0;pc<16;pc=pc+1) begin
                ma=value; mb=15-value; mo=(value+7)%16; mp=pc; mc=c;
                dut.a=ma; dut.b=mb; dut.out_port_o=mo; dut.pc=mp; dut.carry=mc;
                instruction=ins; input_port=(value+3)%16;
                tick;
              end
        reset_core;
        // Directed carry lifecycle: JNC consumes OLD carry, then clears it.
        instruction=8'h3f; tick; // MOV A,15
        instruction=8'h01; tick; // ADD A,1 -> carry
        if(dut.carry !== 1 || dut.a !== 0) $fatal(1,"ADD overflow");
        instruction=8'he9; tick; // JNC does not jump
        if(pc_out !== 3 || dut.carry !== 0) $fatal(1,"JNC old carry");
        tick; // JNC now jumps
        if(pc_out !== 9) $fatal(1,"JNC after clear");
        // Noncanonical IN adds its immediate and can produce carry.
        input_port=15; instruction=8'h21; tick;
        if(dut.a !== 0 || dut.carry !== 1) $fatal(1,"IN immediate extension");
        // Reset from populated state, then reset held across a clock.
        instruction=8'hbf; tick; reset_core;
        // Program using every normal opcode, external asynchronous ROM.
        for(n=0;n<16;n=n+1) rom[n]=8'hff;
        rom[0]=8'h20; rom[1]=8'h40; rom[2]=8'h01; rom[3]=8'h10;
        rom[4]=8'h51; rom[5]=8'h90; rom[6]=8'h30; rom[7]=8'h7f;
        rom[8]=8'h51; rom[9]=8'he0; rom[10]=8'h60; rom[11]=8'hb5;
        rom[12]=8'hfd;
        input_port=6;
        for(n=0;n<13;n=n+1) begin instruction=rom[pc_out]; tick; end
        if(dut.a !== 0 || dut.b !== 6 || output_port !== 5 || pc_out !== 13)
            $fatal(1,"All-normal-opcode program");
        reset_core;
        // Representative count/overflow program: B=0..15, OUT B, add, JNC.
        for(n=0;n<16;n=n+1) rom[n]=8'hf0;
        rom[0]=8'h70; rom[1]=8'h90; rom[2]=8'h51; rom[3]=8'he1; rom[4]=8'hb0;
        trace=$fopen("count_trace.csv","w");
        if(!trace) $fatal(1,"trace open");
        $fdisplay(trace,"cycle,instruction_hex,input,a,b,out,pc_after,carry_after");
        $dumpfile("count.vcd"); $dumpvars(0,dut);
        for(n=0;n<50;n=n+1) begin instruction=rom[pc_out]; tick; end
        if(output_port !== 0 || pc_out !== 5) $fatal(1,"count/overflow completion");
        $fclose(trace); trace=0;
        $display("PASS: my_cpu4 %0d state checks; all instruction bytes/source values/carries/PCs; reset and programs", checks);
        $finish;
    end
    initial begin #2000000; $fatal(1,"timeout"); end
endmodule
