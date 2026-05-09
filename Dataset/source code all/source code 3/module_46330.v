`define use_dtr 1       
`define use_dtr 1       
module          top
(
input           clock_50,       
`ifdef use_dtr
input           dtr,            
`else
input           inp_resn,       
`endif
inout   [31:0]  pin,            
output  [7:0]   ledg,           
output          tx_led,         
output          rx_led,         
output          p16_led,        
output          p17_led         
);
reg         nres;
wire [7:0]  cfg;
wire [31:0] pin_in, pin_out, pin_dir;
wire        clkfb, clock_160, clk;
reg [23:0]  reset_cnt;
reg         reset_to;
wire        res;
reg [7:0]   cfgx;
reg [12:0]  divide;
wire        clk_pll;
wire        clk_cog;
`ifdef use_pll
PLL_BASE # (
    .CLKIN_PERIOD(20),
    .CLKFBOUT_MULT(16),
    .CLKOUT0_DIVIDE(5),
    .COMPENSATION("INTERNAL")
  ) PLL (
    .CLKFBOUT(clkfb),
    .CLKOUT0(clock_160),
    .CLKOUT1(),
    .CLKOUT2(),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .LOCKED(),
    .CLKFBIN(clkfb),
    .CLKIN(clock_50),
    .RST(1'b0)
  );
`else
DCM_SP DCM_SP_(
    .CLKIN(clock_50),
    .CLKFB(clkfb),
    .RST(1'b0),
    .PSEN(1'b0),
    .PSINCDEC(1'b0),
    .PSCLK(1'b0),
    .DSSEN(1'b0),
    .CLK0(clkfb),
    .CLK90(),
    .CLK180(),
    .CLK270(),
    .CLKDV(),
    .CLK2X(),
    .CLK2X180(),
    .CLKFX(clock_160),
    .CLKFX180(),
    .STATUS(),
    .LOCKED(),
    .PSDONE());
  defparam DCM_SP_.CLKIN_DIVIDE_BY_2 = "FALSE";
  defparam DCM_SP_.CLKIN_PERIOD = 20;
  defparam DCM_SP_.CLK_FEEDBACK = "1X";
  defparam DCM_SP_.CLKFX_DIVIDE = 5;
  defparam DCM_SP_.CLKFX_MULTIPLY = 16;
`endif
BUFG BUFG_clk(.I(clock_160), .O(clk));
assign clk_pll = ((cfgx[6:5] == 2'b11) && (cfgx[2:0] == 3'b111)) ? clock_160 : divide[11];
assign clk_cog = divide[12];
`ifdef use_dtr
always @ (posedge clk or negedge dtr)
    if (!dtr) begin
        reset_cnt <= 24'd0;
        reset_to <= 1'b0;
    end else begin
        reset_cnt <= reset_to ? reset_cnt : reset_cnt + 1;
        reset_to <= (reset_cnt == 24'hfffff) ? 1'b1 : reset_to;
    end
wire inp_resn = ~(dtr & ~reset_to);
`endif
assign res = ~inp_resn;
always @ (posedge clk)
    cfgx <= cfg;
always @ (posedge clk)
    divide <= divide + 
        {   (cfgx[6:5] == 2'b11 && cfgx[2:0] == 3'b111) || res,
            cfgx[6:5] == 2'b11 && cfgx[2:0] == 3'b110 && !res,
            cfgx[6:5] == 2'b11 && cfgx[2:0] == 3'b101 && !res,
            ((cfgx[6:5] == 2'b11 && cfgx[2:0] == 3'b100) || cfgx[2:0] == 3'b000) && !res,
            ((cfgx[6:5] == 2'b11 && cfgx[2:0] == 3'b011) || (cfgx[5] == 1'b1 && cfgx[2:0] == 3'b010)) && !res,
            7'b0,
            cfgx[2:0] == 3'b001 && !res
        };
always @ (posedge clk_cog)
    nres <= inp_resn & !cfgx[7];
dig core (  .nres       (nres),
            .cfg        (cfg),
            .clk_cog    (clk_cog),
            .clk_pll    (clk_pll),
            .pin_in     (pin_in),
            .pin_out    (pin_out),
            .pin_dir    (pin_dir),
            .cog_led    (ledg) );
genvar i;
generate
    for (i=0; i<32; i=i+1)
    begin : iogen
        IOBUF io_ (.IO(pin[i]), .O(pin_in[i]), .I(pin_out[i]), .T(~pin_dir[i]));
    end
endgenerate
assign tx_led = pin_in[30];
assign rx_led = pin_in[31];
assign p16_led = pin_in[16];
assign p17_led = pin_in[17];
endmodule
