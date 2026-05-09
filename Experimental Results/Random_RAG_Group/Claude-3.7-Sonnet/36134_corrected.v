module i2c_bus_controller(
    test_i,
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
    i2c_stop_ctrl_cnt
                );
input           test_i;                
input           iCLK;
input           iRST_n;
input           iStart;
input   [2:0]   iSlave_addr;
input   [7:0]   iWord_addr;
input   [7:0]   iRead_length;
input   [7:0]   wr_data;
input           wr_cmd;
input           iSequential_read;
inout           i2c_data;
output          oSYSTEM_STATE;
output          oCONFIG_DONE;
output  reg [1:0]   i2c_clk_cnt;
output  reg [5:0]   i2c_state;
output  reg [2:0]   i2c_bit_cnt;
output  reg         system_clk;
output  reg         i2c_clk_src;
output  wire        process_en;
output  wire        falling_edge;
output  wire        rising_edge ;
output  wire        start_data_control;
output  wire        stop_data_control; 
output  wire        i2c_clk;        
output  wire        start_clk_control;
output  wire        stop_clk_control; 
output  reg         i2c_master_out;                    
output  reg         shift_out;  
output  reg [7:0]   read_data_tmp;   
output  wire        i2c_slave_out;
output  wire        i2c_read_done;
output  reg [7:0]   i2c_read_data;
output  reg [7:0]   read_length;
output  wire        i2c_read_data_rdy;
output  reg [1:0]   test_cnt;
output  wire        test_start ;
output  wire        slave_addr1_shift_en;
output  wire        slave_addr2_shift_en;
output  wire        word_addr1_shift_en;
output  wire        data_shift_en;
output  wire        wr_data_en;
output  reg [2:0]   i2c_stop_ctrl_cnt;

// ... existing code ...

wire dft_i2c_clk;
assign dft_i2c_clk = test_i ? iCLK : i2c_clk;

// ... existing code ...

always@(negedge dft_i2c_clk or negedge iRST_n)
    begin
        if (!iRST_n)
            i2c_bit_cnt <=0;
        else if (i2c_bit_cnt == 7)
            i2c_bit_cnt <=0;
        else if (
                  (i2c_state == state_slave_addr1) ||
                  (i2c_state == state_word_addr1)  ||        
                  (i2c_state == state_slave_addr2) ||    
                  (i2c_state == state_wr_data)     ||                  
                  (i2c_state == state_data1)          
                )                    
            i2c_bit_cnt <= i2c_bit_cnt + 1;
    end

// ... rest of existing code ...

endmodule