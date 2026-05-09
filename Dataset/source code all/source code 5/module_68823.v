module altpcie_pclk_align
(
rst,
clock,
offset,
onestep,
onestep_dir,
PCLK_Master,
PCLK_Slave,
PhaseUpDown,
PhaseStep,
PhaseDone,
AlignLock,
pcie_sw_in,
pcie_sw_out
);
input rst;
input clock;
input [7:0] offset;
input 	    onestep;
input 	    onestep_dir;
input PCLK_Master;
input PCLK_Slave;
input PhaseDone;
output PhaseUpDown;
output PhaseStep;
output AlignLock;
input  pcie_sw_in;
output pcie_sw_out;
reg    PhaseUpDown;
reg    PhaseStep;
reg    AlignLock;
localparam DREG_SIZE = 16;
localparam BIAS_ONE = 1;
reg [3:0] align_sm;
localparam INIT = 0;
localparam EVAL = 1;
localparam ADVC = 2;
localparam DELY = 3;
localparam BACK = 4;
localparam ERR = 5;
localparam DONE = 6;
localparam MNUL = 7;
reg [4 * 8 -1 :0] align_sm_txt;
always@(align_sm)
  case(align_sm)
  INIT: align_sm_txt = "init";
  EVAL: align_sm_txt = "eval";
  ADVC: align_sm_txt = "advc";
  DELY: align_sm_txt = "dely";
  BACK: align_sm_txt = "back";
  ERR: align_sm_txt = "err";
  DONE: align_sm_txt = "done";
  MNUL: align_sm_txt = "mnul";
  endcase
