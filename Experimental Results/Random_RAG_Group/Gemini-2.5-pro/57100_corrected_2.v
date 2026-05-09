`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module altera_jtag_streaming #(
    parameter PURPOSE = 0,
    parameter UPSTREAM_FIFO_SIZE = 0,
    parameter DOWNSTREAM_FIFO_SIZE = 0,
    parameter MGMT_CHANNEL_WIDTH = -1
) (
	input wire test_i,
    input  wire       tck,
    input  wire       tdi,
    output reg        tdo,
    input  wire [2:0] ir_in,
    input  wire       virtual_state_cdr,
    input  wire       virtual_state_sdr,
    input  wire       virtual_state_udr,
    input  wire       reset_n, // Primary asynchronous reset
    output wire [7:0] source_data,
    output wire       source_valid,
    input  wire [7:0] sink_data,
    input  wire       sink_valid,
    output wire       sink_ready,
    input  wire       clock_to_sample,
    input  wire       reset_to_sample, // Synchronous reset for clock_to_sample domain? Assume PI for now.
    output reg        resetrequest,
    output wire       debug_reset,
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
    reg [1:0] write_state = ST_BYPASS;
    reg [1:0] read_state  = ST_HEADER;
    reg [ 7:0] dr_data_in  = 'b0;
    reg [ 7:0] dr_data_out = 'b0;
    reg        dr_loopback = 'b0;
    reg [ 2:0] dr_debug    = 'b0;
    reg [10:0] dr_info     = 'b0;
    reg [ 8:0] dr_control  = 'b0;
    reg [MGMT_CHANNEL_WIDTH+2:0] dr_mgmt = 'b0;
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
    (* altera_attribute = {"-name GLOBAL_SIGNAL OFF"}*) reg clock_sense_reset_n  = 'b1;
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
    wire dft_clock_sense_reset_n_sync;
    wire dft_sync_reset;

    // DFT Fix: Mux reset for synchronizer clock_sense_reset_n_synchronizer
    assign dft_sync_reset = test_i ? reset_n : clock_sense_reset_n;

    // DFT Fix: Mux reset for clock_sensor flop
	assign dft_clock_sense_reset_n_sync = test_i ? reset_n : clock_sense_reset_n_sync ;

    // Note: Assuming altera_std_synchronizer uses reset_n as asynchronous reset internally.
    // If it uses synchronous reset, this fix might need adjustment based on the synchronizer's implementation.
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
    altera_std_synchronizer #(.depth(TCK_TO_SYSCLK_SYNC_DEPTH)) clock_sense_reset_n_synchronizer (
        .clk(clock_to_sample),
        .reset_n(dft_sync_reset), // DFT Fix: Use muxed reset
        .din(1'b1),
        .dout(clock_sense_reset_n_sync));

    // DFT Fix: Use muxed reset 'dft_clock_sense_reset_n_sync' in sensitivity list and condition
    always @ (posedge clock_to_sample or negedge dft_clock_sense_reset_n_sync) begin
        if (~dft_clock_sense_reset_n_sync) begin // DFT Fix: Check muxed reset
            clock_sensor <= 1'b0;
        end else begin
            clock_sensor <= 1'b1;
        end
    end

    // This flop seems fine, reset is synchronous if reset_to_sample is synchronous to clock_to_sample
    // Assuming reset_to_sample is a synchronous reset signal. If it's async, it needs fixing.
    // No explicit reset used here.
    always @ (posedge clock_to_sample) begin
        clock_to_sample_div2 <= ~clock_to_sample_div2;
    end

    // Main state machine and data path logic - clocked by tck
    // Assuming reset_n is the primary async reset for this domain
    always @ (posedge tck or negedge reset_n) begin
      if (~reset_n) begin
         // Reset all registers driven by tck
         write_state <= ST_BYPASS;
         read_state  <= ST_HEADER;
         dr_data_in  <= 'b0;
         dr_data_out <= 'b0;
         dr_loopback <= 'b0;
         dr_debug    <= 'b0;
         dr_info     <= 'b0;
         dr_control  <= 'b0;
         dr_mgmt     <= 'b0; // Assuming MGMT_CHANNEL_WIDTH is known or handled
         padded_bit_counter             <= 'b0;
         bypass_bit_counter             <= 'b0;
         write_data_bit_counter         <= 'b0;
         read_data_bit_counter          <= 'b0;
         header_in_bit_counter          <= 'b0;
         header_out_bit_counter         <= 'b0;
         scan_length_byte_counter       <= 'b0;
         valid_write_data_length_byte_counter  <= 'b0;
         write_data_valid     <= 'b0;
         read_data_valid      <= 'b0;
         read_data_all_valid  <= 'b0;
         decode_header_1 <= 'b0;
         decode_header_2 <= 'b0;
         offset     <= 'b0;
         header_in  <= 'b0;
         scan_length       <= 'b0;
         read_data_length  <= 'b0;
         write_data_length <= 'b0;
         idle_inserter_source_ready <= 'b0;
         idle_remover_sink_data     <= 'b0;
         idle_remover_sink_valid    <= 'b0;
         clock_sense_reset_n <= 1'b1; // Reset state for internal signal
         resetrequest <= 1'b0; // Reset output register
         // Note: tdo is combinational based on state, no reset needed here.

      end else begin // Non-reset behavior
        // Keep original logic but ensure idle_remover_sink_valid and idle_inserter_source_ready default correctly
        idle_remover_sink_valid <= 1'b0; // Default value per cycle
        idle_inserter_source_ready <= 1'b0; // Default value per cycle

        if (ir_in == DATA) begin
            if (virtual_state_cdr) begin
                if (offset == 'b0) begin
                    write_state <= ST_HEADER_1;
                end else begin
                    write_state <= ST_BYPASS;
                end
                bypass_bit_counter <= offset;
                header_in_bit_counter <= 15;
                write_data_bit_counter <= 0; // Start from 8'b0000_0000
                decode_header_1 <= 1'b0;
                decode_header_2 <= 1'b0;
                read_data_all_valid  <= 1'b0;
                valid_write_data_length_byte_counter  <= 0;

                // Read state machine reset on CDR
                read_state <= ST_HEADER;
                if (|offset[2:0]) begin
                    padded_bit_counter[8:3] <= offset[7:3] + 1'b1;
                    padded_bit_counter[2:0] <= 3'b0;
                end else begin
                    padded_bit_counter <= {1'b0, offset};
                end
                header_out_bit_counter <= 0; // Start from 4'b0000
                read_data_bit_counter <= 0; // Start from 3'b000
                dr_data_out <= {{7{1'b0}}, data_available}; // Load initial value
                read_data_valid <= 0;
            end

            if (virtual_state_sdr) begin
                // Write state machine logic
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
                        if (header_in_bit_counter == 3) begin
                            read_data_length  <= {tdi, header_in[15:14]};
                            scan_length       <= header_in[13:4];
                            write_state <= ST_HEADER_2;
                            decode_header_1 <= 1'b1;
                        end
                    end
                    ST_HEADER_2: begin
                        header_in <= {tdi, header_in[15:1]};
                        header_in_bit_counter <= header_in_bit_counter - 1'b1;
                        if (decode_header_1) begin
                            decode_header_1 <= 1'b0;
                            if (read_data_length == 3'b111) begin
                                read_data_all_valid <= 1'b1;
                            end
                            scan_length_byte_counter <= decoded_scan_length;
                        end
                        if (header_in_bit_counter == 0) begin
                            write_data_length <= {tdi, header_in[15:14]};
                            write_state <= ST_WRITE_DATA;
                            decode_header_2 <= 1'b1;
                        end
                    end
                    ST_WRITE_DATA: begin
                        dr_data_in <= {tdi, dr_data_in[7:1]};
                        if (decode_header_2) begin
                            decode_header_2 <= 1'b0;
                            case (write_data_length)
                                3'b111:  valid_write_data_length_byte_counter <= decoded_scan_length + 1'b1;
                                3'b000:  valid_write_data_length_byte_counter <= 'b0;
                                default: valid_write_data_length_byte_counter <= decoded_write_data_length;
                            endcase
                        end
                        write_data_bit_counter <= write_data_bit_counter - 1'b1; // Counts 0, 7, 6, .. 1
                        write_data_valid <= (valid_write_data_length_byte_counter != 0);
                        if (write_data_byte_aligned && write_data_valid) begin // write_data_bit_counter == 1
                            valid_write_data_length_byte_counter <= valid_write_data_length_byte_counter - 1'b1;
                            idle_remover_sink_valid <= 1'b1; // Assert valid for one cycle
                            idle_remover_sink_data <= {tdi, dr_data_in[7:1]}; // Capture last bit
                        end
                    end
                    default: write_state <= ST_BYPASS; // Should not happen
                endcase

                // Read state machine logic
                dr_data_out <= {1'b0, dr_data_out[7:1]}; // Shift existing data out
                case (read_state)
                    ST_HEADER: begin
                        header_out_bit_counter <= header_out_bit_counter - 1'b1; // Counts 0, 15, 14, .. 1
                        if (header_out_bit_counter == 2) begin
                            if (padded_bit_counter == 0) begin
                                idle_inserter_source_ready <= read_data_all_valid; // Assert ready based on condition
                            end // else keep default 1'b0
                        end
                        if (header_out_bit_counter == 1) begin // Last bit of header
                            if (padded_bit_counter == 0) begin
                                read_state <= ST_READ_DATA;
                                read_data_valid <= read_data_all_valid || (scan_length_byte_counter<=decoded_read_data_length+1);
                                // Update dr_data_out based on read data availability
                                dr_data_out <= read_data_all_valid ? idle_inserter_source_data : 8'h4a;
                            end else begin
                                read_state <= ST_PADDED;
                                padded_bit_counter <= padded_bit_counter - 1'b1;
                                // idle_inserter_source_ready remains 1'b0 (default)
                                dr_data_out <= 8'h4a; // Output padding
                            end
                        end
                    end
                    ST_PADDED: begin
                        padded_bit_counter <= padded_bit_counter - 1'b1;
                        if (padded_bit_byte_aligned) begin // padded_bit_counter[2:0] == 0
                            dr_data_out <= 8'h4a; // Output padding
                        end
                        if (padded_bit_counter == 1) begin // One bit left
                            idle_inserter_source_ready <= read_data_all_valid; // Assert ready based on condition
                        end
                        if (padded_bit_counter == 0) begin // Padding finished
                            read_state <= ST_READ_DATA;
                            read_data_valid <= read_data_all_valid || (scan_length_byte_counter<=decoded_read_data_length+1);
                            // Update dr_data_out based on read data availability
                            dr_data_out <= read_data_all_valid ? idle_inserter_source_data : 8'h4a;
                        end
                    end
                    ST_READ_DATA: begin
                        read_data_bit_counter <= read_data_bit_counter - 1'b1; // Counts 0, 7, 6, .. 1
                        if (read_data_bit_counter == 2) begin
                            idle_inserter_source_ready <= bytestream_end ? 1'b0 : read_data_valid; // Assert ready based on condition
                        end
                        if (read_