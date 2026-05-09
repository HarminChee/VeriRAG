//-----------------------------------------------------------------------------
// Dummy module definitions for synthesis/simulation if originals are missing
//-----------------------------------------------------------------------------
//`ifndef VGAFREQUENCY_MODULE_DEFINED
//`define VGAFREQUENCY_MODULE_DEFINED
module VGAFrequency (
    input wire inclk0,
    input wire areset,
    output wire c0
);
    // Simplified behavior: Pass through clock (adjust frequency in reality)
    // In real hardware, this uses a PLL/MMCM primitive
    assign c0 = inclk0;
endmodule
//`endif

//`ifndef VGACONTROLLER_MODULE_DEFINED
//`define VGACONTROLLER_MODULE_DEFINED
module VGAController (
    input wire           pclk,
    input wire           reset_n,
    output reg [10:0] h_pos,
    output reg [10:0] v_pos,
    output wire          hsync,
    output wire          vsync,
    output wire          active,
    output wire          blank_n
);
    // Dummy controller - provides basic counting for simulation
    // Real controller implements proper VGA timing (sync pulses, blanking)
    localparam H_MAX = 1688; // Example total horizontal count for 1280 @ 60Hz
    localparam V_MAX = 1066; // Example total vertical count for 1024 @ 60Hz
    localparam H_ACTIVE = 1280;
    localparam V_ACTIVE = 1024;

    always @(posedge pclk or negedge reset_n) begin
        if (!reset_n) begin
            h_pos <= 0;
            v_pos <= 0;
        end else begin
            if (h_pos == H_MAX - 1) begin
                h_pos <= 0;
                if (v_pos == V_MAX - 1) begin
                    v_pos <= 0;
                end else begin
                    v_pos <= v_pos + 1;
                end
            end else begin
                h_pos <= h_pos + 1;
            end
        end
    end

    // Simplified sync/active logic (replace with actual timing)
    assign hsync = (h_pos >= 1328 && h_pos < 1440); // Example H sync pulse timing
    assign vsync = (v_pos >= 1027 && v_pos < 1030); // Example V sync pulse timing
    assign active = (h_pos < H_ACTIVE) && (v_pos < V_ACTIVE);
    assign blank_n = active; // Simplified blanking

endmodule
//`endif


// Note: This code is written to support monitor display resolutions of 1280 x 1024 at 60 fps

// (DETAILS OF THE MODULES)
// VGAInterface.v is the top most level module and asserts the red/green/blue signals to draw to the computer screen
// VGAController.v is a submodule within the top module used to generate the vertical and horizontal synch signals as well as X and Y pixel positions
// VGAFrequency.v is a submodule within the top module used to generate a 108Mhz pixel clock frequency from a 50Mhz pixel clock frequency using the PLL

// (USER/CODER Notes)
// Note: User should modify/write code in the VGAInterface.v file and not modify any code written in VGAController.v or VGAFrequency.v

module VGAInterface(

	//////////// CLOCK //////////
	input wire          		CLOCK_50,
	input wire          		CLOCK2_50, // Unused in provided logic
	input wire          		CLOCK3_50, // Unused in provided logic

	//////////// LED //////////
	output wire	     [8:0]		LEDG,
	output wire	    [17:0]		LEDR,

	//////////// KEY //////////
	input wire	     [3:0]		KEY,

	//////////// SW //////////
	input wire	    [17:0]		SW,

	//////////// SEG7 //////////
	output wire	     [6:0]		HEX0,
	output wire	     [6:0]		HEX1,
	output wire	     [6:0]		HEX2,
	output wire	     [6:0]		HEX3,
	output wire	     [6:0]		HEX4,
	output wire	     [6:0]		HEX5,
	output wire	     [6:0]		HEX6,
	output wire	     [6:0]		HEX7,

	//////////// VGA //////////
	output wire	     [7:0]		VGA_B,
	output wire	          		VGA_BLANK_N,
	output wire	          		VGA_CLK,
	output wire	     [7:0]		VGA_G,
	output wire	          		VGA_HS,
	output wire	     [7:0]		VGA_R,
	output wire	          		VGA_SYNC_N,
	output wire	          		VGA_VS,

    //////////// DFT //////////
    input wire               test_i,
    input wire               scan_clk,
    input wire               rst_n // Added primary reset (active low)
);

