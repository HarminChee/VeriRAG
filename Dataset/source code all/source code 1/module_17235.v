module etx_io (
   txo_lclk_p, txo_lclk_n, txo_frame_p, txo_frame_n, txo_data_p,
   txo_data_n, tx_wr_wait, tx_rd_wait,
   reset, txi_wr_wait_p, txi_wr_wait_n, txi_rd_wait_p, txi_rd_wait_n,
   tx_lclk_par, tx_lclk, tx_lclk_out, tx_frame_par, tx_data_par,
   ecfg_tx_enable, ecfg_tx_gpio_enable, ecfg_dataout
   );
   parameter IOSTD_ELINK = "LVDS_25";
   input        reset;              
   output 	 txo_lclk_p, txo_lclk_n;       
   output        txo_frame_p, txo_frame_n;     
   output [7:0]  txo_data_p, txo_data_n;       
   input 	 txi_wr_wait_p,txi_wr_wait_n;  
   input 	 txi_rd_wait_p, txi_rd_wait_n; 
   input        tx_lclk_par;  
   input        tx_lclk;      
   input        tx_lclk_out;  
   input [7:0]  tx_frame_par; 
   input [63:0] tx_data_par;  
   output       tx_wr_wait;
   output       tx_rd_wait;
   input         ecfg_tx_enable;     
   input         ecfg_tx_gpio_enable;
   input [8:0] 	 ecfg_dataout;       
   reg [63:0] 	pdata;
   reg [7:0] 	pframe;
   reg [1:0]    txenb_sync;  
   reg [1:0] 	txgpio_sync;
   wire [7:0]    tx_data;    
   wire [7:0]    tx_data_t;  
   wire          tx_frame;   
   wire          tx_lclk_buf;
   wire 	 txenb;   
   wire 	 txgpio;
   integer 	 n;
   assign         txenb = txenb_sync[0];   
   assign         txgpio = txgpio_sync[0];
   always @ (posedge tx_lclk_par) 
     begin
	txenb_sync[1:0]  <= {ecfg_tx_enable, txenb_sync[1]};
	txgpio_sync[1:0] <= {ecfg_tx_gpio_enable, txgpio_sync[1]};      
	if(txgpio) 
	  begin
             pframe <= {8{ecfg_dataout[8]}};           
             for(n=0; n<8; n=n+1)
               pdata[n*8+7 -: 8] <= ecfg_dataout[7:0];	   
	  end else if(txenb) 
	    begin
               pframe[7:0]  <= tx_frame_par[7:0];
               pdata[63:0]  <= tx_data_par[63:0];         
	    end 
	  else 
	    begin	   
               pframe[7:0] <= 8'd0;
               pdata[63:0] <= 64'd0;	   
	    end
     end
   genvar        i;
   generate for(i=0; i<8; i=i+1)
     begin : gen_serdes
        OSERDESE2 
          #(
            .DATA_RATE_OQ("DDR"),  
            .DATA_RATE_TQ("BUF"),  
            .DATA_WIDTH(8),        
            .INIT_OQ(1'b0),        
            .INIT_TQ(1'b1),        
            .SERDES_MODE("MASTER"), 
            .SRVAL_OQ(1'b0),       
            .SRVAL_TQ(1'b1),       
            .TBYTE_CTL("FALSE"),   
            .TBYTE_SRC("FALSE"),   
            .TRISTATE_WIDTH(1)     
            ) OSERDESE2_txdata 
            (
             .OFB(),   
             .OQ(tx_data[i]),     
             .SHIFTOUT1(),
             .SHIFTOUT2(),
             .TBYTEOUT(),       
             .TFB(),            
             .TQ(tx_data_t[i]), 
             .CLK(tx_lclk),      
             .CLKDIV(tx_lclk_par), 
             .D1(pdata[i+56]),  
             .D2(pdata[i+48]),
             .D3(pdata[i+40]),
             .D4(pdata[i+32]),
             .D5(pdata[i+24]),
             .D6(pdata[i+16]),
             .D7(pdata[i+8]),
             .D8(pdata[i]),   
             .OCE(1'b1),      
             .RST(reset),   
             .SHIFTIN1(1'b0),
             .SHIFTIN2(1'b0),
             .T1(~ecfg_tx_enable), 
             .T2(1'b0),
             .T3(1'b0),
             .T4(1'b0),
             .TBYTEIN(1'b0),   
             .TCE(1'b1)          
             );     
     end 
   endgenerate
   OSERDESE2 
     #(
       .DATA_RATE_OQ("DDR"),  
       .DATA_RATE_TQ("SDR"),  
       .DATA_WIDTH(8),        
       .INIT_OQ(1'b0),        
       .INIT_TQ(1'b0),        
       .SERDES_MODE("MASTER"), 
       .SRVAL_OQ(1'b0),       
       .SRVAL_TQ(1'b0),       
       .TBYTE_CTL("FALSE"),   
       .TBYTE_SRC("FALSE"),   
       .TRISTATE_WIDTH(1)     
       ) OSERDESE2_tframe
       (
        .OFB(),   
        .OQ(tx_frame),     
        .SHIFTOUT1(),
        .SHIFTOUT2(),
        .TBYTEOUT(),       
        .TFB(),            
        .TQ(),             
        .CLK(tx_lclk),      
        .CLKDIV(tx_lclk_par), 
        .D1(pframe[7]),  
        .D2(pframe[6]),
        .D3(pframe[5]),
        .D4(pframe[4]),
        .D5(pframe[3]),
        .D6(pframe[2]),
        .D7(pframe[1]),
        .D8(pframe[0]),  
        .OCE(1'b1),      
        .RST(reset),   
        .SHIFTIN1(1'b0),
        .SHIFTIN2(1'b0),
        .T1(1'b0),
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        .TBYTEIN(1'b0),   
        .TCE(1'b0)          
        );
   ODDR 
     #(
       .DDR_CLK_EDGE  ("SAME_EDGE"), 
	   .INIT          (1'b0),
       .SRTYPE        ("ASYNC"))
   oddr_lclk_inst
     (
      .Q  (tx_lclk_buf),
      .C  (tx_lclk_out),
      .CE (1'b0),
      .D1 (ecfg_tx_enable),
      .D2 (1'b0),
      .R  (reset),
      .S  (1'b0));
   OBUFTDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFTDS_txdata [7:0]
       (
        .O   (txo_data_p),
        .OB  (txo_data_n),
        .I   (tx_data),
        .T   (tx_data_t)            
        );
   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFDS_txframe
       (
        .O   (txo_frame_p),
        .OB  (txo_frame_n),
        .I   (tx_frame)
        );
   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFDS_lclk
       (
        .O   (txo_lclk_p),
        .OB  (txo_lclk_n),
        .I   (tx_lclk_buf)
        );
   IBUFDS
     #(.DIFF_TERM  ("TRUE"),     
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_txwrwait
     (.I     (txi_wr_wait_p),
      .IB    (txi_wr_wait_n),
      .O     (tx_wr_wait));
`ifdef TODO
  IBUFDS
     #(.DIFF_TERM  ("TRUE"),     
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_txwrwait
     (.I     (txi_rd_wait_p),
      .IB    (txi_rd_wait_n),
      .O     (tx_rd_wait));
`else
   assign tx_rd_wait = txi_rd_wait_p;
`endif
endmodule 
