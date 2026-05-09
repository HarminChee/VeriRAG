module fmlmeter #(
	parameter csr_addr = 4'h0
) (
	input sys_clk,
	input sys_rst,
	input [13:0] csr_a,
	input csr_we,
	input [31:0] csr_di,
	output reg [31:0] csr_do,
	input fml_stb,
	input fml_ack
);
reg fml_stb_r;
reg fml_ack_r;
always @(posedge sys_clk) begin
	fml_stb_r <= fml_stb;
	fml_ack_r <= fml_ack;
end
reg en;			
reg [31:0] stb_count;	
reg [31:0] ack_count;	
wire csr_selected = csr_a[13:10] == csr_addr;
always @(posedge sys_clk) begin
	if(sys_rst) begin
		en <= 1'b0;
		stb_count <= 32'd0;
		ack_count <= 32'd0;
		csr_do <= 32'd0;
	end else begin
		if(en) begin
			if(fml_stb_r)
				stb_count <= stb_count + 32'd1;
			if(fml_ack_r)
				ack_count <= ack_count + 32'd1;
		end
		csr_do <= 32'd0;
		if(csr_selected) begin
			if(csr_we) begin
				en <= csr_di[0];
				if(csr_di[0]) begin
					stb_count <= 32'd0;
					ack_count <= 32'd0;
				end
			end
			case(csr_a[1:0])
				2'b00: csr_do <= en;
				2'b01: csr_do <= stb_count;
				2'b10: csr_do <= ack_count;
			endcase
		end
	end
end
endmodule
