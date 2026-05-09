`timescale 1ns / 1ps
`timescale 1ns / 1ps
module wb_async_reg #
(
    parameter DATA_WIDTH = 32,                  
    parameter ADDR_WIDTH = 32,                  
    parameter SELECT_WIDTH = (DATA_WIDTH/8)     
)
(
    input  wire                    wbm_clk,
    input  wire                    wbm_rst,
    input  wire [ADDR_WIDTH-1:0]   wbm_adr_i,   
    input  wire [DATA_WIDTH-1:0]   wbm_dat_i,   
    output wire [DATA_WIDTH-1:0]   wbm_dat_o,   
    input  wire                    wbm_we_i,    
    input  wire [SELECT_WIDTH-1:0] wbm_sel_i,   
    input  wire                    wbm_stb_i,   
    output wire                    wbm_ack_o,   
    output wire                    wbm_err_o,   
    output wire                    wbm_rty_o,   
    input  wire                    wbm_cyc_i,   
    input  wire                    wbs_clk,
    input  wire                    wbs_rst,
    output wire [ADDR_WIDTH-1:0]   wbs_adr_o,   
    input  wire [DATA_WIDTH-1:0]   wbs_dat_i,   
    output wire [DATA_WIDTH-1:0]   wbs_dat_o,   
    output wire                    wbs_we_o,    
    output wire [SELECT_WIDTH-1:0] wbs_sel_o,   
    output wire                    wbs_stb_o,   
    input  wire                    wbs_ack_i,   
    input  wire                    wbs_err_i,   
    input  wire                    wbs_rty_i,   
    output wire                    wbs_cyc_o    
);
reg [ADDR_WIDTH-1:0] wbm_adr_i_reg = 0;
reg [DATA_WIDTH-1:0] wbm_dat_i_reg = 0;
reg [DATA_WIDTH-1:0] wbm_dat_o_reg = 0;
reg wbm_we_i_reg = 0;
reg [SELECT_WIDTH-1:0] wbm_sel_i_reg = 0;
reg wbm_stb_i_reg = 0;
reg wbm_ack_o_reg = 0;
reg wbm_err_o_reg = 0;
reg wbm_rty_o_reg = 0;
reg wbm_cyc_i_reg = 0;
reg wbm_done_sync1 = 0;
reg wbm_done_sync2 = 0;
reg wbm_done_sync3 = 0;
reg [ADDR_WIDTH-1:0] wbs_adr_o_reg = 0;
reg [DATA_WIDTH-1:0] wbs_dat_i_reg = 0;
reg [DATA_WIDTH-1:0] wbs_dat_o_reg = 0;
reg wbs_we_o_reg = 0;
reg [SELECT_WIDTH-1:0] wbs_sel_o_reg = 0;
reg wbs_stb_o_reg = 0;
reg wbs_ack_i_reg = 0;
reg wbs_err_i_reg = 0;
reg wbs_rty_i_reg = 0;
reg wbs_cyc_o_reg = 0;
reg wbs_cyc_o_sync1 = 0;
reg wbs_cyc_o_sync2 = 0;
reg wbs_cyc_o_sync3 = 0;
reg wbs_stb_o_sync1 = 0;
reg wbs_stb_o_sync2 = 0;
reg wbs_stb_o_sync3 = 0;
reg wbs_done_reg = 0;
assign wbm_dat_o = wbm_dat_o_reg;
assign wbm_ack_o = wbm_ack_o_reg;
assign wbm_err_o = wbm_err_o_reg;
assign wbm_rty_o = wbm_rty_o_reg;
assign wbs_adr_o = wbs_adr_o_reg;
assign wbs_dat_o = wbs_dat_o_reg;
assign wbs_we_o = wbs_we_o_reg;
assign wbs_sel_o = wbs_sel_o_reg;
assign wbs_stb_o = wbs_stb_o_reg;
assign wbs_cyc_o = wbs_cyc_o_reg;
always @(posedge wbm_clk) begin
    if (wbm_rst) begin
        wbm_adr_i_reg <= 0;
        wbm_dat_i_reg <= 0;
        wbm_dat_o_reg <= 0;
        wbm_we_i_reg <= 0;
        wbm_sel_i_reg <= 0;
        wbm_stb_i_reg <= 0;
        wbm_ack_o_reg <= 0;
        wbm_err_o_reg <= 0;
        wbm_rty_o_reg <= 0;
        wbm_cyc_i_reg <= 0;
    end else begin
        if (wbm_cyc_i_reg & wbm_stb_i_reg) begin
            if (wbm_done_sync2 & ~wbm_done_sync3) begin
                wbm_dat_o_reg <= wbs_dat_i_reg;
                wbm_ack_o_reg <= wbs_ack_i_reg;
                wbm_err_o_reg <= wbs_err_i_reg;
                wbm_rty_o_reg <= wbs_rty_i_reg;
                wbm_we_i_reg <= 0;
                wbm_stb_i_reg <= 0;
            end
        end else begin
            wbm_adr_i_reg <= wbm_adr_i;
            wbm_dat_i_reg <= wbm_dat_i;
            wbm_dat_o_reg <= 0;
            wbm_we_i_reg <= wbm_we_i & ~(wbm_ack_o | wbm_err_o | wbm_rty_o);
            wbm_sel_i_reg <= wbm_sel_i;
            wbm_stb_i_reg <= wbm_stb_i & ~(wbm_ack_o | wbm_err_o | wbm_rty_o);
            wbm_ack_o_reg <= 0;
            wbm_err_o_reg <= 0;
            wbm_rty_o_reg <= 0;
            wbm_cyc_i_reg <= wbm_cyc_i;
        end
    end
    wbm_done_sync1 <= wbs_done_reg;
    wbm_done_sync2 <= wbm_done_sync1;
    wbm_done_sync3 <= wbm_done_sync2;
