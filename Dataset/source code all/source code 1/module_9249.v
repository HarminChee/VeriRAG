`timescale 1ns/1ns
`timescale 1ns/1ns
module pcie_upconfig_fix_3451_v6 # (
  parameter                                     UPSTREAM_FACING = "TRUE",
  parameter                                     PL_FAST_TRAIN = "FALSE",
  parameter                                     LINK_CAP_MAX_LINK_WIDTH = 6'h08,
  parameter                                     TCQ = 1
)
(
  input                                         pipe_clk,
  input                                         pl_phy_lnkup_n,
  input  [5:0]                                  pl_ltssm_state,
  input                                         pl_sel_lnk_rate,
  input  [1:0]                                  pl_directed_link_change,
  input  [3:0]                                  cfg_link_status_negotiated_width,
  input  [15:0]                                 pipe_rx0_data,
  input  [1:0]                                  pipe_rx0_char_isk,
  output                                        filter_pipe
);
  reg                                           reg_filter_pipe;
  reg  [15:0]                                   reg_tsx_counter;
  wire [15:0]                                   tsx_counter;
  wire [5:0]                                    cap_link_width;
reg reg_filter_used, reg_com_then_pad;
reg reg_data0_b4, reg_data0_08, reg_data0_43;
reg reg_data1_b4, reg_data1_08, reg_data1_43;
reg reg_data0_com, reg_data1_com, reg_data1_pad;
wire  data0_b4 = pipe_rx0_char_isk[0] &&
        ((pipe_rx0_data[7:0] & 8'hb4) == 8'hb4);
wire  data0_08 = ((pipe_rx0_data[7:0] & 8'h4b) == 8'h08);
wire  data0_43 = ((pipe_rx0_data[7:0] & 8'h4b) == 8'h43);
wire  data1_b4 = pipe_rx0_char_isk[1] &&
        ((pipe_rx0_data[15:8] & 8'hb4) == 8'hb4);
wire  data1_08 = ((pipe_rx0_data[15:8] & 8'h4b) == 8'h08);
wire  data1_43 = ((pipe_rx0_data[15:8] & 8'h4b) == 8'h43);
wire  data0_com = reg_data0_b4 && reg_data0_08;
wire  data1_com = reg_data1_b4 && reg_data1_08;
wire  data0_pad = reg_data0_b4 && reg_data0_43;
wire  data1_pad = reg_data1_b4 && reg_data1_43;
wire  com_then_pad0 = reg_data0_com && reg_data1_pad && data0_pad;
wire  com_then_pad1 = reg_data1_com && data0_pad && data1_pad;
wire  com_then_pad = (com_then_pad0 || com_then_pad1) && ~reg_filter_used;
wire  filter_used = (pl_ltssm_state == 6'h20) &&
        (reg_filter_pipe || reg_filter_used);
  always @(posedge pipe_clk) begin
    reg_data0_b4 <= #TCQ data0_b4;
    reg_data0_08 <= #TCQ data0_08;
    reg_data0_43 <= #TCQ data0_43;
    reg_data1_b4 <= #TCQ data1_b4;
    reg_data1_08 <= #TCQ data1_08;
    reg_data1_43 <= #TCQ data1_43;
    reg_data0_com <= #TCQ data0_com;
    reg_data1_com <= #TCQ data1_com;
    reg_data1_pad <= #TCQ data1_pad;
    reg_com_then_pad <= #TCQ (~pl_phy_lnkup_n) ? com_then_pad : 1'b0;
    reg_filter_used <= #TCQ (~pl_phy_lnkup_n) ? filter_used : 1'b0;
  end
  always @ (posedge pipe_clk) begin
    if (pl_phy_lnkup_n) begin
      reg_tsx_counter <= #TCQ 16'h0;
      reg_filter_pipe <= #TCQ 1'b0;
    end else if ((pl_ltssm_state == 6'h20) &&
     reg_com_then_pad &&
                 (cfg_link_status_negotiated_width != cap_link_width) &&
                 (pl_directed_link_change[1:0] == 2'b00)) begin
      reg_tsx_counter <= #TCQ 16'h0;
      reg_filter_pipe <= #TCQ 1'b1;
    end else if (filter_pipe == 1'b1) begin
      if (tsx_counter < ((PL_FAST_TRAIN == "TRUE") ? 16'd225: pl_sel_lnk_rate ? 16'd800 : 16'd400)) begin
        reg_tsx_counter <= #TCQ tsx_counter + 1'b1;
        reg_filter_pipe <= #TCQ 1'b1;
      end else begin
        reg_tsx_counter <= #TCQ 16'h0;
        reg_filter_pipe <= #TCQ 1'b0;
      end
    end
  end
  assign filter_pipe = (UPSTREAM_FACING == "TRUE") ? 1'b0 : reg_filter_pipe;
  assign tsx_counter = reg_tsx_counter;
  assign cap_link_width = LINK_CAP_MAX_LINK_WIDTH;
endmodule
