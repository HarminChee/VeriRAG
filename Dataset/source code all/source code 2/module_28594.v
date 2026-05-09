module rgmii_io
(
     output wire [3:0] rgmii_txd,
     output wire rgmii_tx_ctl,
     output wire rgmii_txc,
     input  wire [3:0] rgmii_rxd,
     input  wire rgmii_rx_ctl,
     input wire [7:0] gmii_txd_int,      
     input wire       gmii_tx_en_int,
     input wire       gmii_tx_er_int,
     output wire      gmii_col_int,
     output wire      gmii_crs_int,
     output reg [7:0] gmii_rxd_reg,   
     output reg       gmii_rx_dv_reg, 
     output reg       gmii_rx_er_reg, 
     output reg       eth_link_status,
     output reg [1:0] eth_clock_speed,
     output reg       eth_duplex_status,
     input wire tx_rgmii_clk_int,     
     input wire tx_rgmii_clk90_int,   
     input wire rx_rgmii_clk_int,     
     input wire reset
     );
   reg [7:0] gmii_txd_rising;     
   reg 	     gmii_tx_en_rising;   
   reg 	     rgmii_tx_ctl_rising; 
   reg [3:0] gmii_txd_falling;    
   reg 	     rgmii_tx_ctl_falling;
   wire [3:0] rgmii_txd_obuf;     
   wire [3:0] rgmii_rxd_ibuf;     
   wire rgmii_rx_ctl_ibuf;
   reg [7:0]  rgmii_rxd_ddr;
   reg 	      rgmii_rx_dv_ddr;    
   reg 	      rgmii_rx_ctl_ddr;   
   reg [7:0]  rgmii_rxd_reg;      
   reg 	      rgmii_rx_dv_reg;    
   reg 	      rgmii_rx_ctl_reg;   
   wire rgmii_txc_obuf;
   ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"),
      .INIT(1'b0),
      .SRTYPE("SYNC")
   ) ODDR_inst (
      .Q(rgmii_txc_obuf), 
      .C(tx_rgmii_clk90_int),  
      .CE(1'b1), 
      .D1(1'b1), 
      .D2(1'b0),
      .R(1'b0),
      .S(1'b0) 
   );
   OBUF drive_rgmii_txc     (.I(rgmii_txc_obuf),     .O(rgmii_txc));
   wire rgmii_tx_ctl_int;
   assign      rgmii_tx_ctl_int = gmii_tx_en_int ^ gmii_tx_er_int;
   always @ (posedge tx_rgmii_clk_int or posedge reset)
     begin
	if (reset)
          begin
             gmii_txd_rising     <= 8'b0;
             gmii_tx_en_rising   <= 1'b0;
             rgmii_tx_ctl_rising <= 1'b0;
          end
	else
          begin
             gmii_txd_rising     <= gmii_txd_int;
             gmii_tx_en_rising   <= gmii_tx_en_int;
             rgmii_tx_ctl_rising <= rgmii_tx_ctl_int;
          end
     end
   wire not_tx_rgmii_clk_int;
   assign not_tx_rgmii_clk_int = ~(tx_rgmii_clk_int);
   always @ (posedge not_tx_rgmii_clk_int or posedge reset)
     begin
	if (reset)
          begin
             gmii_txd_falling     <= 4'b0;
             rgmii_tx_ctl_falling <= 1'b0;
          end
	else
          begin
	     gmii_txd_falling     <= gmii_txd_rising[7:4];
	     rgmii_tx_ctl_falling <= rgmii_tx_ctl_rising;
          end
     end
   ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"),
      .INIT(1'b0),
      .SRTYPE("SYNC")
   ) ODDR_rgmii_txd_out3 (
      .Q(rgmii_txd_obuf[3]), 
      .C(tx_rgmii_clk_int),  
      .CE(1'b1), 
      .D1(gmii_txd_rising[3]), 
      .D2(gmii_txd_falling[3]),
      .R(reset),
      .S(1'b0) 
   );
   ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"),
      .INIT(1'b0),
      .SRTYPE("SYNC")
   ) ODDR_rgmii_txd_out2 (
      .Q(rgmii_txd_obuf[2]), 
      .C(tx_rgmii_clk_int),  
      .CE(1'b1), 
      .D1(gmii_txd_rising[2]), 
      .D2(gmii_txd_falling[2]),
      .R(reset),
      .S(1'b0) 
   );
    ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"),
      .INIT(1'b0),
      .SRTYPE("SYNC")
   ) ODDR_rgmii_txd_out1 (
      .Q(rgmii_txd_obuf[1]), 
      .C(tx_rgmii_clk_int),  
      .CE(1'b1), 
      .D1(gmii_txd_rising[1]), 
      .D2(gmii_txd_falling[1]),
      .R(reset),
      .S(1'b0) 
   );
   ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"),
      .INIT(1'b0),
      .SRTYPE("SYNC")
   ) ODDR_rgmii_txd_out0 (
      .Q(rgmii_txd_obuf[0]), 
      .C(tx_rgmii_clk_int),  
      .CE(1'b1), 
      .D1(gmii_txd_rising[0]), 
      .D2(gmii_txd_falling[0]),
      .R(reset),
      .S(1'b0) 
   );
   wire rgmii_tx_ctl_obuf;
     ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"),
      .INIT(1'b0),
      .SRTYPE("SYNC")
      ) ODDR_rgmii_txd_ctl
     (
      .Q(rgmii_tx_ctl_obuf), 
      .C(tx_rgmii_clk_int),  
      .CE(1'b1), 
      .D1(gmii_tx_en_rising), 
      .D2(rgmii_tx_ctl_falling),
      .R(reset),
      .S(1'b0) 
     );
   OBUF drive_rgmii_tx_ctl  (.I(rgmii_tx_ctl_obuf),     .O(rgmii_tx_ctl));
   OBUF drive_rgmii_txd3    (.I(rgmii_txd_obuf[3]),     .O(rgmii_txd[3]));
   OBUF drive_rgmii_txd2    (.I(rgmii_txd_obuf[2]),     .O(rgmii_txd[2]));
   OBUF drive_rgmii_txd1    (.I(rgmii_txd_obuf[1]),     .O(rgmii_txd[1]));
   OBUF drive_rgmii_txd0    (.I(rgmii_txd_obuf[0]),     .O(rgmii_txd[0]));
   IBUF drive_rgmii_rx_ctl (.I(rgmii_rx_ctl), .O(rgmii_rx_ctl_ibuf));
   IBUF drive_rgmii_rxd3   (.I(rgmii_rxd[3]), .O(rgmii_rxd_ibuf[3]));
   IBUF drive_rgmii_rxd2   (.I(rgmii_rxd[2]), .O(rgmii_rxd_ibuf[2]));
   IBUF drive_rgmii_rxd1   (.I(rgmii_rxd[1]), .O(rgmii_rxd_ibuf[1]));
   IBUF drive_rgmii_rxd0   (.I(rgmii_rxd[0]), .O(rgmii_rxd_ibuf[0]));
   always @ (posedge rx_rgmii_clk_int or posedge reset)
   begin
      if (reset)
         begin
            rgmii_rxd_ddr[3:0]   <= 4'b0;
            rgmii_rx_dv_ddr      <= 1'b0;
         end
      else
         begin
            rgmii_rxd_ddr[3:0]   <= rgmii_rxd_ibuf;
            rgmii_rx_dv_ddr      <= rgmii_rx_ctl_ibuf;
         end
   end
   wire not_rx_rgmii_clk_int;
   assign not_rx_rgmii_clk_int = ~(rx_rgmii_clk_int);
   always @ (posedge not_rx_rgmii_clk_int or posedge reset)
   begin
      if (reset)
         begin
            rgmii_rxd_ddr[7:4]    <= 4'b0;
            rgmii_rx_ctl_ddr      <= 1'b0;
         end
      else
         begin
            rgmii_rxd_ddr[7:4]    <= rgmii_rxd_ibuf;
            rgmii_rx_ctl_ddr      <= rgmii_rx_ctl_ibuf;
         end
   end
   always @ (posedge rx_rgmii_clk_int or posedge reset)
   begin
      if (reset)
         begin
            rgmii_rxd_reg[3:0] <= 4'b0;
            rgmii_rx_dv_reg    <= 1'b0;
         end
      else
         begin
            rgmii_rxd_reg[3:0] <= rgmii_rxd_ddr[3:0];
            rgmii_rx_dv_reg    <= rgmii_rx_dv_ddr;
         end
   end 
   always @ (posedge not_rx_rgmii_clk_int or posedge reset)
   begin
      if (reset)
         begin
            rgmii_rxd_reg[7:4] <= 4'b0;
            rgmii_rx_ctl_reg   <= 1'b0;
         end
      else
         begin
            rgmii_rxd_reg[7:4] <= rgmii_rxd_ddr[7:4];
            rgmii_rx_ctl_reg   <= rgmii_rx_ctl_ddr;
         end
   end
   always @ (posedge rx_rgmii_clk_int or posedge reset)
   begin
       if (reset)
          begin
             gmii_rxd_reg[7:0] <= 8'b0;
             gmii_rx_dv_reg    <= 1'b0;
             gmii_rx_er_reg    <= 1'b0;
          end
       else
          begin
             gmii_rxd_reg[7:0] <= rgmii_rxd_reg[7:0];
             gmii_rx_dv_reg    <= rgmii_rx_dv_reg;
             gmii_rx_er_reg    <= rgmii_rx_ctl_reg ^ rgmii_rx_dv_reg;
          end
   end
   wire inband_ce;
   assign inband_ce = !(gmii_rx_dv_reg || gmii_rx_er_reg);
   always @ (posedge rx_rgmii_clk_int or posedge reset)
   begin
      if (reset)
          begin
            eth_link_status         <= 1'b0;
            eth_clock_speed[1:0]    <= 2'b0;
            eth_duplex_status       <= 1'b0;
      end
      else
        if (inband_ce)
            begin
            eth_link_status      <= gmii_rxd_reg[0];
            eth_clock_speed[1:0] <= gmii_rxd_reg[2:1];
            eth_duplex_status    <= gmii_rxd_reg[3];
        end
   end
   assign gmii_col_int = (gmii_tx_en_int | gmii_tx_er_int) & (gmii_rx_dv_reg | gmii_rx_er_reg);
   assign gmii_crs_int = (gmii_tx_en_int | gmii_tx_er_int) | (gmii_rx_dv_reg | gmii_rx_er_reg);
endmodule 
