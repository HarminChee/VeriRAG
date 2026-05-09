module rfid_reader_rx_corrected_ffc ( // Renamed module
                     reset, clk, tag_backscatter,
                     rx_done, rx_timeout,
                     miller, trext, divide_ratio, // divide_ratio seems unused?
                     rtcal_counts, trcal_counts, tari_counts, // tari_counts, trcal_counts seem unused?
                     rx_data, rx_dataidx
                     );
input  reset, clk, tag_backscatter;
output reg rx_done; // Made reg as it's assigned in always block
output rx_timeout;
input [2:0] miller;
input trext;
input divide_ratio;
input [15:0] tari_counts;
input [15:0] rtcal_counts;
input [15:0] trcal_counts;
output reg [1023:0] rx_data;
output reg [9:0]    rx_dataidx;

// Internal registers
reg [15:0]  rx_period;
reg [15:0]  rx_counter;
reg previousbit;
reg [15:0] count;
reg edge_detected;     // Replaces edgeclk signal, synchronous to clk
reg [15:0] period_capture; // To capture count value at edge detection
reg [4:0] rx_state;

// State parameters
parameter STATE_CLK_UP   = 5'd0;
parameter STATE_CLK_DN   = 5'd1;
parameter STATE_PREAMBLE = 5'd2;
parameter STATE_DATA1    = 5'd3;
parameter STATE_DATA2    = 5'd4;
// Removed unused states STATE_DATA3 to STATE_DATA8 for clarity

// Wires for combinational logic
wire isfm0, ism2, ism4, ism8;
wire count_lessthan_period;
wire fm0_preamble_done;
wire [15:0] period_capture_by2; // Renamed from rx_counter_by2

// Assignments
assign rx_timeout = (rx_counter > rtcal_counts << 2); // Shift left by 2 is multiply by 4
assign isfm0 = (miller == 3'b000);
assign ism2  = (miller == 3'b001);
assign ism4  = (miller == 3'b010);
assign ism8  = (miller == 3'b011); // Assuming miller 3 means Miller-8

// Compare current counter value (time since last edge) with established period
assign count_lessthan_period = (rx_counter <= rx_period);

// Check if enough preamble edges detected (using original logic threshold)
assign fm0_preamble_done = (rx_dataidx >= 5);

// Calculate half of the captured period duration
assign period_capture_by2 = period_capture >> 1;


// First synchronous block: Edge detection and counters
// Detects changes in tag_backscatter, updates counters. All FFs clocked by clk.
always @ (posedge clk or posedge reset) begin
  if (reset) begin
    previousbit <= 1'b0;
    count       <= 16'b0;
    rx_counter  <= 16'b0;
    edge_detected <= 1'b0;
    period_capture <= 16'b0;
  end else begin
    edge_detected <= 1'b0; // Default to no edge this cycle
    if (tag_backscatter != previousbit) begin
      edge_detected <= 1'b1; // Signal edge detection for one clock cycle
      previousbit <= tag_backscatter;
      period_capture <= count + 1; // Capture duration since last edge
      count       <= 16'b0;     // Reset count for the next interval
      // rx_counter starts counting time since this new edge
      rx_counter  <= 16'd1;     // Start counter from 1 for the new interval's duration
    end else begin
      count      <= count + 1;
      rx_counter <= count + 1; // Continue counting since last edge
    end
  end
end

// Second synchronous block: State machine and data capture logic
// Updates state, captures data based on edge detection. All FFs clocked by clk.
always @ (posedge clk or posedge reset) begin
  if (reset) begin
    rx_state   <= STATE_CLK_UP;
    rx_dataidx <= 10'b0;
    rx_data    <= 1024'b0;
    rx_period  <= 16'b0;
    rx_done    <= 1'b0;
  end else begin
    // Reset rx_done when starting a new reception cycle triggered by an edge in CLK_UP state
    if (rx_state == STATE_CLK_UP && edge_detected) begin
        rx_done <= 1'b0;
    end

    // Process state transitions and actions only when an edge is detected by the first block
    if (edge_detected) begin
      case(rx_state)
        STATE_CLK_UP: begin
          // First edge detected, move to wait for the second edge
          rx_state   <= STATE_CLK_DN;
          rx_dataidx <= 10'b0; // Initialize index
          rx_data    <= 1024'b0; // Initialize data buffer
        end
        STATE_CLK_DN: begin
          // Second edge detected, calculate and store the base period
          if(isfm0 & ~trext) begin
            rx_period <= period_capture_by2; // Use half period for FM0 non-TRExt
          end else begin
            rx_period <= period_capture;     // Use full captured period otherwise
          end
          rx_state <= STATE_PREAMBLE; // Move to preamble state
        end
        STATE_PREAMBLE: begin
          // Edges detected during preamble phase
          if(isfm0) begin // FM0 specific preamble handling
            if( fm0_preamble_done ) begin // Check if preamble edge count is sufficient
              rx_state    <= STATE_DATA1; // Preamble complete, move to data state
              rx_dataidx  <= 10'b0;       // Reset index for actual data bits
            end else begin
              // Still in preamble, count the edge
              rx_dataidx  <= rx_dataidx + 1;
            end
          end else begin // Placeholder for other Miller modes preamble handling
             // Assuming preamble completion leads to DATA1 for now
             // This part might need specific logic based on Miller 2/4/8 standards
             rx_state <= STATE_DATA1;
             rx_dataidx <= 10'b0;
          end
        end
        STATE_DATA1: begin
          // Edge detected during data phase - determines bit value based on interval length
          if (rx_dataidx < 1024) begin // Check buffer bounds before writing
              if( count_lessthan_period ) begin // Short interval relative to rx_period
                  rx_data[rx_dataidx] <= 1'b0; // Decode as '0'
                  rx_dataidx <= rx_dataidx + 1;
                  // Original logic transitioned to DATA2 for both FM0 and others on short interval
                  rx_state <= STATE_DATA2;
              end else begin // Long interval relative to rx_period
                  rx_data[rx_dataidx] <= 1'b1; // Decode as '1'
                  rx_dataidx <= rx_dataidx + 1;
                  // Original logic stayed in DATA1 after a long interval
                  // rx_state <= STATE_DATA1; // No state change needed here
              end

              // Check if buffer is now full after incrementing index
              if (rx_dataidx == 1023) begin // If the incremented index is now max index + 1 (meaning buffer is full)
                  // This check might be off by one depending on interpretation.
                  // Let's assume writing to 1023 is the last valid write.
                  // So, if rx_dataidx *was* 1023 and is now incremented, we are done.
                  // Let's adjust the check:
                  // if (rx_dataidx == 1024) // Check if index goes out of bounds
                  // A simpler check: if the index *before* increment was 1023
                  // Let's revert to checking after increment, if index is now 1024 (meaning 0-1023 are filled)
                  // No, the index goes from 0 to 1023. So when idx becomes 1023+1 = 1024, we're done.
                  // The previous check was correct if rx_dataidx is the NEXT index to write.
                  // If rx_dataidx points to the location JUST WRITTEN, the check should be:
                  // if (rx_dataidx == 1024) // If we just wrote to 1023 and incremented
                  // Let's stick to the original intent: check if the *next* index would be out of bounds
                  // If current rx_dataidx (before potential increment) is 1023, the next write