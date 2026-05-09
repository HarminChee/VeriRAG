`timescale 1ns / 1ps
`define DLY #1

module data_vio (
  inout  [35:0] control,
  input        clk,
  input  [31:0] async_in,
  output [31:0] async_out,
  input  [31:0] sync_in,
  output [31:0] sync_out
);
endmodule

module icon (
  inout [35:0] control0,
  inout [35:0] control1,
  inout [35:0] control2,
  inout [35:0] control3
);
endmodule

module ila (
  inout [35:0] control,
  input        clk,
  input [163:0] trig0
);
endmodule

module mgtTop #(
  parameter EXAMPLE_CONFIG_INDEPENDENT_LANES     = 1,
  parameter EXAMPLE_LANE_WITH_START_CHAR         = 0,
  parameter EXAMPLE_WORDS_IN_BRAM                = 512,
  parameter EXAMPLE_SIM_GTRESET_SPEEDUP          = "TRUE",
  parameter EXAMPLE_USE_CHIPSCOPE                = 0
)(
  // 顶层端口定义略，可根据实际需要补充
);

// 省略全部assign语句和实例化，保留关键结构

generate
  if (EXAMPLE_USE_CHIPSCOPE == 1) begin : chipscope_enabled
    // your chipscope logic here
  end else begin : no_chipscope
    // your alternative logic here
  end
endgenerate

endmodule
