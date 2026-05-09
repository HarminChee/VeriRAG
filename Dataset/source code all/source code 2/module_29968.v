`timescale 1ns / 1ps
module regfile(
  input [31:0] Aselect,
  input [31:0] Bselect,
  input [31:0] Dselect,
  input [31:0] dbus,
  output [31:0] abus,
  output [31:0] bbus,
  input clk
  );
  assign abus = Aselect[0] ? 32'b0 : 32'bz;
  assign bbus = Bselect[0] ? 32'b0 : 32'bz;
  DNegflipFlop myFlips[30:0](
      .dbus(dbus),
      .abus(abus),
      .Dselect(Dselect[31:1]),
      .Bselect(Bselect[31:1]),
      .Aselect(Aselect[31:1]),
      .bbus(bbus),
      .clk(clk)
    );
  endmodule
  module DNegflipFlop(dbus, abus, Dselect, Bselect, Aselect, bbus, clk);
    input [31:0] dbus;
    input Dselect;
    input Bselect;
    input Aselect;
    input clk;
    output [31:0] abus;
    output [31:0] bbus;
    reg [31:0] data;
    always @(negedge clk) begin
      if(Dselect) begin
      data = dbus;
      end
    end
    assign abus = Aselect ? data : 32'bz;
    assign bbus = Bselect ? data : 32'bz;
  endmodule
`timescale 1ns / 1ps
module regfile(
  input [31:0] Aselect,
  input [31:0] Bselect,
  input [31:0] Dselect,
  input [31:0] dbus,
  output [31:0] abus,
  output [31:0] bbus,
  input clk
  );
  assign abus = Aselect[0] ? 32'b0 : 32'bz;
  assign bbus = Bselect[0] ? 32'b0 : 32'bz;
  DNegflipFlop myFlips[30:0](
      .dbus(dbus),
      .abus(abus),
      .Dselect(Dselect[31:1]),
      .Bselect(Bselect[31:1]),
      .Aselect(Aselect[31:1]),
      .bbus(bbus),
      .clk(clk)
    );
  endmodule
  module DNegflipFlop(dbus, abus, Dselect, Bselect, Aselect, bbus, clk);
    input [31:0] dbus;
    input Dselect;
    input Bselect;
    input Aselect;
    input clk;
    output [31:0] abus;
    output [31:0] bbus;
    reg [31:0] data;
    always @(negedge clk) begin
      if(Dselect) begin
      data = dbus;
      end
    end
    assign abus = Aselect ? data : 32'bz;
    assign bbus = Bselect ? data : 32'bz;
  endmodule
