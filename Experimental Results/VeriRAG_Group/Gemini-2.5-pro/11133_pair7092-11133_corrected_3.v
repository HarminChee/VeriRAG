module AUDIO_DAC (	//	Memory Side
					oFLASH_ADDR,iFLASH_DATA,
					oSDRAM_ADDR,iSDRAM_DATA,
					oSRAM_ADDR,iSRAM_DATA,
					//	Audio Side
					oAUD_BCK,
					oAUD_DATA,
					oAUD_LRCK,
					//	Control Signals
					test_mode_i, // Added for DFT
					iSrc_Select,
				    iCLK_18_4,
					iRST_N	);

parameter	REF_CLK			=	18432000;	//	18.432	MHz
parameter	SAMPLE_RATE		=	48000;		//	48		KHz
parameter	DATA_WIDTH		=	16;			//	16		Bits
parameter	CHANNEL_NUM		=	2;			//	Dual Channel

parameter	SIN_SAMPLE_DATA	=	48;
parameter	FLASH_DATA_NUM	=	1048576;	//	1	MWords
parameter	SDRAM_DATA_NUM	=	4194304;	//	4	MWords
parameter	SRAM_DATA_NUM	=	262144;		//	256	KWords

parameter	FLASH_ADDR_WIDTH=	20;			//	20	Address Line
parameter	SDRAM_ADDR_WIDTH=	22;			//	22	Address Line
parameter	SRAM_ADDR_WIDTH=	18;			//	18	Address	Line

parameter	FLASH_DATA_WIDTH=	8;			//	8	Bits
parameter	SDRAM_DATA_WIDTH=	16;			//	16	Bits
parameter	SRAM_DATA_WIDTH=	16;			//	16	Bits

////////////	Input Source Number	//////////////
parameter	SIN_SANPLE		=	0;
parameter	FLASH_DATA		=	1;
parameter	SDRAM_DATA		=	2;
parameter	SRAM_DATA		=	3;
//////////////////////////////////////////////////
//	Memory Side
output	[FLASH_ADDR_WIDTH-1:0]	oFLASH_ADDR;
input	[FLASH_DATA_WIDTH-1:0]	iFLASH_DATA;
output	[SDRAM_ADDR_WIDTH-1:0]	oSDRAM_ADDR;
input	[SDRAM_DATA_WIDTH-1:0]	iSDRAM_DATA;
output	[SRAM_ADDR_WIDTH-1:0]	oSRAM_ADDR;
input	[SRAM_DATA_WIDTH-1:0]	iSRAM_DATA;
//	Audio Side
output			oAUD_DATA;
output			oAUD_LRCK;
output			oAUD_BCK;
//	Control Signals
input			test_mode_i; // Added for DFT
input	[1:0]	iSrc_Select;
input			iCLK_18_4;
input			iRST_N;
//	Internal Registers and Wires
reg		oAUD_BCK_reg; // Internal register for oAUD_BCK
assign	oAUD_BCK	= oAUD_BCK_reg; // Assign output from internal register

// Clock divider constants (Example values, adjust as needed)
localparam BCK_DIV_MAX  = (REF_CLK / (SAMPLE_RATE * DATA_WIDTH * CHANNEL_NUM) / 2) - 1;
localparam LRCK_DIV_MAX = (REF_CLK / (SAMPLE_RATE * 2)) - 1;

reg		[15:0]	BCK_DIV_count; // Adjust width based on BCK_DIV_MAX
reg		[15:0]	LRCK_DIV_count; // Adjust width based on LRCK_DIV_MAX