end
always @(posedge wbs_clk) begin
    if (wbs_rst) begin
        wbs_adr_o_reg <= 0;
        wbs_dat_i_reg <= 0;
        wbs_dat_o_reg <= 0;
        wbs_we_o_reg <= 0;
        wbs_sel_o_reg <= 0;
        wbs_stb_o_reg <= 0;
        wbs_ack_i_reg <= 0;
        wbs_err_i_reg <= 0;
        wbs_rty_i_reg <= 0;
        wbs_cyc_o_reg <= 0;
        wbs_done_reg <= 0;
    end else begin
        if (wbs_ack_i | wbs_err_i | wbs_rty_i) begin
            wbs_dat_i_reg <= wbs_dat_i;
            wbs_ack_i_reg <= wbs_ack_i;
            wbs_err_i_reg <= wbs_err_i;
            wbs_rty_i_reg <= wbs_rty_i;
            wbs_we_o_reg <= 0;
            wbs_stb_o_reg <= 0;
            wbs_done_reg <= 1;
        end else if (wbs_stb_o_sync2 & ~wbs_stb_o_sync3) begin
            wbs_adr_o_reg <= wbm_adr_i_reg;
            wbs_dat_i_reg <= 0;
            wbs_dat_o_reg <= wbm_dat_i_reg;
            wbs_we_o_reg <= wbm_we_i_reg;
            wbs_sel_o_reg <= wbm_sel_i_reg;
            wbs_stb_o_reg <= wbm_stb_i_reg;
            wbs_ack_i_reg <= 0;
            wbs_err_i_reg <= 0;
            wbs_rty_i_reg <= 0;
            wbs_cyc_o_reg <= wbm_cyc_i_reg;
            wbs_done_reg <= 0;
        end else if (~wbs_cyc_o_sync2 & wbs_cyc_o_sync3) begin
            wbs_adr_o_reg <= 0;
            wbs_dat_i_reg <= 0;
            wbs_dat_o_reg <= 0;
            wbs_we_o_reg <= 0;
            wbs_sel_o_reg <= 0;
            wbs_stb_o_reg <= 0;
            wbs_ack_i_reg <= 0;
            wbs_err_i_reg <= 0;
            wbs_rty_i_reg <= 0;
            wbs_cyc_o_reg <= 0;
            wbs_done_reg <= 0;
        end
    end
    wbs_cyc_o_sync1 <= wbm_cyc_i_reg;
    wbs_cyc_o_sync2 <= wbs_cyc_o_sync1;
    wbs_cyc_o_sync3 <= wbs_cyc_o_sync2;
    wbs_stb_o_sync1 <= wbm_stb_i_reg;
    wbs_stb_o_sync2 <= wbs_stb_o_sync1;
    wbs_stb_o_sync3 <= wbs_stb_o_sync2;
end
endmodule
