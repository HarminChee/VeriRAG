module IICctrl
(
	input wire test_i, // Added DFT test mode signal
	input				iCLK,
	input				iRST_N,
	output				I2C_SCLK,
	inout				I2C_SDAT
);
parameter	LUT_SIZE	=	170;
reg	[7:0]	LUT_INDEX;
wire [7:0]	I2C_RDATA;
reg			Config_Done;
parameter	CLK_Freq	=	25_000000;
parameter	I2C_Freq	=	10_000;
reg	[15:0]	mI2C_CLK_DIV;
reg			mI2C_CTRL_CLK;
wire        i2c_tick; // Signal indicating the divider rollover
reg         i2c_tick_en; // Single-cycle enable synchronized to iCLK

// Clock Divider Logic
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
		begin
		mI2C_CLK_DIV	<=	0;
		mI2C_CTRL_CLK	<=	0;
		end
	else
		begin
		 if( mI2C_CLK_DIV	< (CLK_Freq/I2C_Freq)/2) begin
			 mI2C_CLK_DIV	<=	mI2C_CLK_DIV + 1'd1;
             mI2C_CTRL_CLK <= mI2C_CTRL_CLK; // Keep state unless toggling
         end
		 else
			 begin
			 mI2C_CLK_DIV	<=	0;
			mI2C_CTRL_CLK	<=	~mI2C_CTRL_CLK; // Toggle generated clock
			end
		end
end

// Generate single-cycle tick enable for state machine
assign i2c_tick = (mI2C_CLK_DIV == (CLK_Freq/I2C_Freq)/2);

always @(posedge iCLK or negedge iRST_N) begin
    if (!iRST_N) begin
        i2c_tick_en <= 1'b0;
    end else begin
        i2c_tick_en <= i2c_tick; // Capture the tick for one cycle
    end
end

// State Machine Logic (now synchronous to iCLK, enabled by i2c_tick_en)
wire		mI2C_END;
wire		mI2C_ACK;
reg	[1:0]	mSetup_ST;
reg			mI2C_GO;
reg			mI2C_WR;

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
		begin
		Config_Done <= 0;
		LUT_INDEX	<=	0;
		mSetup_ST	<=	0;
		mI2C_GO		<=	0;
		mI2C_WR     <=	0;
		end
	else if(i2c_tick_en) // Use synchronous enable
		begin
		if(LUT_INDEX < LUT_SIZE)
			begin
			Config_Done <= 0;
			case(mSetup_ST)
			0:	begin
				// Assuming mI2C_END is synchronous to iCLK or properly synchronized
				if(~mI2C_END)
					mSetup_ST	<=	1;
				else
					mSetup_ST	<=	0;
				mI2C_GO		<=	1;
				if(LUT_INDEX < 8'd2)
					mI2C_WR <= 0;
				else
					mI2C_WR <= 1;
				end
			1:
				begin
				// Assuming mI2C_END and mI2C_ACK are synchronous to iCLK or properly synchronized
				if(mI2C_END)
					begin
					mI2C_WR     <=	0;
					mI2C_GO		<=	0;
					if(~mI2C_ACK)
						mSetup_ST	<=	2;
					else
						mSetup_ST	<=	0;
					end
                else begin
                    // Keep GO/WR active if END is not yet asserted
                    mI2C_GO <= mI2C_GO;
                    mI2C_WR <= mI2C_WR;
                    mSetup_ST <= mSetup_ST; // Stay in state 1
                end
				end
			2:	begin
				LUT_INDEX	<=	LUT_INDEX + 8'd1;
				mSetup_ST	<=	0;
				mI2C_GO		<=	0;
				mI2C_WR     <=	0;
				end
            default: begin
                 mSetup_ST <= 0;
                 mI2C_GO <= 0;
                 mI2C_WR <= 0;
            end
			endcase
			end
		else
			begin
			Config_Done <= 1'b1;
			LUT_INDEX 	<= LUT_INDEX; // Hold value
			mSetup_ST	<=	0;
			mI2C_GO		<=	0;
			mI2C_WR     <=	0;
			end
	end
    else begin // If not enabled, hold state (added else to prevent latch generation)
        Config_Done <= Config_Done;
        LUT_INDEX   <= LUT_INDEX;
        mSetup_ST   <= mSetup_ST;
        mI2C_GO     <= mI2C_GO;
        mI2C_WR     <= mI2C_WR;
    end
end

wire	[15:0]	LUT_DATA;
I2C_OV7670_RGB565_Config	u_I2C_OV7725_RGB565_Config
(
	.LUT_INDEX		(LUT_INDEX),
	.LUT_DATA		(LUT_DATA)
);

// DFT Clock and Enable Muxing for I2C_Controller
wire dft_mI2C_CTRL_CLK;
wire dft_i2c_en;

// Use primary clock iCLK during test mode, otherwise use generated clock
assign dft_mI2C_CTRL_CLK = test_i ? iCLK : mI2C_CTRL_CLK;
// Enable controller during test mode, otherwise use functional enable
assign dft_i2c_en = test_i ? 1'b1 : i2c_tick_en; // Use the synchronous tick enable

I2C_Controller 	u_I2C_Controller
(
	.iCLK			(iCLK), // Keep original primary clock connection if needed internally
	.iRST_N			(iRST_N),
	.I2C_CLK		(dft_mI2C_CTRL_CLK), // Use muxed clock
	.I2C_EN			(dft_i2c_en),        // Use muxed enable
	.I2C_WDATA		({8'h42, LUT_DATA}),
	.I2C_SCLK		(I2C_SCLK),
	.I2C_SDAT		(I2C_SDAT),
	.GO				(mI2C_GO),
	.WR				(mI2C_WR),
	.ACK			(mI2C_ACK), // Output from controller
	.END			(mI2C_END), // Output from controller
	.I2C_RDATA		(I2C_RDATA) // Output from controller
);
endmodule