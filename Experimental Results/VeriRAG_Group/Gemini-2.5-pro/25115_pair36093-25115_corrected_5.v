module mmcme2_test
(
input  wire         CLK,
input  wire         RST,
output wire         CLKFBOUT, // Only used if FEEDBACK = "EXTERNAL"
input  wire         CLKFBIN,  // Only used if FEEDBACK = "EXTERNAL"
input  wire         I_PWRDWN,
input  wire         I_CLKINSEL,
output wire         O_LOCKED,
output wire [5:0]   O_CNT,
input  wire         test_i // Added DFT control input
);

parameter FEEDBACK = "INTERNAL"; // Example: "INTERNAL", "EXTERNAL", "BUFG", "NONE"
parameter CLKFBOUT_MULT_F  = 12.000;
parameter CLKOUT0_DIVIDE_F = 12.000;

// DFT Signals
wire dft_clkin1;
wire dft_clkin2;
wire dft_rst;
wire dft_pwrdwn;
wire dft_clkinsel;

// Input clock buffering
wire clk100;
BUFG bufg_clk (.I(CLK), .O(clk100));

// Internal clock generation (for CLKIN1 of MMCM)
reg clk50_ce = 1'b0; // Initialize register
always @(posedge clk100) begin
    clk50_ce <= !clk50_ce;
end

wire clk50;
BUFGCE bufgce_clk50 (.I(clk100), .CE(clk50_ce), .O(clk50));

// DFT Muxing for MMCM inputs
assign dft_clkin1   = test_i ? CLK    : clk50;      // Use primary CLK as test clock
assign dft_clkin2   = test_i ? CLK    : clk100;     // Use primary CLK as test clock
assign dft_rst      = test_i ? RST    : RST;        // Use primary RST as test reset
assign dft_pwrdwn   = test_i ? 1'b0   : I_PWRDWN;   // Disable powerdown during test
assign dft_clkinsel = test_i ? 1'b0   : I_CLKINSEL; // Select CLKIN1 during test (arbitrary choice, ensure MMCM config matches)

// MMCM signals
wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk_out; // MMCM outputs before buffering
wire [5:0] gclk;    // MMCM outputs after buffering

// Default assignment for CLKFBOUT (overridden below if FEEDBACK = "EXTERNAL")
assign CLKFBOUT = 1'b0;

