module dma_zx(
	input clk,
	input rst_n,
	input zxdmaread,  
	input zxdmawrite, 
	input      [7:0] dma_wr_data, 
	output reg [7:0] dma_rd_data, 
	output reg wait_ena, 
	output reg dma_on,
	input      [7:0] din,  
	output reg [7:0] dout,
	input module_select, 
	input write_strobe, 
	input [1:0] regsel, 
      output reg [20:0] dma_addr,
      output reg  [7:0] dma_wd,
      input       [7:0] dma_rd,
      output reg        dma_rnw,
      output reg dma_req,
      input      dma_ack,
      input      dma_end
);
	reg [7:0] dma_rd_temp; 
	reg [2:0] zxdmaread_sync;  
	reg [2:0] zxdmawrite_sync;
	reg zxread_begin, zxwrite_begin; 
	reg zxread_end,   zxwrite_end;   
	reg dma_prereq; 
	reg [1:0] waena_state,waena_next; 
	reg [1:0] dmarq_state,dmarq_next; 
	localparam _HAD = 2'b00; 
	localparam _MAD = 2'b01; 
	localparam _LAD = 2'b10; 
	localparam _CST = 2'b11; 
	always @*
	case( regsel[1:0] )
		_HAD: dout = { 3'b000, dma_addr[20:16] };
		_MAD: dout = dma_addr[15:8];
		_LAD: dout = dma_addr[7:0];
		_CST: dout = { dma_on, 7'bXXXXXXX };
	endcase
	always @(posedge clk, negedge rst_n)
	if( !rst_n ) 
	begin
		dma_on <= 1'b0;
	end
	else 
	begin
		if( module_select && write_strobe && (regsel==_CST) )
			dma_on <= din[7];
		if( dma_ack && dma_on )
			dma_addr <= dma_addr + 21'd1; 
		else if( module_select && write_strobe )
		begin
			if( regsel==_HAD )
				dma_addr[20:16] <= din[4:0];
			else if( regsel==_MAD )
				dma_addr[15:8]  <= din[7:0];
			else if( regsel==_LAD )
				dma_addr[7:0]   <= din[7:0];
		end
	end
	always @(posedge clk)
	begin
		zxdmaread_sync[2:0]  <= { zxdmaread_sync[1:0],  zxdmaread  };
		zxdmawrite_sync[2:0] <= { zxdmawrite_sync[1:0], zxdmawrite };
	end
	always @*
	begin
		zxread_begin  <= zxdmaread_sync[1]  && (!zxdmaread_sync[2]);
		zxwrite_begin <= zxdmawrite_sync[1] && (!zxdmawrite_sync[2]);
		zxread_end  <= (!zxdmaread_sync[1])  && zxdmaread_sync[2];
		zxwrite_end <= (!zxdmawrite_sync[1]) && zxdmawrite_sync[2];
	end
	always @* dma_rnw = 1'b1;
	localparam waenaIDLE = 0;
	localparam waenaWAIT = 1;
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		waena_state <= waenaIDLE;
	else if( !dma_on )
		waena_state <= waenaIDLE;
	else
		waena_state <= waena_next;
	always @*
	case( waena_state )
		waenaIDLE:
			if( zxread_end && (!dma_end) )
				waena_next <= waenaWAIT;
			else
				waena_next <= waenaIDLE;
		waenaWAIT:
			if( dma_end )
				waena_next <= waenaIDLE;
			else
				waena_next <= waenaWAIT;
	endcase
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		wait_ena <= 1'b0;
	else if( !dma_on )
		wait_ena <= 1'b0;
	else
	case( waena_next )
		waenaIDLE:
			wait_ena <= 1'b0;
		waenaWAIT:
			wait_ena <= 1'b1;
	endcase
	localparam dmarqIDLE = 0;
	localparam dmarqREQ1 = 1;
	localparam dmarqREQ2 = 2;
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		dmarq_state <= dmarqIDLE;
	else if( !dma_on )
		dmarq_state <= dmarqIDLE;
	else
		dmarq_state <= dmarq_next;
	always @*
	case( dmarq_state )
		dmarqIDLE:
			if( zxread_begin )
				dmarq_next <= dmarqREQ1;
			else
				dmarq_next <= dmarqIDLE;
		dmarqREQ1:
			if( dma_ack && (!zxread_begin) )
				dmarq_next <= dmarqIDLE;
			else if( (!dma_ack) && zxread_begin )
				dmarq_next <= dmarqREQ2;
			else 
				dmarq_next <= dmarqREQ1;
		dmarqREQ2:
			if( dma_ack )
				dmarq_next <= dmarqREQ1;
			else
				dmarq_next <= dmarqREQ2;
	endcase
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		dma_prereq <= 1'b0;
	else
	case( dmarq_next )
		dmarqIDLE:
			dma_prereq <= 1'b0;
		dmarqREQ1:
			dma_prereq <= 1'b1;
		dmarqREQ2:
			dma_prereq <= 1'b1;
	endcase
	always @* dma_req <= (dma_prereq | zxread_begin) & dma_on;
	always @(posedge clk) if( dma_end ) dma_rd_temp <= dma_rd;
	always @(posedge clk)
	begin
		if( zxread_end && dma_end ) 
			dma_rd_data <= dma_rd;
		else if( dma_end && wait_ena ) 
			dma_rd_data <= dma_rd;
		else if( zxread_end )
			dma_rd_data <= dma_rd_temp; 
	end
endmodule
