module i2c_bus_controller(
	iCLK,  
	iRST_n, 
	iStart,  
	iSlave_addr, 
	iWord_addr,   
	iSequential_read, 
	iRead_length, 
	i2c_clk, 
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
	system_clk,
	i2c_clk_src,
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
	test_start,
	test_cnt,
	wr_data_en,
	i2c_stop_ctrl_cnt,
	test_mode,
	scan_clk,
	scan_clk_src,
	scan_system_clk
				);
input			iCLK;
input			iRST_n;
input			iStart;
input	[2:0]	iSlave_addr;
input	[7:0]	iWord_addr;
input	[7:0]	iRead_length;
input	[7:0]   wr_data;
input			wr_cmd;
input			iSequential_read;
input           test_mode;
input           scan_clk;
input           scan_clk_src;
input           scan_system_clk;
inout			i2c_data;
output 		oSYSTEM_STATE;
output		oCONFIG_DONE;
output	reg	[1:0]	i2c_clk_cnt;
output	reg	[5:0]	i2c_state;
output	reg	[2:0]	i2c_bit_cnt;
output	reg			system_clk;
output	reg			i2c_clk_src;
output	wire			process_en;
output	wire			falling_edge;
output	wire	    	rising_edge ;
output	wire			start_data_control;
output	wire        stop_data_control; 
output	wire			i2c_clk;        
output	wire			start_clk_control;
output	wire        stop_clk_control; 
output	reg			i2c_master_out;                    
output	reg			shift_out;	
output	reg	[7:0]	read_data_tmp;	
output	wire			i2c_slave_out;
output	wire			i2c_read_done;
output	reg	[7:0]	i2c_read_data;
output	reg	[7:0]	read_length;
output	wire			i2c_read_data_rdy;
output 	reg	[1:0] test_cnt;
output 	wire 			test_start ;
output 	wire			slave_addr1_shift_en;
output 	wire			slave_addr2_shift_en;
output 	wire			word_addr1_shift_en;
output 	wire			data_shift_en;
output 	wire			wr_data_en;
output 	reg	[2:0] i2c_stop_ctrl_cnt;

// ... existing code ...

wire dft_clk;
wire dft_clk_src;
wire dft_system_clk;

assign dft_clk = test_mode ? scan_clk : i2c_clk;
assign dft_clk_src = test_mode ? scan_clk_src : i2c_clk_src;
assign dft_system_clk = test_mode ? scan_system_clk : system_clk;

// ... existing code ...

always@(posedge dft_clk_src or negedge iRST_n)
	begin
		if (!iRST_n)
			read_length <= 0;
		else if (i2c_state == state_start1)	
			read_length <= iRead_length;
		else if ((i2c_state == state_data1)&&(i2c_bit_cnt == 1))
			begin
				if (read_length == 0)
					read_length <= 0;	
				else	
					read_length <= read_length - 1;
			end
	end			

// ... existing code ...

endmodule