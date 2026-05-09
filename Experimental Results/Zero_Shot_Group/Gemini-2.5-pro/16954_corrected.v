`default_nettype none

module plle2_test
(
    input  wire         CLK,          // Input clock (e.g., 100MHz)
    input  wire         RST,          // External reset
    input  wire         I_CLKINSEL,   // PLL input clock select (0 for CLKIN1, 1 for CLKIN2)
    output wire         O_LOCKED,     // PLL locked indicator
    output wire [5:0]   O_CNT         // Output counter bits (one per clock output)
);

    // Input clock buffer (optional but good practice)
    wire clk100;
    // Assign input clock directly or through a buffer if needed
    assign clk100 = CLK;

    // Clock divider for CLKIN1 (generate 50MHz from 100MHz)
    reg  clk50 = 1'b0; // Initialize to prevent unknown state
    always @(posedge clk100 or posedge RST) begin
        if (RST) begin
            clk50 <= 1'b0;
        end else begin
            clk50 <= !clk50;
        end
    end

    // Internal PLL signals
    wire clk_fb_o; // PLL feedback output
    wire clk_fb_i; // PLL feedback input
    wire [5:0] clk; // PLL clock outputs

    // Instantiate the PLLE2_ADV primitive
    PLLE2_ADV #
    (
        .BANDWIDTH          ("OPTIMIZED"), // Changed from HIGH for potentially better performance/jitter
        .COMPENSATION       ("BUF_IN"),    // Feedback compensation using BUFG
        .STARTUP_WAIT       ("FALSE"),     // Do not wait for LOCK during configuration
        .DIVCLK_DIVIDE      (1),           // Master division factor
        // Input Clock Information
        .CLKIN1_PERIOD      (20.0),        // Period of CLKIN1 (50MHz)
        .CLKIN2_PERIOD      (10.0),        // Period of CLKIN2 (100MHz)
        // Feedback Configuration
        .CLKFBOUT_MULT      (16),          // VCO multiplication factor (VCO = 100MHz * 16 = 1600MHz if CLKIN2 selected and DIVCLK_DIVIDE=1)
        .CLKFBOUT_PHASE     (0.0),         // Feedback clock phase
        // Output Clock Configuration (based on VCO = 1600MHz)
        .CLKOUT0_DIVIDE     (16),          // CLKOUT0 = 1600 / 16 = 100MHz
        .CLKOUT0_DUTY_CYCLE (0.5),         // Duty cycle for CLKOUT0
        .CLKOUT0_PHASE      (0.0),         // Phase for CLKOUT0 (corrected example, original was 45.0)
        .CLKOUT1_DIVIDE     (32),          // CLKOUT1 = 1600 / 32 = 50MHz
        .CLKOUT1_DUTY_CYCLE (0.5),
        .CLKOUT1_PHASE      (0.0),         // Phase for CLKOUT1 (corrected example, original was 90.0)
        .CLKOUT2_DIVIDE     (48),          // CLKOUT2 = 1600 / 48 = 33.33MHz
        .CLKOUT2_DUTY_CYCLE (0.5),
        .CLKOUT2_PHASE      (0.0),         // Phase for CLKOUT2 (corrected example, original was 135.0)
        .CLKOUT3_DIVIDE     (64),          // CLKOUT3 = 1600 / 64 = 25MHz
        .CLKOUT3_DUTY_CYCLE (0.5),
        .CLKOUT3_PHASE      (0.0),         // Phase for CLKOUT3 (corrected example, original was -45.0)
        .CLKOUT4_DIVIDE     (80),          // CLKOUT4 = 1600 / 80 = 20MHz
        .CLKOUT4_DUTY_CYCLE (0.5),
        .CLKOUT4_PHASE      (0.0),         // Phase for CLKOUT4 (corrected example, original was -90.0)
        .CLKOUT5_DIVIDE     (96),          // CLKOUT5 = 1600 / 96 = 16.67MHz
        .CLKOUT5_DUTY_CYCLE (0.5),
        .CLKOUT5_PHASE      (0.0),         // Phase for CLKOUT5 (corrected example, original was -135.0)
        // Power Saving Parameters
        .REF_JITTER1        (0.01),        // Reference jitter for CLKIN1
        .REF_JITTER2        (0.01)         // Reference jitter for CLKIN2
    )
    pll_inst
    (
        // Output Clocks
        .CLKOUT0    (clk[0]),
        .CLKOUT1    (clk[1]),
        .CLKOUT2    (clk[2]),
        .CLKOUT3    (clk[3]),
        .CLKOUT4    (clk[4]),
        .CLKOUT5    (clk[5]),
        // Input Clocks
        .CLKIN1     (clk50),       // Connect derived 50MHz
        .CLKIN2     (clk100),      // Connect input 100MHz
        .CLKINSEL   (I_CLKINSEL),  // Selects CLKIN1 or CLKIN2
        // Feedback Clocks
        .CLKFBIN    (clk_fb_i),    // Clock feedback input
        .CLKFBOUT   (clk_fb_o),    // Clock feedback output
        // Control Signals
        .PWRDWN     (1'b0),        // Power down signal (active high)
        .RST        (RST),         // Reset signal (active high)
        // Status Signals
        .LOCKED     (O_LOCKED),    // PLL lock status
        // Unused Ports (Tie off if necessary, consult documentation)
        .CLKINSEL   (I_CLKINSEL),
        .DADDR      (7'b0),
        .DCLK       (1'b0),
        .DEN        (1'b0),
        .DI         (16'b0),
        .DO         (),
        .DRDY       (),
        .DWE        (1'b0),
        .PSCLK      (1'b0),
        .PSEN       (1'b0),
        .PSINCDEC   (1'b0),
        .PSDONE     ()
    );

    // Feedback buffer (required for COMPENSATION="BUF_IN")
    BUFG clk_fb_buf_inst (.I(clk_fb_o), .O(clk_fb_i));

    // Combined reset signal (external reset OR PLL not locked)
    wire rst_internal = RST || !O_LOCKED;

    // Generate counters for each clock output to verify activity
    genvar i;
    generate
        for (i = 0; i < 6; i = i + 1) begin : counter_gen_block
            reg [23:0] counter = 24'b0; // Initialize counter

            // Counter logic for each generated clock
            always @(posedge clk[i] or posedge rst_internal) begin
                if (rst_internal) begin
                    counter <= 24'b0;
                end else begin
                    counter <= counter + 1;
                end
            end

            // Assign a high-order bit of the counter to the output bus
            // This bit will toggle periodically, indicating the clock is running
            assign O_CNT[i] = counter[21];
        end
    endgenerate

endmodule

`default_nettype wire // Restore default net type if needed elsewhere