//=======================================================
//  PARAMETER declarations
//=======================================================
// Screen resolution (example: 1280x1024) - Adjust if VGAController uses different parameters
localparam H_ACTIVE = 1280; // Horizontal active pixels
localparam V_ACTIVE = 1024; // Vertical active pixels
// Drawing parameters
localparam PADDLE_WIDTH = 20;
localparam PADDLE_HEIGHT = 125;
localparam DOT_RADIUS = 15;
localparam DOT_RADIUS_SQ = DOT_RADIUS * DOT_RADIUS; // 225
// Boundaries (assuming active area starts at 0,0 for simplicity here, adjust based on VGAController)
localparam V_TOP_BOUNDARY = 128; // Example top boundary for play area
localparam V_BOTTOM_BOUNDARY = 896; // Example bottom boundary for play area
localparam H_LEFT_BOUNDARY = 225; // Paddle 1 X position (Left edge)
localparam H_RIGHT_BOUNDARY = 1030; // Paddle 2 X position (Left edge)
localparam COURT_LEFT_EDGE = H_LEFT_BOUNDARY + PADDLE_WIDTH; // Right edge of Paddle 1's area
localparam COURT_RIGHT_EDGE = H_RIGHT_BOUNDARY; // Left edge of Paddle 2's area

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire 	aresetPll; // asynchronous reset for pll (active high)
wire 	pixelClock_internal; // Internal PLL output
wire    pixelClock;          // Clock used by VGA Controller and drawing logic (potentially muxed)
wire	[10:0] XPixelPosition; // Current Horizontal pixel coordinate from controller
wire	[10:0] YPixelPosition; // Current Vertical pixel coordinate from controller
reg		[7:0] redValue;
reg		[7:0] greenValue;
reg		[7:0] blueValue;
wire    activeVideo; // Indicates if current pixel is in active display area

// Movement state for the dot
reg		[1:0] movement; // 00: Up-Right, 01: Down-Right, 10: Up-Left, 11: Down-Left

// slow clock counter variables
reg 	[20:0] slowClockCounter;
wire 	slowClockEnable;

// fast clock counter variables
reg 	[20:0] fastClockCounter;
wire 	fastClockEnable;

// variables for the dot
reg		[10:0] XDotPosition; // Center X
reg		[10:0] YDotPosition; // Center Y

// variables for paddle 1
reg		[10:0] P1y; // Top Y position

// variables for paddle 2
reg		[10:0] P2y; // Top Y position

// variables for player scores
reg 	[3:0] P1Score;
reg		[3:0] P2Score;
reg 	score_flag; // Flag to prevent multiple score updates per miss

// DFT clock signals
wire dft_pixel_clk;
wire dft_clk_50;

//=======================================================
//  Structural coding
//=======================================================

// output assignments
assign VGA_SYNC_N = 1'b0;  // Typically tied low
assign VGA_CLK = pixelClock; // Output potentially muxed clock to monitor
assign VGA_R = redValue;
assign VGA_G = greenValue;
assign VGA_B = blueValue;

// display the X or Y position of the dot on LEDS (Binary format)
// MSB is LEDR[10], LSB is LEDR[0]
assign LEDR[10:0] = SW[1] ? YDotPosition : XDotPosition;
assign LEDR[17:11] = 7'b0; // Tie unused LEDs low
assign LEDG = 9'b0; // Tie unused LEDs low

// Unused HEX displays
assign HEX0 = 7'b1111111;
assign HEX1 = 7'b1111111;
assign HEX2 = 7'b1111111;
assign HEX3 = 7'b1111111;
assign HEX4 = 7'b1111111;
assign HEX5 = 7'b1111111;
assign HEX6 = 7'b1111111;
assign HEX7 = 7'b1111111;


