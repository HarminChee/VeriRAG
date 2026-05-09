module blink (
  input clk_12MHz,
  input test_i,
  output [4:0] LED
);
  localparam WLOG = 4;
  localparam W = 1 << WLOG;
  localparam HI = W - 1;
  wire rdy, err;
  wire [HI:0] res;
  reg go;
  reg [31:0] clk_count;
  reg blink;
  wire rst;
  wire por_rst;
  wire gen_clk;
  wire clk_rdy;
  localparam F = 16;

  clk_gen #(.F(F)) u_clk_gen (
    .clk_12MHz(clk_12MHz),
    .clk(gen_clk),
    .ready(clk_rdy)
  );

  por u_por (
    .clk(dft_clk),
    .rst(por_rst)
  );

  assign rst = por_rst || !clk_rdy;
  wire dft_clk;
  wire dft_rst;

  assign dft_clk = test_i ? clk_12MHz : gen_clk;
  assign dft_rst = test_i ? 1'b0 : rst;

  primogen #(.WIDTH_LOG(WLOG)) pg (
    .clk(dft_clk),
    .go(go),
    .rst(dft_rst),
    .ready(rdy),
    .error(err),
    .res(res)
  );

  localparam BLINK_COUNT = F * 1000000 * 5;
  always @(posedge dft_clk) begin
    if (dft_rst) begin
      blink <= 0;
      clk_count <= 0;
    end else begin
      if (clk_count == BLINK_COUNT) begin
        blink <= 1;
        clk_count <= 0;
      end else begin
        blink <= 0;
        clk_count <= clk_count + 1'd1;
      end
    end
  end

  always @(posedge dft_clk) begin
    if (dft_rst) begin
      go <= 0;
    end else begin
      go <= 0;
      if (rdy && !err && !go && blink) begin
        go <= 1;
      end
    end
  end

  assign LED[3:0] = res[3:0];
  assign LED[4] = err;
endmodule