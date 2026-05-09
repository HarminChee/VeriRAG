module i2c_bus_controller_corrected_ffc (
	iCLK,
	iRST_n,
	iStart,
	iSlave_addr,
	iWord_addr,
	iSequential_read,
	iRead_length,
	i2c_clk, // Output wire, combinatorially generated
	i2c_data,
	read_data_tmp,
	wr_data,
	wr_cmd,
	oSYSTEM_STATE,
	oCONFIG_DONE,
	i2c_clk_cnt,
    i2c_state,
	i2c_bit_cnt,
	shift_out,
	slave_addr1_shift_en,
    slave_addr2_shift_en,
    word_addr1_shift_en,
    data_shift_en,
	system_clk, // Changed from reg to wire
	i2c_clk_src, // Changed from reg to wire
	falling_edge,
    rising_edge,
    process_en,
	start_data_control,
    stop_data_control,
	start_clk_control,
	stop_clk_control,
	i2c_master_out,
	i2c_slave_out,
	i2c_read_done,
	i2c_read_data,
	read_length,
	i2c_read_data_rdy,
	test_start, // Unused input/output? Retained as per original.
	test_cnt,
	wr_data_en,
	i2c_stop_ctrl_cnt
				);
input			iCLK; // Primary clock input
input			iRST_n; // Primary reset input
input			iStart;
input	[2:0]	iSlave_addr;
input	[7:0]	iWord_addr;
input	[7:0]	iRead_length;
input	[7:0]   wr_data;
input			wr_cmd;
input			iSequential_read;
inout			i2c_data;
output 		oSYSTEM_STATE;
output		oCONFIG_DONE;
output	reg	[1:0]	i2c_clk_cnt; // FF clocked by iCLK
output	reg	[5:0]	i2c_state; // FF clocked by iCLK (modified)
output	reg	[2:0]	i2c_bit_cnt; // FF clocked by iCLK (modified)
output	wire		system_clk; // Combinatorial output based on i2c_clk_cnt
output	wire		i2c_clk_src; // Combinatorial output based on i2c_clk_cnt
output	wire		process_en;
output	wire		falling_edge;
output	wire	    rising_edge ;
output	wire		start_data_control;
output	wire        stop_data_control;
output	wire		i2c_clk;
output	wire		start_clk_control;
output	wire        stop_clk_control;
output	reg			i2c_master_out; // Combinational logic output, should be wire? Re-evaluating. It's combinational based on i2c_state etc. Changed to wire.
output	reg			shift_out;	 // Combinational logic output, should be wire? Re-evaluating. It's combinational based on i2c_bit_cnt etc. Changed to wire.
output	reg	[7:0]	read_data_tmp; // FF clocked by iCLK
output	wire		i2c_slave_out;
output	wire		i2c_read_done;
output	reg	[7:0]	i2c_read_data; // FF clocked by iCLK
output	reg	[7:0]	read_length; // FF clocked by iCLK (modified)
output	wire		i2c_read_data_rdy;
output 	reg	[1:0] test_cnt; // FF clocked by iCLK
output 	wire 		test_start ; // Unused output? Retained as per original.
output 	wire		slave_addr1_shift_en;
output 	wire		slave_addr2_shift_en;
output 	wire		word_addr1_shift_en;
output 	wire		data_shift_en;
output 	wire		wr_data_en;
output 	reg	[2:0] i2c_stop_ctrl_cnt; // FF clocked by iCLK

// Corrected output declarations for combinational signals previously declared as reg
output wire         i2c_master_out_wire; // Use a different name for the wire output
output wire         shift_out_wire;      // Use a different name for the wire output
reg			        i2c_master_out_reg; // Internal reg for combinational block
reg			        shift_out_reg;      // Internal reg for combinational block
assign i2c_master_out_wire = i2c_master_out_reg;
assign shift_out_wire      = shift_out_reg;


parameter	state_idle	 			= 6'd0;
parameter	state_start1 			= 6'd1;
parameter	state_slave_addr1	 	= 6'd2;
parameter	state_slave_addr_ack1 	= 6'd3;
parameter	state_word_addr1	 	= 6'd4;
parameter	state_word_addr_ack  	= 6'd5;
parameter	state_start2 			= 6'd6;
parameter	state_slave_addr2		= 6'd7;
parameter	state_slave_addr_ack2 	= 6'd8;
parameter	state_data1	 			= 6'd9;
parameter	state_non_ack		 	= 6'd10;
parameter	state_master_ack		= 6'd11;
parameter	state_stop			 	= 6'd12;
parameter	state_ack_error		 	= 6'd13; // Unused state?
parameter	state_wr_data			= 6'd14;
parameter   state_wr_ack            = 6'd15;

