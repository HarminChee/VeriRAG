:1_corrected_cdf.v
`define SPICLOCKDIV 6
`define STATUS_READ 8'hAA

module spi_clock_divisor (clkin, reset, clkoutp, clkoutn);
    parameter clkdiv = 2;
    input     clkin;
    input     reset;
    output    clkoutp, clkoutn;
    wire      clkin;
    reg       clkoutp, clkoutn;
    reg       clkbase;
    reg [6:0] clkcnt;

    always @(posedge clkin or negedge reset)
      if (~reset)
        begin
           clkcnt  <= 0;
           clkbase <= 0;
           clkoutp <= 0;
           clkoutn <= 0;
        end
      else
        begin
           clkoutp <= 0;
           clkoutn <= 0;
           if (clkcnt == clkdiv)
             begin
                clkcnt  <= 0;
                clkbase <= ~clkbase;
                clkoutp <= ~clkbase;
                clkoutn <= clkbase;
             end
           else clkcnt <= clkcnt + 7'd1;
        end
endmodule

// ... existing code ...

module spi_emit_data (clock, reset, enable,
                       data, count, sclk, sdo, done,
                       spiclockp, spiclockn, picready, starting);
    input clock, spiclockp, spiclockn;
    input reset;
    input [127:0] data;
    input [4:0] count;
    input       enable, picready;
    output      sclk, sdo, done, starting;
    wire   clock, spiclockp, spiclockn;
    wire   enable;
    wire [127:0] data;
    wire [4:0]   count;
    reg          sclk, starting;
    wire         sdo, picready;
    reg [127:0]  latch;
    reg [7:0]    left;
    reg          ready, transmit_next;
    wire         done, transmitting;
    reg          clk_gate;

    always @(posedge clock or negedge reset)
      if (~reset)
        begin
           ready <= 1;
           left  <= 0;
           starting <= 0;
           clk_gate <= 0;
        end
      else
        begin
           if (spiclockn)
             begin
                sclk     <= 0;
                starting <= 0;
                if (~enable)
                  begin
                     ready <= 1;
                     left  <= 0;
                  end
                else if (ready)
                  begin
                     latch <= data;
                     left  <= {count, 3'b0};
                     ready <= 0;
                  end
                else if (left > 0 && transmit_next)
                  begin
                     latch <= {latch[126:0], 1'b0};
                     left  <= left - 8'd1;
                  end
             end
           else if (spiclockp & transmitting)
             begin
                if (left[2:0] != 3'b000 | picready)
                  begin
                     clk_gate <= 1;
                     transmit_next <= 1;
                     starting      <= left[2:0] == 3'b000;
                  end
                else transmit_next <= 0;
             end
           sclk <= clk_gate & spiclockp;
        end

    assign done = ~ready & (left == 0);
    assign transmitting = ~ready & ~done;
    assign sdo = latch[127];
endmodule

// ... existing code ...

module spi_receive_data (clock, reset, enable, sdi,
                          count, sclk, done, data, spiclockp, spiclockn,
                          picready, starting);
    input clock, spiclockp, spiclockn;
    input reset;
    input [4:0] count;
    input       enable, sdi, picready;
    output      sclk, starting, done;
    output [127:0] data;
    wire   clock;
    wire   enable;
    wire [127:0] data;
    wire [4:0]  count;
    reg         sclk, starting;
    wire        sdi, picready;
    reg [127:0] latch;
    reg [7:0]   left;
    reg         sample, ready, receive_next;
    wire        receiving, done;
    reg         clk_gate;

    always @(posedge clock or negedge reset)
      if (~reset)
        begin
           ready <= 1;
           left  <= 0;
           starting <= 0;
           clk_gate <= 0;
        end
      else
        begin
           if (spiclockn)
             begin
                sclk     <= 0;
                starting <= 0;
                if (~enable)
                  begin
                     ready <= 1;
                     left  <= 0;
                  end
                else if (ready)
                  begin
                     left         <= {count, 3'b0};
                     ready        <= 0;
                  end
                else if (left > 0 && receive_next)
                  begin
                     latch <= {latch[126:0], sample};
                     left  <= left - 8'd1;
                  end
             end
           else if (spiclockp && receiving)
             if (left[2:0] != 3'b000 | picready)
               begin
                  sample       <= sdi;
                  clk_gate    <= 1;
                  receive_next <= 1;
                  starting     <= left[2:0] == 3'b000;
               end
             else receive_next <= 0;
           sclk <= clk_gate & spiclockp;
        end

    assign done = ~ready & (left == 0);
    assign receiving = ~ready & ~done;
    assign data = latch;
endmodule

// ... rest of existing code ...