module hc_core (
                input wire           clk,
                input wire           reset_n,
                input wire           init,
                input wire           next,
                output wire          ready,
                input wire [255 : 0] iv,
                input wire [255 : 0] key,
                input wire           keylen,
                output wire [31 : 0] result,
                output wire          result_valid
               );
  localparam CTRL_IDLE = 3'h0;
  function [31 : 0] f1 (input [31 : 0] x);
    begin
      f1 = {x[6 : 0], x[31 : 7]} ^ {x[17 : 0], x[31 : 18]} ^ {x[2 : 0], x[31 : 3]};
    end
  endfunction 
  function [31 : 0] f2 (input [31 : 0] x);
    begin
      f2 = {x[16 : 0], x[31 : 17]} ^ {x[18 : 0], x[31 : 19]} ^ {x[9 : 0], x[31 : 10]};
    end
  endfunction 
  reg [31 : 0] P [0 : 511];
  reg [31 : 0] P_new;
  reg  [8 : 0] P_addr;
  reg          P_we;
  reg [31 : 0] Q [0 : 511];
  reg [31 : 0] Q_new;
  reg  [8 : 0] Q_addr;
  reg          Q_we;
  reg [31 : 0] s_reg;
  reg [31 : 0] s_new;
  reg          s_we;
  reg          update_s;
  reg          s_valid_reg;
  reg          s_valid_new;
  reg          s_valid_we;
  reg [9 : 0]  i_ctr_reg;
  reg [9 : 0]  i_ctr_new;
  reg          i_ctr_inc;
  reg          i_ctr_rst;
  reg          i_ctr_we;
  reg [2 : 0]  hc_core_ctrl_reg;
  reg [2 : 0]  hc_core_ctrl_new;
  reg          hc_core_ctrl_we;
  reg update_state;
  reg init_mode;
  assign result       = s_reg;
  assign result_valid = s_valid_reg;
  always @ (posedge clk or negedge reset_n)
    begin : reg_update
      if (!reset_n)
        begin
          i_ctr_reg   <= 10'h0;
          s_reg       <= 32'h0;
          s_valid_reg <= 0;
        end
      else
        begin
          if (i_ctr_we)
            i_ctr_reg <= i_ctr_new;
          if (P_we)
            P[P_addr] <= P_new;
          if (Q_we)
            Q[Q_addr] <= Q_new;
          if (s_we)
            s_reg <= s_new;
          if (s_valid_we)
            s_valid_reg <= s_valid_new;
        end
    end
  always @*
    begin : state_update
    end 
  always @*
    begin : s_generate
      reg  [8 : 0] j_000;
      reg  [8 : 0] j_012;
      reg [31 : 0] P_000;
      reg [31 : 0] P_012;
      reg [31 : 0] Q_000;
      reg [31 : 0] Q_012;
    end
  always @*
    begin : i_ctr
      i_ctr_new = 10'h0;
      i_ctr_we  = 0;
      if (i_ctr_rst)
          i_ctr_we  = 1;
      if (i_ctr_inc)
        begin
          i_ctr_new = i_ctr_reg + 1'b1;
          i_ctr_we  = 1;
        end
    end
  always @*
    begin : hc_ctrl
      update_s         = 0;
      update_state     = 0;
      init_mode        = 0;
      i_ctr_rst        = 0;
      i_ctr_inc        = 0;
      s_valid_new      = 0;
      s_valid_we       = 0;
      hc_core_ctrl_new = CTRL_IDLE;
      hc_core_ctrl_we  = 0;
      case (hc_core_ctrl_reg)
        CTRL_IDLE:
          begin
          end
        default:
          begin
          end
      endcase 
    end
endmodule 
