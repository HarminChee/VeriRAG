module bench (
  input clk_12MHz,
  input test_i,
  input rst_i,
  output reg [4:0] LED);
  localparam WLOG = 4;
  localparam W = 1 << WLOG;
  localparam HI = W - 1;
  wire rdy, err;
  wire [HI:0] res;
  reg go;
  reg [HI:0] prime;
  reg [15:0] count;
  wire rst;
  wire por_rst;
  wire clk_rdy;
  wire clk;
  wire dft_clk;
  localparam F = 16;
  clk_gen #(.F(F)) clk_gen_inst (.clk_12MHz(clk_12MHz), .clk(clk), .ready(clk_rdy));
  por por_inst(.clk(clk), .rst_i(rst_i), .rst(por_rst));
  assign dft_clk = test_i ? clk_12MHz : clk;
  assign rst = rst_i || por_rst || !clk_rdy;
  primogen #(.WIDTH_LOG(WLOG)) pg(
    .clk(dft_clk),
    .go(go),
    .rst(rst),
    .ready(rdy),
    .error(err),
    .res(res));
  always @(posedge dft_clk) begin
    if (rst) begin
      go <= 0;
      prime <= 0;
      count <= 0;
    end else begin
      go <= 0;
      if (rdy && !err && !go) begin
        go <= 1;
        prime <= res;
        count <= count + 1'd1;
      end
    end
  end
  always @(posedge dft_clk) begin
    if (rst) begin
      LED <= 5'd0;
    end else begin
      LED[4] <= err;
      if (!err && res > {LED[3:0], {W-4{1'd1}}}) begin
        LED[3:0] <= LED[3:0] + 1'd1;  
      end
    end
  end
endmodule