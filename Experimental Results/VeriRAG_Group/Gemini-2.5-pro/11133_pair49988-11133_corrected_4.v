module AUDIO_DAC
#(
    parameter	REF_CLK			=	18432000,	//	18.432	MHz
    parameter	SAMPLE_RATE		=	48000,		//	48		KHz
    parameter	DATA_WIDTH		=	16,			//	16		Bits
    parameter	CHANNEL_NUM		=	2,			//	Dual Channel

    parameter	SIN_SAMPLE_DATA	=	48,
    parameter	FLASH_DATA_NUM	=	1048576,	//	1	MWords
    parameter	SDRAM_DATA_NUM	=	4194304,	//	4	MWords
    parameter	SRAM_DATA_NUM	=	262144,		//	256	KWords

    parameter	FLASH_ADDR_WIDTH=	20,			//	20	Address Line
    parameter	SDRAM_ADDR_WIDTH=	22,			//	22	Address Line
    parameter	SRAM_ADDR_WIDTH=	18,			//	18	Address	Line

    parameter	FLASH_DATA_WIDTH=	8,			//	8	Bits
    parameter	SDRAM_DATA_WIDTH=	16,			//	16	Bits
    parameter	SRAM_DATA_WIDTH=	16,			//	16	Bits

    ////////////	Input Source Number	//////////////
    parameter	SIN_SANPLE		=	0,
    parameter	FLASH_DATA		=	1,
    parameter	SDRAM_DATA		=	2,
    parameter	SRAM_DATA		=	3
)
(	//	Memory Side
    output	reg [FLASH_ADDR_WIDTH-1:0]	oFLASH_ADDR,
    input	[FLASH_DATA_WIDTH-1:0]	iFLASH_DATA,
    output	reg [SDRAM_ADDR_WIDTH-1:0]	oSDRAM_ADDR,
    input	[SDRAM_DATA_WIDTH-1:0]	iSDRAM_DATA,
    output	reg [SRAM_ADDR_WIDTH-1:0]	oSRAM_ADDR,
    input	[SRAM_DATA_WIDTH-1:0]	iSRAM_DATA,
    //	Audio Side
    output							oAUD_BCK,
    output	reg                     oAUD_DATA,
    output							oAUD_LRCK,
    //	Control Signals
    input	[1:0]					iSrc_Select,
    input							iCLK_18_4, // Primary Clock
    input							iRST_N,    // Primary Async Reset
    input 							test_i     // DFT test mode signal
);

// Calculate divider values based on parameters
localparam BCK_CYCLES_PER_LRCK = DATA_WIDTH * CHANNEL_NUM;
// Ensure division by zero doesn't occur if parameters lead to it
localparam BCK_RATE_HZ = SAMPLE_RATE * BCK_CYCLES_PER_LRCK;
localparam BCK_DIV_VAL = (BCK_RATE_HZ == 0) ? 1 : (REF_CLK / (BCK_RATE_HZ * 2)) - 1; // Divide by 2 for toggle rate, ensure > 0
localparam LRCK_RATE_HZ = SAMPLE_RATE;
localparam LRCK_DIV_VAL = (LRCK_RATE_HZ == 0) ? 1 : (REF_CLK / (LRCK_RATE_HZ * 2)) - 1; // Divide by 2 for toggle rate, ensure > 0

// Check if calculated divider values are valid (non-blocking display)
// initial begin
//     if (BCK_RATE_HZ == 0 || BCK_DIV_VAL < 0) $display("Warning: REF_CLK potentially too slow for desired BCK rate or invalid parameters.");
//     if (LRCK_RATE_HZ == 0 || LRCK_DIV_VAL < 0) $display("Warning: REF_CLK potentially too slow for desired SAMPLE_RATE or invalid parameters.");
// end

// Internal counters for clock generation
localparam BCK_CNT_WIDTH = (BCK_DIV_VAL < 1) ? 1 : $clog2(BCK_DIV_VAL+1);
localparam LRCK_CNT_WIDTH = (LRCK_DIV_VAL < 1) ? 1 : $clog2(LRCK_DIV_VAL+1);
reg [BCK_CNT_WIDTH-1:0] bck_div_cnt;
reg [LRCK_CNT_WIDTH-1:0] lrck_div_cnt;

