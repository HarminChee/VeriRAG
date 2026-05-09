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
      if (clk_count == BLINK_COUNT - 1) begin
        blink <= 1;
        clk_count <= 0;
      end else begin
        clk_count <= clk_count + 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      go <= 0;
    end else begin
      if (rdy && !err && !go && blink) begin
        go <= 1;
      end else begin
        go <= 0;
      end
    end
  end

  assign LED[3:0] = res[3:0];
  assign LED[4] = err;

endmodule

module clk_gen (
  input clk_12MHz,
  output clk,
  output ready
);
  parameter F = 16;
  reg [31:0] count = 0;
  reg clk_r = 0;
  reg ready_r = 0;

  always @(posedge clk_12MHz) begin
    if (count == F / 2 - 1) begin
      clk_r <= ~clk_r;
      count <= count + 1'b1;
    end else if (count == F - 1) begin
      clk_r <= ~clk_r;
      count <= 0;
    end else begin
      count <= count + 1'b1;
    end
  end

  always @(posedge clk_12MHz) begin
    if (count == F - 1) begin
      ready_r <= 1'b1;
    end else begin
      ready_r <= 1'b0;
    end
  end

  assign clk = clk_r;
  assign ready = ready_r;

endmodule

module por (
  input clk,
  output rst
);
  reg [31:0] count = 0;
  reg rst_r = 1;

  always @(posedge clk) begin
    if (count < 32'd100000) begin
      count <= count + 1'b1;
      rst_r <= 1'b1;
    end else begin
      rst_r <= 1'b0;
    end
  end

  assign rst = rst_r;

endmodule

module primogen (
  input clk,
  input go,
  input rst,
  output ready,
  output error,
  output [15:0] res
);
  parameter WIDTH_LOG = 4;
  localparam WIDTH = 1 << WIDTH_LOG;
  reg [WIDTH - 1:0] res_r = 0;
  reg ready_r = 0;
  reg error_r = 0;
  reg [31:0] count = 0;

  always @(posedge clk) begin
    if (rst) begin
      res_r <= 0;
      ready_r <= 0;
      error_r <= 0;
      count <= 0;
    end else begin
      if (go) begin
        if (count < WIDTH) begin
          res_r[count] <= 1'b1;
          count <= count + 1'b1;
          ready_r <= 1'b0;
          error_r <= 1'b0;
        end else begin
          ready_r <= 1'b1;
          error_r <= 1'b0;
        end
      end else begin
        ready_r <= 0;
      end
    end
  end

  assign ready = ready_r;
  assign error = error_r;
  assign res = res_r;

endmodule