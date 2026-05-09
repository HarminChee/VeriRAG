module wb_sdio_device (
  input               test_i,
  input               clk,
  input               rst_n,
  input               i_wbs_we,
  input               i_wbs_cyc,
  input       [3:0]   i_wbs_sel,
  input       [31:0]  i_wbs_dat,
  input               i_wbs_stb,
  output  reg         o_wbs_ack,
  output  reg [31:0]  o_wbs_dat,
  input       [31:0]  i_wbs_adr,
  output              o_wbs_int,
  input               i_phy_sd_clk,
  inout               io_phy_sd_cmd,
  inout       [3:0]   io_phy_sd_data
);

// ... existing code ...

wire dft_clk;
assign dft_clk = test_i ? i_phy_sd_clk : sd_clk;

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    clock_count <= 0;
  end
  else begin
    clock_count <= clock_count + 1;
  end
end

// ... existing code ...

wire dft_rst_n;
assign dft_rst_n = test_i ? rst_n : (rst_n && !sdio_rst && pll_locked);

sdio_memory_function #(
  .FUNC_NUM             (1                    ),
  .MEM_EXP              (`BUFFER_EXP          )
)memory_function(
  .clk                  (i_phy_sd_clk         ),
  .sdio_clk             (dft_clk              ),
  .rst_n                (rst_n                ),
  
// ... existing code ...

endmodule