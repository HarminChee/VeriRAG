`timescale 1ns / 1ps
`timescale 1ns / 1ps
module ym_sync(
  input rst_i,  
  input clk,
  input test_i,
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

reg p1_0, so_0, sh1_0, sh2_0, irq_0;
reg [7:0] data0;
wire dft_clk;

assign dft_clk = test_i ? clk : ym_p1;

always @(posedge dft_clk or posedge rst_i ) begin : first_sync
  if( rst_i ) begin
    p1_0  <= 1'b0;
    so_0  <= 1'b0;
    sh1_0 <= 1'b0;
    sh2_0 <= 1'b0;
    irq_0 <= 1'b1;
    data0 <= 8'h0;
  end
  else begin
    p1_0  <= ym_p1;
    so_0  <= ym_so;
    sh1_0 <= ym_sh1;
    sh2_0 <= ym_sh2;
    irq_0 <= ym_irq_n;
    data0 <= ym_data;
  end
end

always @(posedge clk or posedge rst_i ) begin : second_sync
  if( rst_i ) begin
    ym_p1_sync    <= 1'b0;
    ym_so_sync    <= 1'b0;
    ym_sh1_sync   <= 1'b0;
    ym_sh2_sync   <= 1'b0;
    ym_irq_n_sync <= 1'b1;
    ym_data_sync  <= 8'h0;
  end
  else begin
    ym_p1_sync    <= p1_0;
    ym_so_sync    <= so_0;
    ym_sh1_sync   <= sh1_0;
    ym_sh2_sync   <= sh2_0;
    ym_irq_n_sync <= irq_0;
    ym_data_sync  <= data0;
  end
end

endmodule