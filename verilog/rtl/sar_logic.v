`default_nettype none

module sar_logic (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
    input clk,
    input comp_in,

    output [20:0] sample,
    output wire [20:0] io_oeb);

    assign io_oeb = 21'b000000000000000000000;

    wire comp_en;
    wire q5,q4,q3,q2,q1,q0;
    wire sw5,sw5b,sw4,sw4b,sw3,sw3b,sw2,sw2b,sw1,sw1b,sw0,sw0b;
    wire d1,d2,d3,d4,d5,d6;
    wire d1b,d2b,d3b,d4b,d5b,d6b;
    wire r0,r1,r2,r3,r4,r5,rs;

    count_monitor ccc ( .clk(clk),
                        .comp_en (comp_en),
                        .sample (sample),
                        .d1 (d1),
                        .d1b (d1b),
                        .d2 (d2),
                        .d2b (d2b),
                        .d3 (d3),
                        .d3b (d3b),
                        .d4 (d4),
                        .d4b (d4b),
                        .d5 (d5),
                        .d5b (d5b),
                        .d6 (d6),
                        .d6b (d6b),
                        .rs (rs));
    
    hold hhh ( .comp_in(comp_in),
                .sample(sample),
                .d1b(d1b),
                .d2b(d2b),
                .d3b(d3b),
                .d4b(d4b),
                .d5b(d5b),
                .d6b(d6b),
                .r5(r5),
                .r4(r4),
                .r3(r3),
                .r2(r2),
                .r1(r1),
                .r0(r0));

    qout qqq ( .sample(sample),
                .rs(rs),
                .r5(r5),
                .r4(r4),
                .r3(r3),
                .r2(r2),
                .r1(r1),
                .r0(r0),
                .q5(q5),
                .q4(q4),
                .q3(q3),
                .q2(q2),
                .q1(q1),
                .q0(q0));


    
    assign sw5 = sample | r5 | d6;
    assign sw5b = ~sw5;
    assign sw4 = sample | r4 | d5;
    assign sw4b = ~sw4;
    assign sw3 = sample | r3 | d4;
    assign sw3b = ~sw3;
    assign sw2 = sample | r2 | d3;
    assign sw2b = ~sw2;
    assign sw1 = sample | r1 | d2;
    assign sw1b = ~sw1;
    assign sw0 = sample | r0 | d1;
    assign sw0b = ~sw0;

    
    // + sw5*2048 + sw5b*1024 + sw4*512 + sw4b*256+ sw3*128 + sw3b*64 + sw2*32 + sw2b*16 + sw1*8 + sw1b*4 + sw0*2 + sw0b*1;



        
endmodule

// dff
module dff ( input wire d,
              input wire rst,
              input wire clk,
              output reg q,
              output wire qn);
	
      initial begin
        q <= 0;
      end

      always @ (posedge clk or posedge rst)
            if (rst)
                  q <= 0;
            else
                  q <= d;
      
      assign qn = ~q;

endmodule

// hold
module hold ( input wire comp_in,
                input wire sample,
                input wire d1b,
                input wire d2b,
                input wire d3b,
                input wire d4b,
                input wire d5b,
                input wire d6b,
                output wire r5,
                output wire r4,
                output wire r3,
                output wire r2,
                output wire r1,
                output wire r0);

    dff  dff5 ( .d(comp_in),
                .rst (sample),
                .clk (d6b),
                .q (r5),
				.qn ()),
        dff4 ( .d(comp_in),
                .rst (sample),
                .clk (d5b),
                .q (r4),
				.qn ()),
        dff3 ( .d(comp_in),
                .rst (sample),
                .clk (d4b),
                .q (r3),
				.qn ()),
        dff2 ( .d(comp_in),
                .rst (sample),
                .clk (d3b),
                .q (r2),
				.qn ()),
        dff1 ( .d(comp_in),
                .rst (sample),
                .clk (d2b),
                .q (r1),
				.qn ()),
        dff0 ( .d(comp_in),
                .rst (sample),
                .clk (d1b),
                .q (r0),
				.qn ());



endmodule

// qout
module qout ( input wire sample,
                input wire rs,
                input wire r5,
                input wire r4,
                input wire r3,
                input wire r2,
                input wire r1,
                input wire r0,
                output wire q5,
                output wire q4,
                output wire q3,
                output wire q2,
                output wire q1,
                output wire q0);

    dff dff6 ( .d(r5),
                .rst (sample),
                .clk (rs),
                .q (q5),
				.qn ()),
        dff5 ( .d(r4),
                .rst (sample),
                .clk (rs),
                .q (q4),
				.qn ()),
        dff4 ( .d(r3),
                .rst (sample),
                .clk (rs),
                .q (q3),
				.qn ()),
        dff3 ( .d(r2),
                .rst (sample),
                .clk (rs),
                .q (q2),
				.qn ()),
        dff2 ( .d(r1),
                .rst (sample),
                .clk (rs),
                .q (q1),
				.qn ()),
        dff1 ( .d(r0),
                .rst (sample),
                .clk (rs),
                .q (q0),
				.qn ());



endmodule

// count_monitor
module count_monitor ( input wire clk,
                    output reg comp_en,
                    output reg sample,
                    output reg d1,
                    output wire d1b,
                    output reg d2,
                    output wire d2b,
                    output reg d3,
                    output wire d3b,
                    output reg d4,
                    output wire d4b,
                    output reg d5,
                    output wire d5b,
                    output reg d6,
                    output wire d6b,
                    output reg rs);

    reg [4:0] sar_counter;

    // 初期値代入
    initial begin
        sar_counter = 8;
        comp_en <= 1;
        sample <= 0;
        d1 <= 0;
        d2 <= 0;
        d3 <= 0;
        d4 <= 0;
        d5 <= 0;
        d6 <= 0;
        rs <= 0;
    end

    // 比較回数モニタ，制御
    always @ (posedge clk)
        if (sar_counter == 8) begin
            sample <= 0;
            sar_counter = sar_counter - 1;
        end
        else if (sar_counter == 7) begin
            comp_en <= 0;
            d6 <= 1;
            sar_counter = sar_counter - 1;
        end
        else if (sar_counter == 6) begin
            d5 <= 1;
            d6 <= 0;
            sar_counter = sar_counter - 1;
        end
        else if (sar_counter == 5) begin
            d4 <= 1;
            d5 <= 0;
            sar_counter = sar_counter - 1;
        end
        else if (sar_counter == 4) begin
            d3 <= 1;
            d4 <= 0;
            sar_counter = sar_counter - 1;
        end
        else if (sar_counter == 3) begin
            d2 <= 1;
            d3 <= 0;
            sar_counter = sar_counter - 1;
        end
        else if (sar_counter == 2) begin
            d1 <= 1;
            d2 <= 0;
            sar_counter = sar_counter - 1;
        end
        else if (sar_counter == 1) begin
            d1 <= 0;
            comp_en <= 1;
            sar_counter = sar_counter - 1;
        end
        else if (sar_counter == 0) begin
            sample <= 1;
            sar_counter = 8;
        end

    always @ (negedge clk)
        if (sar_counter == 0) begin
            rs <= 1;
            sample <= 1;
        end
        else if (sar_counter == 8) begin
            rs <= 0;
        end

    assign d1b = ~d1;
    assign d2b = ~d2;
    assign d3b = ~d3;
    assign d4b = ~d4;
    assign d5b = ~d5;
    



endmodule

