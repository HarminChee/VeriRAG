module line( 
	input clk,
	output reg [9:0] vector = 0,	
	output read_vector,		
	input [9:0] x0,			
	input [9:0] y0,			
	input [9:0] x1,			
	input [9:0] y1,			
	input [15:0] col,		
	input last_vector,		
	input trigger,			
	input fifo_full,
	output reg fifo_write,
	output reg [15:0] fifo_data );
reg [9:0] scan_y = 0;
reg [9:0] x = 0;			
reg [9:0] xend = 0;			
reg [10:0] e = 0;			
reg [9:0] w = 0;			
reg [9:0] h = 0;			
reg [9:0] off = 0;			
reg [15:0] col_1;			
reg start_frame = 0;			
reg start_line = 0;			
parameter
        SYNC = 2'd0,                    
        DRAW = 2'd1,                    
        COPY = 2'd2;                    
reg [2:0] state = SYNC;
reg [2:0] next = SYNC;
wire draw_done;
wire last_line = (scan_y == 479);
wire copy_done;
always @(posedge clk)
 	if( trigger )			start_frame <= 1;
	else				start_frame <= 0;
always @(posedge clk)
 	if( trigger | copy_done )	start_line <= 1;
	else				start_line <= 0;
always @(posedge clk)
	if( start_frame )		scan_y <= 0;
	else if( start_line )		scan_y <= scan_y + 1;
always @(posedge clk)
        state <= next;
always @* begin
        next = state;
        case( state )
            SYNC: if( trigger )         next = DRAW;
            DRAW: if( draw_done )       next = COPY; 
            COPY: if( copy_done )
	    	      if( last_line )   next = SYNC;
		      else		next = DRAW;
        endcase
end
reg [9:0] bres_wr_vector = 0;		
wire bres_we;				
wire span;				
wire [31:0] bres_rd_data;		
wire bres_valid;			
wire [9:0] bres_x;			
wire [10:0] bres_e;			
assign bres_valid = bres_rd_data[0]; 
assign bres_x = bres_rd_data[10:1];
assign bres_e = bres_rd_data[21:11];
RAMB16_S36_S36 Bresenham(
	.CLKA(clk),
	.ADDRA(vector),
	.DIPA(4'b0),
	.DIA(0),
	.DOA(bres_rd_data),
	.ENA(read_vector),
	.SSRA(1'b0),
	.WEA(1'b0),
	.CLKB(clk),
	.ADDRB(bres_wr_vector),
	.DIPB(4'b0),
	.DIB({e + w, x, 1'b1}),
	.ENB(bres_we),
	.WEB(bres_we),
	.SSRB(1'b0)
	);
reg drawing = 0;			
reg vector_valid = 0;
reg xy_valid = 0;
reg last_pixel = 0;
always @(posedge clk)
	last_pixel <= (x == xend);
wire in_range = off < h || (off == h && !last_pixel);
assign span = xy_valid && ~e[10] && in_range;
always @(posedge clk)
	if( start_line )			drawing <= 1;
	else if( vector_valid & last_vector )	drawing <= 0;
always @(posedge clk)
	if( start_line )			vector <= 0;
	else if( read_vector & drawing )	vector <= vector + 1;
always @(posedge clk)
	if( read_vector ) begin
	    vector_valid <= drawing;
	    xy_valid <= vector_valid && !last_vector;
	end
reg fill = 0;
always @(posedge clk)
	if( span || last_vector )		fill <= 0;
	else if( vector_valid )			fill <= 1;
assign bres_we = xy_valid && off <= h && e[10];		
always @(posedge clk)
	if( start_line )			bres_wr_vector <= 0;
	else if( bres_we )			bres_wr_vector <= bres_wr_vector + 1;
always @(posedge clk)
	if( span ) begin
	    e <= e - h;
	    x <= x + 1;
	end else if( read_vector ) begin
		w     <= x1 - x0;
		h     <= y1 - y0;
		off   <= scan_y - y0;
		xend  <= x1;
		col_1 <= col;
		if( bres_valid ) begin
		    x <= bres_x;
		    e <= bres_e;
		end else begin
		    x <= x0;
		    e <= 49;
		end
	end 
assign read_vector = !xy_valid || !span;
wire plot = (span | fill) && in_range;
reg xy_valid_1 = 0;
always @(posedge clk)
	xy_valid_1 <= xy_valid;
assign draw_done = xy_valid_1 && !xy_valid;
wire [9:0] wr_addr = x;
wire [15:0] wr_data = col_1;
reg [9:0] copy_addr = 0;
assign copy_done = (copy_addr == 639) & ~fifo_full;
reg vid_data_valid = 0;
wire [15:0] rd_data;
reg [9:0] fifo_count = 0;
always @(posedge clk)
	if( state != COPY )		vid_data_valid <= 0;
	else				vid_data_valid <= 1;
always @(posedge clk)
	if( state != COPY )		copy_addr <= 0;
	else if( ~fifo_full )		copy_addr <= copy_addr + 1;
RAMB16_S18_S18 line_buffer(
	.CLKA(clk),
	.ADDRA(copy_addr),
	.DIPA(2'b0),
	.DIA(0),
	.DOA(rd_data),
	.ENA( state == COPY && ~fifo_full ),
	.SSRA(1'b0),
	.WEA( 1'b1 ),
	.CLKB(clk),
	.ADDRB(wr_addr),
	.DIPB(2'b0),
	.DIB(wr_data),
	.ENB(plot),
	.WEB(plot),
	.SSRB(1'b0)
	);
defparam line_buffer.WRITE_MODE_A = "READ_FIRST";
always @(posedge clk)
	if( !fifo_full )
	    fifo_data <= rd_data;
always @(posedge clk)
	if( !fifo_full )
	    fifo_write <= vid_data_valid;
always @(posedge clk)
	if( ~vid_data_valid )		fifo_count <= 0;
	else if( ~fifo_full )		fifo_count <= fifo_count + 1;
endmodule
