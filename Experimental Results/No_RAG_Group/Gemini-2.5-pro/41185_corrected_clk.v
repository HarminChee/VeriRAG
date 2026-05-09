`default_nettype none
`timescale 1ns / 1ps

module memory_corrected_clk (
  input  wire        pll_ref_clk, // Primary clock input
  input  wire        reset_in,
  input  wire        scan_mode,    // DFT Scan Mode signal
  input  wire        scan_clk,     // DFT Scan Clock signal (usually connected to pll_ref_clk or a dedicated test clock)
  output reg         reset_out,
  output wire        clk,          // Functional clock output
  input  wire        write_req,
  input  wire        read_req,
  input  wire [31:0] data_write,
  output reg  [31:0] data_read,
  input  wire [25:0] addr,
  output wire        busy,
  output wire [ 12: 0]       mem_addr,
  output wire [  2: 0]       mem_ba,
  output wire                mem_cas_n,
  output wire [  0: 0]       mem_cke,
  inout  wire [  0: 0]       mem_clk,
  inout  wire [  0: 0]       mem_clk_n,
  output wire [  0: 0]       mem_cs_n,
  output wire [  1: 0]       mem_dm,
  inout  wire [ 15: 0]       mem_dq,
  inout  wire [  1: 0]       mem_dqs,
  output wire [  0: 0]       mem_odt,
  output wire                mem_ras_n,
  output wire                mem_we_n,
  output wire        flash_dq0,
  input  wire        flash_dq1,
  output wire        flash_wb,
  output wire        flash_holdb,
  output wire        flash_c,
  output wire        flash_sb,
  input  wire         program_req,
  output reg          program_ack,
  input  wire         program_buffer_empty,
  input  wire [31:0]  program_buffer_q,
  output reg          program_buffer_read,
  output reg  [5:0]  state,
  output reg         busy_int
);

localparam VOID                         = 6'd00,
           DELAY                        = 6'd01,
           INIT                         = 6'd02,
           INIT_B                       = 6'd03,
           IDLE                         = 6'd04,
           PROGRAM_WRITE_ENABLE         = 6'd05,
           PROGRAM_WRITE_ENABLE_B       = 6'd06,
           PROGRAM_WRITE_FINISH         = 6'd07,
           PROGRAM_WRITE_FINISH_B       = 6'd08,
           PROGRAM_START                = 6'd09,
           PROGRAM_PAGE                 = 6'd10,
           PROGRAM_SECTOR_ERASE_ADDR1   = 6'd11,
           PROGRAM_SECTOR_ERASE_ADDR2   = 6'd12,
           PROGRAM_SECTOR_ERASE_ADDR3   = 6'd13,
           PROGRAM_SECTOR_ERASE_EXECUTE = 6'd14,
           PROGRAM_SECTOR_ERASE_FINISH  = 6'd15,
           PROGRAM_ADDR1                = 6'd16,
           PROGRAM_ADDR2                = 6'd17,
           PROGRAM_ADDR3                = 6'd18,
           PROGRAM_DAT1                 = 6'd19,
           PROGRAM_DAT2A                = 6'd20,
           PROGRAM_DAT2B                = 6'd21,
           PROGRAM_DAT2C                = 6'd22,
           PROGRAM_DAT2D                = 6'd23,
           PROGRAM_DAT2E                = 6'd24,
           LOAD_0                       = 6'd25,
           LOAD_1                       = 6'd26,
           LOAD_ADDR1                   = 6'd27,
           LOAD_ADDR2                   = 6'd28,
           LOAD_ADDR3                   = 6'd29,
           LOAD_EXECUTE                 = 6'd30,
           LOAD_WORD1                   = 6'd31,
           LOAD_WORD1B                  = 6'd32,
           LOAD_WORD2                   = 6'd33,
           LOAD_WORD3                   = 6'd34,
           LOAD_WORD4                   = 6'd35,
           READ_1                       = 6'd36,
           READ_2                       = 6'd37,
           WRITE_1                      = 6'd38,
           WRITE_2                      = 6'd39;

