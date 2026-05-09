`timescale 1ns / 1ps
`define width 640 
`define height 480 
`timescale 1ns / 1ps
`define width 640 
`define height 480 
module sobel(
	clk_i,
	rst_i,
	cyc_i,
	stb_i,
	start,   
	we,   
	adr_in,  
	dat_in,   
	dat_out,      
	ack_out,    
	done     
    );
input  clk_i;
input  rst_i;
input cyc_i;
input stb_i;
input  start;   
input	 we;
input [21:0] adr_in;
input [31:0] dat_in;    
output  [31:0] dat_out;   
output reg ack_out;
output  done;   
wire  readstart;   
wire   start;     
wire   cyc_o;     
wire   stb_o;     
wire   we_o;		
wire   done_set;    
wire   shift_en;    
wire   prev_row_load;   
wire   curr_row_load;	
wire   next_row_load;	
wire   O_offset_cnt_en;   
wire   D_offset_cnt_en;		
wire   offset_reset;     
wire[31:0]   result_row;   
wire[31:0]   dat_i;    
wire[21:0]   adr_o;    
wire mem_ack_out;
wire done;   
assign readstart = cyc_i;
reg mem_we;
reg mem_cyc;
reg mem_stb;
reg [21:0] mem_adr_i;
wire [21:0] adr_out;
reg [31:0] mem_dat_in;
always @* begin  
	if(cyc_i) begin     
		mem_cyc = cyc_i;
		mem_stb = stb_i;
		mem_we = we;
		mem_adr_i = adr_in;
		mem_dat_in = dat_in;
		ack_out = mem_ack_out;
	end
	else begin            
		mem_cyc = cyc_o;
		mem_stb = stb_o;
		mem_we = we_o;
		mem_adr_i = adr_o;
		mem_dat_in = result_row;
		ack_out = 0;
	end
end
assign dat_out[31:0] = dat_i; 
assign   ack_i = mem_ack_out;  
compute compute(
	.rst_i(rst_i),     
	.clk_i(clk_i),
	.dat_i(dat_i),     
	.shift_en(shift_en),    
	.prev_row_load(prev_row_load),
	.curr_row_load(curr_row_load),
	.next_row_load(next_row_load),
	.result_row(result_row)
);
mem  mem(
	.clk_i(clk_i),
	.mem_cyc_i(mem_cyc),
	.mem_stb_i(mem_stb),
	.mem_we_i(mem_we),       
	.mem_ack_o(mem_ack_out),   
	.mem_adr_i(mem_adr_i),    
	.mem_dat_i(mem_dat_in),
	.mem_dat_o(dat_i),
	.readorg(readstart)
);
addr_gen addr_gen(
	.clk_i(clk_i),
	.O_offset_cnt_en(O_offset_cnt_en),
	.D_offset_cnt_en(D_offset_cnt_en),
	.offset_reset(offset_reset),
	.prev_row_load(prev_row_load),        
	.curr_row_load(curr_row_load),
	.next_row_load(next_row_load),
	.adr_o(adr_o)
);
machine machine(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.ack_i(ack_i),
	.start(start),
	.offset_reset(offset_reset),      
	.O_offset_cnt_en(O_offset_cnt_en),     
	.D_offset_cnt_en(D_offset_cnt_en),
	.prev_row_load(prev_row_load),
	.curr_row_load(curr_row_load),
	.next_row_load(next_row_load),
	.shift_en(shift_en),
	.cyc_o(cyc_o),
	.we_o(we_o),
	.stb_o(stb_o),
	.done_set(done)
);
endmodule
