module t (
   clk
   );
   input clk;
   logic unsigned [15:0] luv;  
   logic   signed [15:0] lsv;  
   int cnt = 0;
   bit mod = 1'b0;
   always @ (posedge clk) begin
      mod <= ~mod;
      cnt <= cnt + {31'b0, mod};
   end
   always @ (posedge clk)
   if (mod && (cnt==3)) begin
      $write("*-* All Finished *-*\n");
      $finish;
   end
   always @ (posedge clk)
   begin
      if (cnt==  0) begin if (~mod)  luv <= '0;     else begin if (luv !== 16'b0000_0000_0000_0000) begin $display("luv = 'b%b != '0",     luv); $stop(); end end end
      if (cnt==  1) begin if (~mod)  luv <= '1;     else begin if (luv !== 16'b1111_1111_1111_1111) begin $display("luv = 'b%b != '1",     luv); $stop(); end end end
      if (cnt==  2) begin if (~mod)  luv <= 'x;     else begin if (luv !== 16'bxxxx_xxxx_xxxx_xxxx) begin $display("luv = 'b%b != 'x",     luv); $stop(); end end end
      if (cnt==  3) begin if (~mod)  luv <= 'z;     else begin if (luv !== 16'bzzzz_zzzz_zzzz_zzzz) begin $display("luv = 'b%b != 'z",     luv); $stop(); end end end
      if (cnt==  4) begin if (~mod)  luv <= 'b0;    else begin if (luv !== 16'b0000_0000_0000_0000) begin $display("luv = 'b%b != 'b0",    luv); $stop(); end end end
      if (cnt==  5) begin if (~mod)  luv <= 'b1;    else begin if (luv !== 16'b0000_0000_0000_0001) begin $display("luv = 'b%b != 'b1",    luv); $stop(); end end end
      if (cnt==  6) begin if (~mod)  luv <= 'bx;    else begin if (luv !== 16'bxxxx_xxxx_xxxx_xxxx) begin $display("luv = 'b%b != 'bx",    luv); $stop(); end end end
      if (cnt==  7) begin if (~mod)  luv <= 'bz;    else begin if (luv !== 16'bzzzz_zzzz_zzzz_zzzz) begin $display("luv = 'b%b != 'bz",    luv); $stop(); end end end
      if (cnt==  8) begin if (~mod)  luv <= 'b00;   else begin if (luv !== 16'b0000_0000_0000_0000) begin $display("luv = 'b%b != 'b00",   luv); $stop(); end end end
      if (cnt==  9) begin if (~mod)  luv <= 'b11;   else begin if (luv !== 16'b0000_0000_0000_0011) begin $display("luv = 'b%b != 'b11",   luv); $stop(); end end end
      if (cnt== 10) begin if (~mod)  luv <= 'bxx;   else begin if (luv !== 16'bxxxx_xxxx_xxxx_xxxx) begin $display("luv = 'b%b != 'bxx",   luv); $stop(); end end end
      if (cnt== 11) begin if (~mod)  luv <= 'bzz;   else begin if (luv !== 16'bzzzz_zzzz_zzzz_zzzz) begin $display("luv = 'b%b != 'bzz",   luv); $stop(); end end end
      if (cnt== 12) begin if (~mod)  luv <= 'b1x;   else begin if (luv !== 16'b0000_0000_0000_001x) begin $display("luv = 'b%b != 'b1x",   luv); $stop(); end end end
      if (cnt== 13) begin if (~mod)  luv <= 'b1z;   else begin if (luv !== 16'b0000_0000_0000_001z) begin $display("luv = 'b%b != 'b1z",   luv); $stop(); end end end
      if (cnt== 14) begin if (~mod)  luv <= 'bx1;   else begin if (luv !== 16'bxxxx_xxxx_xxxx_xxx1) begin $display("luv = 'b%b != 'bx1",   luv); $stop(); end end end
      if (cnt== 15) begin if (~mod)  luv <= 'bz1;   else begin if (luv !== 16'bzzzz_zzzz_zzzz_zzz1) begin $display("luv = 'b%b != 'bz1",   luv); $stop(); end end end
      if (cnt== 16) begin if (~mod)  luv <= 'o0;    else begin if (luv !== 16'b0000_0000_0000_0000) begin $display("luv = 'b%b != 'o0",    luv); $stop(); end end end
      if (cnt== 17) begin if (~mod)  luv <= 'o5;    else begin if (luv !== 16'b0000_0000_0000_0101) begin $display("luv = 'b%b != 'o5",    luv); $stop(); end end end
      if (cnt== 18) begin if (~mod)  luv <= 'ox;    else begin if (luv !== 16'bxxxx_xxxx_xxxx_xxxx) begin $display("luv = 'b%b != 'ox",    luv); $stop(); end end end
      if (cnt== 19) begin if (~mod)  luv <= 'oz;    else begin if (luv !== 16'bzzzz_zzzz_zzzz_zzzz) begin $display("luv = 'b%b != 'oz",    luv); $stop(); end end end
      if (cnt== 20) begin if (~mod)  luv <= 'o00;   else begin if (luv !== 16'b0000_0000_0000_0000) begin $display("luv = 'b%b != 'o00",   luv); $stop(); end end end
      if (cnt== 21) begin if (~mod)  luv <= 'o55;   else begin if (luv !== 16'b0000_0000_0010_1101) begin $display("luv = 'b%b != 'o55",   luv); $stop(); end end end
      if (cnt== 22) begin if (~mod)  luv <= 'oxx;   else begin if (luv !== 16'bxxxx_xxxx_xxxx_xxxx) begin $display("luv = 'b%b != 'oxx",   luv); $stop(); end end end
      if (cnt== 23) begin if (~mod)  luv <= 'ozz;   else begin if (luv !== 16'bzzzz_zzzz_zzzz_zzzz) begin $display("luv = 'b%b != 'ozz",   luv); $stop(); end end end
      if (cnt== 24) begin if (~mod)  luv <= 'o5x;   else begin if (luv !== 16'b0000_0000_0010_1xxx) begin $display("luv = 'b%b != 'o5x",   luv); $stop(); end end end
      if (cnt== 25) begin if (~mod)  luv <= 'o5z;   else begin if (luv !== 16'b0000_0000_0010_1zzz) begin $display("luv = 'b%b != 'o5z",   luv); $stop(); end end end
      if (cnt== 26) begin if (~mod)  luv <= 'ox5;   else begin if (luv !== 16'bxxxx_xxxx_xxxx_x101) begin $display("luv = 'b%b != 'ox5",   luv); $stop(); end end end
      if (cnt== 27) begin if (~mod)  luv <= 'oz5;   else begin if (luv !== 16'bzzzz_zzzz_zzzz_z101) begin $display("luv = 'b%b != 'oz5",   luv); $stop(); end end end
      if (cnt== 28) begin if (~mod)  luv <= 'h0;    else begin if (luv !== 16'b0000_0000_0000_0000) begin $display("luv = 'b%b != 'h0",    luv); $stop(); end end end
      if (cnt== 29) begin if (~mod)  luv <= 'h9;    else begin if (luv !== 16'b0000_0000_0000_1001) begin $display("luv = 'b%b != 'h9",    luv); $stop(); end end end
      if (cnt== 30) begin if (~mod)  luv <= 'hx;    else begin if (luv !== 16'bxxxx_xxxx_xxxx_xxxx) begin $display("luv = 'b%b != 'hx",    luv); $stop(); end end end
      if (cnt== 31) begin if (~mod)  luv <= 'hz;    else begin if (luv !== 16'bzzzz_zzzz_zzzz_zzzz) begin $display("luv = 'b%b != 'hz",    luv); $stop(); end end end
      if (cnt== 32) begin if (~mod)  luv <= 'h00;   else begin if (luv !== 16'b0000_0000_0000_0000) begin $display("luv = 'b%b != 'h00",   luv); $stop(); end end end
      if (cnt== 33) begin if (~mod)  luv <= 'h99;   else begin if (luv !== 16'b0000_0000_1001_1001) begin $display("luv = 'b%b != 'h99",   luv); $stop(); end end end
      if (cnt== 34) begin if (~mod)  luv <= 'hxx;   else begin if (luv !== 16'bxxxx_xxxx_xxxx_xxxx) begin $display("luv = 'b%b != 'hxx",   luv); $stop(); end end end
      if (cnt== 35) begin if (~mod)  luv <= 'hzz;   else begin if (luv !== 16'bzzzz_zzzz_zzzz_zzzz) begin $display("luv = 'b%b != 'hzz",   luv); $stop(); end end end
      if (cnt== 36) begin if (~mod)  luv <= 'h9x;   else begin if (luv !== 16'b0000_0000_1001_xxxx) begin $display("luv = 'b%b != 'h9x",   luv); $stop(); end end end
      if (cnt== 37) begin if (~mod)  luv <= 'h9z;   else begin if (luv !== 16'b0000_0000_1001_zzzz) begin $display("luv = 'b%b != 'h9z",   luv); $stop(); end end end
      if (cnt== 38) begin if (~mod)  luv <= 'hx9;   else begin if (luv !== 16'bxxxx_xxxx_xxxx_1001) begin $display("luv = 'b%b != 'hx9",   luv); $stop(); end end end
      if (cnt== 39) begin if (~mod)  luv <= 'hz9;   else begin if (luv !== 16'bzzzz_zzzz_zzzz_1001) begin $display("luv = 'b%b != 'hz9",   luv); $stop(); end end end
      if (cnt== 40) begin if (~mod)  luv <= 'd0;    else begin if (luv !== 16'b0000_0000_0000_0000) begin $display("luv = 'b%b != 'd0",    luv); $stop(); end end end
      if (cnt== 41) begin if (~mod)  luv <= 'd9;    else begin if (luv !== 16'b0000_0000_0000_1001) begin $display("luv = 'b%b != 'd9",    luv); $stop(); end end end
      if (cnt== 45) begin if (~mod)  luv <= 'd00;   else begin if (luv !== 16'b0000_0000_0000_0000) begin $display("luv = 'b%b != 'd00",   luv); $stop(); end end end
      if (cnt== 46) begin if (~mod)  luv <= 'd99;   else begin if (luv !== 16'b0000_0000_0110_0011) begin $display("luv = 'b%b != 'd99",   luv); $stop(); end end end
   end
endmodule 