// MMCM Instantiation using generate block based on FEEDBACK
generate
    // Common parameters for MMCM
    localparam real C_CLKIN1_PERIOD      = 20.0; // Example period for clk50 (50MHz) - Derived from clk100/2
    localparam real C_CLKIN2_PERIOD      = 10.0; // Example period for clk100 (100MHz)
    localparam real C_TEST_CLK_PERIOD    = 10.0; // Assuming test clock is same as CLK (100MHz)

    if (FEEDBACK == "NONE") begin : mmcm_gen_none
        MMCME2_ADV #(
            .BANDWIDTH          ("HIGH"),
            .CLKIN1_PERIOD      (test_i ? C_TEST_CLK_PERIOD : C_CLKIN1_PERIOD), // Adjust period based on test mode
            .CLKIN2_PERIOD      (test_i ? C_TEST_CLK_PERIOD : C_CLKIN2_PERIOD), // Adjust period based on test mode
            .CLKFBOUT_MULT_F    (CLKFBOUT_MULT_F),
            .CLKFBOUT_PHASE     (0.0),
            .CLKOUT0_DIVIDE_F   (CLKOUT0_DIVIDE_F),
            .CLKOUT0_DUTY_CYCLE (0.5),
            .CLKOUT0_PHASE      (45.0),
            .CLKOUT1_DIVIDE     (32),
            .CLKOUT1_DUTY_CYCLE (0.5),
            .CLKOUT1_PHASE      (90.0),
            .CLKOUT2_DIVIDE     (48),
            .CLKOUT2_DUTY_CYCLE (0.5),
            .CLKOUT2_PHASE      (135.0),
            .CLKOUT3_DIVIDE     (64),
            .CLKOUT3_DUTY_CYCLE (0.5),
            .CLKOUT3_PHASE      (45.0),
            .CLKOUT4_DIVIDE     (80),
            .CLKOUT4_DUTY_CYCLE (0.5),
            .CLKOUT4_PHASE      (90.0),
            .CLKOUT5_DIVIDE     (96),
            .CLKOUT5_DUTY_CYCLE (0.5),
            .CLKOUT5_PHASE      (135.0),
            .STARTUP_WAIT       ("FALSE"),
            .COMPENSATION       ("INTERNAL") // Assuming INTERNAL compensation for NONE feedback
        )
        mmcm_inst_none (
            .CLKIN1     (dft_clkin1),
            .CLKIN2     (dft_clkin2),
            .CLKINSEL   (dft_clkinsel),
            .RST        (dft_rst),
            .PWRDWN     (dft_pwrdwn),
            .LOCKED     (O_LOCKED),
            .CLKFBIN    (clk_fb_i), // Connected via fb_none generate block
            .CLKFBOUT   (clk_fb_o),
            .CLKOUT0    (clk_out[0]),
            .CLKOUT1    (clk_out[1]),
            .CLKOUT2    (clk_out[2]),
            .CLKOUT3    (clk_out[3]),
            .CLKOUT4    (clk_out[4]),
            .CLKOUT5    (clk_out[5])
        );
    end else begin : mmcm_gen_feedback // Handles "INTERNAL", "EXTERNAL", "BUFG"
        MMCME2_ADV #(
            .BANDWIDTH          ("HIGH"),
            .COMPENSATION       ((FEEDBACK == "EXTERNAL") ? "EXTERNAL" : "INTERNAL"), // BUFG uses INTERNAL comp
            .CLKIN1_PERIOD      (test_i ? C_TEST_CLK_PERIOD : C_CLKIN1_PERIOD), // Adjust period based on test mode
            .CLKIN2_PERIOD      (test_i ? C_TEST_CLK_PERIOD : C_CLKIN2_PERIOD), // Adjust period based on test mode
            .CLKFBOUT_MULT_F    (CLKFBOUT_MULT_F),
            .CLKFBOUT_PHASE     (0.0),
            .CLKOUT0_DIVIDE_F   (CLKOUT0_DIVIDE_F),
            .CLKOUT0_DUTY_CYCLE (0.5),
            .CLKOUT0_PHASE      (45.0),
            .CLKOUT1_DIVIDE     (32),
            .CLKOUT1_DUTY_CYCLE (0.5),
            .CLKOUT1_PHASE      (90.0),
            .CLKOUT2_DIVIDE     (48),
            .CLKOUT2_DUTY_CYCLE (0.5),
            .CLKOUT2_PHASE      (135.0),
            .CLKOUT3_DIVIDE     (64),
            .CLKOUT3_DUTY_CYCLE (0.5),
            .CLKOUT3_PHASE      (45.0),
            .CLKOUT4_DIVIDE     (80),
            .CLKOUT4_DUTY_CYCLE (0.5),
            .CLKOUT4_PHASE      (90.0),
            .CLKOUT5_DIVIDE     (96),
            .CLKOUT5_DUTY_CYCLE (0.5),
            .CLKOUT5_PHASE      (135.0),
            .STARTUP_WAIT       ("FALSE")
        )
        mmcm_inst_fb (
            .CLKIN1     (dft_clkin1),
            .CLKIN2     (dft_clkin2),
            .CLKINSEL   (dft_clkinsel),
            .RST        (dft_rst),
            .PWRDWN     (dft_pwrdwn),
            .LOCKED     (O_LOCKED),
            .CLKFBIN    (clk_fb_i), // Connected based on feedback generate block
            .CLKFBOUT   (clk_fb_o),
            .CLKOUT0    (clk_out[0]),
            .CLKOUT1    (clk_out[1]),
            .CLKOUT2    (clk_out[2]),
            .CLKOUT3    (clk_out[3]),
            .CLKOUT4    (clk_out[4]),
            .CLKOUT5    (clk_out[5])
        );
    end
endgenerate

// Feedback Path Logic using generate block
generate
    if (FEEDBACK == "INTERNAL") begin : fb_internal
        assign clk_fb_i = clk_fb_o;
    end else if (FEEDBACK == "BUFG") begin : fb_bufg
        BUFG clk_fb_buf (.I(clk_fb_o), .O(clk_fb_i));
    end else if (FEEDBACK == "EXTERNAL") begin : fb_external
        assign clk_fb_i = CLKFBIN;
        assign CLKFBOUT = clk_fb_o; // Drive output port
    end else if (FEEDBACK == "NONE") begin : fb_none
        assign clk_fb_i = 1'b0; // Tie feedback input low
    end
endgenerate

// Output Buffering (Important for driving loads)
genvar i;
generate
    for (i = 0; i < 6; i = i + 1) begin : out_bufg
        BUFG bufg_out (.I(clk_out[i]), .O(gclk[i]));
    end
endgenerate

// Connect buffered outputs to module outputs
assign O_CNT = gclk;

endmodule