`timescale 1ns/1ps
module I2C_wr_subad_corrected (
    sda,
    scl,
    ack,
    rst_n,
    clk,
    WR,
    RD,
    data,
    test_mode // Added test_mode input for DFT
);

input  rst_n, WR, RD, clk;
input  test_mode; // Added test_mode input
output scl, ack;
inout [7:0] data;
inout  sda;

reg link_sda, link_data;
reg[7:0] data_buf;
reg scl; // This FF generates scl based on negedge clk
reg ack, WF, RF, FF;
reg wr_state;
reg head_state;
reg[8:0] sh8out_state;
reg[9:0] sh8in_state;
reg stop_state;
reg[6:0] main_state;
reg[7:0] data_from_rm;
reg[7:0] cnt_read;
reg[7:0] cnt_write;

assign sda  = (link_sda)   ? data_buf[7] : 1'bz;
assign data = (link_data)  ? data_from_rm : 8'hz;

parameter page_write_num = 10'd34,
          page_read_num  = 10'd32;
parameter
          idle         = 7'b000_0001, // Corrected width
          ready        = 7'b000_0010, // Corrected width
          write_start  = 7'b000_0100, // Corrected width
          addr_write   = 7'b000_1000, // Corrected width
          data_read    = 7'b001_0000, // Corrected width
          stop         = 7'b010_0000, // Corrected width
          ackn         = 7'b100_0000; // Corrected width
parameter
          bit7     = 9'b0_0000_0001,
          bit6     = 9'b0_0000_0010,
          bit5     = 9'b0_0000_0100,
          bit4     = 9'b0_0000_1000,
          bit3     = 9'b0_0001_0000,
          bit2     = 9'b0_0010_0000,
          bit1     = 9'b0_0100_0000,
          bit0     = 9'b0_1000_0000,
          bitend   = 9'b1_0000_0000;
parameter
          read_begin  = 10'b00_0000_0001,
          read_bit7   = 10'b00_0000_0010,
          read_bit6   = 10'b00_0000_0100,
          read_bit5   = 10'b00_0000_1000,
          read_bit4   = 10'b00_0001_0000,
          read_bit3   = 10'b00_0010_0000,
          read_bit2   = 10'b00_0100_0000,
          read_bit1   = 10'b00_1000_0000,
          read_bit0   = 10'b01_0000_0000,
          read_end    = 10'b10_0000_0000;

// SCL generation - Flop clocked by negedge clk
always @(negedge clk or negedge rst_n) begin
    if (!rst_n)
        scl <= 1'b0;
    else
        scl <= ~scl;
end

// Main logic - Flops clocked by posedge clk
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        link_sda    <= 1'b0;
        ack         <= 1'b0;
        RF          <= 1'b0;
        WF          <= 1'b0;
        FF          <= 1'b0;
        main_state  <= idle;
        head_state  <= 1'b0; // Use defined width
        sh8out_state<= bit7;
        sh8in_state <= read_begin;
        stop_state  <= 1'b0; // Use defined width
        cnt_read    <= 8'h1; // Use defined width
        cnt_write   <= 8'h1; // Use defined width
        link_data   <= 1'b0;
        wr_state    <= 1'b0;
        data_buf    <= 8'h0;
        data_from_rm <= 8'h0;
    end
    else begin
        case (main_state)
            idle: begin
                link_data  <= 1'b0;
                link_sda   <= 1'b0;
                if (WR) begin
                    WF <= 1'b1;
                    RF <= 1'b0; // Ensure RF is cleared
                    main_state <= ready;
                end
                else if (RD) begin
                    RF <= 1'b1;
                    WF <= 1'b0; // Ensure WF is cleared
                    main_state <= ready;
                end
                else begin
                    WF <= 1'b0;
                    RF <= 1'b0;
                    main_state <= idle;
                end
            end
            ready: begin
                FF         <= 1'b0;
                main_state <= write_start;
            end
            write_start: begin
                if (FF == 1'b0)
                    shift_head;
                else begin
                    if (WF == 1'b1)
                        data_buf <= {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0}; // Device address + Write
                    else // RF == 1'b1
                        data_buf <= {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1}; // Device address + Read
                    FF           <= 1'b0;
                    sh8out_state <= bit7; // Start shifting from bit7
                    main_state   <= addr_write;
                end
            end
            addr_write: begin
                if (FF == 1'b0)
                    shift8_out;
                else begin // Ack received/handled in shift8_out
                    if (RF == 1'b1) begin
                        data_buf   <= 8'h0; // Prepare for read
                        link_sda   <= 1'b0; // Release SDA for slave ack/data
                        FF         <= 1'b0;
                        cnt_read   <= 8'h1;
                        main_state <= data_read;
                        sh8in_state <= read_begin; // Reset read state machine
                    end
                    else if (WF == 1'b1) begin
                        FF          <= 1'b0;
                        main_state  <= data_read;
                        data_buf    <= data; // Load first data byte to write
                        cnt_write   <= 8'h1;
                        wr_state    <= 1'b0; // Reset write sub-state
                        sh8out_state <= bit7; // Prepare to shift data
                    end
                    ack <= 1'b0; // Deassert ack after checking it in task
                end
            end
            data_read: begin // Handles both data read and data write phases
                if (RF == 1'b1) begin // Reading data from slave
                    if (cnt_read <= page_read_num) begin
                        if (FF == 1'b0) begin // State machine within shift8_in controls FF
                           shift8_in;
                        end else begin // Byte received, prepare for next or stop
                           // Update happens inside shift8_in task based on state
                           // FF is set in read_end state of shift8_in
                           // Reset FF for next byte/ack cycle
                           FF <= 1'b0;
                           link_data <= 1'b0; // Deassert link_data after capture
                        end
                    end
                    else begin
                        main_state <= stop;
                        FF         <= 1'b0; // Prepare for stop condition
                    end
                end
                else if (WF == 1'b1) begin // Writing data to slave
                    if (cnt_write <= page_write_num) begin
                        case (wr_state)
                            1'b0: begin // Prepare to send byte
                                // Use test_mode to bypass scl dependency
                                if (test_mode || !scl) begin // Wait for SCL low
                                    data_buf  <= data; // Load next data byte
                                    link_sda  <= 1'b1; // Drive SDA
                                    sh8out_state<= bit7; // Start shifting from bit7
                                    wr_state    <= 1'b1; // Move to shifting state
                                    ack         <= 1'b0; // Ensure ack is low
                                end
                                else
                                    wr_state <= 1'b0; // Stay in this state
                            end
                            1'b1: begin // Shifting byte out
                                if(FF == 1'b0) begin
                                   shift8_out;
                                end else begin // Byte sent, ack received/handled in shift8_out
                                    // FF is set in bitend state of shift8_out
                                    wr_state <= 1'b0; // Go back to load next byte state
                                    FF <= 1'b0; // Reset