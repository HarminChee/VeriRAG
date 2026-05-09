`define ONE_SEC 25000000
`define ONE_SEC 25000000
module DE0_NANO(
	CLOCK_50,
	LED,
	KEY,
	SW,
	GPIO_0_D,
	GPIO_0_IN,
	GPIO_1_D,
	GPIO_1_IN,
);
	 localparam ONE_SEC = 25000000; 
	 localparam white = 8'b11111111;
	 localparam black = 8'b0;
	 localparam pink = 8'b11110011;
	 localparam cyan = 8'b10011011;
	 input 		          		CLOCK_50;
	 output		     [7:0]		LED;
	 input 		     [1:0]		KEY;
	 input 		     [3:0]		SW;
	 inout 		    [33:0]		GPIO_0_D;
	 input 		     [1:0]		GPIO_0_IN;
	 inout 		    [33:0]		GPIO_1_D;
	 input 		     [1:0]		GPIO_1_IN;
    reg         CLOCK_25;
    wire        reset; 
    wire [9:0]  PIXEL_COORD_X; 
    wire [9:0]  PIXEL_COORD_Y; 
    reg [7:0]  PIXEL_COLOR;   
	 wire [2:0] GRID_X;
	 wire [2:0] GRID_Y;
	 reg grid [19:0][7:0];
	 reg visited [19:0]; 
	 GRID_SELECTOR gridSelector(
		.CLOCK_50(CLOCK_50),
		.PIXEL_COORD_X(PIXEL_COORD_X),
		.PIXEL_COORD_Y(PIXEL_COORD_Y),
		.GRID_X(GRID_X),
		.GRID_Y(GRID_Y)
	);
	reg[7:0] grid1[3:0] [4:0];
	reg[7:0] currentGrid;
	reg[24:0] counter;
	always @(posedge CLOCK_25) begin
		if (GRID_X > 3) begin 
			PIXEL_COLOR <= black;
		end
		else begin
		currentGrid <= grid1[GRID_X][GRID_Y];
			if (currentGrid == 0) begin 
				PIXEL_COLOR <= white;
			end
			if (currentGrid[0] == 1) begin 
				PIXEL_COLOR <= pink;
			end
		end
	end
	reg[2:0] x;
	reg[2:0] y;
	 reg [24:0] led_counter; 
	 reg 			led_state;   
    VGA_DRIVER driver(
		  .RESET(reset),
        .CLOCK(CLOCK_25),
        .PIXEL_COLOR_IN(PIXEL_COLOR),
        .PIXEL_X(PIXEL_COORD_X),
        .PIXEL_Y(PIXEL_COORD_Y),
        .PIXEL_COLOR_OUT({GPIO_0_D[9],GPIO_0_D[11],GPIO_0_D[13],GPIO_0_D[15],GPIO_0_D[17],GPIO_0_D[19],GPIO_0_D[21],GPIO_0_D[23]}),
        .H_SYNC_NEG(GPIO_0_D[7]),
        .V_SYNC_NEG(GPIO_0_D[5])
    );
	 assign reset = ~KEY[0]; 
	 assign LED[0] = led_state;
    always @ (posedge CLOCK_50) begin
        CLOCK_25 <= ~CLOCK_25; 
    end 
	 always @ (posedge CLOCK_25) begin
		  if (reset) begin
				led_state   <= 1'b0;
				led_counter <= 25'b0;
				x <= 3'b0;
				y <= 3'b0;
				grid1[0][0] = 8'b0;
				grid1[0][1] = 8'b0;
				grid1[0][2] = 8'b0;
				grid1[0][3] = 8'b0;
				grid1[0][4] = 8'b0;
				grid1[1][0] = 8'b0;
				grid1[1][1] = 8'b0;
				grid1[1][2] = 8'b0;
				grid1[1][3] = 8'b0;
				grid1[1][4] = 8'b0;
				grid1[2][0] = 8'b0;
				grid1[2][1] = 8'b0;
				grid1[2][2] = 8'b0;
				grid1[2][3] = 8'b0;
				grid1[2][4] = 8'b0;
				grid1[3][0] = 8'b0;
				grid1[3][1] = 8'b0;
				grid1[3][2] = 8'b0;
				grid1[3][3] = 8'b0;
				grid1[3][4] = 8'b0;
		  end
		  if (led_counter == ONE_SEC) begin
				led_state   <= ~led_state;
				led_counter <= 25'b0;
				if (y==3'b100) begin 
					y<= 3'b0;
					x<=x+3'b001;
				end
				else begin
					y <= y + 3'b1;
				end 
				grid1[x][y] <= 8'b1;
		  end
		  else begin	
				led_state   <= led_state;
				led_counter <= led_counter + 25'b1;
		  end 
	 end
endmodule 
