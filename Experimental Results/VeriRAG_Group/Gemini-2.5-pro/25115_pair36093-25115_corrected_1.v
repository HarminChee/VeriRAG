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

// Input clock buffering
wire clk100;
BUFG bufg_clk (.I(CLK), .O(clk100)); // Use unique instance names

// Internal clock generation (for CLKIN1 of MMCM)
reg clk50_ce = 1'b0; // Initialize register
always @(posedge clk100) begin
    clk50_ce <= !clk50_ce;
end

wire clk50;
// BUFGCE uses CLK as input, gated by clk50_ce which is derived from clk100
BUFGCE bufgce_clk50 (.I(CLK), .CE(clk50_ce), .O(clk50));

// MMCM signals
wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk_out; // MMCM outputs before buffering
wire [5:0] gclk;    // MMCM outputs after buffering

// MMCM Instantiation using generate block based on FEEDBACK
generate
    // Common parameters for MMCM
    localparam real C_CLKIN1_PERIOD      = 20.0; // Example period for clk50 (50MHz)
    localparam real C_CLKIN2_PERIOD      = 10.0; // Example period for clk100 (100MHz)
    localparam real C_CLKFBOUT_MULT_F    = CLKFBOUT_MULT_F;
    localparam real C_CLKOUT0_DIVIDE_F   = CLKOUT0_DIVIDE_F;

    if (FEEDBACK == "NONE") begin : mmcm_gen_none
        MMCME2_ADV #(
            .BANDWIDTH          ("HIGH"),
            .CLKIN1_PERIOD      (C_CLKIN1_PERIOD),
            .CLKIN2_PERIOD      (C_CLKIN2_PERIOD),
            .CLKFBOUT_MULT_F    (C_CLKFBOUT_MULT_F),
            .CLKFBOUT_PHASE     (0.0),
            .CLKOUT0_DIVIDE_F   (C_CLKOUT0_DIVIDE_F),
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
        mmcm_inst (
            .CLKIN1     (clk50),
            .CLKIN2     (clk100),
            .CLKINSEL   (I_CLKINSEL),
            .RST        (RST),
            .PWRDWN     (I_PWRDWN),
            .LOCKED     (O_LOCKED),
            .CLKFBIN    (clk_fb_i),
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
            .COMPENSATION       ((FEEDBACK == "EXTERNAL") ? "EXTERNAL" : "INTERNAL"),
            .CLKIN1_PERIOD      (C_CLKIN1_PERIOD),
            .CLKIN2_PERIOD      (C_CLKIN2_PERIOD),
            .CLKFBOUT_MULT_F    (C_CLKFBOUT_MULT_F),
            .CLKFBOUT_PHASE     (0.0),
            .CLKOUT0_DIVIDE_F   (C_CLKOUT0_DIVIDE_F),
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
        mmcm_inst (
            .CLKIN1     (clk50),
            .CLKIN2     (clk100),
            .CLKINSEL   (I_CLKINSEL),
            .RST        (RST),
            .PWRDWN     (I_PWRDWN),
            .LOCKED     (O_LOCKED),
            .CLKFBIN    (clk_fb_i),
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
        assign CLKFBOUT = clk_fb_o;
        assign clk_fb_i = CLKFBIN;
    end else if (FEEDBACK == "NONE") begin : fb_none
        // For FEEDBACK=NONE, CLKFBIN is typically unused by MMCM. Tie low.
        assign clk_fb_i = 1'b0;
        // CLKFBOUT might be left unconnected or tied off depending on MMCM model behavior.
    end
endgenerate


// Internal Reset Logic (Functional Mode)
wire rst_internal = RST || !O_LOCKED; // Original internal reset logic

// DFT Reset Logic (Selectable Reset Source)
wire dft_rst;
assign dft_rst = test_i ? RST : rst_internal; // Multiplex reset based on test_i

// Counter Generation with DFT Clock/Reset Muxing
genvar i;
generate
    for (i=0; i<6; i=i+1) begin : counter_gen
        // Buffer the MMCM clock output
        BUFG bufg_clk_out (.I(clk_out[i]), .O