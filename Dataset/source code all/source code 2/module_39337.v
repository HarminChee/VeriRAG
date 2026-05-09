`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module decoder (clk, data_in, xgmii_rxd, xgmii_rxc, r_type, sync_lock, init, idle_bus);
   input clk; 
   input[65:0] data_in; 
   output[63:0] xgmii_rxd; 
   wire[63:0] xgmii_rxd;
   output[7:0] xgmii_rxc; 
   wire[7:0] xgmii_rxc;
   output [2:0] r_type; 
   wire [2:0] r_type;
   input sync_lock; 
   input init; 
   output[7:0] idle_bus; 
   wire[7:0] idle_bus;
   reg[7:0] byte0; 
   reg[7:0] byte1; 
   reg[7:0] byte2; 
   reg[7:0] byte3; 
   reg[7:0] byte4; 
   reg[7:0] byte5; 
   reg[7:0] byte6; 
   reg[7:0] byte7; 
   reg c0; 
   reg c1; 
   reg c2; 
   reg c3; 
   reg c4; 
   reg c5; 
   reg c6; 
   reg c7; 
   wire[1:0] sync_field; 
   wire[7:0] type_field; 
   wire[65:0] data_field; 
   wire data_word; 
   wire control_word; 
   wire type_1e; 
   wire type_2d; 
   wire type_33; 
   wire type_66; 
   wire type_55; 
   wire type_78; 
   wire type_4b; 
   wire type_87; 
   wire type_99; 
   wire type_aa; 
   wire type_b4; 
   wire type_cc; 
   wire type_d2; 
   wire type_e1; 
   wire type_ff; 
   reg[14:0] type_reg; 
   wire[65:0] int_data_in; 
   reg[65:0] data_field_reg; 
   reg[7:0] control0; 
   reg[7:0] control1; 
   reg[7:0] control2; 
   reg[7:0] control3; 
   reg[7:0] control4; 
   reg[7:0] control5; 
   reg[7:0] control6; 
   reg[7:0] control7; 
   reg lane0_seq_9c; 
   reg lane0_seq_5c; 
   reg lane4_seq_9c; 
   reg lane4_seq_5c; 
   wire int_init; 
   reg [2:0] int_r_type; 
   wire[2:0] int_rt_bv; 
   wire[2:0] int_rt_del; 
   wire gnd; 
   wire r_type_pre_reg; 
   parameter dly = 1; 
   parameter [2:0] control = 3'b000;
   parameter [2:0] start = 3'b001;
   parameter [2:0] data = 3'b010;
   parameter [2:0] terminate = 3'b011;
   parameter [2:0] error = 3'b100;
   assign gnd = 1'b0 ;
   assign int_data_in = data_in ;
   assign int_init = init | ~(sync_lock) ;
   assign sync_field = int_data_in[1:0] ;
   assign type_field = int_data_in[9:2] ;
   assign data_field = int_data_in ;
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         data_field_reg <= #dly {66{1'b0}} ; 
      end
      else
      begin
         data_field_reg <= #dly data_field ; 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         control0 <= #dly {8{1'b0}} ; 
      end
      else
      begin
         if (data_field[16:10] == 7'b0000000)
         begin
            control0 <= #dly 8'b00000111 ; 
         end
         else if (data_field[16:10] == 7'b0101101)
         begin
            control0 <= #dly 8'b00011100 ; 
         end
         else if (data_field[16:10] == 7'b0110011)
         begin
            control0 <= #dly 8'b00111100 ; 
         end
         else if (data_field[16:10] == 7'b1001011)
         begin
            control0 <= #dly 8'b01111100 ; 
         end
         else if (data_field[16:10] == 7'b1010101)
         begin
            control0 <= #dly 8'b10111100 ; 
         end
         else if (data_field[16:10] == 7'b1100110)
         begin
            control0 <= #dly 8'b11011100 ; 
         end
         else if (data_field[16:10] == 7'b1111000)
         begin
            control0 <= #dly 8'b11110111 ; 
         end
         else
         begin
            control0 <= #dly 8'b11111110 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         lane0_seq_9c <= #dly 1'b0 ; 
         lane0_seq_5c <= #dly 1'b0 ; 
      end
      else
      begin
         lane0_seq_9c <= #dly (sync_field[0] & ~(sync_field[1])) & ((type_66 | type_55 | type_4b) & ~(data_field[35]) & ~(data_field[34]) & ~(data_field[33]) & ~(data_field[32])) ; 
         lane0_seq_5c <= #dly (sync_field[0] & ~(sync_field[1])) & ((type_66 | type_55 | type_4b) & data_field[35] & data_field[34] & data_field[33] & data_field[32]) ; 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         control1 <= #dly {8{1'b0}} ; 
      end
      else
      begin
         if (data_field[23:17] == 7'b0000000)
         begin
            control1 <= #dly 8'b00000111 ; 
         end
         else if (data_field[23:17] == 7'b0101101)
         begin
            control1 <= #dly 8'b00011100 ; 
         end
         else if (data_field[23:17] == 7'b0110011)
         begin
            control1 <= #dly 8'b00111100 ; 
         end
         else if (data_field[23:17] == 7'b1001011)
         begin
            control1 <= #dly 8'b01111100 ; 
         end
         else if (data_field[23:17] == 7'b1010101)
         begin
            control1 <= #dly 8'b10111100 ; 
         end
         else if (data_field[23:17] == 7'b1100110)
         begin
            control1 <= #dly 8'b11011100 ; 
         end
         else if (data_field[23:17] == 7'b1111000)
         begin
            control1 <= #dly 8'b11110111 ; 
         end
         else
         begin
            control1 <= #dly 8'b11111110 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         control2 <= #dly {8{1'b0}} ; 
      end
      else
      begin
         if (data_field[30:24] == 7'b0000000)
         begin
            control2 <= #dly 8'b00000111 ; 
         end
         else if (data_field[30:24] == 7'b0101101)
         begin
            control2 <= #dly 8'b00011100 ; 
         end
         else if (data_field[30:24] == 7'b0110011)
         begin
            control2 <= #dly 8'b00111100 ; 
         end
         else if (data_field[30:24] == 7'b1001011)
         begin
            control2 <= #dly 8'b01111100 ; 
         end
         else if (data_field[30:24] == 7'b1010101)
         begin
            control2 <= #dly 8'b10111100 ; 
         end
         else if (data_field[30:24] == 7'b1100110)
         begin
            control2 <= #dly 8'b11011100 ; 
         end
         else if (data_field[30:24] == 7'b1111000)
         begin
            control2 <= #dly 8'b11110111 ; 
         end
         else
         begin
            control2 <= #dly 8'b11111110 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         control3 <= #dly {8{1'b0}} ; 
      end
      else
      begin
         if (data_field[37:31] == 7'b0000000)
         begin
            control3 <= #dly 8'b00000111 ; 
         end
         else if (data_field[37:31] == 7'b0101101)
         begin
            control3 <= #dly 8'b00011100 ; 
         end
         else if (data_field[37:31] == 7'b0110011)
         begin
            control3 <= #dly 8'b00111100 ; 
         end
         else if (data_field[37:31] == 7'b1001011)
         begin
            control3 <= #dly 8'b01111100 ; 
         end
         else if (data_field[37:31] == 7'b1010101)
         begin
            control3 <= #dly 8'b10111100 ; 
         end
         else if (data_field[37:31] == 7'b1100110)
         begin
            control3 <= #dly 8'b11011100 ; 
         end
         else if (data_field[37:31] == 7'b1111000)
         begin
            control3 <= #dly 8'b11110111 ; 
         end
         else
         begin
            control3 <= #dly 8'b11111110 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         control4 <= #dly {8{1'b0}} ; 
      end
      else
      begin
         if (data_field[44:38] == 7'b0000000)
         begin
            control4 <= #dly 8'b00000111 ; 
         end
         else if (data_field[44:38] == 7'b0101101)
         begin
            control4 <= #dly 8'b00011100 ; 
         end
         else if (data_field[44:38] == 7'b0110011)
         begin
            control4 <= #dly 8'b00111100 ; 
         end
         else if (data_field[44:38] == 7'b1001011)
         begin
            control4 <= #dly 8'b01111100 ; 
         end
         else if (data_field[44:38] == 7'b1010101)
         begin
            control4 <= #dly 8'b10111100 ; 
         end
         else if (data_field[44:38] == 7'b1100110)
         begin
            control4 <= #dly 8'b11011100 ; 
         end
         else if (data_field[44:38] == 7'b1111000)
         begin
            control4 <= #dly 8'b11110111 ; 
         end
         else
         begin
            control4 <= #dly 8'b11111110 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         lane4_seq_9c <= #dly 1'b0 ; 
         lane4_seq_5c <= #dly 1'b0 ; 
      end
      else
      begin
         lane4_seq_9c <= #dly (sync_field[0] & ~(sync_field[1])) & ((type_2d | type_55) & ~(data_field[39]) & ~(data_field[38]) & ~(data_field[37]) & ~(data_field[36])) ; 
         lane4_seq_5c <= #dly (sync_field[0] & ~(sync_field[1])) & ((type_2d | type_55) & data_field[39] & data_field[38] & data_field[37] & data_field[36]) ; 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         control5 <= #dly {8{1'b0}} ; 
      end
      else
      begin
         if (data_field[51:45] == 7'b0000000)
         begin
            control5 <= #dly 8'b00000111 ; 
         end
         else if (data_field[51:45] == 7'b0101101)
         begin
            control5 <= #dly 8'b00011100 ; 
         end
         else if (data_field[51:45] == 7'b0110011)
         begin
            control5 <= #dly 8'b00111100 ; 
         end
         else if (data_field[51:45] == 7'b1001011)
         begin
            control5 <= #dly 8'b01111100 ; 
         end
         else if (data_field[51:45] == 7'b1010101)
         begin
            control5 <= #dly 8'b10111100 ; 
         end
         else if (data_field[51:45] == 7'b1100110)
         begin
            control5 <= #dly 8'b11011100 ; 
         end
         else if (data_field[51:45] == 7'b1111000)
         begin
            control5 <= #dly 8'b11110111 ; 
         end
         else
         begin
            control5 <= #dly 8'b11111110 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         control6 <= #dly {8{1'b0}} ; 
      end
      else
      begin
         if (data_field[58:52] == 7'b0000000)
         begin
            control6 <= #dly 8'b00000111 ; 
         end
         else if (data_field[58:52] == 7'b0101101)
         begin
            control6 <= #dly 8'b00011100 ; 
         end
         else if (data_field[58:52] == 7'b0110011)
         begin
            control6 <= #dly 8'b00111100 ; 
         end
         else if (data_field[58:52] == 7'b1001011)
         begin
            control6 <= #dly 8'b01111100 ; 
         end
         else if (data_field[58:52] == 7'b1010101)
         begin
            control6 <= #dly 8'b10111100 ; 
         end
         else if (data_field[58:52] == 7'b1100110)
         begin
            control6 <= #dly 8'b11011100 ; 
         end
         else if (data_field[58:52] == 7'b1111000)
         begin
            control6 <= #dly 8'b11110111 ; 
         end
         else
         begin
            control6 <= #dly 8'b11111110 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         control7 <= #dly {8{1'b0}} ; 
      end
      else
      begin
         if (data_field[65:59] == 7'b0000000)
         begin
            control7 <= #dly 8'b00000111 ; 
         end
         else if (data_field[65:59] == 7'b0101101)
         begin
            control7 <= #dly 8'b00011100 ; 
         end
         else if (data_field[65:59] == 7'b0110011)
         begin
            control7 <= #dly 8'b00111100 ; 
         end
         else if (data_field[65:59] == 7'b1001011)
         begin
            control7 <= #dly 8'b01111100 ; 
         end
         else if (data_field[65:59] == 7'b1010101)
         begin
            control7 <= #dly 8'b10111100 ; 
         end
         else if (data_field[65:59] == 7'b1100110)
         begin
            control7 <= #dly 8'b11011100 ; 
         end
         else if (data_field[65:59] == 7'b1111000)
         begin
            control7 <= #dly 8'b11110111 ; 
         end
         else
         begin
            control7 <= #dly 8'b11111110 ; 
         end 
      end 
   end 
   assign data_word = ~(sync_field[0]) & sync_field[1] ;
   assign control_word = sync_field[0] & ~(sync_field[1]) ;
   assign type_1e = ~(type_field[7]) & ~(type_field[6]) & ~(type_field[5]) & type_field[4] & type_field[3] & type_field[2] & type_field[1] & ~(type_field[0]) ;
   assign type_2d = ~(type_field[7]) & ~(type_field[6]) & type_field[5] & ~(type_field[4]) & type_field[3] & type_field[2] & ~(type_field[1]) & type_field[0] ;
   assign type_33 = ~(type_field[7]) & ~(type_field[6]) & type_field[5] & type_field[4] & ~(type_field[3]) & ~(type_field[2]) & type_field[1] & type_field[0] ;
   assign type_66 = ~(type_field[7]) & type_field[6] & type_field[5] & ~(type_field[4]) & ~(type_field[3]) & type_field[2] & type_field[1] & ~(type_field[0]) ;
   assign type_55 = ~(type_field[7]) & type_field[6] & ~(type_field[5]) & type_field[4] & ~(type_field[3]) & type_field[2] & ~(type_field[1]) & type_field[0] ;
   assign type_78 = ~(type_field[7]) & type_field[6] & type_field[5] & type_field[4] & type_field[3] & ~(type_field[2]) & ~(type_field[1]) & ~(type_field[0]) ;
   assign type_4b = ~(type_field[7]) & type_field[6] & ~(type_field[5]) & ~(type_field[4]) & type_field[3] & ~(type_field[2]) & type_field[1] & type_field[0] ;
   assign type_87 = type_field[7] & ~(type_field[6]) & ~(type_field[5]) & ~(type_field[4]) & ~(type_field[3]) & type_field[2] & type_field[1] & type_field[0] ;
   assign type_99 = type_field[7] & ~(type_field[6]) & ~(type_field[5]) & type_field[4] & type_field[3] & ~(type_field[2]) & ~(type_field[1]) & type_field[0] ;
   assign type_aa = type_field[7] & ~(type_field[6]) & type_field[5] & ~(type_field[4]) & type_field[3] & ~(type_field[2]) & type_field[1] & ~(type_field[0]) ;
   assign type_b4 = type_field[7] & ~(type_field[6]) & type_field[5] & type_field[4] & ~(type_field[3]) & type_field[2] & ~(type_field[1]) & ~(type_field[0]) ;
   assign type_cc = type_field[7] & type_field[6] & ~(type_field[5]) & ~(type_field[4]) & type_field[3] & type_field[2] & ~(type_field[1]) & ~(type_field[0]) ;
   assign type_d2 = type_field[7] & type_field[6] & ~(type_field[5]) & type_field[4] & ~(type_field[3]) & ~(type_field[2]) & type_field[1] & ~(type_field[0]) ;
   assign type_e1 = type_field[7] & type_field[6] & type_field[5] & ~(type_field[4]) & ~(type_field[3]) & ~(type_field[2]) & ~(type_field[1]) & type_field[0] ;
   assign type_ff = type_field[7] & type_field[6] & type_field[5] & type_field[4] & type_field[3] & type_field[2] & type_field[1] & type_field[0] ;
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         type_reg <= #dly {15{1'b0}} ; 
      end
      else
      begin
         type_reg <= #dly ({(control_word & type_ff), (control_word & type_e1), (control_word & type_d2), (control_word & type_cc), (control_word & type_b4), (control_word & type_aa), (control_word & type_99), (control_word & type_87), (control_word & type_4b), (control_word & type_78), (control_word & type_55), (control_word & type_66), (control_word & type_33), (control_word & type_2d), (control_word & type_1e)}) ; 
      end 
   end 
   always @(posedge init or posedge clk)
   begin 
      if (init == 1'b1)
      begin
         int_r_type <= #dly control ; 
      end
      else
      begin
         if (control_word == 1'b1 & (type_ff == 1'b1 | type_e1 == 1'b1 | type_d2 == 1'b1 | type_cc == 1'b1 | type_b4 == 1'b1 | type_aa == 1'b1 | type_99 == 1'b1 | type_87 == 1'b1))
         begin
            int_r_type <= #dly terminate ; 
         end
         else if (control_word == 1'b1 & (type_1e == 1'b1 | type_2d == 1'b1 | type_55 == 1'b1 | type_4b == 1'b1))
         begin
            int_r_type <= #dly control ; 
         end
         else if (control_word == 1'b1 & (type_33 == 1'b1 | type_66 == 1'b1 | type_78 == 1'b1))
         begin
            int_r_type <= #dly start ; 
         end
         else if (control_word == 1'b0)
         begin
            int_r_type <= #dly data ; 
         end
         else
         begin
            int_r_type <= #dly error ; 
         end
      end 
   end 
   assign r_type = int_r_type ;
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         byte0 <= #dly {8{1'b0}} ; 
         c0 <= #dly 1'b0 ; 
      end
      else
      begin
         if (type_reg[2:0] != 3'b000)
         begin
            byte0 <= #dly control0 ; 
            c0 <= #dly 1'b1 ; 
         end
         else if ((type_reg[3]) == 1'b1 & lane0_seq_9c == 1'b1)
         begin
            byte0 <= #dly 8'b10011100 ; 
            c0 <= #dly 1'b1 ; 
         end
         else if ((type_reg[3]) == 1'b1 & lane0_seq_5c == 1'b1)
         begin
            byte0 <= #dly 8'b01011100 ; 
            c0 <= #dly 1'b1 ; 
         end
         else if ((type_reg[4]) == 1'b1 & lane0_seq_9c == 1'b1)
         begin
            byte0 <= #dly 8'b10011100 ; 
            c0 <= #dly 1'b1 ; 
         end
         else if ((type_reg[4]) == 1'b1 & lane0_seq_5c == 1'b1)
         begin
            byte0 <= #dly 8'b01011100 ; 
            c0 <= #dly 1'b1 ; 
         end
         else if ((type_reg[5]) == 1'b1)
         begin
            byte0 <= #dly 8'b11111011 ; 
            c0 <= #dly 1'b1 ; 
         end
         else if ((type_reg[6]) == 1'b1 & lane0_seq_9c == 1'b1)
         begin
            byte0 <= #dly 8'b10011100 ; 
            c0 <= #dly 1'b1 ; 
         end
         else if ((type_reg[6]) == 1'b1 & lane0_seq_5c == 1'b1)
         begin
            byte0 <= #dly 8'b01011100 ; 
            c0 <= #dly 1'b1 ; 
         end
         else if ((type_reg[7]) == 1'b1)
         begin
            byte0 <= #dly 8'b11111101 ; 
            c0 <= #dly 1'b1 ; 
         end
         else if (type_reg[14:8] != 7'b0000000)
         begin
            byte0 <= #dly data_field_reg[17:10] ; 
            c0 <= #dly 1'b0 ; 
         end
         else
         begin
            byte0 <= #dly data_field_reg[9:2] ; 
            c0 <= #dly 1'b0 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         byte1 <= #dly {8{1'b0}} ; 
         c1 <= #dly 1'b0 ; 
      end
      else
      begin
         if (type_reg[2:0] != 3'b000)
         begin
            byte1 <= #dly control1 ; 
            c1 <= #dly 1'b1 ; 
         end
         else if (type_reg[6:3] != 3'b000)
         begin
            byte1 <= #dly data_field_reg[17:10] ; 
            c1 <= #dly 1'b0 ; 
         end
         else if ((type_reg[7]) == 1'b1)
         begin
            byte1 <= #dly control1 ; 
            c1 <= #dly 1'b1 ; 
         end
         else if ((type_reg[8]) == 1'b1)
         begin
            byte1 <= #dly 8'b11111101 ; 
            c1 <= #dly 1'b1 ; 
         end
         else if (type_reg[14:9] != 6'b000000)
         begin
            byte1 <= #dly data_field_reg[25:18] ; 
            c1 <= #dly 1'b0 ; 
         end
         else
         begin
            byte1 <= #dly data_field_reg[17:10] ; 
            c1 <= #dly 1'b0 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         byte2 <= #dly {8{1'b0}} ; 
         c2 <= #dly 1'b0 ; 
      end
      else
      begin
         if (type_reg[2:0] != 3'b000 | type_reg[8:7] != 2'b00)
         begin
            byte2 <= #dly control2 ; 
            c2 <= #dly 1'b1 ; 
         end
         else if (type_reg[6:3] != 3'b000)
         begin
            byte2 <= #dly data_field_reg[25:18] ; 
            c2 <= #dly 1'b0 ; 
         end
         else if ((type_reg[9]) == 1'b1)
         begin
            byte2 <= #dly 8'b11111101 ; 
            c2 <= #dly 1'b1 ; 
         end
         else if (type_reg[14:10] != 5'b00000)
         begin
            byte2 <= #dly data_field_reg[33:26] ; 
            c2 <= #dly 1'b0 ; 
         end
         else
         begin
            byte2 <= #dly data_field_reg[25:18] ; 
            c2 <= #dly 1'b0 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         byte3 <= #dly {8{1'b0}} ; 
         c3 <= #dly 1'b0 ; 
      end
      else
      begin
         if (type_reg[2:0] != 3'b000 | type_reg[9:7] != 3'b000)
         begin
            byte3 <= #dly control3 ; 
            c3 <= #dly 1'b1 ; 
         end
         else if (type_reg[6:3] != 3'b000)
         begin
            byte3 <= #dly data_field_reg[33:26] ; 
            c3 <= #dly 1'b0 ; 
         end
         else if ((type_reg[10]) == 1'b1)
         begin
            byte3 <= #dly 8'b11111101 ; 
            c3 <= #dly 1'b1 ; 
         end
         else if (type_reg[14:11] != 4'b0000)
         begin
            byte3 <= #dly data_field_reg[41:34] ; 
            c3 <= #dly 1'b0 ; 
         end
         else
         begin
            byte3 <= #dly data_field_reg[33:26] ; 
            c3 <= #dly 1'b0 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         byte4 <= #dly {8{1'b0}} ; 
         c4 <= #dly 1'b0 ; 
      end
      else
      begin
         if ((type_reg[0]) == 1'b1 | type_reg[10:6] != 5'b00000)
         begin
            byte4 <= #dly control4 ; 
            c4 <= #dly 1'b1 ; 
         end
         else if ((type_reg[1]) == 1'b1 & lane4_seq_9c == 1'b1)
         begin
            byte4 <= #dly 8'b10011100 ; 
            c4 <= #dly 1'b1 ; 
         end
         else if ((type_reg[1]) == 1'b1 & lane4_seq_5c == 1'b1)
         begin
            byte4 <= #dly 8'b01011100 ; 
            c4 <= #dly 1'b1 ; 
         end
         else if ((type_reg[2]) == 1'b1)
         begin
            byte4 <= #dly 8'b11111011 ; 
            c4 <= #dly 1'b1 ; 
         end
         else if ((type_reg[3]) == 1'b1)
         begin
            byte4 <= #dly 8'b11111011 ; 
            c4 <= #dly 1'b1 ; 
         end
         else if ((type_reg[4]) == 1'b1 & lane4_seq_9c == 1'b1)
         begin
            byte4 <= #dly 8'b10011100 ; 
            c4 <= #dly 1'b1 ; 
         end
         else if ((type_reg[4]) == 1'b1 & lane4_seq_5c == 1'b1)
         begin
            byte4 <= #dly 8'b01011100 ; 
            c4 <= #dly 1'b1 ; 
         end
         else if ((type_reg[5]) == 1'b1)
         begin
            byte4 <= #dly data_field_reg[41:34] ; 
            c4 <= #dly 1'b0 ; 
         end
         else if ((type_reg[11]) == 1'b1)
         begin
            byte4 <= #dly 8'b11111101 ; 
            c4 <= #dly 1'b1 ; 
         end
         else if (type_reg[14:12] != 3'b000)
         begin
            byte4 <= #dly data_field_reg[49:42] ; 
            c4 <= #dly 1'b0 ; 
         end
         else
         begin
            byte4 <= #dly data_field_reg[41:34] ; 
            c4 <= #dly 1'b0 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         byte5 <= #dly {8{1'b0}} ; 
         c5 <= #dly 1'b0 ; 
      end
      else
      begin
         if ((type_reg[0]) == 1'b1 | type_reg[11:6] != 6'b000000)
         begin
            byte5 <= #dly control5 ; 
            c5 <= #dly 1'b1 ; 
         end
         else if (type_reg[5:1] != 5'b00000)
         begin
            byte5 <= #dly data_field_reg[49:42] ; 
            c5 <= #dly 1'b0 ; 
         end
         else if ((type_reg[12]) == 1'b1)
         begin
            byte5 <= #dly 8'b11111101 ; 
            c5 <= #dly 1'b1 ; 
         end
         else if (type_reg[14:13] != 2'b00)
         begin
            byte5 <= #dly data_field_reg[57:50] ; 
            c5 <= #dly 1'b0 ; 
         end
         else
         begin
            byte5 <= #dly data_field_reg[49:42] ; 
            c5 <= #dly 1'b0 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         byte6 <= #dly {8{1'b0}} ; 
         c6 <= #dly 1'b0 ; 
      end
      else
      begin
         if ((type_reg[0]) == 1'b1 | type_reg[12:6] != 7'b0000000)
         begin
            byte6 <= #dly control6 ; 
            c6 <= #dly 1'b1 ; 
         end
         else if (type_reg[5:1] != 5'b00000)
         begin
            byte6 <= #dly data_field_reg[57:50] ; 
            c6 <= #dly 1'b0 ; 
         end
         else if ((type_reg[13]) == 1'b1)
         begin
            byte6 <= #dly 8'b11111101 ; 
            c6 <= #dly 1'b1 ; 
         end
         else if ((type_reg[14]) == 1'b1)
         begin
            byte6 <= #dly data_field_reg[65:58] ; 
            c6 <= #dly 1'b0 ; 
         end
         else
         begin
            byte6 <= #dly data_field_reg[57:50] ; 
            c6 <= #dly 1'b0 ; 
         end 
      end 
   end 
   always @(posedge int_init or posedge clk)
   begin 
      if (int_init == 1'b1)
      begin
         byte7 <= #dly {8{1'b0}} ; 
         c7 <= #dly 1'b0 ; 
      end
      else
      begin
         if ((type_reg[0]) == 1'b1 | type_reg[13:6] != 8'b00000000)
         begin
            byte7 <= #dly control7 ; 
            c7 <= #dly 1'b1 ; 
         end
         else if (type_reg[5:1] != 5'b00000)
         begin
            byte7 <= #dly data_field_reg[65:58] ; 
            c7 <= #dly 1'b0 ; 
         end
         else if ((type_reg[14]) == 1'b1)
         begin
            byte7 <= #dly 8'b11111101 ; 
            c7 <= #dly 1'b1 ; 
         end
         else
         begin
            byte7 <= #dly data_field_reg[65:58] ; 
            c7 <= #dly 1'b0 ; 
         end 
      end 
   end 
   assign xgmii_rxd = {byte7, byte6, byte5, byte4, byte3, byte2, byte1, byte0} ;
   assign xgmii_rxc = {c7, c6, c5, c4, c3, c2, c1, c0} ;
endmodule