localparam FLASH_WREN = 8'b0000_0110,
           FLASH_WRDI = 8'b0000_0100,
           FLASH_RFSR = 8'b0111_0000,
           FLASH_RDSR = 8'b0000_0101,
           FLASH_BE   = 8'b1100_0111,
           FLASH_SE   = 8'b1101_1000,
           FLASH_PP   = 8'b0000_0010,
           FLASH_READ = 8'b0000_0011,
           FLASH_RDID = 8'b1001_1111;

wire        phy_clk; // Internal clock from ram_controller
wire        dft_clk; // Clock used for FFs (muxed)

wire        local_ready;
wire [31:0] local_rdata;
wire        local_rdata_valid;
wire        local_init_done;
wire        flash_busy;
wire [7:0]  flash_read_buffer_q;
wire        flash_write_buffer_full;
wire        flash_read_buffer_empty;

reg  [24:0] local_address;
reg         local_write_req;
reg         local_read_req;
reg         local_burstbegin;
reg  [31:0] local_wdata;
reg  [5:0]  state_callback;
reg  [7:0]  delay_counter;
reg  [16:0] pages_to_write;
reg  [16:0] pages_written;
reg         pages_to_write_valid;
reg  [16:0] pages_to_read;
reg  [16:0] pages_read;
reg         pages_to_read_valid;
reg  [6:0]  page_words;
reg  [31:0] page_word;
reg  [23:0] page_address;
reg  [7:0]  flash_instruction;
reg         flash_execute;
reg  [8:0]  flash_bytes_to_read;
reg  [7:0]  flash_write_buffer_data;
reg         flash_write_buffer_write;
reg         flash_read_buffer_read;

// DFT Clock Mux: Select scan_clk in scan_mode, otherwise use functional clock phy_clk
assign dft_clk = scan_mode ? scan_clk : phy_clk;

// Assign functional clock output (might be needed externally)
assign clk = phy_clk;

assign busy = busy_int | program_req | write_req | read_req;

