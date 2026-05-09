module PFF_DSP_16 (
	input clk,
	input store_strb,
	input feedfwd_en_b,
	input useDiode_b, loop2_useDiode_b,
	input diodeGating_b, loop2_diodeGating_b,
	input use_strobes_b,
	input [9:0] start_proc_b,
	input [9:0] end_proc_b,
	input [4:0] kick1_delay_b,
	input [4:0] kick2_delay_b,
	input [1:0] opMode_b, 
	input [1:0] oflowMode_b, 
	input signed [12:0] diodeIn, loop2_diodeIn,
	input signed [15:0] MixerIn, loop2_MixerIn,
	input signed [12:0] kick1_constDac_val_b,
	input signed [12:0] kick2_constDac_val_b,
	input signed [13:0] kick1_gain_b, loop2_kick1_gain_b,
	input signed [13:0] kick2_gain_b, loop2_kick2_gain_b,
	input DAC1clkPhase_b,
	input DAC2clkPhase_b,
	input oflowClr,
	input signed [6:0] DAC1_IIRtapWeight, DAC2_IIRtapWeight,
	output reg oflowDetect = 1'b0,
	output signed [12:0] kick1_dout,
	output signed [12:0] kick2_dout,
	output DAC1_en,
	output DAC2_en
);
`define COMBINE 
parameter GAIN_SCALE =-4;
parameter GAIN_OFFSET = 10; 
parameter GAIN_MSB = 30; 
parameter DIODE_SCALE = 4; 
wire signed [17:0] lutReg;
LUTROM LUT1(
	.clka(clk),
	.addra(diodeIn),
	.douta(lutReg)
	);
(* shreg_extract = "no" *) reg useDiode = 1'b0, useDiode_a = 1'b0;
(* shreg_extract = "no" *) reg diodeGating = 1'b0, diodeGating_a = 1'b0;
(* shreg_extract = "no" *) reg loop2_useDiode = 1'b0, loop2_useDiode_a = 1'b0;
(* shreg_extract = "no" *) reg loop2_diodeGating = 1'b0, loop2_diodeGating_a = 1'b0;
(* shreg_extract = "no" *) reg [1:0] oflowMode = 2'd0, oflowMode_a = 2'd0;
(* keep = "yes", shreg_extract = "no" *) reg signed [17:0] lutReg_b = 18'sd0, loop2_lutReg_b = 18'sd0;
(* shreg_extract = "no" *) reg signed [17:0] lutReg_c = 18'sd0, loop2_lutReg_c = 18'sd0;
wire signed [17:0] loop2_lutReg;
`ifdef XILINX_ISIM
	(* shreg_extract = "no" *) reg feedfwd_en = 1'b1, feedfwd_en_a = 1'b1;
	(* shreg_extract = "no" *) reg use_strobes = 1'b1, use_strobes_a = 1'b1;
	(* shreg_extract = "no" *) reg [9:0] start_proc = 10'd0, start_proc_a = 10'd0;
	(* shreg_extract = "no" *) reg [9:0] end_proc = 10'd164, end_proc_a = 10'd164;
	(* shreg_extract = "no" *) reg [4:0] kick1_delay = 5'd0, kick1_delay_a = 5'd0;
	(* shreg_extract = "no" *) reg [4:0] kick2_delay = 5'd0, kick2_delay_a= 5'd0;
	(* ASYNC_REG = "TRUE" *) reg [1:0] opMode = 2'd0, opMode_a = 2'd0;
	(* shreg_extract = "no" *) reg signed [12:0] kick1_constDac_val = 13'd0, kick1_constDac_val_a = 13'd0;
	(* shreg_extract = "no" *) reg signed [12:0] kick2_constDac_val = 13'd0, kick2_constDac_val_a = 13'd0;
	(* shreg_extract = "no" *) reg signed [13:0] kick1_gain = 14'd0, kick1_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg signed [13:0] kick2_gain = 14'd0, kick2_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg signed [13:0] loop2_kick1_gain = 14'd0, loop2_kick1_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg signed [13:0] loop2_kick2_gain = 14'd0, loop2_kick2_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg DAC1clkPhase = 1'b0, DAC1clkPhase_a = 1'b0;
	(* shreg_extract = "no" *) reg DAC2clkPhase = 1'b0, DAC2clkPhase_a = 1'b0;
