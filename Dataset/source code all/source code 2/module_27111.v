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
      output reg [21:0] dma_addr,
      output reg  [7:0] dma_wd,
      input       [7:0] dma_rd,
      output reg        dma_rnw,
      output reg dma_req,
      input      dma_ack,
      input      dma_end
);
	reg [7:0] dma_rd_temp; 
	reg zxdmaread_sync;  
	reg zxdmawrite_sync; 
	reg [1:0] zxdmaread_strobe;  
	reg [1:0] zxdmawrite_strobe; 
	reg zxread_beg, zxwrite_beg; 
	reg zxread_end, zxwrite_end; 
	reg dma_prireq; 
	reg dma_prirnw; 
	reg waitena_reg; 
	reg waitena_fwd; 
	reg [3:0] zdma_state, zdma_next; 
	reg [1:0] dmarq_state,dmarq_next; 
	localparam _HAD = 2'b00; 
	localparam _MAD = 2'b01; 
	localparam _LAD = 2'b10; 
	localparam _CST = 2'b11; 
	always @*
	case( regsel[1:0] )
		_HAD: dout = { 2'b00, dma_addr[21:16] };
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
			dma_addr <= dma_addr + 22'd1; 
		else if( module_select && write_strobe )
		begin
			if( regsel==_HAD )
				dma_addr[21:16] <= din[5:0];
			else if( regsel==_MAD )
				dma_addr[15:8]  <= din[7:0];
			else if( regsel==_LAD )
				dma_addr[7:0]   <= din[7:0];
		end
	end
	always @(negedge clk) 
	begin
		zxdmaread_sync  <= zxdmaread;
		zxdmawrite_sync <= zxdmawrite;
	end
	always @(posedge clk)
	begin
		zxdmaread_strobe[1:0]  <= { zxdmaread_strobe[0],  zxdmaread_sync  };
		zxdmawrite_strobe[1:0] <= { zxdmawrite_strobe[0], zxdmawrite_sync };
	end
	always @*
	begin
		zxread_beg  <= zxdmaread_strobe[0]  && (!zxdmaread_strobe[1]);
		zxwrite_beg <= zxdmawrite_strobe[0] && (!zxdmawrite_strobe[1]);
		zxread_end  <= (!zxdmaread_strobe[0])  && zxdmaread_strobe[1];
		zxwrite_end <= (!zxdmawrite_strobe[0]) && zxdmawrite_strobe[1];
	end
	localparam zdmaIDLE       = 0;
	localparam zdmaREAD       = 1; 
	localparam zdmaENDREAD1   = 2; 
	localparam zdmaENDREAD2   = 3; 
	localparam zdmaSTARTWAIT  = 4; 
	localparam zdmaFWDNOWAIT1 = 5; 
	localparam zdmaFWDNOWAIT2 = 6; 
	localparam zdmaWAITED     = 7; 
	localparam zdmaWRITEWAIT  = 8; 
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		zdma_state <= zdmaIDLE;
	else if( !dma_on )
		zdma_state <= zdmaIDLE;
	else
		zdma_state <= zdma_next;
	always @*
	begin
		case( zdma_state )
		zdmaIDLE:
			if( zxread_beg )
				zdma_next = zdmaREAD;
			else if( zxwrite_end )
				zdma_next = zdmaWRITEWAIT;
			else
				zdma_next = zdmaIDLE;
		zdmaREAD:
			if( dma_end && zxread_end ) 
				zdma_next = zdmaFWDNOWAIT1;
			else if( zxread_end )
				zdma_next = zdmaSTARTWAIT;
			else if( dma_end )
				zdma_next = zdmaENDREAD1;
			else
				zdma_next = zdmaREAD;
		zdmaENDREAD1:
			if( zxread_end )
				zdma_next = zdmaENDREAD2;
			else
				zdma_next = zdmaENDREAD1;
		zdmaENDREAD2:
			if( zxread_beg )
				zdma_next = zdmaREAD;
			else
				zdma_next = zdmaIDLE;
		zdmaSTARTWAIT:
			if( dma_end && zxread_beg )
				zdma_next = zdmaFWDNOWAIT2;
			else if( dma_end )
				zdma_next = zdmaFWDNOWAIT1;
			else if( zxread_beg )
				zdma_next = zdmaWAITED;
			else if( zxwrite_beg ) 
				zdma_next = zdmaIDLE;
			else
				zdma_next = zdmaSTARTWAIT;
		zdmaFWDNOWAIT1:
			if( zxread_beg )
				zdma_next = zdmaREAD;
			else
				zdma_next = zdmaIDLE;
		zdmaFWDNOWAIT2:
			zdma_next = zdmaREAD;
		zdmaWAITED:
			if( dma_end )
				zdma_next = zdmaFWDNOWAIT2;
			else
				zdma_next = zdmaWAITED;
		zdmaWRITEWAIT:
			if( dma_ack )
				zdma_next = zdmaIDLE;
			else if( zxread_beg )
				zdma_next = zdmaIDLE;
			else
				zdma_next = zdmaWRITEWAIT;
		endcase
	end
	always @(posedge clk)
		if( dma_end ) dma_rd_temp <= dma_rd;
	always @(posedge clk)
		case( zdma_next )
			zdmaENDREAD2:
				dma_rd_data <= dma_rd_temp;
			zdmaFWDNOWAIT1:
				dma_rd_data <= dma_rd;
			zdmaFWDNOWAIT2:
				dma_rd_data <= dma_rd;
		endcase
	always @(posedge clk, negedge rst_n)
		if( !rst_n )
			waitena_reg <= 1'b0;
		else if( !dma_on )
			waitena_reg <= 1'b0;
		else if( (zdma_next == zdmaSTARTWAIT) || (zdma_next == zdmaWRITEWAIT) )
			waitena_reg <= 1'b1;
		else if( (zdma_state == zdmaFWDNOWAIT1) || (zdma_state == zdmaFWDNOWAIT2) || (zdma_state == zdmaIDLE) )
			waitena_reg <= 1'b0;
	always @*
		waitena_fwd = ( (zdma_state==zdmaREAD) && zxread_end && (!dma_end) ) || ( (zdma_state==zdmaIDLE) && zxwrite_end );
	always @*
		wait_ena = waitena_reg | waitena_fwd;
	localparam dmarqIDLE   = 0;
	localparam dmarqRDREQ1 = 1;
	localparam dmarqRDREQ2 = 2;
	localparam dmarqWRREQ  = 3;
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
			if( zxread_beg )
				dmarq_next <= dmarqRDREQ1;
			else if( zxwrite_end )
				dmarq_next <= dmarqWRREQ;
			else
				dmarq_next <= dmarqIDLE;
		dmarqRDREQ1:
			if( zxwrite_beg )
				dmarq_next <= dmarqIDLE; 
			else if( dma_ack && (!zxread_beg) )
				dmarq_next <= dmarqIDLE;
			else if( (!dma_ack) && zxread_beg )
				dmarq_next <= dmarqRDREQ2;
			else 
				dmarq_next <= dmarqRDREQ1;
		dmarqRDREQ2:
			if( dma_ack )
				dmarq_next <= dmarqRDREQ1;
			else
				dmarq_next <= dmarqRDREQ2;
		dmarqWRREQ:
			if( dma_ack || zxread_beg ) 
				dmarq_next <= dmarqIDLE;
			else
				dmarq_next <= dmarqWRREQ;
	endcase
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		dma_prireq <= 1'b0;
	else
	case( dmarq_next )
		dmarqIDLE:
		begin
			dma_prireq <= 1'b0;
		end
		dmarqRDREQ1:
		begin
			dma_prireq <= 1'b1;
			dma_prirnw <= 1'b1;
		end
		dmarqRDREQ2:
		begin
		end
		dmarqWRREQ:
		begin
			dma_prireq <= 1'b1;
			dma_prirnw <= 1'b0;
		end
	endcase
	always @* dma_req <= (dma_prireq | zxread_beg | zxwrite_end ) & dma_on;
	always @*
		if( zxread_beg )
			dma_rnw <= 1'b1;
		else if( zxwrite_end )
			dma_rnw <= 1'b0;
		else
			dma_rnw <= dma_prirnw;
	always @* dma_wd <= dma_wr_data;
endmodule
