`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module altera_jtag_streaming #(
    parameter PURPOSE = 0,
    parameter UPSTREAM_FIFO_SIZE = 0,
    parameter DOWNSTREAM_FIFO_SIZE = 0,
    parameter MGMT_CHANNEL_WIDTH = -1
) (
    input wire test_i, // Added test mode input
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
    input  wire       reset_to_sample,
    output reg        resetrequest,
    output wire       debug_reset,
    output reg        mgmt_valid,
    // Use conditional width based on parameter for output port
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
    // Use original declaration; generate block handles MGMT_CHANNEL_WIDTH < 0 case
    reg [(MGMT_CHANNEL_WIDTH>0?MGMT_CHANNEL_WIDTH+2:1):0] dr_mgmt = 'b0;

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
    wire dft_sync_reset; // Muxed reset for synchronizer

    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) clock_sensor_synchronizer (
        .clk(tck),
        .reset_n(reset_n), // Use primary reset for synchronizer DFT
        .din(clock_sensor),
        .dout(clock_sensor_sync));
    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) reset_to_sample_synchronizer (
        .clk(tck),
        .reset_n(reset_n), // Use primary reset for synchronizer DFT
        .din(reset_to_sample),
        .dout(reset_to_sample_sync));
    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) clock_to_sample_div2_synchronizer (
        .clk(tck),
        .reset_n(reset_n), // Use primary reset for synchronizer DFT
        .din(clock_to_sample_div2),
        .dout(clock_to_sample_div2_sync));

    // Mux the asynchronous reset for the synchronizer itself
    assign dft_sync_reset = test_i ? reset_n : clock_sense_reset_n;

    altera_std_synchronizer #(.depth(TCK_TO_SYSCLK_SYNC_DEPTH)) clock_sense_reset_n_synchronizer (
        .clk(clock_to_sample),
        .reset_n(dft_sync_reset), // Use muxed reset
        .din(1'b1), // Synchronizing a constant '1' when reset is inactive
        .dout(clock_sense_reset_n_sync)); // Output reflects synchronized state of dft_sync_reset (active low)

    // Corrected always block for clock_sensor FF with DFT reset
    // Sensitivity list uses only the primary reset_n for asynchronous reset control
    always @ (posedge clock_to_sample or negedge reset_n) begin
        if (~reset_n) begin // Primary reset (active low) always has priority
             clock_sensor <= 1'b0;
        // Check functional reset only if primary reset is inactive AND not in test mode
        // Functional reset (clock_sense_reset_n_sync) is active low
        end else if (~clock_sense_reset_n_sync && !test_i) begin
             clock_sensor <= 1'b0; // Apply functional reset condition (synchronized active low)
        end else begin
             clock_sensor <= 1'b1; // Normal operation or test mode without reset
        end
    end

    // This FF only needs clock and primary reset for DFT
    always @ (posedge clock_to_sample or negedge reset_n) begin
        if (~reset_n) begin
            clock_to_sample_div2 <= 1'b0;
        end else begin
            clock_to_sample_div2 <= ~clock_to_sample_div2;
        end
    end

    // Main state machine and data path logic - ensure all FFs have reset_n
    always @ (posedge tck or negedge reset_n) begin
        if (~reset_n) begin
            // Reset all registers controlled by tck
            write_state <= ST_BYPASS;
            read_state  <= ST_HEADER;
            dr_data_in  <= 'b0;
            dr_data_out <= 'b0;
            dr_loopback <= 'b0;
            dr_debug    <= 'b0;
            dr_info     <= 'b0;
            dr_control  <= 'b0;
            // dr_mgmt reset handled in generate block
            padded_bit_counter <= 'b0;
            bypass_bit_counter <= 'b0;
            write_data_bit_counter <= 'b0;
            read_data_bit_counter <= 'b0;
            header_in_bit_counter <= 'b0;
            header_out_bit_counter <= 'b0;
            scan_length_byte_counter <= 'b0;
            valid_write_data_length_byte_counter <= 'b0;
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
            resetrequest <= 1'b0; // Reset output register
            clock_sense_reset_n <= 1'b1; // Reset internal control signal state
        end else begin
            // Default assignments (can be overridden below)
            idle_remover_sink_valid <= 1'b0;
            idle_inserter_source_ready <= 1'b0;
            // Keep functional reset control separate from primary reset
            // clock_sense_reset_n is updated based on JTAG state
            if (ir_in == DEBUG) begin
                 if (virtual_state_udr) begin
                     clock_sense_reset_n <= 1'b0; // Assert functional reset source
                 end else begin
                     clock_sense_reset_n <= 1'b1; // Deassert functional reset source
                 end
            end else begin
                 clock_sense_reset_n <= 1'b1; // Default to inactive if not in DEBUG UDR
            end

            // Existing logic based on ir_in and virtual states
            if (ir_in == DATA) begin
                if (virtual_state_cdr) begin
                    // Reset state for DATA state machine
                    if (offset == 'b0) begin
                        write_state <= ST_HEADER_1;
                    end else begin
                        write_state <= ST_BYPASS;
                    end
                    bypass_bit_counter <= offset;
                    header_in_bit_counter <= 15;
                    write_data_bit_counter <= 0;
                    decode_header_1 <= 1'b0;
                    decode_header_2 <= 1'b0;
                    read_data_all_valid  <= 1'b0;
                    valid_write_data_length_byte_counter  <= 0;

                    // Reset read path state machine
                    read_state <= ST_HEADER;
                    if (|offset[2:0]) begin
                        padded_bit_counter[8:3] <= offset[7:3] + 1'b1;
                        padded_bit_counter[2:0] <= 3'b0;
                    end else begin
                        padded_bit_counter <= {1'b0, offset};
                    end
                    header_out_bit_counter <= 0;
                    read_data_bit_counter <= 0;
                    dr_data_out <= {{7{1'b0}}, data_available}; // Load initial value
                    read_data_valid <= 0;
                end
                if (virtual_state_sdr) begin
                    // Write path logic
                    case (write_state)
                        ST_BYPASS: begin
                            bypass_bit_counter <= bypass_bit_counter - 1'b1;
                            if (bypass