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
	VGA_VS 
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
output		     [8:0]		LEDG;
output		    [17:0]		LEDR;

//////////// KEY //////////
input		     [3:0]		KEY;

//////////// SW //////////
input		    [17:0]		SW;

//////////// SEG7 //////////
output		     [6:0]		HEX0;
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
reg	aresetPll = 0; // asynchrous reset for pll
wire 	pixelClock;
wire	[10:0] XPixelPosition;
wire	[10:0] YPixelPosition; 
reg	[7:0] redValue;
reg	[7:0] greenValue;
reg	[7:0] blueValue;

reg	[1:0] movement = 0;
parameter r = 15;

// slow clock counter variables
reg 	[20:0] slowClockCounter = 0;
wire 	slowClock;

// fast clock counter variables
reg 	[20:0] fastClockCounter = 0;
wire 	fastClock;

// variables for the dot 
reg	[10:0] XDotPosition = 500;
reg	[10:0] YDotPosition = 500; 

// variables for paddle 1 
reg	[10:0] P1x = 225;
reg	[10:0] P1y = 500;

// variables for paddle 2
reg	[10:0] P2x = 1030;
reg	[10:0] P2y = 500;

// variables for player scores
reg 	[3:0] P1Score = 0;
reg	[3:0] P2Score = 0;
reg 	flag = 1'b0;



//=======================================================
//  Structural coding
//=======================================================

// output assignments
assign VGA_BLANK_N = 1'b1;
assign VGA_SYNC_N = 1'b1;			
assign VGA_CLK = pixelClock;

// display the X or Y position of the dot on LEDS (Binary format)
// MSB is LEDR[10], LSB is LEDR[0]
assign LEDR[10:0] = SW[1] ? YDotPosition : XDotPosition; 



assign slowClock = slowClockCounter[16]; // take MSB from counter to use as a slow clock

always@ (posedge CLOCK_50) // generates a slow clock by selecting the MSB from a large counter
begin
	slowClockCounter <= slowClockCounter + 1;
end

assign fastClock = fastClockCounter[17]; // take Middle Bit from counter to use as a slow clock

always@ (posedge CLOCK_50) // generates a fast clock by selecting the Middle Bit from a large counter
begin
	fastClockCounter <= fastClockCounter + 1;
end