////////	DATA Counter	////////
reg		[5:0]	SIN_Cont; // Assuming max 48 samples
reg		[FLASH_ADDR_WIDTH-1:0]	FLASH_Cont;
reg		[SDRAM_ADDR_WIDTH-1:0]	SDRAM_Cont;
reg		[SRAM_ADDR_WIDTH-1:0]	SRAM_Cont;
////////////////////////////////////
reg		[DATA_WIDTH-1:0]	Sin_Out; // Placeholder for Sin wave data
reg		[DATA_WIDTH-1:0]	FLASH_Out_Tmp;
reg		[DATA_WIDTH-1:0]	SDRAM_Out_Tmp;
reg		[DATA_WIDTH-1:0]	SRAM_Out_Tmp;
reg							LRCK_1X; // Represents the sample clock
reg                         flash_byte_flag; // For 8-bit FLASH data assembly

// New registers for data selection and serialization
reg     [DATA_WIDTH-1:0]    Audio_Data_Selected;
reg     [DATA_WIDTH-1:0]    Audio_Shift_Reg;
reg     [4:0]               Bit_Counter; // Counter for DATA_WIDTH bits (needs 5 bits for 16)

// DFT Clock Mux Wires
wire dft_clk_LRCK_1X;
// wire dft_clk_LRCK_2X; // Not used in simplified logic
// wire dft_clk_LRCK_4X; // Not used in simplified logic
wire dft_clk_oAUD_BCK;

// DFT Clock Mux Assignments
assign dft_clk_LRCK_1X  = test_mode_i ? iCLK_18_4 : LRCK_1X;
// assign dft_clk_LRCK_2X  = test_mode_i ? iCLK_18_4 : LRCK_2X; // Not used
// assign dft_clk_LRCK_4X  = test_mode_i ? iCLK_18_4 : LRCK_4X; // Not used
assign dft_clk_oAUD_BCK = test_mode_i ? iCLK_18_4 : oAUD_BCK_reg;

// Clock Generation Logic
always @(posedge iCLK_18_4 or negedge iRST_N) begin
    if (!iRST_N) begin
        BCK_DIV_count <= 16'b0;
        LRCK_DIV_count <= 16'b0;
        oAUD_BCK_reg <= 1'b0;
        LRCK_1X <= 1'b0;
    end else begin
        // BCK Generation
        if (BCK_DIV_count == BCK_DIV_MAX) begin
            BCK_DIV_count <= 16'b0;
            oAUD_BCK_reg <= ~oAUD_BCK_reg;
        end else begin
            BCK_DIV_count <= BCK_DIV_count + 1;
        end

        // LRCK Generation (Sample Clock)
        if (LRCK_DIV_count == LRCK_DIV_MAX) begin
            LRCK_DIV_count <= 16'b0;
            LRCK_1X <= ~LRCK_1X;
        end else begin
            LRCK_DIV_count <= LRCK_DIV_count + 1;
        end
    end
end

