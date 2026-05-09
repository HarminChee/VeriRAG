module dcache_top
(
	clk_i, 
	rst_i,
	mem_data_i, 
	mem_ack_i, 	
	mem_data_o, 
	mem_addr_o, 	
	mem_enable_o, 
	mem_write_o, 
	p1_data_i, 
	p1_addr_i, 	
	p1_MemRead_i, 
	p1_MemWrite_i, 
	p1_data_o, 
	p1_stall_o
);
input				clk_i; 
input				rst_i;
input	[256-1:0]	mem_data_i; 
input				mem_ack_i; 	
output	[256-1:0]	mem_data_o; 
output	[32-1:0]	mem_addr_o; 	
output				mem_enable_o; 
output				mem_write_o; 
input	[32-1:0]	p1_data_i; 
input	[32-1:0]	p1_addr_i; 	
input				p1_MemRead_i; 
input				p1_MemWrite_i; 
output	[32-1:0]	p1_data_o; 
output				p1_stall_o; 
wire	[4:0]		cache_sram_index;
wire				cache_sram_enable;
wire	[23:0]		cache_sram_tag;
wire	[255:0]		cache_sram_data;
wire				cache_sram_write;
wire	[23:0]		sram_cache_tag;
wire	[255:0]		sram_cache_data;
wire				sram_valid;
wire				sram_dirty;
parameter 			STATE_IDLE			= 3'h0,
					STATE_READMISS		= 3'h1,
					STATE_READMISSOK	= 3'h2,
					STATE_WRITEBACK		= 3'h3,
					STATE_MISS			= 3'h4;
