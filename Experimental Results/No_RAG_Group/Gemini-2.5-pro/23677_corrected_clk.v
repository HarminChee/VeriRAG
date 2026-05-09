`define     CONTROL_BIT_ENABLE_SDIO         0
`define     CONTROL_BIT_ENABLE_SDIO_INT     1
`define     CONTROL_BIT_ENABLE_SDIO_INT_EN  2
`define     CONTROL_BIT_ENABLE_DEBUG_INT    3
`define     CONTROL_BIT_USER_RESET          4
`define     BUFFER_OFFSET                   32'h00000400
`define     BUFFER_EXP                      10
`define     BUFFER_SIZE                     2**(`BUFFER_EXP)
`define     MEM_DELAY_COUNT                 2
// Duplicate defines removed

module wb_sdio_device (
  input               clk,
  input               rst,
  input               scan_enable, // Added DFT scan enable signal
  input               i_wbs_we,
  input               i_wbs_cyc,
  input       [3:0]   i_wbs_sel,
  input       [31:0]  i_wbs_dat,
  input               i_wbs_stb,
  output  reg         o_wbs_ack,
  output  reg [31:0]  o_wbs_dat,
  input       [31:0]  i_wbs_adr,
  output              o_wbs_int,
  input               i_phy_sd_clk,
  inout               io_phy_sd_cmd,
  inout       [3:0]   io_phy_sd_data
);
localparam    CONTROL               = 32'h00000000;
localparam    STATUS                = 32'h00000001;
localparam    CLOCK_COUNT           = 32'h00000002;
localparam    DEBUG_SD_CMD          = 32'h00000003;
localparam    DEBUG_SD_CMD_ARG      = 32'h00000004;
localparam    DEBUG_SD_PHY_STATE    = 32'h00000005;
localparam    DEBUG_SD_CONTROL_STATE= 32'h00000006;
localparam    SD_DELAY_VALUE        = 32'h00000007;
localparam    SD_DBG_CRC_GEN        = 32'h00000023;
localparam    SD_DBG_CRC_RMT        = 32'h00000024;
localparam    SD_DBG_CRC_DATA_GEN   = 32'h00000028;
localparam    SD_DBG_CRC_DATA_RMT   = 32'h0000002C;
wire              pll_locked;
wire              sd_clk;
wire              debug_interrupts;
reg               debug_interrupt_detect;
wire              sd_cmd_dir;
wire              sd_cmd_in;
wire              sd_cmd_out;
wire              sd_data_dir;
wire    [7:0]     sd_data_in;
wire    [7:0]     sd_data_out;
wire              fbr1_csa_en;
wire    [3:0]     fbr1_pwr_mode;
wire    [15:0]    fbr1_block_size;
wire              fbr2_csa_en;
wire    [3:0]     fbr2_pwr_mode;
wire    [15:0]    fbr2_block_size;
wire              fbr3_csa_en;
wire    [3:0]     fbr3_pwr_mode;
wire    [15:0]    fbr3_block_size;
wire              fbr4_csa_en;
wire    [3:0]     fbr4_pwr_mode;
wire    [15:0]    fbr4_block_size;
wire              fbr5_csa_en;
wire    [3:0]     fbr5_pwr_mode;
wire    [15:0]    fbr5_block_size;
wire              fbr6_csa_en;
wire    [3:0]     fbr6_pwr_mode;
wire    [15:0]    fbr6_block_size;
wire              fbr7_csa_en;
wire    [3:0]     fbr7_pwr_mode;
wire    [15:0]    fbr7_block_size;
wire    [7:0]     function_enable;
wire    [7:0]     function_ready;
wire    [2:0]     function_abort_stb;
wire    [7:0]     function_exec_status;
wire    [7:0]     function_ready_for_data;
wire              function_inc_addr;
wire              function_bock_mode;
wire              func_wr_stb   [0:8];
wire    [7:0]     func_wr_data  [0:8];
wire              func_rd_stb   [0:8];
wire    [7:0]     func_rd_data  [0:8];
wire              func_hst_rdy  [0:8];
wire              func_com_rdy  [0:8];
wire              func_activate [0:8];
wire    [7:0]     function_interrupt;
wire              func_inc_addr;
wire    [3:0]     func_num;
wire              func_write_flag;
wire              func_rd_after_wr;
wire    [17:0]    func_addr;
wire    [12:0]    func_data_count;
wire              func_block_mode;
wire              sdio_func_ready;
wire              sdio_func_int_pend;
wire              sdio_func_busy;
wire              sdio_func_exec_sts;
wire              local_buffer_en;
wire              local_buffer_we;
wire    [(`BUFFER_EXP - 1):0]     local_buffer_addr;
wire    [31:0]    local_buffer_data;
wire              enable_interrupts;
reg               request_interrupt;
reg     [31:0]    control;
wire    [31:0]    status;
reg     [3:0]     mem_delay_count;
wire              posedge_buffer;
reg               prev_buffer_en;
reg     [31:0]    clock_count = 0;
reg     [31:0]    clock_count_synced_to_clk; // Synchronized version for Wishbone read
wire              clk_for_clock_count; // Muxed clock for clock_count FF
wire    [5:0]     sd_cmd;
wire              sd_cmd_stb;
wire              sd_phy_idle;
wire    [31:0]    sd_cmd_arg;
wire    [3:0]     sd_phy_state;
reg               user_reset;
wire              user_reset_control;
wire              sdio_rst;
reg     [7:0]     delay_value;
reg     [7:0]     current_delay_value;
reg               delay_dir;
reg               delay_en;
wire    [3:0]     sd_control_state;
reg               sd_cntrl_stb_det;
wire    [7:0]     gen_crc;
wire    [7:0]     rmt_crc;
wire    [15:0]    crc0_data_rmt;
wire    [15:0]    crc1_data_rmt;
wire    [15:0]    crc2_data_rmt;
wire    [15:0]    crc3_data_rmt;
wire    [15:0]    crc0_data_gen;
wire    [15:0]    crc1_data_gen;
wire    [15:0]    crc2_data_gen;
wire    [15:0]    crc3_data_gen;

// Clock Mux for clock_count FF to allow scan testing using 'clk'
assign clk_for_clock_count = scan_enable ? clk : sd_clk;

cross_clock_strobe ccstb (
  .rst                  (rst                  ),
  .in_clk               (clk                  ),
  .in_stb               (user_reset           ),
  .out_clk              (sd_clk               ),
  .out_stb              (sdio_rst             )
);
sdio_device_stack sdio_device (
  .sdio_clk             (sd_clk               ),
  .rst                  (rst   || sdio_rst  || !pll_locked), // Consider DFT implications of complex resets
  // .scan_enable       (scan_enable), // Pass scan_enable down if needed
  .o_fbr1_csa_en        (fbr1_csa_en          ),
  .o_fbr1_pwr_mode      (fbr1_pwr_mode        ),
  .o_fbr1_block_size    (fbr1_block_size      ),
  .o_fbr2_csa_en        (fbr2_csa_en          ),
  .o_fbr2_pwr_mode      (fbr2_pwr_mode        ),
  .o_fbr2_block_size    (fbr2_block_size      ),
  .o_fbr3_csa_en        (fbr3_csa_en          ),
  .o_fbr3_pwr_mode      (fbr3_pwr_mode        ),
  .o_fbr3_block_size    (fbr3_block_size      ),
  .o_fbr4_csa_en        (fbr4_csa_en          ),
  .o_fbr4_pwr_mode      (fbr4_pwr_mode        ),
  .o_fbr4_block_size    (fbr4_block_size      ),
  .o_fbr5_csa_en        (fbr5_csa_en          ),
  .o_fbr5_pwr_mode      (fbr5_pwr_mode        ),
  .o_fbr5_block_size    (fbr5_block_size      ),
  .o_fbr6_csa_en        (fbr6_csa_en          ),
  .o_fbr6_pwr_mode      (fbr6_pwr_mode        ),
  .o_fbr6_block_size    (fbr6_block_size      ),
  .o_fbr7_csa_en        (fbr7_csa_en          ),
  .o_fbr7_pwr_mode      (fbr7_pwr_mode        ),
  .o_fbr7_block_size    (fbr7_block_size      ),
  .o_func1_wr_stb       (func_wr_stb[1]       ),
  .o_func1_wr_data      (func_wr_data[1]      ),
  .i_func1_rd_stb       (func_rd_stb[1]       ),
  .i_func1_rd_data      (func_rd_data[1]      ),
  .o_func1_hst_rdy      (func_hst_rdy[1]      ),
  .i_func1_com_rdy      (func_com_rdy[1]      ),
  .o_func1_activate     (func_activate[1]     ),
  .o_func2_wr_stb       (func_wr_stb[2]       ),
  .o_func2_wr_data      (func_wr_data[2]      ),
  .i_func2_rd_stb       (func_rd_stb[2]       ),
  .i_func2_rd_data      (func_rd_data[2]      ),
  .o_func2_hst_rdy      (func_hst_rdy[2]      ),
  .i_func2_com_rdy      (func_com_rdy[2]      ),
  .o_func2_activate     (func_activate[2]     ),
  .o_func3_wr_stb       (func_wr_stb[3]       ),
  .o_func3_wr_data      (func_wr_data[3]      ),
  .i_func3_rd_stb       (func_rd_stb[3]       ),
  .i_func3_rd_data      (func_rd_data[3]      ),
  .o_func3_hst_rdy      (func_hst_rdy[3]      ),
  .i_func3_com_rdy      (func_com_rdy[3]      ),
  .o_func3_activate     (func_activate[3]     ),
  .o_func4_wr_stb       (func_wr_stb[4]       ),
  .o_func4_wr_data      (func_wr_data[4]      ),
  .i_func4_rd_stb       (func_rd_stb[4]       ),
  .i_func4_rd_data      (func_rd_data[4]      ),
  .o_func4_hst_rdy      (func_hst_rdy[4]      ),
  .i_func4_com_rdy      (func_com_rdy[4]      ),
  .o_func4_activate     (func_activate[4]     ),
  .o_func5_wr_stb       (func_wr_stb[5]       ),
  .o_func5_wr_data      (func_wr_data[5]      ),
  .i_func5_rd_stb       (func_rd_stb[5]       ),
  .i_func5_rd_data      (func_rd_data[5]      ),
  .o_func5_hst_rdy      (func_hst_rdy[5]      ),
  .i_func5_com_rdy      (func_com_rdy[5]      ),
  .o_func5_activate     (func_activate[5]     ),
  .o_func6_wr_stb       (func_wr_stb[6]       ),
  .o_func6_wr_data      (func_wr_data[6]      ),
  .i_func6_rd_stb       (func_rd_stb[6]       ),
  .i_func6_rd_data      (func_rd_data[6]      ),
  .o_func6_hst_rdy      (func_hst_rdy[6]      ),
  .i_func6_com_rdy      (func_com_rdy[6]      ),
  .o_func6_activate     (func_activate[6]     ),
  .o_func7_wr_stb       (func_wr_stb[7]       ),
  .o_func7_wr_data      (func_wr_data[7]      ),
  .i_func7_rd_stb       (func_rd_stb[7]       ),
  .i_func7_rd_data      (func_rd_data[7]      ),
  .o_func7_hst_rdy      (func_hst_rdy[7]      ),
  .i_func7_com_rdy      (func_com_rdy[7]      ),
  .o_func7_activate     (func_activate[7]     ),
  .o_mem_wr_stb         (func_wr_stb[8]       ),
  .o_mem_wr_data        (func_wr_data[8]      ),
  .i_mem_rd_stb         (func_rd_stb[8]       ),
  .i_mem_rd_data        (func_rd_data[8]      ),
  .o_mem_hst_rdy        (func_hst_rdy[8]      ),
  .i_mem_com_rdy        (func_com_rdy[8]      ),
  .o_mem_activate       (func_activate[8]     ),
  .o_func_enable        (function_enable      ),
  .i_func_ready         (function_ready       ),
  .o_func_abort_stb     (function_abort_stb   ),
  .i_func_exec_status   (function_exec_status ),
  .i_func_ready_for_data(function_ready_for_data  ),
  .o_func_inc_addr      (func_inc_addr        ),
  .o_func_block_mode    (func_block_mode      ),
  .o_func_write_flag    (func_write_flag      ),
  .o_func_num           (func_num             ),
  .o_func_rd_after_wr   (func_rd_after_wr     ),
  .o_func_addr          (func_addr            ),
  .o_func_data_count    (func_data_count      ),
  .i_