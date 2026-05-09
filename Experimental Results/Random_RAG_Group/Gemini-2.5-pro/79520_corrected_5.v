`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module altera_jtag_streaming #(
    parameter PURPOSE = 0,
    parameter UPSTREAM_FIFO_SIZE = 0,
    parameter DOWNSTREAM_FIFO_SIZE = 0,
    parameter MGMT_CHANNEL_WIDTH = -1
) (
	input wire test_i, // DFT test mode signal
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
    input  wire       reset_to_sample, // Primary synchronous reset (used for sync)
    output reg        resetrequest,
    output wire       debug_reset, // Functional debug reset output
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
    // Renamed states to avoid name collision
    localparam ST_WRITE_BYPASS     = 'h0;
    localparam ST_WRITE_HEADER_1   = 'h1;
    localparam ST_WRITE_HEADER_2   = 'h2;
    localparam ST_WRITE_DATA_ST    = 'h3; // Renamed to avoid conflict with parameter DATA
    localparam ST_READ_HEADER      = 'h0;
    localparam ST_READ_PADDED      = 'h1;
    localparam ST_READ_DATA_ST     = 'h2; // Renamed to avoid conflict with parameter DATA

    reg [1:0] write_state = ST_WRITE_BYPASS;
    reg [1:0] read_state  = ST_READ_HEADER;
    reg [ 7:0] dr_data_in  = 'b0;
    reg [ 7:0] dr_data_out = 'b0;
    reg        dr_loopback = 'b0;
    reg [ 2:0] dr_debug    = 'b0;
    reg [10:0] dr_info     = 'b0;
    reg [ 8:0] dr_control  = 'b0;
    // Use conditional width based on parameter for dr_mgmt
    localparam DR_MGMT_WIDTH = (MGMT_CHANNEL_WIDTH > 0) ? MGMT_CHANNEL_WIDTH + 2 : 1;
    reg [DR_MGMT_WIDTH:0] dr_mgmt = 'b0;
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
    (* altera_attribute = {"-name GLOBAL_SIGNAL OFF"}*) reg clock_sense_reset_n  = 'b1; // Internal functional reset control signal
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
    wire clock_sense_reset_n_sync; // Output of synchronizer (functional reset path, active low)
    wire dft_clock_sense_reset_n; // Muxed reset for clock_sensor FF (active high)
    wire dr_debug_d1_data; // DFT-safe data for dr_debug[1]

    // DFT Fix ACNCPI (clock_sensor): Mux for clock_sensor asynchronous reset
    // Use primary reset (~reset_n active high) during test mode (test_i=1)
    // Use functional synchronized reset (~clock_sense_reset_n_sync active high) during functional mode (test_i=0)
    assign dft_clock_sense_reset_n = test_i ? ~reset_n : ~clock_sense_reset_n_sync ;

    // DFT Fix CDFDAT (dr_debug[1]): Mux for clock_to_sample_div2_sync feeding dr_debug FF
    // Provide constant '0' during test mode
    assign dr_debug_d1_data = test_i ? 1'b0 : clock_to_sample_div2_sync;

    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) clock_sensor_synchronizer (
        .clk(tck),
        .reset_n(reset_n), // Use primary reset
        .din(clock_sensor),
        .dout(clock_sensor_sync));
    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) reset_to_sample_synchronizer (
        .clk(tck),
        .reset_n(reset_n), // Use primary reset
        .din(reset_to_sample),
        .dout(reset_to_sample_sync));
    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) clock_to_sample_div2_synchronizer (
        .clk(tck),
        .reset_n(reset_n), // Use primary reset
        .din(clock_to_sample_div2),
        .dout(clock_to_sample_div2_sync));

    // Synchronizer for the internally generated functional reset signal clock_sense_reset_n
    // Its output clock_sense_reset_n_sync is the functional asynchronous reset for clock_sensor FF (active low)
    altera_std_synchronizer #(.depth(TCK_TO_SYSCLK_SYNC_DEPTH)) clock_sense_reset_n_synchronizer (
        .clk(clock_to_sample),
        .reset_n(reset_n), // Use primary reset
        .din(clock_sense_reset_n), // Synchronize the internal reset signal (active low)
        .dout(clock_sense_reset_n_sync)); // Output is the synchronized functional reset path (active low)

    // clock_sensor FF with DFT controllable asynchronous reset (active high)
    always @ (posedge clock_to_sample or posedge dft_clock_sense_reset_n) begin
        if (dft_clock_sense_reset_n) begin // Use muxed reset (active high)
            clock_sensor <= 1'b0;
        end else begin
            clock_sensor <= 1'b1;
        end
    end

    // clock_to_sample_div2 FF (synchronous logic)
    always @ (posedge clock_to_sample) begin
       // This FF does not have an explicit reset in the original code.
       // If a reset is needed, it should be synchronous and use reset_to_sample or similar.
       // For now, keeping original behavior.
        clock_to_sample_div2 <= ~clock_to_sample_div2;
    end

    // Main TCK-domain logic
    always @ (posedge tck) begin
        // Default assignments (can reduce inferred latches if covering all paths)
        idle_remover_sink_valid <= 1'b0;
        idle_inserter_source_ready <= 1'b0;

        if (ir_in == DATA) begin
            if (virtual_state_cdr) begin
                // Reset state and counters for DATA mode
                if (offset == 'b0) begin
                    write_state <= ST_WRITE_HEADER_1;
                end else begin
                    write_state <= ST_WRITE_BYPASS;
                end
                bypass_bit_counter <= offset;
                header_in_bit_counter <= 15;
                write_data_bit_counter <= 0; // Reset to 8 bits (decrements to 1)
                decode_header_1 <= 1'b0;
                decode_header_2 <= 1'b0;
                read_data_all_valid  <= 1'b0;
                valid_write_data_length_byte_counter  <= 0;

                // Reset read side state
                read_state <= ST_READ_HEADER;
                if (|offset[2:0]) begin // Padded bits calculation
                    padded_bit_counter[8:3] <= offset[7:3] + 1'b1;
                    padded_bit_counter[2:0] <= 3'b0;
                end else begin
                    padded_bit_counter <= {1'b0, offset};
                end
                header_out_bit_counter <= 0; // Reset to 16 bits (decrements to 1)
                read_data_bit_counter <= 0; // Reset to 8 bits (decrements to 1)
                dr_data_out <= {{7{1'b0}}, data_available}; // Load initial data_available status
                read_data_valid <= 0;
            end

            // Shift Data Register (SDR) logic for DATA mode
            if (virtual_state_sdr) begin
                // Write side state machine
                case (write_state)
                    ST_WRITE_BYPASS: begin
                        bypass_bit_counter <= bypass_bit_counter - 1'b1;
                        if (bypass_bit_counter == 1) begin
                            write_state <= ST_WRITE_HEADER_1;
                        end
                    end
                    ST_WRITE_HEADER_1: begin
                        header_in <= {tdi, header_in[15:1]};
                        header_in_bit_counter <= header_in_bit_counter - 1'b1;
                        if (header_in_bit_counter == 3) begin // Capture lengths just before end
                            read_data_length  <= {tdi, header_in[15:14]};
                            scan_length       <= header_in[13:4];
                            write_state <= ST_WRITE_HEADER_2;
                            decode_header_1 <= 1'b1; // Signal header 1 decoded
                        end
                    end
                    ST_WRITE_HEADER_2: begin
                        header_in <= {tdi, header_in[15:1]};
                        header_in_bit_counter <= header_in_bit_counter - 1'b1;
                        if (decode_header_1) begin // Actions after header 1 decoded
                            decode_header_1 <= 1'b0;
                            if (read_data_length == 3'b111) begin
                                read_data_all_valid <= 1'b1; // Read all data
                            end
                            scan_length_byte_counter <= decoded_scan_length; // Set total scan length
                        end
                        if (header_in_bit_counter == 0) begin // Capture write length at the end
                            write_data_length <= {tdi, header_in[15:14]};
                            write_state <= ST_WRITE_DATA_ST;
                            decode_header_2 <= 1'b1; // Signal header 2 decoded
                        end
                    end
                    ST_WRITE_DATA_ST: begin
                        dr_data_in <= {tdi, dr_data_in[7:1]}; // Shift in write data
                        if (decode_header_2) begin // Actions after header 2 decoded
                            decode_header_2 <= 1'b0;
                            // Calculate valid write data length based on encoding
                            case (write_data_length)
                                3'b111:  valid_write_data_length_byte_counter <= decoded_scan_length + 1'b1; // Write all data
                                3'b000:  valid_write_data_length_byte_counter <= 'b0; // Write no data
                                default: valid_write_data_length_byte_counter <= decoded_write_data_length; // Write specific length
                            endcase
                        end
                        write_data_bit_counter <= write_data_bit_counter - 1'b1; // Decrement bit counter (wraps around)
                        write_data_valid <= (valid_write_data_length_byte_counter != 0); // Check if valid data remains
                        if (write_data_byte_aligned && write_data_valid) begin // On byte boundary and valid data expected
                            valid_write_data_length_byte_counter <= valid_write_data_length_byte_counter - 1'b1; // Decrement byte counter
                            idle_remover_sink_valid <= 1'b1; // Send data byte to remover
                            idle_remover_sink_data <= {tdi, dr_data_in[7:1]}; // Capture the full byte
                        end
                    end
                    default: write_state <= ST_WRITE_BYPASS; // Should not happen
                endcase

                // Read side state machine
                dr_data_out <= {1'b0, dr_data_out[7:1]}; // Default shift out 0, overridden below
                case (read_state)
                    ST_READ_HEADER: begin
                        header_out_bit_counter <= header_out_bit_counter - 1'b1; // Decrement header bit counter (wraps around)
                        if (header_out_bit_counter == 2) begin // Check readiness near end of header shift
                            if (padded_bit_counter == 0) begin // If no padding, check if inserter ready
                                idle_inserter_source_ready <= read_data_all_valid;
                            end
                        end
                        if (header_out_bit_counter == 1) begin // Transition at end of header shift
                            if (padded_bit_counter == 0) begin // No padding
                                read_state <= ST_READ_DATA_ST; // Go to read data state
                                read_data_valid <= read_data_all_valid || (scan_length_byte_counter <= decoded_read_data_length + 1); // Determine if read data is valid
                                dr_data_out <= read_data_all_valid ? idle_inserter_source_data : 8'h4a; // Output data or 'J'
                            end else begin // Padding needed
                                read_state <= ST_READ_PADDED; // Go to padding state
                                padded_bit_counter <= padded_bit_counter - 1'b1; // Decrement padding counter
                                idle_inserter_source_ready <= 1'b0; // Not ready for data yet
                                dr_data_out <= 8'h4a; // Output 'J' during padding
                            end
                        end
                        // During header shift, output LSB of dr_data_out (which was loaded in CDR)
                    end
                    ST_READ_PADDED: begin
                        padded_bit_counter <= padded_bit_counter - 1'b1; // Decrement padding counter
                        if (padded_bit_byte_aligned) begin // Every 8 bits during padding
                            dr_data_out <= 8'h4a; // Output 'J'
                        end
                        if (padded_bit_counter == 1) begin // One bit before padding ends
                            idle_inserter_source_ready <= read_data_all_valid; // Check readiness if all data is valid
                        end
                        if (padded_bit_counter == 0) begin // Padding finished
                            read_state <= ST_READ_DATA_ST; // Go to read data state
                            read_data_valid <= read_data_all_valid || (scan_length_byte_counter <= decoded_read_data_length + 1); // Determine data validity
                            dr_data_out <= read_data_all_valid ? idle_inserter_source_data : 8'h4a; // Output data or 'J'
                        end
                        // During padding shift, output LSB of dr_data_out (usually from 8'h4a)
                    end
                    ST_READ_DATA_ST: begin
                        read_data_bit_counter <= read_data_bit_counter - 1'b1; // Decrement data bit counter (wraps around)
                        if (read_data_bit_counter == 2) begin // Check readiness near end of byte shift
                            idle_inserter_source_ready <= bytestream_end ? 1'b0 : read_data_valid; // Ready if not end and data valid
                        end