// DFT clock assignments
assign dft_clk_50   = test_i ? scan_clk : CLOCK_50;
// Use scan_clk for pixel domain FFs if test_i is active, otherwise use the generated pixelClock
assign dft_pixel_clk = test_i ? scan_clk : pixelClock;

// PLL Reset assignment (assuming PLL needs active high reset)
assign aresetPll = ~rst_n;

// Instantiate PLL to generate pixel clock
// Assuming VGAFrequency has ports: inclk0, areset, c0
VGAFrequency u_pll (
    .inclk0 (CLOCK_50),          // Input clock (50MHz)
    .areset (aresetPll),         // Asynchronous reset (active high derived from rst_n)
    .c0     (pixelClock_internal) // Output clock (e.g., 108MHz)
);
// Assign the internal clock to the clock signal used downstream
// No muxing needed here if dft_pixel_clk muxes later
assign pixelClock = pixelClock_internal;


// Instantiate VGA Controller
// Assuming VGAController ports: pclk, reset_n, h_pos, v_pos, hsync, vsync, active, blank_n
VGAController u_vga_ctrl (
    .pclk       (dft_pixel_clk), // Use DFT-muxed pixel clock
    .reset_n    (rst_n),         // Use primary active-low reset
    .h_pos      (XPixelPosition),// Output horizontal position
    .v_pos      (YPixelPosition),// Output vertical position
    .hsync      (VGA_HS),        // Output horizontal sync
    .vsync      (VGA_VS),        // Output vertical sync
    .active     (activeVideo),   // Output active video flag
    .blank_n    (VGA_BLANK_N)    // Output blanking signal
);


// Slow Clock Counter & Enable Generation (for dot movement)
// Clocked by dft_clk_50 (Primary CLOCK_50 or scan_clk)
always @(posedge dft_clk_50 or negedge rst_n) begin
    if (!rst_n) begin
        slowClockCounter <= 21'b0;
    end else begin
        // Increment continuously
        slowClockCounter <= slowClockCounter + 1;
    end
end
// Enable roughly every 2^16 cycles of CLOCK_50 (~1.3ms at 50MHz)
assign slowClockEnable = (slowClockCounter[15:0] == 16'hFFFF);

// Fast Clock Counter & Enable Generation (for paddle movement)
// Clocked by dft_clk_50 (Primary CLOCK_50 or scan_clk)
always @(posedge dft_clk_50 or negedge rst_n) begin
     if (!rst_n) begin
         fastClockCounter <= 21'b0;
     end else begin
         // Increment continuously
         fastClockCounter <= fastClockCounter + 1;
     end
 end
// Enable roughly every 2^17 cycles of CLOCK_50 (~2.6ms at 50MHz)
assign fastClockEnable = (fastClockCounter[16:0] == 17'h1FFFF);


// Paddle 1 Y position movement (Top edge Y coordinate)
// Clocked by dft_clk_50 (Primary CLOCK_50 or scan_clk)
always@(posedge dft_clk_50 or negedge rst_n)
begin
    if (!rst_n) begin
        P1y <= (V_TOP_BOUNDARY + V_BOTTOM_BOUNDARY - PADDLE_HEIGHT) / 2; // Center paddle vertically
    end else if (fastClockEnable) begin // Update on fast clock enable
        // Functional mode controlled by SW[0] - Allows disabling P1 movement (SW[0]=0 enables movement)
        if (SW[0] == 1'b0) begin
             // KEY[3] = Up, KEY[2] = Down (active low)
            if (KEY[3] == 1'b0 && KEY[2] == 1'b1) begin // Move up (KEY[3] pressed)
                if(P1y <= V_TOP_BOUNDARY) // Check top edge
                    P1y <= V_TOP_BOUNDARY; // Min position
                else
                    P1y <= P1y -