// Internal clock signals (registered outputs of dividers)
reg rAUD_BCK_int;
reg rAUD_LRCK_int;

// DFT Muxed Clocks
wire dft_AUD_BCK;
wire dft_AUD_LRCK;

// Clock Generation Logic (using primary clock and reset)
always @(posedge iCLK_18_4 or negedge iRST_N) begin
    if (!iRST_N) begin
        bck_div_cnt <= {BCK_CNT_WIDTH{1'b0}};
        lrck_div_cnt <= {LRCK_CNT_WIDTH{1'b0}};
        rAUD_BCK_int <= 1'b0;
        rAUD_LRCK_int <= 1'b0;
    end else begin
        // BCK generation
        if (BCK_DIV_VAL == 0) begin // Handle case where divider is 0 (max rate)
             rAUD_BCK_int <= ~rAUD_BCK_int; // Toggle every clock cycle
             bck_div_cnt <= {BCK_CNT_WIDTH{1'b0}}; // Keep counter at 0
        end else if (bck_div_cnt == BCK_DIV_VAL) begin
            bck_div_cnt <= {BCK_CNT_WIDTH{1'b0}};
            rAUD_BCK_int <= ~rAUD_BCK_int;
        end else begin
            bck_div_cnt <= bck_div_cnt + 1;
        end

        // LRCK generation
        if (LRCK_DIV_VAL == 0) begin // Handle case where divider is 0
             rAUD_LRCK_int <= ~rAUD_LRCK_int; // Toggle every clock cycle
             lrck_div_cnt <= {LRCK_CNT_WIDTH{1'b0}}; // Keep counter at 0
        end else if (lrck_div_cnt == LRCK_DIV_VAL) begin
            lrck_div_cnt <= {LRCK_CNT_WIDTH{1'b0}};
            rAUD_LRCK_int <= ~rAUD_LRCK_int;
        end else begin
            lrck_div_cnt <= lrck_div_cnt + 1;
        end
    end
end

// Assign internal clocks to outputs
assign oAUD_BCK = rAUD_BCK_int;
assign oAUD_LRCK = rAUD_LRCK_int;

// DFT Clock Muxing
assign dft_AUD_BCK = test_i ? iCLK_18_4 : rAUD_BCK_int;
assign dft_AUD_LRCK = test_i ? iCLK_18_4 : rAUD_LRCK_int;

// Placeholder for Sin wave table (needs definition if SIN_SANPLE is used)
reg [DATA_WIDTH-1:0] sin_table [0:SIN_SAMPLE_DATA-1];
// initial begin
//     // Populate sin_table - example: simple ramp for demonstration
//     integer i;
//     for (i = 0; i < SIN_SAMPLE_DATA; i = i + 1) begin
//         sin_table[i] = i * ( (1 << DATA_WIDTH) / SIN_SAMPLE_DATA );
//     end
// end

// Data source selection and address generation
localparam SIN_CONT_WIDTH = $clog2(SIN_SAMPLE_DATA);
reg [SIN_CONT_WIDTH-1:0] SIN_Cont;
reg [DATA_WIDTH-1:0] current_data_word;
reg data_load_req; // Flag to load next data word
reg [DATA_WIDTH-1:0] next_data_word_comb; // Combinational logic for next data

// Address/Data Counter Logic (clocked by dft_AUD_LRCK falling edge)
always @(negedge dft_AUD_LRCK or negedge iRST_N) begin
    if (!iRST_N) begin
        oFLASH_ADDR <= {FLASH_ADDR_WIDTH{1'b0}};
        oSDRAM_ADDR <= {SDRAM_ADDR_WIDTH{1'b0}};
        oSRAM_ADDR  <= {SRAM_ADDR_WIDTH{1'b0}};
        SIN_Cont    <= {SIN_CONT_WIDTH{1'b0}};
        data_load_req <= 1'b1; // Request load on first cycle
    end else begin
        data_load_req <= 1'b1; // Request load every LRCK cycle (at falling edge)
        case(iSrc_Select)
            SIN_SANPLE: begin
                if (SIN_Cont == SIN_SAMPLE_DATA - 1)
                    SIN_Cont <= {SIN_CONT_WIDTH{1'b0}};
                else
                    SIN_Cont <= SIN_Cont + 1;
                 // Address regs remain unchanged
                 oFLASH_ADDR <= oFLASH_ADDR;
                 oSDRAM_ADDR <= oSDRAM_ADDR;
                 oSRAM_ADDR  <= oSRAM_ADDR;
            end
            FLASH_DATA: begin
                localparam FLASH_READS_PER_WORD = (FLASH_DATA_WIDTH==0) ? 1 : (DATA_WIDTH + FLASH_DATA_WIDTH - 1) / FLASH_DATA_WIDTH;
                // Check bounds carefully, assuming FLASH_DATA_NUM is in words of FLASH_DATA_WIDTH
                localparam FLASH_ADDR_LIMIT = (FLASH_DATA_NUM * FLASH_DATA_WIDTH) / 8; // Example limit in bytes if needed
                 if (oFLASH_ADDR >= FLASH_DATA_NUM - FLASH_READS_PER_WORD) // Check based on number of reads needed
                     oFLASH_ADDR <= {FLASH_ADDR_WIDTH{1'b0}};
                else
                     oFLASH_ADDR <= oFLASH_ADDR + FLASH_READS_PER_WORD; // Increment address for next word
                 // Other address regs remain unchanged
                 SIN_Cont <= SIN_Cont;
                 oSDRAM_ADDR <= oSDRAM_ADDR;
                 oSRAM_ADDR  <= oSRAM_ADDR;
            end
            SDRAM_DATA: begin
                 if (oSDRAM_ADDR == SDRAM_DATA_NUM - 1)
                     oSDRAM_ADDR <= {SDRAM_ADDR_WIDTH{1'b0}};
                 else
                     oSDRAM_ADDR <= oSDRAM_ADDR + 1; // Fixed increment
                 // Other address regs remain unchanged
                 SIN_Cont <= SIN_Cont;
                 oFLASH_ADDR <= oFLASH_ADDR;
                 oSRAM_ADDR  <= oSRAM_ADDR;
            end
            SRAM_DATA: begin // Added SRAM case
                 if (oSRAM_ADDR == SRAM_DATA_NUM - 1)
                     oSRAM_ADDR <= {SRAM_ADDR_WIDTH{1'b0}};
                 else
                     oSRAM_ADDR <= oSRAM_ADDR + 1;
                 // Other address regs remain unchanged
                 SIN_Cont <= SIN_Cont;
                 oFLASH_ADDR <= oFLASH_ADDR;
                 oSDRAM_ADDR <= oSDRAM_ADDR;
            end
            default: begin // Added default case
                oFLASH_ADDR <= oFLASH_ADDR;
                oSDRAM_ADDR <= oSDRAM_ADDR;
                oSRAM_ADDR  <= oSRAM_ADDR;
                SIN_Cont    <= SIN_Cont;
                data_load_req <= 1'b0; // Don't load if selection is invalid
            end
        endcase
    end
end

// Combinational logic to determine the next data word based on source and address/counter
// Note: FLASH requires assembling data if FLASH_DATA_WIDTH < DATA_WIDTH. This is simplified.
always_comb begin
    case(iSrc_Select)
        SIN_SANPLE: next_data_word_comb = sin_table[SIN_Cont]; // Assumes sin_table is populated
        FLASH_DATA: next_data_word_comb = (FLASH_DATA_WIDTH >= DATA_WIDTH) ? iFLASH_DATA[DATA_WIDTH-1:0] : {DATA_WIDTH{1'bx}}; // Simplified/Placeholder - Needs proper multi-byte read logic if FLASH_DATA_WIDTH < DATA_WIDTH
        SDRAM_DATA: next_data_word_comb = i