module mulacc2(
               input wire           clk,
               input wire           reset_n,
               input wire           clear,
               input wire           next,
               input wire [25 : 0]  a,
               input wire [28 : 0]  b,
               output wire [58 : 0] psum
              );
  reg [25 : 0] a_reg;
  reg [28 : 0] b_reg;
  reg [58 : 0] psum_reg;
  reg [58 : 0] psum_new;
  reg          psum_we;
  assign psum = psum_reg;
  always @ (posedge clk)
    begin : reg_update
      if (!reset_n)
        begin
          a_reg    <= 26'h0;
          b_reg    <= 29'h0;
          psum_reg <= 59'h0;
        end
      else
        begin
          a_reg <= a;
          b_reg <= b;
          if (psum_we)
            psum_reg <= psum_new;
        end
    end 
  always @*
    begin : mac_logic
      psum_new = 59'h0;
      psum_we  = 0;
      if (clear)
        begin
          psum_new = 59'h0;
          psum_we  = 1;
        end
      if (next)
        begin
          psum_new = (a_reg * b_reg) + psum_reg;
        end
    end
endmodule 
