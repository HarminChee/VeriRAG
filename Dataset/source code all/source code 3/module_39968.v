`timescale 1 ps / 1 ps
 module aurora_64b66b_25p4G_SYM_GEN
 (
     TX_PE_DATA,
     TX_PE_DATA_V,
     GEN_SEP7,
     GEN_SEP,
     SEP_NB,
     GEN_NA_IDLE,
     GEN_CH_BOND,
     GEN_CC,
     TX_HEADER_1,
     TX_HEADER_0,
     TX_DATA,
     TXDATAVALID_SYMGEN_IN,
     CHANNEL_UP,
     USER_CLK,
     RESET
 );
 `define DLY #1
       input    [63:0]     TX_PE_DATA; 
       input               TX_PE_DATA_V; 
       input               GEN_SEP7; 
       input               GEN_SEP; 
       input    [0:2]      SEP_NB; 
       input               GEN_CC; 
       input               GEN_NA_IDLE;       
       input               GEN_CH_BOND;       
       output              TX_HEADER_1;  
       output              TX_HEADER_0; 
       output   [63:0]     TX_DATA;          
       input               TXDATAVALID_SYMGEN_IN; 
       input               CHANNEL_UP; 
       input               USER_CLK;          
       input               RESET;             
       reg      [63:0]     TX_DATA=64'd0; 
       reg                 TX_HEADER_1=1'b0; 
       reg                 TX_HEADER_0=1'b1; 
       reg      [63:0]     txdata_c; 
       reg                 tx_header_1_c; 
       reg                 tx_header_0_c; 
       wire                gen_idle_c; 
       wire     [63:0]     tx_data_ctrl_c; 
       wire                gen_ctrl_ch; 
       wire     [63:0]     txdata_s; 
     assign gen_ctrl_ch =   GEN_CC   | GEN_CH_BOND | GEN_NA_IDLE 
 | GEN_SEP  | GEN_SEP7  
 ;
     assign  gen_idle_c     =   !(TX_PE_DATA_V | gen_ctrl_ch);
     assign tx_data_ctrl_c[63:56] = (GEN_CC || GEN_CH_BOND ||    GEN_NA_IDLE ||  (gen_idle_c & !TX_PE_DATA_V)) ? 8'h78 : 
                                    (GEN_SEP) ? 8'h1e : 
                                    (GEN_SEP7) ? 8'he1 :  
                                    8'h0;
     assign tx_data_ctrl_c[55:48] = (GEN_CC) ? 8'h80 : (GEN_CH_BOND) ? 8'h40 :  (GEN_NA_IDLE) ? 8'h30 :
                                    ((gen_idle_c & !TX_PE_DATA_V)) ? 8'h10 : 8'h0;
     assign tx_data_ctrl_c[47:0]  =  48'h0;
     assign txdata_s = {TX_PE_DATA[7:0],TX_PE_DATA[15:8],TX_PE_DATA[23:16],TX_PE_DATA[31:24],TX_PE_DATA[39:32],TX_PE_DATA[47:40],TX_PE_DATA[55:48],TX_PE_DATA[63:56]};
     always @ ( CHANNEL_UP or GEN_CC or  GEN_CH_BOND or txdata_s
              or  GEN_NA_IDLE 
              or  gen_idle_c or  TX_PE_DATA_V or  GEN_SEP or  GEN_SEP7 
              or  tx_data_ctrl_c or TX_PE_DATA 
              or SEP_NB
              )
     begin  
         if(GEN_CC   || GEN_CH_BOND 
                     || GEN_NA_IDLE || (gen_idle_c & !TX_PE_DATA_V) && (!GEN_SEP || !GEN_SEP7))               
         begin
             txdata_c =   tx_data_ctrl_c;                                 
             tx_header_1_c = 1'b1;
             tx_header_0_c = 1'b0;
         end
         else if(TX_PE_DATA_V && !GEN_SEP && !GEN_SEP7 && CHANNEL_UP)
         begin
             txdata_c =   txdata_s;      
             tx_header_1_c = 1'b0;
             tx_header_0_c = 1'b1;
         end
         else if(GEN_SEP && !gen_idle_c && CHANNEL_UP)
         begin
             txdata_c =   {tx_data_ctrl_c[63:56],5'h0,SEP_NB,txdata_s[47:0]};     
             tx_header_1_c = 1'b1;
             tx_header_0_c = 1'b0;
         end
         else if(GEN_SEP7 && CHANNEL_UP)
         begin
             txdata_c =   {tx_data_ctrl_c[63:56],txdata_s[55:0]}; 
             tx_header_1_c = 1'b1;
             tx_header_0_c = 1'b0;
         end
         else 
         begin
             txdata_c =   64'b0;
             tx_header_1_c = 1'b0;
             tx_header_0_c = 1'b1;
         end
     end
     always @ (posedge USER_CLK)
     begin
         if(TXDATAVALID_SYMGEN_IN)
         begin
             TX_DATA <= `DLY txdata_c;
             TX_HEADER_0 <= `DLY tx_header_0_c;
             TX_HEADER_1 <= `DLY tx_header_1_c;
         end
     end
 endmodule
`timescale 1 ps / 1 ps
 module aurora_64b66b_25p4G_SYM_GEN
 (
     TX_PE_DATA,
     TX_PE_DATA_V,
     GEN_SEP7,
     GEN_SEP,
     SEP_NB,
     GEN_NA_IDLE,
     GEN_CH_BOND,
     GEN_CC,
     TX_HEADER_1,
     TX_HEADER_0,
     TX_DATA,
     TXDATAVALID_SYMGEN_IN,
     CHANNEL_UP,
     USER_CLK,
     RESET
 );
 `define DLY #1
       input    [63:0]     TX_PE_DATA; 
       input               TX_PE_DATA_V; 
       input               GEN_SEP7; 
       input               GEN_SEP; 
       input    [0:2]      SEP_NB; 
       input               GEN_CC; 
       input               GEN_NA_IDLE;       
       input               GEN_CH_BOND;       
       output              TX_HEADER_1;  
       output              TX_HEADER_0; 
       output   [63:0]     TX_DATA;          
       input               TXDATAVALID_SYMGEN_IN; 
       input               CHANNEL_UP; 
       input               USER_CLK;          
       input               RESET;             
       reg      [63:0]     TX_DATA=64'd0; 
       reg                 TX_HEADER_1=1'b0; 
       reg                 TX_HEADER_0=1'b1; 
       reg      [63:0]     txdata_c; 
       reg                 tx_header_1_c; 
       reg                 tx_header_0_c; 
       wire                gen_idle_c; 
       wire     [63:0]     tx_data_ctrl_c; 
       wire                gen_ctrl_ch; 
       wire     [63:0]     txdata_s; 
     assign gen_ctrl_ch =   GEN_CC   | GEN_CH_BOND | GEN_NA_IDLE 
 | GEN_SEP  | GEN_SEP7  
 ;
     assign  gen_idle_c     =   !(TX_PE_DATA_V | gen_ctrl_ch);
     assign tx_data_ctrl_c[63:56] = (GEN_CC || GEN_CH_BOND ||    GEN_NA_IDLE ||  (gen_idle_c & !TX_PE_DATA_V)) ? 8'h78 : 
                                    (GEN_SEP) ? 8'h1e : 
                                    (GEN_SEP7) ? 8'he1 :  
                                    8'h0;
     assign tx_data_ctrl_c[55:48] = (GEN_CC) ? 8'h80 : (GEN_CH_BOND) ? 8'h40 :  (GEN_NA_IDLE) ? 8'h30 :
                                    ((gen_idle_c & !TX_PE_DATA_V)) ? 8'h10 : 8'h0;
     assign tx_data_ctrl_c[47:0]  =  48'h0;
     assign txdata_s = {TX_PE_DATA[7:0],TX_PE_DATA[15:8],TX_PE_DATA[23:16],TX_PE_DATA[31:24],TX_PE_DATA[39:32],TX_PE_DATA[47:40],TX_PE_DATA[55:48],TX_PE_DATA[63:56]};
     always @ ( CHANNEL_UP or GEN_CC or  GEN_CH_BOND or txdata_s
              or  GEN_NA_IDLE 
              or  gen_idle_c or  TX_PE_DATA_V or  GEN_SEP or  GEN_SEP7 
              or  tx_data_ctrl_c or TX_PE_DATA 
              or SEP_NB
              )
     begin  
         if(GEN_CC   || GEN_CH_BOND 
                     || GEN_NA_IDLE || (gen_idle_c & !TX_PE_DATA_V) && (!GEN_SEP || !GEN_SEP7))               
         begin
             txdata_c =   tx_data_ctrl_c;                                 
             tx_header_1_c = 1'b1;
             tx_header_0_c = 1'b0;
         end
         else if(TX_PE_DATA_V && !GEN_SEP && !GEN_SEP7 && CHANNEL_UP)
         begin
             txdata_c =   txdata_s;      
             tx_header_1_c = 1'b0;
             tx_header_0_c = 1'b1;
         end
         else if(GEN_SEP && !gen_idle_c && CHANNEL_UP)
         begin
             txdata_c =   {tx_data_ctrl_c[63:56],5'h0,SEP_NB,txdata_s[47:0]};     
             tx_header_1_c = 1'b1;
             tx_header_0_c = 1'b0;
         end
         else if(GEN_SEP7 && CHANNEL_UP)
         begin
             txdata_c =   {tx_data_ctrl_c[63:56],txdata_s[55:0]}; 
             tx_header_1_c = 1'b1;
             tx_header_0_c = 1'b0;
         end
         else 
         begin
             txdata_c =   64'b0;
             tx_header_1_c = 1'b0;
             tx_header_0_c = 1'b1;
         end
     end
     always @ (posedge USER_CLK)
     begin
         if(TXDATAVALID_SYMGEN_IN)
         begin
             TX_DATA <= `DLY txdata_c;
             TX_HEADER_0 <= `DLY tx_header_0_c;
             TX_HEADER_1 <= `DLY tx_header_1_c;
         end
     end
 endmodule
