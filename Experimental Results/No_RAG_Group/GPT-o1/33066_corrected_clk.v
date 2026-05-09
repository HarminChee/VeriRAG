module bench (
  input clk_12MHz,
  output reg [4:0] LED
);
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
  localparam F = 16;

  clk_gen #(.F(F)) clk_gen_inst (
    .clk_12MHz(clk_12MHz),
    .clk(),
    .ready(clk_rdy)
  );

  por por_inst(
    .clk(clk_12MHz),
    .rst(por_rst)
  );

  assign rst = por_rst || !clk_rdy;

  primogen #(.WIDTH_LOG(WLOG)) pg(
    .clk(clk_12MHz),
    .go(go),
    .rst(rst),
    .ready(rdy),
    .error(err),
    .res(res)
  );

  always @(posedge clk_12MHz) begin
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

  always @(posedge clk_12MHz) begin
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