`timescale 1ns/1ns
`timescale 1ns/1ns
module fx2_bidir(
	fx2_clk, fx2_fd, fx2_slrd, fx2_slwr, fx2_flags, 
	fx2_sloe, fx2_wu2, fx2_fifoadr, fx2_pktend,
	sample, sample_rdy, sample_ack,
	cmd, cmd_wr,
	reply, reply_rdy, reply_ack, reply_end
);
input [7:0] sample;
input sample_rdy;
output sample_ack;
output [7:0] cmd;
output cmd_wr;
input [7:0] reply;
input reply_rdy;
output reply_ack;
input reply_end;
input fx2_clk;
output fx2_wu2; 
inout [7:0] fx2_fd;
output [1:0] fx2_fifoadr; 
input [2:0] fx2_flags; 
output fx2_slrd, fx2_slwr;
output fx2_sloe; 
output fx2_pktend; 
wire fifo_clk = fx2_clk;
wire fifo2_empty = ~fx2_flags[0];	wire fifo2_data_available = ~fifo2_empty;
wire fifo6_full = ~fx2_flags[1];	wire fifo6_ready_to_accept_data = ~fifo6_full;
wire fifo8_full = ~fx2_flags[2];	wire fifo8_ready_to_accept_data = ~fifo8_full;
assign fx2_wu2 = 1'b1;
wire sample_ack;
wire [7:0] fifo_dataout;
wire fifo_dataout_oe;
wire fifo_wr;
wire request_length;
wire [7:0] length_byte;
wire fifo_rd,  fifo_pktend, fifo_datain_oe;
wire fx2_slrd = ~fifo_rd;
wire fx2_slwr = ~fifo_wr;
assign fx2_sloe = ~fifo_datain_oe;
assign fx2_pktend = ~fifo_pktend;
wire [1:0] fifo_fifoadr;
assign fx2_fifoadr = fifo_fifoadr;
wire [7:0] fifo_datain = fx2_fd;
assign fx2_fd = fifo_dataout_oe ? fifo_dataout : 8'hZZ;
reg [3:0] state;
always @(posedge fifo_clk)
case(state)
	4'b1001:							
		if (fifo2_data_available)				
			state <= 4'b0001;
		else if (reply_rdy && fifo8_ready_to_accept_data)	
			state <= 4'b1110;
		else if (sample_rdy && fifo6_ready_to_accept_data)	
			state <= 4'b1011;
	4'b1011:							
		if (reply_rdy && fifo8_ready_to_accept_data)		
			state <= 4'b1110;			
		else if (fifo2_data_available)				
			state <= 4'b0001;
		else if (fifo6_full)					
			state <= 4'b1001;
	4'b0001: state <= 4'b0011;					
	4'b0011: if (fifo2_empty) state <= 4'b1001;			
	4'b1110: if (reply_end) state <= 4'b1111;			
	4'b1111: state <= 4'b1000;					
	4'b1000:							
	begin
		#2 state <= 4'b1010;
	end
	default: state <= 4'b1011;
endcase
assign fifo_fifoadr = state[3:2];
assign fifo_rd = (state==4'b0011);
assign cmd[7:0] = (state==4'b0011) ? fifo_datain[7:0] : 8'b0;
assign cmd_wr = (state==4'b0011);
assign fifo_datain_oe = (state[3:2] == 2'b00);
wire can_xmit_sample = (state==4'b1011) && sample_rdy && fifo2_empty && fifo6_ready_to_accept_data;
assign sample_ack = can_xmit_sample;
assign fifo_dataout = (state==4'b1011) ? sample : 
		      (state==4'b1110) ? reply : 8'bX;
assign fifo_wr = can_xmit_sample || (state==4'b1110);
assign fifo_dataout_oe = can_xmit_sample || (state==4'b1110);
assign fifo_pktend = (state==4'b1111);
assign reply_ack = (state==4'b1110);
endmodule
