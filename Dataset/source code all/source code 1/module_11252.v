module e_tx_io (
   tx_lclk_p, tx_lclk_n, tx_frame_p, tx_frame_n, tx_data_p, tx_data_n,
   tx_wr_wait, tx_rd_wait,
   reset, ioreset, tx_wr_wait_p, tx_wr_wait_n, tx_rd_wait_p,
   tx_rd_wait_n, txlclk_p, txlclk_s, txlclk_out, txframe_p, txdata_p,
   ecfg_tx_enable, ecfg_tx_gpio_mode, ecfg_tx_clkdiv, ecfg_dataout
   );
   parameter IOSTD_ELINK = "LVDS_25";
   output       tx_lclk_p, tx_lclk_n;    
   input        reset;
   input        ioreset;
   output       tx_frame_p, tx_frame_n;  
   output [7:0] tx_data_p, tx_data_n;
   input        tx_wr_wait_p, tx_wr_wait_n;
   input        tx_rd_wait_p, tx_rd_wait_n;
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
      .D1 (txenb),
      .D2 (1'b0),
      .R  (1'b0),
      .S  (1'b0));
   OBUFTDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFTDS_txdata [7:0]
       (
        .O   (tx_data_p),
        .OB  (tx_data_n),
        .I   (tx_data),
        .T   (tx_data_t)
        );
   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFDS_txframe
       (
        .O   (tx_frame_p),
        .OB  (tx_frame_n),
        .I   (tx_frame_n)
        );
   OBUFDS 
     #(
       .IOSTANDARD(IOSTD_ELINK),
       .SLEW("FAST")
       ) OBUFDS_lclk
       (
        .O   (tx_lclk_p),
        .OB  (tx_lclk_n),
        .I   (tx_lclk)
        );
   IBUFDS
	 #(.DIFF_TERM  ("TRUE"),     
       .IOSTANDARD (IOSTD_ELINK))
   ibufds_txwrwait
     (.I     (tx_wr_wait_p),
      .IB    (tx_wr_wait_n),
      .O     (tx_wr_wait));
   assign tx_rd_wait = tx_rd_wait_p;
endmodule 
