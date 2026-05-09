module blink (
  input clk_12MHz,
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
  wire clk;
  wire clk_rdy;
  localparam F = 16;

  clk_gen #(.F(F)) clk_gen_inst (
    .clk_12MHz(clk_12MHz),
    .clk(clk),
    .ready(clk_rdy)
  );

  por por_inst (
    .clk(clk),
    .rst(por_rst)
  );

  assign rst = por_rst || !clk_rdy;

  primogen #(.WIDTH_LOG(WLOG)) pg (
    .clk(clk),
    .go(go),
    .rst(rst),
    .ready(rdy),
    .error(err),
    .res(res)
  );

  localparam BLINK_COUNT = F * 1000000 * 5;

  always @(posedge clk) begin
    if (rst) begin
      blink <= 0;
      clk_count <= 0;
    end else begin
      if (clk_count == BLINK_COUNT) begin
        blink <= 1;
        clk_count <= 0;
      end else begin
        blink <= 0;
        clk_count <= clk_count + 1;
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
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