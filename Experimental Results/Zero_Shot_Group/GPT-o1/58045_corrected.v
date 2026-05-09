module reginit(input wire clk, output wire [3:0] data);
  parameter NP  = 23;
  parameter INI = 4'b1100;
  
  wire clk_pres;
  reg [3:0] dout;
  wire [3:0] din;
  reg sel;
  
  initial begin
    sel = 1'b0;
  end

  always @(posedge clk_pres) begin
    dout <= din;
  end

  assign data = dout;
  assign din  = (sel == 1'b0) ? INI : ~dout;

  always @(posedge clk_pres) begin
    sel <= 1'b1;
  end

  prescaler #(.N(NP)) PRES (
    .clk_in(clk),
    .clk_out(clk_pres)
  );
endmodule