reg		[2:0]		state;
reg					mem_enable;
reg					mem_write;
reg					cache_we;
wire				cache_dirty;
reg					write_back;
wire	[4:0]		p1_offset;
wire	[4:0]		p1_index;
wire	[21:0]		p1_tag;
wire	[255:0]		r_hit_data;
wire	[21:0]		sram_tag;
wire				hit;
reg		[255:0]		w_hit_data;
wire				write_hit;
wire				p1_req;
reg		[31:0]		p1_data;
assign 	p1_req = p1_MemRead_i | p1_MemWrite_i;
assign	p1_offset = p1_addr_i[4:0];
assign	p1_index = p1_addr_i[9:5];
assign	p1_tag = p1_addr_i[31:10];
assign	p1_stall_o = ~hit & p1_req;
assign	p1_data_o = p1_data; 
assign	sram_valid = sram_cache_tag[23];
assign	sram_dirty = sram_cache_tag[22];
assign	sram_tag = sram_cache_tag[21:0];
assign	cache_sram_index = p1_index;
assign	cache_sram_enable = p1_req;
assign	cache_sram_write = cache_we | write_hit;
assign	cache_sram_tag = {1'b1, cache_dirty, p1_tag};	
assign	cache_sram_data = (hit) ? w_hit_data : mem_data_i;
assign	mem_enable_o = mem_enable;
assign	mem_addr_o = (write_back) ? {sram_tag, p1_index, 5'b0} : {p1_tag, p1_index, 5'b0};
assign	mem_data_o = sram_cache_data;
assign	mem_write_o = mem_write;
assign	write_hit = hit & p1_MemWrite_i;
assign	cache_dirty = write_hit;
assign hit = (p1_tag==sram_tag)&sram_valid;
assign r_hit_data = hit?sram_cache_data:mem_data_o;
wire    [4:0]  cache_addr;
assign cache_addr=p1_offset<<3;
always@(p1_offset or r_hit_data) begin
    case(p1_offset)
    0:  p1_data <= r_hit_data[31:0];
    1:  p1_data <= r_hit_data[39:8];
    2:  p1_data <= r_hit_data[47:16];
    3:  p1_data <= r_hit_data[55:24];
    4:  p1_data <= r_hit_data[63:32];
    5:  p1_data <= r_hit_data[71:40];
    6:  p1_data <= r_hit_data[79:48];
    7:  p1_data <= r_hit_data[87:56];
    8:  p1_data <= r_hit_data[95:64];
    9:  p1_data <= r_hit_data[103:72];
    10: p1_data <= r_hit_data[111:80];
    11: p1_data <= r_hit_data[119:88];
    12: p1_data <= r_hit_data[127:96];
    13: p1_data <= r_hit_data[135:104];
    14: p1_data <= r_hit_data[143:112];
    15: p1_data <= r_hit_data[151:120];
    16: p1_data <= r_hit_data[159:128];
    17: p1_data <= r_hit_data[167:136];
    18: p1_data <= r_hit_data[175:144];
    19: p1_data <= r_hit_data[183:152];
    20: p1_data <= r_hit_data[191:160];
    21: p1_data <= r_hit_data[199:168];
    22: p1_data <= r_hit_data[207:176];
    23: p1_data <= r_hit_data[215:184];
    24: p1_data <= r_hit_data[223:192];
    25: p1_data <= r_hit_data[231:200];
    26: p1_data <= r_hit_data[239:208];
    27: p1_data <= r_hit_data[247:216];
    28: p1_data <= r_hit_data[255:224];
    29: p1_data <= r_hit_data[255:232];
    30: p1_data <= r_hit_data[255:240];
    31: p1_data <= r_hit_data[255:248];
    endcase
end
always@(p1_offset or r_hit_data or p1_data_i) begin
    w_hit_data <= r_hit_data;
    case(p1_offset)
    0:  w_hit_data[31:0] <= p1_data_i;
    1:  w_hit_data[39:8] <= p1_data_i;
    2:  w_hit_data[47:16] <= p1_data_i;
    3:  w_hit_data[55:24] <= p1_data_i;
    4:  w_hit_data[63:32] <= p1_data_i;
    5:  w_hit_data[71:40] <= p1_data_i;
    6:  w_hit_data[79:48] <= p1_data_i;
    7:  w_hit_data[87:56] <= p1_data_i;
    8:  w_hit_data[95:64] <= p1_data_i;
    9:  w_hit_data[103:72] <= p1_data_i;
    10: w_hit_data[111:80] <= p1_data_i;
    11: w_hit_data[119:88] <= p1_data_i;
    12: w_hit_data[127:96] <= p1_data_i;
    13: w_hit_data[135:104] <= p1_data_i;
    14: w_hit_data[143:112] <= p1_data_i;
    15: w_hit_data[151:120] <= p1_data_i;
    16: w_hit_data[159:128] <= p1_data_i;
    17: w_hit_data[167:136] <= p1_data_i;
    18: w_hit_data[175:144] <= p1_data_i;
    19: w_hit_data[183:152] <= p1_data_i;
    20: w_hit_data[191:160] <= p1_data_i;
    21: w_hit_data[199:168] <= p1_data_i;
    22: w_hit_data[207:176] <= p1_data_i;
    23: w_hit_data[215:184] <= p1_data_i;
    24: w_hit_data[223:192] <= p1_data_i;
    25: w_hit_data[231:200] <= p1_data_i;
    26: w_hit_data[239:208] <= p1_data_i;
    27: w_hit_data[247:216] <= p1_data_i;
    28: w_hit_data[255:224] <= p1_data_i;
    29: w_hit_data[255:232] <= p1_data_i;
    30: w_hit_data[255:240] <= p1_data_i;
    31: w_hit_data[255:248] <= p1_data_i;
    endcase
end
always@(posedge clk_i or negedge rst_i) begin
	if(~rst_i) begin
		state <= STATE_IDLE;
		mem_enable <= 1'b0;
		mem_write <= 1'b0;
		cache_we <= 1'b0; 
		write_back <= 1'b0;
	end
	else begin
		case(state)		
			STATE_IDLE: begin
				if(p1_req && !hit) begin	
					state <= STATE_MISS;
				end
				else begin
					state <= STATE_IDLE;
				end
			end
			STATE_MISS: begin
				if(sram_dirty) begin		
                    write_back <= 1;
                    mem_write <= 1;
                    mem_enable <= 1;
					state <= STATE_WRITEBACK;
				end
				else begin					
                    mem_enable <= 1;
                    state <= STATE_READMISS;
				end
			end
			STATE_READMISS: begin
				if(mem_ack_i) begin			
                    mem_enable <= 0;
                    cache_we <= 1;
					state <= STATE_READMISSOK;
				end
				else begin
                    mem_enable <= 1;
					state <= STATE_READMISS;
				end
			end
			STATE_READMISSOK: begin			
                cache_we <= 0;
				state <= STATE_IDLE;
			end
			STATE_WRITEBACK: begin
				if(mem_ack_i) begin			
                    mem_write <= 0;
                    write_back <= 0;
                    state <= STATE_READMISS;
				end
				else begin
					state <= STATE_WRITEBACK;
				end
			end
		endcase
	end
end
dcache_tag_sram dcache_tag_sram
(
	.clk_i(clk_i),
	.addr_i(cache_sram_index),
	.data_i(cache_sram_tag),
	.enable_i(cache_sram_enable),
	.write_i(cache_sram_write),
	.data_o(sram_cache_tag)
);
dcache_data_sram dcache_data_sram
(
	.clk_i(clk_i),
	.addr_i(cache_sram_index),
	.data_i(cache_sram_data),
	.enable_i(cache_sram_enable),
	.write_i(cache_sram_write),
	.data_o(sram_cache_data)
);
endmodule
