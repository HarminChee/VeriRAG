module emaxi (
   input wire test_i,
   input wire wr_access,
   input wire [PW-1:0] wr_packet,
   output wire wr_wait,
   input wire rd_access,
   input wire [PW-1:0] rd_packet,
   output wire rd_wait,
   output wire rr_access,
   output wire [PW-1:0] rr_packet,
   input wire rr_wait,
   input wire m_axi_aclk,
   input wire m_axi_aresetn,
   output wire [M_IDW-1:0] m_axi_awid,
   output wire [31:0] m_axi_awaddr,
   output wire [7:0] m_axi_awlen,
   output wire [2:0] m_axi_awsize,
   output wire [1:0] m_axi_awburst,
   output wire m_axi_awlock,
   output wire [3:0] m_axi_awcache,
   output wire [2:0] m_axi_awprot,
   output wire [3:0] m_axi_awqos,
   output wire m_axi_awvalid,
   input wire m_axi_awready,
   output wire [M_IDW-1:0] m_axi_wid,
   output wire [63:0] m_axi_wdata,
   output wire [7:0] m_axi_wstrb,
   output wire m_axi_wlast,
   output wire m_axi_wvalid,
   input wire m_axi_wready,
   input wire [M_IDW-1:0] m_axi_bid,
   input wire [1:0] m_axi_bresp,
   input wire m_axi_bvalid,
   output wire m_axi_bready,
   output wire [M_IDW-1:0] m_axi_arid,
   output wire [31:0] m_axi_araddr,
   output wire [7:0] m_axi_arlen,
   output wire [2:0] m_axi_arsize,
   output wire [1:0] m_axi_arburst,
   output wire m_axi_arlock,
   output wire [3:0] m_axi_arcache,
   output wire [2:0] m_axi_arprot,
   output wire [3:0] m_axi_arqos,
   output wire m_axi_arvalid,
   input wire m_axi_arready,
   input wire [M_IDW-1:0] m_axi_rid,
   input wire [63:0] m_axi_rdata,
   input wire [1:0] m_axi_rresp,
   input wire m_axi_rlast,
   input wire m_axi_rvalid,
   output wire m_axi_rready
);
   parameter M_IDW = 12;
   parameter PW = 104;
   parameter AW = 32;
   parameter DW = 32;

   reg [31:0] m_axi_awaddr_reg;
   reg [7:0] m_axi_awlen_reg;
   reg [2:0] m_axi_awsize_reg;
   reg m_axi_awvalid_reg;
   reg [63:0] m_axi_wdata_reg;
   reg [7:0] m_axi_wstrb_reg;
   reg m_axi_wlast_reg;
   reg m_axi_wvalid_reg;
   reg awvalid_b;
   reg [31:0] awaddr_b;
   reg [2:0] awsize_b;
   reg [7:0] awlen_b;
   reg wvalid_b;
   reg [63:0] wdata_b;
   reg [7:0] wstrb_b;
   reg [63:0] wdata_aligned;
   reg [7:0] wstrb_aligned;
   reg rr_access_reg;
   reg [31:0] rr_data;
   reg [31:0] rr_srcaddr;
   reg [3:0] rr_datamode;
   reg [3:0] rr_ctrlmode;
   reg [31:0] rr_dstaddr;
   reg [63:0] m_axi_rdata_fifo;
   reg rr_access_fifo;

   wire aw_go;
   wire w_go;
   wire readinfo_wren;
   wire readinfo_full;
   wire [40:0] readinfo_out;
   wire [40:0] readinfo_in;
   wire awvalid_in;
   wire [1:0] wr_datamode;
   wire [AW-1:0] wr_dstaddr;
   wire [DW-1:0] wr_data;
   wire [AW-1:0] wr_srcaddr;
   wire [1:0] rd_datamode;
   wire [4:0] rd_ctrlmode;
   wire [AW-1:0] rd_dstaddr;
   wire [AW-1:0] rd_srcaddr;
   wire [1:0] rr_datamode_fifo;
   wire [3:0] rr_ctrlmode_fifo;
   wire [31:0] rr_dstaddr_fifo;
   wire [2:0] rr_alignaddr_fifo;
   wire [103:0] packet_out;
   wire fifo_prog_full;
   wire fifo_full;
   wire fifo_rd_en;
   wire fifo_wr_en;
   wire sync_nreset;
   wire dft_resetn;
   wire dft_clk;

   assign dft_resetn = test_i ? m_axi_aresetn : sync_nreset;
   assign dft_clk = test_i ? m_axi_aclk : m_axi_aclk;

   packet2emesh p2e_rxwr (
      .write_in(),
      .datamode_in(wr_datamode[1:0]),
      .ctrlmode_in(),
      .dstaddr_in(wr_dstaddr[AW-1:0]),
      .data_in(wr_data[DW-1:0]),
      .srcaddr_in(wr_srcaddr[AW-1:0]),
      .packet_in(wr_packet[PW-1:0])
   );

   packet2emesh p2e_rxrd (
      .write_in(),
      .datamode_in(rd_datamode[1:0]),
      .ctrlmode_in(rd_ctrlmode[4:0]),
      .dstaddr_in(rd_dstaddr[AW-1:0]),
      .data_in(),
      .srcaddr_in(rd_srcaddr[AW-1:0]),
      .packet_in(rd_packet[PW-1:0])
   );

   emesh2packet e2p (
      .packet_out(rr_packet[PW-1:0]),
      .write_out(1'b1),
      .datamode_out(rr_datamode[1:0]),
      .ctrlmode_out({1'b0, rr_ctrlmode[3:0]}),
      .dstaddr_out(rr_dstaddr[AW-1:0]),
      .data_out(rr_data[DW-1:0]),
      .srcaddr_out(rr_srcaddr[AW-1:0])
   );

   assign m_axi_awid[M_IDW-1:0] = {(M_IDW){1'b0}};
   assign m_axi_awburst[1:0] = 2'b01;
   assign m_axi_awcache[3:0] = 4'b0000;
   assign m_axi_awprot[2:0] = 3'b000;
   assign m_axi_awqos[3:0] = 4'b0000;
   assign m_axi_awlock = 1'b0;
   assign m_axi_arid[M_IDW-1:0] = {(M_IDW){1'b0}};
   assign m_axi_arburst[1:0] = 2'b01;
   assign m_axi_arcache[3:0] = 4'b0000;
   assign m_axi_arprot[2:0] = 3'h0;
   assign m_axi_arqos[3:0] = 4'h0;
   assign m_axi_arlock = 1'b0;
   assign m_axi_bready = 1'b1;
   assign m_axi_wid[M_IDW-1:0] = {(M_IDW){1'b0}};

   assign aw_go = m_axi_awvalid_reg & m_axi_awready;
   assign w_go = m_axi_wvalid_reg & m_axi_wready;
   assign wr_wait = awvalid_b | wvalid_b;
   assign awvalid_in = wr_access & ~awvalid_b & ~wvalid_b;

   always @(posedge dft_clk or negedge dft_resetn)
     if (!dft_resetn)
       begin
          m_axi_awvalid_reg <= 1'b0;
          m_axi_awaddr_reg <= 32'd0;
          m_axi_awlen_reg <= 8'd0;
          m_axi_awsize_reg <= 3'd0;
          awvalid_b <= 1'b0;
          awaddr_b <= 32'd0;
          awlen_b <= 8'd0;
          awsize_b <= 3'd0;
       end
     else
       begin
          if (~m_axi_awvalid_reg | aw_go)
            begin
               if (awvalid_b)
                 begin
                    m_axi_awvalid_reg <= 1'b1;
                    m_axi_awaddr <= awaddr_b;
                    m_axi_awlen <= awlen_b;
                    m_axi_awsize <= awsize_b;
                 end
               else
                 begin
                    m_axi_awvalid_reg <= awvalid_in;
                    m_axi_awaddr <= wr_dstaddr;
                    m_axi_awlen <= 8'b0;
                    m_axi_awsize <= {1'b0, wr_datamode[1:0]};
                 end
            end
          if (awvalid_in & m_axi_awvalid_reg & ~aw_go)
            awvalid_b <= 1'b1;
          else if (aw_go)
            awvalid_b <= 1'b0;
          if (awvalid_in)
            begin
               awaddr_b <= wr_dstaddr;
               awlen_b <= 8'b0;
               awsize_b <= {1'b0, wr_datamode[1:0]};
            end
       end

   always @*
     case (wr_datamode[1:0])
       2'b00: wdata_aligned = {8{wr_data[7:0]}};
       2'b01: wdata_aligned = {4{wr_data[15:0]}};
       2'b10: wdata_aligned = {2{wr_data[31:0]}};
       default: wdata_aligned = {wr_srcaddr[31:0], wr_data[31:0]};
     endcase

   always @*
     begin
        case (wr_datamode[1:0])
          2'd0:
            case (wr_dstaddr[2:0])
              3'd0: wstrb_aligned = 8'h01;
              3'd1: wstrb_aligned = 8'h02;
              3'd2: wstrb_aligned = 8'h04;
              3'd3: wstrb_aligned = 8'h08;
              3'd4: wstrb_aligned = 8'h10;
              3'd5: wstrb_aligned = 8'h20;
              3'd6: wstrb_aligned = 8'h40;
              default: wstrb_aligned = 8'h80;
            endcase
          2'd1:
            case (wr_dstaddr[2:1])
              2'd0: wstrb_aligned = 8'h03;
              2'd1: wstrb_aligned = 8'h0c;
              2'd2: wstrb_aligned = 8'h30;
              default: wstrb_aligned = 8'hc0;
            endcase
          2'd2:
            if (wr_dstaddr[2])
              wstrb_aligned = 8'hf0;
            else
              wstrb_aligned = 8'h0f;
          2'd3:
            wstrb_aligned = 8'hff;
        endcase
     end

   always @(posedge dft_clk or negedge dft_resetn)
     if (!dft_resetn)
       begin
          m_axi_wvalid_reg <= 1'b0;
          m_axi_wdata_reg <= 64'b0;
          m_axi_wstrb_reg <= 8'b0;
          m_axi_wlast_reg <= 1'b1;
          wvalid_b <= 1'b0;
          wdata_b <= 64'b0;
          wstrb_b <= 8'b0;
       end
     else
       begin
          if (~m_axi_wvalid_reg | w_go)
            begin
               if (wvalid_b)
                 begin
                    m_axi_wvalid_reg <= 1'b1;
                    m_axi_wdata <= wdata_b;
                    m_axi_wstrb <= wstrb_b;
                    m_axi_wlast <= m_axi_wlast_reg;
                 end
               else
                 begin
                    m_axi_wvalid_reg <= awvalid_in;
                    m_axi_wdata <= wdata_aligned;
                    m_axi_wstrb <= wstrb_aligned;
                    m_axi_wlast <= 1'b1;
                 end
            end
          if (wr_access & m_axi_wvalid_reg & ~w_go)
            wvalid_b <= 1'b1;
          else if (w_go)
            wvalid_b <= 1'b0;
          if (awvalid_in)
            begin
               wdata_b <= wdata_aligned;
               wstrb_b <= wstrb_aligned;
               m_axi_wlast_reg <= 1'b1;
            end
       end

   assign readinfo_in[40:0] = {rd_srcaddr[31:0], rd_dstaddr[2:0], rd_ctrlmode[3:0], rd_datamode[1:0]};

   oh_dsync dsync (
      .dout(sync_nreset),
      .clk(m_axi_aclk),
      .nreset(1'b1),
      .din(m_axi_aresetn)
   );

   oh_fifo_sync #(.DW(104), .DEPTH(32))
   fifo_async (
      .full(fifo_full),
      .prog_full(fifo_prog_full),
      .dout(packet_out[103:0]),
      .empty(),
      .nreset(dft_resetn),
      .clk(dft_clk),
      .wr_en(fifo_wr_en),
      .din({63'b0, readinfo_in[40:0]}),
      .rd_en(fifo_rd_en)
   );

   assign rr_datamode_fifo[1:0] = packet_out[1:0];
   assign rr_ctrlmode_fifo[3:0] = packet_out[5:2];
   assign rr_alignaddr_fifo[2:0] = packet_out[8:6];
   assign rr_dstaddr_fifo[31:0] = packet_out[40:9];
   assign m_axi_araddr = rd_dstaddr;
   assign m_axi_arsize = {1'b0, rd_datamode[1:0]};
   assign m_axi_arlen = 8'd0;
   assign m_axi_arvalid = rd_access & ~fifo_prog_full;
   assign fifo_wr_en = m_axi_arvalid & m_axi_arready;
   assign rd_wait = ~m_axi_arready | fifo_prog_full;
   assign fifo_rd_en = m_axi_rvalid & m_axi_rready;
   assign m_axi_rready = ~rr_wait;

   always @(posedge dft_clk or negedge dft_resetn)
     if (!dft_resetn)
       begin
          rr_access_fifo <= 1'b0;
          rr_access_reg <= 1'b0;
       end
     else
       begin
          rr_access_fifo <= fifo_rd_en;
          rr_access <= rr_access_fifo;
       end

   always @(posedge dft_clk or negedge dft_resetn)
     if (!dft_resetn)
       begin
          m_axi_rdata_fifo <= 64'b0;
          rr_datamode <= 2'b0;
          rr_ctrlmode <= 4'b0;
          rr_dstaddr <= 32'b0;
          rr_data <= 32'b0;
          rr_srcaddr <= 32'b0;
       end
     else
       begin
          m_axi_rdata_fifo <= m_axi_rdata;
          rr_datamode <= rr_datamode_fifo;
          rr_ctrlmode <= rr_ctrlmode_fifo;
          rr_dstaddr <= rr_dstaddr_fifo;
          case (rr_datamode_fifo[1:0])
            2'd0:
              case (rr_alignaddr_fifo[2:0])
                3'd0: rr_data <= {24'b0, m_axi_rdata_fifo[7:0]};
                3'd1: rr_data <= {24'b0, m_axi_rdata_fifo[15:8]};
                3'd2: rr_data <= {24'b0, m_axi_rdata_fifo[23:16]};
                3'd3: rr_data <= {24'b0, m_axi_rdata_fifo[31:24]};
                3'd4: rr_data <= {24'b0, m_axi_rdata_fifo[39:32]};
                3'd5: rr_data <= {24'b0, m_axi_rdata_fifo[47:40]};
                3'd6: rr_data <= {24'b0, m_axi_rdata_fifo[55:48]};
                3'd7: rr_data <= {24'b0, m_axi_rdata_fifo[63:56]};
                default: rr_data <= {24'b0, m_axi_rdata_fifo[7:0]};
              endcase
            2'd1:
              case (rr_alignaddr_fifo[2:1])
                2'd0: rr_data <= {16'b0, m_axi_rdata_fifo[15:0]};
                2'd1: rr_data <= {16'b0, m_axi_rdata_fifo[31:16]};
                2'd2: rr_data <= {16'b0, m_axi_rdata_fifo[47:32]};
                2'd3: rr_data <= {16'b0, m_axi_rdata_fifo[63:48]};
                default: rr_data <= {16'b0, m_axi_rdata_fifo[15:0]};
              endcase
            2'd2:
              begin
                 if (rr_alignaddr_fifo[2])
                   rr_data <= m_axi_rdata_fifo[63:32];
                 else
                   rr_data <= m_axi_rdata_fifo[31:0];
              end
            2'd3:
              begin
                 rr_data <= m_axi_rdata_fifo[31:0];
                 rr_srcaddr <= m_axi_rdata_fifo[63:32];
              end
          endcase
       end

   assign m_axi_awaddr = m_axi_awaddr_reg;
   assign m_axi_awlen = m_axi_awlen_reg;
   assign m_axi_awsize = m_axi_awsize_reg;
   assign m_axi_awvalid = m_axi_awvalid_reg;
   assign m_axi_wdata = m_axi_wdata_reg;
   assign m_axi_wstrb = m_axi_wstrb_reg;
   assign m_axi_wlast = m_axi_wlast_reg;
   assign m_axi_wvalid = m_axi_wvalid_reg;
   assign rr_access = rr_access_reg;

endmodule