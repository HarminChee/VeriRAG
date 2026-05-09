module ps2 (
    input         wb_clk_i,  
    input         wb_rst_i,  
    input  [15:0] wb_dat_i,  
    output [15:0] wb_dat_o,  
    input         wb_cyc_i,  
    input         wb_stb_i,  
    input  [ 2:1] wb_adr_i,  
    input  [ 1:0] wb_sel_i,  
    input         wb_we_i,   
    output        wb_ack_o,  
    output        wb_tgk_o,  
    output        wb_tgm_o,  
    input ps2_kbd_clk_,  
    inout ps2_kbd_dat_,  
    inout ps2_mse_clk_,  
    inout ps2_mse_dat_   
  );
  wire   [7:0] dat_i;
  wire   [2:0] wb_ps2_addr;
  wire         wb_ack_i;
  wire         write_i;
  wire         read_i;
  wire    PS_IBF;
  wire    PS_OBF;
  wire    PS_SYS;
  wire    PS_A2;
  wire    PS_INH;
  wire    PS_MOBF;
  wire    PS_TO;
  wire    RX_PERR;
  wire [7:0]  PS_STAT;
  reg  [7:0]  PS_CNTL;        
  wire        PS_INT;
  wire        PS_INT2;
  wire        DAT_SEL;
  wire        DAT_wr;
  wire        DAT_rd;
  wire        CMD_SEL;
  wire        CMD_wr;
  wire        CMD_rdc;
  wire        CMD_wrc;
  wire    CMD_mwr;
  wire    CMD_tst;
  wire    CMD_mit;
  wire [7:0]  dat_o;
  wire [7:0]  d_dat_o;
  wire [7:0]  r_dat_o;
  wire [7:0]  t_dat_o;
  wire [7:0]  i_dat_o;
  wire [7:0]  p_dat_o;
  wire [7:0]  ps_tst_o;
  wire [7:0]  ps_mit_o;
  wire     cmd_msnd;
  wire    IBF;
  reg  cnt_r_flag;              
  reg  cnt_w_flag;              
  reg  cmd_w_msnd;              
  reg cmd_r_test;              
  reg cmd_r_mint;              
  reg   MSE_INT;            
  wire  PS_READ;
  wire [7:0]  MSE_dat_o;        
  wire [7:0]  MSE_dat_i;
  wire        MSE_RDY;        
  wire        MSE_DONE;        
  wire        MSE_TOER;             
  wire        MSE_OVER;             
  wire        MSE_SEND;
  wire       KBD_INT;
  wire [7:0] KBD_dat_o;
  wire     KBD_Txdone;
  wire     KBD_Rxdone;
  wire released;
