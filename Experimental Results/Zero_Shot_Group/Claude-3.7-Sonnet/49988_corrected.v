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
   reg [1:0]   clk;
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
      .CLK       (clk[0]),                
      .I         (ff_icap_din_reversed),  
      .WRITE     (ff_icap_wr)             
      );

   localparam
     IDLE     = 5'd0,
     SYNC_H   = 5'd1,
     SYNC_L   = 5'd2,
     CWD_H    = 5'd3,
     CWD_L    = 5'd4,
     GEN1_H   = 5'd5,
     GEN1_L   = 5'd6,
     GEN2_H   = 5'd7,
     GEN2_L   = 5'd8,
     GEN3_H   = 5'd9,
     GEN3_L   = 5'd10,
     GEN4_H   = 5'd11,
     GEN4_L   = 5'd12,
     GEN5_H   = 5'd13,
     GEN5_L   = 5'd14,
     NUL_H    = 5'd15,
     NUL_L    = 5'd16,
     MOD_H    = 5'd17,
     MOD_L    = 5'd18,
     HCO_H    = 5'd19,
     HCO_L    = 5'd20,
     RBT_H    = 5'd21,
     RBT_L    = 5'd22,
     NOOP_0   = 5'd23,
     NOOP_1   = 5'd24,
     NOOP_2   = 5'd25,
     NOOP_3   = 5'd26;

   reg [4:0]   state = IDLE;
   reg [4:0]   next_state;

   always @(*) begin: COMB
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
               icap_din    = 16'h1111;    
            end
        endcase
     end

   always @(posedge clock) begin
      if (clk == 2'b00)
        clk <= 2'b10;
      else if (clk == 2'b10)
        clk <= 2'b11;
      else if (clk == 2'b11)
        clk <= 2'b01;
      else
        clk <= 2'b00;
   end

   always @(posedge clk[1]) begin
      if (MBT_REBOOT == 16'hffff) begin
         state <= next_state;
      end else begin
         MBT_REBOOT <= MBT_REBOOT + 1'b1;
         state <= IDLE;
      end
   end

   always @(posedge clk[1]) begin: ICAP_FF
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

   always @(posedge clock) begin
      counter <= counter + 1'b1;
   end

   assign led1 = 1'b1;
   assign led2 = 1'b0;
   assign led3 = 1'b0;
   assign ld1 = counter[24];
   assign ld2 = ~counter[24];
   assign ld3 = 1'b0;
   assign ld4 = state[4];
   assign ld5 = state[3];
   assign ld6 = state[2];
   assign ld7 = state[1];
   assign ld8 = state[0];

endmodule