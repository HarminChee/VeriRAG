`timescale 1ps/1ps
`timescale 1ps/1ps
module mmcme2_drp
 #(
      parameter DIV_F          = 5
   )
   (
      input             SEN,
      input             SCLK,
      input             RST,
      output reg        SRDY,
		input 	[35:0]	S1_CLKOUT0,
		input 	[35:0]	S1_CLKFBOUT,
		input 	[13:0]	S1_DIVCLK,
		input 	[39:0]	S1_LOCK,
		input 	[9:0]		S1_DIGITAL_FILT,
		input					REF_CLK,
		output				PXL_CLK,
		output				CLKFBOUT_O,
		input				CLKFBOUT_I,
		output				LOCKED_O
   );
   localparam  TCQ = 100;
   wire [38:0]  rom [12:0];  
   reg [3:0]   rom_addr;
   reg [38:0]  rom_do;
   reg         next_srdy;
   reg [3:0]   next_rom_addr;
   reg [6:0]   next_daddr;
   reg         next_dwe;
   reg         next_den;
   reg         next_rst_mmcm;
   reg [15:0]  next_di;
   wire      [15:0] DO;
   wire             DRDY;
   wire             LOCKED;
   reg        		  DWE;
   reg        		  DEN;
   reg [6:0]  		  DADDR;
   reg [15:0] 		  DI;
   wire             DCLK;
   reg        		  RST_MMCM;
   assign DCLK = SCLK;
      assign rom[0] = {7'h28, 16'h0000, 16'hFFFF};
      assign rom[1]  =  {7'h08, 16'h1000, S1_CLKOUT0[15:0]};
      assign rom[2]  =  {7'h09, 16'h8000, S1_CLKOUT0[31:16]};
      assign rom[3] = {7'h07, 16'hC3FF, 2'b00 , S1_CLKOUT0[35:32], 10'h000}; 
      assign rom[4] = {7'h13, 16'hC3FF, 2'b00 , S1_CLKFBOUT[35:32], 10'h000};
      assign rom[5] = {7'h16, 16'hC000, {2'h0, S1_DIVCLK[13:0]} };
      assign rom[6] = {7'h14, 16'h1000, S1_CLKFBOUT[15:0]};
      assign rom[7] = {7'h15, 16'h8000, S1_CLKFBOUT[31:16]};
      assign rom[8] = {7'h18, 16'hFC00, {6'h00, S1_LOCK[29:20]} };
      assign rom[9] = {7'h19, 16'h8000, {1'b0 , S1_LOCK[34:30], S1_LOCK[9:0]} };
      assign rom[10] = {7'h1A, 16'h8000, {1'b0 , S1_LOCK[39:35], S1_LOCK[19:10]} };
      assign rom[11] = {7'h4E, 16'h66FF, 
                S1_DIGITAL_FILT[9], 2'h0, S1_DIGITAL_FILT[8:7], 2'h0, 
                S1_DIGITAL_FILT[6], 8'h00 };
      assign rom[12] = {7'h4F, 16'h666F, 
                S1_DIGITAL_FILT[5], 2'h0, S1_DIGITAL_FILT[4:3], 2'h0,
                S1_DIGITAL_FILT[2:1], 2'h0, S1_DIGITAL_FILT[0], 4'h0 };
   always @(posedge SCLK) begin
      rom_do<= #TCQ rom[rom_addr];
   end
   localparam RESTART      = 4'h1;
   localparam WAIT_LOCK    = 4'h2;
   localparam WAIT_SEN     = 4'h3;
   localparam ADDRESS      = 4'h4;
   localparam WAIT_A_DRDY  = 4'h5;
   localparam BITMASK      = 4'h6;
   localparam BITSET       = 4'h7;
   localparam WRITE        = 4'h8;
   localparam WAIT_DRDY    = 4'h9;
   reg [3:0]  current_state   = RESTART;
   reg [3:0]  next_state      = RESTART;
   localparam STATE_COUNT_CONST  = 13;
   reg [3:0] state_count         = STATE_COUNT_CONST; 
   reg [3:0] next_state_count    = STATE_COUNT_CONST;
   always @(posedge SCLK) begin
      DADDR       <= #TCQ next_daddr;
      DWE         <= #TCQ next_dwe;
      DEN         <= #TCQ next_den;
      RST_MMCM    <= #TCQ next_rst_mmcm;
      DI          <= #TCQ next_di;
      SRDY        <= #TCQ next_srdy;
      rom_addr    <= #TCQ next_rom_addr;
      state_count <= #TCQ next_state_count;
   end
   always @(posedge SCLK) begin
      if(RST) begin
         current_state <= #TCQ RESTART;
      end else begin
         current_state <= #TCQ next_state;
      end
   end
   always @* begin
      next_srdy         = 1'b0;
      next_daddr        = DADDR;
      next_dwe          = 1'b0;
      next_den          = 1'b0;
      next_rst_mmcm     = RST_MMCM;
      next_di           = DI;
      next_rom_addr     = rom_addr;
      next_state_count  = state_count;
      case (current_state)
         RESTART: begin
            next_daddr     = 7'h00;
            next_di        = 16'h0000;
            next_rom_addr  = 6'h00;
            next_rst_mmcm  = 1'b1;
            next_state     = WAIT_LOCK;
         end
         WAIT_LOCK: begin
            next_rst_mmcm   = 1'b0;
            next_state_count = STATE_COUNT_CONST ;
            if(LOCKED) begin
               next_state  = WAIT_SEN;
               next_srdy   = 1'b1;
            end else begin
               next_state  = WAIT_LOCK;
            end
         end
         WAIT_SEN: begin
            if (SEN) begin
					next_rom_addr = 8'h00;
               next_state = ADDRESS;
            end else begin
               next_state = WAIT_SEN;
            end
         end
         ADDRESS: begin
            next_rst_mmcm  = 1'b1;
            next_den       = 1'b1;
            next_daddr     = rom_do[38:32];
            next_state     = WAIT_A_DRDY;
         end
         WAIT_A_DRDY: begin
            if (DRDY) begin
               next_state = BITMASK;
            end else begin
               next_state = WAIT_A_DRDY;
            end
         end
         BITMASK: begin
            next_di     = rom_do[31:16] & DO;
            next_state  = BITSET;
         end
         BITSET: begin
            next_di           = rom_do[15:0] | DI;
            next_rom_addr     = rom_addr + 1'b1;
            next_state        = WRITE;
         end
         WRITE: begin
            next_dwe          = 1'b1;
            next_den          = 1'b1;
            next_state_count  = state_count - 1'b1;
            next_state        = WAIT_DRDY;
         end
         WAIT_DRDY: begin
            if(DRDY) begin
               if(state_count > 0) begin
                  next_state  = ADDRESS;
               end else begin
                  next_state  = WAIT_LOCK;
               end
            end else begin
               next_state     = WAIT_DRDY;
            end
         end
         default: begin
            next_state = RESTART;
         end
      endcase
   end
  wire        psdone_unused;
  wire        clkfboutb_unused;
  wire        clkout0b_unused;
  wire        clkout1_unused;
  wire        clkout1b_unused;
  wire        clkout2_unused;
  wire        clkout2b_unused;
  wire        clkout3_unused;
  wire        clkout3b_unused;
  wire        clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;
  MMCME2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (10.000),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (DIV_F),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (10.000),
    .REF_JITTER1          (0.010))
  mmcm_adv_inst
   (.CLKFBOUT            (CLKFBOUT_O),
    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (PXL_CLK),
    .CLKOUT0B            (clkout0b_unused),
    .CLKOUT1             (clkout1_unused),
    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (clkout2_unused),
    .CLKOUT2B            (clkout2b_unused),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT3B            (clkout3b_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
    .CLKOUT6             (clkout6_unused),
    .CLKFBIN             (CLKFBOUT_I),
    .CLKIN1              (REF_CLK),
    .CLKIN2              (1'b0),
    .CLKINSEL            (1'b1),
    .DADDR               (DADDR),
    .DCLK                (DCLK),
    .DEN                 (DEN),
    .DI                  (DI),
    .DO                  (DO),
    .DRDY                (DRDY),
    .DWE                 (DWE),
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    .LOCKED              (LOCKED),
    .CLKINSTOPPED        (clkinstopped_unused),
    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (RST_MMCM));
   assign LOCKED_O = LOCKED;
endmodule
