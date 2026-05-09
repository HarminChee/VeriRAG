Here is the modified Verilog code addressing the CLKNPI issue:


module blink (
  input clk_12MHz,
  input rst_n,
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

  assign rst = !rst_n;

  localparam F = 16;
  localparam BLINK_COUNT = F * 1000000 * 5;  

  always @(posedge clk_12MHz or posedge rst) begin
    if (rst) begin
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

  always @(posedge clk_12MHz or posedge rst) begin
    if (rst) begin
      go <= 0;
    end else begin
      go <= 0;
      if (rdy && !err && !go && blink) begin
        go <= 1;
      end
    end
  end

  primogen #(.WIDTH_LOG(WLOG)) pg(
    .clk(clk_12MHz),
    .go(go),
    .rst(rst),
    .ready(rdy),
    .error(err),
    .res(res)
  );

  assign LED[3:0] = res[3:0];
  assign LED[4] = err;
endmodule