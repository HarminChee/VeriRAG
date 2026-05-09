`timescale 1ns / 1ps
`timescale 1ns / 1ps
module WireDelay # (
  parameter Delay_g = 0,
  parameter Delay_rd = 0,
  parameter ERR_INSERT = "OFF"
)
(
  inout A,
  inout B,
  input reset,
  input phy_init_done
);
  reg A_r;
  reg B_r;
  reg B_inv ;
  reg line_en;
  assign A = A_r;
  assign B = B_r;
  always@(*)
    if((B == 'b1) || (B == 'b0))
      B_inv <= #0 ~B ;
    else
      B_inv <= #0 'bz ;
  always @(*) begin
    if (!reset) begin
      A_r <= 1'bz;
      B_r <= 1'bz;
      line_en <= 1'b0;
    end else begin
      if (line_en) begin
	B_r <= 1'bz;
	  if ((ERR_INSERT == "ON") & (phy_init_done))
            A_r <= #Delay_rd B_inv;
	  else
            A_r <= #Delay_rd B;
      end else begin
        B_r <= #Delay_g A;
	A_r <= 1'bz;
      end
    end
  end
  always @(A or B) begin
    if (!reset) begin
      line_en <= 1'b0;
    end else if (A !== A_r) begin
      line_en <= 1'b0;
    end else if (B_r !== B) begin
      line_en <= 1'b1;
    end else begin
      line_en <= line_en;
    end
  end
endmodule