reg [DREG_SIZE-1: 0] delay_reg;
integer 	     i;
reg 		     all_zero;
reg 		     all_one;
reg 		     chk_req;
wire 		     chk_ack;
reg [4:0] 	     chk_cnt;
reg 		     chk_ack_r;
reg 		     chk_ack_rr;
reg 		     chk_ok;
reg 		     found_zero; 
reg 		     found_meta; 
reg 		     found_one; 
reg [7:0] 	     window_cnt; 
reg 		     clr_window_cnt;
reg 		     inc_window_cnt;
reg 		     dec_window_cnt;
reg 		     half_window_cnt;
reg [1:0]	     retrain_cnt;
reg 		     pcie_sw_r;
reg 		     pcie_sw_rr;
reg 		     pcie_sw_out;
assign 		     chk_ack = chk_cnt[4];
always @ (posedge PCLK_Master or posedge rst)
  begin
  if (rst)
    begin
    delay_reg <= {DREG_SIZE{1'b0}};
    all_zero <= 1'b1;
    all_one <= 1'b0;
    chk_cnt <= 0;
    end
  else
    begin
    delay_reg[0] <= PCLK_Slave;
    for (i = 1; i < DREG_SIZE; i = i + 1)
      delay_reg[i] <= delay_reg[i-1];
    if (chk_cnt == 5'h10)
      begin
      all_zero <= ~|delay_reg[DREG_SIZE-1:2];
      all_one <= &delay_reg[DREG_SIZE-1:2];
      end
    if (chk_req & (chk_cnt == 5'h1f))
      chk_cnt <= 0;
    else if (chk_cnt == 5'h1f)
      chk_cnt <= chk_cnt;
    else
      chk_cnt <= chk_cnt + 1;
    end
  end
always @ (posedge clock or posedge rst)
  begin
  if (rst)
    begin
    align_sm <= INIT;
    chk_req <= 0;
    chk_ack_r <= 0;
    chk_ack_rr <= 0;
    chk_ok <= 0;
    found_zero <= 0;
    found_meta <= 0;
    found_one <= 0;
    PhaseUpDown <= 0;
    PhaseStep <= 0;
    window_cnt <= 8'h00;
    clr_window_cnt <= 0;
    inc_window_cnt <= 0;
    dec_window_cnt <= 0;
    half_window_cnt <= 0;
    AlignLock <= 0;
    retrain_cnt <= 0;
    end
  else
    begin
    chk_ack_r <= chk_ack;
    chk_ack_rr <= chk_ack_r;
    if ((chk_ack_rr == 0) & (chk_ack_r == 1))
      chk_ok <= 1;
    else
      chk_ok <= 0;
    if (align_sm == DONE)
      AlignLock <= 1'b1;
    if (clr_window_cnt)
      window_cnt <= offset;
    else if (window_cnt == 8'hff)
      window_cnt <= window_cnt;
    else if (inc_window_cnt)
      window_cnt <=  window_cnt + 1;
    else if (dec_window_cnt & (window_cnt > 0))
      window_cnt <=  window_cnt - 1;
    else if (half_window_cnt)
      window_cnt <= {1'b0,window_cnt[7:1]};
    if (retrain_cnt == 2'b11)
      retrain_cnt <= retrain_cnt;
    else if (align_sm == ERR)
      retrain_cnt <= retrain_cnt + 1;
    case (align_sm)
    INIT:
      begin
      chk_req <= 1;
      align_sm <= EVAL;
      clr_window_cnt <= 1;
      end
    EVAL:
      if (chk_ok)
	begin
	chk_req <= 0;
	clr_window_cnt <= 0;
	casex ({found_zero,found_meta,found_one})
	3'b000 : 
	  begin
	  if (all_zero)
	    begin
	    found_zero <= 1;
	    PhaseUpDown <= 0;
	    PhaseStep <= 1;
	    align_sm <= ADVC;
	    end
	  else if (all_one)
	    begin
	    found_one <= 1;
	    PhaseUpDown <= 1;
	    PhaseStep <= 1;
	    align_sm <= DELY;
	    end
	  else
	    begin
	    found_meta <= 1;
	    PhaseUpDown <= 0;
	    PhaseStep <= 1;
	    align_sm <= ADVC;
	    end
	  end
	3'b010 : 
	  begin
	  if (all_zero)
	    begin
	    found_zero <= 1;
	    PhaseUpDown <= 0;
	    PhaseStep <= 1;
	    align_sm <= ADVC;
	    inc_window_cnt <= 1;
	    end
	  else
	    begin
	    PhaseUpDown <= 1;
	    PhaseStep <= 1;
	    align_sm <= DELY;
	    end
	  end
	3'b110 : 
	  begin
	  if (all_one)
	    begin
	    found_one <= 1;
	    PhaseStep <= 1;
	    align_sm <= BACK;
	    if (BIAS_ONE)
	      begin
	      clr_window_cnt <= 1;
	      PhaseUpDown <= 0;
	      end
	    else
	      begin
	      PhaseUpDown <= 1;
	      half_window_cnt <= 1;
	      end
	    end
	  else
	    begin
	    PhaseUpDown <= 0;
	    PhaseStep <= 1;
	    align_sm <= ADVC;
	    inc_window_cnt <= 1;
	    end
	  end
	3'b100 : 
	  begin
	  PhaseUpDown <= 0;
	  PhaseStep <= 1;
	  align_sm <= ADVC;
	  if (all_zero == 0) 
	    begin
	    found_meta <= 1;
	    inc_window_cnt <= 1;	    
	    end
	  end
	3'b001 : 
	  begin
	  PhaseUpDown <= 1;
	  PhaseStep <= 1;
	  align_sm <= DELY;
	  if (all_one == 0) 
	    begin
	    found_meta <= 1;
	    inc_window_cnt <= 1;	    
	    end
	  end
	3'b011 : 
	  begin
	  if (all_zero)
	    begin
	    found_zero <= 1;
	    PhaseStep <= 1;
	    PhaseUpDown <= 0;
	    align_sm <= BACK;
	    if (BIAS_ONE == 0) 
	      half_window_cnt <= 1;
	    else
	      inc_window_cnt <= 1;
	    end
	  else
	    begin
	    PhaseUpDown <= 1;
	    PhaseStep <= 1;
	    align_sm <= DELY;
	    inc_window_cnt <= 1;
	    end
	  end
	3'b111 : 
	  begin
	  if (window_cnt > 0)
	    begin
	    PhaseStep <= 1;
	    align_sm <= BACK;
	    dec_window_cnt <= 1;
	    end
	  else
	    align_sm <= DONE;
	  end
	3'b101 : 
	  begin
	  align_sm <= ERR;
	  clr_window_cnt <= 1;
	  found_zero <= 0;
	  found_one <= 0;
	  found_meta <= 0;
	  end
	endcase
	end
    ADVC:
      begin
      inc_window_cnt <= 0;
      if (PhaseDone == 0)
	begin
	PhaseStep <= 0;
	chk_req <= 1;
	align_sm <= EVAL;
	end
      end
    DELY:
      begin
      inc_window_cnt <= 0;
      if (PhaseDone == 0)
	begin
	PhaseStep <= 0;
	chk_req <= 1;
	align_sm <= EVAL;
	end
      end
    BACK:
      begin
      half_window_cnt <= 0;
      dec_window_cnt <= 0;
      inc_window_cnt <= 0;
      clr_window_cnt <= 0;
      if (PhaseDone == 0)
	begin
	PhaseStep <= 0;
	chk_req <= 1;
	align_sm <= EVAL;
	end
      end
    DONE:
      begin
      if (onestep) 
	begin
	align_sm <= MNUL;
	PhaseStep <= 1;
	PhaseUpDown <= onestep_dir;
	end
      end
    MNUL:
      if (PhaseDone == 0)
	begin
	PhaseStep <= 0;
	align_sm <= DONE;
	end
    ERR:
      begin
      clr_window_cnt <= 0;
      align_sm <= INIT;
      end
    default:
      align_sm <= INIT;
    endcase
    end
  end
always @ (posedge PCLK_Master or posedge rst)
  begin
  if (rst)
    begin
    pcie_sw_r <= 0;
    pcie_sw_rr <= 0;
    pcie_sw_out <= 0;
    end
  else
    begin
    pcie_sw_r <= pcie_sw_in;
    pcie_sw_rr <= pcie_sw_r;
    pcie_sw_out <= pcie_sw_rr;
    end
  end
endmodule
