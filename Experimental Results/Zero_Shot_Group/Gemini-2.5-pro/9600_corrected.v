`default_nettype none

module plle2_test
(
input  wire         CLK,
input  wire         RST,
output wire         CLKFBOUT,
input  wire         CLKFBIN,
input  wire         I_PWRDWN,
input  wire         I_CLKINSEL,
output wire         O_LOCKED,
output wire [5:0]   O_CNT
);

parameter FEEDBACK = "INTERNAL";

wire clk100;
reg  clk50 = 1'b0; // Initialize clk50

assign clk100 = CLK;

// Clock divider
always @(posedge clk100 or posedge RST) begin
    if (RST) begin
        clk50 <= 1'b0;
    end else begin
        clk50 <= !clk50;
    end
end

wire clk50_bufg;
BUFG bufgctrl (.I(clk50), .O(clk50_bufg));

wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk;
wire [5:0] gclk;

PLLE2_ADV #
(
.BANDWIDTH          ("HIGH"),       // "HIGH", "LOW", "OPTIMIZED"
.COMPENSATION       ("ZHOLD"),      // "ZHOLD", "BUF_IN", "EXTERNAL", "INTERNAL"
.CLKIN1_PERIOD      (20.0),         // Input clock period in ns
.CLKIN2_PERIOD      (10.0),         // Input clock period in ns
.CLKFBOUT_MULT      (16),           // Multiply value for all CLKOUT
.CLKFBOUT_PHASE     (0.0),          // Phase shift in degrees
.CLKOUT0_DIVIDE     (16),           // Divide value for CLKOUT0
.CLKOUT0_DUTY_CYCLE (0.5),          // Duty cycle for CLKOUT0 (0.001 to 0.999)
.CLKOUT0_PHASE      (45.0),         // Phase shift in degrees for CLKOUT0
.CLKOUT1_DIVIDE     (32),           // Divide value for CLKOUT1
.CLKOUT1_DUTY_CYCLE (0.5),          // Duty cycle for CLKOUT1
.CLKOUT1_PHASE      (90.0),         // Phase shift in degrees for CLKOUT1
.CLKOUT2_DIVIDE     (48),           // Divide value for CLKOUT2
.CLKOUT2_DUTY_CYCLE (0.5),          // Duty cycle for CLKOUT2
.CLKOUT2_PHASE      (135.0),        // Phase shift in degrees for CLKOUT2
.CLKOUT3_DIVIDE     (64),           // Divide value for CLKOUT3
.CLKOUT3_DUTY_CYCLE (0.5),          // Duty cycle for CLKOUT3
.CLKOUT3_PHASE      (-45.0),        // Phase shift in degrees for CLKOUT3
.CLKOUT4_DIVIDE     (80),           // Divide value for CLKOUT4
.CLKOUT4_DUTY_CYCLE (0.5),          // Duty cycle for CLKOUT4
.CLKOUT4_PHASE      (-90.0),        // Phase shift in degrees for CLKOUT4
.CLKOUT5_DIVIDE     (96),           // Divide value for CLKOUT5
.CLKOUT5_DUTY_CYCLE (0.5),          // Duty cycle for CLKOUT5
.CLKOUT5_PHASE      (-135.0),       // Phase shift in degrees for CLKOUT5
.STARTUP_WAIT       ("FALSE")       // "TRUE" or "FALSE"
)
pll
(
.CLKIN1     (clk50_bufg), // Use buffered 50MHz clock
.CLKIN2     (clk100),     // Use direct 100MHz clock
.CLKINSEL   (I_CLKINSEL), // Selects CLKIN1 or CLKIN2
.RST        (RST),        // Asynchronous reset
.PWRDWN     (I_PWRDWN),   // Power down input
.LOCKED     (O_LOCKED),   // PLL lock status output
.CLKFBIN    (clk_fb_i),   // Feedback clock input
.CLKFBOUT   (clk_fb_o),   // Feedback clock output
.CLKOUT0    (clk[0]),     // Clock output 0
.CLKOUT1    (clk[1]),     // Clock output 1
.CLKOUT2    (clk[2]),     // Clock output 2
.CLKOUT3    (clk[3]),     // Clock output 3
.CLKOUT4    (clk[4]),     // Clock output 4
.CLKOUT5    (clk[5])      // Clock output 5
);

// Feedback path selection
generate
    if (FEEDBACK == "INTERNAL") begin : fb_internal
        assign clk_fb_i = clk_fb_o;
    end else if (FEEDBACK == "BUFG") begin : fb_bufg
        BUFG clk_fb_buf (.I(clk_fb_o), .O(clk_fb_i));
    end else if (FEEDBACK == "EXTERNAL") begin : fb_external
        assign CLKFBOUT = clk_fb_o;
        assign clk_fb_i = CLKFBIN;
    end
endgenerate

wire rst_sync = RST || !O_LOCKED; // Combined reset condition (sync reset for counters)

// Generate counters for each output clock
genvar i;
generate
    for (i=0; i<6; i=i+1) begin : counter_gen
        BUFG bufg(.I(clk[i]), .O(gclk[i])); // Buffer each clock output

        reg [23:0] counter = 24'd0; // Counter for each clock, initialized

        // Counter logic, reset synchronously with the respective clock or asynchronously with global reset
        always @(posedge gclk[i] or posedge rst_sync) begin
            if (rst_sync) begin
                counter <= 24'd0;
            end else begin
                counter <= counter + 1;
            end
        end

        // Assign a specific bit of the counter to the output
        assign O_CNT[i] = counter[21];
    end
endgenerate

endmodule
`default_nettype wire // Set default net type back to wire (good practice)