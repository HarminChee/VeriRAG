`timescale 1ns / 1ps
`timescale 1ns / 1ps
module wb_reg #
(
    parameter DATA_WIDTH = 32,                  
    parameter ADDR_WIDTH = 32,                  
    parameter SELECT_WIDTH = (DATA_WIDTH/8)     
)
(
    input  wire                    clk,
    input  wire                    rst,
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
reg [DATA_WIDTH-1:0] wbm_dat_o_reg = 0;
reg wbm_ack_o_reg = 0;
reg wbm_err_o_reg = 0;
reg wbm_rty_o_reg = 0;
reg [ADDR_WIDTH-1:0] wbs_adr_o_reg = 0;
reg [DATA_WIDTH-1:0] wbs_dat_o_reg = 0;
reg wbs_we_o_reg = 0;
reg [SELECT_WIDTH-1:0] wbs_sel_o_reg = 0;
reg wbs_stb_o_reg = 0;
reg wbs_cyc_o_reg = 0;
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
always @(posedge clk) begin
    if (rst) begin
        wbm_dat_o_reg <= 0;
        wbm_ack_o_reg <= 0;
        wbm_err_o_reg <= 0;
        wbm_rty_o_reg <= 0;
        wbs_adr_o_reg <= 0;
        wbs_dat_o_reg <= 0;
        wbs_we_o_reg <= 0;
        wbs_sel_o_reg <= 0;
        wbs_stb_o_reg <= 0;
        wbs_cyc_o_reg <= 0;
    end else begin
        if (wbs_cyc_o_reg & wbs_stb_o_reg) begin
            if (wbs_ack_i | wbs_err_i | wbs_rty_i) begin
                wbm_dat_o_reg <= wbs_dat_i;
                wbm_ack_o_reg <= wbs_ack_i;
                wbm_err_o_reg <= wbs_err_i;
                wbm_rty_o_reg <= wbs_rty_i;
                wbs_we_o_reg <= 0;
                wbs_stb_o_reg <= 0;
            end
        end else begin
            wbm_dat_o_reg <= 0;
            wbm_ack_o_reg <= 0;
            wbm_err_o_reg <= 0;
            wbm_rty_o_reg <= 0;
            wbs_adr_o_reg <= wbm_adr_i;
            wbs_dat_o_reg <= wbm_dat_i;
            wbs_we_o_reg <= wbm_we_i & ~(wbm_ack_o | wbm_err_o | wbm_rty_o);
            wbs_sel_o_reg <= wbm_sel_i;
            wbs_stb_o_reg <= wbm_stb_i & ~(wbm_ack_o | wbm_err_o | wbm_rty_o);
            wbs_cyc_o_reg <= wbm_cyc_i;
        end
    end
end
endmodule
