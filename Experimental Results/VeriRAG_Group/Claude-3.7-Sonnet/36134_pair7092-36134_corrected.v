module i2c_bus_controller(
    input iCLK,  
    input test_mode_i,
    input iRST_n, 
    input iStart,  
    input [2:0] iSlave_addr, 
    input [7:0] iWord_addr,   
    input iSequential_read, 
    input [7:0] iRead_length, 
    input [7:0] wr_data,
    input wr_cmd,
    inout i2c_data,
    output oSYSTEM_STATE,
    output oCONFIG_DONE,
    output reg [1:0] i2c_clk_cnt,
    output reg [5:0] i2c_state,
    output reg [2:0] i2c_bit_cnt,
    output reg system_clk,
    output reg i2c_clk_src,
    output wire process_en,
    output wire falling_edge,
    output wire rising_edge,
    output wire start_data_control,
    output wire stop_data_control, 
    output wire i2c_clk,        
    output wire start_clk_control,
    output wire stop_clk_control, 
    output reg i2c_master_out,                    
    output reg shift_out,    
    output reg [7:0] read_data_tmp,    
    output wire i2c_slave_out,
    output wire i2c_read_done,
    output reg [7:0] i2c_read_data,
    output reg [7:0] read_length,
    output wire i2c_read_data_rdy,
    output reg [1:0] test_cnt,
    output wire test_start,
    output wire slave_addr1_shift_en,
    output wire slave_addr2_shift_en,
    output wire word_addr1_shift_en,
    output wire data_shift_en,
    output wire wr_data_en,
    output reg [2:0] i2c_stop_ctrl_cnt
);

// ... existing code ...

wire dft_clk;
assign dft_clk = test_mode_i ? iCLK : system_clk;

// ... existing code ...

always@(posedge dft_clk or negedge iRST_n)
    begin
        if (!iRST_n)
            begin
                i2c_state <= 0;
            end
        else
            begin
                // ... existing state machine code ...
            end
    end

// ... rest of existing code ...

endmodule