module serial (
    input         wb_clk_i,  
    input         wb_rst_i,  
    input  [15:0] wb_dat_i,  
    output [15:0] wb_dat_o,  
    input         wb_cyc_i,  
    input         wb_stb_i,  
    input  [ 1:0] wb_adr_i,  
    input  [ 1:0] wb_sel_i,  
    input         wb_we_i,   
    output reg    wb_ack_o,  
    output        wb_tgc_o,  
    output rs232_tx,  
    input  rs232_rx   
  );
  reg    [7:0] dat_o;
  wire   [7:0] dat_i;
  wire   [2:0] UART_Addr;
  wire         wb_ack_i;
  wire         wr_command;
  wire         rd_command;
  wire rxd_endofpacket;
  wire EDAI;
  wire ETXH;
  wire EMSI;
  wire [7:0] INTE;
  reg          IPEN;             
  reg      IPEND;        
  reg  [1:0]   INTID;            
  wire [7:0]   ISTAT;
  wire TSRE;
  wire PE;
  wire BI;
  wire FE;
  wire OR;
  reg  rx_rden;                
  reg  DR;                             
  reg  THRE;                           
  wire [7:0] LSTAT;
  wire DTR;
  wire RTS;
  wire OUT1;
  wire OUT2;
  wire LOOP;
  wire [7:0] MCON;
  wire RLSD;
  wire RI;
  wire DSR;
  wire CTS;
  wire DRLSD;
  wire TERI;
  wire DDSR;
  wire DCTS;
  wire [7:0] MSTAT;
  wire [7:0] LCON;
  wire dlab;
  wire [7:0] output_data;        
  reg  [7:0] input_data;         
  reg  [3:0] ier;                
  reg  [7:0] lcr;                
  reg  [7:0] mcr;                
  reg  [7:0] dll;                
  reg  [7:0] dlh;                
  wire    rx_drdy;                
  wire    rx_idle;                
  wire    rx_over;                
  reg     tx_send;                
  wire    to_error;               
  wire    tx_done;
  wire    tx_busy;                
  wire [18:0] Baudiv;
  wire     Baud1Tick;
  wire     Baud8Tick;
  reg  [18:0] BaudAcc1;
  reg  [15:0] BaudAcc8;
  wire [18:0] BaudInc;
  always @(posedge wb_clk_i or posedge wb_rst_i) begin    
    if (wb_rst_i) wb_ack_o <= 1'b0;
    else          wb_ack_o <= wb_ack_i & ~wb_ack_o; 
  end
  `define UART_RG_TR   3'h0    
  `define UART_RG_IE   3'h1    
  `define UART_RG_II   3'h2    
  `define UART_RG_LC   3'h3    
  `define UART_RG_MC   3'h4    
  `define UART_RG_LS   3'h5    
  `define UART_RG_MS   3'h6    
  `define UART_RG_SR   3'h7    
  `define UART_DL_LSB  8'h60    
  `define UART_DL_MSB  8'h00    
  `define UART_IE_DEF  8'h00    
  `define UART_LC_DEF  8'h03    
  `define UART_MC_DEF  8'h00    
  always @(posedge wb_clk_i or posedge wb_rst_i) begin    
      if(wb_rst_i) begin
          IPEN    <= 1'b1;                 
          IPEND   <= 1'b0;          
          INTID   <= 2'b00;                
      end
      else begin
          if(DR & EDAI) begin           
              IPEN  <= 1'b0;                
              IPEND <= 1'b1;          
              INTID <= 2'b10;               
          end
          if(THRE & ETXH) begin          
              IPEN  <= 1'b0;                
              IPEND <= 1'b1;          
              INTID <= 2'b01;               
          end
          if((CTS | DSR | RI |RLSD) && EMSI) begin    
              IPEN  <= 1'b0;                    
              IPEND <= 1'b1;          
              INTID <= 2'b00;                   
          end
          if(rd_command)                      
              case(UART_Addr)                 
                  `UART_RG_TR: IPEN <= 1'b1;  
                  `UART_RG_II: IPEN <= 1'b1;  
                  `UART_RG_MS: IPEN <= 1'b1;  
                  default:   ;                
              endcase                         
          if(wr_command)                      
              case(UART_Addr)                 
                  `UART_RG_TR: IPEN <= 1'b1;  
                  default:   ;                
              endcase                         
      if(IPEN & IPEND) begin
        INTID <= 2'b00;          
        IPEND <= 1'b0;          
      end
      end
  end    
  always @(posedge wb_clk_i or posedge wb_rst_i) begin    
      if(wb_rst_i) begin
      rx_rden  <= 1'b1;          
          DR      <= 1'b0;          
          THRE    <= 1'b0;          
      end
      else begin
          if(rx_drdy) begin             
              DR    <= 1'b1;          
        if(rx_rden) ;   
        else begin            
          rx_rden <= 1'b0;      
        end                
      end
          if(tx_done) begin            
              THRE  <= 1'b1;          
          end
      if(IPEN && IPEND) begin        
        rx_rden <= 1'b1;         
              DR      <= 1'b0;        
              THRE    <= 1'b0;        
      end
    end
  end
  always @(posedge wb_clk_i or posedge wb_rst_i) begin    
      if(wb_rst_i) begin
          dat_o   <= 8'h00;            
      end
      else
      if(rd_command) begin
          case(UART_Addr)                            
              `UART_RG_TR: dat_o <= dlab ? dll : output_data;
              `UART_RG_IE: dat_o <= dlab ? dlh : INTE;
              `UART_RG_II: dat_o <= ISTAT;        
              `UART_RG_LC: dat_o <= LCON;         
              `UART_RG_MC: dat_o <= MCON;        
              `UART_RG_LS: dat_o <= LSTAT;        
              `UART_RG_MS: dat_o <= MSTAT;        
              `UART_RG_SR: dat_o <= 8'h00;        
              default:     dat_o <= 8'h00;        
          endcase                                 
      end
  end  
  always @(posedge wb_clk_i or posedge wb_rst_i) begin    
      if(wb_rst_i) begin
          dll     <= `UART_DL_LSB;    
          dlh     <= `UART_DL_MSB;    
          ier     <= 4'h01;           
          lcr     <= 8'h03;           
          mcr     <= 8'h00;           
      end
      else if(wr_command) begin                   
          case(UART_Addr)                         
              `UART_RG_TR: if(dlab) dll <= dat_i; else input_data <= dat_i;
              `UART_RG_IE: if(dlab) dlh <= dat_i; else ier        <= dat_i[3:0];
              `UART_RG_II: ;                      
              `UART_RG_LC: lcr <= dat_i;          
              `UART_RG_MC: mcr <= dat_i;          
              `UART_RG_LS: ;                      
              `UART_RG_MS: ;                      
              `UART_RG_SR: ;                  
              default:     ;                      
          endcase                                 
      end
  end  
  always @(posedge wb_clk_i or posedge wb_rst_i) begin    
      if(wb_rst_i) tx_send <= 1'b0;                  
      else         tx_send <= (wr_command && (UART_Addr == `UART_RG_TR) && !dlab);
  end  
  serial_arx arx (
    .clk             (wb_clk_i),
    .baud8tick       (Baud8Tick),
    .rxd             (rs232_rx),
    .rxd_data_ready  (rx_drdy),
    .rxd_data        (output_data),
    .rxd_endofpacket (rxd_endofpacket),
    .rxd_idle        (rx_idle)
  );
  serial_atx atx (
    .clk       (wb_clk_i),
    .baud1tick (Baud1Tick),
    .txd       (rs232_tx),
    .txd_start (tx_send),
    .txd_data  (input_data),
    .txd_busy  (tx_busy)
  );
  always @(posedge wb_clk_i)
    BaudAcc1 <= {1'b0, BaudAcc1[17:0]} + BaudInc;
  always @(posedge wb_clk_i)
    BaudAcc8 <= {1'b0, BaudAcc8[14:0]} + BaudInc[15:0];
  assign dat_i = wb_sel_i[0] ? wb_dat_i[7:0]  : wb_dat_i[15:8]; 
  assign wb_dat_o   = wb_sel_i[0] ? {8'h00, dat_o} : {dat_o, 8'h00}; 
  assign UART_Addr = {wb_adr_i, wb_sel_i[1]}; 
  assign wb_ack_i = wb_stb_i &  wb_cyc_i;    
  assign wr_command = wb_ack_i &  wb_we_i;     
  assign rd_command = wb_ack_i & ~wb_we_i;     
  assign wb_tgc_o   = ~IPEN;               
  assign EDAI = ier[0];             
  assign ETXH = ier[1];            
  assign EMSI = ier[3];            
  assign INTE = {4'b0000, ier};
  assign ISTAT = { 5'b0000_0,INTID,IPEN};
  assign TSRE = tx_done;                      
  assign PE = 1'b0;                       
  assign BI = 1'b0;                         
  assign FE = to_error;                     
  assign OR = rx_over;                     
  assign LSTAT = {1'b0,TSRE,THRE,BI,FE,PE,OR,DR};
  assign DTR = mcr[0];
  assign RTS = mcr[1];
  assign OUT1 = mcr[2];
  assign OUT2 = mcr[3];
  assign LOOP = mcr[4];
  assign MCON = {3'b000, mcr[4:0]};
  assign RLSD = LOOP ? OUT2 : 1'b0;    
  assign RI = LOOP ? OUT1 : 1'b1;    
  assign DSR = LOOP ? DTR  : 1'b0;    
  assign CTS = LOOP ? RTS  : 1'b0;    
  assign DRLSD = 1'b0;                  
  assign TERI = 1'b0;                  
  assign DDSR = 1'b0;                  
  assign DCTS = 1'b0;                  
  assign MSTAT = {RLSD,RI,DSR,CTS,DCTS,DDSR,TERI,DRLSD};
  assign LCON = lcr;              
  assign dlab = lcr[7];           
  assign tx_done = ~tx_busy;     
  assign rx_over  = 1'b0;
  assign to_error = 1'b0;
  assign Baudiv = {3'b000,dlh,dll};
  assign Baud1Tick = BaudAcc1[18];
  assign BaudInc =  19'd2416/Baudiv;
endmodule
