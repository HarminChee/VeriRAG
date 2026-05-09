// Note: This code is written to support monitor display resolutions of 1280 x 1024 at 60 fps

// (DETAILS OF THE MODULES)
// VGAInterface.v is the top most level module and asserts the red/green/blue signals to draw to the computer screen
// VGAController.v is a submodule within the top module used to generate the vertical and horizontal synch signals as well as X and Y pixel positions
// VGAFrequency.v is a submodule within the top module used to generate a 108Mhz pixel clock frequency from a 50Mhz pixel clock frequency using the PLL

// (USER/CODER Notes)
// Note: User should modify/write code in the VGAInterface.v file and not modify any code written in VGAController.v or VGAFrequency.v

module VGAInterface(

	//////////// CLOCK //////////
	CLOCK_50,
	CLOCK2_50,
	CLOCK3_50,

	//////////// LED //////////
	LEDG,
	LEDR,

	//////////// KEY //////////
	KEY,

	//////////// SW //////////
	SW,

	//////////// SEG7 //////////
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7,

	//////////// VGA //////////
	VGA_B,
	VGA_BLANK_N,
	VGA_CLK,
	VGA_G,
	VGA_HS,
	VGA_R,
	VGA_SYNC_N,
	VGA_VS,

    //////////// DFT //////////
    input               test_i,
    input               scan_clk,
    input               rst_n // Added primary reset (active low)
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input		          		CLOCK_50;
input		          		CLOCK2_50;
input		          		CLOCK3_50;

//////////// LED //////////
output		     [8:0]		LEDG; // Note: LEDG seems unused in the logic provided
output		    [17:0]		LEDR;

//////////// KEY //////////
input		     [3:0]		KEY;

//////////// SW //////////
input		    [17:0]		SW;

//////////// SEG7 //////////
output		     [6:0]		HEX0; // Note: HEX0-3 seem unused
output		     [6:0]		HEX1;
output		     [6:0]		HEX2;
output		     [6:0]		HEX3;
output		     [6:0]		HEX4;
output		     [6:0]		HEX5;
output		     [6:0]		HEX6;
output		     [6:0]		HEX7;

//////////// VGA //////////
output		     [7:0]		VGA_B;
output		          		VGA_BLANK_N;
output		          		VGA_CLK;
output		     [7:0]		VGA_G;
output		          		VGA_HS;
output		     [7:0]		VGA_R;
output		          		VGA_SYNC_N;
output		          		VGA_VS;

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire 	aresetPll; // asynchronous reset for pll (active high)
wire 	pixelClock;
wire	[10:0] XPixelPosition;
wire	[10:0] YPixelPosition;
reg	[7:0] redValue;
reg	[7:0] greenValue;
reg	[7:0] blueValue;

reg	[1:0] movement; // Initial value removed, use reset
localparam r = 15;
localparam r_squared = 225; // 15*15

// slow clock counter variables
reg 	[20:0] slowClockCounter; // Initial value removed, use reset
wire 	slowClockEnable;

// fast clock counter variables
reg 	[20:0] fastClockCounter; // Initial value removed, use reset
wire 	fastClockEnable;

// variables for the dot
reg	[10:0] XDotPosition; // Initial value removed, use reset
reg	[10:0] YDotPosition; // Initial value removed, use reset

// variables for paddle 1
reg	[10:0] P1x = 225; // Constant X position
reg	[10:0] P1y; // Initial value removed, use reset

// variables for paddle 2
reg	[10:0] P2x = 1030; // Constant X position
reg	[10:0] P2y; // Initial value removed, use reset

// variables for player scores
reg 	[3:0] P1Score; // Initial value removed, use reset
reg	[3:0] P2Score; // Initial value removed, use reset
reg 	flag; // Initial value removed, use reset

// DFT clock signals
wire dft_pixel_clk;
wire dft_clk_50; // DFT mux for primary clock

//=======================================================
//  Structural coding
//=======================================================

// output assignments
assign VGA_BLANK_N = 1'b1; // Typically driven by controller based on blanking intervals
assign VGA_SYNC_N = 1'b0;  // Typically tied low
assign VGA_CLK = pixelClock; // Output original pixel clock for monitor

// display the X or Y position of the dot on LEDS (Binary format)
// MSB is LEDR[10], LSB is LEDR[0]
assign LEDR[10:0] = SW[1] ? YDotPosition : XDotPosition;
// Assign unused LEDs?
assign LEDR[17:11] = 7'b0; // Example: Tie unused LEDs low
assign LEDG = 9'b0; // Tie unused LEDs low

// DFT clock assignments
assign dft_clk_50   = test_i ? scan_clk : CLOCK_50;
assign dft_pixel_clk = test_i ? scan_clk : pixelClock;

// PLL Reset assignment (assuming PLL needs active high reset)
assign aresetPll = ~rst_n;

// Slow Clock Counter & Enable Generation
always @(posedge dft_clk_50 or negedge rst_n) begin
    if (!rst_n) begin
        slowClockCounter <= 0;
    end else begin
        slowClockCounter <= slowClockCounter + 1;
    end
end
// Enable when the equivalent posedge of the old slowClock (slowClockCounter[16]) would occur
// This happens when slowClockCounter[15:0] transitions from 16'hFFFF to 16'h0000
assign slowClockEnable = (slowClockCounter[15:0] == 16'hFFFF);

// Fast Clock Counter & Enable Generation
always @(posedge dft_clk_50 or negedge rst_n) begin
     if (!rst_n) begin
         fastClockCounter <= 0;
     end else begin
         fastClockCounter <= fastClockCounter + 1;
     end
 end
// Enable when the equivalent posedge of the old fastClock (fastClockCounter[17]) would occur
// This happens when fastClockCounter[16:0] transitions from 17'h1FFFF to 17'h0000
assign fastClockEnable = (fastClockCounter[16:0] == 17'h1FFFF);


// Paddle 1 Y position movement
always@(posedge dft_clk_50 or negedge rst_n)
begin
    if (!rst_n) begin
        P1y <= 500; // Reset position
    end else if (fastClockEnable) begin // Use enable signal
        // Functional mode controlled by SW[0]
        if (SW[0] == 1'b0) begin
            if (KEY[2] == 1'b0 && KEY[3] == 1'b1) begin // Move down (KEY[2] pressed)
                if (P1y + 125 > 896) // Boundary check (bottom edge + paddle height)
                    P1y <= 896 - 125; // Max position
                else
                    P1y <= P1y + 1;
            end else if (KEY[2] == 1'b1 && KEY[3] == 1'b0) begin // Move up (KEY[3] pressed)
                if(P1y < 128) // Boundary check (top edge)
                    P1y <= 128; // Min position
                else
                    P1y <= P1y - 1;
            end
            // else P1y <= P1y; // Hold position if no/both keys pressed - implicit
        end
        // else P1y <= P1y; // Hold position if SW[0] is high - implicit
    end
end

// Paddle 2 Y position movement
always@(posedge dft_clk_50 or negedge rst_