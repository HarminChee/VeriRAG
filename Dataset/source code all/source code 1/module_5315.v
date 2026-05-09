module debounce(
    clk,
    PB,
    PB_state
);
	input clk;
	input PB;
	output PB_state;
reg init_state = 1'b0;
reg PB_state = 1'b0;
reg [11:0] PB_cnt = 12'd0;
wire PB_cnt_max = &PB_cnt;
wire PB_idle = (PB_cnt == 12'd0);
wire PB_changed = (PB != init_state);
always @(posedge clk)
if(PB_idle & PB_changed)
begin
	init_state = PB;
	PB_cnt = 12'd1;
end
else if(PB_cnt_max)
begin
	PB_state = init_state;
	PB_cnt = 12'd0;
end
else if(~PB_idle)
	PB_cnt = PB_cnt + 12'd1;
endmodule
