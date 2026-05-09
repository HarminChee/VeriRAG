module eval_node(
	clk,
	nrst,
	p_up,
	p_down,
	v_up,
	v_down,
	v_ex,
	result
);
input  clk;
input  nrst; 
input  [63:0] p_up;
input  [63:0] p_down;
input  [63:0] v_up;
input  [63:0] v_down;
input  [63:0] v_ex;
output [63:0] result;
wire [63:0] upside_value;
wire [63:0] downside_value;
wire [63:0] v_hold;
wire [63:0] v_ex_delayed;
wire [63:0] v_hold_delayed;
wire exercise;
reg [63:0] result;
fp_mult_v1 upside_mult (
	.clock ( clk ),
	.dataa ( p_up ),
	.datab ( v_up ),
	.result ( upside_value )
);
fp_mult_v1 downside_mult (
	.clock ( clk ),
	.dataa ( p_down ),
	.datab ( v_down ),
	.result ( downside_value )
);
fp_add_v1 fp_mult_vhold (
	.clock ( clk ),
	.dataa ( upside_value ),
	.datab ( downside_value ),
	.result ( v_hold )
);
fp_compare_v1	fp_compare_v1_inst (
	.clock ( clk ),
	.dataa ( v_ex ),
	.datab ( v_hold ),
	.agb ( exercise )
);
lpm_ff_v1	lpm_ff_v_ex (
	.clock ( clk ),
	.data ( v_ex ),
	.q ( v_ex_delayed )
);
lpm_ff_v1	lpm_ff_v_hold (
	.clock ( clk ),
	.data ( v_hold ),
	.q ( v_hold_delayed )
);
always@(posedge clk)
begin
  if( exercise ) result <= v_ex_delayed[63:0];
  else result <= v_hold_delayed[63:0];
end
endmodule
