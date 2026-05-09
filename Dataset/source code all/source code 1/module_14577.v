module DriveOutput (
	input clk,
	input store_strb,
	input feedfwd_en,
	input use_strobes,
	input [9:0] start_proc,
	input [9:0] end_proc,
	input [4:0] Ldelay,
	input [1:0] opMode, 
	input signed [12:0] constDac_val,
	input signed [24:0] din,
	input signed [6:0] gain,
	input DACclkPhase,
	input signed [6:0] IIRtapWeight,
	(* IOB = "true" *) output reg signed [12:0] dout = 13'd0, 
	(* IOB = "true" *) output reg DAC_en  = 1'b0 
);
parameter offset_delay = 4'd7; 
(* shreg_extract = "no" *) reg signed [35:0] gain_mult = 36'sd0, gainMult_out = 36'sd0;
(* shreg_extract = "no" *) reg signed [12:0] amp_drive = 13'sd0;
wire signed [12:0] amp_drive_del;
always @(posedge clk) begin
	gain_mult <= din * gain;
	gainMult_out <= gain_mult;
	end
ShiftReg #(32) latencyDelay (clk, gainMult_out[30:18], Ldelay, amp_drive_del);
wire storeStrbDel;
wire [5:0] strbDel;
assign strbDel = Ldelay + offset_delay;
StrbShifter #(64) StoreStrbDel (clk, store_strb, strbDel, storeStrbDel);
(* shreg_extract = "no" *) reg [9:0] opGate_ctr = 10'd0;
(* shreg_extract = "no" *) reg opGate = 1'b0;
always @(posedge clk) begin
	opGate_ctr <= (storeStrbDel) ? opGate_ctr + 1'b1 : 11'd0;
	if (storeStrbDel) begin
		case (opGate_ctr) 
			start_proc: opGate <= 1'b1;	
			end_proc: opGate <= 1'b0;
			default: opGate <= opGate;
		endcase
	end else begin
		opGate <= 1'b0;
		end
end
reg feedfwd_en_a = 0, feedfwd_en_b = 0; 
reg signed [12:0] amp_drive_b = 13'sd0; 
always @(posedge clk) begin
	feedfwd_en_a <= feedfwd_en;
	feedfwd_en_b <= feedfwd_en_a;
	amp_drive_b <= amp_drive;
	end
always @(*) begin
	if (storeStrbDel && (opGate || ~use_strobes))
		(* full_case, parallel_case *) 
		case (opMode) 	
		2'd0: amp_drive = amp_drive_del;
		2'd1: amp_drive = constDac_val;
		default: amp_drive = 13'd0;
		endcase
	else amp_drive = 13'd0;
end
wire signed [12:0] amp_drive_AD, amp_drive_out;
antiDroopIIR #(16) antiDroopIIR_DAC(
	.clk(clk),
	.trig(store_strb),
	.din(amp_drive_b),
	.tapWeight(IIRtapWeight),
	.accClr_en(1'b1),
	.oflowClr(),
	.oflowDetect(),
	.dout(amp_drive_AD)
);
assign amp_drive_out = amp_drive_AD;
(* shreg_extract = "no" *) reg clk_tog = 1'b0; 
(* shreg_extract = "no" *) reg storeStrbDel_a = 1'b0, storeStrbDel_b = 1'b0, storeStrbDel_c = 1'b0, storeStrbDel_d = 1'b0, storeStrbDel_e = 1'b0;
wire clearDAC;
wire output_en;
assign clearDAC = storeStrbDel_e & ~storeStrbDel_d; 
assign output_en = storeStrbDel_c; 
always @(posedge clk) begin
	storeStrbDel_a <= storeStrbDel;
	storeStrbDel_b <= storeStrbDel_a;	
	storeStrbDel_c <= storeStrbDel_b;	
	storeStrbDel_d <= storeStrbDel_c;	
	storeStrbDel_e <= storeStrbDel_d;	
	if (clearDAC && feedfwd_en_b) begin
		dout <= 13'd0;
		DAC_en <= 1'b1;
		clk_tog <= clk_tog;
	end else if (output_en && feedfwd_en_b) begin
		clk_tog <= ~clk_tog;
		DAC_en <= clk_tog ^ DACclkPhase;
		dout <= (clk_tog) ? dout : amp_drive_out;
	end else begin
		dout <= 13'd0;
		DAC_en <= 1'b0;
		clk_tog <= 1'b0;
	end
end
endmodule
