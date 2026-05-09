`timescale 1ns / 1ps
module MultiBootLoader
  (
   input       clock,
   input       mode,
   input [3:0] id,
   output      led1,
   output      led2,
   output      led3,
   output      ld1,
   output      ld2,
   output      ld3,
   output      ld4,
   output      ld5,
   output      ld6,
   output      ld7,
   output      ld8
   );
   reg [15:0]  icap_din;
   reg         icap_ce;
   reg         icap_wr;
   reg [15:0]  ff_icap_din_reversed;
   reg         ff_icap_ce;
   reg         ff_icap_wr;
   reg [15:0]  MBT_REBOOT = 16'h0000;
   reg [24:0]  counter;

   parameter
     IDLE     = 0,
     SYNC_H   = 1,
     SYNC_L   = 2,
     CWD_H    = 3,
     CWD_L    = 4,
     GEN1_H   = 5,
     GEN1_L   = 6,
     GEN2_H   = 7,
     GEN2_L   = 8,
     GEN3_H   = 9,
     GEN3_L   = 10,
     GEN4_H   = 11,
     GEN4_L   = 12,
     GEN5_H   = 13,
     GEN5_L   = 14,
     NUL_H    = 15,
     NUL_L    = 16,
     MOD_H    = 17,
     MOD_L    = 18,
     HCO_H    = 19,
     HCO_L    = 20,
     RBT_H    = 21,
     RBT_L    = 22,
     NOOP_0   = 23,
     NOOP_1   = 24,
     NOOP_2   = 25,
     NOOP_3   = 26;

   reg [4:0]   state = IDLE;
   reg [4:0]   next_state;

   ICAP_SPARTAN6 ICAP_SPARTAN6_inst
     (
      .BUSY      (),
      .O         (),
      .CE        (ff_icap_ce),
      .CLK       (clock),
      .I         (ff_icap_din_reversed),
      .WRITE     (ff_icap_wr)
      );

   always @(MBT_REBOOT or state or id or mode)
     begin: COMB
        case (state)
          IDLE:
            begin
               if (MBT_REBOOT==16'hffff)
                 begin
                    next_state  = SYNC_H;
                    icap_ce     = 0;
                    icap_wr     = 0;
                    icap_din    = 16'hAA99;
                 end
               else
                 begin
                    next_state  = IDLE;
                    icap_ce     = 1;
                    icap_wr     = 1;
                    icap_din    = 16'hFFFF;
                 end
            end
          SYNC_H:
            begin
               next_state  = SYNC_L;
               icap_ce     = 0;
               icap_wr     = 0;
               icap_din    = 16'h5566;
            end
          SYNC_L:
            begin
               next_state  = GEN1_H;
               icap_ce     = 0;
               icap_wr     = 0;
               icap_din    = 16'h3261;
            end
          GEN1_H:
            begin
               next_state  = GEN1_L;
               icap_ce     = 0;
               icap_wr     = 0;
               case ({mode, id})
                 5'b11110: icap_din = 16'h8000;
                 5'b11101: icap_din = 16'hC000;
                 5'b01101: icap_din = 16'hC000;
                 5'b01110: icap_din = 16'h0000;
                 5'b11100: icap_din = 16'h4000;
                 5'b01100: icap_din = 16'h4000;
                 default:  icap_din = 16'h4000;
               endcase
            end
          GEN1_L:
            begin
               next_state  = GEN2_H;
               icap_ce     = 0;
               icap_wr     = 0;
               icap_din    = 16'h3281;
            end
          GEN2_H:
            begin
               next_state  = GEN2_L;
               icap_ce     = 0;
               icap_wr     = 0;
               case ({mode, id})
                 5'b11110: icap_din = 16'h030A;
                 5'b11101: icap_din = 16'h030F;
                 5'b01101: icap_din = 16'h030F;
                 5'b01110: icap_din = 16'h0315;
                 5'b11100: icap_din = 16'h031A;
                 5'b01100: icap_din = 16'h031A;
                 default:  icap_din = 16'h0305;
               endcase
            end
          GEN2_L:
            begin
               next_state  = RBT_H;
               icap_ce     = 0;
               icap_wr     = 0;
               icap_din    = 16'h30A1;
            end
          RBT_H:
            begin
               next_state  = RBT_L;
               icap_ce     = 0;
               icap_wr     = 0;
               icap_din    = 16'h000E;
            end
          RBT_L:
            begin
               next_state  = NOOP_0;
               icap_ce     = 0;
               icap_wr     = 0;
               icap_din    = 16'h2000;
            end
          NOOP_0:
            begin
               next_state  = NOOP_1;
               icap_ce     = 0;
               icap_wr     = 0;
               icap_din    = 16'h2000;
            end
          NOOP_1:
            begin
               next_state  = NOOP_2;
               icap_ce     = 0;
               icap_wr     = 0;
               icap_din    = 16'h2000;
            end
          NOOP_2:
            begin
               next_state  = NOOP_3;
               icap_ce     = 0;
               icap_wr     = 0;
               icap_din    = 16'h2000;
            end
          NOOP_3:
            begin
               next_state  = IDLE;
               icap_ce     = 1;
               icap_wr     = 1;
               icap_din    = 16'h1111;
            end
          default:
            begin
               next_state  = IDLE;
               icap_ce     = 1;
               icap_wr     = 1;
               icap_din    = 16'h1111;
            end
        endcase
     end

   always @(posedge clock)
     begin
        if (MBT_REBOOT == 16'hffff)
          state <= next_state;
        else
          begin
             MBT_REBOOT <= MBT_REBOOT + 1'b1;
             state <= IDLE;
          end
     end

   always @(posedge clock)
     begin: ICAP_FF
        ff_icap_din_reversed[0]  <= icap_din[7];
        ff_icap_din_reversed[1]  <= icap_din[6];
        ff_icap_din_reversed[2]  <= icap_din[5];
        ff_icap_din_reversed[3]  <= icap_din[4];
        ff_icap_din_reversed[4]  <= icap_din[3];
        ff_icap_din_reversed[5]  <= icap_din[2];
        ff_icap_din_reversed[6]  <= icap_din[1];
        ff_icap_din_reversed[7]  <= icap_din[0];
        ff_icap_din_reversed[8]  <= icap_din[15];
        ff_icap_din_reversed[9]  <= icap_din[14];
        ff_icap_din_reversed[10] <= icap_din[13];
        ff_icap_din_reversed[11] <= icap_din[12];
        ff_icap_din_reversed[12] <= icap_din[11];
        ff_icap_din_reversed[13] <= icap_din[10];
        ff_icap_din_reversed[14] <= icap_din[9];
        ff_icap_din_reversed[15] <= icap_din[8];
        ff_icap_ce  <= icap_ce;
        ff_icap_wr  <= icap_wr;
     end

   always@(posedge clock)
     begin
        counter <= counter + 1'b1;
     end

   assign led1 = 1'b1;
   assign led2 = 1'b0;
   assign led3 = 1'b0;
   assign ld1  = counter[24];
   assign ld2  = ~counter[24];
   assign ld3  = 1'b0;
   assign ld4  = state[4];
   assign ld5  = state[3];
   assign ld6  = state[2];
   assign ld7  = state[1];
   assign ld8  = state[0];
endmodule