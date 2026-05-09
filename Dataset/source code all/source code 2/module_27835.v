module zxbus
(
	input  wire clk,
	input  wire rst_n,
	inout  wire [7:0] zxid, 
	input  wire [7:0] zxa,  
	input  wire       zxiorq_n,
	input  wire       zxmreq_n,
	input  wire       zxrd_n,
	input  wire       zxwr_n,
	output wire       zxblkiorq_n, 
	output reg        zxbusin,    
	output reg        zxbusena_n, 
	output reg        init, 
	input  wire       init_in_progress, 
	output reg        led, 
	output reg        autoinc_ena, 
	output reg        wr_addr,   
	output reg        wr_data,   
	output reg        rd_data,   
	output reg  [7:0] wr_buffer, 
	input  wire [7:0] rd_buffer  
);
	wire iowr = ~(zxiorq_n | zxwr_n);
	wire iord = ~(zxiorq_n | zxrd_n);
	reg [2:0] iowr_r;
	reg [2:0] iord_r;
	wire iowr_begin, iowr_end;
	wire iord_begin, iord_end;
	wire io_begin, io_end;
	wire addr_ok;
	reg wrr;
	wire [1:0] regsel;
	reg [7:0] read_data;
	reg        zxid_oe;
	reg  [7:0] zxid_out;
	wire [7:0] zxid_in;
	reg [8:0] test_reg;
	reg [7:0] test_reg_pre;
	reg       test_reg_write;
	assign regsel[1:0] = { zxa[7], zxa[3] };
	assign addr_ok = (zxa==8'h33) || (zxa==8'h3B) || (zxa==8'hB3) || (zxa==8'hBB);
	assign zxblkiorq_n = ~addr_ok;
	assign zxid = zxid_oe ? zxid_out : 8'bZZZZ_ZZZZ;
	assign zxid_in = zxid;
	always @(posedge clk)
	begin
		iowr_r[2:0] <= { iowr_r[1:0], iowr };
		iord_r[2:0] <= { iord_r[1:0], iord };
	end
	assign iowr_begin = iowr_r[1] && !iowr_r[2];
	assign iord_begin = iord_r[1] && !iord_r[2];
	assign iowr_end = !iowr_r[1] && iowr_r[2];
	assign iord_end = !iord_r[1] && iord_r[2];
	assign io_begin = iowr_begin || iord_begin;
	assign io_end   = iowr_end   || iord_end;
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
	begin
		zxbusin    <= 1'b1;
		zxbusena_n <= 1'b1;
	end
	else if( addr_ok && io_begin )
	begin
		zxbusin    <= ~iord_begin;
		zxbusena_n <= 1'b0;
	end
	else if( io_end )
	begin
		zxbusena_n <= 1'b1;
	end
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
	begin
		zxid_oe <= 1'b0;
	end
	else if( addr_ok && io_begin )
	begin
		zxid_oe <= iord_begin;
	end
	else if( io_end )
	begin
		zxid_oe <= 1'b0;
	end
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		wrr <= 1'b0;
	else
		wrr <= addr_ok && iowr_begin;
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		led <= 1'b0;
	else if( init )
		led <= 1'b0;
	else if( wrr && regsel==2'b00 && zxid[6] )
		led <= ~led;
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		init <= 1'b0;
	else if( wrr && regsel==2'b00 && zxid[7] )
		init <= 1'b1;
	else
		init <= 1'b0;
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		autoinc_ena <= 1'b0;
	else if( wrr && regsel==2'b00 )
		autoinc_ena <= zxid[5];
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
	begin
		test_reg <= 9'd0;
	end
	else if( init )
	begin
		test_reg <= 9'd0;
	end
	else if( test_reg_write )
	begin
		test_reg[8:0] <= { (~test_reg_pre[7:0]), test_reg[8] };
	end
	always @(posedge clk)
	if( wrr && regsel==2'b01 )
	begin
		test_reg_pre <= zxid_in;
		test_reg_write <= 1'b1;
	end
	else
	begin
		test_reg_write <= 1'b0;
	end
	always @(posedge clk)
	if( wrr && regsel==2'b10 )
		wr_addr <= 1'b1;
	else
		wr_addr <= 1'b0;
	always @(posedge clk)
	if( wrr && regsel==2'b11 )
		wr_data <= 1'b1;
	else
		wr_data <= 1'b0;
	always @(posedge clk)
	if( addr_ok && regsel==2'b11 && iord_begin )
		rd_data <= 1'b1;
	else
		rd_data <= 1'b0;
	always @(posedge clk)
	if( wrr && regsel[1]==1'b1 )
		wr_buffer <= zxid_in;
	always @*
	case( regsel )
		2'b00:   read_data = { init_in_progress, 7'd0 };
		2'b01:   read_data = test_reg[7:0];
		2'b11:   read_data = rd_buffer;
		default: read_data = 8'd0;
	endcase
	always @(posedge clk)
	if( addr_ok && iord_begin )
		zxid_out <= read_data;
endmodule
