`define EP16          1
`define IOSTND        "LVDS_25"
`define CLKEDGE       "SAME_EDGE_PIPELINED"
`define PHYS_EXT_MEM  4'h1

module top_parallella16_prototype (
    input wire processing_system7_0_PS_SRSTB,
    input wire processing_system7_0_PS_CLK,
    input wire processing_system7_0_PS_PORB,
    output wire processing_system7_0_DDR_WEB_pin,
    input wire [7:0] rxi_data_p,
    input wire [7:0] rxi_data_n,
    input wire rxi_frame_p,
    input wire rxi_frame_n,
    input wire rxi_lclk_p,
    input wire rxi_lclk_n,
    input wire txo_wr_wait_p,
    input wire txo_wr_wait_n,
    input wire txo_rd_wait_p,
    input wire txo_rd_wait_n,
    output wire [7:0] txo_data_p,
    output wire [7:0] txo_data_n,
    output wire txo_frame_p,
    output wire txo_frame_n,
    output wire txo_lclk_p,
    output wire txo_lclk_n,
    output wire rxi_wr_wait_p,
    output wire rxi_wr_wait_n,
    output wire rxi_rd_wait_p,
    output wire rxi_rd_wait_n,
    output wire aafm_resetn,
    output wire [2:0] aafm_ctrl,
    output wire aafm_xid0,
    output wire aafm_xid1,
    output wire aafm_xid2,
    output wire aafm_i2c_scl,
    input wire aafm_flag0,
    input wire aafm_flag1,
    input wire aafm_flag2,
    input wire aafm_flag3,
    input wire aafm_yid0,
    input wire aafm_yid1,
    input wire aafm_yid2,
    input wire [3:0] aafm_misc,
    input wire aafm_i2c_sda,
    output wire [7:0] user_led,
    input wire [1:0] user_pb
);

    wire sys_clk;
    wire esaxi_areset;
    wire fpga_reset;
    wire pbr_reset;
    wire [1:0] user_pb_clean;
    reg [19:0] por_cnt;
    reg por_reset;
    reg [1:0] user_pb_clean_reg;
    reg [31:0] counter_reg;

    assign sys_clk = processing_system7_0_PS_CLK;
    assign esaxi_areset = ~processing_system7_0_PS_SRSTB;
    assign aafm_ctrl = 3'b000;
    assign aafm_xid0 = 1'b0;
    assign aafm_xid1 = 1'b0;
    assign aafm_xid2 = 1'b0;
    assign aafm_i2c_scl = 1'b0;

    genvar k;
    generate
        for (k = 0; k < 2; k = k + 1) begin : gen_debounce
            debouncer #(20) debouncer_inst (
                .clean_out(user_pb_clean[k]),
                .clk(sys_clk),
                .noisy_in(user_pb[k])
            );
        end
    endgenerate

    always @(posedge sys_clk) begin
        user_pb_clean_reg <= user_pb_clean;
    end

    always @(posedge sys_clk) begin
        if (por_cnt == 20'hff13f) begin
            por_reset <= 1'b0;
        end else begin
            por_reset <= 1'b1;
            por_cnt <= por_cnt + 1;
        end
    end

    assign pbr_reset = user_pb_clean[0];
    assign user_led = ~counter_reg[30:23];

    always @(posedge sys_clk or posedge fpga_reset) begin
        if (fpga_reset) begin
            counter_reg <= 32'b0;
        end else begin
            counter_reg <= counter_reg + 1;
        end
    end

    assign fpga_reset = por_reset | pbr_reset | esaxi_areset;
    assign aafm_resetn = ~(por_reset | pbr_reset);

endmodule