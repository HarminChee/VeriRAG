`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module de3d_read_addr_in
	(
	input		de_clk,		
	input	[2:0]	bpt,		
	input	[14:0]	ul_tag_adr_rd,	
	input	[14:0]	ll_tag_adr_rd,	
	input	[14:0]	ur_tag_adr_rd,	
	input	[14:0]	lr_tag_adr_rd,	
	output reg	[4:0]	ee_tag_adr_rd,
	output reg	[4:0]	eo_tag_adr_rd,
	output reg	[4:0]	oe_tag_adr_rd,
	output reg	[4:0]	oo_tag_adr_rd
	);
reg	[6:0]	ul_tag_adr_bpt;
reg	[6:0]	ll_tag_adr_bpt;
reg	[6:0]	ur_tag_adr_bpt;
reg	[6:0]	lr_tag_adr_bpt;
reg	[14:0]	ul_tag_adr;	
reg	[14:0]	ll_tag_adr;	
reg	[14:0]	ur_tag_adr;	
reg	[14:0]	lr_tag_adr;	
always @* begin
	case(bpt)
	3'b011:	
		begin
			ul_tag_adr_bpt = {ul_tag_adr_rd[5:1],ul_tag_adr_rd[11]};
			ll_tag_adr_bpt = {ll_tag_adr_rd[5:1],ll_tag_adr_rd[11]};
			ur_tag_adr_bpt = {ur_tag_adr_rd[5:1],ur_tag_adr_rd[11]};
			lr_tag_adr_bpt = {lr_tag_adr_rd[5:1],lr_tag_adr_rd[11]};
		end
	3'b100:	
		begin
			ul_tag_adr_bpt = {ul_tag_adr_rd[4:1],ul_tag_adr_rd[11:10]};
			ll_tag_adr_bpt = {ll_tag_adr_rd[4:1],ll_tag_adr_rd[11:10]};
			ur_tag_adr_bpt = {ur_tag_adr_rd[4:1],ur_tag_adr_rd[11:10]};
			lr_tag_adr_bpt = {lr_tag_adr_rd[4:1],lr_tag_adr_rd[11:10]};
		end
	default: 
		begin
			ul_tag_adr_bpt = {ul_tag_adr_rd[3:1],ul_tag_adr_rd[11:9]};
			ll_tag_adr_bpt = {ll_tag_adr_rd[3:1],ll_tag_adr_rd[11:9]};
			ur_tag_adr_bpt = {ur_tag_adr_rd[3:1],ur_tag_adr_rd[11:9]};
			lr_tag_adr_bpt = {lr_tag_adr_rd[3:1],lr_tag_adr_rd[11:9]};
		end
	endcase
	end
always @(posedge de_clk) begin
  		casex ({ul_tag_adr_bpt[0],ul_tag_adr[0],ur_tag_adr_bpt[0]})
    		3'b01x:
			begin
				 ee_tag_adr_rd <= ll_tag_adr_bpt[5:1];
				 oe_tag_adr_rd <= lr_tag_adr_bpt[5:1];
				 eo_tag_adr_rd <= ul_tag_adr_bpt[5:1];
				 oo_tag_adr_rd <= ur_tag_adr_bpt[5:1];
			end
    		3'b10x:
			begin
				 ee_tag_adr_rd <= ur_tag_adr_bpt[5:1];
				 oe_tag_adr_rd <= ul_tag_adr_bpt[5:1];
				 eo_tag_adr_rd <= lr_tag_adr_bpt[5:1];
				 oo_tag_adr_rd <= ll_tag_adr_bpt[5:1];
			end
    		3'b11x:
			begin
				 ee_tag_adr_rd <= lr_tag_adr_bpt[5:1];
				 oe_tag_adr_rd <= ll_tag_adr_bpt[5:1];
				 eo_tag_adr_rd <= ur_tag_adr_bpt[5:1];
				 oo_tag_adr_rd <= ul_tag_adr_bpt[5:1];
			end
    		default:
			begin
				 ee_tag_adr_rd = ul_tag_adr_bpt[5:1];
				 oe_tag_adr_rd = ur_tag_adr_bpt[5:1];
				 eo_tag_adr_rd = ll_tag_adr_bpt[5:1];
				 oo_tag_adr_rd = lr_tag_adr_bpt[5:1];
			end
  		endcase
	end
endmodule
