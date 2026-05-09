`timescale 1ns / 1ps
`timescale 1ns / 1ps
module altera_sdram_tri_controller
   #(
      parameter                           TRISTATE_EN = 0,
      parameter                           NUM_CHIPSELECTS = 1,
      parameter                           CNTRL_ADDR_WIDTH = 22,                    
      parameter                           SDRAM_BANK_WIDTH = 2,                     
      parameter                           SDRAM_ROW_WIDTH = 12,                     
      parameter                           SDRAM_COL_WIDTH = 8,                      
      parameter                           SDRAM_DATA_WIDTH = 32,                    
      parameter                           CAS_LATENCY = 2,                          
      parameter                           INIT_REFRESH = 2,                         
      parameter                           REFRESH_PERIOD = 1563,                    
      parameter                           POWERUP_DELAY = 10000,                    
      parameter                           T_RFC = 7,                                
      parameter                           T_RP = 2,                                 
      parameter                           T_RCD = 2,                                
      parameter                           T_WR = 5,                                 
      parameter                           MAX_REC_TIME = 1                          
   )
   (
      input wire                                   clk                  ,           
      input wire                                   rst_n                ,           
      input wire                                   avs_read             ,
      input wire                                   avs_write            ,
      input wire  [ (SDRAM_DATA_WIDTH/8) - 1 : 0 ] avs_byteenable       ,
      input wire      [ CNTRL_ADDR_WIDTH - 1 : 0 ] avs_address          ,
      input wire      [ SDRAM_DATA_WIDTH - 1 : 0 ] avs_writedata        ,
      output wire     [ SDRAM_DATA_WIDTH - 1 : 0 ] avs_readdata         ,
      output wire                                  avs_readdatavalid    ,
      output wire                                  avs_waitrequest      ,
      input wire                                   tcm_grant            ,        
      output wire                                  tcm_request          ,        
      output wire     [  SDRAM_ROW_WIDTH - 1 : 0 ] sdram_addr           ,
      output wire     [ SDRAM_BANK_WIDTH - 1 : 0 ] sdram_ba             ,
      inout  wire     [ SDRAM_DATA_WIDTH - 1 : 0 ] sdram_dq             ,        
      output wire     [ SDRAM_DATA_WIDTH - 1 : 0 ] sdram_dq_out         ,
      input wire      [ SDRAM_DATA_WIDTH - 1 : 0 ] sdram_dq_in          ,        
      output wire                                  sdram_dq_oe          ,
      output wire [ (SDRAM_DATA_WIDTH/8) - 1 : 0 ] sdram_dqm            ,
      output wire                                  sdram_ras_n          ,
      output wire                                  sdram_cas_n          ,
      output wire                                  sdram_we_n           ,
      output wire      [ NUM_CHIPSELECTS - 1 : 0 ] sdram_cs_n           ,
      output wire                                  sdram_cke
   );
   function integer log2ceil;
     input reg[63:0] val;
     reg [63:0] i;
     begin
       i = 1;
       log2ceil = 0;
       while (i < val) begin
         log2ceil = log2ceil + 1;
         i = i << 1;
       end
     end
   endfunction
   function integer max_2;
     input reg[63:0] val0;
     input reg[63:0] val1;
     begin
       if (val0 > val1)
         max_2 = val0;
       else
         max_2 = val1;
      end
   endfunction
   function integer max_5;
     input reg[63:0] val0;
     input reg[63:0] val1;
     input reg[63:0] val2;
     input reg[63:0] val3;
     input reg[63:0] val4;
     reg [63:0] i;
     reg [63:0] j;
     begin
       max_5 = 1;
       if (val0 > val1)  max_5 = val0;
       else              max_5 = val1;
       if (val2 > max_5) max_5 = val2;
       if (val3 > max_5) max_5 = val3;
       if (val4 > max_5) max_5 = val4;
     end
   endfunction
   localparam                          SDRAM_ADDR_WIDTH  = SDRAM_ROW_WIDTH;
   localparam                          CMD_LMR           = 3'b000;            
   localparam                          CMD_REFRESH       = 3'b001;            
   localparam                          CMD_PRECHARGE     = 3'b010;            
   localparam                          CMD_ACTIVE        = 3'b011;            
   localparam                          CMD_WRITE         = 3'b100;            
   localparam                          CMD_READ          = 3'b101;            
   localparam                          CMD_BURST         = 3'b110;            
   localparam                          CMD_NOP           = 3'b111;            
   localparam                          T_MRD             = 4;
   localparam                          I_RESET           = 3'b000;            
   localparam                          I_PRECH           = 3'b001;            
   localparam                          I_ARF             = 3'b010;            
   localparam                          I_WAIT            = 3'b011;            
   localparam                          I_INIT            = 3'b101;            
   localparam                          I_LMR             = 3'b111;            
   localparam                          M_IDLE            = 9'b000000001;      
   localparam                          M_RAS             = 9'b000000010;      
   localparam                          M_WAIT            = 9'b000000100;      
   localparam                          M_RD              = 9'b000001000;      
   localparam                          M_WR              = 9'b000010000;      
   localparam                          M_REC             = 9'b000100000;      
   localparam                          M_PRE             = 9'b001000000;      
   localparam                          M_REF             = 9'b010000000;      
   localparam                          M_OPEN            = 9'b100000000;
   localparam                          NUM_CS_ADDR_WIDTH  = log2ceil(NUM_CHIPSELECTS);
   localparam                          NUM_CS_N_WIDTH = (NUM_CHIPSELECTS == 1) ? 1 : log2ceil(NUM_CHIPSELECTS);
   localparam                          SDRAM_DQM_WIDTH = SDRAM_DATA_WIDTH / 8;
   localparam                          TRISTATE_PIPELINE = TRISTATE_EN ? 2 : 0;
   localparam                          POWERUP_DELAY_WIDTH = log2ceil(POWERUP_DELAY);
   localparam                          REFRESH_PERIOD_WIDTH = log2ceil(REFRESH_PERIOD);
   localparam                          REFRESH_CNT_WIDTH = max_2(POWERUP_DELAY_WIDTH, REFRESH_PERIOD_WIDTH);
   localparam                          T_RP_WIDTH  = log2ceil(T_RP + 1);
   localparam                          T_RFC_WIDTH = log2ceil(T_RFC + 1);
   localparam                          T_MRD_WIDTH = log2ceil(T_MRD + 1);
   localparam                          T_RCD_WIDTH = log2ceil(T_RCD + 1);
   localparam                          T_WR_WIDTH  = log2ceil(T_WR + 1);
   localparam                          TIM_CNT_WIDTH = max_5(T_RP_WIDTH, T_RFC_WIDTH, T_MRD_WIDTH, T_RCD_WIDTH, T_WR_WIDTH);
   localparam                          TOP_ROW_ADDR    = (SDRAM_BANK_WIDTH == 1) ? CNTRL_ADDR_WIDTH - NUM_CS_ADDR_WIDTH - 1 : CNTRL_ADDR_WIDTH - NUM_CS_ADDR_WIDTH - 2;
   localparam                          BOTTOM_ROW_ADDR = (SDRAM_BANK_WIDTH == 1) ? SDRAM_COL_WIDTH + 1                      : TOP_ROW_ADDR - SDRAM_ADDR_WIDTH + 1;
   localparam                          CAS_ADDR_WIDTH = (SDRAM_COL_WIDTH < 11) ? SDRAM_COL_WIDTH : SDRAM_COL_WIDTH + 1;
   localparam                          RD_LATENCY = CAS_LATENCY+TRISTATE_PIPELINE;
   wire                                grant                      ;
   reg                                 request                    ;
   wire                                az_rd_n                    ;
   wire                                az_wr_n                    ;
   wire   [  SDRAM_DQM_WIDTH - 1 : 0 ] az_be_n                    ;
   wire   [ CNTRL_ADDR_WIDTH - 1 : 0 ] az_addr                    ;
   wire   [ SDRAM_DATA_WIDTH - 1 : 0 ] az_data                    ;
   reg    [ SDRAM_DATA_WIDTH - 1 : 0 ] za_data                    ;
   reg                                 za_valid                   ;
   wire                                za_waitrequest             ;
   reg                                 ack_refresh_request        ;
   reg     [ CNTRL_ADDR_WIDTH - 
           NUM_CS_ADDR_WIDTH - 1 : 0 ] active_addr                ;
   wire   [ SDRAM_BANK_WIDTH - 1 : 0 ] active_bank                ;
   reg      [ NUM_CS_N_WIDTH - 1 : 0 ] active_cs_n                ;
   reg    [ SDRAM_DATA_WIDTH - 1 : 0 ] active_data                ;
   reg    [  SDRAM_DQM_WIDTH - 1 : 0 ] active_dqm                 ;
   reg                                 active_rnw                 ;
   wire                                almost_empty               ;
   wire                                almost_full                ;
   wire                                bank_match                 ;
   wire     [ CAS_ADDR_WIDTH - 1 : 0 ] cas_addr                   ;
   wire                                clk_en                     ;
   wire     [ NUM_CS_N_WIDTH - 1 : 0 ] cs_n                       ;
   wire    [ NUM_CHIPSELECTS - 1 : 0 ] csn_decode                 ;
   wire                                csn_match                  ;
   wire    [ CNTRL_ADDR_WIDTH - 
           NUM_CS_ADDR_WIDTH - 1 : 0 ] f_addr                     ;
   wire   [ SDRAM_BANK_WIDTH - 1 : 0 ] f_bank                     ;
   wire     [ NUM_CS_N_WIDTH - 1 : 0 ] f_cs_n                     ;
   wire   [ SDRAM_DATA_WIDTH - 1 : 0 ] f_data                     ;
   wire   [  SDRAM_DQM_WIDTH - 1 : 0 ] f_dqm                      ;
   wire                                f_empty                    ;
   reg                                 f_pop                      ;
   wire                                f_rnw                      ;
   wire                                f_select                   ;
   wire    [ CNTRL_ADDR_WIDTH + SDRAM_DQM_WIDTH + 
                SDRAM_DATA_WIDTH : 0 ] fifo_read_data             ;
   reg     [ SDRAM_ADDR_WIDTH - 1 : 0] i_addr                     ;
   reg  [ NUM_CHIPSELECTS + 3 - 1 : 0] i_cmd                      ;
   reg      [  TIM_CNT_WIDTH - 1 : 0 ] i_count                    ;
   reg                      [  2 : 0 ] i_refs                     ;
   reg                                 i_req                      ;
   reg                      [  2 : 0 ] i_state                    ;
   reg                      [  2 : 0 ] i_next                     ;
   reg                                 init_done                  ;
   reg    [ SDRAM_ADDR_WIDTH - 1 : 0 ] m_addr                     ;
   reg    [ SDRAM_BANK_WIDTH - 1 : 0 ] m_bank                     ;
   reg [ NUM_CHIPSELECTS + 3 - 1 : 0 ] m_cmd                      ;
   reg    [ SDRAM_DATA_WIDTH - 1 : 0 ] m_data                     ;
   reg    [  SDRAM_DQM_WIDTH - 1 : 0 ] m_dqm                      ;
   reg                                 oe                         ;
   reg                      [  8 : 0 ] m_state                    ;
   reg                      [  8 : 0 ] m_next                     ;
   reg      [  TIM_CNT_WIDTH - 1 : 0 ] m_count                    ;
   reg                                 m_csn                      ;
   wire                                pending                    ;
   wire                                rd_strobe                  ;
   reg           [  RD_LATENCY-1 : 0 ] rd_valid                   ;
   reg   [ REFRESH_CNT_WIDTH - 1 : 0 ] refresh_counter            ;
   reg                                 refresh_request            ;
   wire                                rnw_match                  ;
   wire                                row_match                  ;
   reg                                 za_cannotrefresh           ;
   wire   [ SDRAM_DATA_WIDTH - 1 : 0 ] dq                         ;     
   assign clk_en = 1;
   assign grant         = TRISTATE_EN ? tcm_grant     : 1'b1;
   assign tcm_request   = TRISTATE_EN ? request       : 1'b0;
   assign {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = m_cmd;
   assign sdram_dq      = oe ? m_data : {SDRAM_DATA_WIDTH{1'bz}};
   assign sdram_dq_out  = m_data;
   assign sdram_dq_oe   = oe;
   assign sdram_addr    = m_addr;
   assign sdram_ba      = m_bank;
   assign sdram_dqm     = m_dqm;
   assign sdram_cke     = clk_en;
   assign az_rd_n = ~avs_read;
   assign az_wr_n = ~avs_write;
   assign az_be_n = ~avs_byteenable;
   assign az_addr = avs_address;
   assign az_data = avs_writedata;
   assign avs_readdata = za_data;
   assign avs_readdatavalid = za_valid;
   assign avs_waitrequest = za_waitrequest;
   efifo_module #(
      .DATA_WIDTH    (CNTRL_ADDR_WIDTH + SDRAM_DQM_WIDTH + SDRAM_DATA_WIDTH + 1),
      .DEPTH         (2                                                        )
   ) the_efifo_module 
   (
      .almost_empty  (almost_empty                                         ),
      .almost_full   (almost_full                                          ),
      .clk           (clk                                                  ),
      .empty         (f_empty                                              ),
      .full          (za_waitrequest                                       ),
      .rd            (f_select                                             ),
      .rd_data       (fifo_read_data                                       ),
      .rst_n         (rst_n                                                ),
      .wr            ((~az_wr_n | ~az_rd_n) & !za_waitrequest              ),
      .wr_data       ({az_wr_n, az_addr, az_wr_n ? {SDRAM_DQM_WIDTH{1'b0}} : az_be_n, az_data})
   );
genvar i;
generate
if (NUM_CS_ADDR_WIDTH > 0)
begin: g_FifoReadData
   assign {f_rnw, f_cs_n, f_addr, f_dqm, f_data} = fifo_read_data;
   for (i = 0; i <= NUM_CHIPSELECTS-1; i = i + 1)
   begin: g_CsnDecode
      assign csn_decode[i] = cs_n != i;
   end
end
else
begin: g_FifoReadData
   assign {f_rnw, f_addr, f_dqm, f_data} = fifo_read_data;
   assign f_cs_n     = 1'b0;
   assign csn_decode = cs_n;
end
endgenerate
   assign f_select = f_pop & pending;
   assign cs_n = f_select ? f_cs_n : active_cs_n;
generate
if (SDRAM_BANK_WIDTH == 1)
begin: g_ActiveBank
   assign f_bank = f_addr[SDRAM_COL_WIDTH];
end
else
begin: g_ActiveBank
   assign f_bank = {  f_addr[CNTRL_ADDR_WIDTH-NUM_CS_ADDR_WIDTH-1],
                           f_addr[SDRAM_COL_WIDTH]};
end
endgenerate
   always @(posedge clk or negedge rst_n)
   begin
      if (rst_n == 0)
         refresh_counter <= POWERUP_DELAY;
      else if (refresh_counter == 0)
         refresh_counter <= REFRESH_PERIOD - 1;
      else
         refresh_counter <= refresh_counter - 1'b1;
   end
   always @(posedge clk or negedge rst_n)
   begin
      if (rst_n == 0)
         refresh_request <= 0;
      else if (1)
         refresh_request <= ((refresh_counter == 0) | refresh_request) & ~ack_refresh_request & init_done;
   end
   always @(posedge clk or negedge rst_n)
   begin
      if (rst_n == 0)
         za_cannotrefresh <= 0;
      else if (1)
         za_cannotrefresh <= (refresh_counter == 0) & refresh_request;
   end
   always @(posedge clk or negedge rst_n)
   begin
      if (rst_n == 0)
         init_done <= 0;
      else if (1)
         init_done <= init_done | (i_state == I_INIT);
   end
   always @(posedge clk or negedge rst_n)
   begin
      if (rst_n == 0)
      begin
         i_state  <= I_RESET;
         i_next   <= I_RESET;
         i_cmd    <= {{NUM_CHIPSELECTS{1'b1}}, CMD_NOP};
         i_addr   <= {SDRAM_ADDR_WIDTH{1'b1}};
         i_count  <= {TIM_CNT_WIDTH{1'b0}};
         i_refs   <= 3'b0;
         i_req    <= 1'b0;
      end
      else
      begin
         i_addr <= {SDRAM_ADDR_WIDTH{1'b1}};
         case (i_state) 
            I_RESET:
            begin
               i_cmd  <= {{NUM_CHIPSELECTS{1'b1}}, CMD_NOP};
               i_refs <= 3'b0;
               if (refresh_counter == 0) begin
                  i_state <= I_PRECH;
                  i_req   <= 1'b1;
               end
            end 
            I_PRECH:
            begin
               i_req <= 1'b1;
               if (grant == 1'b1) begin
                  i_state  <= I_WAIT;
                  i_cmd    <= {{NUM_CHIPSELECTS{1'b0}}, CMD_PRECHARGE};
                  i_count  <= T_RP;
                  i_next   <= I_ARF;
               end
            end
            I_ARF:
            begin
               i_req    <= 1'b0;
               i_cmd    <= {{NUM_CHIPSELECTS{1'b0}}, CMD_REFRESH};
               i_refs   <= i_refs + 1'b1;
               i_state  <= I_WAIT;
               i_count  <= T_RFC-1;
               if (i_refs == INIT_REFRESH-1) begin
                  i_next <= I_LMR;
                  i_req  <= 1'b1;
               end
               else begin
                  i_next <= I_ARF;
               end
            end
            I_WAIT:
            begin
               i_req <= 1'b0;
               i_cmd <= {{NUM_CHIPSELECTS{1'b0}}, CMD_NOP};
               if (i_count > 1)
                  i_count <= i_count - 1'b1;
               else
                  i_state <= i_next;
            end
            I_INIT:
            begin
               i_req   <= 1'b0;
               i_state <= I_INIT;
            end
            I_LMR:
            begin
               i_req <= 1'b1;
               if (grant == 1'b1) begin
                  i_state <= I_WAIT;
                  i_cmd   <= {{NUM_CHIPSELECTS{1'b0}}, CMD_LMR};
                  i_addr  <= {{SDRAM_ADDR_WIDTH-10{1'b0}}, 1'b0, 2'b00, {3{CAS_LATENCY}}, 4'h0};
                  i_count <= T_MRD;
                  i_next  <= I_INIT;
               end
            end
            default:
            begin
               i_state <= I_RESET;
               i_req   <= 1'b0;
            end
         endcase 
      end
   end
generate
if (SDRAM_BANK_WIDTH == 1)
begin: g_ActiveBankOne
   assign active_bank = active_addr[SDRAM_COL_WIDTH];
end
else
begin: g_ActiveBankTwo
   assign active_bank = {  active_addr[CNTRL_ADDR_WIDTH-NUM_CS_ADDR_WIDTH-1],
                           active_addr[SDRAM_COL_WIDTH]};
end
endgenerate
   assign csn_match = active_cs_n == f_cs_n;
   assign rnw_match = active_rnw == f_rnw;
   assign bank_match = active_bank == f_bank;
   assign row_match = { active_addr[TOP_ROW_ADDR : BOTTOM_ROW_ADDR] } == 
                      { f_addr     [TOP_ROW_ADDR : BOTTOM_ROW_ADDR] };
   assign pending = csn_match && rnw_match && bank_match && row_match && !f_empty;
generate
if (SDRAM_COL_WIDTH < 11)
begin: g_CasAddr
   assign cas_addr = f_select ? { {SDRAM_ADDR_WIDTH-SDRAM_COL_WIDTH{1'b0}}, f_addr     [SDRAM_COL_WIDTH-1 : 0] } : 
                                { {SDRAM_ADDR_WIDTH-SDRAM_COL_WIDTH{1'b0}}, active_addr[SDRAM_COL_WIDTH-1 : 0] } ;
end
else
begin: g_CasAddr
   assign cas_addr = f_select ? { {SDRAM_ADDR_WIDTH-SDRAM_COL_WIDTH-1{1'b0}}, f_addr     [SDRAM_COL_WIDTH-1:10], 1'b0, f_addr     [9 : 0] } : 
                                { {SDRAM_ADDR_WIDTH-SDRAM_COL_WIDTH-1{1'b0}}, active_addr[SDRAM_COL_WIDTH-1:10], 1'b0, active_addr[9 : 0] } ;
end
endgenerate
   always @(posedge clk or negedge rst_n)
   begin
      if (rst_n == 0)
      begin
         m_state  <= M_IDLE;
         m_next   <= M_IDLE;
         m_cmd    <= {{NUM_CHIPSELECTS{1'b1}}, CMD_NOP};
         m_bank   <= {SDRAM_BANK_WIDTH{1'b0}};
         m_addr   <= {SDRAM_ADDR_WIDTH{1'b0}};
         m_data   <= {SDRAM_DATA_WIDTH{1'b0}};
         m_dqm    <= {SDRAM_DQM_WIDTH{1'b0}};
         m_count  <= {TIM_CNT_WIDTH{1'b0}};
         ack_refresh_request <= 1'b0;
         f_pop    <= 1'b0;
         oe       <= 1'b0;
         request  <= 1'b0;
      end
      else
      begin
         f_pop    <= 1'b0;
         oe       <= 1'b0;
         request  <= 1'b0;
         case (m_state) 
            M_IDLE:
            begin
               if (init_done == 1'b1) begin
                  if (refresh_request == 1'b1) begin
                     m_cmd <= {{NUM_CHIPSELECTS{1'b0}}, CMD_NOP};
                  end else begin
                     m_cmd <= {{NUM_CHIPSELECTS{1'b1}}, CMD_NOP};
                  end
                  ack_refresh_request <= 1'b0;
                  if (refresh_request == 1'b1) begin
                     request     <= 1'b1;
                     m_state     <= M_PRE;
                     m_next      <= M_REF;
                     m_count     <= T_RP;
                     active_cs_n <= {NUM_CS_N_WIDTH{1'b1}};
                  end else if (f_empty == 1'b0) begin
                     request     <= 1'b1;
                     f_pop       <= 1'b1;
                     active_cs_n <= f_cs_n;
                     active_rnw  <= f_rnw;
                     active_addr <= f_addr;
                     active_data <= f_data;
                     active_dqm  <= f_dqm;
                     m_state     <= M_RAS;
                  end
               end else begin
                  request  <= i_req;
                  m_addr   <= i_addr;
                  m_cmd    <= i_cmd;
                  m_state  <= M_IDLE;
                  m_next   <= M_IDLE;
               end
            end 
            M_RAS:
            begin
               request <= 1'b1;
               if (grant == 1'b1) begin
                  m_state  <= M_WAIT;
                  m_cmd    <= {csn_decode, CMD_ACTIVE};
                  m_bank   <= active_bank;
                  m_addr   <= active_addr[TOP_ROW_ADDR : BOTTOM_ROW_ADDR];
                  m_data   <= active_data;
                  m_dqm    <= active_dqm;
                  m_count  <= T_RCD;
                  m_next   <= active_rnw ? M_RD : M_WR;
               end
            end 
            M_WAIT:
            begin
               request <= request;
               if (m_next == M_REF) begin
                  m_cmd <= {{NUM_CHIPSELECTS{1'b0}}, CMD_NOP};
               end else begin
                  m_cmd <= {csn_decode, CMD_NOP};
               end
               if (m_count > 1) begin
                  m_count <= m_count - 1'b1;
               end else begin
                  m_state <= m_next;
               end
            end 
            M_RD:
            begin
               request  <= 1'b1;
               m_cmd    <= {csn_decode, CMD_READ};
               m_bank   <= f_select ? f_bank : active_bank;
               m_dqm    <= f_select ? f_dqm  : active_dqm;
               m_addr   <= cas_addr;
               if (pending)
               begin
                  if (refresh_request)
                  begin
                     m_state  <= M_WAIT;
                     m_next   <= M_IDLE;
                     m_count  <= RD_LATENCY - 1;
                  end
                  else
                  begin
                     f_pop       <= 1'b1;
                     active_cs_n <= f_cs_n;
                     active_rnw  <= f_rnw;
                     active_addr <= f_addr;
                     active_data <= f_data;
                     active_dqm  <= f_dqm;
                  end
               end
               else 
               begin
                  if (~pending & f_pop) begin
                     m_cmd <= {csn_decode, CMD_NOP};
                  end
                  if (TRISTATE_EN == 0)
                  begin
                     m_state  <= M_OPEN;
                  end
                  else
                  begin
                     m_state  <= M_WAIT;
                     m_next   <= M_OPEN;
                     m_count  <= RD_LATENCY - 1;
                  end
               end
            end 
            M_WR:
            begin
               request  <= 1'b1;
               m_cmd    <= {csn_decode, CMD_WRITE};
               oe       <= 1'b1;
               m_data   <= f_select ? f_data : active_data;
               m_dqm    <= f_select ? f_dqm  : active_dqm;
               m_bank   <= f_select ? f_bank : active_bank;
               m_addr   <= cas_addr;
               if (pending)
               begin
                  if (refresh_request)
                  begin
                     m_state  <= M_WAIT;
                     m_next   <= M_IDLE;
                     m_count  <= T_WR;
                  end
                  else 
                  begin
                     f_pop       <= 1'b1;
                     active_cs_n <= f_cs_n;
                     active_rnw  <= f_rnw;
                     active_addr <= f_addr;
                     active_data <= f_data;
                     active_dqm  <= f_dqm;
                  end
               end
               else
               begin
                  if (~pending & f_pop)
                  begin
                     m_cmd <= {csn_decode, CMD_NOP};
                     oe <= 1'b0;
                  end
                  m_state <= M_OPEN;
               end
            end 
            M_REC:
            begin
               m_cmd <= {csn_decode, CMD_NOP};
               if (m_count > 1)
                  m_count <= m_count - 1'b1;
               else 
               begin
                  request <= 1'b1;
                  m_state <= M_PRE;
                  m_count <= T_RP;
               end
            end 
            M_PRE:
            begin
               request <= 1'b1;
               if (grant == 1'b1) begin
                  m_state <= M_WAIT;
                  m_addr  <= {SDRAM_ADDR_WIDTH{1'b1}};
                  if (refresh_request)
                     m_cmd <= {{NUM_CHIPSELECTS{1'b0}}, CMD_PRECHARGE};
                  else
                     m_cmd <= {csn_decode, CMD_PRECHARGE};
               end
            end 
            M_REF:
            begin
               ack_refresh_request <= 1'b1;
               m_state  <= M_WAIT;
               m_cmd    <= {{NUM_CHIPSELECTS{1'b0}}, CMD_REFRESH};
               m_count  <= T_RFC-1;
               m_next   <= M_IDLE;
            end 
            M_OPEN:
            begin
               m_cmd <= {csn_decode, CMD_NOP};
               if (refresh_request)
               begin
                  if (MAX_REC_TIME > 0)
                  begin
                     m_state  <= M_WAIT;
                     m_next   <= M_IDLE;
                     m_count  <= MAX_REC_TIME;
                  end
                  else
                  begin
                     m_state  <= M_IDLE;
                  end
               end
               else 
               begin
                  if (!f_empty)
                  begin
                     if (csn_match && rnw_match && bank_match && row_match)
                     begin
                        m_state     <= f_rnw ? M_RD : M_WR;
                        f_pop       <= 1'b1;
                        active_cs_n <= f_cs_n;
                        active_rnw  <= f_rnw;
                        active_addr <= f_addr;
                        active_data <= f_data;
                        active_dqm  <= f_dqm;
                     end
                     else 
                     begin
                        if (MAX_REC_TIME > 0)
                        begin
                           m_state  <= M_REC;
                           m_next   <= M_IDLE;
                           m_count  <= MAX_REC_TIME;
                        end
                        else
                        begin
                           request  <= 1'b1;
                           m_state  <= M_PRE;
                           m_next   <= M_IDLE;
                           m_count  <= T_RP;
                        end
                     end
                  end
               end
            end 
         endcase 
      end
   end
   assign rd_strobe = m_cmd[2 : 0] == CMD_READ;
generate
if (RD_LATENCY > 1)
begin: g_RdValid
   always @(posedge clk or negedge rst_n)
   begin
      if (rst_n == 0)
         rd_valid <= {RD_LATENCY{1'b0}};
      else
         rd_valid <= (rd_valid << 1) | { {RD_LATENCY-1{1'b0}}, rd_strobe };
   end
end
else
begin: g_RdValid
   always @(posedge clk or negedge rst_n)
   begin
      if (rst_n == 0)
         rd_valid <= 1'b0;
      else
         rd_valid <= rd_strobe;
   end
end
endgenerate
   assign dq = TRISTATE_EN ? sdram_dq_in : sdram_dq;
   always @(posedge clk or negedge rst_n)
   begin
      if (rst_n == 0)
         za_data <= 0;
      else
         za_data <= dq;
   end
   always @(posedge clk or negedge rst_n)
   begin
      if (rst_n == 0)
         za_valid <= 0;
      else if (1)
         za_valid <= rd_valid[RD_LATENCY- 1];
   end
endmodule
