module v7_corrected_clk	#(parameter tx_dst_addr = 48'h001F293A10FD,tx_src_addr = 48'hAABBCCDDEEFF,tx_max_data_size = 16'd1024,rx_dst_addr=48'hAABBCCDDEEFF)
(
      input         glbl_rst,
      input         clkin200, // Primary input clock
      output        phy_resetn,
      input            gtrefclk_p,
      input            gtrefclk_n,
      output           txp,
      output           txn,
      input            rxp,
      input            rxn,
      output           synchronization_done,
      output           linkup,
      input         mdio_i,
	  output        mdio_o,
	  output        mdio_t,
      output        mdc,
      input         enet_loopback,
      input         enet_wr_clk, // Primary input clock
      input         enet_wr_data_valid,
      input [63:0]  enet_wr_data,
      output        enet_wr_rdy,
      input         enet_rd_clk, // Primary input clock
      input         enet_rd_rdy,
      output [63:0] enet_rd_data,
      output reg    enet_rd_data_valid,
      input         if_enable,
	  output        o_tx_mac_count
);
wire       w_core_ip_clk; // Internally generated clock (output from ec)
wire       w_core_ip_rst_n; // Internally generated reset (output from ec)
wire [7:0] w_core_ip_data;
wire       w_core_ip_data_valid;
wire       w_core_ip_data_last;
wire       w_ip_core_data_ready;
wire [7:0] w_ip_core_data;
reg        ip_core_data_valid;
wire       w_core_ip_data_ready;
wire       w_ip_core_data_last;
wire [13:0] eth_tx_fifo_data_cnt;
wire [10:0] eth_tx_fifo_wr_data_cnt;
wire [7:0]  eth_rx_fifo_rd_data_cnt;
reg [2:0] rd_state;
reg       enet_rd_en;
reg [3:0] dat_cnt;
reg       tx_fifo_rd;
wire      tx_full;
wire      tx_fifo_empty;

tx_fifo eth_tx_fifo
(
  .rst(glbl_rst),
  .wr_clk(enet_wr_clk), // Primary input clock
  .rd_clk(clkin200), // DFT Fix: Use primary input clock instead of w_core_ip_clk
  .din(enet_wr_data),
  .wr_en(enet_wr_data_valid & enet_wr_rdy & if_enable),
  .rd_en(tx_fifo_rd || w_core_ip_data_ready),
  .dout(w_ip_core_data),
  .full(tx_full),
  .empty(tx_fifo_empty),
  .rd_data_count(eth_tx_fifo_data_cnt),
  .wr_data_count(eth_tx_fifo_wr_data_cnt)
);
assign enet_wr_rdy = ((eth_tx_fifo_wr_data_cnt > 2045) || (tx_full)) ? 1'b0 : 1'b1;
reg tx_fif_rd_state;

