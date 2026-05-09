`define ALTERA
`define ALTERA
module onchip_ram_top (
wb_clk_i, wb_rst_i,
wb_dat_i, wb_dat_o, wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i,
wb_stb_i, wb_ack_o, wb_err_o
);
function integer log2;
input [31:0] value;
for (log2=0; value>0; log2=log2+1)
value = value>>1;
endfunction
parameter dwidth = 32;
parameter size_bytes = 4096;
parameter initfile = "NONE";
parameter words = (size_bytes / (dwidth/8));  
parameter awidth = log2(size_bytes)-1;  
parameter bewidth = (dwidth/8);  
input wb_clk_i;
input wb_rst_i;
input [dwidth-1:0] wb_dat_i;
output [dwidth-1:0] wb_dat_o;
input [awidth-1:0] wb_adr_i;
input [bewidth-1:0] wb_sel_i;
input wb_we_i;
input wb_cyc_i;
input wb_stb_i;
output wb_ack_o;
output wb_err_o;
wire we;
wire [bewidth-1:0] be_i;
wire [dwidth-1:0] wb_dat_o;
wire ack_we;
reg ack_we1;
reg ack_we2;
reg ack_re;
assign wb_ack_o = ack_re | ack_we;
assign wb_err_o = 1'b0;  
assign we = wb_cyc_i & wb_stb_i & wb_we_i & (|wb_sel_i[bewidth-1:0]);
assign be_i = (wb_cyc_i & wb_stb_i) * wb_sel_i;
always @ (negedge wb_clk_i or posedge wb_rst_i)
begin
	if (wb_rst_i)
		ack_we1 <= 1'b0;
	else
		if (wb_cyc_i & wb_stb_i & wb_we_i & ~ack_we)
			ack_we1 <= #1 1'b1;
		else
			ack_we1 <= #1 1'b0;
end
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
	if (wb_rst_i)
		ack_we2 <= 1'b0;
	else
		ack_we2 <= ack_we1;
end
assign ack_we = ack_we1 & ~ack_we2;
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
	if (wb_rst_i)
		ack_re <= 1'b0;
	else
		if (wb_cyc_i & wb_stb_i & ~wb_err_o & ~wb_we_i & ~ack_re)
			ack_re <= 1'b1;
		else
			ack_re <= 1'b0;
end
`ifdef ALTERA
altsyncram altsyncram_component (
.wren_a (we),
.clock0 (wb_clk_i),
.byteena_a (be_i),
.address_a (wb_adr_i[awidth-1:2]),
.data_a (wb_dat_i),
.q_a (wb_dat_o));
defparam
altsyncram_component.intended_device_family = "CycloneII",
altsyncram_component.width_a = dwidth,
altsyncram_component.widthad_a = (awidth-2),
altsyncram_component.numwords_a = (words),
altsyncram_component.operation_mode = "SINGLE_PORT",
altsyncram_component.outdata_reg_a = "UNREGISTERED",
altsyncram_component.indata_aclr_a = "NONE",
altsyncram_component.wrcontrol_aclr_a = "NONE",
altsyncram_component.address_aclr_a = "NONE",
altsyncram_component.outdata_aclr_a = "NONE",
altsyncram_component.width_byteena_a = bewidth,
altsyncram_component.byte_size = 8,
altsyncram_component.byteena_aclr_a = "NONE",
altsyncram_component.ram_block_type = "AUTO",
altsyncram_component.lpm_type = "altsyncram",
altsyncram_component.init_file = initfile;
`else
reg [7:0] mem_bank0 [0:(words-1)];
reg [7:0] mem_bank1 [0:(words-1)];
reg [7:0] mem_bank2 [0:(words-1)];
reg [7:0] mem_bank3 [0:(words-1)];
wire we_0, we_1, we_2, we_3;
wire en;
reg [(awidth-3):0] addr_reg0;
reg [(awidth-3):0] addr_reg1;
reg [(awidth-3):0] addr_reg2;
reg [(awidth-3):0] addr_reg3;
assign we_0 = be_i[0] & wb_we_i;
assign we_1 = be_i[1] & wb_we_i;
assign we_2 = be_i[2] & wb_we_i;
assign we_3 = be_i[3] & wb_we_i;
assign en = (|be_i);
always @ (posedge wb_clk_i)
begin
	if (en) 
		begin
		addr_reg0 <= wb_adr_i[(awidth-1):2];
		if (we_0)
		begin
			mem_bank0[wb_adr_i[(awidth-1):2]] <= wb_dat_i[7:0];
		end
	end
	if (en) 
		begin
		addr_reg1 <= wb_adr_i[(awidth-1):2];
		if (we_1)
		begin
			mem_bank1[wb_adr_i[(awidth-1):2]] <= wb_dat_i[15:8];
		end
	end
	if (en) 
		begin
		addr_reg2 <= wb_adr_i[(awidth-1):2];
		if (we_2)
		begin
			mem_bank2[wb_adr_i[(awidth-1):2]] <= wb_dat_i[23:16];
		end
	end
	if (en) 
		begin
		addr_reg3 <= wb_adr_i[(awidth-1):2];
		if (we_3)
		begin
			mem_bank3[wb_adr_i[(awidth-1):2]] <= wb_dat_i[31:24];
		end
	end
end
assign wb_dat_o = {mem_bank3[addr_reg2], mem_bank2[addr_reg2], mem_bank1[addr_reg1], mem_bank0[addr_reg0]};
`endif
endmodule
