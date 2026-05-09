`define SPICLOCKDIV 6
`define STATUS_READ 8'hAA
module spi_clock_divisor (test_i,scan_clk,clkin, reset, clkoutp, clkoutn);
    parameter clkdiv = 2;
    input     clkin,test_i,scan_clk;
    input     reset;
    output    clkoutp, clkoutn;
    wire      clkin;
    reg       clkoutp, clkoutn;
    reg       clkbase, clkgen;
    reg [6:0] clkcnt;
	wire dft_clkin;
	assign dft_clkin = test_i ? scan_clk : clkin ;
    always @(posedge dft_clkin or negedge reset)
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
                if (clkbase) clkoutn <= 1;
                else clkoutp <= 1;
             end
           else clkcnt <= clkcnt + 7'd1;
        end
    always @(negedge dft_clkin) clkgen <= clkbase;
endmodule
module spi_emit_data (clock, reset, enable,test_i,
                       data, count, sclk, sdo, done,
                       spiclockp, spiclockn, picready, starting);
    input clock, spiclockp, spiclockn;
    input reset,test_i;
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
    always @(posedge clock or negedge reset)
      if (~reset)
        begin
           ready <= 1;
           left  <= 0;
           starting <= 0;
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
                     sclk          <= 1;
                     transmit_next <= 1;
                     starting      <= left[2:0] == 3'b000;
                  end
                else transmit_next <= 0;
             end
        end
    assign done = ~ready & (left == 0);
    assign transmitting = ~ready & ~done;
    assign sdo = latch[127];
endmodule
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
    always @(negedge clock or negedge reset)
      if (~reset)
        begin
           ready <= 1;
           left  <= 0;
           starting <= 0;
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
                  sclk         <= 1;
                  receive_next <= 1;
                  starting     <= left[2:0] == 3'b000;
               end
             else receive_next <= 0;
        end
    assign done = ~ready & (left == 0);
    assign receiving = ~ready & ~done;
    assign data = latch;
endmodule
module spi_irq (clock, reset, signal, irq, ack);
    input signal, ack, clock, reset;
    output irq;
    wire   clock, reset, signal, ack;
    reg    irq, prevsignal;
    always @(posedge clock or negedge reset)
      if (~reset)
        begin
           prevsignal <= 0;
           irq <= 0;
        end
      else
        begin
           if (signal && ~prevsignal) irq <= 1;
           prevsignal <= signal;
           if (ack) irq <= 0;
        end
