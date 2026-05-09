`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module acl_int_mult64u (
	enable,
	clock,
	dataa,
	datab,
	result);
  parameter INPUT1_WIDTH = 64;
  parameter INPUT2_WIDTH = 64;
	input	  enable;
	input	  clock;
	input	[INPUT1_WIDTH - 1 : 0]  dataa;
	input	[INPUT2_WIDTH - 1 : 0]  datab;
	output	reg [63:0]  result;
	wire [127:0] sub_wire0;
	lpm_mult	lpm_mult_component (
				.clock (clock),
				.datab (datab),
				.clken (enable),
				.dataa (dataa),
				.result (sub_wire0),
				.aclr (1'b0),
				.sum (1'b0));
	defparam
		lpm_mult_component.lpm_hint = "MAXIMIZE_SPEED=9",
		lpm_mult_component.lpm_pipeline = 3,
		lpm_mult_component.lpm_representation = "UNSIGNED",
		lpm_mult_component.lpm_type = "LPM_MULT",
		lpm_mult_component.lpm_widtha = INPUT1_WIDTH,
		lpm_mult_component.lpm_widthb = INPUT2_WIDTH,
		lpm_mult_component.lpm_widthp = 128;
  always@(posedge clock)
  begin
    if (enable)
      result <= sub_wire0[63:0];
  end
endmodule
