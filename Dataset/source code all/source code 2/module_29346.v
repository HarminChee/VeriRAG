module jt12_mixer #(parameter w0=16,w1=16,w2=16,w3=16,wout=20)
(
    input                    clk,
    input                    cen,
    input  signed [w0-1:0]   ch0,
    input  signed [w1-1:0]   ch1,
    input  signed [w2-1:0]   ch2,
    input  signed [w3-1:0]   ch3,
    input  [7:0]             gain0,
    input  [7:0]             gain1,
    input  [7:0]             gain2,
    input  [7:0]             gain3,
    output reg signed [wout-1:0] mixed
);
reg signed [w0+7:0] ch0_amp;
reg signed [w1+7:0] ch1_amp;
reg signed [w2+7:0] ch2_amp;
reg signed [w3+7:0] ch3_amp;
wire signed [wout+11:0] scaled0 = { {wout+4-w0{ch0_amp[w0+7]}}, ch0_amp   };
wire signed [wout+11:0] scaled1 = { {wout+4-w1{ch1_amp[w1+7]}}, ch1_amp   };
wire signed [wout+11:0] scaled2 = { {wout+4-w2{ch2_amp[w2+7]}}, ch2_amp   };
wire signed [wout+11:0] scaled3 = { {wout+4-w3{ch3_amp[w3+7]}}, ch3_amp   };
reg signed [wout+11:0] sum, limited;
wire signed [wout+11:0] max_pos = { {12{1'b0}}, {(wout-1){1'b1}}};
wire signed [8:0]
    g0 = {1'b0, gain0},
    g1 = {1'b0, gain1},
    g2 = {1'b0, gain2},
    g3 = {1'b0, gain3};
always @(posedge clk) if(cen) begin
    ch0_amp <= g0 * ch0;
    ch1_amp <= g1 * ch1;
    ch2_amp <= g2 * ch2;
    ch3_amp <= g3 * ch3;
    sum     <= (scaled0 + scaled1 + scaled2 + scaled3)>>>4;
    limited <= sum>max_pos ? max_pos : (sum<~max_pos ? ~max_pos : sum);
    mixed   <= limited[wout-1:0];
end
endmodule 
