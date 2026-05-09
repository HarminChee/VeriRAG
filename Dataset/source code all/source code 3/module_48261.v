module eio_tx (
   TX_LCLK_P, TX_LCLK_N, TX_FRAME_P, TX_FRAME_N, TX_DATA_P, TX_DATA_N,
   tx_wr_wait, tx_rd_wait,
   reset, ioreset, TX_WR_WAIT_P, TX_WR_WAIT_N, TX_RD_WAIT_P,
   TX_RD_WAIT_N, txlclk_p, txlclk_s, txlclk_out, txframe_p, txdata_p,
   ecfg_tx_enable, ecfg_tx_gpio_mode, ecfg_tx_clkdiv, ecfg_dataout
   );
   parameter IOSTD_ELINK = "LVDS_25";
   output       TX_LCLK_P, TX_LCLK_N; 
   input        reset;
   input        ioreset;
   output       TX_FRAME_P, TX_FRAME_N;  
   output [7:0] TX_DATA_P, TX_DATA_N;
   input        TX_WR_WAIT_P, TX_WR_WAIT_N;
   input        TX_RD_WAIT_P, TX_RD_WAIT_N;
   input        txlclk_p;   
   input        txlclk_s;   
   input        txlclk_out; 
   input [7:0]  txframe_p;
   input [63:0] txdata_p;
   output       tx_wr_wait;
   output       tx_rd_wait;
   input         ecfg_tx_enable;         
   input         ecfg_tx_gpio_mode;      
   input [3:0]   ecfg_tx_clkdiv;         
   input [10:0]  ecfg_dataout;           
   wire [7:0]    tx_data;  
   wire [7:0]    tx_data_t; 
   wire          tx_frame; 
   wire          tx_lclk;
   reg [63:0]   pdata;
   reg [7:0]    pframe;
   reg [1:0]    txenb_sync;
   wire         txenb = txenb_sync[0];
   reg [1:0]    txgpio_sync;
   wire         txgpio = txgpio_sync[0];
   integer      n;
   always @ (posedge txlclk_p) begin
      txenb_sync <= {ecfg_tx_enable, txenb_sync[1]};
      txgpio_sync <= {ecfg_tx_gpio_mode, txgpio_sync[1]};
      if(txgpio) begin
         pframe <= {8{ecfg_dataout[8]}};
         for(n=0; n<8; n=n+1)
           pdata[n*8+7 -: 8] <= ecfg_dataout[7:0];
      end else if(txenb) begin
         pframe <= txframe_p;
         pdata  <= txdata_p;
      end else begin
         pframe <= 8'd0;
         pdata <= 64'd0;
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
             .CLK(txlclk_s),    
             .CLKDIV(txlclk_p), 
             .D1(pdata[i+56]),  
             .D2(pdata[i+48]),
             .D3(pdata[i+40]),
             .D4(pdata[i+32]),
             .D5(pdata[i+24]),
             .D6(pdata[i+16]),
             .D7(pdata[i+8]),
             .D8(pdata[i]),   
             .OCE(1'b1),      
             .RST(ioreset),   
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
        .CLK(txlclk_s),    
        .CLKDIV(txlclk_p), 
        .D1(pframe[7]),  
        .D2(pframe[6]),
        .D3(pframe[5]),
        .D4(pframe[4]),
        .D5(pframe[3]),
        .D6(pframe[2]),
        .D7(pframe[1]),
        .D8(pframe[0]),  
        .OCE(1'b1),      
        .RST(ioreset),   
        .SHIFTIN1(1'b0),
        .SHIFTIN2(1'b0),
        .T1(1'b0),
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        .TBYTEIN(1'b0),   
        .TCE(1'b0)          
        );
   reg [1:0]  txenb_out_sync;
   wire       txenb_out = txenb_out_sync[0];
   always @ (posedge txlclk_out)
     txenb_out_sync <= {ecfg_tx_enable, txenb_out_sync[1]};
   ODDR 
     #(
       .DDR_CLK_EDGE  ("SAME_EDGE"), 
	   .INIT          (1'b0),
       .SRTYPE        ("ASYNC"))
   oddr_lclk_inst
     (
      .Q  (tx_lclk),
      .C  (txlclk_out),
      .CE (1'b1),
      .D1 (txenb_out),
      .D2 (1'b0),
      .R  (1'b0),
      .S  (1'b0));
   OBUFTDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFTDS_txdata [7:0]
       (
        .O   (TX_DATA_P),
        .OB  (TX_DATA_N),
        .I   (tx_data),
        .T   (tx_data_t)
        );
   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFDS_txframe
       (
        .O   (TX_FRAME_P),
        .OB  (TX_FRAME_N),
        .I   (tx_frame)
        );
   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFDS_lclk
       (
        .O   (TX_LCLK_P),
        .OB  (TX_LCLK_N),
        .I   (tx_lclk)
        );
   IBUFDS
	 #(.DIFF_TERM  ("TRUE"),     
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_txwrwait
	 (.I     (TX_WR_WAIT_P),
      .IB    (TX_WR_WAIT_N),
      .O     (tx_wr_wait));
   assign tx_rd_wait = TX_RD_WAIT_P;
endmodule 
