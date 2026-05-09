module jpeg_encoder #(
  parameter coef_width = 11,
  parameter di_width   = 8
)(
  input  wire                  clk,
  input  wire                  ena,
  input  wire                  dstrb,
  input  wire [di_width-1:0]   din,
  input  wire [7:0]            qnt_val,
  output wire [5:0]            qnt_cnt,
  output wire [3:0]            size,
  output wire [3:0]            rlen,
  output wire [11:0]           amp,
  output wire                  douten,
  input  wire                  SE,
  input  wire                  SI,
  output wire                  SO
);

  wire        rst         = 1'b1;
  wire        fdct_doe;
  wire [11:0] fdct_dout;
  reg  [11:0] dfdct_dout;
  wire [10:0] qnr_dout;
  wire        qnr_doe;
  reg         dqnr_doe;

  assign SO = SI;

  fdct #(coef_width, di_width, 12)
  fdct_zigzag(
    .clk    (clk),
    .ena    (ena),
    .rst    (rst),
    .dstrb  (dstrb),
    .din    (din),
    .dout   (fdct_dout),
    .douten (fdct_doe)
  );

  always @(posedge clk) begin
    if (ena)
      dfdct_dout <= #1 fdct_dout;
  end

  jpeg_qnr
  qnr(
    .clk     (clk),
    .ena     (ena),
    .rst     (rst),
    .dstrb   (fdct_doe),
    .din     (dfdct_dout),
    .qnt_val (qnt_val),
    .qnt_cnt (qnt_cnt),
    .dout    (qnr_dout),
    .douten  (qnr_doe)
  );

  always @(posedge clk) begin
    if (ena)
      dqnr_doe <= #1 qnr_doe;
  end

  wire [11:0] dc_diff_dout = {qnr_dout[10], qnr_dout};
  wire        dc_diff_doe  = dqnr_doe;

  jpeg_rle
  rle(
    .clk    (clk),
    .ena    (ena),
    .rst    (rst),
    .dstrb  (dc_diff_doe),
    .din    (dc_diff_dout),
    .size   (size),
    .rlen   (rlen),
    .amp    (amp),
    .douten (douten),
    .bstart ()
  );

endmodule