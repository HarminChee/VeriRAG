module uart_tx
#(
  parameter DATA_BITS                = 8,
  parameter STOP_BITS                = 1,
  parameter PARITY_MODE              = 1, 
  parameter BAUD_CLK_OVERSAMPLE_RATE = 16
)
(
  input  wire                 clk,            
  input  wire                 reset,          
  input  wire                 baud_clk_tick,  
  input  wire                 tx_start,       
  input  wire [DATA_BITS-1:0] tx_data,        
  output wire                 tx_done_tick,   
  output wire                 tx              
);
localparam [5:0] STOP_OVERSAMPLE_TICKS = STOP_BITS * BAUD_CLK_OVERSAMPLE_RATE;
localparam [4:0] S_IDLE   = 5'h01,
                 S_START  = 5'h02,
                 S_DATA   = 5'h04,
                 S_PARITY = 5'h08,
                 S_STOP   = 5'h10;
reg [4:0]           q_state, d_state;
reg [3:0]           q_baud_clk_tick_cnt, d_baud_clk_tick_cnt;
reg [DATA_BITS-1:0] q_data, d_data;
reg [2:0]           q_data_bit_idx, d_data_bit_idx;
reg                 q_parity_bit, d_parity_bit;
reg                 q_tx, d_tx;
reg                 q_tx_done_tick, d_tx_done_tick;
always @(posedge clk, posedge reset)
  begin
    if (reset)
      begin
        q_state             <= S_IDLE;
        q_baud_clk_tick_cnt <= 0;
        q_data              <= 0;
        q_data_bit_idx      <= 0;
        q_tx                <= 1'b1;
        q_tx_done_tick      <= 1'b0;
        q_parity_bit        <= 1'b0;
      end
    else
      begin
        q_state             <= d_state;
        q_baud_clk_tick_cnt <= d_baud_clk_tick_cnt;
        q_data              <= d_data;
        q_data_bit_idx      <= d_data_bit_idx;
        q_tx                <= d_tx;
        q_tx_done_tick      <= d_tx_done_tick;
        q_parity_bit        <= d_parity_bit;
      end
  end
always @*
  begin
    d_state             = q_state;
    d_data              = q_data;
    d_data_bit_idx      = q_data_bit_idx;
    d_parity_bit        = q_parity_bit;
    d_baud_clk_tick_cnt = (baud_clk_tick) ? (q_baud_clk_tick_cnt + 4'h1) : q_baud_clk_tick_cnt;
    d_tx_done_tick = 1'b0;
    d_tx           = 1'b1;
    case (q_state)
      S_IDLE:
        begin
          if (tx_start && ~q_tx_done_tick)
            begin
              d_state             = S_START;
              d_baud_clk_tick_cnt = 0;
              d_data              = tx_data;
              if (PARITY_MODE == 1)
                d_parity_bit = ~^tx_data;
              else if (PARITY_MODE == 2)
                d_parity_bit = ~tx_data;
            end
        end
      S_START:
        begin
          d_tx = 1'b0;
          if (baud_clk_tick && (q_baud_clk_tick_cnt == (BAUD_CLK_OVERSAMPLE_RATE - 1)))
            begin
              d_state             = S_DATA;
              d_baud_clk_tick_cnt = 0;
              d_data_bit_idx      = 0;
            end
        end
      S_DATA:
        begin
          d_tx = q_data[0];
          if (baud_clk_tick && (q_baud_clk_tick_cnt == (BAUD_CLK_OVERSAMPLE_RATE - 1)))
            begin
              d_data              = q_data >> 1;
              d_data_bit_idx      = q_data_bit_idx + 3'h1;
              d_baud_clk_tick_cnt = 0;
              if (q_data_bit_idx == (DATA_BITS - 1))
                begin
                  if (PARITY_MODE == 0)
                    d_state = S_STOP;
                  else
                    d_state = S_PARITY;
                end
            end
        end
      S_PARITY:
        begin
          d_tx = q_parity_bit;
          if (baud_clk_tick && (q_baud_clk_tick_cnt == (BAUD_CLK_OVERSAMPLE_RATE - 1)))
            begin
              d_state             = S_STOP;
              d_baud_clk_tick_cnt = 0;
            end
        end
      S_STOP:
        begin
          if (baud_clk_tick && (q_baud_clk_tick_cnt == (STOP_OVERSAMPLE_TICKS - 1)))
            begin
              d_state        = S_IDLE;
              d_tx_done_tick = 1'b1;
            end
        end
    endcase
end
assign tx           = q_tx;
assign tx_done_tick = q_tx_done_tick;
endmodule
