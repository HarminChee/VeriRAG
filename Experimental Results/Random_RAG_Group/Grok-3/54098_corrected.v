module speaker (
    // Clocks
    input clk,
    input rst,
    input test_i,

    // Wishbone slave interface
    input      [7:0] wb_dat_i,
    output reg [7:0] wb_dat_o,
    input            wb_we_i,
    input            wb_stb_i,
    input            wb_cyc_i,
    output           wb_ack_o,

    // Clocks
    input clk_100M,
    input clk_25M,
    input timer2,

    // I2C pad signals
    output i2c_sclk_,
    inout  i2c_sdat_,

    // Audio codec pad signals
    input  aud_adcdat_,
    input  aud_daclrck_,
    output aud_dacdat_,
    input  aud_bclk_
  );

  // Net declaration
  wire [15:0] audio_r;
  wire [15:0] audio_l;
  wire        write;
  wire        spk;
  wire        dft_clk_100M;
  wire        dft_clk_25M;
  wire        dft_clk;

  // DFT signals
  assign dft_clk_100M = test_i ? clk : clk_100M;
  assign dft_clk_25M  = test_i ? clk : clk_25M;
  assign dft_clk      = test_i ? clk : clk;

  // Module instances
  speaker_iface iface (
    .clk_i         (dft_clk_100M),
    .rst_i         (rst),
    .datal_i       (audio_l),
    .datar_i       (audio_r),
    .datal_o       (),
    .datar_o       (),
    .ready_o       (),
    .aud_bclk_i    (aud_bclk_),
    .aud_daclrck_i (aud_daclrck_),
    .aud_dacdat_o  (aud_dacdat_),
    .aud_adcdat_i  (aud_adcdat_)
  );

  speaker_i2c_av_config i2c_av_config (
    // Host Side
    .clk_i (dft_clk_25M),
    .rst_i (rst),

    // I2C Side
    .i2c_sclk (i2c_sclk_),
    .i2c_sdat (i2c_sdat_)
  );

  // Combinatorial logic
  // System speaker
  assign spk = timer2 & wb_dat_o[1];

  // System speaker audio output
  assign audio_l = {spk, 15'h4000};
  assign audio_r = {spk, 15'h4000};

  // Wishbone signals
  assign wb_ack_o = wb_stb_i && wb_cyc_i;
  assign write    = wb_stb_i && wb_cyc_i && wb_we_i;

  // Sequential logic
  always @(posedge dft_clk or posedge rst)
    wb_dat_o <= rst ? 8'h0 : (write ? wb_dat_i : wb_dat_o);

endmodule