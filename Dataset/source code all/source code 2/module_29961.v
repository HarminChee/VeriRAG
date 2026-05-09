module
	comm_fpga_epp(
		input  wire      clk_in,          
		input  wire      reset_in,        
		output reg       reset_out,       
		inout  wire[7:0] eppData_io,      
		input  wire      eppAddrStb_in,   
		input  wire      eppDataStb_in,   
		input  wire      eppWrite_in,     
		output wire      eppWait_out,     
		output wire[6:0] chanAddr_out,    
		output reg[7:0]  h2fData_out,     
		output reg       h2fValid_out,    
		input  wire      h2fReady_in,     
		input  wire[7:0] f2hData_in,      
		input  wire      f2hValid_in,     
		output reg       f2hReady_out     
	);
	localparam[2:0] S_RESET            = 3'h0;
	localparam[2:0] S_IDLE             = 3'h1;
	localparam[2:0] S_ADDR_WRITE_WAIT  = 3'h2;
	localparam[2:0] S_DATA_WRITE_EXEC  = 3'h3;
	localparam[2:0] S_DATA_WRITE_WAIT  = 3'h4;
	localparam[2:0] S_DATA_READ_EXEC   = 3'h5;
	localparam[2:0] S_DATA_READ_WAIT   = 3'h6;
	reg[2:0] state           = S_RESET;
	reg[2:0] state_next;
	reg      eppAddrStb_sync = 1'b1;
	reg      eppDataStb_sync = 1'b1;
	reg      eppWrite_sync   = 1'b1;
	reg      eppWait         = 1'b0;
	reg      eppWait_next;
	reg[6:0] chanAddr        = 7'b0000000;
	reg[6:0] chanAddr_next;
	reg[7:0] eppData         = 8'h00;
	reg[7:0] eppData_next;
	reg      driveBus        = 1'b0;	
	always @(posedge clk_in)
	begin
		if ( reset_in == 1'b1 )
			begin
				state           <= S_RESET;
				chanAddr        <= 7'b0000000;
				eppData         <= 8'h00;
				eppWait         <= 1'b1;
				eppAddrStb_sync <= 1'b1;
				eppDataStb_sync <= 1'b1;
				eppWrite_sync   <= 1'b1;
			end
		else
			begin
				state           <= state_next;
				chanAddr        <= chanAddr_next;
				eppData         <= eppData_next;
				eppWait         <= eppWait_next;
				eppAddrStb_sync <= eppAddrStb_in;
				eppDataStb_sync <= eppDataStb_in;
				eppWrite_sync   <= eppWrite_in;
			end
	end
	always @*
	begin
		state_next = state;
		chanAddr_next = chanAddr;
		eppWait_next = eppWait;
		eppData_next = eppData;
		h2fData_out = 8'h00;
		f2hReady_out = 1'b0;
		h2fValid_out = 1'b0;
		reset_out = 1'b0;
		driveBus = eppWrite_sync;
		case ( state )
			S_ADDR_WRITE_WAIT:
				begin
					if ( eppAddrStb_sync == 1'b1 )
						begin
							eppWait_next = 1'b0;
							state_next = S_IDLE;
						end
				end
			S_DATA_WRITE_EXEC:
				begin
					h2fData_out = eppData_io;
					h2fValid_out = 1'b1;
					if ( h2fReady_in == 1'b1 )
						begin
							eppWait_next = 1'b1;
							state_next = S_DATA_WRITE_WAIT;
						end
				end
			S_DATA_WRITE_WAIT:
				begin
					if ( eppDataStb_sync == 1'b1 )
						begin
							eppWait_next = 1'b0;
							state_next = S_IDLE;
						end
				end
			S_DATA_READ_EXEC:
				begin
					eppData_next = f2hData_in;
					f2hReady_out = 1'b1;
					if ( f2hValid_in == 1'b1 )
						begin
							eppWait_next = 1'b1;
							state_next = S_DATA_READ_WAIT;
						end
				end
			S_DATA_READ_WAIT:
				begin
					if ( eppDataStb_sync == 1'b1 )
						begin
							eppWait_next = 1'b0;
							state_next = S_IDLE;
						end
				end
			S_RESET:
				begin
					reset_out = 1'b1;
					driveBus = 1'b0;
					if ( eppWrite_sync == 1'b0 )
						begin
							state_next = S_IDLE;
						end
				end
			default:
				begin
					eppWait_next = 1'b0;
					if ( eppAddrStb_sync == 1'b0 )
						begin
							if ( eppWrite_sync == 1'b0 )
								begin
									eppWait_next = 1'b1;
									chanAddr_next = eppData_io[6:0];
									state_next = S_ADDR_WRITE_WAIT;
								end
						end
					else if ( eppDataStb_sync == 1'b0 )
						begin
							if ( eppWrite_sync == 1'b0 )
								state_next = S_DATA_WRITE_EXEC;
							else
								state_next = S_DATA_READ_EXEC;
						end
				end
		endcase
	end
	assign chanAddr_out = chanAddr;
	assign eppWait_out = eppWait;
	assign eppData_io = (driveBus == 1'b1) ? eppData : 8'hZZ;
endmodule
module
	comm_fpga_epp(
		input  wire      clk_in,          
		input  wire      reset_in,        
		output reg       reset_out,       
		inout  wire[7:0] eppData_io,      
		input  wire      eppAddrStb_in,   
		input  wire      eppDataStb_in,   
		input  wire      eppWrite_in,     
		output wire      eppWait_out,     
		output wire[6:0] chanAddr_out,    
		output reg[7:0]  h2fData_out,     
		output reg       h2fValid_out,    
		input  wire      h2fReady_in,     
		input  wire[7:0] f2hData_in,      
		input  wire      f2hValid_in,     
		output reg       f2hReady_out     
	);
	localparam[2:0] S_RESET            = 3'h0;
	localparam[2:0] S_IDLE             = 3'h1;
	localparam[2:0] S_ADDR_WRITE_WAIT  = 3'h2;
	localparam[2:0] S_DATA_WRITE_EXEC  = 3'h3;
	localparam[2:0] S_DATA_WRITE_WAIT  = 3'h4;
	localparam[2:0] S_DATA_READ_EXEC   = 3'h5;
	localparam[2:0] S_DATA_READ_WAIT   = 3'h6;
	reg[2:0] state           = S_RESET;
	reg[2:0] state_next;
	reg      eppAddrStb_sync = 1'b1;
	reg      eppDataStb_sync = 1'b1;
	reg      eppWrite_sync   = 1'b1;
	reg      eppWait         = 1'b0;
	reg      eppWait_next;
	reg[6:0] chanAddr        = 7'b0000000;
	reg[6:0] chanAddr_next;
	reg[7:0] eppData         = 8'h00;
	reg[7:0] eppData_next;
	reg      driveBus        = 1'b0;	
	always @(posedge clk_in)
	begin
		if ( reset_in == 1'b1 )
			begin
				state           <= S_RESET;
				chanAddr        <= 7'b0000000;
				eppData         <= 8'h00;
				eppWait         <= 1'b1;
				eppAddrStb_sync <= 1'b1;
				eppDataStb_sync <= 1'b1;
				eppWrite_sync   <= 1'b1;
			end
		else
			begin
				state           <= state_next;
				chanAddr        <= chanAddr_next;
				eppData         <= eppData_next;
				eppWait         <= eppWait_next;
				eppAddrStb_sync <= eppAddrStb_in;
				eppDataStb_sync <= eppDataStb_in;
				eppWrite_sync   <= eppWrite_in;
			end
	end
	always @*
	begin
		state_next = state;
		chanAddr_next = chanAddr;
		eppWait_next = eppWait;
		eppData_next = eppData;
		h2fData_out = 8'h00;
		f2hReady_out = 1'b0;
		h2fValid_out = 1'b0;
		reset_out = 1'b0;
		driveBus = eppWrite_sync;
		case ( state )
			S_ADDR_WRITE_WAIT:
				begin
					if ( eppAddrStb_sync == 1'b1 )
						begin
							eppWait_next = 1'b0;
							state_next = S_IDLE;
						end
				end
			S_DATA_WRITE_EXEC:
				begin
					h2fData_out = eppData_io;
					h2fValid_out = 1'b1;
					if ( h2fReady_in == 1'b1 )
						begin
							eppWait_next = 1'b1;
							state_next = S_DATA_WRITE_WAIT;
						end
				end
			S_DATA_WRITE_WAIT:
				begin
					if ( eppDataStb_sync == 1'b1 )
						begin
							eppWait_next = 1'b0;
							state_next = S_IDLE;
						end
				end
			S_DATA_READ_EXEC:
				begin
					eppData_next = f2hData_in;
					f2hReady_out = 1'b1;
					if ( f2hValid_in == 1'b1 )
						begin
							eppWait_next = 1'b1;
							state_next = S_DATA_READ_WAIT;
						end
				end
			S_DATA_READ_WAIT:
				begin
					if ( eppDataStb_sync == 1'b1 )
						begin
							eppWait_next = 1'b0;
							state_next = S_IDLE;
						end
				end
			S_RESET:
				begin
					reset_out = 1'b1;
					driveBus = 1'b0;
					if ( eppWrite_sync == 1'b0 )
						begin
							state_next = S_IDLE;
						end
				end
			default:
				begin
					eppWait_next = 1'b0;
					if ( eppAddrStb_sync == 1'b0 )
						begin
							if ( eppWrite_sync == 1'b0 )
								begin
									eppWait_next = 1'b1;
									chanAddr_next = eppData_io[6:0];
									state_next = S_ADDR_WRITE_WAIT;
								end
						end
					else if ( eppDataStb_sync == 1'b0 )
						begin
							if ( eppWrite_sync == 1'b0 )
								state_next = S_DATA_WRITE_EXEC;
							else
								state_next = S_DATA_READ_EXEC;
						end
				end
		endcase
	end
	assign chanAddr_out = chanAddr;
	assign eppWait_out = eppWait;
	assign eppData_io = (driveBus == 1'b1) ? eppData : 8'hZZ;
endmodule
