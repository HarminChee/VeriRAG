`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module altera_jtag_streaming #(
    parameter PURPOSE = 0,
    parameter UPSTREAM_FIFO_SIZE = 0,
    parameter DOWNSTREAM_FIFO_SIZE = 0,
    parameter MGMT_CHANNEL_WIDTH = -1
) (
    input wire        test_i, // Added test mode input
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
    input  wire       clock_to_sample, // Primary clock for another domain
    input  wire       reset_to_sample, // Primary reset for clock_to_sample domain (assume active high synchronous)
    output reg        resetrequest,
    output wire       debug_reset, // Raw output from synchronizer
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
    localparam TCK_TO_SYSCLK_SYNC_DEPTH = 8; // Depth for tck -> clock_to_sample
    localparam SYSCLK_TO_TCK_SYNC_DEPTH = 3; // Depth for clock_to_sample -> tck
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
    reg [1:0] write_state = ST_BYPASS;
    reg [1:0] read_state  = ST_HEADER;
    reg [ 7:0] dr_data_in  = 'b0;
    reg [ 7:0] dr_data_out = 'b0;
    reg        dr_loopback = 'b0;
    reg [ 2:0] dr_debug    = 'b0;
    reg [10:0] dr_info     = 'b0;
    reg [ 8:0] dr_control  = 'b0;
    reg [MGMT_CHANNEL_WIDTH+2:0] dr_mgmt = 'b0; // Use original width calculation
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
    (* altera_attribute = {"-name GLOBAL_SIGNAL OFF"}*) reg clock_sense_reset_n  = 'b1; // Internal signal based on JTAG state
    wire data_available;
    assign data_available = sink_valid;
    wire [18:0] decoded_scan_length;
    wire [18:0] decoded_write_data_length;
    wire [18:0] decoded_read_data_length;
    assign decoded_scan_length =  { scan_length, {8{1'b1}} };
    assign decoded_write_data_length = (write_data_length == 0) ? 19'h0 : (19'h00080 << write_data_length);
    assign decoded_read_data_length  = (read_data_length == 0)  ? 19'h0 : (19'h00080 << read_data_length);

    // Synchronizers for signals crossing clock domains
    wire clock_sensor_sync;
    wire reset_to_sample_sync;
    wire clock_to_sample_div2_sync;
    wire clock_sense_reset_n_sync; // Output of the synchronizer
    wire dft_clock_sense_reset_n_sync; // Muxed reset for DFT

    // Synchronizers reset by primary reset_n
    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) clock_sensor_synchronizer (
        .clk(tck),
        .reset_n(reset_n),
        .din(clock_sensor),
        .dout(clock_sensor_sync));
    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) reset_to_sample_synchronizer (
        .clk(tck),
        .reset_n(reset_n),
        .din(reset_to_sample),
        .dout(reset_to_sample_sync));
    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) clock_to_sample_div2_synchronizer (
        .clk(tck),
        .reset_n(reset_n),
        .din(clock_to_sample_div2),
        .dout(clock_to_sample_div2_sync));
    altera_std_synchronizer #(.depth(TCK_TO_SYSCLK_SYNC_DEPTH)) clock_sense_reset_n_synchronizer (
        .clk(clock_to_sample),
        .reset_n(reset_n), // Use primary reset_n for synchronizer FFs
        .din(clock_sense_reset_n),
        .dout(clock_sense_reset_n_sync));

    // DFT Fix: Mux the asynchronous reset for clock_sensor FF
    assign dft_clock_sense_reset_n_sync = test_i ? reset_n : clock_sense_reset_n_sync;

    // Flip-flop clock_sensor: Clocked by clock_to_sample, Async Reset dft_clock_sense_reset_n_sync (ACNCPI violation fixed)
    always @ (posedge clock_to_sample or negedge dft_clock_sense_reset_n_sync) begin
        if (~dft_clock_sense_reset_n_sync) begin // Use the DFT-controlled reset (active low)
            clock_sensor <= 1'b0;
        end else begin
            clock_sensor <= 1'b1; // Functional behavior: normally high unless reset
        end
    end

    // Flip-flop clock_to_sample_div2: Clocked by clock_to_sample, Sync Reset reset_to_sample
    always @ (posedge clock_to_sample or posedge reset_to_sample) begin
        if (reset_to_sample) begin // Use the primary synchronous reset for this domain
            clock_to_sample_div2 <= 1'b0;
        end else begin
            clock_to_sample_div2 <= ~clock_to_sample_div2;
        end
    end

    // Main logic clocked by tck, Async Reset reset_n
    always @ (posedge tck or negedge reset_n) begin
        if (~reset_n) begin
            // Reset state for tck domain logic
            write_state <= ST_BYPASS;
            read_state  <= ST_HEADER;
            dr_data_in  <= 'b0;
            dr_data_out <= 'b0;
            dr_loopback <= 'b0;
            dr_debug    <= 'b0;
            dr_info     <= 'b0;
            dr_control  <= 'b0;
            dr_mgmt     <= 'b0;
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
            clock_sense_reset_n <= 'b1; // Reset internal signal
            resetrequest <= 1'b0;
        end else begin
            // Default assignments to avoid latches
            idle_remover_sink_valid <= 1'b0;
            idle_inserter_source_ready <= 1'b0;
            // Keep clock_sense_reset_n high unless driven low by DEBUG UDR
            clock_sense_reset_n <= 1'b1;

            // IR == DATA state machine logic
            if (ir_in == DATA) begin
                // Capture Data Register (CDR) phase
                if (virtual_state_cdr) begin
                    // Write side CDR logic
                    if (offset == 'b0) begin
                        write_state <= ST_HEADER_1;
                    end else begin
                        write_state <= ST_BYPASS;
                    end
                    bypass_bit_counter <= offset;
                    header_in_bit_counter <= 15; // Start counter for 16 bits
                    write_data_bit_counter <= 0; // Start counter for 8 bits (decrements from 0)
                    decode_header_1 <= 1'b0;
                    decode_header_2 <= 1'b0;
                    read_data_all_valid <= 1'b0;
                    valid_write_data_length_byte_counter <= 0;

                    // Read side CDR logic
                    read_state <= ST_HEADER;
                    if (|offset[2:0]) begin // Calculate padding based on offset
                        padded_bit_counter[8:3] <= offset[7:3] + 1'b1;
                        padded_bit_counter[2:0] <= 3'b0;
                    end else begin
                        padded_bit_counter <= {1'b0, offset};
                    end
                    header_out_bit_counter <= 0; // Start counter for 16 bits (decrements from 0)
                    read_data_bit_counter <= 0;  // Start counter for 8 bits (decrements from 0)
                    dr_data_out <= {{7{1'b0}}, data_available}; // Capture data_available (sink_valid) status
                    read_data_valid <= 0;
                end

                // Shift Data Register (SDR) phase
                if (virtual_state_sdr) begin
                    // Write side SDR logic
                    case (write_state)
                        ST_BYPASS: begin
                            bypass_bit_counter <= bypass_bit_counter - 1'b1;
                            if (bypass_bit_counter == 1) begin // Check if next state is HEADER_1
                                write_state <= ST_HEADER_1;
                            end
                        end
                        ST_HEADER_1: begin
                            header_in <= {tdi, header_in[15:1]}; // Shift in header bits
                            header_in_bit_counter <= header_in_bit_counter - 1'b1;
                            if (header_in_bit_counter == 3) begin // After 13 shifts (16 - 3 = 13 bits shifted in)
                                read_data_length <= {tdi, header_in[15:14]}; // Capture read_data_length
                                scan_length      <= header_in[13:4];       // Capture scan_length
                                write_state <= ST_HEADER_2;               // Move to next state
                                decode_header_1 <= 1'b1;                  // Signal header part 1 decoded
                            end
                        end
                        ST_HEADER_2: begin
                            header_in <= {tdi, header_in[15:1]}; // Shift in remaining header bits
                            header_in_bit_counter <= header_in_bit_counter - 1'b1;
                            if (decode_header_1) begin // Use decoded values from previous cycle
                                decode_header_1 <= 1'b0;
                                if (read_data_length == 3'b111) begin // Check for special read length case
                                    read_data_all_valid <= 1'b1;
                                end
                                scan_length_byte_counter <= decoded_scan_length; // Calculate total scan length in bytes
                            end
                            if (header_in_bit_counter == 0) begin // End of header
                                write_data_length <= {tdi, header_in[15:14]}; // Capture write_data_length
                                write_state <= ST_WRITE_DATA;               // Move to data state
                                decode_header_2 <= 1'b1;                  // Signal header part 2 decoded
                            end
                        end
                        ST_WRITE_DATA: begin
                            dr_data_in <= {tdi, dr_data_in[7:1]}; // Shift in write data bits
                            if (decode_header_2) begin // Use decoded values from previous cycle
                                decode_header_2 <= 1'b0;
                                // Calculate valid write data length based on write_data_length code
                                case (write_data_length)
                                    3'b111:  valid_write_data_length_byte_counter <= decoded_scan_length + 1'b1; // Special case: write all
                                    3'b000:  valid_write_data_length_byte_counter <= 'b0;                      // Special case: write none
                                    default: valid_write_data_length_byte_counter <= decoded_write_data_length; // Calculated length
                                endcase
                            end
                            write_data_bit_counter <= write_data_bit_counter - 1'b1; // Decrement bit counter (wraps around)
                            write_data_valid <= (valid_write_data_length_byte_counter != 0); // Check if valid write data remains
                            if (write_data_byte_aligned && write_data_valid) begin // On byte boundary and data is valid
                                valid_write_data_length_byte_counter <= valid_write_data_length_byte_counter - 1'b1; // Decrement byte counter
                                idle_remover_sink_valid <= 1'b1; // Assert valid signal to idle remover
                                idle_remover_sink_data <= {tdi, dr_data_in[7:1]}; // Provide data byte
                            end
                        end
                    endcase // case (write_state)

                    // Read side SDR logic
                    dr_data_out <= {1'b0, dr_data_out[7:1]}; // Shift out read data bits (TDO source)
                    case (read_state)
                        ST_HEADER: begin
                            header_out_bit_counter <= header_out_bit_counter - 1'b1; // Decrement header bit counter
                            if (header_out_bit_counter == 2) begin // Penultimate header bit
                                if (padded_bit_counter == 0) begin // If no padding, check if ready for read data
                                    idle_inserter_source_ready <= read_data_all_valid; // Signal ready based on read_data_all_valid flag
                                end
                            end
                            if (header_out_bit_counter == 1) begin // Last header bit
                                if (padded_bit_counter == 0) begin // No padding
                                    read_state <= ST_READ_DATA; // Transition to read data state
                                    // Determine if read data is valid based on flags or remaining length
                                    read_data_valid <= read_data_all_valid || (scan_length_byte_counter <= decoded_read_data_length + 1);
                                    // Select data source: actual data or JTAG ID ('J')
                                    dr_data_out <= read_data_all_valid ? idle_inserter_source_data : 8'h4a;
                                end else begin // Padding needed
                                    read_state <= ST_PADDED; // Transition to padding state
                                    padded_bit_counter <= padded_bit_counter - 1'b1; // Decrement padding counter
                                    idle_inserter_source_ready <= 1'b0; // Not ready for data yet
                                    dr_data_out <= 8'h4a; // Output JTAG ID ('J') during padding header
                                end
                            end
                        end
                        ST_PADDED: begin
                            padded_bit_counter <= padded_bit_counter - 1'b1; // Decrement padding counter
                            if (padded_bit_byte_aligned) begin // On byte boundary during padding
                                dr_data_out <= 8'h4a; // Output JTAG ID ('J')
                            end
                            if (padded_bit_counter == 1) begin // Penultimate padding bit
                                idle_inserter_source_ready <= read_data_all_valid; // Signal readiness if applicable
                            end
                            if (padded_bit_counter == 0) begin // End of padding
                                read_state <= ST_READ_DATA; // Transition to read data state
                                // Determine if read data is valid
                                read_data_valid <= read_data_all_valid || (scan_length_byte_counter <= decoded_read_data_length + 1);
                                // Select data source: actual data or JTAG ID ('J')
                                dr_data_out <= read_data_all_valid ? idle_inserter_source_data : 8'h4a;
                            end
                        end
                        ST_READ_DATA: begin
                            read_data_bit_counter <= read_data_bit_counter - 1'b1; // Decrement read data bit counter
                            if (read_data_bit_counter == 2) begin // Penultimate data bit
                                // Signal ready if not end of stream and data is valid
                                idle_inserter_source_ready <= bytestream_end ? 1'b0 : read_data_valid;
                            end
                            if (read_data_byte_aligned) begin // On byte boundary
                                if (~bytestream_end) begin // If not end of stream
                                    scan_length_byte_counter <= scan_length_byte_counter - 1'b1; // Decrement byte counter
                                end
                                // Determine if read data is valid for the next byte
                                read_data_valid <= read_data_all_valid || (scan_length_byte_counter <= decoded_read_data_length + 1);
                                // Select data source: actual data or JTAG ID ('J') if invalid or end of stream
                                dr_data_out <= (read_data_valid & ~bytestream_end) ? idle_inserter_source_data : 8'h4a;
                            end
                        end
                    endcase // case (read_state)
                end // if (virtual_state_sdr)
            end // if (ir_in == DATA)

            // IR == LOOPBACK logic
            if (ir_in == LOOPBACK) begin
                if (virtual_state_cdr) begin
                    dr_loopback <= 1'b0; // Load 0 in CDR
                end
                if (virtual_state_sdr) begin
                    dr_loopback <= tdi; // Shift TDI to TDO
                end
            end

            // IR == DEBUG logic
            if (ir_in == DEBUG) begin
                if (virtual_state_cdr) begin
                    // Load synchronized status bits into DR
                    dr_debug <= {clock_sensor_sync, clock_to_sample_div2_sync, reset_to_sample_sync};
                end
                if (virtual_state_sdr) begin
                    dr_debug <= {1'b0, dr_debug[2:1]}; // Shift out status bits
                end
                // Update Data Register (UDR) phase
                if (virtual_state_udr) begin
                    clock_sense_reset_n <= 1'b0; // Assert internal reset signal
                end else begin
                    clock_sense_reset_n <= 1'b1; // Deassert internal reset signal (default)
                end
            end

            // IR == INFO logic
            if (ir_in == INFO) begin
                if (virtual_state_cdr) begin
                    // Load configuration info into DR
                    dr_info <= {PURPOSE[2:0], UPSTREAM_ENCODED_SIZE[3:0], DOWNSTREAM_ENCODED_SIZE[3:0]};
                end
                if (virtual_state_sdr) begin
                    dr_info <= {1'b0, dr_info[10:1]}; // Shift out info bits
                end
            end

            // IR == CONTROL logic
            if (ir_in == CONTROL) begin
                if (virtual_state_cdr) begin
                    dr_control <= 'b0; // Load 0 in CDR
                end
                if (virtual_state_sdr) begin
                    dr_