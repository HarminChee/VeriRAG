module wdt(clk, ena, cnt, out);
input clk, ena, cnt;
output out;
reg [6:0] timer;
wire timer_top = (timer == 7'd127);
reg internal_enable;
wire out = internal_enable && timer_top;
always @(posedge clk) begin
    if(ena) begin
        internal_enable <= 1;
        timer <= 0;
    end 
    else if(cnt && !timer_top) timer <= timer + 7'd1;
end
endmodule
