module reginit(
    input wire clk,
    input wire test_mode, // Added test mode signal
    output wire [3:0] data
);
parameter NP = 23;        
parameter INI = 4'b1100;  
wire clk_pres;
reg [3:0] dout;
wire [3:0] din;
reg sel = 0;

// Clock selection mux for DFT
wire ff_clk;
assign ff_clk = test_mode ? clk : clk_pres;

// Use the muxed clock for the flip-flops
always @(posedge(ff_clk))
  dout <= din;

assign data = dout;
assign din = (sel == 0) ? INI : ~dout;

// Use the muxed clock for the flip-flops
always @(posedge(ff_clk))
  sel <= 1;

// Prescaler instantiation remains the same for functional clock generation
// Note: The prescaler module itself might require DFT modifications internally
// depending on its implementation, but this fix addresses the clocking of dout and sel.
prescaler #(.N(NP))
  PRES (
    .clk_in(clk),
    .clk_out(clk_pres)
  );
endmodule