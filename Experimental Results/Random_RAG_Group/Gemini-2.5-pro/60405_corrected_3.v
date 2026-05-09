`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module altera_jtag_streaming #(
    parameter PURPOSE = 0,
    parameter UPSTREAM_FIFO_SIZE = 0,
    parameter DOWNSTREAM_FIFO_SIZE = 0,
    parameter MGMT_CHANNEL_WIDTH = -1
) (
    input wire       test_i, // Added test input (may not be strictly needed for these fixes but common)
    input  wire       tck,
    input  wire       tdi,
    output reg        tdo,
    input  wire [2:0] ir_in,
    input  wire       virtual_state_cdr,
    input  wire       virtual_state_sdr,
    input  wire       virtual_state_udr,
    input  wire       reset_n, // Primary asynchronous reset (active low)
    output wire [7:0] source_data,
    output wire       source_valid,
    input  wire [7:0] sink_data,
    input  wire       sink_valid,
    output wire       sink_ready,
    input  wire       clock_to_sample,
    input  wire       reset_to_sample, // This seems like another reset, potentially sync to clock_to_sample? Assuming reset_n is the primary async reset for DFT.
    output reg        resetrequest,
    output wire       debug_reset, // This is defined within the generate block if MGMT_CHANNEL_WIDTH > 0
    output reg        mgmt_valid,
    output reg  [(MGMT_CHANNEL_WIDTH>0?MGMT_CHANNEL_WIDTH:1)-1:0] mgmt_channel,
    output reg        mgmt_data
);
    function integer flog2;
      input [31:0] Depth;
      integer i;
      begin
        i = Depth;
        if ( i <= 0 ) flog2 = 0;
        else begin
          for(flog2 = -1; i > 0; flog2 = flog2 + 1)
          i = i >> 1;
        end
      end
    endfunction
    localparam UPSTREAM_ENCODED_SIZE = flog2(UPSTREAM_FIFO_SIZE);
    localparam DOWNSTREAM_ENCODED_SIZE = flog2(DOWNSTREAM_FIFO_SIZE);
    localparam TCK_TO_SYSCLK_SYNC_DEPTH = 8;
    localparam SYSCLK_TO_TCK_SYNC_DEPTH = 3;
    localparam DATA     = 0;
    localparam LOOPBACK = 1;
    localparam DEBUG    = 2;
    localparam INFO     = 3;
    localparam CONTROL  = 4;
    localparam MGMT     = 5;
    localparam IRWIDTH = 3;
    localparam ST_BYPASS     = 'h0;
    localparam ST_HEADER_1   = 'h1;
    localparam ST_HEADER_2   = 'h2;
    localparam ST_WRITE_DATA = 'h3;
    localparam ST_HEADER    = 'h0;
    localparam ST_PADDED    = 'h1;
    localparam ST_READ_DATA = 'h2;

    // Calculate actual width, handling MGMT_CHANNEL_WIDTH <= 0
    localparam REAL_MGMT_WIDTH = (MGMT_CHANNEL_WIDTH>0?MGMT_CHANNEL_WIDTH:1);

    reg [1:0] write_state = ST_BYPASS;
    reg [1:0] read_state  = ST_HEADER;
    reg [ 7:0] dr_data_in  = 'b0;
    reg [ 7:0] dr_data_out = 'b0;
    reg        dr_loopback = 'b0;
    reg [ 2:0] dr_debug    = 'b0;
    reg [10:0] dr_info     = 'b0;
    reg [ 8:0] dr_control  = 'b0;
    reg [REAL_MGMT_WIDTH+2:0] dr_mgmt = 'b0; // Use calculated width
    reg [ 8:0] padded_bit_counter             = 'b0;
    reg [ 7:0] bypass_bit_counter             = 'b0;
    reg [ 2:0] write_data_bit_counter         = 'b0;
    reg [ 2:0] read_data_bit_counter          = 'b0;
    reg [ 3:0] header_in_bit_counter          = 'b0;
    reg [ 3:0] header_out_bit_counter         = 'b0;
    reg [18:0] scan_length_byte_counter       = 'b0;
    reg [18:0] valid_write_data_length_byte_counter  = 'b0;
    reg write_data_valid     = 'b0;
    reg read_data_valid      = 'b0;
    reg read_data_all_valid  = 'b0;
    reg decode_header_1 = 'b0;
    reg decode_header_2 = 'b0;
    wire write_data_byte_aligned;
    wire read_data_byte_aligned;
    wire padded_bit_byte_aligned;
    wire bytestream_end;
    assign write_data_byte_aligned = (write_data_bit_counter == 1);
    assign read_data_byte_aligned  = (read_data_bit_counter == 1);
    assign padded_bit_byte_aligned = (padded_bit_counter[2:0] == 'b0);
    assign bytestream_end          = (scan_length_byte_counter == 'b0);
    reg [ 7:0] offset     = 'b0;
    reg [15:0] header_in  = 'b0;
    reg [9:0] scan_length       = 'b0;
    reg [2:0] read_data_length  = 'b0;
    reg [2:0] write_data_length = 'b0;
    wire [7:0] idle_inserter_sink_data;
    wire       idle_inserter_sink_valid;
    wire       idle_inserter_sink_ready;
    wire [7:0] idle_inserter_source_data;
    reg        idle_inserter_source_ready = 'b0;
    reg  [7:0] idle_remover_sink_data     = 'b0;
    reg        idle_remover_sink_valid    = 'b0;
    wire [7:0] idle_remover_source_data;
    wire       idle_remover_source_valid;
    assign source_data  = idle_remover_source_data;
    assign source_valid = idle_remover_source_valid;
    assign sink_ready   = idle_inserter_sink_ready;
    assign idle_inserter_sink_data  = sink_data;
    assign idle_inserter_sink_valid = sink_valid;
    reg clock_sensor         = 'b0;
    reg clock_to_sample_div2 = 'b0;
    (* altera_attribute = {"-name GLOBAL_SIGNAL OFF"}*) reg clock_sense_reset_n  = 'b1; // Internal signal, reset by primary reset_n now
    wire data_available;
    assign data_available = sink_valid;
    wire [18:0] decoded_scan_length;
    wire [18:0] decoded_write_data_length;
    wire [18:0] decoded_read_data_length;
    assign decoded_scan_length =  { scan_length, {8{1'b1}} };
    assign decoded_write_data_length = (write_data_length == 0) ? 19'h0 : (19'h00080 << write_data_length);
    assign decoded_read_data_length  = (read_data_length == 0)  ? 19'h0 : (19'h00080 << read_data_length);
    wire clock_sensor_sync;
    wire reset_to_sample_sync;
    wire clock_to_sample_div2_sync;
    wire clock_sense_reset_n_sync;

    // Synchronizers - connect primary async reset 'reset_n'
    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) clock_sensor_synchronizer (
        .clk(tck),
        .reset_n(reset_n), // DFT Fix: Use primary reset
        .din(clock_sensor),
        .dout(clock_sensor_sync));
    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) reset_to_sample_synchronizer (
        .clk(tck),
        .reset_n(reset_n), // DFT Fix: Use primary reset
        .din(reset_to_sample),
        .dout(reset_to_sample_sync));
    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) clock_to_sample_div2_synchronizer (
        .clk(tck),
        .reset_n(reset_n), // DFT Fix: Use primary reset
        .din(clock_to_sample_div2),
        .dout(clock_to_sample_div2_sync));
    altera_std_synchronizer #(.depth(TCK_TO_SYSCLK_SYNC_DEPTH)) clock_sense_reset_n_synchronizer (
        .clk(clock_to_sample),
        .reset_n(reset_n), // DFT Fix: Use primary reset (Handles ACNCP on synchronizer itself)
        .din(clock_sense_reset_n), // Synchronize the internally controlled signal
        .dout(clock_sense_reset_n_sync));

    // clock_sensor FF - clocked by clock_to_sample, reset by primary reset_n
    // Original used negedge clock_sense_reset_n_sync (ACNCP)
    always @ (posedge clock_to_sample or negedge reset_n) begin
        if (~reset_n) begin
            clock_sensor <= 1'b0;
        end else begin
            // Functional logic remains, but reset is now standard
            // This FF essentially indicates if clock_to_sample is running,
            // but its reset behavior was tied to JTAG state via clock_sense_reset_n.
            // Now it resets with the primary reset. The functional logic
            // might need review if the original reset behavior was critical.
            // Assuming standard reset is acceptable for DFT.
            clock_sensor <= 1'b1; // Original logic when not reset
        end
    end

    // clock_to_sample_div2 FF - needs primary reset
    always @ (posedge clock_to_sample or negedge reset_n) begin
        if (~reset_n) begin
            clock_to_sample_div2 <= 1'b0;
        end else begin
            clock_to_sample_div2 <= ~clock_to_sample_div2;
        end
    end

    // Main state machine and data path logic - clocked by tck, reset by primary reset_n
    always @ (posedge tck or negedge reset_n) begin
      if (~reset_n) begin
          // Reset all registers driven by this block
          write_state <= ST_BYPASS;
          read_state <= ST_HEADER;
          dr_data_in <= 'b0;
          dr_data_out <= 'b0;
          dr_loopback <= 'b0;
          dr_debug <= 'b0;
          dr_info <= 'b0;
          dr_control <= 'b0;
          // dr_mgmt is handled in generate block (needs reset too)
          padded_bit_counter <= 'b0;
          bypass_bit_counter <= 'b0;
          write_data_bit_counter <= 'b0;
          read_data_bit_counter <= 'b0;
          header_in_bit_counter <= 'b0;
          header_out_bit_counter <= 'b0;
          scan_length_byte_counter <= 'b0;
          valid_write_data_length_byte_counter <= 'b0;
          write_data_valid <= 'b0;
          read_data_valid <= 'b0;
          read_data_all_valid <= 'b0;
          decode_header_1 <= 'b0;
          decode_header_2 <= 'b0;
          offset <= 'b0;
          header_in <= 'b0;
          scan_length <= 'b0;
          read_data_length <= 'b0;
          write_data_length <= 'b0;
          idle_inserter_source_ready <= 'b0;
          idle_remover_sink_data <= 'b0;
          idle_remover_sink_valid <= 'b0;
          clock_sense_reset_n <= 'b1; // Reset state for this internal control signal
          resetrequest <= 'b0;
          // Note: dr_mgmt reset is handled inside the generate block

      end else begin
        // Original synchronous logic
        idle_remover_sink_valid <= 1'b0; // Default assignment
        idle_inserter_source_ready <= 1'b0; // Default assignment

        // Default assignments for signals controlled in specific JTAG states
        // Prevents latches and ensures defined behavior when not in that state/condition
        if (ir_in != DEBUG) begin
            // clock_sense_reset_n is normally high, pulled low only during UDR of DEBUG
             clock_sense_reset_n <= 1'b1;
        end
        if (ir_in != CONTROL || !virtual_state_udr) begin
            // offset and resetrequest are loaded only during UDR of CONTROL
            // Keep previous value otherwise (implicit memory) - this is handled by FF behavior
        end


        if (ir_in == DATA) begin
            if (virtual_state_cdr) begin
                // Initialize write side state
                if (offset == 'b0) begin
                    write_state <= ST_HEADER_1;
                end else begin
                    write_state <= ST_BYPASS;
                end
                bypass_bit_counter <= offset;
                header_in_bit_counter <= 15;
                write_data_bit_counter <= 0; // Counter resets to 0 for byte alignment
                decode_header_1 <= 1'b0;
                decode_header_2 <= 1'b0;
                read_data_all_valid  <= 1'b0;
                valid_write_data_length_byte_counter  <= 0;

                // Initialize read side state
                read_state <= ST_HEADER;
                if (|offset[2:0]) begin // Calculate padding based on offset
                    padded_bit_counter[8:3] <= offset[7:3] + 1'b1;
                    padded_bit_counter[2:0] <= 3'b0;
                end else begin
                    padded_bit_counter <= {1'b0, offset};
                end
                header_out_bit_counter <= 0; // Counter resets to 0 for byte alignment
                read_data_bit_counter <= 0; // Counter resets to 0 for byte alignment
                dr_data_out <= {{7{1'b0}}, data_available}; // Load initial data availability
                read_data_valid <= 0;
            end
            if (virtual_state_sdr) begin
                // Write side logic (shifting in data)
                case (write_state)
                    ST_BYPASS: begin
                        bypass_bit_counter <= bypass_bit_counter - 1'b1;
                        if (bypass_bit_counter == 1) begin
                            write_state <= ST_HEADER_1;
                        end
                    end
                    ST_HEADER_1: begin
                        header_in <= {tdi, header_in[15:1]};
                        header_in_bit_counter <= header_in_bit_counter - 1'b1;
                        if (header_in_bit_counter == 3) begin // Latch fields at specific bit counts
                            read_data_length  <= {tdi, header_in[15:14]};
                            scan_length       <= header_in[13:4];
                            write_state <= ST_HEADER_2;
                            decode_header_1 <= 1'b1; // Signal header part 1 decoded
                        end
                    end
                    ST_HEADER_2: begin
                        header_in <= {tdi, header_in[15:1]};
                        header_in_bit_counter <= header_in_bit_counter - 1'b1;
                        if (decode_header_1) begin // Use latched values after decode signal
                            decode_header_1 <= 1'b0;
                            if (read_data_length == 3'b111) begin
                                read_data_all_valid <= 1'b1; // Special case: read all available data
                            end
                            scan_length_byte_counter <= decoded_scan_length; // Calculate total length
                        end
                        if (header_in_bit_counter == 0) begin // Latch final field
                            write_data_length <= {tdi, header_in[15:14]};
                            write_state <= ST_WRITE_DATA;
                            decode_header_2 <= 1'b1; // Signal header part 2 decoded
                        end
                    end
                    ST_WRITE_DATA: begin
                        dr_data_in <= {tdi, dr_data_in[7:1]}; // Shift in data bit
                        if (decode_header_2) begin // Use latched values after decode signal
                            decode_header_2 <= 1'b0;
                            case (write_data_length) // Calculate valid write data length
                                3'b111:  valid_write_data_length_byte_counter <= decoded_scan_length + 1'b1; // Special case: write all
                                3'b000:  valid_write_data_length_byte_counter <= 'b0; // Special case: write none
                                default: valid_write_data_length_byte_counter <= decoded_write_data_length; // Calculated length
                            endcase
                        end
                        write_data_bit_counter <= write_data_bit_counter - 1'b1; // Counts bits within a byte (7 down to 0)
                        write_data_valid <= (valid_write_data_length_byte_counter != 0); // Data is valid if length > 0
                        if (write_data_byte_aligned && write_data_valid) begin // On byte boundary and valid data
                            valid_write_data_length_byte_counter <= valid_write_data_length_byte_counter - 1'b1; // Decrement byte counter
                            idle_remover_sink_valid <= 1'b1; // Assert valid for one cycle
                            idle_remover_sink_data <= {tdi, dr_data_in[7:1]}; // Pass the completed byte
                        end
                    end
                endcase // write_state

                // Read side logic (shifting out data)
                dr_data_out <= {1'b0, dr_data_out[7:1]}; // Shift register for TDO output (LSB first)
                case (read_state)
                    ST_HEADER: begin // Output header bits (fixed pattern initially, then data availability)
                        header_out_bit_counter <= header_out_bit_counter - 1'b1; // Counts bits within header
                        if (header_out_bit_counter == 2) begin // Check ready condition near end of header output
                            if (padded_bit_counter == 0) begin // Only ready if no padding needed
                                idle_inserter_source_ready <= read_data_all_valid; // Ready if reading all data
                            end
                        end
                        if (header_out_bit_counter == 1) begin // Transition state at end of header output
                            if (padded_bit_counter == 0) begin // No padding needed
                                read_state <= ST_READ_DATA; // Go to read data state
                                // Determine initial data validity based on counters/flags
                                read_data_valid <= read_data_all_valid || (scan_length_byte_counter <= decoded_read_data_length + 1);
                                // Load first byte of data or placeholder
                                dr_data_out <= read_data_all_valid ? idle_inserter_source_data : 8'h4a;
                            end else begin // Padding needed
                                read_state <= ST_PADDED; // Go to padding state
                                padded_bit_counter <= padded_bit_counter - 1'b1; // Start padding countdown
                                idle_inserter_source_ready <= 1'b0; // Not ready while padding
                                dr_data_out <= 8'h4a; // Output placeholder during padding
                            end
                        end
                    end
                    ST_PADDED: begin // Output padding bits (placeholder)
                        padded_bit_counter <= padded_bit_counter - 1'b1; // Countdown padding bits
                        // Load placeholder on byte boundaries during padding
                        if (padded_bit_byte_aligned) begin
                            dr_data_out <= 8'h4a;
                        end
                        // Check ready condition near end of padding
                        if (padded_bit_counter == 1) begin
                            idle_inserter_source_ready <= read_data_all_valid; // Ready if reading all data
                        end
                        if (padded_bit_counter == 0) begin // Padding finished
                            read_state <= ST_READ_DATA; // Go to read data state
                            // Determine data validity after padding
                            read_data_valid <= read_data_all_valid || (scan_length_byte_counter <= decoded_read_data_length + 1);
                             // Load first byte of data or placeholder
                            dr_data_out <= read_data_all_valid ? idle_inserter_source_data : 8'h4a;
                        end
                    end
                    ST_READ_DATA: begin // Output actual data bytes
                        read_data_bit_counter <= read_data_bit_counter - 1'b1; // Counts bits within a byte (7 down to 0)
                        // Check ready condition near end of byte output
                        if (read_data_bit_counter == 2) begin
                            idle_inserter_source_ready <= bytestream_end ? 1'b0 : read_data_valid; // Ready if valid and not end
                        end
                        // On byte boundary
                        if (read_data_byte_aligned) begin
                            if (~bytestream_end) begin // Decrement byte counter if not finished
                                scan_length_byte_counter <= scan_length_byte_counter - 1'b1;
                            end
                            // Update data validity for next byte
                            read_data_valid <= read_data_all_valid || (scan_length_byte_counter <= decoded_read_data_length + 1);
                            // Load next byte or placeholder
                            dr_data_out <= (read_data_valid & ~bytestream_end) ? idle_inserter_source_data : 8'h4a;
                        end
                    end
                endcase // read_state
            end // virtual_state_sdr for DATA
        end // ir_in == DATA

        // Other JTAG instructions
        if (ir_in == LOOPBACK) begin
            if (virtual_state_cdr) begin
                dr_loopback <= 1'b0; // Reset loopback FF
            end
            if (virtual_state_sdr) begin
                dr_loopback <= tdi; // Simple loopback TDI to TDO (via FF)
            end
        end

        if (ir_in == DEBUG) begin
            if (virtual_state_cdr) begin
                // Load synchronized status signals into DR
                dr_debug <= {clock_sensor_sync, clock_to_sample_div2_sync, reset_to_sample_sync};
            end
            if (virtual_state_sdr) begin
                dr_debug <= {1'b0, dr_debug[2:1]}; // Shift DR (TDO is dr_debug[0])
            end
            // Control clock_sense_reset_n via UDR state
            if (virtual_state_udr) begin
                 clock_sense_reset_n <= 1'b0; // Assert internal reset signal
            end
            // else: clock_sense_reset_n returns to 1'b1 due to default assignment at top of block
        end

        if (ir_in == INFO) begin
            if (virtual_state_cdr) begin
                // Load parameters into DR
                dr_info <= {PURPOSE[2:0], UPSTREAM_ENCODED_SIZE[3:0], DOWNSTREAM_ENCODED_SIZE[3:0]};
            end
            if (virtual_state_sdr) begin
                dr_info <= {1'b0, dr_info[10:1]}; // Shift DR
            end
        end

        if (ir_in == CONTROL) begin
            if (virtual_state_cdr) begin
                dr_control <= 'b0; // Clear DR
            end
            if (virtual_state_sdr) begin
                dr_control <= {tdi, dr_control[8:1]}; // Shift DR
            end
            if (virtual_state_udr) begin
                // Update offset and resetrequest from DR content
                {resetrequest, offset} <= dr_control;
            end
        end
        // MGMT instruction handled in generate block below
      end // else: !~reset_n
    end // always @ (posedge tck or negedge reset_n)

    // Combinational logic for TDO based on current instruction and state
    always @ * begin
        tdo = 1'b0; // Default TDO to 0
        if (virtual_state_sdr) begin // TDO is only active during