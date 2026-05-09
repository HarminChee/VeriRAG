`timescale 1ns / 1ps
`define DLY #1
`timescale 1ns / 1ps
`define DLY #1
module TX_SYNC #(
  parameter         PLL_DIVSEL_OUT    =   1
)
(
  output  reg [16-1:0]            USER_DO,
  input       [16-1:0]            USER_DI,
  input       [7-1:0]             USER_DADDR,
  input                           USER_DEN,
  input                           USER_DWE,
  output  reg                     USER_DRDY,
  output      [16-1:0]            GT_DO,         
  input       [16-1:0]            GT_DI,         
  output  reg [7-1:0]             GT_DADDR,
  output  reg                     GT_DEN,
  output                          GT_DWE,
  input                           GT_DRDY,
  input                           USER_CLK, 
  input                           DCLK,
  input                           RESET,
  input                           RESETDONE,
  output                          TXENPMAPHASEALIGN,
  output                          TXPMASETPHASE,
  output  reg                     TXRESET,
  output                          SYNC_DONE,
  input                           RESTART_SYNC
);
parameter C_DRP_DWIDTH = 16;
parameter C_DRP_AWIDTH = 7;
reg   [1:0]             reset_usrclk_r; 
reg                     dclk_fsms_rdy_r; 
reg                     dclk_fsms_rdy_r2; 
reg   [6:0]             sync_state;
reg   [6:0]             sync_next_state;
reg   [40*7:0]          sync_fsm_name;
reg                     revert_drp;
reg                     start_drp;
reg                     start_drp_done_r2;
reg                     start_drp_done_r;
reg                     txreset_done_r;
reg                     revert_drp_done_r2;
reg                     revert_drp_done_r;
reg                     phase_align_done_r;
reg   [15:0]            sync_counter_r;
reg                     en_phase_align_r;
reg                     set_phase_r;
reg   [5:0]             wait_before_sync_r;
reg                     restart_sync_r2;
reg                     restart_sync_r;
reg                     resetdone_r;
reg                     resetdone_r2;
reg   [1:0]             reset_dclk_r; 
reg  [C_DRP_DWIDTH-1:0] user_di_r = {C_DRP_DWIDTH{1'b0}};
reg  [C_DRP_AWIDTH-1:0] user_daddr_r = {C_DRP_AWIDTH{1'b0}};
reg                     user_den_r;
reg                     user_req;
reg                     user_dwe_r;
reg                     xd_req = 1'b0;
reg                     xd_read = 1'b0;
reg                     xd_write = 1'b0;
reg                     xd_drp_done = 1'b0;
reg  [C_DRP_DWIDTH-1:0] xd_wr_wreg = {C_DRP_DWIDTH{1'b0}};
reg  [C_DRP_AWIDTH-1:0] xd_addr_r;
reg                     gt_drdy_r = 1'b0;
reg [C_DRP_DWIDTH-1:0]  gt_do_r = {C_DRP_DWIDTH{1'b0}};
reg   [3:0]             db_state;
reg   [3:0]             db_next_state;
reg   [5:0]             drp_state;
reg   [5:0]             drp_next_state;
reg   [15:0]            xd_state;
reg   [15:0]            xd_next_state;
reg   [40*7:0]          db_fsm_name;
reg   [40*7:0]          drp_fsm_name;
reg   [40*7:0]          xd_fsm_name;
reg                     revert_drp_r2;
reg                     revert_drp_r;
reg                     start_drp_r2;
reg                     start_drp_r;
wire [C_DRP_AWIDTH-1:0] c_tx_xclk0_addr;
wire [C_DRP_AWIDTH-1:0] c_tx_xclk1_addr;
wire                    user_sel;
wire                    xd_sel;
wire                    drp_rd;
wire                    drp_wr;
wire                    db_fsm_rdy;
wire                    drp_fsm_rdy;
wire                    xd_fsm_rdy;
wire                    dclk_fsms_rdy;
wire                    revert_drp_done;
wire                    start_drp_done;
wire                    count_setphase_complete_r;
wire                    txreset_i;
parameter C_RESET           = 4'b0001;
parameter C_IDLE            = 4'b0010;
parameter C_XD_DRP_OP       = 4'b0100;
parameter C_USER_DRP_OP     = 4'b1000;
parameter C_DRP_RESET       = 6'b000001;
parameter C_DRP_IDLE        = 6'b000010;
parameter C_DRP_READ        = 6'b000100;
parameter C_DRP_WRITE       = 6'b001000;
parameter C_DRP_WAIT        = 6'b010000;
parameter C_DRP_COMPLETE    = 6'b100000;
parameter C_XD_RESET              = 16'b0000000000000001;
parameter C_XD_IDLE               = 16'b0000000000000010;
parameter C_XD_RD_XCLK0_TXUSR     = 16'b0000000000000100;
parameter C_XD_MD_XCLK0_TXUSR     = 16'b0000000000001000;
parameter C_XD_WR_XCLK0_TXUSR     = 16'b0000000000010000;
parameter C_XD_RD_XCLK1_TXUSR     = 16'b0000000000100000;
parameter C_XD_MD_XCLK1_TXUSR     = 16'b0000000001000000;
parameter C_XD_WR_XCLK1_TXUSR     = 16'b0000000010000000;
parameter C_XD_WAIT               = 16'b0000000100000000;
parameter C_XD_RD_XCLK0_TXOUT     = 16'b0000001000000000;
parameter C_XD_MD_XCLK0_TXOUT     = 16'b0000010000000000;
parameter C_XD_WR_XCLK0_TXOUT     = 16'b0000100000000000;
parameter C_XD_RD_XCLK1_TXOUT     = 16'b0001000000000000;
parameter C_XD_MD_XCLK1_TXOUT     = 16'b0010000000000000;
parameter C_XD_WR_XCLK1_TXOUT     = 16'b0100000000000000;
parameter C_XD_DONE               = 16'b1000000000000000;  
parameter C_SYNC_IDLE               = 7'b0000001;
parameter C_SYNC_START_DRP          = 7'b0000010;
parameter C_SYNC_PHASE_ALIGN        = 7'b0000100;
parameter C_SYNC_REVERT_DRP         = 7'b0001000;
parameter C_SYNC_TXRESET            = 7'b0010000;
parameter C_SYNC_WAIT_RESETDONE     = 7'b0100000;
parameter C_SYNC_DONE               = 7'b1000000;
parameter C_GTX0_TX_XCLK_ADDR     = 7'h3A;
parameter C_GTX1_TX_XCLK_ADDR     = 7'h15;
assign c_tx_xclk0_addr    = C_GTX0_TX_XCLK_ADDR;
assign c_tx_xclk1_addr    = C_GTX1_TX_XCLK_ADDR;
always @(posedge DCLK or posedge RESET)
  if (RESET)
    reset_dclk_r <= 2'b11;
  else
    reset_dclk_r <= {1'b0, reset_dclk_r[1]};
always @(posedge USER_CLK or posedge RESET)
  if (RESET)
    reset_usrclk_r <= 2'b11;
  else
    reset_usrclk_r <= {1'b0, reset_usrclk_r[1]};
always @ (posedge DCLK)
begin
  if (reset_dclk_r[0])
    user_di_r <= 1'b0;
  else if (USER_DEN)
    user_di_r <= USER_DI;
end
always @ (posedge DCLK)
begin
  if (reset_dclk_r[0])
    user_daddr_r <= 7'b0;
  else if (USER_DEN)
    user_daddr_r <= USER_DADDR[C_DRP_AWIDTH-1:0];
end
always @ (posedge DCLK)
  if (reset_dclk_r[0])
    user_dwe_r <= 1'b0;
  else if (USER_DEN)
    user_dwe_r <= USER_DWE;
always @ (posedge DCLK)
  if (reset_dclk_r[0] | (db_state==C_USER_DRP_OP))
    user_den_r <= 1'b0;
  else if (~user_den_r)
    user_den_r <= USER_DEN;
always @ (posedge DCLK)
  if (reset_dclk_r[0] | (db_state==C_USER_DRP_OP))
    user_req <= 1'b0;
  else if ( 
            ~(user_daddr_r==c_tx_xclk0_addr) &
            ~(user_daddr_r==c_tx_xclk1_addr))
    user_req <= user_den_r;
  else if (xd_state==C_XD_IDLE || xd_state==C_XD_DONE)
    user_req <= user_den_r;
always @ (posedge DCLK)
  if ( (db_state == C_USER_DRP_OP) & GT_DRDY)
    USER_DO <= GT_DI;
always @ (posedge DCLK)
  if (reset_dclk_r[0] | USER_DRDY)
    USER_DRDY <= 1'b0;
  else if ( (db_state==C_USER_DRP_OP) )
    USER_DRDY <= GT_DRDY;
always @(posedge DCLK)
  casez( {xd_sel,user_sel} )
    2'b1?: gt_do_r <= xd_wr_wreg;
    2'b01: gt_do_r <= user_di_r;
  endcase
assign GT_DO = gt_do_r;
always @(posedge DCLK)
begin
  casez( {xd_sel, user_sel})
    2'b1?: GT_DADDR <= xd_addr_r;
    2'b01: GT_DADDR <= user_daddr_r;
  endcase
end
always @(posedge DCLK)
  if (reset_dclk_r[0])
    GT_DEN <= 1'b0;
  else
    GT_DEN <= (drp_state==C_DRP_IDLE) & (drp_wr | drp_rd);
assign GT_DWE = (drp_state==C_DRP_WRITE);
always @(posedge DCLK)
  gt_drdy_r <= GT_DRDY;
assign dclk_fsms_rdy = db_fsm_rdy & xd_fsm_rdy & drp_fsm_rdy;
always @(posedge USER_CLK)
begin
  if (dclk_fsms_rdy)
    dclk_fsms_rdy_r <= 1'b1;
  else
    dclk_fsms_rdy_r <= 1'b0;
end
always @(posedge USER_CLK)
    dclk_fsms_rdy_r2 <= dclk_fsms_rdy_r;
always @(posedge USER_CLK)
begin
  if (sync_state == C_SYNC_START_DRP)
    start_drp <= 1'b1;
  else  
    start_drp <= 1'b0;
end
always @(posedge USER_CLK)
begin
  if (reset_usrclk_r[0])
    start_drp_done_r <= 1'b0;
  else if (start_drp_done)
    start_drp_done_r <= 1'b1;
  else 
    start_drp_done_r <= 1'b0;
end       
always @(posedge USER_CLK)
    start_drp_done_r2 <= start_drp_done_r;
always @(posedge USER_CLK)
begin
  if ( reset_usrclk_r[0] | (sync_state == C_SYNC_IDLE) )
     en_phase_align_r <= 1'b0;
  else if (sync_state == C_SYNC_PHASE_ALIGN)
     en_phase_align_r <= 1'b1;
end
assign TXENPMAPHASEALIGN = en_phase_align_r;
always @(posedge USER_CLK)
begin
  if ( reset_usrclk_r[0] | ~en_phase_align_r )
    wait_before_sync_r <= `DLY  6'b000000;
  else if( ~wait_before_sync_r[5] )
    wait_before_sync_r <= `DLY  wait_before_sync_r + 1'b1;
end
always @(posedge USER_CLK)
begin
  if ( ~wait_before_sync_r[5] )
    set_phase_r <= 1'b0;
  else if ( ~count_setphase_complete_r & (sync_state == C_SYNC_PHASE_ALIGN) )
    set_phase_r <= 1'b1;
  else  
    set_phase_r <= 1'b0;
end
assign TXPMASETPHASE = set_phase_r;
always @(posedge USER_CLK)
begin
 if ( reset_usrclk_r[0] | ~(sync_state == C_SYNC_PHASE_ALIGN) )
   sync_counter_r <= `DLY  16'h0000;
 else if (set_phase_r)
   sync_counter_r <= `DLY  sync_counter_r + 1'b1;
end
generate
if (PLL_DIVSEL_OUT==1)
begin : pll_divsel_out_equals_1 
  assign count_setphase_complete_r = sync_counter_r[13];
end
else if (PLL_DIVSEL_OUT==2)
begin :pll_divsel_out_equals_2
  assign count_setphase_complete_r = sync_counter_r[14];
end
else 
begin :pll_divsel_out_equals_4
  assign count_setphase_complete_r = sync_counter_r[15];
end
endgenerate
always @(posedge USER_CLK)
begin
  if (reset_usrclk_r[0])
    phase_align_done_r <= 1'b0;
  else 
    phase_align_done_r <= set_phase_r & count_setphase_complete_r;
end
always @(posedge USER_CLK)
begin
  if (reset_usrclk_r[0])
    revert_drp <= 1'b0;
  else if (sync_state == C_SYNC_REVERT_DRP)
    revert_drp <= 1'b1;
  else  
    revert_drp <= 1'b0;
end
always @(posedge USER_CLK)
begin
  if (reset_usrclk_r[0])
    revert_drp_done_r <= 1'b0;
  else if (revert_drp_done)
    revert_drp_done_r <= 1'b1;
  else 
    revert_drp_done_r <= 1'b0;
end    
always @(posedge USER_CLK)
    revert_drp_done_r2 <= revert_drp_done_r;
assign txreset_i = (sync_state == C_SYNC_TXRESET);
always @(posedge USER_CLK)
  TXRESET <= txreset_i;
always @(posedge USER_CLK)
begin
  if (reset_usrclk_r[0])
    txreset_done_r <= 1'b0;
  else if ((sync_state == C_SYNC_TXRESET) & ~resetdone_r2)  
    txreset_done_r <= 1'b1;
  else  
    txreset_done_r <= 1'b0;
end
always @(posedge USER_CLK)
begin
  if (RESETDONE)  
    resetdone_r <= 1'b1;
  else
    resetdone_r <= 1'b0;
end
always @(posedge USER_CLK)
  resetdone_r2 <= resetdone_r;
always @(posedge USER_CLK)
begin
  if (RESTART_SYNC)  
    restart_sync_r <= 1'b1;
  else
    restart_sync_r <= 1'b0;
end
always @(posedge USER_CLK)
  restart_sync_r2 <= restart_sync_r;
assign SYNC_DONE = (sync_state == C_SYNC_DONE);
always @(posedge USER_CLK)
begin
  if (reset_usrclk_r[0])
    sync_state <= C_SYNC_IDLE;
  else
    sync_state <= sync_next_state;
end
always @*
begin
  case (sync_state)
    C_SYNC_IDLE: begin
      sync_next_state <= dclk_fsms_rdy_r2 ? C_SYNC_START_DRP : C_SYNC_IDLE;
      sync_fsm_name = "C_SYNC_IDLE";
    end
    C_SYNC_START_DRP: begin
      sync_next_state <= start_drp_done_r2 ? C_SYNC_PHASE_ALIGN : C_SYNC_START_DRP;
      sync_fsm_name = "C_SYNC_START_DRP";
    end
    C_SYNC_PHASE_ALIGN: begin
      sync_next_state <= phase_align_done_r ? C_SYNC_REVERT_DRP : C_SYNC_PHASE_ALIGN;
      sync_fsm_name = "C_SYNC_PHASE_ALIGN";
    end
    C_SYNC_REVERT_DRP: begin
      sync_next_state <= revert_drp_done_r2 ? C_SYNC_TXRESET : C_SYNC_REVERT_DRP;
      sync_fsm_name = "C_SYNC_REVERT_DRP";
    end
    C_SYNC_TXRESET: begin
      sync_next_state <= txreset_done_r ? C_SYNC_WAIT_RESETDONE : C_SYNC_TXRESET;
      sync_fsm_name = "C_SYNC_TXRESET";
    end
    C_SYNC_WAIT_RESETDONE: begin
      sync_next_state <= resetdone_r2 ? C_SYNC_DONE : C_SYNC_WAIT_RESETDONE;
      sync_fsm_name = "C_SYNC_WAIT_RESETDONE"; 
    end
    C_SYNC_DONE: begin
      sync_next_state <= restart_sync_r2 ? C_SYNC_IDLE : C_SYNC_DONE;
      sync_fsm_name = "C_SYNC_DONE";
    end
    default: begin
      sync_next_state <= C_SYNC_IDLE;
      sync_fsm_name = "default";
    end
  endcase
end
assign xd_sel = (db_state == C_XD_DRP_OP);
assign user_sel = (db_state == C_USER_DRP_OP);
assign db_fsm_rdy = ~(db_state == C_RESET);
always @(posedge DCLK)
begin
  if (reset_dclk_r[0])
    db_state <= C_RESET;
  else
    db_state <= db_next_state;
end
always @*
begin
  case (db_state)
    C_RESET: begin
      db_next_state <= C_IDLE;
      db_fsm_name = "C_RESET";
    end
    C_IDLE: begin
      if (xd_req)         db_next_state <= C_XD_DRP_OP;
      else if (user_req)  db_next_state <= C_USER_DRP_OP;
      else                db_next_state <= C_IDLE;
      db_fsm_name = "C_IDLE";
    end
    C_XD_DRP_OP: begin
      db_next_state <= gt_drdy_r ? C_IDLE : C_XD_DRP_OP;
      db_fsm_name = "C_XD_DRP_OP";
    end
    C_USER_DRP_OP: begin
      db_next_state <= gt_drdy_r ? C_IDLE : C_USER_DRP_OP;
      db_fsm_name = "C_USER_DRP_OP";
    end
    default: begin
      db_next_state <= C_IDLE;
      db_fsm_name = "default";
    end
  endcase
end
always @(posedge DCLK)
begin
  if ((xd_state == C_XD_IDLE) | xd_drp_done)
    xd_req <= 1'b0;
  else
    xd_req <= xd_read | xd_write;
end
always @(posedge DCLK)
begin
  if ((xd_state == C_XD_IDLE) | xd_drp_done)
    xd_read <= 1'b0;
  else
    xd_read <=  (xd_state == C_XD_RD_XCLK0_TXUSR) |
                (xd_state == C_XD_RD_XCLK1_TXUSR) |
                (xd_state == C_XD_RD_XCLK0_TXOUT) |
                (xd_state == C_XD_RD_XCLK1_TXOUT);
end
always @(posedge DCLK)
begin
  if ((xd_state == C_XD_IDLE) | xd_drp_done)
    xd_write <= 1'b0;
  else
    xd_write <= (xd_state == C_XD_WR_XCLK0_TXUSR) |
                (xd_state == C_XD_WR_XCLK1_TXUSR) |
                (xd_state == C_XD_WR_XCLK0_TXOUT) |
                (xd_state == C_XD_WR_XCLK1_TXOUT);
end
always @(posedge DCLK)
begin
  if ((db_state == C_XD_DRP_OP) & xd_read & GT_DRDY)
    xd_wr_wreg <= GT_DI;
  else begin
    case (xd_state)
      C_XD_MD_XCLK0_TXUSR:
        xd_wr_wreg <= {xd_wr_wreg[15:9], 1'b1, xd_wr_wreg[7:0]};
      C_XD_MD_XCLK1_TXUSR:
        xd_wr_wreg <= {xd_wr_wreg[15:8], 1'b1, xd_wr_wreg[6:0]};
      C_XD_MD_XCLK0_TXOUT:
        xd_wr_wreg <= {xd_wr_wreg[15:9], 1'b0, xd_wr_wreg[7:0]};
      C_XD_MD_XCLK1_TXOUT:
        xd_wr_wreg <= {xd_wr_wreg[15:8], 1'b0, xd_wr_wreg[6:0]};
    endcase
  end
end
always @*
begin
  case (xd_state)
    C_XD_RD_XCLK0_TXUSR:  xd_addr_r <= c_tx_xclk0_addr;
    C_XD_WR_XCLK0_TXUSR:  xd_addr_r <= c_tx_xclk0_addr;
    C_XD_RD_XCLK0_TXOUT:  xd_addr_r <= c_tx_xclk0_addr;
    C_XD_WR_XCLK0_TXOUT:  xd_addr_r <= c_tx_xclk0_addr;
    C_XD_RD_XCLK1_TXUSR:  xd_addr_r <= c_tx_xclk1_addr;
    C_XD_WR_XCLK1_TXUSR:  xd_addr_r <= c_tx_xclk1_addr;
    C_XD_RD_XCLK1_TXOUT:  xd_addr_r <= c_tx_xclk1_addr;
    C_XD_WR_XCLK1_TXOUT:  xd_addr_r <= c_tx_xclk1_addr;
    default:              xd_addr_r <= c_tx_xclk0_addr;
  endcase
end
always @(posedge DCLK)
  xd_drp_done <= GT_DRDY & (db_state==C_XD_DRP_OP);
assign xd_fsm_rdy = ~(xd_state == C_XD_RESET);
always @(posedge DCLK)
begin
  if (reset_dclk_r[0])
    start_drp_r <= 1'b0; 
  else if (start_drp)
    start_drp_r <= 1'b1;
  else  
    start_drp_r <= 1'b0; 
end
always @(posedge DCLK)
    start_drp_r2 <= start_drp_r;
assign start_drp_done = (xd_state == C_XD_WAIT);
always @(posedge DCLK)
begin
  if (reset_dclk_r[0])
    revert_drp_r <= 1'b0; 
  else if (revert_drp)
    revert_drp_r <= 1'b1;
  else  
    revert_drp_r <= 1'b0; 
end
always @(posedge DCLK)
    revert_drp_r2 <= revert_drp_r;
assign revert_drp_done = (xd_state == C_XD_DONE);
always @(posedge DCLK)
begin
  if (reset_dclk_r[0])
    xd_state <= C_XD_RESET;
  else
    xd_state <= xd_next_state;
end
always @*
begin
  case (xd_state)
    C_XD_RESET: begin
      xd_next_state <= C_XD_IDLE;
      xd_fsm_name = "C_XD_RESET";
    end
    C_XD_IDLE: begin
      if (start_drp_r2)
        xd_next_state <= C_XD_RD_XCLK0_TXUSR;
      else
        xd_next_state <= C_XD_IDLE;
      xd_fsm_name = "C_XD_IDLE";
    end
    C_XD_RD_XCLK0_TXUSR: begin
      xd_next_state <= xd_drp_done ? C_XD_MD_XCLK0_TXUSR :
                                     C_XD_RD_XCLK0_TXUSR;
      xd_fsm_name = "C_XD_RD_XCLK0_TXUSR";
    end
    C_XD_MD_XCLK0_TXUSR: begin
      xd_next_state <= C_XD_WR_XCLK0_TXUSR;
      xd_fsm_name = "C_XD_MD_XCLK0_TXUSR";
    end
    C_XD_WR_XCLK0_TXUSR: begin
      xd_next_state <= xd_drp_done ? C_XD_RD_XCLK1_TXUSR : C_XD_WR_XCLK0_TXUSR;
      xd_fsm_name = "C_XD_WR_XCLK0_TXUSR";
    end
    C_XD_RD_XCLK1_TXUSR: begin
      xd_next_state <= xd_drp_done ? C_XD_MD_XCLK1_TXUSR : C_XD_RD_XCLK1_TXUSR;
      xd_fsm_name = "C_XD_RD_XCLK1_TXUSR";
    end
    C_XD_MD_XCLK1_TXUSR: begin
      xd_next_state <= C_XD_WR_XCLK1_TXUSR;
      xd_fsm_name = "C_XD_MD_XCLK1_TXUSR";
    end
    C_XD_WR_XCLK1_TXUSR: begin
      xd_next_state <= xd_drp_done ? C_XD_WAIT: C_XD_WR_XCLK1_TXUSR;
      xd_fsm_name = "C_XD_WR_XCLK1_TXUSR";
    end
    C_XD_WAIT: begin
      xd_next_state <= revert_drp_r2 ? C_XD_RD_XCLK0_TXOUT : C_XD_WAIT;
      xd_fsm_name = "C_XD_WAIT";
    end
    C_XD_RD_XCLK0_TXOUT: begin
      xd_next_state <= xd_drp_done ?
                        C_XD_MD_XCLK0_TXOUT : C_XD_RD_XCLK0_TXOUT;
      xd_fsm_name = "C_XD_RD_XCLK0_TXOUT";
    end
    C_XD_MD_XCLK0_TXOUT: begin
      xd_next_state <= C_XD_WR_XCLK0_TXOUT;
      xd_fsm_name = "C_XD_MD_XCLK0_TXOUT";
    end
    C_XD_WR_XCLK0_TXOUT: begin
      xd_next_state <= xd_drp_done ? C_XD_RD_XCLK1_TXOUT : C_XD_WR_XCLK0_TXOUT;
      xd_fsm_name = "C_XD_WR_XCLK0_TXOUT";
    end
    C_XD_RD_XCLK1_TXOUT: begin
      xd_next_state <= xd_drp_done ? C_XD_MD_XCLK1_TXOUT : C_XD_RD_XCLK1_TXOUT;
      xd_fsm_name = "C_XD_RD_XCLK1_TXOUT";
    end
    C_XD_MD_XCLK1_TXOUT: begin
      xd_next_state <= C_XD_WR_XCLK1_TXOUT;
      xd_fsm_name = "C_XD_MD_XCLK1_TXOUT";
    end
    C_XD_WR_XCLK1_TXOUT: begin
      xd_next_state <= xd_drp_done ? C_XD_DONE : C_XD_WR_XCLK1_TXOUT;
      xd_fsm_name = "C_XD_WR_XCLK1_TXOUT";
    end
    C_XD_DONE: begin
      xd_next_state <= ~revert_drp_r2 ? C_XD_IDLE : C_XD_DONE;
      xd_fsm_name = "C_XD_DONE";
    end
    default: begin
      xd_next_state <= C_XD_IDLE;
      xd_fsm_name = "default";
    end
  endcase
end
assign drp_rd = ((db_state == C_XD_DRP_OP) & xd_read) |
                ((db_state == C_USER_DRP_OP) & ~user_dwe_r); 
assign drp_wr = ((db_state == C_XD_DRP_OP) & xd_write) |
                ((db_state == C_USER_DRP_OP) & user_dwe_r);
assign drp_fsm_rdy = ~(drp_state == C_DRP_RESET);
always @(posedge DCLK)
begin
  if (reset_dclk_r[0])
    drp_state <= C_DRP_RESET;
  else
    drp_state <= drp_next_state;
end
always @*
begin
  case (drp_state)
    C_DRP_RESET: begin
      drp_next_state <= C_DRP_IDLE;
      drp_fsm_name = "C_DRP_RESET";
    end 
    C_DRP_IDLE: begin
      drp_next_state <= drp_wr ? C_DRP_WRITE : (drp_rd?C_DRP_READ:C_DRP_IDLE);
      drp_fsm_name = "C_DRP_IDLE";
    end
    C_DRP_READ: begin
      drp_next_state <= C_DRP_WAIT;
      drp_fsm_name = "C_DRP_READ";
    end
    C_DRP_WRITE: begin
      drp_next_state <= C_DRP_WAIT;
      drp_fsm_name = "C_DRP_WRITE";
    end
    C_DRP_WAIT: begin
      drp_next_state <= gt_drdy_r ? C_DRP_COMPLETE : C_DRP_WAIT;
      drp_fsm_name = "C_DRP_WAIT";
    end
    C_DRP_COMPLETE: begin
      drp_next_state <= C_DRP_IDLE;
      drp_fsm_name = "C_DRP_COMPLETE";
    end
    default: begin
      drp_next_state <= C_DRP_IDLE;
      drp_fsm_name = "default";
    end
  endcase
end
endmodule