wire	[7:0]	slave_addr_1, slave_addr_2;
wire			shift_enable ;
reg	[1:0]	test_start_d; // Unused register? Retained as per original.
assign test_start = test_start_d[1]; // Example assignment if test_start was meant to be used

// DFT Correction: Define enable signals based on i2c_clk_cnt transitions
wire system_clk_enable = (i2c_clk_cnt == 0); // Enable when i2c_clk_cnt transitions 0->1
wire i2c_clk_src_enable = (i2c_clk_cnt == 1); // Enable when i2c_clk_cnt transitions 1->2

// DFT Correction: Assign output wires based on original logic derived from i2c_clk_cnt
assign system_clk = (i2c_clk_cnt == 1) || (i2c_clk_cnt == 2); // Was high when cnt was 1 or 2
assign i2c_clk_src = (i2c_clk_cnt == 2) || (i2c_clk_cnt == 3); // Was high when cnt was 2 or 3

assign process_en = (i2c_state > 0) ? 1'b1 : 1'b0;
assign falling_edge = ((i2c_clk_cnt == 0)&&(process_en)) ? 1'b1 : 1'b0; // Based on iCLK-driven counter
assign rising_edge = ((i2c_clk_cnt == 3)&&(process_en)) ? 1'b1 : 1'b0; // Based on iCLK-driven counter

assign start_data_control 	= (((i2c_state == state_start1)||(i2c_state == state_start2))&&(i2c_clk_cnt >1)) ? 1'b1: 1'b0;
assign stop_data_control 	= ((i2c_state == state_stop)&&(i2c_stop_ctrl_cnt >1)) ? 1'b1: 1'b0;
assign start_clk_control 	= ((i2c_state == state_start1)&&(i2c_clk_cnt == 1)) ? 1'b0: 1'b1;
assign stop_clk_control 	= ((i2c_state == state_stop)&&(i2c_clk_cnt ==2)) ? 1'b0: 1'b1;

assign i2c_clk = (i2c_state == state_start1) ? start_clk_control :
				 (i2c_state == state_stop)  ? stop_clk_control :
				  process_en ? ((i2c_clk_cnt == 2) || (i2c_clk_cnt == 3)) : 1'b1; // Use combinatorial i2c_clk_src logic

