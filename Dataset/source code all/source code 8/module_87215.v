`timescale 1ns / 1ps
`timescale 1ns / 1ps
module nvme_cq_check # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,
	input									pcie_msi_en,
	input									cq_rst_n,
	input									cq_valid,
	input									io_cq_irq_en,
	input	[7:0]							cq_tail_ptr,
	input	[7:0]							cq_head_ptr,
	input									cq_head_update,
	output									cq_legacy_irq_req,
	output									cq_msi_irq_req,
	input									cq_msi_irq_ack
);
localparam	LP_CQ_IRQ_DELAY_TIME			= 8'h01;
localparam	S_IDLE							= 4'b0001;
localparam	S_CQ_MSI_IRQ_REQ				= 4'b0010;
localparam	S_CQ_MSI_HEAD_SET				= 4'b0100;
localparam	S_CQ_MSI_IRQ_TIMER				= 4'b1000;
reg		[3:0]								cur_state;
reg		[3:0]								next_state;
reg		[7:0]								r_cq_tail_ptr;
reg		[7:0]								r_cq_msi_irq_head_ptr;
reg		[7:0]								r_irq_timer;
reg											r_cq_legacy_irq_req;
reg											r_cq_msi_irq_req;
wire										w_cq_rst_n;
assign cq_legacy_irq_req = r_cq_legacy_irq_req;
assign cq_msi_irq_req = r_cq_msi_irq_req;
assign w_cq_rst_n = pcie_user_rst_n & cq_rst_n;
always @ (posedge pcie_user_clk)
begin
	r_cq_tail_ptr <= cq_tail_ptr;
	r_cq_legacy_irq_req <= ((cq_head_ptr != r_cq_tail_ptr) && ((cq_valid & io_cq_irq_en) == 1));
end
always @ (posedge pcie_user_clk or negedge w_cq_rst_n)
begin
	if(w_cq_rst_n == 0)
		cur_state <= S_IDLE;
	else
		cur_state <= next_state;
end
always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			if(((r_cq_msi_irq_head_ptr != r_cq_tail_ptr) & (pcie_msi_en & cq_valid & io_cq_irq_en)) == 1)
				next_state <= S_CQ_MSI_IRQ_REQ;
			else
				next_state <= S_IDLE;
		end
		S_CQ_MSI_IRQ_REQ: begin
			if(cq_msi_irq_ack == 1)
				next_state <= S_CQ_MSI_HEAD_SET;
			else
				next_state <= S_CQ_MSI_IRQ_REQ;
		end
		S_CQ_MSI_HEAD_SET: begin
			next_state <= S_CQ_MSI_IRQ_TIMER;
		end
		S_CQ_MSI_IRQ_TIMER: begin
			if(r_irq_timer == 0)
				next_state <= S_IDLE;
			else
				next_state <= S_CQ_MSI_IRQ_TIMER;
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
		end
		S_CQ_MSI_IRQ_REQ: begin
		end
		S_CQ_MSI_HEAD_SET: begin
			r_irq_timer <= LP_CQ_IRQ_DELAY_TIME;
		end
		S_CQ_MSI_IRQ_TIMER: begin
			r_irq_timer <= r_irq_timer - 1;
		end
		default: begin
		end
	endcase
end
always @ (posedge pcie_user_clk or negedge w_cq_rst_n)
begin
	if(w_cq_rst_n == 0) begin
		r_cq_msi_irq_head_ptr <= 0;
	end
	else begin
		case(cur_state)
			S_IDLE: begin
				if((pcie_msi_en & cq_valid & io_cq_irq_en) == 0)
					r_cq_msi_irq_head_ptr <= r_cq_tail_ptr;
			end
			S_CQ_MSI_IRQ_REQ: begin
			end
			S_CQ_MSI_HEAD_SET: begin
				r_cq_msi_irq_head_ptr <= r_cq_tail_ptr;
			end
			S_CQ_MSI_IRQ_TIMER: begin
			end
			default: begin
			end
		endcase
	end
end
always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_cq_msi_irq_req <= 0;
		end
		S_CQ_MSI_IRQ_REQ: begin
			r_cq_msi_irq_req <= 1;
		end
		S_CQ_MSI_HEAD_SET: begin
			r_cq_msi_irq_req <= 0;
		end
		S_CQ_MSI_IRQ_TIMER: begin
			r_cq_msi_irq_req <= 0;
		end
		default: begin
			r_cq_msi_irq_req <= 0;
		end
	endcase
end
endmodule