// Main state machine clocked by dft_clk for testability
always @( posedge dft_clk or posedge reset_in ) begin
  if ( reset_in ) begin
    state <= INIT;
    state_callback <= VOID;
    local_write_req <= 1'b0;
    local_read_req <= 1'b0;
    local_burstbegin <= 1'b0;
    data_read <= 32'h0;
    program_buffer_read <= 1'b0;
    flash_execute <= 1'b0;
    flash_read_buffer_read <= 1'b0;
    flash_write_buffer_write <= 1'b0;
    program_ack <= 1'b0;
    busy_int <= 1'b1;
    reset_out <= 1'b0;
    delay_counter <= 8'd0;
    pages_to_write <= 17'd0;
    pages_written <= 17'd0;
    pages_to_write_valid <= 1'b0;
    pages_to_read <= 17'd0;
    pages_read <= 17'd0;
    pages_to_read_valid <= 1'b0;
    page_words <= 7'd0;
    page_word <= 32'd0;
    page_address <= 24'd0;
    flash_instruction <= 8'd0;
    flash_bytes_to_read <= 9'd0;
    flash_write_buffer_data <= 8'd0;
    local_address <= 25'd0;
    local_wdata <= 32'd0;
  end
  else begin
    // Default assignments (reduce toggling)
    local_write_req <= 1'b0;
    local_read_req <= 1'b0;
    local_burstbegin <= 1'b0;
    // data_read assignment moved inside READ_2 state
    program_buffer_read <= 1'b0;
    flash_execute <= 1'b0;
    flash_read_buffer_read <= 1'b0;
    flash_write_buffer_write <= 1'b0;
    program_ack <= 1'b0;
    busy_int <= 1'b1; // Default to busy unless in IDLE and no requests
    reset_out <= 1'b0; // Only asserted during INIT state

    case ( state )
      INIT: begin
        reset_out <= 1'b1; // Assert reset during INIT
        state <= DELAY;
        state_callback <= INIT_B;
        delay_counter <= 8'd2; // Initialize delay
      end
      INIT_B: begin
        if ( program_req ) begin
          state <= PROGRAM_START;
          program_ack <= 1'b1;
        end
        else begin
          // Assuming LOAD_0 is the normal boot sequence
          state <= LOAD_0;
        end
      end
      IDLE: begin
        busy_int <= 1'b0; // Not busy in IDLE unless a request comes in
        if ( program_req ) begin
          state <= PROGRAM_START;
          program_ack <= 1'b1;
          busy_int <= 1'b1;
        end
        else if ( write_req ) begin
          state <= WRITE_1;
          local_wdata <= data_write;
          local_address <= addr[24:0];
          busy_int <= 1'b1;
        end
        else if ( read_req ) begin
          state <= READ_1;
          local_address <= addr[24:0];
          busy_int <= 1'b1;
        end
        // else: stay in IDLE, busy_int remains 0
      end
      DELAY: begin
        if ( delay_counter == 8'd0 ) begin
          state <= state_callback;
          state_callback <= VOID; // Clear callback state
        end
        else begin
          delay_counter <= delay_counter - 8'd1;
        end
      end
      PROGRAM_WRITE_ENABLE: begin
        // Assume flash_busy check is necessary if flash interface takes time
        // if ( !flash_busy ) begin // This check might be implicit if flash interface stalls state machine
          state <= PROGRAM_WRITE_ENABLE_B;
          flash_instruction <= FLASH_WREN;
          flash_bytes_to_read <= 9'd0; // No bytes to read for WREN
          flash_execute <= 1'b1;
        // end
      end
      PROGRAM_WRITE_ENABLE_B: begin
         // Wait for flash command to complete (flash_busy to go low)
        if ( !flash_busy ) begin
          state <= state_callback; // Proceed to next step after WREN
          state_callback <= VOID;
        end
      end
      PROGRAM_WRITE_FINISH: begin
        // Wait for previous operation (e.g., PP, SE) to finish
        if ( !flash_busy ) begin
          state <= PROGRAM_WRITE_FINISH_B;
          flash_instruction <= FLASH_RDSR; // Read Status Register
          flash_bytes_to_read <= 9'd1;     // Read 1 byte
          flash_execute <= 1'b1;
        end
      end
      PROGRAM_WRITE_FINISH_B: begin
        // Wait for RDSR command to execute and data to be available
        if ( !flash_busy && !flash_read_buffer_empty ) begin
          flash_read_buffer_read <= 1'b1; // Read the status byte
          // Check WIP (Write In Progress) bit (typically bit 0)
          if ( ~flash_read_buffer_q[0] ) begin // If WIP bit is 0, operation is complete
            state <= state_callback; // Proceed to next step
            state_callback <= VOID;
          end
          else begin // WIP bit is 1, operation still in progress
            state <= PROGRAM_WRITE_FINISH; // Re-check status later
          end
        end
      end
      PROGRAM_START: begin
         // Optional: Wait for flash_busy if needed, otherwise proceed
         // if ( !flash_busy ) begin
          state <= PROGRAM_PAGE;
          pages_to_write_valid <= 1'b0; // Invalidate until first word read
          pages_written <= 17'd0;
        // end
      end
      PROGRAM_PAGE: begin
        if ( pages_to_write_valid && (pages_written == pages_to_write) ) begin
          // All pages programmed, go back to load/idle sequence
          state <= LOAD_0; // Or IDLE if loading isn't needed after programming
        end
        else begin
          // Start programming next page (or first page)
          state <= PROGRAM_WRITE_ENABLE; // Enable write first
          if ( (pages_written % 16'd256) == 0 ) begin // Erase sector every 256 pages
            state_callback <= PROGRAM_SECTOR_ERASE_ADDR1;
          end
          else begin // Just program page
            state_callback <= PROGRAM_ADDR1;
          end
          page_words <= 7'd0; // Reset word counter for the page
          // Calculate flash page address (adjust offset/mapping as needed)
          page_address <= {pages_written[15:0] + 16'h8000, 8'h00}; // Example mapping
        end
      end
      PROGRAM_SECTOR_ERASE_ADDR1: begin
        // Assuming flash interface buffers writes or stalls state machine
        state <= PROGRAM_SECTOR_ERASE_ADDR2;
        flash_write_buffer_data <= page_address[23:16];
        flash_write_buffer_write <= 1'b1;
      end
      PROGRAM_SECTOR_ERASE_ADDR2: begin
        state <= PROGRAM_SECTOR_ERASE_ADDR3;
        flash_write_buffer_data <= page_address[15:8];
        flash_write_buffer_write <= 1'b1;
      end
      PROGRAM_SECTOR_ERASE_ADDR3: begin
        state <= PROGRAM_SECTOR_ERASE_EXECUTE;
        flash_write_buffer_data <= page_address[7:0];
        flash_write_buffer_write <= 1'b1;
      end
      PROGRAM_SECTOR_ERASE_EXECUTE: begin
        // Wait for address bytes to be written if buffer is used
        // if (!flash_write_buffer_full) // Or similar check
        state <= PROGRAM_WRITE_FINISH; // Go check status after SE command
        state_callback <= PROGRAM_SECTOR_ERASE_FINISH;
        flash_instruction <= FLASH_SE; // Sector Erase command
        flash_bytes_to_read <= 9'd0;
        flash_execute <= 1'b1;
      end
      PROGRAM_SECTOR_ERASE_FINISH: begin
        // After sector erase is confirmed done (by PROGRAM_WRITE_FINISH)
        state <= PROGRAM_WRITE_ENABLE; // Need WREN again for PP
        state_callback <= PROGRAM_ADDR1; // Start Page Program sequence
      end
      PROGRAM_ADDR1: begin
        state <= PROGRAM_ADDR2;
        flash_write_buffer_data <= page_address[23:16];
        flash_write_buffer_write <= 1'b1;
      end
      PROGRAM_ADDR2: begin
        state <= PROGRAM_ADDR3;
        flash_write_buffer_data <= page_address[15:8];
        flash_write_buffer_write <= 1'b1;
      end
      PROGRAM_ADDR3: begin
        state <= PROGRAM_DAT1; // Ready to accept data after address
        flash_write_buffer_data <= page_address[7:0];
        flash_write_buffer_write <= 1'b1;
      end
      PROGRAM_DAT1: begin
        // Wait for address bytes and previous data byte (if any) to be sent
        // if (!flash_write_buffer_full)
        if ( page_words == 7'd64 ) begin // Assuming 64 words (256 bytes) per page
          state <= PROGRAM_WRITE_FINISH; // Check PP status after sending command
          state_callback <= PROGRAM_PAGE; // Go back to decide next page/finish
          flash_instruction <= FLASH_PP; // Page Program command
          flash_execute <= 1'b1;
          flash_bytes_to_read <= 9'd0;
          pages_written <= pages_written + 17'd1;
        end
        else if ( !program_buffer_empty ) begin // If data available and page not full
          program_buffer_read <= 1'b1; // Request next word from buffer
          // state <= DELAY; // Delay might not be needed if buffer provides data quickly
          // delay_counter <= 0;
          state_callback <= PROGRAM_DAT2A; // Process the read data
          state <= PROGRAM_DAT2A; // Go directly if no delay needed
        end
        // else: Wait for data or page full condition
      end
      PROGRAM_DAT2A: begin // Data received from program_buffer
        state <= PROGRAM_DAT2B;
        page_word <= program_buffer_q; // Latch the data word
        if ( !pages_to_write_valid && (page_words == 0) ) begin // First word contains page count
          pages_to_write <= program_buffer_q[16:0]; // Extract page count
          pages_to_write_valid <= 1'b1;
        end
      end
      PROGRAM_DAT2B: begin // Send first byte
        state <= PROGRAM_DAT2C;
        flash_write_buffer_data <= page_word[31:24];
        flash_write_buffer_write <= 1'b1;
      end
      PROGRAM_DAT2C: begin // Send second byte
        state <= PROGRAM_DAT2D;
        flash_write_buffer_data <= page_word[23:16];
        flash_write_buffer_write <= 1'b1;
      end
      PROGRAM_DAT2D: begin // Send third byte
        state <= PROGRAM_DAT2E;
        flash_write_buffer_data <= page_word[15:8];
        flash_write_buffer_write <= 1'b1;
      end
      PROGRAM_DAT2E: begin // Send fourth byte
        state <= PROGRAM_DAT1; // Go back to check if page full or get next word
        flash_write_buffer_data <= page_word[7:0];
        flash_write_buffer_write <= 1'b1;
        page_words <= page_words + 7'd1; // Increment word counter
      end
      LOAD_0: begin // Start of loading sequence from flash to RAM
        state <= LOAD_1;
        pages_to_read_valid <= 1'b0; // Invalidate until first word read
        pages_read <= 17'd0;
        page_address <= 24'd0; // Reset address pointer
      end
      LOAD_1: begin
        if ( pages_to_read_valid && (pages_read == pages_to_read) ) begin
          // Finished loading all required pages
          state <= IDLE;
        end
        else begin
          // Start reading next page
          state <= LOAD_ADDR1;
          // Calculate flash page address for reading (adjust offset/mapping as needed)
          page_address <= {pages_read[15:0] + 16'h8000, 8'h00}; // Example mapping
        end
      end
      LOAD_ADDR1: begin
        state <= LOAD_ADDR2;
        flash_write_buffer_data <= page_address[23:16];
        flash_write_buffer_write <= 1'b1;
      end
      LOAD_ADDR2: begin
        state <= LOAD_ADDR3;
        flash_write_buffer_data <= page_address[15:8];
        flash_write_buffer_write <= 1'b1;
      end
      LOAD_ADDR3: begin
        state <= LOAD_EXECUTE;
        flash_write_buffer_data <= page_address[7:0];
        flash_write_buffer_write <= 1'b1;
      end
      LOAD_EXECUTE: begin
        // Wait for address bytes to be sent if needed
        // if (!flash_write_buffer_full)
        state <= LOAD_WORD1; // Start reading data words
        flash_instruction <= FLASH_READ; // Flash Read command
        flash_execute <= 1'b1;
        flash_bytes_to_read <= 9'd256; // Read 256 bytes (64 words)
        page_words <= 7'd0; // Reset word counter for the page
      end
      LOAD_WORD1: begin
        // Wait for read command to finish executing (flash_busy=0) and data to be ready
        if ( !flash_busy && !flash_read_buffer_empty ) begin
          if ( page_words == 7'd64 ) begin // Page read complete
            pages_read <= pages_read + 17'd1; // Increment page counter
            state <= LOAD_1; // Go back to check if more pages needed
          end
          else begin // Read next byte
            state <= LOAD_WORD1B;
            flash_read_buffer_read <= 1'b1; // Read first byte of the word
          end
        end
      end
      LOAD_WORD1B: begin // First byte read
         if (!flash_read_buffer_empty) begin // Check if next byte is ready
            state <= LOAD_WORD2;
            flash_read_buffer_read <= 1'b1; // Read second byte
            page_word[31:24] <= flash_read_buffer_q; // Store first byte
         end
      end
      LOAD_WORD2: begin // Second byte read
         if (!flash_read_buffer_empty) begin
            state <= LOAD_WORD3;
            flash_read_buffer_read <= 1'b1; // Read third byte
            page_word[23:16] <= flash_read_buffer_q; // Store second byte
         end
      end
      LOAD_WORD3: begin // Third byte read
         if (!flash_read_buffer_empty) begin
            state <= LOAD_WORD4;
            flash_read_buffer_read <= 1'b1; // Read fourth byte
            page_word[15:8] <= flash_read_buffer_q; // Store third byte
         end
      end
      LOAD_WORD4: begin // Fourth byte read
        if (!flash_read_buffer_empty) begin
            // Assemble the full word
            local_wdata <= {page_word[31:8], flash_read_buffer_q};
            page_word[7:0] <= flash_read_buffer_q; // Store fourth byte locally if needed

            // Determine destination RAM address
            local_address <= {2'b00, pages_read[15:0], page_words[5:0]}; // Example RAM mapping

            // Check if this is the first word (contains page count)
            if ( page_words == 0 && pages_read == 0 ) begin
              // Extract total pages to read (adjust bit positions as needed)
              pages_to_read <= {page_word[15:8], flash_read_buffer_q}[16:0];
              pages_to_read_valid <= 1'b1;
            end

            page_words <= page_words + 7'd1; // Increment word counter for the page
            state <= WRITE_1; // Go write the assembled word to RAM
            state_callback <= LOAD_WORD1; // Return to LOAD_WORD1 after write
         end
      end
      WRITE_1: begin // Request RAM write
        if ( local_ready ) begin // Wait for RAM controller to be ready
          state <= WRITE_2;
          local_write_req <= 1'b1;
          local_burstbegin <= 1'b1; // Assuming single word writes for simplicity
        end
      end
      WRITE_2: begin // Wait for RAM write to complete (implicitly handled by local_ready going low then high again)
        if ( local_ready ) begin // Assumes ready drops during write, then comes high
          if ( state_callback != VOID ) begin // Check if returning from a subroutine (like LOAD_WORD4)
            state <= state_callback;
            state_callback <= VOID;
          end
          else begin // Normal write request finished
            busy_int <= 1'b0; // Write complete, go idle
            state <= IDLE;
          end
        end
      end
      READ_1: begin // Request RAM read
        if ( local_ready ) begin // Wait for RAM controller to be ready
          state <= READ_2;
          local_read_req <= 1'b1;
          local_burstbegin <= 1'b1; // Assuming single word reads
        end
      end
      READ_2: begin // Wait for RAM read data
        if ( local_ready & local_rdata_valid ) begin // Wait for ready and valid data
          data_read <= local_rdata; // Capture read data
          if ( state_callback != VOID ) begin // Check if returning from subroutine
            state <= state_callback;
            state_callback <= VOID;
          end
          else begin // Normal read request finished
            busy_int <= 1'b0; // Read complete, go idle
            state <= IDLE;
          end
        end
      end
      default: begin
         state <= IDLE; // Default to IDLE state
      end
    endcase
  end
end

// Instantiate RAM Controller
// Assuming ram_controller handles its own clocking internally but provides phy_clk
ram_controller ram_controller_inst (
  .pll_ref_clk     ( pll_ref_clk ),      // Primary clock input
  .phy_clk         ( phy_clk ),          // Output clock used functionally
  .global_reset_n  ( ~reset_in ),
  .soft_reset_n    ( 1'b1 ),             // Assuming no soft reset used here
  .reset_phy_clk_n ( /* connect appropriately if needed */ ),
  .local_address   ( local_address ),
  .local_write_req ( local_write_req ),
  .local_read_req  ( local_read_req ),
  .local_burstbegin( local_burstbegin ),
  .local_wdata     ( local_wdata ),
  .local_be        ( 4'hF ),             // Assuming full byte enable
  .local_size      ( 3'd1 ),             // Assuming word size access
  .local_ready     ( local_ready ),
  .local_rdata     ( local_rdata ),
  .local_rdata_valid( local_rdata_valid ),
  .local_refresh_ack( /* unused */ ),
  .local_init_done ( local_init_done ),
  .mem_addr        ( mem_addr ),
  .mem_ba          ( mem_ba ),
  .mem_cas_n       ( mem_cas_n ),
  .mem_cke         ( mem_cke ),
  .mem_clk         ( mem_clk ),
  .mem_clk_n       ( mem_clk_n ),
  .mem_cs_n        ( mem_cs_n ),
  .mem_dm          ( mem_dm ),
  .mem_dq          ( mem_dq ),
  .mem_dqs         ( mem_dqs ),
  .mem_odt         ( mem_odt ),
  .mem_ras_n       ( mem_ras_n ),
  .mem_we_n        ( mem_we_n ),
  .aux_full_rate_clk( /* unused */ ),
  .aux_half_rate_clk( /* unused */ ),
  .reset_request_n ( /* unused */ )
);

// Instantiate Flash Interface
// Clocked by dft_clk for testability
flash_interface flash_interface_inst (
  .clk                 ( dft_clk ),      // Use muxed clock
  .reset               ( reset_out ),    // Use controlled reset
  .instruction         ( flash_instruction ),
  .execute             ( flash_execute ),
  .bytes_to_read       ( flash_bytes_to_read ),
  .busy                ( flash_busy ),
  .write_buffer