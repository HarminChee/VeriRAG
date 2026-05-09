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
localparam BCK_CYCLES_PER_LRCK = (DATA_WIDTH == 0 || CHANNEL_NUM == 0) ? 1 : DATA_WIDTH * CHANNEL_NUM; // Avoid 0
localparam BCK_RATE_HZ = SAMPLE_RATE * BCK_CYCLES_PER_LRCK;
localparam BCK_DIV_VAL = (BCK_RATE_HZ == 0 || REF_CLK < (BCK_RATE_HZ * 2)) ? 0 : (REF_CLK / (BCK_RATE_HZ * 2)) - 1; // Divide by 2 for toggle rate, ensure non-negative
localparam LRCK_RATE_HZ = SAMPLE_RATE;
localparam LRCK_DIV_VAL = (LRCK_RATE_HZ == 0 || REF_CLK < (LRCK_RATE_HZ * 2)) ? 0 : (REF_CLK / (LRCK_RATE_HZ * 2)) - 1; // Divide by 2 for toggle rate, ensure non-negative

// Internal counters for clock generation
localparam BCK_CNT_WIDTH = (BCK_DIV_VAL < 1) ? 1 : $clog2(BCK_DIV_VAL+1);
localparam LRCK_CNT_WIDTH = (LRCK_DIV_VAL < 1) ? 1 : $clog2(LRCK_DIV_VAL+1);
reg [BCK_CNT_WIDTH-1:0] bck_div_cnt;
reg [LRCK_CNT_WIDTH-1:0] lrck_div_cnt;

// Internal clock signals (registered outputs of dividers)
reg rAUD_BCK_int;
reg rAUD_LRCK_int;
reg rAUD_LRCK_int_d1; // Delayed LRCK for edge detection in BCK domain

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
        if (BCK_DIV_VAL == 0) begin // Handle case where divider is 0 (max rate or invalid params)
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
// Example: reg [DATA_WIDTH-1:0] sin_table [0:SIN_SAMPLE_DATA-1];
// initial begin
//     // Populate sin_table here if needed for simulation
//     integer i;
//     for (i = 0; i < SIN_SAMPLE_DATA; i = i + 1) begin
//         sin_table[i] = i * ( (1 << DATA_WIDTH) / SIN_SAMPLE_DATA );
//     end
// end
// Use a default value if table is not defined/populated
reg [DATA_WIDTH-1:0] sin_table [0:SIN_SAMPLE_DATA-1];


// Data source selection and address generation
localparam SIN_CONT_WIDTH = (SIN_SAMPLE_DATA==0)? 1 : $clog2(SIN_SAMPLE_DATA);
reg [SIN_CONT_WIDTH-1:0] SIN_Cont;
reg data_load_req; // Flag to load next data word
wire [DATA_WIDTH-1:0] next_data_word_comb; // Combinational logic for next data
reg [DATA_WIDTH-1:0] current_data_word_left;
reg [DATA_WIDTH-1:0] current_data_word_right; // Assuming stereo


// Address/Counter Logic and Data Loading Trigger
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
                if (SIN_SAMPLE_DATA > 0) begin // Avoid modulo by zero
                    if (SIN_Cont == SIN_SAMPLE_DATA - 1)
                        SIN_Cont <= {SIN_CONT_WIDTH{1'b0}};
                    else
                        SIN_Cont <= SIN_Cont + 1;
                end else begin
                    SIN_Cont <= {SIN_CONT_WIDTH{1'b0}};
                end
                 oFLASH_ADDR <= oFLASH_ADDR;
                 oSDRAM_ADDR <= oSDRAM_ADDR;
                 oSRAM_ADDR  <= oSRAM_ADDR;
            end
            FLASH_DATA: begin
                localparam FLASH_READS_PER_WORD = (FLASH_DATA_WIDTH==0) ? 1 : (DATA_WIDTH + FLASH_DATA_WIDTH - 1) / FLASH_DATA_WIDTH;
                // Check bounds carefully
                 if (FLASH_DATA_NUM > 0 && oFLASH_ADDR >= FLASH_DATA_NUM - FLASH_READS_PER_WORD)
                     oFLASH_ADDR <= {FLASH_ADDR_WIDTH{1'b0}};
                else if (FLASH_DATA_NUM > 0)
                     oFLASH_ADDR <= oFLASH_ADDR + FLASH_READS_PER_WORD; // Increment address for next word
                else
                     oFLASH_ADDR <= {FLASH_ADDR_WIDTH{1'b0}};

                 SIN_Cont <= SIN_Cont;
                 oSDRAM_ADDR <= oSDRAM_ADDR;
                 oSRAM_ADDR  <= oSRAM_ADDR;
            end
            SDRAM_DATA: begin
                 if (SDRAM_DATA_NUM > 0 && oSDRAM_ADDR == SDRAM_DATA_NUM - 1)
                     oSDRAM_ADDR <= {SDRAM_ADDR_WIDTH{1'b0}};
                 else if (SDRAM_DATA_NUM > 0)
                     oSDRAM_ADDR <= oSDRAM_ADDR + 1;
                 else
                     oSDRAM_ADDR <= {SDRAM_ADDR_WIDTH{1'b0}};

                 SIN_Cont <= SIN_Cont;
                 oFLASH_ADDR <= oFLASH_ADDR;
                 oSRAM_ADDR  <= oSRAM_ADDR;
            end
            SRAM_DATA: begin
                 if (SRAM_DATA_NUM > 0 && oSRAM_ADDR == SRAM_DATA_NUM - 1)
                     oSRAM_ADDR <= {SRAM_ADDR_WIDTH{1'b0}};
                 else if (SRAM_DATA_NUM > 0)
                     oSRAM_ADDR <= oSRAM_ADDR + 1;
                 else
                     oSRAM_ADDR <= {SRAM_ADDR_WIDTH{1'b0}};

                 SIN_Cont <= SIN_Cont;
                 oFLASH_ADDR <= oFLASH_ADDR;
                 oSDRAM_ADDR <= oSDRAM_ADDR;
            end
            default: begin
                oFLASH_ADDR <= oFLASH_ADDR;
                oSDRAM_ADDR <= oSDRAM_ADDR;
                oSRAM_ADDR  <= oSRAM_ADDR;
                SIN_Cont    <= SIN_