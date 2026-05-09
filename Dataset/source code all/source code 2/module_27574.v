`timescale 1ns / 1ps
`timescale 1ns / 1ps
module debouncer(
    input clk, input reset,
    input PB,  
    output reg PB_state,  
    output PB_down,  
    output PB_up   
);
reg PB_sync_0;  always @(posedge clk) PB_sync_0 <= PB;  
reg PB_sync_1;  always @(posedge clk) PB_sync_1 <= PB_sync_0;
reg [7:0] PB_cnt;
wire PB_idle = (PB_state==PB_sync_1);
wire PB_cnt_max = &PB_cnt;	
always @(posedge clk, posedge reset)
if(reset)begin
PB_cnt <= 0;
PB_state <= 0;
end else
if(PB_idle)
    PB_cnt <= 0;  
else
begin
    PB_cnt <= PB_cnt + 1'b1;  
    if(PB_cnt_max) PB_state <= ~PB_state;  
end
assign PB_down = ~PB_idle & PB_cnt_max & ~PB_state;
assign PB_up   = ~PB_idle & PB_cnt_max &  PB_state;
endmodule
