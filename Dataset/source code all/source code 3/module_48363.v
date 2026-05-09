`undef USE_TO_MEMORY
`define USE_32BIT_MASTER
`undef USE_TO_MEMORY
`define USE_32BIT_MASTER
module video_sys_Video_DMA (
	clk,
	reset,
	stream_data,
	stream_startofpacket,
	stream_endofpacket,
	stream_empty,
	stream_valid,
	master_waitrequest,
	slave_address,
	slave_byteenable,
	slave_read,
	slave_write,
	slave_writedata,
	stream_ready,
	master_address,
	master_write,
	master_writedata,
	slave_readdata
);
parameter DW								= 15; 
parameter EW								= 0; 
parameter WIDTH							= 320; 
parameter HEIGHT							= 240; 
parameter AW								= 16; 
parameter WW								= 8; 
parameter HW								= 7; 
parameter MDW								= 15; 
parameter DEFAULT_BUFFER_ADDRESS		= 32'd0;
parameter DEFAULT_BACK_BUF_ADDRESS	= 32'd0;
parameter ADDRESSING_BITS				= 16'd2057;
parameter COLOR_BITS						= 4'd15;
parameter COLOR_PLANES					= 2'd0;
input						clk;
input						reset;
input			[DW: 0]	stream_data;
input						stream_startofpacket;
input						stream_endofpacket;
input			[EW: 0]	stream_empty;
input						stream_valid;
input						master_waitrequest;
input			[ 1: 0]	slave_address;
input			[ 3: 0]	slave_byteenable;
input						slave_read;
input						slave_write;
input			[31: 0]	slave_writedata;
output					stream_ready;
output		[31: 0]	master_address;
output					master_write;
output		[MDW:0]	master_writedata;
output		[31: 0]	slave_readdata;
wire						inc_address;
wire						reset_address;
wire			[31: 0]	buffer_start_address;
reg			[WW: 0]	w_address;		
reg			[HW: 0]	h_address;		
always @(posedge clk)
begin
	if (reset)
	begin
		w_address 	<= 'h0;
		h_address 	<= 'h0;
	end
	else if (reset_address)
	begin
		w_address 	<= 'h0;
		h_address 	<= 'h0;
	end
	else if (inc_address)
	begin
		if (w_address == (WIDTH - 1))
		begin
			w_address 	<= 'h0;
			h_address	<= h_address + 1;
		end
		else
			w_address 	<= w_address + 1;
	end
end
assign master_address		= buffer_start_address +
								{h_address, w_address, 1'b0};
altera_up_video_dma_control_slave DMA_Control_Slave (
	.clk									(clk),
	.reset								(reset),
	.address								(slave_address),
	.byteenable							(slave_byteenable),
	.read									(slave_read),
	.write								(slave_write),
	.writedata							(slave_writedata),
	.swap_addresses_enable			(reset_address),
	.readdata							(slave_readdata),
	.current_start_address			(buffer_start_address)
);
defparam
	DMA_Control_Slave.DEFAULT_BUFFER_ADDRESS		= DEFAULT_BUFFER_ADDRESS,
	DMA_Control_Slave.DEFAULT_BACK_BUF_ADDRESS	= DEFAULT_BACK_BUF_ADDRESS,
	DMA_Control_Slave.WIDTH								= WIDTH,
	DMA_Control_Slave.HEIGHT							= HEIGHT,
	DMA_Control_Slave.ADDRESSING_BITS				= ADDRESSING_BITS,
	DMA_Control_Slave.COLOR_BITS						= COLOR_BITS,
	DMA_Control_Slave.COLOR_PLANES					= COLOR_PLANES,
	DMA_Control_Slave.ADDRESSING_MODE				= 1'b0;
altera_up_video_dma_to_memory From_Stream_to_Memory (
	.clk									(clk),
	.reset								(reset),
	.stream_data						(stream_data),
	.stream_startofpacket			(stream_startofpacket),
	.stream_endofpacket				(stream_endofpacket),
	.stream_empty						(stream_empty),
	.stream_valid						(stream_valid),
	.master_waitrequest				(master_waitrequest),
	.stream_ready						(stream_ready),
	.master_write						(master_write),
	.master_writedata					(master_writedata),
	.inc_address						(inc_address),
	.reset_address						(reset_address)
);
defparam
	From_Stream_to_Memory.DW	= DW,
	From_Stream_to_Memory.EW	= EW,
	From_Stream_to_Memory.MDW	= MDW;
endmodule
