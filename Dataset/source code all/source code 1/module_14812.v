`timescale 1ps / 1ps
`define MAJOR_VERSION             1
`define MINOR_VERSION             0
`define REVISION                  0
`define MAJOR_RANGE               31:28
`define MINOR_RANGE               27:20
`define REVISION_RANGE            19:16
`timescale 1ps / 1ps
`define MAJOR_VERSION             1
`define MINOR_VERSION             0
`define REVISION                  0
`define MAJOR_RANGE               31:28
`define MINOR_RANGE               27:20
`define REVISION_RANGE            19:16
module axi_lite_demo #(
  parameter ADDR_WIDTH          = 8,
  parameter DATA_WIDTH          = 32,
  parameter STROBE_WIDTH        = (DATA_WIDTH / 8),
  parameter INVERT_AXI_RESET    = 1
)(
  input                               clk,
  input                               rst,
  input                               i_awvalid,
  input       [ADDR_WIDTH - 1: 0]     i_awaddr,
  output                              o_awready,
  input                               i_wvalid,
  output                              o_wready,
  input       [DATA_WIDTH - 1: 0]     i_wdata,
  output                              o_bvalid,
  input                               i_bready,
  output      [1:0]                   o_bresp,
  input                               i_arvalid,
  output                              o_arready,
  input       [ADDR_WIDTH - 1: 0]     i_araddr,
  output                              o_rvalid,
  input                               i_rready,
  output      [1:0]                   o_rresp,
  output      [DATA_WIDTH - 1: 0]     o_rdata
);
localparam                  REG_CONTROL         = 0;
localparam                  REG_STATUS          = 1;
localparam                  REG_VERSION         = 2;
reg         [31:0]              control;
wire        [31:0]              status;
wire  [ADDR_WIDTH - 1: 0]           w_reg_address;
wire   [((ADDR_WIDTH - 1) - 2): 0]  w_reg_32bit_address;
reg                                 r_reg_invalid_addr;
wire                                w_reg_in_rdy;
reg                                 r_reg_in_ack_stb;
wire  [DATA_WIDTH - 1: 0]           w_reg_in_data;
wire                                w_reg_out_req;
reg                                 r_reg_out_rdy_stb;
reg   [DATA_WIDTH - 1: 0]           r_reg_out_data;
wire                                w_axi_rst;
axi_lite_slave #(
  .ADDR_WIDTH         (ADDR_WIDTH           ),
  .DATA_WIDTH         (DATA_WIDTH           )
) axi_lite_reg_interface (
  .clk                (clk                  ),
  .rst                (w_axi_rst            ),
  .i_awvalid          (i_awvalid            ),
  .i_awaddr           (i_awaddr             ),
  .o_awready          (o_awready            ),
  .i_wvalid           (i_wvalid             ),
  .o_wready           (o_wready             ),
  .i_wdata            (i_wdata              ),
  .o_bvalid           (o_bvalid             ),
  .i_bready           (i_bready             ),
  .o_bresp            (o_bresp              ),
  .i_arvalid          (i_arvalid            ),
  .o_arready          (o_arready            ),
  .i_araddr           (i_araddr             ),
  .o_rvalid           (o_rvalid             ),
  .i_rready           (i_rready             ),
  .o_rresp            (o_rresp              ),
  .o_rdata            (o_rdata              ),
  .o_reg_address      (w_reg_address        ),
  .i_reg_invalid_addr (r_reg_invalid_addr   ),
  .o_reg_in_rdy       (w_reg_in_rdy         ),
  .i_reg_in_ack_stb   (r_reg_in_ack_stb     ),
  .o_reg_in_data      (w_reg_in_data        ),
  .o_reg_out_req      (w_reg_out_req        ),
  .i_reg_out_rdy_stb  (r_reg_out_rdy_stb    ),
  .i_reg_out_data     (r_reg_out_data       )
);
assign        w_axi_rst               = (INVERT_AXI_RESET)   ? ~rst         : rst;
assign        w_reg_32bit_address     = w_reg_address[(ADDR_WIDTH - 1): 2];
always @ (posedge clk) begin
  r_reg_in_ack_stb                        <=  0;
  r_reg_out_rdy_stb                       <=  0;
  r_reg_invalid_addr                      <=  0;
  if (w_axi_rst) begin
    control                               <=  0;
    r_reg_out_data                        <=  0;
  end
  else begin
    if (w_reg_in_rdy && !r_reg_in_ack_stb) begin
      case (w_reg_32bit_address)
        REG_CONTROL: begin
          control                         <= w_reg_in_data;
        end
        default: begin
        end
      endcase
      if (w_reg_32bit_address > REG_VERSION) begin
        r_reg_invalid_addr                <= 1;
      end
      r_reg_in_ack_stb                    <= 1;
    end
    else if (w_reg_out_req && !r_reg_out_rdy_stb) begin
      case (w_reg_32bit_address)
        REG_CONTROL: begin
          r_reg_out_data                  <= control;
        end
        REG_STATUS: begin
          r_reg_out_data                  <= status;
        end
        REG_VERSION: begin
          r_reg_out_data                  <= 32'h00;
          r_reg_out_data[`MAJOR_RANGE]    <= `MAJOR_VERSION;
          r_reg_out_data[`MINOR_RANGE]    <= `MINOR_VERSION;
          r_reg_out_data[`REVISION_RANGE] <= `REVISION;
        end
        default: begin
          r_reg_out_data                  <= 32'h00;
        end
      endcase
      if (w_reg_32bit_address > REG_VERSION) begin
        r_reg_invalid_addr                <= 1;
      end
      r_reg_out_rdy_stb                   <= 1;
    end
  end
end
endmodule
