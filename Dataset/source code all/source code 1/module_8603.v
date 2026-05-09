`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module CLASSIFY(
input clk,
input reset,
input in_ingress_key_wr,
input [133:0] in_ingress_key,
input in_ingress_valid_wr,
input in_ingress_valid,
output out_ingress_key_almostfull,
output reg out_offset_key_wr,
output reg [133:0] out_offset_key,
output reg out_offset_valid,
output reg out_offset_valid_wr,
input in_offset_key_almostfull
);
reg [2:0] state;
wire 	in_ingress_valid_q; 
wire 	in_ingress_valid_empty;
reg	out_ingress_valid_rd;	
wire [7:0] out_ingress_key_usedw;
assign out_ingress_key_almostfull = out_ingress_key_usedw[7];
reg 	out_ingress_key_rd;
wire [133:0]in_ingress_key_q;
reg is_unknown;
reg [7:0]tos;
reg [15:0]l3_protocol;
reg [7:0]l4_protocol;
reg [31:0]sip;
reg [31:0]dip;
reg [15:0]sport;
reg [15:0]dport;
reg [7:0]tcp_flag;
reg [7:0]layer_type;
reg [7:0]code;
reg tcp_icmp;
parameter idle=3'd0,
          l2=3'd1,
          l3=3'd2,
          l4=3'd3,
          prepad1=3'd4,
          prepad2=3'd5,
          prepad3=3'd6,
          prepad4=3'd7;
always @(posedge clk or negedge reset) begin
  if(!reset)begin
    out_offset_key_wr<=1'b0;
    out_offset_key<=134'b0;
    out_offset_valid<=1'b0;
    out_offset_valid_wr<=1'b0;
    out_ingress_key_rd<=1'b0;
    out_ingress_valid_rd<=1'b0;
	  is_unknown<=1'b0;
	   tos<=8'b0;
	   l3_protocol<=16'b0;
    	l4_protocol<=8'b0;
    	sip<=32'b0;
    	dip<=32'b0;
    	sport<=16'b0;
    	dport<=16'b0;
    	tcp_flag<=8'b0;
    	layer_type<=8'b0;
    	code<=8'b0;
    	tcp_icmp<=1'b0;
    state<=idle;
  end
  else begin
    case(state) 
      idle:begin
        out_offset_key_wr<=1'b0;
        out_offset_key<=134'b0;
        out_offset_valid<=1'b0;
        out_offset_valid_wr<=1'b0;
        out_ingress_key_rd<=1'b0;
        out_ingress_valid_rd<=1'b0;
		    is_unknown<=1'b0;
		    tos<=8'b0;
		    l3_protocol<=16'b0;
		    l4_protocol<=8'b0;
		    sip<=32'b0;
		    dip<=32'b0;
		    sport<=16'b0;
		    dport<=16'b0;
		    tcp_flag<=8'b0;
		    layer_type<=8'b0;
		    code<=8'b0;
		    tcp_icmp<=1'b0;
        if(in_offset_key_almostfull==1'b0 && in_ingress_valid_empty==1'b0 )begin
          out_ingress_key_rd<=1'b1;
          out_ingress_valid_rd<=1'b1;
          state<=l2;
        end
        else begin
          state<=idle;
        end
       end 
      l2: begin
        out_ingress_key_rd<=1'b1;
        out_ingress_valid_rd<=1'b0;
		state<=l3;
		if(in_ingress_key_q[31:16]==16'h0800 &&in_ingress_key_q[11:8] ==4'd5)
		begin
			l3_protocol<=in_ingress_key_q[31:16];
			tos<=in_ingress_key_q[7:0];			
		end
		else
		begin
			is_unknown<=1'b1;
		end
      end
      l3:begin
		out_ingress_key_rd<=1'b1;
        out_ingress_valid_rd<=1'b0;
		if(is_unknown==1'b1)
		begin
        state<=l4;
		end
		else if(in_ingress_key_q[71:64]==8'd6|| in_ingress_key_q[71:64]==8'd1)
		begin
		l4_protocol<=in_ingress_key_q[71:64];
		sip<=in_ingress_key_q[47:16];
		dip[31:16]<=in_ingress_key_q[15:0];
        end
		else 
		begin
		is_unknown<=1'b1;
		end
		state<=l4;
      end
      l4:begin
        out_ingress_key_rd<=1'b1;
        out_ingress_valid_rd<=1'b0;
		if(is_unknown==1'b1)
		begin
        state<=prepad1;
		end
		else if(l4_protocol==8'd6)
		begin
		dip[15:0]<=in_ingress_key_q[127:112];
		sport<=in_ingress_key_q[111:96];
		dport<=in_ingress_key_q[95:80];
		tcp_flag<=in_ingress_key_q[7:0];
		state<=prepad1;
		end
		else if(l4_protocol==8'd1)
		begin
		dip[15:0]<=in_ingress_key_q[127:112];
		layer_type<=in_ingress_key_q[111:104];
		code<=in_ingress_key_q[103:96];
		tcp_flag<=8'b0;
		end
		else 
		begin
		is_unknown<=1'b1;
		end
		state<=prepad1;
      end
    prepad1:begin
        out_ingress_key_rd<=1'b0;
        out_ingress_valid_rd<=1'b0;
        out_offset_key_wr<=1'b1;
        out_offset_key<={6'b010000,3'b001,125'b0};
        state<=prepad2;
      end 
      prepad2:begin
        out_ingress_key_rd<=1'b0;
        out_ingress_valid_rd<=1'b0;
        out_offset_key_wr<=1'b1;
        out_offset_key<={6'b110000,48'b0,l3_protocol,tos,l4_protocol,sip,dip[31:16]};
        state<=prepad3;
      end 
      prepad3:begin
        out_ingress_key_rd<=1'b0;
        out_ingress_valid_rd<=1'b0;
        out_offset_key_wr<=1'b1;
		if(tcp_icmp==1'b0)
		begin
        out_offset_key<={6'b110000,dip[15:0],sport,dport,tcp_flag,72'b0};
		end
		else
		begin
		out_offset_key<={6'b110000,dip[15:0],layer_type,code,96'b0};
		end
		state<=prepad4;
      end     
      prepad4:begin
        out_ingress_key_rd<=1'b0;
        out_ingress_valid_rd<=1'b0;
        out_offset_key_wr<=1'b1;
        out_offset_key<={6'b100000,128'b0};
        out_offset_valid<=1'b1;
        out_offset_valid_wr<=1'b1;
        state<=idle;
      end  
    endcase     
  end
end          
fifo_64_1 FIFO_VALID_input  (
							.aclr(!reset),
							.data(in_ingress_valid),
							.clock(clk),
							.rdreq(out_ingress_valid_rd),
							.wrreq(in_ingress_valid_wr),
							.q(in_ingress_valid_q),
							.empty(in_ingress_valid_empty)
						);
fifo_256_134	FIFO_key_input (
								.aclr(!reset),
								.data(in_ingress_key),
								.clock(clk),
								.rdreq(out_ingress_key_rd),
								.wrreq(in_ingress_key_wr),
								.q(in_ingress_key_q),
								.usedw(out_ingress_key_usedw)
								);	
endmodule								
