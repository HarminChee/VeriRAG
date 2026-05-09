`timescale 1ns / 1ps
module spi_bonus_corrected (clk, reset, din, dout, wren, rden, addr, mosi, miso, sclk);
input clk, reset, wren, rden;
input [7:0] din;
output [7:0] dout;
input [1:0] addr;
output mosi;
input miso;
output sclk;

`define TXreg     2'b00
`define RXreg     2'b01
`define control   2'b10
`define TXFULL    control[0]
`define DATARDY   control[1]
`define WAIT      2'b00
`define SHIFT     2'b01
`define SHIFT1    2'b10
`define WRITE     2'b11

reg [7:0] control_reg, shiftin, shiftout, dout_reg; // Renamed control to control_reg, dout to dout_reg
reg wr_tx, wr_rx, rd_tx, sout, sin, spi, wr_control, enspi, clr_count, rd_rx;
reg [6:0] spiclk;
reg [1:0] pstate, nstate;
reg [3:0] counter;
reg spi_dly; // Added register to detect spi edge

wire rx_empty, tx_full, tx_empty;
wire [7:0] txout, dout_rx;

assign mosi = shiftout[7];
assign sclk = spi;
// Assign internal control register bits to defines for clarity elsewhere if needed (or use control_reg directly)
assign `TXFULL = control_reg[0];
assign `DATARDY = control_reg[1];

// Use dout_reg for assignments, assign dout output from dout_reg
assign dout = dout_reg;

txreg txfifo(
  .clk    (clk),
  .rst    (reset),
  .din    (din),
  .wr_en  (wr_tx),
  .rd_en  (rd_tx),
  .dout   (txout),
  .full   (tx_full),
  .empty  (tx_empty)
);

txreg rxfifo(
  .clk    (clk),
  .rst    (reset),
  .din    (shiftin),
  .wr_en  (wr_rx),
  .rd_en  (rd_rx),
  .dout   (dout_rx),
  .full   (rx_full),
  .empty  (rx_empty)
);