endmodule
`define SPICLOCKDIV 6
`define STATUS_READ 8'hAA
module spi (clock, reset, sclk, sdi, sdo,
             inbuffer0, inbuffer1, inbuffer2, inbuffer3,
             inbuffer4, inbuffer5, inbuffer6, inbuffer7,
             inbuffer8, inbuffer9, inbufferA, inbufferB,
             inbufferC, inbufferD, inbufferE, inbufferF,
             outbuffer0, outbuffer1, outbuffer2, outbuffer3,
             outbuffer4, outbuffer5, outbuffer6, outbuffer7,
             outbuffer8, outbuffer9, outbufferA, outbufferB,
             outbufferC, outbufferD, outbufferE, outbufferF,
             toread,  towrite, enable, irq, picintr, rts,
             status, statusirq,test_i,scan_clk, statusread, picready, state);
    output picready;
    output [1:0] state;
    input clock,scan_clk,test_i;
    input reset;
    output sclk;
    input  sdi, statusread;
    output sdo, statusirq;
    input  rts, picintr;
    output [7:0] inbuffer0, inbuffer1, inbuffer2, inbuffer3,
                 inbuffer4, inbuffer5, inbuffer6, inbuffer7,
                 inbuffer8, inbuffer9, inbufferA, inbufferB,
                 inbufferC, inbufferD, inbufferE, inbufferF,
                 status;
    input [7:0]  outbuffer0, outbuffer1, outbuffer2, outbuffer3,
                 outbuffer4, outbuffer5, outbuffer6, outbuffer7,
                 outbuffer8, outbuffer9, outbufferA, outbufferB,
                 outbufferC, outbufferD, outbufferE, outbufferF,
                 toread,  towrite;
    input        enable;
    output       irq;
    wire         clock, reset, sclk, sdi, sdo, dft_clock,enable, picintr,
                 statusread;
    reg [7:0]    inbuffer0, inbuffer1, inbuffer2, inbuffer3,
                 inbuffer4, inbuffer5, inbuffer6, inbuffer7,
                 inbuffer8, inbuffer9, inbufferA, inbufferB,
                 inbufferC, inbufferD, inbufferE, inbufferF,
                 status;
    wire [7:0]   outbuffer0, outbuffer1, outbuffer2, outbuffer3,
                 outbuffer4, outbuffer5, outbuffer6, outbuffer7,
                 outbuffer8, outbuffer9, outbufferA, outbufferB,
                 outbufferC, outbufferD, outbufferE, outbufferF,
                 toread,  towrite;
    reg [7:0]    engine_toread, engine_towrite;
    wire [127:0] engine_inbuffer;
    reg [127:0]  engine_outbuffer;
	assign dft_clock = test_i ? scan_clk : clock ;
    wire         engine_irq, engine_enable;
    wire         spiclockp, spiclockn;
    reg          irq, statusirq, oldpicintr, statuschanged;
    spi_clock_divisor #(.clkdiv(`SPICLOCKDIV)) divisor
      (.reset(reset), .clkin(dft_clock), .clkoutp(spiclockp), .clkoutn(spiclockn));
    spi_engine engine (.clock(clock), .reset(reset),
                       .sclk(sclk), .sdi(sdi), .sdo(sdo),
                       .indata(engine_inbuffer), .outdata(engine_outbuffer),
                       .toread(engine_toread), .towrite(engine_towrite),
                       .enable(engine_enable), .irq(engine_irq),
                       .rts(rts),
                       .spiclockp(spiclockp), .spiclockn(spiclockn),
                       .picready(picready));
    reg [1:0]    state;
    reg          prevstatusread;
