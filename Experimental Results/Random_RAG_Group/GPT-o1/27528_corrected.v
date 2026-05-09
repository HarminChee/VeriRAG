`timescale 1ns / 1ps
`timescale 1ns / 1ps
module ym_sync(
  input rst,
  input clk,
  input ym_p1,
  input ym_so,
  input ym_sh1,
  input ym_sh2,
  input ym_irq_n,
  input [7:0] ym_data,
  output reg ym_p1_sync,
  output reg ym_so_sync,
  output reg ym_sh1_sync,
  output reg ym_sh2_sync,
  output reg ym_irq_n_sync,
  output reg [7:0] ym_data_sync
);

reg p1_0, p1_1;
reg so_0, so_1;
reg sh1_0, sh1_1;
reg sh2_0, sh2_1;
reg irq_0, irq_1;
reg [7:0] data0, data1;

always @(posedge clk or posedge rst) begin
  if (rst) begin
    p1_0         <= 1'b0;
    p1_1         <= 1'b0;
    so_0         <= 1'b0;
    so_1         <= 1'b0;
    sh1_0        <= 1'b0;
    sh1_1        <= 1'b0;
    sh2_0        <= 1'b0;
    sh2_1        <= 1'b0;
    irq_0        <= 1'b1;
    irq_1        <= 1'b1;
    data0        <= 8'h00;
    data1        <= 8'h00;
    ym_p1_sync    <= 1'b0;
    ym_so_sync    <= 1'b0;
    ym_sh1_sync   <= 1'b0;
    ym_sh2_sync   <= 1'b0;
    ym_irq_n_sync <= 1'b1;
    ym_data_sync  <= 8'h00;
  end
  else begin
    p1_0  <= ym_p1;
    p1_1  <= p1_0;
    so_0  <= ym_so;
    so_1  <= so_0;
    sh1_0 <= ym_sh1;
    sh1_1 <= sh1_0;
    sh2_0 <= ym_sh2;
    sh2_1 <= sh2_0;
    irq_0 <= ym_irq_n;
    irq_1 <= irq_0;
    data0 <= ym_data;
    data1 <= data0;

    ym_p1_sync    <= p1_1;
    ym_so_sync    <= so_1;
    ym_sh1_sync   <= sh1_1;
    ym_sh2_sync   <= sh2_1;
    ym_irq_n_sync <= irq_1;
    ym_data_sync  <= data1;
  end
end

endmodule