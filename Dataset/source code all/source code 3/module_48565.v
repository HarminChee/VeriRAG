`timescale 1 ns / 1 ps 
`timescale 1 ns / 1 ps 
module dut (
        ap_clk,
        ap_rst,
        in_fifo_V_dout,
        in_fifo_V_empty_n,
        in_fifo_V_read,
        out_fifo_V_din,
        out_fifo_V_full_n,
        out_fifo_V_write
);
input   ap_clk;
input   ap_rst;
input  [31:0] in_fifo_V_dout;
input   in_fifo_V_empty_n;
output   in_fifo_V_read;
output  [31:0] out_fifo_V_din;
input   out_fifo_V_full_n;
output   out_fifo_V_write;
reg in_fifo_V_read;
reg out_fifo_V_write;
reg   [31:0] cnt = 32'b00000000000000000000000000000000;
reg   [0:0] ap_CS_fsm = 1'b0;
reg    ap_sig_bdd_24;
wire   [31:0] tmp_fu_49_p2;
reg   [0:0] ap_NS_fsm;
parameter    ap_const_logic_1 = 1'b1;
parameter    ap_const_logic_0 = 1'b0;
parameter    ap_ST_st1_fsm_0 = 1'b0;
parameter    ap_const_lv32_0 = 32'b00000000000000000000000000000000;
parameter    ap_const_lv32_FFFFFFFF = 32'b11111111111111111111111111111111;
parameter    ap_true = 1'b1;
always @ (posedge ap_clk)
begin : ap_ret_ap_CS_fsm
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_st1_fsm_0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end
always @ (posedge ap_clk)
begin : ap_ret_cnt
    if (ap_rst == 1'b1) begin
        cnt <= ap_const_lv32_0;
    end else begin
        if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~ap_sig_bdd_24)) begin
            cnt <= tmp_fu_49_p2;
        end
    end
end
always @ (ap_CS_fsm or ap_sig_bdd_24)
begin
    if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~ap_sig_bdd_24)) begin
        ap_NS_fsm = ap_ST_st1_fsm_0;
    end else begin
        ap_NS_fsm = ap_CS_fsm;
    end
end
always @ (ap_CS_fsm or ap_sig_bdd_24)
begin
    if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~ap_sig_bdd_24)) begin
        in_fifo_V_read = ap_const_logic_1;
    end else begin
        in_fifo_V_read = ap_const_logic_0;
    end
end
always @ (ap_CS_fsm or ap_sig_bdd_24)
begin
    if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~ap_sig_bdd_24)) begin
        out_fifo_V_write = ap_const_logic_1;
    end else begin
        out_fifo_V_write = ap_const_logic_0;
    end
end
always @ (in_fifo_V_empty_n or out_fifo_V_full_n)
begin
    ap_sig_bdd_24 = ((in_fifo_V_empty_n == ap_const_logic_0) | (out_fifo_V_full_n == ap_const_logic_0));
end
assign out_fifo_V_din = (cnt + ap_const_lv32_FFFFFFFF);
assign tmp_fu_49_p2 = (cnt + ap_const_lv32_FFFFFFFF);
endmodule 
