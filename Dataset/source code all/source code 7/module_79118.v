`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_crossbar_v2_1_10_decerr_slave #
  (
   parameter integer C_AXI_ID_WIDTH           = 1,
   parameter integer C_AXI_DATA_WIDTH         = 32,
   parameter integer C_AXI_BUSER_WIDTH        = 1,
   parameter integer C_AXI_RUSER_WIDTH        = 1,
   parameter integer C_AXI_PROTOCOL           = 0,
   parameter integer C_RESP                   = 2'b11   
   )
  (
   input wire S_AXI_ACLK,
   input wire S_AXI_ARESET,
   input wire [(C_AXI_ID_WIDTH-1):0] S_AXI_AWID,
   input wire S_AXI_AWVALID,
   output wire S_AXI_AWREADY,
   input wire S_AXI_WLAST,
   input wire S_AXI_WVALID,
   output wire S_AXI_WREADY,
   output wire [(C_AXI_ID_WIDTH-1):0] S_AXI_BID,
   output wire [1:0] S_AXI_BRESP,
   output wire [C_AXI_BUSER_WIDTH-1:0]          S_AXI_BUSER,
   output wire S_AXI_BVALID,
   input wire S_AXI_BREADY,
   input wire [(C_AXI_ID_WIDTH-1):0] S_AXI_ARID,
   input wire [7:0] S_AXI_ARLEN,
   input wire S_AXI_ARVALID,
   output wire S_AXI_ARREADY,
   output wire [(C_AXI_ID_WIDTH-1):0] S_AXI_RID,
   output wire [(C_AXI_DATA_WIDTH-1):0] S_AXI_RDATA,
   output wire [1:0] S_AXI_RRESP,
   output wire [C_AXI_RUSER_WIDTH-1:0]          S_AXI_RUSER,
   output wire S_AXI_RLAST,
   output wire S_AXI_RVALID,
   input wire S_AXI_RREADY
   );
  reg s_axi_awready_i;
  reg s_axi_wready_i;
  reg s_axi_bvalid_i;
  reg s_axi_arready_i;
  reg s_axi_rvalid_i;
  localparam P_WRITE_IDLE = 2'b00;
  localparam P_WRITE_DATA = 2'b01;
  localparam P_WRITE_RESP = 2'b10;
  localparam P_READ_IDLE = 1'b0;
  localparam P_READ_DATA = 1'b1;
  localparam integer  P_AXI4 = 0;
  localparam integer  P_AXI3 = 1;
  localparam integer  P_AXILITE = 2;
  assign S_AXI_BRESP = C_RESP;
  assign S_AXI_RRESP = C_RESP;
  assign S_AXI_RDATA = {C_AXI_DATA_WIDTH{1'b0}};
  assign S_AXI_BUSER = {C_AXI_BUSER_WIDTH{1'b0}};
  assign S_AXI_RUSER = {C_AXI_RUSER_WIDTH{1'b0}};
  assign S_AXI_AWREADY = s_axi_awready_i;
  assign S_AXI_WREADY = s_axi_wready_i;
  assign S_AXI_BVALID = s_axi_bvalid_i;
  assign S_AXI_ARREADY = s_axi_arready_i;
  assign S_AXI_RVALID = s_axi_rvalid_i;
  generate
  if (C_AXI_PROTOCOL == P_AXILITE) begin : gen_axilite
    assign S_AXI_RLAST = 1'b1;
    assign S_AXI_BID = 0;
    assign S_AXI_RID = 0;
    always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESET) begin
        s_axi_awready_i <= 1'b0;
        s_axi_wready_i <= 1'b0;
        s_axi_bvalid_i <= 1'b0;
      end else begin
        if (s_axi_bvalid_i) begin
          if (S_AXI_BREADY) begin
            s_axi_bvalid_i <= 1'b0;
          end
        end else if (S_AXI_AWVALID & S_AXI_WVALID) begin
          if (s_axi_awready_i) begin
            s_axi_awready_i <= 1'b0;
            s_axi_wready_i <= 1'b0;
            s_axi_bvalid_i <= 1'b1;
          end else begin
            s_axi_awready_i <= 1'b1;
            s_axi_wready_i <= 1'b1;
          end
        end
      end
    end
    always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESET) begin
        s_axi_arready_i <= 1'b0;
        s_axi_rvalid_i <= 1'b0;
      end else begin
        if (s_axi_rvalid_i) begin
          if (S_AXI_RREADY) begin
            s_axi_rvalid_i <= 1'b0;
          end
        end else if (S_AXI_ARVALID & s_axi_arready_i) begin
          s_axi_arready_i <= 1'b0;
          s_axi_rvalid_i <= 1'b1;
        end else begin
          s_axi_arready_i <= 1'b1;
        end
      end
    end
  end else begin : gen_axi
    reg s_axi_rlast_i;
    reg [(C_AXI_ID_WIDTH-1):0] s_axi_bid_i;
    reg [(C_AXI_ID_WIDTH-1):0] s_axi_rid_i;
    reg [7:0] read_cnt;
    reg [1:0] write_cs;
    reg [0:0] read_cs;
    assign S_AXI_RLAST = s_axi_rlast_i;
    assign S_AXI_BID = s_axi_bid_i;
    assign S_AXI_RID = s_axi_rid_i;
    always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESET) begin
        write_cs <= P_WRITE_IDLE;
        s_axi_awready_i <= 1'b0;
        s_axi_wready_i <= 1'b0;
        s_axi_bvalid_i <= 1'b0;
        s_axi_bid_i <= 0;
      end else begin
        case (write_cs) 
          P_WRITE_IDLE: 
            begin
              if (S_AXI_AWVALID & s_axi_awready_i) begin
                s_axi_awready_i <= 1'b0;
                s_axi_bid_i <= S_AXI_AWID;
                s_axi_wready_i <= 1'b1;
                write_cs <= P_WRITE_DATA;
              end else begin
                s_axi_awready_i <= 1'b1;
              end
            end
          P_WRITE_DATA:
            begin
              if (S_AXI_WVALID & S_AXI_WLAST) begin
                s_axi_wready_i <= 1'b0;
                s_axi_bvalid_i <= 1'b1;
                write_cs <= P_WRITE_RESP;
              end
            end
          P_WRITE_RESP:
            begin
              if (S_AXI_BREADY) begin
                s_axi_bvalid_i <= 1'b0;
                s_axi_awready_i <= 1'b1;
                write_cs <= P_WRITE_IDLE;
              end
            end
        endcase
      end
    end
    always @(posedge S_AXI_ACLK) begin
      if (S_AXI_ARESET) begin
        read_cs <= P_READ_IDLE;
        s_axi_arready_i <= 1'b0;
        s_axi_rvalid_i <= 1'b0;
        s_axi_rlast_i <= 1'b0;
        s_axi_rid_i <= 0;
        read_cnt <= 0;
      end else begin
        case (read_cs) 
          P_READ_IDLE: 
            begin
              if (S_AXI_ARVALID & s_axi_arready_i) begin
                s_axi_arready_i <= 1'b0;
                s_axi_rid_i <= S_AXI_ARID;
                read_cnt <= S_AXI_ARLEN;
                s_axi_rvalid_i <= 1'b1;
                if (S_AXI_ARLEN == 0) begin
                  s_axi_rlast_i <= 1'b1;
                end else begin
                  s_axi_rlast_i <= 1'b0;
                end
                read_cs <= P_READ_DATA;
              end else begin
                s_axi_arready_i <= 1'b1;
              end
            end
          P_READ_DATA:
            begin
              if (S_AXI_RREADY) begin
                if (read_cnt == 0) begin
                  s_axi_rvalid_i <= 1'b0;
                  s_axi_rlast_i <= 1'b0;
                  s_axi_arready_i <= 1'b1;
                  read_cs <= P_READ_IDLE;
                end else begin
                  if (read_cnt == 1) begin
                    s_axi_rlast_i <= 1'b1;
                  end
                  read_cnt <= read_cnt - 1;
                end
              end
            end
        endcase
      end
    end
  end  
  endgenerate
endmodule
`default_nettype wire
