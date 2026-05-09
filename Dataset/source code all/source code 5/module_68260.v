`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module mig_7series_v4_0_axi_ctrl_reg #
(
  parameter integer C_REG_WIDTH         = 32,
  parameter integer C_DATA_WIDTH        = 32,
  parameter         C_INIT              = 32'h0,
  parameter         C_MASK              = 32'h1
)
(
  input  wire                               clk         , 
  input  wire                               reset       , 
  input  wire [C_REG_WIDTH-1:0]             data_in     , 
  input  wire                               we          , 
  input  wire                               we_int      , 
  input  wire [C_REG_WIDTH-1:0]             data_in_int , 
  output wire [C_DATA_WIDTH-1:0]            data_out
);
reg [C_REG_WIDTH-1:0] data;
always @(posedge clk) begin
  if (reset) begin
    data <= C_INIT[0+:C_REG_WIDTH];
  end
  else if (we) begin
    data <= data_in;
  end
  else if (we_int) begin
    data <= data_in_int;
  end
  else begin
    data <= data;
  end
end
generate 
  if (C_REG_WIDTH == C_DATA_WIDTH) begin : assign_no_zero_pad
    assign data_out = data;
  end
  else begin : assign_zero_pad
    assign data_out = {{C_DATA_WIDTH-C_REG_WIDTH{1'b0}}, data};
  end
endgenerate
endmodule
`default_nettype wire
