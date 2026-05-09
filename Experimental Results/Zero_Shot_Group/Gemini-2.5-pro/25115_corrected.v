`default_nettype none

module mmcme2_test
(
    input  wire         CLK,        // Assuming 100MHz based on CLKIN2_PERIOD
    input  wire         RST,
    output wire         CLKFBOUT,   // Used only when FEEDBACK = "EXTERNAL"
    input  wire         CLKFBIN,    // Used only when FEEDBACK = "EXTERNAL"
    input  wire         I_PWRDWN,
    input  wire         I_CLKINSEL, // Selects between CLKIN1 (50MHz) and CLKIN2 (100MHz)
    output wire         O_LOCKED,
    output wire [5:0]   O_CNT       // Output counter bits (derived from MMCM outputs)
);

    parameter FEEDBACK = "INTERNAL"; // "INTERNAL", "EXTERNAL", "BUFG", "NONE"
    parameter CLKFBOUT_MULT_F  = 12.000; // VCO = CLKIN * CLKFBOUT_MULT_F / (CLKINSEL ? DIVCLK_DIVIDE : DIVCLK_DIVIDE)
                                        // Assuming CLKIN = 100MHz, DIVCLK=1 => VCO = 1200 MHz
                                        // Assuming CLKIN = 50MHz, DIVCLK=1 => VCO = 600 MHz
    parameter CLKOUT0_DIVIDE_F = 12.000; // CLKOUT0 = VCO / CLKOUT0_DIVIDE_F
                                        // If VCO = 1200MHz => CLKOUT0 = 100 MHz
                                        // If VCO = 600MHz => CLKOUT0 = 50 MHz

    // Generate 100MHz and 50MHz clocks from input CLK (assumed 100MHz)
    wire clk100_unbuf;
    wire clk100;
    wire clk50_unbuf;
    wire clk50;

    // Buffer the input clock (assuming 100MHz)
    BUFG bufg_clk100 (.I(CLK), .O(clk100));

    // Generate 50MHz clock using a toggle flip-flop
    reg clk50_reg = 1'b0;
    always @(posedge clk100 or posedge RST) begin
        if (RST) begin
            clk50_reg <= 1'b0;
        end else begin
            clk50_reg <= ~clk50_reg;
        end
    end
    assign clk50_unbuf = clk50_reg;

    // Buffer the generated 50MHz clock
    BUFG bufg_clk50 (.I(clk50_unbuf), .O(clk50));

    // Internal wires for MMCM feedback and outputs
    wire clk_fb_o; // MMCM feedback output
    wire clk_fb_i; // MMCM feedback input
    wire [5:0] clk; // Raw MMCM clock outputs
    wire [5:0] gclk; // Buffered MMCM clock outputs

    // MMCM Instantiation (single instance)
    MMCME2_ADV #
    (
        .BANDWIDTH          ("HIGH"), // "HIGH", "LOW", "OPTIMIZED"
        .COMPENSATION       ((FEEDBACK == "EXTERNAL") ? "EXTERNAL" : "INTERNAL"), // Set based on FEEDBACK param
        .CLKIN1_PERIOD      (20.0),   // Input clock period for CLKIN1 (50MHz)
        .CLKIN2_PERIOD      (10.0),   // Input clock period for CLKIN2 (100MHz)
        .CLKFBOUT_MULT_F    (CLKFBOUT_MULT_F), // VCO multiplier
        .CLKFBOUT_PHASE     (0.0),    // Phase shift for feedback clock
        .DIVCLK_DIVIDE      (1),      // Division factor for input clock before VCO
        .CLKOUT0_DIVIDE_F   (CLKOUT0_DIVIDE_F), // Division factor for CLKOUT0
        .CLKOUT0_DUTY_CYCLE (0.50),    // Duty cycle for CLKOUT0
        .CLKOUT0_PHASE      (45.0),   // Phase shift for CLKOUT0
        .CLKOUT1_DIVIDE     (32),     // Division factor for CLKOUT1
        .CLKOUT1_DUTY_CYCLE (0.53125),// Duty cycle for CLKOUT1
        .CLKOUT1_PHASE      (90.0),   // Phase shift for CLKOUT1
        .CLKOUT2_DIVIDE     (48),     // Division factor for CLKOUT2
        .CLKOUT2_DUTY_CYCLE (0.50),    // Duty cycle for CLKOUT2
        .CLKOUT2_PHASE      (135.0),  // Phase shift for CLKOUT2
        .CLKOUT3_DIVIDE     (64),     // Division factor for CLKOUT3
        .CLKOUT3_DUTY_CYCLE (0.50),    // Duty cycle for CLKOUT3
        .CLKOUT3_PHASE      (45.0),   // Phase shift for CLKOUT3
        .CLKOUT4_DIVIDE     (80),     // Division factor for CLKOUT4
        .CLKOUT4_DUTY_CYCLE (0.50),    // Duty cycle for CLKOUT4
        .CLKOUT4_PHASE      (90.0),   // Phase shift for CLKOUT4
        .CLKOUT5_DIVIDE     (96),     // Division factor for CLKOUT5
        .CLKOUT5_DUTY_CYCLE (0.50),    // Duty cycle for CLKOUT5
        .CLKOUT5_PHASE      (135.0),  // Phase shift for CLKOUT5
        .CLKOUT6_DIVIDE     (1),      // Division factor for CLKOUT6 (not used)
        .CLKOUT6_DUTY_CYCLE (0.50),    // Duty cycle for CLKOUT6
        .CLKOUT6_PHASE      (0.0),    // Phase shift for CLKOUT6
        .STARTUP_WAIT       ("FALSE") // "TRUE" or "FALSE"
    )
    mmcm_inst
    (
        // Clock Inputs
        .CLKIN1     (clk50),        // 50MHz clock input
        .CLKIN2     (clk100),       // 100MHz clock input
        .CLKINSEL   (I_CLKINSEL),   // Selects CLKIN1 (0) or CLKIN2 (1)
        // Control Ports
        .RST        (RST),          // Asynchronous reset
        .PWRDWN     (I_PWRDWN),     // Power down input
        // Status Ports
        .LOCKED     (O_LOCKED),     // MMCM lock status output
        // Feedback Ports
        .CLKFBIN    (clk_fb_i),     // Feedback clock input
        .CLKFBOUT   (clk_fb_o),     // Feedback clock output (pre-buffer)
        // Clock Outputs
        .CLKOUT0    (clk[0]),
        .CLKOUT1    (clk[1]),
        .CLKOUT2    (clk[2]),
        .CLKOUT3    (clk[3]),
        .CLKOUT4    (clk[4]),
        .CLKOUT5    (clk[5]),
        .CLKOUT6    (),             // Unused output
        // Dynamic Reconfiguration Ports (unused)
        .DADDR      (7'b0),
        .DCLK       (1'b0),
        .DEN        (1'b0),
        .DI         (16'b0),
        .DO         (),
        .DRDY       (),
        .DWE        (1'b0),
        // Phase Shift Ports (unused)
        .PSCLK      (1'b0),
        .PSEN       (1'b0),
        .PSINCDEC   (1'b0),
        .PSDONE     ()
    );

    // Configure Feedback Path based on FEEDBACK parameter
    generate
        if (FEEDBACK == "INTERNAL" || FEEDBACK == "NONE") begin : gen_fb_internal
            // Connect feedback output directly to input (internal MMCM path)
            assign clk_fb_i = clk_fb_o;
        end else if (FEEDBACK == "BUFG") begin : gen_fb_bufg
            // Use a BUFG in the feedback path
            BUFG clk_fb_buf (.I(clk_fb_o), .O(clk_fb_i));
        end else if (FEEDBACK == "EXTERNAL") begin : gen_fb_external
            // Route feedback through top-level ports
            assign CLKFBOUT = clk_fb_o; // Output feedback clock
            assign clk_fb_i = CLKFBIN; // Input feedback clock
        end
        // Add an else case here to catch invalid FEEDBACK parameter values if desired
        // else begin : gen_fb_invalid
        //    // Handle invalid parameter - e.g., assertion or default behavior
        // end
    endgenerate

    // Define reset signal for counters (active during RST or until MMCM locks)
    wire rst_counters = RST || !O_LOCKED;

    // Generate BUFGs and counters for each MMCM output clock
    genvar i;
    generate
        for (i=0; i<6; i=i+1) begin : gen_output_logic
            // Buffer the MMCM clock output
            BUFG bufg_clkout (.I(clk[i]), .O(gclk[i]));

            // Counter logic for each output clock
            reg [23:0] counter = 24'b0;
            always @(posedge gclk[i] or posedge rst_counters) begin
                if (rst_counters) begin
                    counter <= 24'b0;
                end else begin
                    counter <= counter + 1;
                end
            end

            // Assign a specific bit of the counter to the output port
            // This creates a divided-down toggle signal
            assign O_CNT[i] = counter[21]; // Example: Use bit 21
        end
    endgenerate

endmodule
`default_nettype wire // Restore default net type if needed elsewhere