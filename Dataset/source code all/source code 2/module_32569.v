module gearbox_66_40 (
	input clk,
	input sclr,			
	input [65:0] din,     
	output reg din_ack,
	output reg din_pre_ack,
	output reg din_pre2_ack,
	output [39:0] dout	
);
reg [5:0] gbstate = 0 ;
reg [103:0] stor = 0 ;
assign dout = stor[39:0];
reg [65:0] din_r = 0;
always @(posedge clk) begin
	din_r <= din[65:0];
	gbstate <= (sclr | gbstate[5]) ? 6'h0 : (gbstate + 1'b1);
	if (gbstate[5]) begin 
		stor <= {40'h0,stor[103:40]};    
	end    
	else begin	
		case (gbstate[4:0])
			5'h0 : begin stor[65:0] <= din[65:0];  end   
			5'h1 : begin stor[91:26] <= din[65:0]; stor[25:0] <= stor[65:40];   end   
			5'h2 : begin stor <= {40'h0,stor[103:40]};  end   
			5'h3 : begin stor[77:12] <= din[65:0]; stor[11:0] <= stor[51:40];   end   
			5'h4 : begin stor[103:38] <= din[65:0]; stor[37:0] <= stor[77:40];   end   
			5'h5 : begin stor <= {40'h0,stor[103:40]};  end   
			5'h6 : begin stor[89:24] <= din[65:0]; stor[23:0] <= stor[63:40];   end   
			5'h7 : begin stor <= {40'h0,stor[103:40]};  end   
			5'h8 : begin stor[75:10] <= din[65:0]; stor[9:0] <= stor[49:40];   end   
			5'h9 : begin stor[101:36] <= din[65:0]; stor[35:0] <= stor[75:40];   end   
			5'ha : begin stor <= {40'h0,stor[103:40]};  end   
			5'hb : begin stor[87:22] <= din[65:0]; stor[21:0] <= stor[61:40];   end   
			5'hc : begin stor <= {40'h0,stor[103:40]};  end   
			5'hd : begin stor[73:8] <= din[65:0]; stor[7:0] <= stor[47:40];   end   
			5'he : begin stor[99:34] <= din[65:0]; stor[33:0] <= stor[73:40];   end   
			5'hf : begin stor <= {40'h0,stor[103:40]};  end   
			5'h10 : begin stor[85:20] <= din[65:0]; stor[19:0] <= stor[59:40];   end   
			5'h11 : begin stor <= {40'h0,stor[103:40]};  end   
			5'h12 : begin stor[71:6] <= din[65:0]; stor[5:0] <= stor[45:40];   end   
			5'h13 : begin stor[97:32] <= din[65:0]; stor[31:0] <= stor[71:40];   end   
			5'h14 : begin stor <= {40'h0,stor[103:40]};  end   
			5'h15 : begin stor[83:18] <= din[65:0]; stor[17:0] <= stor[57:40];   end   
			5'h16 : begin stor <= {40'h0,stor[103:40]};  end   
			5'h17 : begin stor[69:4] <= din[65:0]; stor[3:0] <= stor[43:40];   end   
			5'h18 : begin stor[95:30] <= din[65:0]; stor[29:0] <= stor[69:40];   end   
			5'h19 : begin stor <= {40'h0,stor[103:40]};  end   
			5'h1a : begin stor[81:16] <= din[65:0]; stor[15:0] <= stor[55:40];   end   
			5'h1b : begin stor <= {40'h0,stor[103:40]};  end   
			5'h1c : begin stor[67:2] <= din[65:0]; stor[1:0] <= stor[41:40];   end   
			5'h1d : begin stor[93:28] <= din[65:0]; stor[27:0] <= stor[67:40];   end   
			5'h1e : begin stor <= {40'h0,stor[103:40]};  end   
			5'h1f : begin stor[79:14] <= din[65:0]; stor[13:0] <= stor[53:40];   end   
		endcase
	end
end
wire [32:0] in_pattern = 33'b101011010110101101011010110101101;
always @(posedge clk) begin
	if (sclr) din_ack <= 1'b0;
	else din_ack <= (64'h0 | in_pattern) >> gbstate;
end
wire [32:0] in_pattern2 = 33'b110101101011010110101101011010110;
always @(posedge clk) begin
	if (sclr) din_pre_ack <= 1'b0;
	else din_pre_ack <= (64'h0 | in_pattern2) >> gbstate;
end
wire [32:0] in_pattern3 = 33'b011010110101101011010110101101011;
always @(posedge clk) begin
	if (sclr) din_pre2_ack <= 1'b0;
	else din_pre2_ack <= (64'h0 | in_pattern3) >> gbstate;
end
endmodule
