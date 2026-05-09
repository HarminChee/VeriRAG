module rfid_reader_rx (
                     reset, clk, tag_backscatter,
                     rx_done, rx_timeout,
                     miller, trext, divide_ratio,
                     rtcal_counts, trcal_counts, tari_counts,
                     rx_data, rx_dataidx
                     );
input  reset, clk, tag_backscatter;
output rx_done, rx_timeout;
input [2:0] miller;
input trext;
input divide_ratio;
input [15:0] tari_counts;
input [15:0] rtcal_counts;
input [15:0] trcal_counts;
output [1023:0] rx_data;
output [9:0]    rx_dataidx;
reg [1023:0] rx_data;
reg [9:0]    rx_dataidx;
reg rx_done;
reg [15:0]  rx_period;
reg [15:0]  rx_counter;
assign rx_timeout = (rx_counter > rtcal_counts<<2);
reg previousbit;
reg edgeclk;
reg [15:0] count;
always @ (posedge clk or posedge reset) begin
  if (reset) begin
    previousbit <= 0;
    edgeclk     <= 0;
    count       <= 0;
    rx_counter  <= 0;
  end else begin
    if (tag_backscatter != previousbit) begin
      edgeclk     <= 1;
      previousbit <= tag_backscatter;
      count       <= 0;
    end else begin
      edgeclk    <= 0;
      count      <= count + 1;
      rx_counter <= count + 1; // Assign based on updated count
    end
  end
end
reg [4:0] rx_state;
parameter STATE_CLK_UP   = 0;
parameter STATE_CLK_DN   = 1;
parameter STATE_PREAMBLE = 2;
parameter STATE_DATA1    = 3;
parameter STATE_DATA2    = 4;
parameter STATE_DATA3    = 5; // Unused states?
parameter STATE_DATA4    = 6; // Unused states?
parameter STATE_DATA5    = 7; // Unused states?
parameter STATE_DATA6    = 8; // Unused states?
parameter STATE_DATA7    = 9; // Unused states?
parameter STATE_DATA8    = 10;// Unused states?
wire isfm0, ism2, ism4, ism8;
assign isfm0 = (miller == 0);
assign ism2  = (miller == 1);
assign ism4  = (miller == 2);
assign ism8  = (miller == 3);
wire count_lessthan_period;
// Use count directly, as rx_counter reflects count+1 from the *next* cycle
assign count_lessthan_period = (count <= rx_period);
wire fm0_preamble_done;
// Preamble check should use the value of rx_dataidx *before* potential increment
assign fm0_preamble_done = (rx_dataidx >= 5);
wire [15:0] rx_counter_by2;
// Use count directly for period calculation as it reflects the duration ending at the edge
assign rx_counter_by2 = count >> 1;
// Changed clock from edgeclk to clk, added edgeclk as enable
always @ (posedge clk or posedge reset) begin
  if (reset) begin
    rx_state   <= STATE_CLK_UP; // Initialize state machine
    rx_dataidx <= 0;
    rx_data    <= 0;
    rx_period  <= 0; // Reset rx_period
    rx_done    <= 0; // Reset rx_done
  end else begin
    if (edgeclk) begin // Only update state machine logic on detected edges
      case(rx_state)
        STATE_CLK_UP: begin
          // First edge detected after reset or previous sequence
          rx_state   <= STATE_CLK_DN;
          rx_dataidx <= 0; // Reset for new sequence
          rx_data    <= 0; // Reset for new sequence
          rx_done    <= 0; // Sequence not done yet
        end
        STATE_CLK_DN: begin
          // Second edge, establish period
          if(isfm0 & ~trext) rx_period <= rx_counter_by2; // Use count captured at the edge
          else               rx_period <= count;         // Use count captured at the edge
          rx_state <= STATE_PREAMBLE;
        end
        STATE_PREAMBLE: begin
          if(isfm0) begin // Assuming only FM0 needs preamble skipping
            if( fm0_preamble_done ) begin
              rx_state    <= STATE_DATA1;
              rx_dataidx  <= 0; // Reset index for actual data start
            end else begin
              // Still in preamble, increment index but don't store data
              rx_dataidx  <= rx_dataidx + 1;
            end
          end else begin // For Miller modes, assume first edge after CLK_DN starts data
              rx_state <= STATE_DATA1;
              // Need to store first data bit based on period?
              // Let's assume STATE_DATA1 handles the first bit storage correctly based on count.
              // We need rx_dataidx to be 0 here. It was set in STATE_CLK_UP.
              if( count_lessthan_period ) begin // Check period for first bit
                 rx_data[0] <= 0;
              end else begin
                 rx_data[0] <= 1;
              end
              rx_dataidx <= 1; // First bit stored at index 0, next is index 1
          end
        end
        STATE_DATA1: begin
          // Entering state means an edge occurred. Check duration (count) against period.
          if( count_lessthan_period ) begin // Symbol 0
            rx_data[rx_dataidx] <= 0;
            rx_dataidx          <= rx_dataidx + 1;
            if(isfm0) begin
                rx_state <= STATE_DATA2; // FM0 has a mid-symbol edge for 0
            end else begin
                rx_state <= STATE_DATA1; // Miller stays in DATA1 after 0
            end
          end else begin // Symbol 1
            rx_data[rx_dataidx] <= 1;
            rx_dataidx          <= rx_dataidx + 1;
            rx_state <= STATE_DATA1; // Both FM0 and Miller stay in DATA1 after 1
          end
          // Check for rx buffer full?
          if (rx_dataidx == 1023) begin
             rx_done <= 1; // Indicate completion (or overflow)
             rx_state <= STATE_CLK_UP; // Go idle
          end
        end
        STATE_DATA2: begin // Only reached for FM0 Symbol 0 mid-period edge
          // This edge confirms the second half of symbol 0. No data stored.
          rx_state <= STATE_DATA1; // Go back to wait for the start of the next symbol
        end
        // Consider adding handling for rx_timeout condition to abort and set rx_done/error flag?
        default begin
          rx_state <= STATE_CLK_UP; // Go to initial state
        end
      endcase
    end else if (rx_timeout && rx_state != STATE_CLK_UP) begin // Check timeout only if not idle and no edge
        rx_done <= 1; // Indicate sequence ended due to timeout
        rx_state <= STATE_CLK_UP; // Go idle
    end
  end
end
// rx_done should probably be assigned based on detecting end-of-packet or timeout/overflow.
// Simplified rx_done logic above needs refinement based on actual protocol end condition.
endmodule