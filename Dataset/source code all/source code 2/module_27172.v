`timescale 1ns / 1ps
`timescale 1ns / 1ps
module WcaDducController(
	input              clock,
	input              reset,
	input              enable,
	input	  wire		 strobe_if,			
	output  wire [7:0]   cfg,				
	output  wire [12:0] 	rate_interp,	
	output  wire 			rate_interp_we,
	output  wire [3:0]	log2_rate,		
	output  wire       	strobe_cic,   	
	output  wire 			strobe_bb,    	
	output  wire [31:0]  phase_cordic, 	
	input   wire  [11:0] rbusCtrl,   
	inout   wire  [7:0]  rbusData		
 );
   parameter IF_FREQ_ADDR 		= 0;
   parameter INTERP_RATE_ADDR = 1;
   parameter CONFIG_ADDR		= 2;
   parameter MODE  =  4'hF; 		
   `define CORDIC_ENABLED 3'h1
	`define CIC_ENABLED 3'h2
	`define HBF_ENABLED 3'h4
	`define DYNAMIC_CONFIG 4'h8
	wire [2:0] dumpReg;
	WcaWriteByteReg #(CONFIG_ADDR) wr_config
							(.reset(reset), 
							.out( cfg), 
							.rbusCtrl(rbusCtrl), .rbusData(rbusData) );	
	WcaPhaseGen #(IF_FREQ_ADDR, 32) phase_generator
	(
	.clock(clock), .reset(reset), .aclr(cfg[1]), .enable(enable), .strobe(strobe_if),
	.rbusCtrl(rbusCtrl), .rbusData(rbusData), 
	.phase(phase_cordic)
	);	 
	WcaWriteWordReg #(INTERP_RATE_ADDR) reg_interp_rate
	(.reset(reset), .out({dumpReg,rate_interp}), .nd(rate_interp_we),
	 .rbusCtrl(rbusCtrl), .rbusData(rbusData) );	
	reg [11:0] strobeGenerator;
	wire clear = strobeGenerator[11:2] == rate_interp[9:0];
	always @( posedge clock)
		begin
			if( reset | ~enable | clear | cfg[1])
				begin 
					strobeGenerator <= 12'h1;
				end
			else 
			  begin
				strobeGenerator <= strobeGenerator + 12'h1;
			end
		end
	assign strobe_cic =  enable & ((MODE[3] & cfg[4]) ?  strobe_if  : strobeGenerator == 12'h3);
	assign strobe_bb  =  enable & ((MODE[3] & cfg[5]) ?  strobe_cic : strobe_cic); 
	assign log2_rate = rate_interp[7] ? 4'h7 :  
							 rate_interp[6] ? 4'h6 : 
							 rate_interp[5] ? 4'h5 : 
							 rate_interp[4] ? 4'h4 : 
							 rate_interp[3] ? 4'h3 : 
							 rate_interp[2] ? 4'h2 : 
							 rate_interp[1] ? 4'h1 : 4'h0;
endmodule
