
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
        dff1 ( .d(r0n),
                .rst (sample),
                .clk (rs),
                .q (q0),
				.qn ());



endmodule