`define STATE_IDLE                0
`define STATE_TRANSMITTING_USER   1
`define STATE_TRANSMITTING_STATUS 2
`define STATE_SIGNALLING          3
    always @(posedge dft_clock or negedge reset)
      if (~reset)
        begin
           state            <= `STATE_IDLE;
           status           <= 0;
           prevstatusread   <= 0;
           irq              <= 0;
           statusirq        <= 0;
           oldpicintr       <= 0;
           statuschanged    <= 0;
        end
      else
        begin
           if (picintr != oldpicintr) statuschanged <= 1;
           if (statusread != prevstatusread)
             begin
                prevstatusread <= statusread;
                statusirq <= 0;
             end
           casex ({state, enable, engine_irq, irq, statusirq, statuschanged})
             {2'd`STATE_IDLE, 1'b1, 1'b?, 1'b0, 1'b?, 1'b?}:
               begin
                  status[7] <= 0;        
                  statuschanged <= 1;
                  engine_outbuffer <=
                              {outbuffer0, outbuffer1, outbuffer2, outbuffer3,
                               outbuffer4, outbuffer5, outbuffer6, outbuffer7,
                               outbuffer8, outbuffer9, outbufferA, outbufferB,
                               outbufferC, outbufferD, outbufferE, outbufferF};
                  engine_toread  <= toread;
                  engine_towrite <= towrite;
                  state          <= `STATE_TRANSMITTING_USER;
               end
             {2'd`STATE_IDLE, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1}:
               begin
                  irq              <= 0;
                  engine_outbuffer <= {`STATUS_READ, 120'd0};
                  engine_toread    <= 1;
                  engine_towrite   <= 1;
                  state            <= `STATE_TRANSMITTING_STATUS;
                  status[7]        <= 0; 
                  oldpicintr       <= picintr;
                  statuschanged    <= 0;
               end 
             {2'd`STATE_TRANSMITTING_USER, 1'b?, 1'b1, 1'b?, 1'b?, 1'b?}:
               begin
                  {inbuffer0, inbuffer1, inbuffer2, inbuffer3,
                   inbuffer4, inbuffer5, inbuffer6, inbuffer7,
                   inbuffer8, inbuffer9, inbufferA, inbufferB,
                   inbufferC, inbufferD, inbufferE, inbufferF}
                    <= engine_inbuffer;
                  irq          <= 1;
                  state        <= `STATE_SIGNALLING;
               end
             {2'd`STATE_TRANSMITTING_STATUS, 1'b?, 1'b1, 1'b?, 1'b?, 1'b?}:
               begin
                  status <= {1'b1, engine_inbuffer[126:120]};
                  if ({1'b1, engine_inbuffer[126:120]} != status)
                    statusirq <= 1;
                  state <= `STATE_SIGNALLING;
               end
             {2'd`STATE_SIGNALLING, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?}:
               state <= `STATE_IDLE;
           endcase
        end
    assign engine_enable = state == `STATE_TRANSMITTING_USER |
                           state == `STATE_TRANSMITTING_STATUS;
endmodule
module spi_engine (clock, reset, sclk, sdi, sdo,
                    indata, outdata,
                    toread,  towrite, enable,
                    irq, rts, spiclockp, spiclockn, picready);
    output         picready;
    input          clock, spiclockp, spiclockn;
    input          reset;
    output         sclk;
    input          sdi;
    output         sdo;
    input          rts;
    output [127:0] indata;
    input  [127:0] outdata;
    input  [7:0]   toread,  towrite;
    input          enable;
    output         irq;
    wire           clock, reset, sclk, sdi, sdo, enable, irq, rts;
    wire [7:0]     toread,  towrite;
    wire [127:0]   indata, outdata, inbuffer;
    reg  [127:0]   shiftinbuffer;
    wire         emit_enable, emit_sclk, emit_done;
    wire         receive_enable, receive_sclk, receive_done;
    wire         spiclockp, spiclockn;
    reg [2:0]    state;
    reg [4:0]    toshift;
    wire [4:0]   inbytes;
    reg          picready;
    wire         start_emitting, start_receiving;
    reg          rts_r, rts_rr;
    wire rts_edge = ~rts_r & rts_rr;
    spi_emit_data emitter (.clock(clock), .reset(reset),
                           .enable(emit_enable), .data(outdata),
                           .count(towrite[4:0]), .sclk(emit_sclk),
                           .sdo(sdo), .done(emit_done),
                           .spiclockp(spiclockp), .spiclockn(spiclockn),
                           .picready(picready), .starting(start_emitting));
    spi_receive_data receiver (.clock(clock), .reset(reset),
                               .enable(receive_enable), .sdi(sdi),
                               .count(toread[4:0]), .sclk(receive_sclk),
                               .done(receive_done), .data(inbuffer),
                               .spiclockp(spiclockp), .spiclockn(spiclockn),
                               .picready(picready),
                               .starting(start_receiving));
`define STATE_IDLE 0
`define STATE_EMITTING 1
`define STATE_RECEIVING 2
`define STATE_SHIFTING 3
`define STATE_SIGNALLING 4
    always @(posedge clock or negedge reset)
      if (~reset) state <= `STATE_IDLE;
      else
        casex ({state, enable, emit_done, receive_done, inbytes, toshift})
          {3'b???, 1'b0, 1'b?, 1'b?, 5'b?, 5'b?}:
            state <= `STATE_IDLE;
          {3'd`STATE_IDLE, 1'b1, 1'b?, 1'b?, 5'b?, 5'b?}:
            begin
               toshift <= 5'd16 - toread[4:0];
               state <= `STATE_EMITTING;
            end
          {3'd`STATE_EMITTING, 1'b?, 1'b1, 1'b?, 5'b0, 5'b?}:
            state <= `STATE_SIGNALLING;
          {3'd`STATE_EMITTING, 1'b?, 1'b1, 1'b?, 5'b?, 5'b?}:
            state <= `STATE_RECEIVING;
          {3'd`STATE_RECEIVING, 1'b?, 1'b?, 1'b1, 5'b?, 5'b0}:
            begin
               shiftinbuffer <= inbuffer;
               state <= `STATE_SIGNALLING;
            end
          {3'd`STATE_RECEIVING, 1'b1, 1'b?, 1'b1, 5'b?, 5'b?}:
            begin
               shiftinbuffer <= inbuffer;
               state <= `STATE_SHIFTING;
            end
          {3'd`STATE_SHIFTING, 1'b1, 1'b?, 1'b?, 5'b?, 5'b0}:
            state <= `STATE_SIGNALLING;
          {3'd`STATE_SHIFTING, 1'b1, 1'b?, 1'b?, 5'b?, 5'b?}:
            begin
               shiftinbuffer <= {shiftinbuffer[119:0],8'b0};
               toshift <= toshift - 5'd1;
            end
        endcase
    always @(posedge clock or negedge reset)
      if (~reset) picready <= 0;
      else if (rts_edge) picready <= 1;
      else if (start_emitting | start_receiving) picready <= 0;
    always @(posedge clock or negedge reset)
      if (~reset) begin rts_r <= 0; rts_rr <= 0; end
      else begin rts_r <= rts; rts_rr <= rts_r; end
    assign inbytes = toread[4:0];
    assign sclk = emit_sclk | receive_sclk;
    assign irq = state == `STATE_SIGNALLING;
    assign emit_enable = state == `STATE_EMITTING;
    assign receive_enable = state == `STATE_RECEIVING;
    assign indata = shiftinbuffer;
endmodule
module spi_clock_divisor (clkin, reset, clkoutp, clkoutn);
    parameter clkdiv = 2;
    input     clkin;
    input     reset;
    output    clkoutp, clkoutn;
    wire      clkin;
    reg       clkoutp, clkoutn;
    reg       clkbase, clkgen;
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
                if (clkbase) clkoutn <= 1;
                else clkoutp <= 1;
             end
           else clkcnt <= clkcnt + 7'd1;
        end
    always @(negedge clkin) clkgen <= clkbase;
endmodule
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
    always @(posedge clock or negedge reset)
      if (~reset)
        begin
           ready <= 1;
           left  <= 0;
           starting <= 0;
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
                     sclk          <= 1;
                     transmit_next <= 1;
                     starting      <= left[2:0] == 3'b000;
                  end
                else transmit_next <= 0;
             end
        end
    assign done = ~ready & (left == 0);
    assign transmitting = ~ready & ~done;
    assign sdo = latch[127];
endmodule
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
    always @(negedge clock or negedge reset)
      if (~reset)
        begin
           ready <= 1;
           left  <= 0;
           starting <= 0;
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
                  sclk         <= 1;
                  receive_next <= 1;
                  starting     <= left[2:0] == 3'b000;
               end
             else receive_next <= 0;
        end
    assign done = ~ready & (left == 0);
    assign receiving = ~ready & ~done;
    assign data = latch;
endmodule
module spi_irq (clock, reset, signal, irq, ack);
    input signal, ack, clock, reset;
    output irq;
    wire   clock, reset, signal, ack;
    reg    irq, prevsignal;
    always @(posedge clock or negedge reset)
      if (~reset)
        begin
           prevsignal <= 0;
           irq <= 0;
        end
      else
        begin
           if (signal && ~prevsignal) irq <= 1;
           prevsignal <= signal;
           if (ack) irq <= 0;
        end
endmodule
