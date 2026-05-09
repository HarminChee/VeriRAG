module reginit_corrected_ffc (
  input wire clk,
  output wire [3:0] data
);
  parameter NP = 23;
  parameter INI = 4'b1100;
  wire clk_pres;
  reg [3:0] dout;
  wire [3:0] din;
  reg sel = 0;

  always @(posedge clk) begin
    if (clk_pres) begin
      dout <= din;
      sel <= 1;
    end
  end

  assign data = dout;
  assign din = (sel == 0) ? INI : ~dout;

  prescaler #(.N(NP)) PRES (
    .clk_in(clk),
    .clk_out(clk_pres)
  );

endmodule