`define     default_cntl  8'b0100_0111
`define PS2_CMD_A9    8'hA9    
`define PS2_CMD_AA    8'hAA    
`define PS2_CMD_D4    8'hD4    
`define PS2_CNT_RD    8'h20    
`define PS2_CNT_WR    8'h60    
`define PS2_DAT_REG    3'b000    
`define PS2_CMD_REG    3'b100    
  always @(posedge wb_clk_i) begin    
    if(wb_rst_i) begin
    PS_CNTL     <= `default_cntl;   
    cnt_r_flag  <= 1'b0;        
    cnt_w_flag  <= 1'b0;        
    cmd_w_msnd  <= 1'b0;        
    cmd_r_test  <= 1'b0;        
    cmd_r_mint  <= 1'b0;        
    end
    else
    if(CMD_rdc) begin
      cnt_r_flag <= 1'b1;    
    end
    else
    if(CMD_wrc) begin
      cnt_w_flag <= 1'b1;        
      cmd_w_msnd <= 1'b0;        
    end
    else
    if(CMD_mwr) begin
      cmd_w_msnd <= 1'b1;    
    end
    else
    if(CMD_tst) begin
      cmd_r_test <= 1'b1;    
    end
    else
    if(CMD_mit) begin
      cmd_r_mint <= 1'b1;    
    end
    else
    if(DAT_rd) begin
      if(cnt_r_flag) cnt_r_flag <= 1'b0;    
      if(cmd_r_test) cmd_r_test <= 1'b0;    
      if(cmd_r_mint) cmd_r_mint <= 1'b0;    
    end
    else
    if(DAT_wr) begin
      if(cnt_w_flag) begin
        PS_CNTL    <= dat_i;        
        cnt_w_flag  <= 1'b0;        
      end
    end
    if(cmd_w_msnd && MSE_DONE) cmd_w_msnd <= 1'b0;    
  end  
  always @(posedge wb_clk_i or posedge wb_rst_i) begin  
    if(wb_rst_i) MSE_INT <= 1'b0;                     
    else begin
        if(MSE_RDY) MSE_INT <= 1'b1;      
        if(PS_READ) MSE_INT <= 1'b0;      
    end
  end  
  ps2_mouse_nofifo mouse_nofifo (
    .clk     (wb_clk_i),
    .reset   (wb_rst_i),
    .ps2_clk (ps2_mse_clk_),
    .ps2_dat (ps2_mse_dat_),
    .writedata (MSE_dat_i),       
    .write     (MSE_SEND),        
    .command_was_sent (MSE_DONE), 
    .readdata (MSE_dat_o), 
    .irq      (MSE_RDY),   
    .inhibit  (MSE_INT),
    .error_sending_command (MSE_TOER),  
    .buffer_overrun_error  (MSE_OVER)    
  );
  ps2_keyb #(
    .TIMER_60USEC_VALUE_PP (750),
    .TIMER_60USEC_BITS_PP  (10),
    .TIMER_5USEC_VALUE_PP  (60),
    .TIMER_5USEC_BITS_PP   (6)
    ) keyb (
    .clk   (wb_clk_i),
    .reset (wb_rst_i),
    .rx_shifting_done (KBD_Rxdone), 
    .tx_shifting_done (KBD_Txdone), 
    .scancode         (KBD_dat_o), 
    .rx_output_strobe (KBD_INT),   
    .released         (released),
    .ps2_clk_  (ps2_kbd_clk_), 
    .ps2_data_ (ps2_kbd_dat_)
  );
  assign dat_i    =  wb_sel_i[0] ? wb_dat_i[7:0]  : wb_dat_i[15:8]; 
  assign wb_dat_o =  wb_sel_i[0] ? {8'h00, dat_o} : {dat_o, 8'h00}; 
  assign wb_ps2_addr = {wb_adr_i,   wb_sel_i[1]};  
  assign wb_ack_i =  wb_stb_i &  wb_cyc_i;    
  assign wb_ack_o    =  wb_ack_i;
  assign write_i =  wb_ack_i &  wb_we_i;    
  assign read_i =  wb_ack_i & ~wb_we_i;    
  assign wb_tgm_o    =  MSE_INT & PS_INT2;      
  assign wb_tgk_o    =  KBD_INT & PS_INT;      
  assign PS_IBF = IBF;          
  assign PS_OBF = KBD_Txdone;      
  assign PS_SYS = 1'b1;          
  assign PS_A2 = 1'b0;          
  assign PS_INH = 1'b1;          
  assign PS_MOBF = MSE_DONE;        
  assign PS_TO = MSE_TOER;        
  assign RX_PERR = MSE_OVER;        
  assign PS_STAT = {RX_PERR, PS_TO, PS_MOBF, PS_INH, PS_A2, PS_SYS, PS_OBF, PS_IBF};    
  assign PS_INT = PS_CNTL[0];  
  assign PS_INT2 = PS_CNTL[1];  
  assign DAT_SEL = (wb_ps2_addr == `PS2_DAT_REG);
  assign DAT_wr = DAT_SEL && write_i;
  assign DAT_rd = DAT_SEL && read_i;
  assign CMD_SEL = (wb_ps2_addr == `PS2_CMD_REG);
  assign CMD_wr = CMD_SEL && write_i;
  assign CMD_rdc = CMD_wr  && (dat_i == `PS2_CNT_RD);  
  assign CMD_wrc = CMD_wr  && (dat_i == `PS2_CNT_WR);  
  assign CMD_mwr = CMD_wr  && (dat_i == `PS2_CMD_D4);  
  assign CMD_tst = CMD_wr  && (dat_i == `PS2_CMD_AA);  
  assign CMD_mit = CMD_wr  && (dat_i == `PS2_CMD_A9);  
  assign dat_o = d_dat_o;  
  assign d_dat_o = DAT_SEL    ? r_dat_o   : PS_STAT;  
  assign r_dat_o = cnt_r_flag ? PS_CNTL   : t_dat_o;  
  assign t_dat_o = cmd_r_test ? ps_tst_o  : i_dat_o;  
  assign i_dat_o = cmd_r_mint ? ps_mit_o  : p_dat_o;  
  assign p_dat_o = MSE_INT    ? MSE_dat_o : KBD_dat_o;  
  assign ps_tst_o = 8'h55;                
  assign ps_mit_o = 8'h00;                
  assign cmd_msnd = cmd_w_msnd && DAT_wr;  
  assign IBF = MSE_INT || KBD_INT || cnt_r_flag || cmd_r_test || cmd_r_mint;
  assign PS_READ = DAT_rd && !(cnt_r_flag || cmd_r_test || cmd_r_mint);
  assign      MSE_dat_i = dat_i;    
  assign MSE_SEND = cmd_msnd;  
endmodule
