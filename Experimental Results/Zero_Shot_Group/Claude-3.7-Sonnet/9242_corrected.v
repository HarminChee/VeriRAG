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
           if (clkcnt == clkdiv-1)
             begin
                clkcnt  <= 0;
                clkbase <= ~clkbase;
             end
           else clkcnt <= clkcnt + 7'd1;
        end
    always @(clkbase) begin
        clkoutp <= clkbase;
        clkoutn <= ~clkbase;
    end
endmodule
module spi_emit_data (clock, reset, enable,
                       data, count, sclk, sdo, done,
                       spiclockp, spiclockn, picready, starting);
    input clock, spiclockp, spiclockn;
    input reset;
    input [127:0] data;
    input [4:0] count;
    input       enable, picready;
    output reg      sclk, sdo, done, starting;
    wire   clock, spiclockp, spiclockn;
    wire   enable;
    wire [127:0] data;
    wire [4:0]   count;
    reg [127:0]  latch;
    reg [7:0]    left;
    reg          ready, transmit_next;
    reg         transmitting;
    always @(posedge clock or negedge reset)
      if (~reset)
        begin
           ready <= 1;
           left  <= 0;
           starting <= 0;
           sclk <= 0;
           sdo <= 0;
           done <= 0;
           transmit_next <= 0;
           transmitting <= 0;
        end
      else
        begin
           if (~enable)
             begin
                ready <= 1;
                left  <= 0;
                transmitting <= 0;
                done <= 0;
             end
           else if (ready)
             begin
                latch <= data;
                left  <= {count, 3'b0};
                ready <= 0;
                transmitting <= 1;
                done <= 0;
             end
           else if (transmitting)
             begin
                if (spiclockn)
                  begin
                     sclk     <= 0;
                     starting <= 0;
                     if (left > 0 )
                       begin
                          sdo <= latch[127];
                          latch <= {latch[126:0], 1'b0};
                          left  <= left - 8'd1;
                          transmit_next <= 1;
                       end
                     else begin
                        transmit_next <= 0;
                        transmitting <= 0;
                        done <= 1;
                     end
                  end
                else if (spiclockp)
                  begin
                     if (left[2:0] != 3'b000 || picready)
                       begin
                          sclk          <= 1;
                          starting      <= left[2:0] == 3'b000;
                       end
                  end
             end
           else begin
                sclk <= 0;
                sdo <= 0;
                starting <= 0;
           end
        end
endmodule
module spi_receive_data (clock, reset, enable, sdi,
                          count, sclk, done, data, spiclockp, spiclockn,
                          picready, starting);
    input clock, spiclockp, spiclockn;
    input reset;
    input [4:0] count;
    input       enable, sdi, picready;
    output reg      sclk, starting, done;
    output reg [127:0] data;
    wire   clock;
    wire   enable;
    wire [4:0]  count;
    wire        sdi, picready;
    reg [127:0] latch;
    reg [7:0]   left;
    reg         sample, ready, receive_next;
    reg        receiving;
    always @(posedge clock or negedge reset)
      if (~reset)
        begin
           ready <= 1;
           left  <= 0;
           starting <= 0;
           sclk <= 0;
           done <= 0;
           latch <= 0;
           receiving <= 0;
        end
      else
        begin
           if (~enable)
             begin
                ready <= 1;
                left  <= 0;
                receiving <= 0;
                done <= 0;
             end
           else if (ready)
             begin
                left         <= {count, 3'b0};
                ready        <= 0;
                receiving <= 1;
                done <= 0;
             end
           else if (receiving)
             begin
                if (spiclockn)
                  begin
                     sclk     <= 0;
                     starting <= 0;
                     if (left > 0)
                       begin
                          latch <= {latch[126:0], sample};
                          left  <= left - 8'd1;
                          receive_next <= 1;
                       end
                     else begin
                        receive_next <= 0;
                        receiving <= 0;
                        done <= 1;
                     end
                  end
                else if (spiclockp)
                  begin
                     if (left[2:0] != 3'b000 || picready)
                       begin
                          sample       <= sdi;
                          sclk         <= 1;
                          starting     <= left[2:0] == 3'b000;
                       end
                  end
             end
           else begin
                sclk <= 0;
                starting <= 0;
           end
        end
    always @(posedge clock or negedge reset)
      if(~reset)
        data <= 0;
      else if(done)
        data <= latch;
endmodule
module spi_irq (clock, reset, signal, irq, ack);
    input signal, ack, clock, reset;
    output reg irq;
    wire   clock, reset, signal, ack;
    reg    prevsignal;
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
             status, statusirq, statusread, picready, state);
    output reg picready;
    output reg [1:0] state;
    input clock;
    input reset;
    output sclk;
    input  sdi, statusread;
    output reg sdo, statusirq;
    input  rts, picintr;
    output reg [7:0] inbuffer0, inbuffer1, inbuffer2, inbuffer3,
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
    wire         clock, reset, sclk, sdi, sdo, enable, picintr,
                 statusread;
    wire [7:0]   outbuffer0, outbuffer1, outbuffer2, outbuffer3,
                 outbuffer4, outbuffer5, outbuffer6, outbuffer7,
                 outbuffer8, outbuffer9, outbufferA, outbufferB,
                 outbufferC, outbufferD, outbufferE, outbufferF,
                 toread,  towrite;
    reg [7:0]    engine_toread, engine_towrite;
    wire [127:0] engine_inbuffer;
    reg [127:0]  engine_outbuffer;
    wire         engine_irq, engine_enable;
    wire         spiclockp, spiclockn;
    reg          oldpicintr, statuschanged;
    spi_clock_divisor #(.clkdiv(`SPICLOCKDIV)) divisor
      (.reset(reset), .clkin(clock), .clkoutp(spiclockp), .clkoutn(spiclockn));
    spi_engine engine (.clock(clock), .reset(reset),
                       .sclk(sclk), .sdi(sdi), .sdo(sdo),
                       .indata(engine_inbuffer), .outdata(engine_outbuffer),
                       .toread(engine_toread), .towrite(engine_towrite),
                       .enable(engine_enable), .irq(engine_irq),
                       .rts(rts),
                       .spiclockp(spiclockp), .spiclockn(spiclockn),
                       .picready(picready));
    reg          prevstatusread;
    wire         irq;
`define STATE_IDLE                2'b00
`define STATE_TRANSMITTING_USER   2'b01
`define STATE_TRANSMITTING_STATUS 2'b10
`define STATE_SIGNALLING          2'b11
    always @(posedge clock or negedge reset)
      if (~reset)
        begin
           state            <= `STATE_IDLE;
           status           <= 0;
           prevstatusread   <= 0;
           statusirq        <= 0;
           oldpicintr       <= 0;
           statuschanged    <= 0;
           picready <= 0;
        end
      else
        begin
           if (picintr != oldpicintr) statuschanged <= 1;
           if (statusread != prevstatusread)
             begin
                prevstatusread <= statusread;
                statusirq <= 0;
             end
           casex ({state, enable, engine_irq, statusirq, statuschanged})
             {`STATE_IDLE, 1'b1, 1'b?, 1'b?, 1'b?}:
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
             {`STATE_IDLE, 1'b?, 1'b?, 1'b?, 1'b1}:
               begin
                  engine_outbuffer <= {`STATUS_READ, 120'd0};
                  engine_toread    <= 8'd1;
                  engine_towrite   <= 8'd1;
                  state            <= `STATE_TRANSMITTING_STATUS;
                  status[7]        <= 0;
                  oldpicintr       <= picintr;
                  statuschanged    <= 0;
               end
             {`STATE_TRANSMITTING_USER, 1'b?, 1'b1, 1'b?, 1'b?}:
               begin
                  {inbuffer0, inbuffer1, inbuffer2, inbuffer3,
                   inbuffer4, inbuffer5, inbuffer6, inbuffer7,
                   inbuffer8, inbuffer9, inbufferA, inbufferB,
                   inbufferC, inbufferD, inbufferE, inbufferF}
                    <= engine_inbuffer;
                  state        <= `STATE_SIGNALLING;
               end
             {`STATE_TRANSMITTING_STATUS, 1'b?, 1'b1, 1'b?, 1'b?}:
               begin
                  status <= {1'b1, engine_inbuffer[126:120]};
                  if ({1'b1, engine_inbuffer[126:120]} != status)
                    statusirq <= 1;
                  state <= `STATE_SIGNALLING;
               end
             {`STATE_SIGNALLING, 1'b0, 1'b?, 1'b?, 1'b?}:
               state <= `STATE_IDLE;
           default: state <= `STATE_IDLE;
           endcase
        end
    assign engine_enable = state == `STATE_TRANSMITTING_USER |
                           state == `STATE_TRANSMITTING_STATUS;
endmodule
module spi_engine (clock, reset, sclk, sdi, sdo,
                    indata, outdata,
                    toread,  towrite, enable,
                    irq, rts, spiclockp, spiclockn, picready);
    input          picready;
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
    wire           clock, reset, sdi, enable, rts;
    wire [7:0]     toread,  towrite;
    wire [127:0]   outdata, inbuffer;
    reg  [127:0]   shiftinbuffer;
    wire         emit_enable, emit_sclk, emit_done;
    wire         receive_enable, receive_sclk, receive_done;
    wire         spiclockp, spiclockn;
    reg [2:0]    state;
    reg [4:0]    toshift;
    wire [4:0]   inbytes;
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
`define STATE_IDLE 3'b000
`define STATE_EMITTING 3'b001
`define STATE_RECEIVING 3'b010
`define STATE_SHIFTING 3'b011
`define STATE_SIGNALLING 3'b100
    always @(posedge clock or negedge reset)
      if (~reset) state <= `STATE_IDLE;
      else
        casex ({state, enable, emit_done, receive_done, toread})
          {`STATE_IDLE, 1'b0, 1'b?, 1'b?, 8'b?}:
            state <= `STATE_IDLE;
          {`STATE_IDLE, 1'b1, 1'b?, 1'b?, 8'b?}:
            begin
               toshift <= 5'd16 - toread[4:0];
               state <= `STATE_EMITTING;
            end
          {`STATE_EMITTING, 1'b?, 1'b1, 1'b?, 8'b?}:
            state <= `STATE_RECEIVING;
          {`STATE_RECEIVING, 1'b1, 1'b?, 1'b1, 8'b0}:
            begin
               shiftinbuffer <= inbuffer;
               state <= `STATE_SIGNALLING;
            end
          {`STATE_RECEIVING, 1'b1, 1'b?, 1'b1, 8'b?}:
            begin
               shiftinbuffer <= inbuffer;
               state <= `STATE_SHIFTING;
            end
          {`STATE_SHIFTING, 1'b1, 1'b?, 1'b?, 8'b?}:
            begin
               shiftinbuffer <= {shiftinbuffer[119:0],8'b0};
               toshift <= toshift - 5'd1;
               if(toshift == 0)
                 state <= `STATE_SIGNALLING;
            end
          default: state <= `STATE_IDLE;
        endcase
    always @(posedge clock or negedge reset)
      if (~reset) rts_r <= 0;
      else  rts_r <= rts;
    always @(posedge clock or negedge reset)
      if (~reset) rts_rr <= 0;
      else rts_rr <= rts_r;
    assign inbytes = toread[4:0];
    assign sclk = emit_sclk | receive_sclk;
    assign irq = (state == `STATE_SIGNALLING) && picready;
    assign emit_enable = state == `STATE_EMITTING;
    assign receive_enable = state == `STATE_RECEIVING;
    assign indata = shiftinbuffer;
endmodule