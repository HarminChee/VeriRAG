module blink (
  input clk_12MHz, // Primary input clock
  output [4:0] LED);

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
  // Removed internal clk and clk_rdy signals and clk_gen instance

  // POR generation, clocked by the primary input clock
  // Assuming 'por' module definition exists elsewhere and accepts 'clk' port
  por por_inst(.clk(clk_12MHz), .rst(por_rst));

  // Reset logic: Use POR reset directly. Assumes clk_12MHz is stable when por_rst deasserts.
  assign rst = por_rst;

  // Primogen instance, clocked by the primary input clock
  // Assuming 'primogen' module definition exists elsewhere and accepts 'clk' port
  primogen #(.WIDTH_LOG(WLOG)) pg(
    .clk(clk_12MHz),
    .go(go),
    .rst(rst),
    .ready(rdy),
    .error(err),
    .res(res));

  // Adjust BLINK_COUNT based on the primary clock frequency (12MHz) for a 5-second period
  localparam BLINK_COUNT = 12000000 * 5; // 12 MHz * 5 seconds

  // Blink logic clocked by the primary input clock
  always @(posedge clk_12MHz) begin
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

  // Go signal logic clocked by the primary input clock
  always @(posedge clk_12MHz) begin
    if (rst) begin
      go <= 0;
    end else begin
      // Default assignment moved inside the non-reset condition for clarity
      go <= 0;
      if (rdy && !err && !go && blink) begin
        go <= 1;
      end
    end
  end

  assign LED[3:0] = res[3:0];
  assign LED[4] = err;

endmodule

// Note: Assumes 'por' and 'primogen' module definitions exist and are compatible
// with being clocked by clk_12MHz. The clk_gen module is no longer used.