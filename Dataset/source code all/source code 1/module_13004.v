module clocks (
	CLOCK_50,
	reset,
	address,
	sys_clk,
	SDRAM_CLK,
	readdata
);
parameter SYS_CLK_MULT	= 1;
parameter SYS_CLK_DIV	= 1;
input						CLOCK_50;
input						reset;
input						address;
output					sys_clk;
output					SDRAM_CLK;
output reg	[ 7: 0]	readdata;
wire						clk_locked;
wire						audio_clk_locked;
wire						video_in_clk;
wire						VGA_CLK;
always @(posedge CLOCK_50)
begin
	if (reset)
		readdata <= 8'h00;
	else if (address)
		readdata <= 8'h00;
	else
		readdata <= {6'h00, audio_clk_locked, clk_locked};
end
altpll DE_Clock_Generator_System (
	.inclk			({1'b0, CLOCK_50}),
	.clk				({VGA_CLK, SDRAM_CLK, sys_clk}),
	.locked			(clk_locked),
	.activeclock	(),
	.areset			(1'b0),
	.clkbad			(),
	.clkena			({6{1'b1}}),
	.clkloss			(),
	.clkswitch		(1'b0),
	.enable0			(),
	.enable1			(),
	.extclk			(),
	.extclkena		({4{1'b1}}),
	.fbin				(1'b1),
	.pfdena			(1'b1),
	.pllena			(1'b1),
	.scanaclr		(1'b0),
	.scanclk			(1'b0),
	.scandata		(1'b0),
	.scandataout	(),
	.scandone		(),
	.scanread		(1'b0),
	.scanwrite		(1'b0),
	.sclkout0		(),
	.sclkout1		()
);
defparam
	DE_Clock_Generator_System.clk0_divide_by				= SYS_CLK_DIV,
	DE_Clock_Generator_System.clk0_duty_cycle				= 50,
	DE_Clock_Generator_System.clk0_multiply_by			= SYS_CLK_MULT,
	DE_Clock_Generator_System.clk0_phase_shift			= "0",
	DE_Clock_Generator_System.clk1_divide_by				= SYS_CLK_DIV,
	DE_Clock_Generator_System.clk1_duty_cycle				= 50,
	DE_Clock_Generator_System.clk1_multiply_by			= SYS_CLK_MULT,
	DE_Clock_Generator_System.clk1_phase_shift			= "-3000",
	DE_Clock_Generator_System.clk2_divide_by				= 2,
	DE_Clock_Generator_System.clk2_duty_cycle				= 50,
	DE_Clock_Generator_System.clk2_multiply_by			= 1,
	DE_Clock_Generator_System.clk2_phase_shift			= "20000",
	DE_Clock_Generator_System.compensate_clock			= "CLK0",
	DE_Clock_Generator_System.gate_lock_signal			= "NO",
	DE_Clock_Generator_System.inclk0_input_frequency	= 20000,
	DE_Clock_Generator_System.intended_device_family	= "Cyclone IV",
	DE_Clock_Generator_System.invalid_lock_multiplier	= 5,
	DE_Clock_Generator_System.lpm_type						= "altpll",
	DE_Clock_Generator_System.operation_mode				= "NORMAL",
	DE_Clock_Generator_System.pll_type						= "FAST",
	DE_Clock_Generator_System.port_activeclock			= "PORT_UNUSED",
	DE_Clock_Generator_System.port_areset					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkbad0					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkbad1					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkloss					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkswitch				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_fbin						= "PORT_UNUSED",
	DE_Clock_Generator_System.port_inclk0					= "PORT_USED",
	DE_Clock_Generator_System.port_inclk1					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_locked					= "PORT_USED",
	DE_Clock_Generator_System.port_pfdena					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_pllena					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scanaclr				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scanclk					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scandata				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scandataout			= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scandone				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scanread				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_scanwrite				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clk0						= "PORT_USED",
	DE_Clock_Generator_System.port_clk1						= "PORT_USED",
	DE_Clock_Generator_System.port_clk2						= "PORT_USED",
	DE_Clock_Generator_System.port_clk3						= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clk4						= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clk5						= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkena0					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkena1					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkena2					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkena3					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkena4					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_clkena5					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_enable0					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_enable1					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclk0					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclk1					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclk2					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclk3					= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclkena0				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclkena1				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclkena2				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_extclkena3				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_sclkout0				= "PORT_UNUSED",
	DE_Clock_Generator_System.port_sclkout1				= "PORT_UNUSED",
	DE_Clock_Generator_System.valid_lock_multiplier		= 1;
endmodule
