`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module altera_jtag_streaming #(
    parameter PURPOSE = 0,
    parameter UPSTREAM_FIFO_SIZE = 0,
    parameter DOWNSTREAM_FIFO_SIZE = 0,
    parameter MGMT_CHANNEL_WIDTH = -1
) (
    input wire test_mode, // Added DFT test mode input
    input  wire       tck,
    input  wire       tdi,
    output reg        tdo,
    input  wire [2:0] ir_in,
    input  wire       virtual_state_cdr,
    input  wire       virtual_state_sdr,
    input  wire       virtual_state_udr,
    input  wire       reset_n, // Primary reset (active low)
    output wire [7:0] source_data,
    output wire       source_valid,
    input  wire [7:0] sink_data,
    input  wire       sink_valid,
    output wire       sink_ready,
    input  wire       clock_to_sample,
    input  wire       reset_to_sample,
    output reg        resetrequest,
    output wire       debug_reset, // Original output name
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

    // DFT Fix for clock_sensor reset (ACNCPI)
    wire clock_sensor_rst_n_muxed;
    // Use primary reset_n (active low) in test mode, functional reset otherwise.
    assign clock_sensor_rst_n_muxed = test_mode ? reset_n : clock_sense_reset_n_sync;

    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) clock_sensor_synchronizer (
        .clk(tck),
        .reset_n(reset_n), // Use primary reset for synchronizer
        .din(clock_sensor),
        .dout(clock_sensor_sync));
    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) reset_to_sample_synchronizer (
        .clk(tck),
        .reset_n(reset_n), // Use primary reset for synchronizer
        .din(reset_to_sample),
        .dout(reset_to_sample_sync));
    altera_std_synchronizer #(.depth(SYSCLK_TO_TCK_SYNC_DEPTH)) clock_to_sample_div2_synchronizer (
        .clk(tck),
        .reset_n(reset_n), // Use primary reset for synchronizer
        .din(clock_to_sample_div2),
        .dout(clock_to_sample_div2_sync));
    altera_std_synchronizer #(.depth(TCK_TO_SYSCLK_SYNC_DEPTH)) clock_sense_reset_n_synchronizer (
        .clk(clock_to_sample),
        // Use primary reset for the synchronizer itself for better DFT
        .reset_n(reset_n),
        .din(clock_sense_reset_n), // Synchronize the internally generated reset control
        .dout(clock_sense_reset_n_sync));

    // Modified always block for clock_sensor using muxed reset
    always @ (posedge clock_to_sample or negedge clock_sensor_rst_n_muxed) begin
        // Use muxed reset (active low)
        if (~clock_sensor_rst_n_muxed) begin
            clock_sensor <= 1'b0;
        end else begin
            clock_sensor <= 1'b1;
        end
    end

    always @ (posedge clock_to_sample or negedge reset_n) begin // Added primary reset
        if (~reset_n) begin
             clock_to_sample_div2 <= 1'b0;
        end else begin
             clock_to_sample_div2 <= ~clock_to_sample_div2;
        end
    end

    // Main state machine and logic clocked by tck, reset by reset_n
    always @ (posedge tck or negedge reset_n) begin
        if (~reset_n) begin // Reset logic for FFs clocked by tck
            write_state <= ST_BYPASS;
            read_state  <= ST_HEADER;
            dr_data_in  <= 'b0;
            dr_data_out <= 'b0;
            dr_loopback <= 'b0;
            dr_debug    <= 'b0;
            dr_info     <= 'b0;
            dr_control  <= 'b0;
            // dr_mgmt reset handled in generate block if present
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
            clock_sense_reset_n <= 1'b1; // Default state for internal reset control
            resetrequest <= 1'b0; // Assuming resetrequest should be reset

        end else begin // Functional logic
            // Default assignments for signals driven in specific states/conditions
            idle_remover_sink_valid <= 1'b0;
            idle_inserter_source_ready <= 1'b0;
            decode_header_1 <= decode_header_1; // Keep current value unless changed
            decode_header_2 <= decode_header_2; // Keep current value unless changed

            if (ir_in == DATA) begin
                if (virtual_state_cdr) begin
                    if (offset == 'b0) begin
                        write_state <= ST_HEADER_1;
                    end else begin
                        write_state <= ST_BYPASS;
                    end
                    bypass_bit_counter <= offset;
                    header_in_bit_counter <= 15;
                    write_data_bit_counter <= 0; // Reset on CDR
                    decode_header_1 <= 1'b0;
                    decode_header_2 <= 1'b0;
                    read_data_all_valid  <= 1'b0;
                    valid_write_data_length_byte_counter  <= 0; // Reset on CDR

                    // Read side CDR logic
                    read_state <= ST_HEADER;
                    if (|offset[2:0]) begin
                        padded_bit_counter[8:3] <= offset[7:3] + 1'b1;
                        padded_bit_counter[2:0] <= 3'b0;
                    end else begin
                        padded_bit_counter <= {1'b0, offset};
                    end
                    header_out_bit_counter <= 0; // Reset on CDR
                    read_data_bit_counter <= 0; // Reset on CDR
                    dr_data_out <= {{7{1'b0}}, data_available}; // Capture availability on CDR
                    read_data_valid <= 0; // Reset on CDR
                end

                if (virtual_state_sdr) begin
                    // Write side SDR logic
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
                            if (decode_header_1) begin // Check if flag was set in previous cycle
                                decode_header_1 <= 1'b0; // Consume flag
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
                            if (decode_header_2) begin // Check if flag was set in previous cycle
                                decode_header_2 <= 1'b0; // Consume flag
                                case (write_data_length)
                                    3'b111:  valid_write_data_length_byte_counter <= decoded_scan_length + 1'b1;
                                    3'b000:  valid_write_data_length_byte_counter <= 'b0;
                                    default: valid_write_data_length_byte_counter <= decoded_write_data_length;
                                endcase
                            end
                            write_data_bit_counter <= write_data_bit_counter - 1'b1;
                            write_data_valid <= (valid_write_data_length_byte_counter != 0); // Update based on counter
                            if (write_data_byte_aligned && write_data_valid) begin // Check validity here
                                valid_write_data_length_byte_counter <= valid_write_data_length_byte_counter - 1'b1;
                                idle_remover_sink_valid <= 1'b1; // Assert valid for one cycle
                                idle_remover_sink_data <= {tdi, dr_data_in[7:1]}; // Latch data on byte boundary
                            end
                        end
                    endcase

                    // Read side SDR logic
                    dr_data_out <= {1'b0, dr_data_out[7:1]}; // Shift out previous bit
                    case (read_state)
                        ST_HEADER: begin
                            header_out_bit_counter <= header_out_bit_counter - 1'b1;
                            if (header_out_bit_counter == 2) begin
                                if (padded_bit_counter == 0) begin
                                    idle_inserter_source_ready <= read_data_all_valid; // Request data if needed
                                end
                            end
                            if (header_out_bit_counter == 1) begin
                                if (padded_bit_counter == 0) begin
                                    read_state <= ST_READ_DATA;
                                    read_data_valid <= read_data_all_valid || (scan_length_byte_counter<=decoded_read_data_length+1);
                                    // Latch data on state transition if valid
                                    dr_data_out <= read_data_valid ? idle_inserter_source_data : 8'h4a;
                                end else begin
                                    read_state <= ST_PADDED;
                                    padded_bit_counter <= padded_bit_counter - 1'b1;
                                    idle_inserter_source_ready <= 1'b0; // Don't request data yet
                                    dr_data_out <= 8'h4a; // Output padding
                                end
                            end
                        end
                        ST_PADDED: begin
                            padded_bit_counter <= padded_bit_counter - 1'b1;
                            if (padded_bit_byte_aligned) begin
                                dr_data_out <= 8'h4a; // Output padding
                            end
                            if (padded_bit_counter == 1) begin // Check if next cycle is last padding bit
                                idle_inserter_source_ready <= read_data_all_valid; // Request data if needed
                            end
                            if (padded_bit_counter == 0) begin
                                read_state <= ST_READ_DATA;
                                read_data_valid <= read_data_all_valid || (scan_length_byte_counter<=decoded_read_data_length+1);
                                // Latch data on state transition if valid
                                dr_data_out <= read_data_valid ? idle_inserter_source_data : 8'h4a;
                            end
                        end
                        ST_READ_DATA: begin
                            read_data_bit_counter <= read_data_bit_counter - 1'b1;
                            if (read_data_bit_counter == 2) begin // Check if next cycle is last bit of byte
                                idle_inserter_source_ready <= bytestream_end ? 1'b0 : read_data_valid; // Request next byte if needed
                            end
                            if (read_data_byte_aligned) begin
                                if (~bytestream_end) begin
                                    scan_length_byte_counter <= scan_length_byte_counter - 1'b1;
                                end
                                // Update validity for the *next* byte based on the new counter value
                                read_data_valid <= read_data_all_valid || (scan_length_byte_counter > decoded_read_data_length + 1); // Check if more valid data expected
                                // Latch new data if valid and not end of stream
                                dr_data_out <= (read_data_valid & ~bytestream_end) ? idle_inserter_source_data : 8'h4a;
                            end
                        end
                    endcase
                end // virtual_state_sdr for DATA
            end // ir_in == DATA

            if (ir_in == LOOPBACK) begin
                if (virtual_state_cdr) begin
                    dr_loopback <= 1'b0;
                end
                if (virtual_state_sdr) begin
                    dr_loopback <= tdi;
                end
            end

            if (ir_in == DEBUG) begin
                if (virtual_state_cdr) begin
                    // Capture synchronized status signals
                    dr_debug <= {clock_sensor_sync, clock_to_sample_div2_sync, reset_to_sample_sync};
                end
                if (virtual_state_sdr) begin
                    dr_debug <= {1'b0, dr_debug[2:1]}; // Shift out
                end
                // Control for internally generated clock_sense_reset_n
                if (virtual_state_udr) begin
                    clock_sense_reset_n <= 1'b0; // Assert internal reset control
                end else begin
                    clock_sense_reset_n <= 1'b1; // Deassert internal reset control
                end
            end

            if (ir_in == INFO) begin
                if (virtual_state_cdr) begin
                    dr_info <= {PURPOSE[2:0], UPSTREAM_ENCODED_SIZE[3:0], DOWNSTREAM_ENCODED_SIZE[3:0]};
                end
                if (virtual_state_sdr) begin
                    dr_info <= {1'b0, dr_info[10:1]}; // Shift out
                end
            end

            if (ir_in == CONTROL) begin
                if (virtual_state_cdr) begin
                    dr_control <= 'b0;
                end
                if (virtual_state_sdr) begin
                    dr_control <= {tdi, dr_control[8:1]};
                end
                if (virtual_state_udr) begin
                    {resetrequest, offset} <= dr_control; // Update control registers
                end
            end
        end // else: !if(~reset_n)
    end // always @ (posedge tck or negedge reset_n)

    // Combinational assignment for tdo based on current state and DR register LSB
    always @ * begin
        tdo = 1'b0; // Default assignment
        if (virtual_state_sdr) begin // tdo only active during Shift-DR
            case (ir_in)
                DATA:     tdo = dr_data_out[0];
                LOOPBACK: tdo = dr_loopback;
                DEBUG:    tdo = dr_debug[0];
                INFO:     tdo = dr_info[0];
                CONTROL:  tdo = dr_control[0];
                MGMT:     tdo = dr_mgmt[0]; // Handled in generate block if present
                default:  tdo = 1'b0;
            endcase
        end
    end

    // Instantiation of idle remover/inserter modules