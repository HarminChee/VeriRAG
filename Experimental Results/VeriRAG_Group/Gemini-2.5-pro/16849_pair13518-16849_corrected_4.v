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
localparam H_LEFT_BOUNDARY = 225; // Paddle 1 X position
localparam H_RIGHT_BOUNDARY = 1030; // Paddle 2 X position
localparam COURT_LEFT_EDGE = H_LEFT_BOUNDARY + PADDLE_WIDTH/2; // Approx center of paddle 1
localparam COURT_RIGHT_EDGE = H_RIGHT_BOUNDARY - PADDLE_WIDTH/2; // Approx center of paddle 2

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

// display the X or Y position of the dot on LEDS (Binary format)
// MSB is LEDR[10], LSB is LEDR[0]
assign LEDR[10:0] = SW[1] ? YDotPosition : XDotPosition;
assign LEDR[17:11] = 7'b0; // Tie unused LEDs low
assign LEDG = 9'b0; // Tie unused LEDs low

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
    .areset (aresetPll),         // Asynchronous reset (active high)
    .c0     (pixelClock_internal) // Output clock (e.g., 108MHz)
);
// Assign the internal clock to the clock signal used downstream
// No muxing needed here if dft_pixel_clk muxes later
assign pixelClock = pixelClock_internal;


// Instantiate VGA Controller
// Assuming VGAController ports: pclk, reset_n, h_pos, v_pos, hsync, vsync, active
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
always@(posedge dft_clk_50 or negedge rst_n)
begin
    if (!rst_n) begin
        P1y <= (V_TOP_BOUNDARY + V_BOTTOM_BOUNDARY - PADDLE_HEIGHT) / 2; // Center paddle vertically
    end else if (fastClockEnable) begin // Update on fast clock enable
        // Functional mode controlled by SW[0] - Allows disabling P1 movement
        if (SW[0] == 1'b0) begin
            if (KEY[2] == 1'b0 && KEY[3] == 1'b1) begin // Move down (KEY[2] pressed) -> Logic seems inverted in comment vs code, assuming KEY[2]=Down, KEY[3]=Up
                if (P1y + PADDLE_HEIGHT >= V_BOTTOM_BOUNDARY) // Check bottom edge
                    P1y <= V_BOTTOM_BOUNDARY - PADDLE_HEIGHT; // Max position
                else
                    P1y <= P1y + 1; // Move down
            end else if (KEY[2] == 1'b1 && KEY[3] == 1'b0) begin // Move up (KEY[3] pressed)
                if(P1y <= V_TOP_BOUNDARY) // Check top edge
                    P1y <= V_TOP_BOUNDARY; // Min position
                else
                    P1y <= P1y - 1; // Move up
            end
            // else P1y <= P1y; // Hold position if no/both keys pressed - implicit
        end
        // else P1y <= P1y; // Hold position if SW[0] is high - implicit
    end
end

// Paddle 2 Y position movement (Top edge Y coordinate)
always@(posedge dft_clk_50 or negedge rst_n)
begin
    if (!rst_n) begin
        P2y <= (V_TOP_BOUNDARY + V_BOTTOM_BOUNDARY - PADDLE_HEIGHT) / 2; // Center paddle vertically
    end else if (fastClockEnable) begin // Update on fast clock enable
        // Controlled by SW[2] (Down) and SW[3] (Up)
        if (SW[2] == 1'b1 && SW[3] == 1'b0) begin // Move down (SW[2] active)
            if (P2y + PADDLE_HEIGHT >= V_BOTTOM_BOUNDARY) // Check bottom edge
                P2y <= V_BOTTOM_BOUNDARY - PADDLE_HEIGHT; // Max position
            else
                P2y <= P2y + 1; // Move down
        end else if (SW[2] == 1'b0 && SW[3] == 1'b1) begin // Move up (SW[3] active)
            if(P2y <= V_TOP_BOUNDARY) // Check top edge
                P2y <= V_TOP_BOUNDARY; // Min position
            else
                P2y <= P2y - 1; // Move up
        end
        // else P2y <= P2y; // Hold position if no/both switches active - implicit
    end
end


// Dot Position and Movement Logic
always @(posedge dft_clk_50 or negedge rst_n) begin
    if (!rst_n) begin
        XDotPosition <= H_ACTIVE / 2; // Start in center X
        YDotPosition <= V_ACTIVE / 2; // Start in center Y
        movement <= 2'b00; // Initial movement: Up-Right
        P1Score <= 4'b0;
        P2Score <= 4'b0;
        score_flag <= 1'b0; // Reset score flag
    end else if (slowClockEnable) begin // Update position on slow clock enable
        score_flag <= 1'b0; // Clear score flag each movement cycle unless a score happens

        // Next position calculation based on current movement direction
        case (movement)
            2'b00: begin // Up-Right
                XDotPosition <= XDotPosition + 1;
                YDotPosition <= YDotPosition - 1;
            end
            2'b01: begin // Down-Right
                XDotPosition <= XDotPosition + 1;
                YDotPosition <= YDotPosition + 1;
            end
            2'b10: begin // Up-Left
                XDotPosition <= XDotPosition - 1;
                YDotPosition <= YDotPosition - 1;
            end
            2'b11: begin // Down-Left
                XDotPosition <= XDotPosition - 1;
                YDotPosition <= YDotPosition + 1;
            end
            default: begin // Should not happen
                XDotPosition <= H_ACTIVE / 2;
                YDotPosition <= V_ACTIVE / 2;
            end
        endcase

        // Collision Detection and Movement Change

        // Top/Bottom Wall Collision
        if (YDotPosition <= V_TOP_BOUNDARY + DOT_RADIUS) begin // Hit top wall (check center relative to boundary+radius)
             movement[0] <= ~movement[0]; // Invert vertical direction (Up -> Down)
             YDotPosition <= V_TOP_BOUNDARY + DOT_RADIUS + 1; // Prevent getting stuck slightly inside
        end else if (YDotPosition >= V_BOTTOM_BOUNDARY - DOT_RADIUS) begin // Hit bottom wall
             movement[0] <= ~movement[0]; // Invert vertical direction (Down -> Up)
             YDotPosition <= V_BOTTOM_BOUNDARY - DOT_RADIUS - 1; // Prevent getting stuck slightly inside
        end

        // Paddle 1 Collision (Left Paddle)
        // Check if dot's left edge is at or past the paddle's right edge
        // And dot's center Y is within paddle's Y range
        if ( (XDotPosition - DOT_RADIUS <= COURT_LEFT_EDGE) && // Check X position near paddle 1 edge
             (YDotPosition >= P1y) &&                     // Check Y within paddle 1 top
             (YDotPosition <= P1y + PADDLE_HEIGHT) ) begin     // Check Y within paddle 1 bottom
            movement[1] <= ~movement[1]; // Invert horizontal direction (Left -> Right)
            XDotPosition <= COURT_LEFT_EDGE + DOT_RADIUS + 1; // Prevent sticking slightly inside
        end

        // Paddle 2 Collision (Right Paddle)
        // Check if dot's right edge is at or past the paddle's left edge
        // And dot's center Y is within paddle's Y range
        else if ( (XDotPosition + DOT_RADIUS >= COURT_RIGHT_EDGE) && // Check X position near paddle 2 edge
                  (YDotPosition >= P2y) &&                      // Check Y within paddle 2 top
                  (YDotPosition <= P2y + PADDLE_HEIGHT) ) begin      // Check Y within paddle