always @(posedge clk or posedge reset) begin
    if(reset) begin
        spiclk <= 7'b0; // Corrected width
        spi <= 1'b0;
    end
    else begin
        // Removed redundant begin/end
        if(enspi) begin
            // Simplified clock generation logic
            if(spiclk == 7'd24) begin // End of high phase
                spi <= 1'b0;
                spiclk <= spiclk + 1;
            end else if (spiclk == 7'd49) begin // End of low phase
                spi <= 1'b1; // Goes high for next cycle start
                spiclk <= 7'b0; // Reset counter
            end else if (spiclk == 7'd0) begin // Start of high phase
                 spi <= 1'b1;
                 spiclk <= spiclk + 1;
            end else begin
                 spiclk <= spiclk + 1; // Continue counting
            end
        end
        else begin
            spiclk <= 7'b0;
            spi <= 1'b0;
        end
    end
end

// Combinational logic for dout and read enables
always @* begin
    dout_reg = 8'b0; // Default assignment
    rd_rx = 1'b0;    // Default assignment
    wr_control = 1'b0; // Default assignment for control write enable

    case(addr)
        `RXreg: begin
            if(rden) begin
                rd_rx = 1'b1;
                dout_reg = dout_rx; // Read from RX FIFO
            end
        end
        `control: begin
            if(rden) begin
                dout_reg = control_reg; // Read from control register
            end
            if(wren) begin // Handle writing to control register
                wr_control = 1'b1;
            end
        end
        // Default case can be added if needed
    endcase
end

// Combinational logic for write enables based on address
always @* begin
    wr_tx = 1'b0; // Default assignment
    // wr_control handled in the block above
    case(addr)
        `TXreg: begin
            if(wren)
                wr_tx = 1'b1; // Write to TX FIFO
            end
        // Control write handled above
    endcase
end

// Control register logic
always @(posedge clk or posedge reset) begin
    if(reset)
        control_reg <= 8'b0;
    else begin
        // Update status bits based on FIFO status wires
        control_reg[1] <= ~rx_empty; // DATARDY
        control_reg[0] <= tx_full;   // TXFULL
        // Allow writing to other control bits via wren/addr logic
        if(wr_control) // Use the combinational signal
            control_reg <= din; // Write external data if enabled
        // Note: Status bits (0 and 1) will be overwritten if wr_control is high!
        // Consider masking if only certain bits should be writable:
        // if(wr_control)
        //    control_reg[7:2] <= din[7:2]; // Example: only write bits 7:2
    end
end

// Added register to delay spi signal for edge detection
always @(posedge clk or posedge reset) begin
    if (reset) begin
        spi_dly <= 1'b0;
    end else begin
        spi_dly <= spi;
    end
end

// Counter logic - MODIFIED TO USE CLK
always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 4'b0000;
    // Increment counter on the detected positive edge of spi when enspi is high.
    // Stop incrementing once it reaches 8.
    // Reset the counter when enspi is low (i.e., when returning to WAIT state or initially).
    end else if (enspi) begin
        // Increment on detected rising edge of spi:
        if (~spi_dly && spi) begin
            if (counter < 4'b1000) begin // Count from 0 to 7 (8 edges)
                 counter <= counter + 1;
            end
            // Note: counter reaches 8 *after* the 8th rising edge clock cycle
        end
    end else begin // Reset counter when SPI transfer is not active (enspi is low)
        counter <= 4'b0000;
    end
end

// Shift register for MOSI output
always @(posedge clk or posedge reset) begin
    if(reset)
        shiftout <= 8'b0;
    else begin
        if(rd_tx) // Load data from TX FIFO when starting
            shiftout <= txout;
        else if(sout) // Shift data out on falling edge of sclk (approximated by spi high in SHIFT1->SHIFT)
            shiftout <= {shiftout[6:0], 1'b0}; // Shift left (MSB first)
    end
end

// Shift register for MISO input
always @(posedge clk or posedge reset) begin
    if(reset)
        shiftin <= 8'b0;
    else begin
        if(sin) // Sample data on rising edge of sclk (approximated by spi low in SHIFT->SHIFT1)
            shiftin <= {shiftin[6:0], miso}; // Shift in MISO data
    end
end

// State machine flops
always @(posedge clk or posedge reset) begin
    if(reset)
        pstate <= `WAIT;
    else
        pstate <= nstate;
end

// State machine combinational logic
always @* begin
    // Default assignments
    rd_tx = 1'b0;
    sout = 1'b0;
    enspi = 1'b0;
    // clr_count = 1'b0; // Not used? Remove if unnecessary
    wr_rx = 1'b0;
    sin = 1'b0;
    nstate = pstate; // Default: stay in current state

    case(pstate)
        `WAIT: begin
            if(~tx_empty) begin // If data is available in TX FIFO
                rd_tx = 1'b1;   // Read data from TX FIFO into shiftout register
                enspi = 1'b1;   // Enable SPI clock generation
                nstate = `SHIFT; // Move to SHIFT state
            end
            // Stay in WAIT otherwise
        end
        `SHIFT: begin // SPI clock (sclk/spi) is HIGH in this state
            enspi = 1'b1; // Keep SPI clock running
            // On the falling edge of spi (transition to SHIFT1)
            if(~spi) begin // Check if spi signal went low (end of high phase)
                sin = 1'b1; // Enable sampling MISO on next clock edge (in SHIFT1)
                // Check if 8 bits have been shifted (counter reached 8 after last rising edge)
                if(counter == 4'b1000) begin
                    nstate = `WRITE; // All bits shifted, move to WRITE
                    enspi = 1'b0; // Disable SPI clock after this cycle
                end else begin
                    nstate = `SHIFT1; // More bits to shift, wait for clock low phase
                end
            end
            // Stay in SHIFT while spi is high
        end
        `SHIFT1: begin // SPI clock (sclk/spi) is LOW in this state
            enspi = 1'b1; // Keep SPI clock running
            // On the rising edge of spi (transition back to SHIFT)
            if(spi) begin // Check if spi signal went high (end of low phase)
                sout = 1'b1; // Enable shifting MOSI data out on next clock edge (in SHIFT)
                nstate = `SHIFT; // Move back to SHIFT for next bit
            end
            // Stay in SHIFT1 while spi is low
        end
        `WRITE: begin // Write received data to RX FIFO
            wr_rx = 1'b1;   // Enable writing shiftin register to RX FIFO
            nstate = `WAIT; // Return to WAIT state
            // enspi remains 0 from previous state exit
        end
        default: nstate = `WAIT; // Default to WAIT state
    endcase
end

endmodule

// Dummy TXREG module (replace with actual FIFO implementation if available)
module txreg (
    clk, rst, din, wr_en, rd_en, dout, full, empty
);
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 4; // Example depth
    parameter ADDR_WIDTH = $clog2(DEPTH);

    input clk, rst;
    input [DATA_WIDTH-1:0] din;
    input wr_en, rd_en;
    output reg [DATA_WIDTH-1:0] dout;
    output full, empty;

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0] wr_ptr, rd_ptr; // Pointers need one extra bit for full/empty detection
    reg [ADDR_WIDTH:0] count; // Keep track of item count

    wire wr_ptr_next = wr_ptr + 1;
    wire rd_ptr_next = rd_ptr + 1;

    assign empty = (count == 0);
    assign full = (count == DEPTH);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
            dout <= 0; // Reset output
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= din;
                wr_ptr <= wr_ptr_next;
            end

            if (rd_en && !empty) begin
                dout <= mem[rd_ptr[ADDR_WIDTH-1:0]]; // Read happens combinationally, pointer updates on edge
                rd_ptr <= rd_ptr_next;
            end
        end
    end

     always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end else begin
            if (wr_en && !full && !(rd_en && !empty)) begin // Write only
                count <= count + 1;
            end else if (!wr_en && (rd_en && !empty)) begin // Read only
                count <= count - 1;
            end // If both happen or neither happens, count remains the same
        end
     end

endmodule