`else
	(* shreg_extract = "no" *) reg feedfwd_en = 1'b0, feedfwd_en_a = 1'b0;
	(* shreg_extract = "no" *) reg use_strobes = 1'b0, use_strobes_a = 1'b0;
	(* shreg_extract = "no" *) reg [9:0] start_proc = 10'd0, start_proc_a = 10'd0;
	(* shreg_extract = "no" *) reg [9:0] end_proc = 10'd0, end_proc_a = 10'd0;
	(* shreg_extract = "no" *) reg [4:0] kick1_delay = 5'd0, kick1_delay_a = 5'd0;
	(* shreg_extract = "no" *) reg [4:0] kick2_delay = 5'd0, kick2_delay_a= 5'd0;
	(* ASYNC_REG = "TRUE" *) reg [1:0] opMode = 2'd0, opMode_a = 2'd0;
	(* shreg_extract = "no" *) reg signed [12:0] kick1_constDac_val = 13'd0, kick1_constDac_val_a = 13'd0;
	(* shreg_extract = "no" *) reg signed [12:0] kick2_constDac_val = 13'd0, kick2_constDac_val_a = 13'd0;
	(* shreg_extract = "no" *) reg signed [13:0] kick1_gain = 14'd0, kick1_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg signed [13:0] kick2_gain = 14'd0, kick2_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg signed [13:0] loop2_kick1_gain = 14'd0, loop2_kick1_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg signed [13:0] loop2_kick2_gain = 14'd0, loop2_kick2_gain_a = 14'd0;
	(* shreg_extract = "no" *) reg DAC1clkPhase = 1'b0, DAC1clkPhase_a = 1'b0;
	(* shreg_extract = "no" *) reg DAC2clkPhase = 1'b0, DAC2clkPhase_a = 1'b0;
`endif
always @(posedge clk) begin
	feedfwd_en <= feedfwd_en_a;
	feedfwd_en_a <= feedfwd_en_b;
	use_strobes <= use_strobes_a;
	use_strobes_a <= use_strobes_b;
	start_proc <= start_proc_a;
	start_proc_a <= start_proc_b;
	end_proc <= end_proc_a;
	end_proc_a <= end_proc_b;
	kick1_delay <= kick1_delay_a;
	kick1_delay_a <= kick1_delay_b;
	kick2_delay <= kick2_delay_a;
	kick2_delay_a <= kick2_delay_b;	
	opMode <= opMode_a;
	opMode_a <= opMode_b;
	kick1_constDac_val <= kick1_constDac_val_a;
	kick1_constDac_val_a <= kick1_constDac_val_b;
	kick2_constDac_val <= kick2_constDac_val_a;
	kick2_constDac_val_a <= kick2_constDac_val_b;
	kick1_gain <= kick1_gain_a;
	kick1_gain_a <= kick1_gain_b;
	kick2_gain <= kick2_gain_a;
	kick2_gain_a <= kick2_gain_b;
	loop2_kick1_gain <= loop2_kick1_gain_a;
	loop2_kick1_gain_a <= loop2_kick1_gain_b;
	loop2_kick2_gain <= loop2_kick2_gain_a;
	loop2_kick2_gain_a <= loop2_kick2_gain_b;
	DAC1clkPhase <= DAC1clkPhase_a;
	DAC1clkPhase_a <= DAC1clkPhase_b;
	DAC2clkPhase <= DAC2clkPhase_a;
	DAC2clkPhase_a <= DAC2clkPhase_b;
	useDiode <= useDiode_a;
	useDiode_a <= useDiode_b;
	diodeGating <= diodeGating_a;
	diodeGating_a <= diodeGating_b;
	loop2_useDiode <= loop2_useDiode_a;
	loop2_useDiode_a <= loop2_useDiode_b;
	loop2_diodeGating <= loop2_diodeGating_a;
	loop2_diodeGating_a <= loop2_diodeGating_b;
	oflowMode <= oflowMode_a;
	oflowMode_a <= oflowMode_b;
	if (diodeGating) lutReg_b <= (useDiode) ? lutReg : {17'sd0, |lutReg};
	else lutReg_b <= (useDiode) ? lutReg : 18'sd1;
	if (loop2_diodeGating) loop2_lutReg_b <= (loop2_useDiode) ? loop2_lutReg : {17'sd0, |loop2_lutReg};
	else loop2_lutReg_b <= (loop2_useDiode) ? loop2_lutReg : 18'sd1;
	lutReg_c <= lutReg_b;
	loop2_lutReg_c <= loop2_lutReg_b;
	end
parameter real CLK_FREQ = 357e6;
parameter real SUB_PULSE_LENGTH = 280e-9;
localparam [9:0] PULSE_LENGTH = (CLK_FREQ * SUB_PULSE_LENGTH * 4); 
(* shreg_extract = "no" *) reg [9:0] opGate_ctr = 10'd0;
(* shreg_extract = "no" *) reg opGate = 1'b0;
`ifdef COMBINE
   localparam OFFSET_DELAY = 4'd10; 
	wire [9:0] startProc = (~opMode[1]) ? start_proc : end_proc - PULSE_LENGTH;
`else
	localparam OFFSET_DELAY = 4'd8; 
	wire [9:0] startProc = start_proc;
`endif
always @(posedge clk) begin
	opGate_ctr <= (store_strb) ? opGate_ctr + 1'b1 : 11'd0;
	if (store_strb) begin
		case (opGate_ctr) 
			startProc: opGate <= 1'b1;	
			end_proc: opGate <= 1'b0;
			default: opGate <= opGate;
		endcase
	end else begin
		opGate <= 1'b0;
		end
end
`ifdef COMBINE
	(* keep = "yes" *) reg signed [17:0] lutReg_d = 18'sd0, lutReg_e = 18'sd0;
	always @(posedge clk) begin
		lutReg_d <= lutReg_c;
		lutReg_e <= lutReg_d;
		end
	wire signed [17:0] normMult_DiodeIn = lutReg_e;
	wire signed [15:0] MixerComb;
	(* keep = "yes" *) reg signed [15:0] MixerIn_a = 16'sd0, MixerIn_b = 16'sd0;
	Combiner #(CLK_FREQ, SUB_PULSE_LENGTH) Combiner1(.clk(clk), .din(MixerIn), .integ(opGate), .bypass(1'b0), .dout(MixerComb));
	always @(posedge clk) begin
		MixerIn_b <= MixerIn_a;
		MixerIn_a <= MixerIn;
		end
	wire signed [15:0] normMult_MixerIn = (~opMode[1]) ? MixerIn_b : MixerComb;	
`else
	wire signed [15:0] normMult_MixerIn = MixerIn; 
	wire signed [17:0] normMult_DiodeIn = lutReg_c; 
`endif
wire signed [15:0] kick1_gainMult;
wire kick1_oflowDet;
normMult #(GAIN_SCALE, GAIN_OFFSET, GAIN_MSB, DIODE_SCALE) kick1Mult(clk, useDiode, oflowMode, normMult_DiodeIn, normMult_MixerIn, kick1_gain, kick1_gainMult, kick1_oflowDet);
wire signed [15:0] kick2_gainMult;
wire kick2_oflowDet;
normMult #(GAIN_SCALE, GAIN_OFFSET, GAIN_MSB, DIODE_SCALE) kick2Mult(clk, useDiode, oflowMode, normMult_DiodeIn, normMult_MixerIn, kick2_gain, kick2_gainMult, kick2_oflowDet);
parameter LOOP2_GAIN_SCALE = -4; 
parameter LOOP2_GAIN_OFFSET = 10; 
parameter LOOP2_GAIN_MSB = 30; 
parameter LOOP2_DIODE_SCALE = 4; 
LUTROM LUT2(
	.clka(clk),
	.addra(loop2_diodeIn),
	.douta(loop2_lutReg)
	);
`ifdef COMBINE
	(* keep = "yes" *) reg signed [17:0] loop2_lutReg_d = 18'sd0, loop2_lutReg_e = 18'sd0;
	always @(posedge clk) begin
		loop2_lutReg_d <= loop2_lutReg_c;
		loop2_lutReg_e <= loop2_lutReg_d;
		end
	wire signed [17:0] loop2_normMult_DiodeIn = loop2_lutReg_e;
	(* keep = "yes" *) reg signed [15:0] loop2_MixerIn_a = 16'sd0, loop2_MixerIn_b = 16'sd0;
	always @(posedge clk) begin
		loop2_MixerIn_a <= loop2_MixerIn;
		loop2_MixerIn_b <= loop2_MixerIn_a;
		end
	wire signed [15:0] loop2_normMult_MixerIn = loop2_MixerIn_b;
`else
	wire signed [15:0] loop2_normMult_MixerIn = loop2_MixerIn; 
	wire signed [17:0] loop2_normMult_DiodeIn = loop2_lutReg_c; 
`endif
wire signed [15:0] loop2_kick1_gainMult;
wire loop2_kick1_oflowDet;
normMult #(LOOP2_GAIN_SCALE, LOOP2_GAIN_OFFSET, LOOP2_GAIN_MSB, LOOP2_DIODE_SCALE) loop2_kick1Mult(clk, loop2_useDiode, oflowMode, loop2_normMult_DiodeIn, loop2_normMult_MixerIn, loop2_kick1_gain, loop2_kick1_gainMult, loop2_kick1_oflowDet);
wire signed [15:0] loop2_kick2_gainMult;
wire loop2_kick2_oflowDet;
normMult #(LOOP2_GAIN_SCALE, LOOP2_GAIN_OFFSET, LOOP2_GAIN_MSB, LOOP2_DIODE_SCALE) loop2_kick2Mult(clk, loop2_useDiode, oflowMode, loop2_normMult_DiodeIn, loop2_normMult_MixerIn, loop2_kick2_gain, loop2_kick2_gainMult, loop2_kick2_oflowDet);
reg signed [16:0] kick1_drive = 17'sd0;
reg signed [15:0] kick1_drive_b = 16'sd0;
reg signed [16:0] kick2_drive = 17'sd0;
reg signed [15:0] kick2_drive_b = 16'sd0;
reg kick1_drive_oflowDet = 1'b0, kick2_drive_oflowDet = 1'b0;
always @(posedge clk) begin
	kick1_drive <= kick1_gainMult + loop2_kick1_gainMult;
	kick2_drive <= kick2_gainMult + loop2_kick2_gainMult;
	end
always @(*) begin
	if (^kick1_drive[16:15]) begin
		kick1_drive_oflowDet = 1'b1;
		(* full_case, parallel_case *) 
		case(oflowMode)
		2'b00: kick1_drive_b = kick1_drive[15:0];
		2'b01: kick1_drive_b = 16'sd0;
		2'b10: kick1_drive_b = (kick1_drive[16]) ? -16'sd32768 : 16'sd32767;
		endcase
	end else begin 
		kick1_drive_b = kick1_drive[15:0];
		kick1_drive_oflowDet = 1'b0;
		end
end
always @(*) begin
	if (^kick2_drive[16:15]) begin
		kick2_drive_oflowDet = 1'b1;
		(* full_case, parallel_case *) 
		case(oflowMode)
		2'b00: kick2_drive_b = kick2_drive[15:0];
		2'b01: kick2_drive_b = 16'sd0;
		2'b10: kick2_drive_b = (kick2_drive[16]) ? -16'sd32768 : 16'sd32767;
		endcase
	end else begin
	kick2_drive_b = kick2_drive[15:0];
	kick2_drive_oflowDet = 1'b0;
	end
end
wire DAC1_IIR_oflowDet, DAC2_IIR_oflowDet;
ampDrive #(.OFFSET_DELAY(OFFSET_DELAY)) kick1Drive(clk, feedfwd_en, (store_strb && (opGate || ~use_strobes)), opMode[0], kick1_delay, kick1_constDac_val, kick1_drive_b, DAC1clkPhase, DAC1_IIRtapWeight, DAC1_IIR_oflowDet, kick1_dout, DAC1_en);
ampDrive #(.OFFSET_DELAY(OFFSET_DELAY)) kick2Drive(clk, feedfwd_en, (store_strb && (opGate || ~use_strobes)), opMode[0], kick2_delay, kick2_constDac_val, kick2_drive_b, DAC2clkPhase, DAC2_IIRtapWeight, DAC2_IIR_oflowDet, kick2_dout, DAC2_en);
reg kick1_oflowDet_a = 1'b0, kick2_oflowDet_a = 1'b0;
always @(posedge clk) begin
	kick1_oflowDet_a <= kick1_oflowDet;
	kick2_oflowDet_a <= kick2_oflowDet;
	oflowDetect <= (kick1_oflowDet_a | kick2_oflowDet_a | loop2_kick1_oflowDet | loop2_kick2_oflowDet | kick1_drive_oflowDet | kick2_drive_oflowDet | DAC1_IIR_oflowDet | DAC2_IIR_oflowDet);
end
endmodule
