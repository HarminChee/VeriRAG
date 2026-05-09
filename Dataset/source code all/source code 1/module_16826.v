module INGRESS_CTRL(
input clk,
input reset,
input in_inputctrl_pkt_wr,
input [133:0] in_inputctrl_pkt,
input in_inputctrl_valid_wr,
input in_inputctrl_valid,
output out_inputctrl_pkt_almostfull,
output reg out_class_key_wr,
output reg [133:0] out_class_key,
input in_class_key_almostfull,
output reg out_class_valid,
output reg out_class_valid_wr,
output reg out_offset_pkt_wr,
output reg [133:0] out_offset_pkt,
output reg out_offset_valid,
output reg out_offset_valid_wr,
input in_offset_pkt_almostfull
);
reg [2:0] current_state;
reg [2:0] counter;
wire 	in_inputctrl_valid_q;
wire 	in_inputctrl_valid_empty;
reg	out_inputctrl_valid_rd;		
wire [7:0] out_inputctrl_pkt_usedw;
assign out_inputctrl_pkt_almostfull = out_inputctrl_pkt_usedw[7];
reg 	out_inputctrl_pkt_rd;
wire [133:0]in_inputctrl_pkt_q;
parameter	idle_s	=	3'd0,
			send_meta1_s	=	3'd1,
			send_meta2_s	=	3'd2,
			send_key_s	=	3'd3,
			send_data_s	=	3'd4,
			discard_s=3'd5;
always@(posedge clk or negedge reset) begin
	if(!reset) begin
		out_class_key_wr<=1'b0;
		out_class_key<=134'b0;
		out_class_valid<=1'b1;
		out_class_valid_wr<=1'b0;
		out_offset_pkt_wr<=1'b0;
		out_offset_pkt<=134'b0;
		out_offset_valid<=1'b0;
		out_offset_valid_wr<=1'b0;
		out_inputctrl_valid_rd<=1'b0;
		out_inputctrl_pkt_rd<=1'b0;
		counter<=3'b0;
		current_state<=idle_s;
	end
	else begin
		case(current_state)
		idle_s:begin
			counter<=3'b0;
			out_class_key_wr<=1'b0;
			out_class_valid_wr<=1'b0;
			out_offset_pkt_wr<=1'b0;
			out_offset_valid_wr<=1'b0;
			out_offset_valid<=1'b0;
			if((in_offset_pkt_almostfull==1'b0) && (in_inputctrl_valid_empty==1'b0) && (in_class_key_almostfull==1'b0))begin
				if(in_inputctrl_valid_q==1'b1)begin
					out_inputctrl_valid_rd<=1'b1;
					out_inputctrl_pkt_rd<=1'b1;
					current_state<=send_meta1_s;
				end
				else begin
					out_inputctrl_valid_rd<=1'b1;
					out_inputctrl_pkt_rd<=1'b1;
					current_state<=discard_s;
				end 				    
			end
			else begin
			out_inputctrl_valid_rd<=1'b0;
			out_inputctrl_pkt_rd<=1'b0;
			current_state<=idle_s;
			end
		end
		send_meta1_s:begin
			out_inputctrl_valid_rd<=1'b0;
			out_offset_pkt_wr<=1'b1;
			out_offset_pkt<=in_inputctrl_pkt_q;
			current_state<=send_meta2_s;
		end
		send_meta2_s:begin
			out_offset_pkt<=in_inputctrl_pkt_q;
			current_state<=send_key_s;
		end
		send_key_s:begin
			out_offset_pkt_wr<=1'b1;
			out_class_key_wr<=1'b1;
			out_offset_pkt<=in_inputctrl_pkt_q;
			out_class_key<=in_inputctrl_pkt_q;
			counter<=counter+1'b1;
			if(in_inputctrl_pkt_q[133:132]==2'b10)begin
				out_inputctrl_pkt_rd<=1'b0;
				out_offset_valid_wr<=1'b1;
				out_offset_valid<=1'b1;
				out_class_valid_wr<=1'b1;
				current_state<=idle_s;
			end
			else begin
				out_inputctrl_pkt_rd<=1'b1;
				out_offset_valid_wr<=1'b0;
				out_offset_valid<=1'b0;
				if(counter<3'd3)begin	
					out_class_valid_wr<=1'b0;
					current_state<=send_key_s;
				end	
				else begin
					out_class_valid_wr<=1'b1;
					current_state<=send_data_s;
				end
			end	
		end
		send_data_s:begin
			out_class_key_wr<=1'b0;
			out_class_valid_wr<=1'b0;
			if(in_inputctrl_pkt_q[133:132]==2'b10)begin
				out_inputctrl_pkt_rd<=1'b0;
				out_offset_pkt_wr<=1'b1;
				out_offset_pkt<=in_inputctrl_pkt_q;
				out_offset_valid_wr<=1'b1;
				out_offset_valid<=1'b1;
				current_state<=idle_s;
			end
			else begin
				out_inputctrl_pkt_rd<=1'b1;
				out_offset_pkt_wr<=1'b1;
				out_offset_pkt<=in_inputctrl_pkt_q;
				current_state<=send_data_s;
			end
		end	
		discard_s:begin
			out_inputctrl_valid_rd<=1'b0;
			if(in_inputctrl_pkt_q[133:132]==2'b10)begin
				out_inputctrl_pkt_rd<=1'b0;
				current_state<=idle_s;
			end
			else begin
				out_inputctrl_pkt_rd<=1'b1;
				current_state<=discard_s;
			end
		end	
		default:;
		endcase
	end	
end
fifo_64_1 FIFO_VALID_input_ctrl  (
							.aclr(!reset),
							.data(in_inputctrl_valid),
							.clock(clk),
							.rdreq(out_inputctrl_valid_rd),
							.wrreq(in_inputctrl_valid_wr),
							.q(in_inputctrl_valid_q),
							.empty(in_inputctrl_valid_empty)
						);
fifo_256_134	FIFO_PKT_input_ctrl (
								.aclr(!reset),
								.data(in_inputctrl_pkt),
								.clock(clk),
								.rdreq(out_inputctrl_pkt_rd),
								.wrreq(in_inputctrl_pkt_wr),
								.q(in_inputctrl_pkt_q),
								.usedw(out_inputctrl_pkt_usedw)
								);	
endmodule
