`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module de3d_tc_tag_val
	(
	input		de_clk,		
	input		de_rstn,	
	input		invalidate,	
	input		ee_s0_loadn,	
	input		ee_s1_loadn,	
	input		eo_s0_loadn,	
	input		eo_s1_loadn,	
	input		oe_s0_loadn,	
	input		oe_s1_loadn,	
	input		oo_s0_loadn,	
	input		oo_s1_loadn,	
	input	[4:0]	ee_tag_adr_wr,	
	input	[4:0]	eo_tag_adr_wr,	
	input	[4:0]	oe_tag_adr_wr,	
	input	[4:0]	oo_tag_adr_wr,	
	input	[4:0]	ee_tag_adr_rd,	
	input	[4:0]	eo_tag_adr_rd,	
	input	[4:0]	oe_tag_adr_rd,	
	input	[4:0]	oo_tag_adr_rd,	
	output	[1:0]	ee_val,		
	output	[1:0]	eo_val,		
	output	[1:0]	oe_val,		
	output	[1:0]	oo_val		
	);
reg	[31:0]	ee_val_s0_reg;	
reg	[31:0]	ee_val_s1_reg;	
reg	[31:0]	eo_val_s0_reg;	
reg	[31:0]	eo_val_s1_reg;	
reg	[31:0]	oe_val_s0_reg;	
reg	[31:0]	oe_val_s1_reg;	
reg	[31:0]	oo_val_s0_reg;	
reg	[31:0]	oo_val_s1_reg;	
assign ee_val[0] = ee_val_s0_reg[ee_tag_adr_rd];
assign ee_val[1] = ee_val_s1_reg[ee_tag_adr_rd];
assign eo_val[0] = eo_val_s0_reg[eo_tag_adr_rd];
assign eo_val[1] = eo_val_s1_reg[eo_tag_adr_rd];
assign oe_val[0] = oe_val_s0_reg[oe_tag_adr_rd];
assign oe_val[1] = oe_val_s1_reg[oe_tag_adr_rd];
assign oo_val[0] = oo_val_s0_reg[oo_tag_adr_rd];
assign oo_val[1] = oo_val_s1_reg[oo_tag_adr_rd];
wire		inv;
assign inv = invalidate;
wire	[31:0]	set_s0_ee;
wire	[31:0]	set_s1_ee;
wire	[31:0]	set_s0_eo;
wire	[31:0]	set_s1_eo;
wire	[31:0]	set_s0_oe;
wire	[31:0]	set_s1_oe;
wire	[31:0]	set_s0_oo;
wire	[31:0]	set_s1_oo;
assign set_s0_ee = {31'b0,~ee_s0_loadn} << (ee_tag_adr_wr & {5{~ee_s0_loadn}});
assign set_s1_ee = {31'b0,~ee_s1_loadn} << (ee_tag_adr_wr & {5{~ee_s1_loadn}});
assign set_s0_eo = {31'b0,~eo_s0_loadn} << (eo_tag_adr_wr & {5{~eo_s0_loadn}});
assign set_s1_eo = {31'b0,~eo_s1_loadn} << (eo_tag_adr_wr & {5{~eo_s1_loadn}});
assign set_s0_oe = {31'b0,~oe_s0_loadn} << (oe_tag_adr_wr & {5{~oe_s0_loadn}});
assign set_s1_oe = {31'b0,~oe_s1_loadn} << (oe_tag_adr_wr & {5{~oe_s1_loadn}});
assign set_s0_oo = {31'b0,~oo_s0_loadn} << (oo_tag_adr_wr & {5{~oo_s0_loadn}});
assign set_s1_oo = {31'b0,~oo_s1_loadn} << (oo_tag_adr_wr & {5{~oo_s1_loadn}});
always @(posedge de_clk or negedge de_rstn)
	begin
		if(!de_rstn)ee_val_s0_reg <= 0;
		else if(inv)ee_val_s0_reg <= 0;
		else ee_val_s0_reg <= ee_val_s0_reg | set_s0_ee;
	end
always @(posedge de_clk or negedge de_rstn)
	begin
		if(!de_rstn)ee_val_s1_reg <= 0;
		else if(inv)ee_val_s1_reg <= 0;
		else ee_val_s1_reg <= ee_val_s1_reg | set_s1_ee;
	end
always @(posedge de_clk or negedge de_rstn)
	begin
		if(!de_rstn)eo_val_s0_reg <= 0;
		else if(inv)eo_val_s0_reg <= 0;
		else eo_val_s0_reg <= eo_val_s0_reg | set_s0_eo;
	end
always @(posedge de_clk or negedge de_rstn)
	begin
		if(!de_rstn)eo_val_s1_reg <= 0;
		else if(inv)eo_val_s1_reg <= 0;
		else eo_val_s1_reg <= eo_val_s1_reg | set_s1_eo;
	end
always @(posedge de_clk or negedge de_rstn)
	begin
		if(!de_rstn)oe_val_s0_reg <= 0;
		else if(inv)oe_val_s0_reg <= 0;
		else oe_val_s0_reg <= oe_val_s0_reg | set_s0_oe;
	end
always @(posedge de_clk or negedge de_rstn)
	begin
		if(!de_rstn)oe_val_s1_reg <= 0;
		else if(inv)oe_val_s1_reg <= 0;
		else oe_val_s1_reg <= oe_val_s1_reg | set_s1_oe;
	end
always @(posedge de_clk or negedge de_rstn)
	begin
		if(!de_rstn)oo_val_s0_reg <= 0;
		else if(inv)oo_val_s0_reg <= 0;
		else oo_val_s0_reg <= oo_val_s0_reg | set_s0_oo;
	end
always @(posedge de_clk or negedge de_rstn)
	begin
		if(!de_rstn)oo_val_s1_reg <= 0;
		else if(inv)oo_val_s1_reg <= 0;
		else oo_val_s1_reg <= oo_val_s1_reg | set_s1_oo;
	end
endmodule