always@(posedge fastClock) // process moves the y position of player1 paddle
begin
if (SW[0] == 1'b0) 
begin
	if (KEY[2] == 1'b0 && KEY[3] == 1'b0) 
		P1y <= P1y;
	else if (KEY[2] == 1'b0) begin
		if (P1y+125 >896)
			P1y <= 771;
		else
		P1y <= P1y + 1;
		end
	else if (KEY[3] == 1'b0) begin
		if(P1y < 128)
			P1y <= 128;
		else
		P1y <= P1y - 1;
		end
end
else if (SW[0] == 1'b1 || flag == 1'b1)
P1y <= 500;
//flag =1'b0;
end

always@(posedge fastClock) // process moves the y position of player2 paddle
begin
if (SW[0] == 1'b0) 
begin
	if (KEY[0] == 1'b0 && KEY[1] == 1'b0) 
		P2y <= P2y;
	else if (KEY[0] == 1'b0) begin
		if(P2y+125 > 896)
			P2y <= 771;
		else
		P2y <= P2y + 1;
		end
	else if (KEY[1] == 1'b0) begin
		if(P2y < 128)
			P2y <= 128;
		else
		P2y <= P2y - 1;
		end
end
else if (SW[0] == 1'b1 || flag == 1'b1)
	P2y <= 500;
end

always@(posedge slowClock) // Moves Ball
begin
if (SW[0] == 1'b0)
	begin
	case(movement)
		2'b00:		begin //Ball moves in NE direction
				XDotPosition <= XDotPosition + 1;
				YDotPosition <= YDotPosition - 1;
				end
		2'b01:		begin //Ball moves in SE direction
				XDotPosition <= XDotPosition + 1;
				YDotPosition <= YDotPosition + 1;
				end
		2'b10:		begin //Ball moves in SW direction
				XDotPosition <= XDotPosition - 1;
				YDotPosition <= YDotPosition + 1;
				end
		2'b11:		begin //Ball moves in NW direction
				XDotPosition <= XDotPosition - 1;
				YDotPosition <= YDotPosition - 1;
				end
	endcase
	
	if(YDotPosition - r <= 128 && movement == 2'b00) //bounce top wall from NE
		movement = 2'b01;
	else if (YDotPosition - r <= 128 && movement == 2'b11)// bounce top wall from NW
		movement = 2'b10;
	else if (YDotPosition + r >= 896 && movement == 2'b01)	// bounce bottom wall from SE
		movement = 2'b00;
	else if (YDotPosition + r >= 896 && movement == 2'b10) // bounce bottom wall from Sw
		movement = 2'b11;
	else if (XDotPosition -r <= P1x+25 && YDotPosition > P1y && YDotPosition < P1y+125 &&  movement == 2'b10)//bounce left paddle from SW
		movement = 2'b01;
	else if (XDotPosition -r<= P1x+25 && YDotPosition > P1y && YDotPosition < P1y+125 &&  movement == 2'b11)//bounce left paddle from NW
		movement = 2'b00;
	else if (XDotPosition + r >= P2x && YDotPosition > P2y && YDotPosition < P2y+125 &&  movement == 2'b01)//bounce right paddle from SE 
		movement = 2'b10;
	else if (XDotPosition + r >= P2x && YDotPosition > P2y && YDotPosition < P2y+125 &&  movement == 2'b00)//bounce right paddle from NE
		movement = 2'b11;
	else if (XDotPosition - r <= 160) begin
		P2Score = P2Score + 1;
		//reset ball
		XDotPosition <= 640;
		YDotPosition <= 512;
		end
	else if (XDotPosition + r >= 1120)begin
		P1Score = P1Score + 1;
		//reset ball
		XDotPosition <= 640;
		YDotPosition <= 512;
		end
		
		/***if(flag==1) begin
			flag<=0;
		end***/
		
		if(P1Score == 10 || P2Score ==10) begin
			P1Score<=0;
			P2Score<=0;
			flag <=1'b1;
			end
end
else //reset ball and score
	begin
	XDotPosition <= 500;
	YDotPosition <= 500;
	P1Score <= 0;
	P2Score <= 0;
	end
	
end


/*always@(posedge slowClock) // process moves the X position of the dot
begin
	if (KEY[0] == 1'b0) 
		XDotPosition <= XDotPosition + 1;
	else if (KEY[1] == 1'b0) 
		XDotPosition <= XDotPosition - 1;
end

always@(posedge slowClock) // process moves the Y position of the dot
begin
	if (KEY[2] == 1'b0) 
		YDotPosition <= YDotPosition + 1;
	else if (KEY[3] == 1'b0) 
		YDotPosition <= YDotPosition - 1;
end
*/


// PLL Module (Phase Locked Loop) used to convert a 50Mhz clock signal to a 108 MHz clock signal for the pixel clock
VGAFrequency VGAFreq (aresetPll, CLOCK_50, pixelClock);

// VGA Controller Module used to generate the vertial and horizontal synch signals for the monitor and the X and Y Pixel position of the monitor display
VGAController VGAControl (pixelClock, redValue, greenValue, blueValue, VGA_R, VGA_G, VGA_B, VGA_VS, VGA_HS, XPixelPosition, YPixelPosition);


// COLOR ASSIGNMENT PROCESS (USER WRITES CODE HERE TO DRAW TO SCREEN)
always@ (posedge pixelClock)
begin		
	begin
		if (XPixelPosition < 160) //set left green border
		begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b11111111;
		end
		else if (XPixelPosition > 1120) // set right green border
		begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b11111111;
		end
		else if (YPixelPosition < 128 && XPixelPosition > 160 && XPixelPosition < 1120) //set top magenta border
		begin
			redValue <= 8'b11111111; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b00000000;
		end
		else if (XPixelPosition < 1120 && XPixelPosition > 160 && YPixelPosition > 896) // set bottom magenta border
		begin
			redValue <= 8'b11111111; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b00000000;
		end
		else if (XPixelPosition > P1x && XPixelPosition < P1x+25 && YPixelPosition > P1y && YPixelPosition < P1y+125) // draw player 1 paddle
		begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b11111111;
		end
		else if (XPixelPosition > P2x && XPixelPosition < P2x+25 && YPixelPosition > P2y && YPixelPosition < P2y+125) // draw player 2 paddle
		begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b11111111;
		end
		//draw ball using (x-a)^2 + (y-b)^2 = r^2 where (a,b) is the center of the circle and r = 15
		//a = XDotPosition, b = YDotPosition
		else if (((XPixelPosition-XDotPosition)*(XPixelPosition-XDotPosition)
						+ (YPixelPosition-YDotPosition)*(YPixelPosition-YDotPosition)) < 15*15) 
		begin
			redValue <= 8'b11111111; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
		end
		else // default background is black
		begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
		end
	end
end

ScoreDecoder p1(P1Score, HEX7, HEX6);
ScoreDecoder p2(P2Score, HEX5, HEX4);

endmodule


// Note: This code is written to support monitor display resolutions of 1280 x 1024 at 60 fps

module VGAFrequency(
	areset,
	inclk0,
	c0
);

input areset;
input inclk0;
output c0;

wire c0_buf;

// Input clock buffering / unused out clock deletion
wire inclk0_buf;
IBUFG inclk0_buf_inst (.I (inclk0), .O (inclk0_buf));

// Clocking primitive
PLL_ADV #(
	.BANDWIDTH            ("OPTIMIZED"),
	.CLKOUT4_CASCADE      ("FALSE"),
	.COMPENSATION         ("SYSTEM_SYNCHRONOUS"),
	.DIVCLK_DIVIDE        (1),
	.CLKFBOUT_MULT        (21),
	.CLKFBOUT_PHASE       (0.000),
	.CLKIN1_PERIOD        (20.000),
	.CLKOUT0_DIVIDE       (19),
	.CLKOUT0_PHASE        (0.000),
	.CLKOUT0_DUTY_CYCLE   (0.500),
	.CLKOUT1_DIVIDE       (5),
	.CLKOUT1_PHASE        (0.000),
	.CLKOUT1_DUTY_CYCLE   (0.500),
	.CLKOUT2_DIVIDE       (1),
	.CLKOUT2_PHASE        (0.000),
	.CLKOUT2_DUTY_CYCLE   (0.500),
	.CLKOUT3_DIVIDE       (1),
	.CLKOUT3_PHASE        (0.000),
	.CLKOUT3_DUTY_CYCLE   (0.500),
	.CLKOUT4_DIVIDE       (1),
	.CLKOUT4_PHASE        (0.000),
	.CLKOUT4_DUTY_CYCLE   (0.500),
	.CLKOUT5_DIVIDE       (1),
	.CLKOUT5_PHASE        (0.000),
	.CLKOUT5_DUTY_CYCLE   (0.500),
	.CLKFB_DIVIDE         (1)
) pll_adv_inst (
	.CLKOUT0  (c0_buf),
	.CLKOUT1  (),
	.CLKOUT2  (),
	.CLKOUT3  (),
	.CLKOUT4  (),
	.CLKOUT5  (),
	.LOCKED   (),
	.CLKFBOUT (),
	.CLKFBDONE(),
	.RST      (areset),
	.CLKFBIN  (c0_buf),
	.CLKIN1   (inclk0_buf),
	.CLKIN2   (1'b0),
	.PWRDWN   (1'b0)
);

OBUF c0_bufg (.I(c0_buf), .O(c0));

endmodule

module VGAController(
	pixelClock,
	redValue,
	greenValue,
	blueValue,
	VGA_R,
	VGA_G,
	VGA_B,
	VGA_VS,
	VGA_HS,
	XPixelPosition,
	YPixelPosition
);

input			pixelClock;
input	[7:0]		redValue;
input	[7:0]		greenValue;
input	[7:0]		blueValue;
output	[7:0]		VGA_R;
output	[7:0]		VGA_G;
output	[7:0]		VGA_B;
output			VGA_VS;
output			VGA_HS;
output	[10:0]		XPixelPosition;
output	[10:0]		YPixelPosition;

// registers for outputs
reg [7:0] 	VGA_R = 8'b00000000;
reg [7:0] 	VGA_G = 8'b00000000;
reg [7:0] 	VGA_B = 8'b00000000;
reg 		VGA_VS = 1'b0;
reg 		VGA_HS = 1'b0;

// pixel coordinate registers
reg [10:0]	XPixelPosition = 0;
reg [10:0]	YPixelPosition = 0;

// horizontal and vertical counters
reg [10:0]	hCounter = 0;
reg [10:0]	vCounter = 0;

// horizontal timing constants
`define H_FRONT_PORCH	16
`define H_SYNC		128
`define H_BACK_PORCH	112
`define H_ACTIVE		1280
`define H_TOTAL		`H_FRONT_PORCH + `H_SYNC + `H_BACK_PORCH + `H_ACTIVE

// vertical timing constants
`define V_FRONT_PORCH	1
`define V_SYNC		3
`define V_BACK_PORCH	14
`define V_ACTIVE		1024
`define V_TOTAL		`V_FRONT_PORCH + `V_SYNC + `V_BACK_PORCH + `V_ACTIVE

always @(posedge pixelClock)
begin
	// horizontal counter always increments
	hCounter <= hCounter + 1;
	
	// when horizontal counter reaches horizontal total...
	if (hCounter == `H_TOTAL)
	begin
		// ...reset horizontal counter
		hCounter <= 0;
		
		// ...and increment vertical counter
		vCounter <= vCounter + 1;
		
		// when vertical counter reaches vertical total...
		if (vCounter == `V_TOTAL)
			// ...reset vertical counter
			vCounter <= 0;
	end
end

always @(posedge pixelClock)
begin
	// horizontal sync signal
	if ((hCounter >= (`H_FRONT_PORCH)) && (hCounter < (`H_FRONT_PORCH + `H_SYNC)))
		VGA_HS <= 0;
	else
		VGA_HS <= 1;
		
	// vertical sync signal
	if ((vCounter >= (`V_FRONT_PORCH)) && (vCounter < (`V_FRONT_PORCH + `V_SYNC)))
		VGA_VS <= 0;
	else
		VGA_VS <= 1;
end

always @(posedge pixelClock)
begin
	// calculate pixel positions
	if ((hCounter >= (`H_FRONT_PORCH + `H_SYNC + `H_BACK_PORCH)) && (hCounter < `H_ACTIVE + `H_FRONT_PORCH + `H_SYNC + `H_BACK_PORCH))
		XPixelPosition <= hCounter - `H_FRONT_PORCH - `H_SYNC - `H_BACK_PORCH;
	else
		XPixelPosition <= 0;
		
	if ((vCounter >= (`V_FRONT_PORCH + `V_SYNC + `V_BACK_PORCH)) && (vCounter < `V_ACTIVE + `V_FRONT_PORCH + `V_SYNC + `V_BACK_PORCH))
		YPixelPosition <= vCounter - `V_FRONT_PORCH - `V_SYNC - `V_BACK_PORCH;
	else
		YPixelPosition <= 0;
end

always @(posedge pixelClock)
begin
	// set colors
	VGA_R <= redValue;
	VGA_G <= greenValue;
	VGA_B <= blueValue;
end

endmodule

module ScoreDecoder(
	input [3:0] score,
	output [6:0] hex1,
	output [6:0] hex2
);

reg [6:0] hex1_reg;
reg [6:0] hex2_reg;

always @(score) begin
    case (score)
        0: begin
            hex1_reg = 7'b0111111;
            hex2_reg = 7'b0111111;
        end
        1: begin
            hex1_reg = 7'b0000110;
            hex2_reg = 7'b0000110;
        end
        2: begin
            hex1_reg = 7'b1011011;
            hex2_reg = 7'b1011011;
        end
        3: begin
            hex1_reg = 7'b1001111;
            hex2_reg = 7'b1001111;
        end
        4: begin
            hex1_reg = 7'b1100110;
            hex2_reg = 7'b1100110;
        end
        5: begin
            hex1_reg = 7'b1101101;
            hex2_reg = 7'b1101101;
        end
        6: begin
            hex1_reg = 7'b1111101;
            hex2_reg = 7'b1111101;
        end
        7: begin
            hex1_reg = 7'b0000111;
            hex2_reg = 7'b0000111;
        end
        8: begin
            hex1_reg = 7'b1111111;
            hex2_reg = 7'b1111111;
        end
        9: begin
            hex1_reg = 7'b1101111;
            hex2_reg = 7'b1101111;
        end
		default: begin
			hex1_reg = 7'b0000000;
			hex2_reg = 7'b0000000;
		end
    endcase
end

assign hex1 = hex1_reg;
assign hex2 = hex2_reg;

endmodule