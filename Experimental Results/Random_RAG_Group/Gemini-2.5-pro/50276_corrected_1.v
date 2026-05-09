module MultiBootLoader
  (
   input       clock,
   input       mode,
   input [3:0] id,
   input       test_i,
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
   reg [1:0]   clk;
   wire        dft_clk;
   wire        dft_rst;
   reg [15:0]  icap_din;
   reg         icap_ce;
   reg         icap_wr;
   reg [15:0]  ff_icap_din_reversed;
   reg         ff_icap_ce;
   reg         ff_icap_wr;
   reg [15:0]  MBT_REBOOT = 16'h0000;
   reg [24:0]  counter;
   ICAP_SPARTAN6 ICAP_SPARTAN6_inst
     (
      .BUSY      (),                      
      .O         (),                      
      .CE        (ff_icap_ce),            
      .CLK       (dft_clk),                
      .I         (ff_icap_din_reversed),  
      .WRITE     (ff_icap_wr)             
      );
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
   assign dft_clk = test_i ? clock : clk[0];
   assign dft_rst = test_i ? 1'b0 : clk[1];
   always @(posedge dft_clk or posedge dft_rst)
     begin
        if (dft_rst)
          begin
             state <= IDLE;
             ff_icap_ce <= 1;
             ff_icap_wr <= 1;
             ff_icap_din_reversed <= 16'hFFFF;
          end
        else
          begin
             state <= next_state;
             ff_icap_ce <= icap_ce;
             ff_icap_wr <= icap_wr;
             ff_icap_din_reversed <= icap_din;
          end
     end
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
                 5'b11110: icap_din    = 16'h8000; 
                 5'b11101: icap_din    = 16'hC000; 
                 5'b01101: icap_din    = 16'hC000; 
                 5'b01110: icap_din    = 16'h0000; 
                 5'b11100: icap_din    = 16'h4000; 
                 5'b01100: icap_din    = 16'h4000; 
                 default:  icap_din    = 16'h4000; 
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
                 5'b11110: icap_din    = 16'h030A; 
                 5'b11101: icap_din    = 16'h030F; 
                 5'b01101: icap_din    = 16'h030F; 
                 5'b01110: icap_din    = 16'h0315; 
                 5'b11100: icap_din    = 16'h031A; 
                 5'b01100: icap_din    = 16'h031A; 
                 default:  icap_din    = 16'h0305; 
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
               icap_din    = 16'hFFFF;
            end
        endcase
     end
   assign led1 = MBT_REBOOT[0];
   assign led2 = MBT_REBOOT[1];
   assign led3 = MBT_REBOOT[2];
   assign ld1 = counter[0];
   assign ld2 = counter[1];
   assign ld3 = counter[2];
   assign ld4 = counter[3];
   assign ld5 = counter[4];
   assign ld6 = counter[5];
   assign ld7 = counter[6];
   assign ld8 = counter[7];
   always @(posedge clock)
     begin
        clk <= clk + 1;
        counter <= counter + 1;
        if (counter == 25'h1FFFFFF)
          MBT_REBOOT <= 16'hFFFF;
     end
endmodule