// DFT Fix: Change clock from internally generated w_core_ip_clk to primary clkin200
// DFT Fix: Change reset from internally generated w_core_ip_rst_n to primary glbl_rst (adjust polarity if needed)
always @(posedge clkin200 or posedge glbl_rst) // Use primary clock and async primary reset
begin
	if (glbl_rst) begin // Use primary reset (active high)
		tx_fifo_rd <= 1'b0;
		ip_core_data_valid <= 1'b0;
		tx_fif_rd_state <= 'd0;
	end
	else begin
		tx_fifo_rd <= 1'b0;
        ip_core_data_valid <= 1'b0;
		case (tx_fif_rd_state)
			1'b0 : begin
				if (|eth_tx_fifo_data_cnt) begin
						tx_fif_rd_state <= 1'b1;
                        ip_core_data_valid <= 1'b1;
				end
			end
			1'b1 : begin
				if (w_core_ip_data_ready && (eth_tx_fifo_data_cnt>14'd2)) begin
                    tx_fif_rd_state <= 1'b1;
                    ip_core_data_valid <= 1'b1;
                end
				else begin
                    ip_core_data_valid <= 1'b1;
                    if (tx_fifo_empty) begin
                        tx_fifo_rd <= 1'b0;
                        tx_fif_rd_state <= 1'b0;
                    end
                end
			end
		endcase
	end
end

v7_ethernet_controller
	#(.tx_dst_addr(tx_dst_addr),
	.tx_src_addr(tx_src_addr),
	.tx_max_data_size(tx_max_data_size),
	.rx_dst_addr(rx_dst_addr))
ec
   (
    .glbl_rst(glbl_rst),
    .clkin200(clkin200),
    .phy_resetn(phy_resetn),
    .gtrefclk_p(gtrefclk_p),
    .gtrefclk_n(gtrefclk_n),
    .txp(txp),
    .txn(txn),
    .rxp(rxp),
    .rxn(rxn),
    .synchronization_done(synchronization_done),
    .linkup(linkup),
    .mdio_i(mdio_i),
    .mdio_t(mdio_t),
    .mdio_o(mdio_o),
    .mdc(mdc),
	.o_axi_rx_clk(w_core_ip_clk), // This clock is generated internally by 'ec'
    .o_axi_rx_rst_n(w_core_ip_rst_n), // This reset is generated internally by 'ec'
    .o_axi_rx_tdata(w_core_ip_data),
    .o_axi_rx_data_tvalid(w_core_ip_data_valid),
    .o_axi_rx_data_tlast(w_core_ip_data_last),
    .loop_back_en(enet_loopback),
	.i_axi_rx_data_tready(1'b1),
	.o_axi_tx_clk(),
    .o_axi_tx_rst_n(),
    .i_axi_tx_tdata(w_ip_core_data),
    .i_axi_tx_data_tvalid(ip_core_data_valid),
    .o_axi_tx_data_tready(w_core_ip_data_ready),
    .i_axi_tx_data_tlast(1'b0),
	 .o_tx_mac_count(o_tx_mac_count)
);
wire rx_fifo_rd_en = (enet_rd_en || ((rd_state == 1'b1) && (enet_rd_en || enet_rd_rdy)));

rx_fifo eth_rx_fifo
(
  .rst(glbl_rst),
  .wr_clk(clkin200), // DFT Fix: Use primary input clock instead of w_core_ip_clk
  .rd_clk(enet_rd_clk), // Primary input clock
  .din(w_core_ip_data), // Data synchronous to w_core_ip_clk (potential CDC issue, but fixes CLKNPI)
  .wr_en(w_core_ip_data_valid && if_enable),
  .rd_en(rx_fifo_rd_en),
  .dout(enet_rd_data),
  .full(),
  .empty(),
  .rd_data_count(eth_rx_fifo_rd_data_cnt)
);

always @ (posedge enet_rd_clk or posedge glbl_rst) // Use primary clock and async primary reset
begin
    if (glbl_rst) begin // Use primary reset (active high)
        enet_rd_data_valid <= 1'b0;
        rd_state <= 2'd0;
        enet_rd_en <= 1'b0;
        dat_cnt <= 'd0;
    end
    else begin
        enet_rd_en <= 1'b0;
        enet_rd_data_valid <= 1'b0; // Default assignment
        case (rd_state)
            2'd0 : begin
                if (eth_rx_fifo_rd_data_cnt >= 8) begin
                    enet_rd_en <= 1'b1;
                    rd_state   <= 2'd1;
                    if (enet_rd_rdy)
                        dat_cnt <= 4'd0; // Reset count if ready on first cycle
                    else
                        dat_cnt    <= 4'd1; // Start count from 1 if not ready
                end
            end
            2'd1 : begin
                 enet_rd_data_valid <= 1'b1; // Data is valid during this state
                 if (enet_rd_rdy) begin
                     enet_rd_en <= 1'b1; // Keep reading if downstream is ready
                     dat_cnt    <= dat_cnt + 1'b1;
                 end
                 else begin
                     enet_rd_en <= 1'b0; // Stop reading if downstream is not ready
                 end

                 // Check if 8 beats have been transferred *including the current one if enet_rd_rdy is high*
                 if (dat_cnt == 4'd8) begin // Transition after 8 beats are acknowledged
                     enet_rd_data_valid <= 1'b0; // Deassert valid on the cycle exiting state 1
                     enet_rd_en <= 1'b0;
                     rd_state <= 2'd2;
                 end
            end
            2'd2 : begin
                // Wait state, potentially for last data to clear?
                rd_state <= 2'd0; // Go back to idle
            end
            default: rd_state <= 2'd0;
        endcase
    end
end
endmodule