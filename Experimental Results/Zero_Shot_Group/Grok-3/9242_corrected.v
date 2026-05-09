`define SPICLOCKDIV 6
`define STATUS_READ 8'hAA

module spi_clock_divisor (
    input     clkin,
    input     reset,
    output    clkoutp,
    output    clkoutn
);
    parameter clkdiv = 2;
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
                if (clkbase) clkoutn <= 1;
                else clkoutp <= 1;
             end
           else clkcnt <= clkcnt + 7'd1;
        end
endmodule

module spi_emit_data (
    input         clock,
    input         spiclockp,
    input         spiclockn,
    input         reset,
    input  [127:0] data,
    input  [4:0]  count,
    input         enable,
    input         picready,
    output        sclk,
    output        sdo,
    output        done,
    output        starting
);
    reg          sclk, starting;
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
           sclk  <= 0;
           transmit_next <= 0;
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
           else if (spiclockp && transmitting)
             begin
                if (left[2:0] != 3'b000 || picready)
                  begin
                     sclk          <= 1;
                     transmit_next <= 1;
                     starting      <= left[2:0] == 3'b000;
                  end
                else transmit_next <= 0;
             end
        end
    assign done = ~ready && (left == 0);
    assign transmitting = ~ready && ~done;
    assign sdo = latch[127];
endmodule

module spi_receive_data (
    input         clock,
    input         spiclockp,
    input         spiclockn,
    input         reset,
    input  [4:0]  count,
    input         enable,
    input         sdi,
    input         picready,
    output        sclk,
    output        starting,
    output        done,
    output [127:0] data
);
    reg         sclk, starting;
    reg [127:0] latch;
    reg [7:0]   left;
    reg         sample, ready, receive_next;
    wire        receiving;

    always @(negedge clock or negedge reset)
      if (~reset)
        begin
           ready <= 1;
           left  <= 0;
           starting <= 0;
           sclk  <= 0;
           receive_next <= 0;
           latch <= 0;
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
             if (left[2:0] != 3'b000 || picready)
               begin
                  sample       <= sdi;
                  sclk         <= 1;
                  receive_next <= 1;
                  starting     <= left[2:0] == 3'b000;
               end
             else receive_next <= 0;
        end
    assign done = ~ready && (left == 0);
    assign receiving = ~ready && ~done;
    assign data = latch;
endmodule

module spi_irq (
    input  signal,
    input  ack,
    input  clock,
    input  reset,
    output irq
);
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

module spi (
    input         clock,
    input         reset,
    output        sclk,
    input         sdi,
    output        sdo,
    output [7:0]  inbuffer0, inbuffer1, inbuffer2, inbuffer3,
                  inbuffer4, inbuffer5, inbuffer6, inbuffer7,
                  inbuffer8, inbuffer9, inbufferA, inbufferB,
                  inbufferC, inbufferD, inbufferE, inbufferF,
    input  [7:0]  outbuffer0, outbuffer1, outbuffer2, outbuffer3,
                  outbuffer4, outbuffer5, outbuffer6, outbuffer7,
                  outbuffer8, outbuffer9, outbufferA, outbufferB,
                  outbufferC, outbufferD, outbufferE, outbufferF,
    input  [7:0]  toread,
    input  [7:0]  towrite,
    input         enable,
    output        irq,
    input         picintr,
    input         rts,
    output [7:0]  status,
    output        statusirq,
    input         statusread,
    output        picready,
    output [1:0]  state
);
    reg [7:0]    inbuffer0, inbuffer1, inbuffer2, inbuffer3,
                 inbuffer4, inbuffer5, inbuffer6, inbuffer7,
                 inbuffer8, inbuffer9, inbufferA, inbufferB,
                 inbufferC, inbufferD, inbufferE, inbufferF,
                 status;
    reg [7:0]    engine_toread, engine_towrite;
    wire [127:0] engine_inbuffer;
    reg [127:0]  engine_outbuffer;
    wire         engine_irq, engine_enable;
    wire         spiclockp, spiclockn;
    reg          irq, statusirq, oldpicintr, statuschanged;
    reg [1:0]    state;
    reg          prevstatusread;

    spi_clock_divisor #(.clkdiv(`SPICLOCKDIV)) divisor (
      .reset(reset),
      .clkin(clock),
      .clkoutp(spiclockp),
      .clkoutn(spiclockn)
    );

    spi_engine engine (
      .clock(clock),
      .reset(reset),
      .sclk(sclk),
      .sdi(sdi),
      .sdo(sdo),
      .indata(engine_inbuffer),
      .outdata(engine_outbuffer),
      .toread(engine_toread),
      .towrite(engine_towrite),
      .enable(engine_enable),
      .irq(engine_irq),
      .rts(rts),
      .spiclockp(spiclockp),
      .spiclockn(spiclockn),
      .picready(picready)
    );

    `define STATE_IDLE                0
    `define STATE_TRANSMITTING_USER   1
    `define STATE_TRANSMITTING_STATUS 2
    `define STATE_SIGNALLING          3

    always @(posedge clock or negedge reset)
      if (~reset)
        begin
           state            <= `STATE_IDLE;
           status           <= 0;
           prevstatusread   <= 0;
           irq              <= 0;
           statusirq        <= 0;
           oldpicintr       <= 0;
           statuschanged    <= 0;
           engine_toread    <= 0;
           engine_towrite   <= 0;
           engine_outbuffer <= 0;
        end
      else
        begin
           if (picintr != oldpicintr) statuschanged <= 1;
           if (statusread != prevstatusread)
             begin
                prevstatusread <= statusread;
                statusirq <= 0;
             end
           case ({state, enable, engine_irq, irq, statusirq, statuschanged})
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
                  engine_toread    <= 8'd1;
                  engine_towrite   <= 8'd1;
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
             default:
               state <= state;
           endcase
        end
    assign engine_enable = (state == `STATE_TRANSMITTING_USER) || (state == `STATE_TRANSMITTING_STATUS);
endmodule

module spi_engine (
    input         clock,
    input         spiclockp,
    input         spiclockn,
    input         reset,
    output        sclk,
    input         sdi,
    output        sdo,
    input         rts,
    output [127:0] indata,
    input  [127:0] outdata,
    input  [7:0]  toread,
    input  [7:0]  towrite,
    input         enable,
    output        irq,
    output        picready
);
    reg  [127:0]  shiftinbuffer;
    wire         emit_enable, emit_sclk, emit_done;
    wire         receive_enable, receive_sclk, receive_done;
    wire [127:0] inbuffer;
    reg [2:0]    state;
    reg [4:0]    toshift;
    wire [4:0]   inbytes;
    reg          picready;
    wire         start_emitting, start_receiving;
    reg          rts_r, rts_rr;
    wire         rts_edge = ~rts_r && rts_rr;

    spi_emit_data emitter (
      .clock(clock),
      .reset(reset),
      .enable(emit_enable),
      .data(outdata),
      .count(towrite[4:0]),
      .sclk(emit_sclk),
      .sdo(sdo),
      .done(emit_done),
      .spiclockp(spiclockp),
      .spiclockn(spiclockn),
      .picready(picready),
      .starting(start_emitting)
    );

    spi_receive_data receiver (
      .clock(clock),
      .reset(reset),
      .enable(receive_enable),
      .sdi(sdi),
      .count(toread[4:0]),
      .sclk(receive_sclk),
      .done(receive_done),
      .data(inbuffer),
      .spiclockp(spiclockp),
      .spiclockn(spiclockn),
      .picready(picready),
      .starting(start_receiving)
    );

    `define STATE_IDLE 0
    `define STATE_EMITTING 1
    `define STATE_RECEIVING 2
    `define STATE_SHIFTING 3
    `define STATE_SIGNALLING 4

    always @(posedge clock or negedge reset)
      if (~reset)
        begin
           state <= `STATE_IDLE;
           toshift <= 0;
           shiftinbuffer <= 0;
        end
      else
        case ({state, enable, emit_done, receive_done, inbytes, toshift})
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
          {3'd`STATE_RECEIVING, 1'b?, 1'b?, 1'b1, 5'b?, 5'b?}:
            begin
               shiftinbuffer <= inbuffer;
               state <= `STATE_SHIFTING;
            end
          {3'd`STATE_SHIFTING, 1'b?, 1'b?, 1'b?, 5'b?, 5'b0}:
            state <= `STATE_SIGNALLING;
          {3'd`STATE_SHIFTING, 1'b?, 1'b?, 1'b?, 5'b?, 5'b?}:
            begin
               shiftinbuffer <= {shiftinbuffer[119:0], 8'b0};
               toshift <= toshift - 5'd1;
            end
          default:
            state <= state;
        endcase

    always @(posedge clock or negedge reset)
      if (~reset)
        begin
           picready <= 0;
           rts_r <= 0;
           rts_rr <= 0;
        end
      else
        begin
           if (rts_edge) picready <= 1;
           else if (start_emitting || start_receiving) picready <= 0;
           rts_r <= rts;
           rts_rr <= rts_r;
        end

    assign inbytes = toread[4:0];
    assign sclk = emit_sclk || receive_sclk;
    assign irq = state == `STATE_SIGNALLING;
    assign emit_enable = state == `STATE_EMITTING;
    assign receive_enable = state == `STATE_RECEIVING;
    assign indata = shiftinbuffer;
endmodule