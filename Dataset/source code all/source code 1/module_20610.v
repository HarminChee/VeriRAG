`timescale 1ps/1ps
`timescale 1ps/1ps
module pcie3_7x_0_pcie_init_ctrl_7vx # (
  parameter         TCQ = 100,
  parameter         PL_UPSTREAM_FACING = "TRUE"
) (
  input               clk_i,                   
  output              reset_n_o,               
  output              pipe_reset_n_o,          
  output              mgmt_reset_n_o,          
  output              mgmt_sticky_reset_n_o,   
  input               mmcm_lock_i,             
  input               phy_rdy_i,               
  input               cfg_input_update_done_i,    
  output              cfg_input_update_request_o, 
  input               cfg_mc_update_done_i,       
  output              cfg_mc_update_request_o,    
  input               user_cfg_input_update_i,    
  output  [2:0]       state_o                     
);
  localparam           STATE_RESET                 =  3'b000;
  localparam           STATE_MGMT_RESET_DEASSERT   =  3'b001;
  localparam           STATE_MC_TRANSFER_REQ       =  3'b010;
  localparam           STATE_INPUT_UPDATE_REQ      =  3'b011;
  localparam           STATE_PHY_RDY               =  3'b100;
  localparam           STATE_RESET_DEASSERT        =  3'b101;
  localparam           STATE_INPUT_UPDATE_REQ_REDO =  3'b110;
  localparam           STATE_MGMT_RESET_ASSERT     =  3'b111;
  reg  [2:0]          reg_state ;
  reg  [2:0]          reg_next_state;
  reg  [1:0]          reg_clock_locked;
  reg  [1:0]          reg_phy_rdy;
  reg                 reg_cold_reset = 1'b1 ;
  reg                 reg_reset_n_o;
  reg                 reg_pipe_reset_n_o;
  reg                 reg_mgmt_reset_n_o;
  reg                 reg_mgmt_sticky_reset_n_o;
  reg                 reg_cfg_input_update_request_o;
  reg                 reg_cfg_mc_update_request_o;
  reg  [1:0]          reg_reset_timer;
  reg  [4:0]          reg_mgmt_reset_timer;
  reg                 regff_mgmt_reset_n_o = 1'b0;
  reg                 regff_mgmt_sticky_reset_n_o = 1'b0;
  reg                 regff_reset_n_o = 1'b0;
  reg                 regff_pipe_reset_n_o = 1'b0;
  wire [2:0]          state_w;
  wire [2:0]          next_state_w;
  wire                clock_locked;
  wire                phy_rdy;
  wire                cold_reset;
  wire [1:0]          reset_timer_w;
  always @ (posedge clk_i or negedge mmcm_lock_i) begin
    if (!mmcm_lock_i) begin
      reg_clock_locked[1:0] <= #TCQ 2'b11;
    end else begin
      reg_clock_locked[1:0] <= #TCQ {reg_clock_locked[0], 1'b0};
    end
  end
  assign  clock_locked = !reg_clock_locked[1];
  always @ (posedge clk_i or negedge phy_rdy_i) begin
    if (!phy_rdy_i) begin
      reg_phy_rdy[1:0] <= #TCQ 2'b11;
    end else begin
      reg_phy_rdy[1:0] <= #TCQ {reg_phy_rdy[0], 1'b0};
    end
  end
  assign  phy_rdy = !reg_phy_rdy[1];
  always @ (posedge clk_i or negedge clock_locked) begin
    if (!clock_locked) begin
       reg_state <= #(TCQ) STATE_RESET;
       reg_reset_timer <= #(TCQ) 2'b00;
    end else begin
      reg_state <= #(TCQ) reg_next_state;
      if ((state_w == STATE_MGMT_RESET_DEASSERT) && (reset_timer_w != 2'b11))
        reg_reset_timer <= #(TCQ) reset_timer_w + 1'b1;
    end
  end
  always @ (posedge clk_i) begin
    if ((state_w == STATE_PHY_RDY) && (next_state_w == STATE_RESET_DEASSERT) && (cold_reset == 1'b1))
      reg_cold_reset <= #(TCQ) 1'b0;
  end
 always @ (posedge clk_i) begin 
    if (state_w == STATE_MGMT_RESET_ASSERT)
      reg_mgmt_reset_timer <= #(TCQ) reg_mgmt_reset_timer + 1'b1;
    else if (state_w == STATE_MGMT_RESET_DEASSERT)
      reg_mgmt_reset_timer <= #(TCQ) 5'h00;
    else
      reg_mgmt_reset_timer <= #(TCQ) reg_mgmt_reset_timer;
  end
generate 
 begin: generate_resets
  if( PL_UPSTREAM_FACING == "TRUE") 
  begin 
   always @ (*) begin
    reg_next_state = STATE_RESET;
    reg_mgmt_reset_n_o = 1'b1;
    reg_mgmt_sticky_reset_n_o = 1'b1;
    reg_cfg_input_update_request_o = 1'b0;
    reg_cfg_mc_update_request_o = 1'b0;
    reg_reset_n_o = 1'b0;
    reg_pipe_reset_n_o = 1'b0;
    case(state_w)
      STATE_RESET : begin
        reg_mgmt_reset_n_o = 1'b0;
        reg_mgmt_sticky_reset_n_o = 1'b0;
        if (clock_locked) begin
          reg_next_state = STATE_MGMT_RESET_DEASSERT;
        end else begin
          reg_next_state = STATE_RESET;
        end
      end
      STATE_MGMT_RESET_DEASSERT : begin
        if (reset_timer_w == 2'b11) begin
          reg_next_state = STATE_MC_TRANSFER_REQ;
        end else begin
          reg_next_state = STATE_MGMT_RESET_DEASSERT;
        end
      end
      STATE_MC_TRANSFER_REQ : begin
        reg_cfg_mc_update_request_o = 1'b1;
        if (cfg_mc_update_done_i) begin
          reg_next_state = STATE_INPUT_UPDATE_REQ;
        end else begin
          reg_next_state = STATE_MC_TRANSFER_REQ;
        end
      end
      STATE_INPUT_UPDATE_REQ : begin
        reg_cfg_input_update_request_o = 1'b1;
        if (cfg_input_update_done_i) begin
          reg_next_state = STATE_PHY_RDY;
        end else begin
          reg_next_state = STATE_INPUT_UPDATE_REQ;
        end
      end
      STATE_PHY_RDY : begin
        if (!cold_reset) begin
          reg_pipe_reset_n_o = 1'b1;
        end
        if (phy_rdy) begin
          reg_next_state = STATE_RESET_DEASSERT;
        end else begin
          reg_next_state = STATE_PHY_RDY;
        end
      end
      STATE_RESET_DEASSERT : begin
        reg_reset_n_o = 1'b1;
        reg_pipe_reset_n_o = 1'b1;
        if (!phy_rdy) begin
          reg_next_state = STATE_MGMT_RESET_ASSERT;
        end else if (user_cfg_input_update_i) begin
          reg_next_state = STATE_INPUT_UPDATE_REQ_REDO;
        end else begin
          reg_next_state = STATE_RESET_DEASSERT;
        end
      end
      STATE_INPUT_UPDATE_REQ_REDO : begin
        reg_reset_n_o = 1'b1;
        reg_pipe_reset_n_o = 1'b1;
        reg_cfg_input_update_request_o = 1'b1;
        if (cfg_input_update_done_i) begin
          reg_next_state = STATE_RESET_DEASSERT;
        end else begin
          reg_next_state = STATE_INPUT_UPDATE_REQ_REDO;
        end
      end
     STATE_MGMT_RESET_ASSERT : begin
        if (reg_mgmt_reset_timer == 5'h1f) begin
          reg_next_state = STATE_MGMT_RESET_DEASSERT;
          reg_mgmt_reset_n_o = 1'b1;
        end else begin
          reg_next_state = STATE_MGMT_RESET_ASSERT;
          reg_mgmt_reset_n_o = 1'b0;
        end
      end
    endcase
  end 
  end else  begin 
   always @ (*) begin
    reg_next_state = STATE_RESET;
    reg_mgmt_reset_n_o = 1'b1;
    reg_mgmt_sticky_reset_n_o = 1'b1;
    reg_cfg_input_update_request_o = 1'b0;
    reg_cfg_mc_update_request_o = 1'b0;
    reg_reset_n_o = 1'b0;
    reg_pipe_reset_n_o = 1'b0;
    case(state_w)
      STATE_RESET : begin
        reg_mgmt_reset_n_o = 1'b0;
        reg_mgmt_sticky_reset_n_o = 1'b0;
        if (clock_locked) begin
          reg_next_state = STATE_MGMT_RESET_DEASSERT;
        end else begin
          reg_next_state = STATE_RESET;
        end
      end
      STATE_MGMT_RESET_DEASSERT : begin
        if (reset_timer_w == 2'b11) begin
          reg_next_state = STATE_MC_TRANSFER_REQ;
        end else begin
          reg_next_state = STATE_MGMT_RESET_DEASSERT;
        end
      end
      STATE_MC_TRANSFER_REQ : begin
        reg_cfg_mc_update_request_o = 1'b1;
        if (cfg_mc_update_done_i) begin
          reg_next_state = STATE_INPUT_UPDATE_REQ;
        end else begin
          reg_next_state = STATE_MC_TRANSFER_REQ;
        end
      end
      STATE_INPUT_UPDATE_REQ : begin
        reg_cfg_input_update_request_o = 1'b1;
        if (cfg_input_update_done_i) begin
          reg_next_state = STATE_PHY_RDY;
        end else begin
          reg_next_state = STATE_INPUT_UPDATE_REQ;
        end
      end
      STATE_PHY_RDY : begin
        if (!cold_reset) begin
          reg_pipe_reset_n_o = 1'b1;
        end
        if (phy_rdy) begin
          reg_next_state = STATE_RESET_DEASSERT;
        end else begin
          reg_next_state = STATE_PHY_RDY;
        end
      end
      STATE_RESET_DEASSERT : begin
        reg_reset_n_o = 1'b1;
        reg_pipe_reset_n_o = 1'b1;
        if (!phy_rdy) begin
          reg_next_state = STATE_PHY_RDY;
        end else if (user_cfg_input_update_i) begin
          reg_next_state = STATE_INPUT_UPDATE_REQ_REDO;
        end else begin
          reg_next_state = STATE_RESET_DEASSERT;
        end
      end
      STATE_INPUT_UPDATE_REQ_REDO : begin
        reg_reset_n_o = 1'b1;
        reg_pipe_reset_n_o = 1'b1;
        reg_cfg_input_update_request_o = 1'b1;
        if (cfg_input_update_done_i) begin
          reg_next_state = STATE_RESET_DEASSERT;
        end else begin
          reg_next_state = STATE_INPUT_UPDATE_REQ_REDO;
        end
      end
    endcase
  end 
  end 
 end 
 endgenerate
  always @(posedge clk_i) begin
    regff_mgmt_reset_n_o        <= reg_mgmt_reset_n_o;
    regff_mgmt_sticky_reset_n_o <= reg_mgmt_sticky_reset_n_o;
    regff_pipe_reset_n_o        <= reg_pipe_reset_n_o;
    regff_reset_n_o             <= reg_reset_n_o;
  end
  assign state_w                    = reg_state;
  assign next_state_w               = reg_next_state;
  assign reset_n_o                  = regff_reset_n_o;
  assign pipe_reset_n_o             = regff_pipe_reset_n_o;
  assign mgmt_reset_n_o             = regff_mgmt_reset_n_o;
  assign mgmt_sticky_reset_n_o      = regff_mgmt_sticky_reset_n_o;
  assign cfg_input_update_request_o = reg_cfg_input_update_request_o;
  assign cfg_mc_update_request_o    = reg_cfg_mc_update_request_o;
  assign cold_reset                 = reg_cold_reset;
  assign state_o                    = reg_state;
  assign reset_timer_w              = reg_reset_timer;
endmodule 