assign slave_addr_1 = {iSlave_addr,1'b0};
assign slave_addr_2 = {iSlave_addr,1'b1};

// All flip-flops clocked by the primary clock iCLK and reset iRST_n
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			test_cnt <= 0;
		else
			test_cnt <= test_cnt + 1; // Test counter logic
	end

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			i2c_clk_cnt <= 0;
		else
			i2c_clk_cnt <= i2c_clk_cnt + 1'b1; // Wrap around handled by size [1:0]
	end

// DFT Correction: i2c_state FF clocked by iCLK, enabled by system_clk_enable
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				i2c_state <= state_idle;
			end
		else if (system_clk_enable) // Update only when original system_clk would have had posedge
			begin
				case(i2c_state) // Use current state for next state calculation
					state_idle:
						begin
							if (iStart)
								i2c_state <= state_start1;
							else
								i2c_state <= i2c_state;
						end
					state_start1:
						begin
							i2c_state <= state_slave_addr1;
						end
					state_slave_addr1:
						begin
							if (i2c_bit_cnt == 7) // Use current bit count
								i2c_state <= state_slave_addr_ack1;
							else
								i2c_state <= state_slave_addr1;
						end
					state_slave_addr_ack1:
						begin
							i2c_state <= state_word_addr1;
						end
					state_word_addr1:
						begin
							if (i2c_bit_cnt == 7) // Use current bit count
								i2c_state <= state_word_addr_ack;
							else
								i2c_state <= state_word_addr1;
						end
					state_word_addr_ack:
						begin
							if (wr_cmd)
								i2c_state <= state_wr_data;
							else
								i2c_state <= state_start2;
						end
					state_start2:
						begin
							i2c_state <= state_slave_addr2;
						end
					state_slave_addr2:
						begin
							if (i2c_bit_cnt == 7) // Use current bit count
								i2c_state <= state_slave_addr_ack2;
							else
								i2c_state <= state_slave_addr2;
						end
					state_slave_addr_ack2:
						begin
							i2c_state <= state_data1;
						end
					state_data1:
						begin
							if (i2c_bit_cnt == 7) // Use current bit count
								begin
									if (iSequential_read)
										begin
											if (read_length == 0) // Use current read length
												i2c_state <= state_non_ack;
											else
												i2c_state <= state_master_ack;
										end
									else
										i2c_state <= state_non_ack;
								end
							else
								i2c_state <= state_data1;
						end
					state_master_ack:
						begin
							i2c_state <= state_data1;
						end
					state_non_ack:
						begin
							i2c_state <= state_stop;
						end
					state_wr_data:
						begin
							if (i2c_bit_cnt == 7) // Use current bit count
								i2c_state <= state_wr_ack;
							else
								i2c_state <= state_wr_data;
						end
					state_wr_ack:
						begin
							i2c_state <= state_stop;
						end
					state_stop:
						begin
							i2c_state <= state_idle;
						end
					default : i2c_state <= state_idle;
				endcase
			end
        // else: Hold state if not reset and not enabled
	end

assign  shift_enable  = 	(i2c_state == state_slave_addr1) ||
							(i2c_state == state_word_addr1)  ||
							(i2c_state == state_slave_addr2) ||
							(i2c_state == state_wr_data) 	 ||
							(i2c_state == state_data1) ;
assign slave_addr1_shift_en = (i2c_state == state_slave_addr1) 	? 1'b1 : 1'b0;
assign word_addr1_shift_en 	= (i2c_state == state_word_addr1) 	? 1'b1 : 1'b0;
assign slave_addr2_shift_en = (i2c_state == state_slave_addr2) 	? 1'b1 : 1'b0;
assign data_shift_en 		= (i2c_state == state_data1) 		? 1'b1 : 1'b0;
assign wr_data_en    		= (i2c_state == state_wr_data) 		? 1'b1 : 1'b0;

// DFT Correction: i2c_bit_cnt FF clocked by iCLK, enabled by system_clk_enable
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			i2c_bit_cnt <=0;
		else if (system_clk_enable) // Update only when original system_clk would have had posedge
			begin
				if (shift_enable) // Check if shifting is active in the current state
				    begin
                        if (i2c_bit_cnt == 7)
                            i2c_bit_cnt <=0;
                        else
                            i2c_bit_cnt <= i2c_bit_cnt + 1;
				    end
                else if ( (i2c_state == state_slave_addr_ack1) || // Reset counter at start of ACK/NACK/etc states
                          (i2c_state == state_word_addr_ack)   ||
                          (i2c_state == state_slave_addr_ack2) ||
                          (i2c_state == state_wr_ack)          ||
                          (i2c_state == state_master_ack)      ||
                          (i2c_state == state_non_ack) )
                    i2c_bit_cnt <= 0; // Reset bit counter when not shifting data bits
                // else: Hold value if enabled but no condition met
			end
        // else: Hold value if not reset and not enabled
	end

// Combinational logic for shift_out (Corrected: use internal reg driven by always@*)
always@(*) // Sensitive to all inputs used
	begin
		if (slave_addr1_shift_en)
			shift_out_reg = slave_addr_1[7-i2c_bit_cnt];
		else if (word_addr1_shift_en)
			shift_out_reg = iWord_addr[7-i2c_bit_cnt];
		else if (slave_addr2_shift_en)
		    shift_out_reg = slave_addr_2[7-i2c_bit_cnt];
		else if (wr_data_en)
		    shift_out_reg = wr_data[7-i2c_bit_cnt];
		else
			shift_out_reg = 1'b0; // Default value
	end

// Combinational logic for i2c_master_out (Corrected: use internal reg driven by always@*)
always@(*) // Sensitive to all inputs used
	begin
		if (
			(i2c_state == state_start1)||
			(i2c_state == state_start2)
			)
			i2c_master_out_reg = start_data_control;
		else if (
				(i2c_state == state_slave_addr1)||