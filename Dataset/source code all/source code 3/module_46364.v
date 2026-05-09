`timescale 1ns/100ps
`timescale 1ns/100ps
module axi_dmac_resize_src #(
  parameter DATA_WIDTH_SRC = 64,
  parameter DATA_WIDTH_MEM = 64
) (
  input clk,
  input reset,
  input src_data_valid,
  input [DATA_WIDTH_SRC-1:0] src_data,
  input src_data_last,
  output mem_data_valid,
  output [DATA_WIDTH_MEM-1:0] mem_data,
  output mem_data_last
);
generate if (DATA_WIDTH_SRC == DATA_WIDTH_MEM)  begin
  assign mem_data_valid = src_data_valid;
  assign mem_data = src_data;
  assign mem_data_last = src_data_last;
end else begin
  localparam RATIO = DATA_WIDTH_MEM / DATA_WIDTH_SRC;
  reg [RATIO-1:0] mask = 'h1;
  reg valid = 1'b0;
  reg last = 1'b0;
  reg [DATA_WIDTH_MEM-1:0] data = 'h0;
  always @(posedge clk) begin
    if (reset == 1'b1) begin
      valid <= 1'b0;
      mask <= 'h1;
    end else if (src_data_valid == 1'b1) begin
      valid <= mask[RATIO-1] || src_data_last;
      if (src_data_last) begin
        mask <= 'h1;
      end else begin
        mask <= {mask[RATIO-2:0],mask[RATIO-1]};
      end
    end else begin
      valid <= 1'b0;
    end
  end
  integer i;
  always @(posedge clk) begin
    for (i = 0; i < RATIO; i = i+1) begin
      if (mask[i] == 1'b1) begin
        data[i*DATA_WIDTH_SRC+:DATA_WIDTH_SRC] <= src_data;
      end
    end
    last <= src_data_last;
  end
  assign mem_data_valid = valid;
  assign mem_data = data;
  assign mem_data_last = last;
end endgenerate
endmodule