// Address Counters & Input Data Latching (Clocked by LRCK_1X)
always @(posedge dft_clk_LRCK_1X or negedge iRST_N) begin // Use MUXed clock
    if (!iRST_N) begin
        SIN_Cont <= 6'b0;
        FLASH_Cont <= {FLASH_ADDR_WIDTH{1'b0}};
        SDRAM_Cont <= {SDRAM_ADDR_WIDTH{1'b0}};
        SRAM_Cont <= {SRAM_ADDR_WIDTH{1'b0}};
        flash_byte_flag <= 1'b0;
        FLASH_Out_Tmp <= {DATA_WIDTH{1'b0}};
        SDRAM_Out_Tmp <= {DATA_WIDTH{1'b0}};
        SRAM_Out_Tmp <= {DATA_WIDTH{1'b0}};
        Sin_Out <= {DATA_WIDTH{1'b0}}; // Initialize Sin_Out if registered here
    end else begin
        // Increment counters at the start of a new sample (e.g., rising edge of LRCK)
        SIN_Cont <= (SIN_Cont == SIN_SAMPLE_DATA - 1) ? 6'b0 : SIN_Cont + 1;
        FLASH_Cont <= FLASH_Cont + 1; // Simple increment, wrap-around handled by size
        SDRAM_Cont <= SDRAM_Cont + 1; // Simple increment
        SRAM_Cont <= SRAM_Cont + 1;   // Simple increment

        // Latch external memory data
        SDRAM_Out_Tmp <= iSDRAM_DATA;
        SRAM_Out_Tmp <= iSRAM_DATA;

        // FLASH data assembly (assuming read happens before this clock edge)
        if (flash_byte_flag) begin // Assemble second byte
            FLASH_Out_Tmp <= {iFLASH_DATA, FLASH_Out_Tmp[DATA_WIDTH-1:8]};
        end else begin // Store first byte
             FLASH_Out_Tmp[DATA_WIDTH-1:8] <= iFLASH_DATA;
        end
        flash_byte_flag <= ~flash_byte_flag;

        // Generate Sin wave data (Example: simple counter for illustration)
        // Replace with actual Sin ROM lookup or generation logic
        Sin_Out <= Sin_Out + 1;
    end
end

// Data Selection Logic (Combinational or clocked - let's make it clocked by LRCK_1X)
always @(posedge dft_clk_LRCK_1X or negedge iRST_N) begin // Use MUXed clock
    if (!iRST_N) begin
        Audio_Data_Selected <= {DATA_WIDTH{1'b0}};
    end else begin
        // Select based on iSrc_Select at the start of each sample
        case (iSrc_Select)
            SIN_SANPLE: Audio_Data_Selected <= Sin_Out;
            FLASH_DATA: Audio_Data_Selected <= FLASH_Out_Tmp;
            SDRAM_DATA: Audio_Data_Selected <= SDRAM_Out_Tmp;
            SRAM_DATA:  Audio_Data_Selected <= SRAM_Out_Tmp;
            default:    Audio_Data_Selected <= {DATA_WIDTH{1'b0}};
        endcase
    end
end


// Data Serialization (Clocked by oAUD_BCK_reg)
assign oAUD_DATA = Audio_Shift_Reg[DATA_WIDTH-1]; // Output MSB
assign oAUD_LRCK = LRCK_1X; // Assign generated sample clock to output

always @(posedge dft_clk_oAUD_BCK or negedge iRST_N) begin // Use MUXed clock
    if (!iRST_N) begin
        Audio_Shift_Reg <= {DATA_WIDTH{1'b0}};
        Bit_Counter <= 5'b0;
    end else begin
        // Load new data when LRCK changes (assume load happens when LRCK is high for left channel, low for right)
        // This requires careful synchronization with LRCK edge and BCK edge
        // Simplified: Load when Bit_Counter resets (end of previous word)
        if (Bit_Counter == DATA_WIDTH*CHANNEL_NUM -1 ) begin // Check end of full sample period
             Bit_Counter <= 5'b0;
             // Reloading might happen based on LRCK edge, handled in Data Selection block
             // Here we just shift
             Audio_Shift_Reg <= {Audio_Shift_Reg[DATA_WIDTH-2:0], 1'b0}; // Shift left
        end
        // Simplified load mechanism triggered by LRCK: Use a flag or check LRCK edge carefully
        // Let's assume Audio_Data_Selected is stable for the duration needed
        else if (Bit_Counter == 0 || Bit_Counter == DATA_WIDTH) begin // Reload at start of L/R channel data
             Audio_Shift_Reg <= Audio_Data_Selected; // Load selected data (simplified)
             Bit_Counter <= Bit_Counter + 1;
        end
         else begin
             Audio_Shift_Reg <= {Audio_Shift_Reg[DATA_WIDTH-2:0], 1'b0}; // Shift left
             Bit_Counter <= Bit_Counter + 1;
        end
    end
end

// Memory Address Outputs (Combinational assignments)
assign oFLASH_ADDR = FLASH_Cont;
assign oSDRAM_ADDR = SDRAM_Cont;
assign oSRAM_ADDR = SRAM_Cont;

endmodule