`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_irq_gen # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,
	input	[15:0]							cfg_command,
	output									cfg_interrupt,
	input									cfg_interrupt_rdy,
	output									cfg_interrupt_assert,
	output	[7:0]							cfg_interrupt_di,
	input	[7:0]							cfg_interrupt_do,
	input	[2:0]							cfg_interrupt_mmenable,
	input									cfg_interrupt_msienable,
	input									cfg_interrupt_msixenable,
	input									cfg_interrupt_msixfm,
	output									cfg_interrupt_stat,
	output	[4:0]							cfg_pciecap_interrupt_msgnum,
	input									pcie_legacy_irq_set,
	input									pcie_msi_irq_set,
	input	[2:0]							pcie_irq_vector,
	input									pcie_legacy_irq_clear,
	output									pcie_irq_done
);
localparam	S_IDLE							= 7'b0000001;
localparam	S_SEND_MSI						= 7'b0000010;
localparam	S_LEGACY_ASSERT					= 7'b0000100;
localparam	S_LEGACY_ASSERT_HOLD			= 7'b0001000;
localparam	S_LEGACY_DEASSERT				= 7'b0010000;
localparam	S_WAIT_RDY_N					= 7'b0100000;
localparam	S_IRQ_DONE						= 7'b1000000;
reg		[6:0]								cur_state;
reg		[6:0]								next_state;
reg											r_cfg_interrupt;
reg											r_cfg_interrupt_assert;
reg		[7:0]								r_cfg_interrupt_di;
reg		[2:0]								r_pcie_irq_vector;
reg											r_pcie_irq_done;
assign cfg_interrupt = r_cfg_interrupt;
assign cfg_interrupt_assert = r_cfg_interrupt_assert;
assign cfg_interrupt_di = r_cfg_interrupt_di;
assign cfg_interrupt_stat = 1'b0;
assign cfg_pciecap_interrupt_msgnum = 5'b0;
assign pcie_irq_done = r_pcie_irq_done;
always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0)
		cur_state <= S_IDLE;
	else
		cur_state <= next_state;
end
always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			if(pcie_msi_irq_set == 1)
				next_state <= S_SEND_MSI;
			else if(pcie_legacy_irq_set == 1)
				next_state <= S_LEGACY_ASSERT;
			else
				next_state <= S_IDLE;
		end
		S_SEND_MSI: begin
			if(cfg_interrupt_rdy == 1)
				next_state <= S_WAIT_RDY_N;
			else
				next_state <= S_SEND_MSI;
		end
		S_LEGACY_ASSERT: begin
			if(cfg_interrupt_rdy == 1)
				next_state <= S_LEGACY_ASSERT_HOLD;
			else
				next_state <= S_LEGACY_ASSERT;
		end
		S_LEGACY_ASSERT_HOLD: begin
			if(pcie_legacy_irq_clear == 1)
				next_state <= S_LEGACY_DEASSERT;
			else
				next_state <= S_LEGACY_ASSERT_HOLD;
		end
		S_LEGACY_DEASSERT: begin
			if(cfg_interrupt_rdy == 1)
				next_state <= S_WAIT_RDY_N;
			else
				next_state <= S_LEGACY_DEASSERT;
		end
		S_WAIT_RDY_N: begin
			if(cfg_interrupt_rdy == 0)
				next_state <= S_IRQ_DONE;
			else
				next_state <= S_WAIT_RDY_N;
		end
		S_IRQ_DONE: begin
			next_state <= S_IDLE;
		end
		default: begin
			next_state <= S_IDLE;
		end
	endcase
end
always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_IDLE: begin
			r_pcie_irq_vector <= pcie_irq_vector;
		end
		S_SEND_MSI: begin
		end
		S_LEGACY_ASSERT: begin
		end
		S_LEGACY_ASSERT_HOLD: begin
		end
		S_LEGACY_DEASSERT: begin
		end
		S_WAIT_RDY_N: begin
		end
		S_IRQ_DONE: begin
		end
		default: begin
		end
	endcase
end
always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_cfg_interrupt <= 0;
			r_cfg_interrupt_assert <= 0;
			r_cfg_interrupt_di <= 0;
			r_pcie_irq_done <= 0;
		end
		S_SEND_MSI: begin
			r_cfg_interrupt <= 1;
			r_cfg_interrupt_assert <= 0;
			r_cfg_interrupt_di <= {5'b0, r_pcie_irq_vector};
			r_pcie_irq_done <= 0;
		end
		S_LEGACY_ASSERT: begin
			r_cfg_interrupt <= 1;
			r_cfg_interrupt_assert <= 1;
			r_cfg_interrupt_di <= 0;
			r_pcie_irq_done <= 0;
		end
		S_LEGACY_ASSERT_HOLD: begin
			r_cfg_interrupt <= 0;
			r_cfg_interrupt_assert <= 1;
			r_cfg_interrupt_di <= 0;
			r_pcie_irq_done <= 0;
		end
		S_LEGACY_DEASSERT: begin
			r_cfg_interrupt <= 1;
			r_cfg_interrupt_assert <= 0;
			r_cfg_interrupt_di <= 0;
			r_pcie_irq_done <= 0;
		end
		S_WAIT_RDY_N: begin
			r_cfg_interrupt <= 1;
			r_cfg_interrupt_assert <= 0;
			r_cfg_interrupt_di <= 0;
			r_pcie_irq_done <= 0;
		end
		S_IRQ_DONE: begin
			r_cfg_interrupt <= 0;
			r_cfg_interrupt_assert <= 0;
			r_cfg_interrupt_di <= 0;
			r_pcie_irq_done <= 1;
		end
		default: begin
			r_cfg_interrupt <= 0;
			r_cfg_interrupt_assert <= 0;
			r_cfg_interrupt_di <= 0;
			r_pcie_irq_done <= 0;
		end
	endcase
end
endmodule
