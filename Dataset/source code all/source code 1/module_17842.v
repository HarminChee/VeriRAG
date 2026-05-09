module compute_vex(
    clk,
    nrst,
	start,
	log_lambda_up,
	log_lambda_down,
	K_over_S,
	v_ex,
	wraddr,
	wren,
	done
);
input  clk;
input  nrst; 
input  start;
input  [63:0] log_lambda_up;
input  [63:0] log_lambda_down;
input  [63:0] K_over_S;
output [63:0] v_ex;
output [9:0] wraddr;
output [7:0]wren;
output done;
reg  [63:0] latched_log_lambda_up;
reg  [63:0] latched_log_lambda_down;
reg  [63:0] v_ex;
wire [63:0] mult_result;
wire [63:0] exp_result;
wire [63:0] sub_result;
wire [63:0] index_fp;
reg clk_en;
reg cnt_en;
reg [12:0] timer1;
reg [6:0]  timer2;
reg [13:0] counter1;
reg [13:0] counter2;
reg [7:0]  wren;
wire t1_expire = timer1[12];
wire t2_expire = timer2[6];
reg second_half;
wire first_half_done = (timer1 == 0);  
assign wraddr[9:0] = counter2[12:3];
reg [4:0]delay;
always@(posedge clk) delay <= {delay[3:0], second_half}; 
int_to_fp int_to_fp_inst (
  .clk_en(clk_en),
  .clock(clk ),
  .dataa({20'b0, second_half ? timer1[11:0] : counter1[11:0]}),
  .result (index_fp)
);
fp_mult_slow stage1_multiply(
  .clk_en(clk_en),
  .clock(clk),
  .dataa( delay[4] ? latched_log_lambda_down:latched_log_lambda_up ),
  .datab(index_fp),
  .result(mult_result)
);
fp_exp stage1_exponent (
  .clk_en(clk_en),
  .clock(clk),
  .data(mult_result),
  .result(exp_result)
);
fp_sub stage1_sub (
  .clk_en(clk_en),
  .clock(clk ),
  .dataa(K_over_S),
  .datab(exp_result),
  .result(sub_result)
);
always@(posedge clk)
  if(~nrst)      latched_log_lambda_up <= 64'h0;
  else if(start) latched_log_lambda_up <= log_lambda_up;
  else           latched_log_lambda_up <= latched_log_lambda_up;
always@(posedge clk)
  if(~nrst)      latched_log_lambda_down <= 64'h0;
  else if(start) latched_log_lambda_down <= log_lambda_down;
  else           latched_log_lambda_down <= latched_log_lambda_down;
always@(posedge clk)
  if(~nrst)         clk_en <= 1'b0;
  else if(start)    clk_en <= 1'b1;
  else if(counter2 == 14'd8000) clk_en <= 1'b0;
always@(posedge clk)
  if(~nrst)        cnt_en <= 1'b0;
  else if(start)   cnt_en <= 1'b1;
  else if(counter1 == 14'd3999)  cnt_en <= 1'b0;
always@(posedge clk)
  if(~nrst)                second_half <= 1'b1;
  else if(start)           second_half <= 1'b1;
  else if(first_half_done) second_half <= 1'b0;
always@(posedge clk)
begin
 if(sub_result[63]) v_ex[63:0] <= 64'h0000000000000000;  
 else v_ex[63:0] <= sub_result[63:0];  
end
always@(posedge clk)
  if (~nrst)           wren <= 8'b00000000;
  else if(~clk_en)     wren <= 8'b00000000;
  else if(timer2 == 0) wren <= 8'b00000001;
  else begin 
    wren <= {wren[6], wren[5], wren[4], wren[3],
             wren[2], wren[1], wren[0], wren[7]};
  end
always @(posedge clk)
  if (~nrst) timer1 <= -1;
  else if(start) timer1 <= {1'b0,12'd4000};
  else if(cnt_en && !t1_expire) timer1 <= timer1 - 1;
always @(posedge clk)
  if (~nrst) timer2 <= -1;
  else if(start) timer2 <= {1'b0,6'b101110};
  else if(clk_en && !t2_expire) timer2 <= timer2 - 1;
always @(posedge clk)
  if(~nrst) counter1 <= -1;
  else if(first_half_done) counter1 <= 1;
  else if(cnt_en && t1_expire) counter1 <= counter1 + 1;
always @(posedge clk)
  if (~nrst) counter2 <= 0;
  else if(start) counter2 <= 0;
  else if(clk_en && t2_expire) counter2 <= counter2 + 1;
reg [1:0] state;
assign done = state[1];
always@(posedge clk)
  if(!nrst) state <= 2'b00;
  else if(start) state <= 2'b01;
  else if((state == 2'b01) && ~clk_en) state <= 2'b10;
  else if(state == 2'b10) state <= 2'b00;
endmodule
