module top_SRAM (
  input          CLOCK_50,
  input   [3:0]  KEY,
  input   [17:0] SW,
  output  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
  output  [7:0]  LEDG,
  output  [17:0] LEDR,
  inout   [35:0] GPIO,
  inout   [15:0] SRAM_DQ,
  output  [19:0] SRAM_ADDR,
  output         SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N
);

  parameter state_rst          = 4'd0;
  parameter state_idle         = 4'd1;
  parameter state_delay        = 4'd2;
  parameter state_check_block  = 4'd3;
  parameter state_start_send   = 4'd4;
  parameter state_cnt_increase = 4'd5;

  parameter AVAIL     = 21'b010000000000000000000;
  parameter AVAIL_DIV = AVAIL / 21'd18;

  wire clk;
  wire rst_n;
  wire locked;
  wire [7:0] sum_SW;
  wire [31:0] delay;
  wire SW_17_debounced;
  reg  fifo_block_read;
  wire pll_in_c0;
  wire pll_out_c0;
  wire dout;
  wire sck;
  wire ss;
  wire send_data;
  wire cc3200_flow_ctrl_n;
  wire fifo_busy;
  wire fifo_full;
  wire [31:0] din;
  reg  fifo_we;
  wire [31:0] fifo_debug;
  wire [21:0] available;
  wire [4:0]  number_data;
  reg  [31:0] delay_cnt;
  reg  [4:0]  data_cnt;
  wire [4:0]  data_cnt_plus_one;
  reg  [3:0]  current_state;
  reg  [3:0]  next_state;

  assign rst_n = KEY[0];
  assign data_cnt_plus_one = data_cnt + 1;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      delay_cnt <= 0;
      data_cnt <= 0;
    end else begin
      case (current_state)
        state_rst: begin
          delay_cnt <= 0;
          data_cnt <= 0;
        end
        state_idle: begin
          delay_cnt <= 0;
        end
        state_delay: begin
          if (delay_cnt < delay)
            delay_cnt <= delay_cnt + 1;
        end
        state_cnt_increase: begin
          delay_cnt <= delay_cnt;
          data_cnt  <= data_cnt_plus_one;
        end
        default: begin
          delay_cnt <= delay_cnt;
          data_cnt  <= data_cnt;
        end
      endcase
    end
  end

  always @(negedge clk or negedge rst_n) begin
    if (!rst_n)
      current_state <= state_rst;
    else
      current_state <= next_state;
  end

  always @(*) begin
    next_state = current_state;
    case (current_state)
      state_rst:
        if (!send_data)
          next_state = state_idle;

      state_idle:
        next_state = state_delay;

      state_delay:
        if (delay_cnt >= delay)
          next_state = state_check_block;

      state_check_block:
        if (!fifo_busy && !fifo_full)
          next_state = state_start_send;

      state_start_send:
        next_state = state_cnt_increase;

      state_cnt_increase:
        next_state = state_idle;

      default:
        next_state = state_rst;
    endcase
  end

endmodule
