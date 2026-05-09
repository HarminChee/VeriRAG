module tube (
             input [2:0] h_addr,
             input       h_cs_b,
             input       test_i,
             input       scan_clk,
`ifdef SEPARATE_HOST_DATABUSSES_D
             input [7:0]  h_data_in,
             output [7:0] h_data_out,
`else 
             inout [7:0] h_data,
`endif 
             input       h_phi2,
             input       h_rdnw,
             input       h_rst_b,
             output      h_irq_b,
`ifndef OMIT_DMA_PINS_D            
             output      drq,
             input       dack_b,
`endif
             
             input [2:0] p_addr,
             input       p_cs_b,
`ifdef SEPARATE_PARASITE_DATABUSSES_D
             input [7:0]  p_data_in,
             output [7:0] p_data_out,
`else 
             inout [7:0] p_data,
`endif 
             
             input       p_rdnw,
             input       p_phi2,
             output      p_rst_b,
             output      p_nmi_b,
             output      p_irq_b
             );

reg scl;
reg h_select_fifo_q_r;
reg h_select_reg0_q_r;
reg h_rdnw_q_r;
wire h_select_reg0_d_w;
wire [3:0] h_select_fifo_d_w;

wire dft_clk;
assign dft_clk = test_i ? scan_clk : h_phi2;

always @(negedge dft_clk or negedge h_rst_b) begin
    if(!h_rst_b)
        scl <= 1'b0;
    else 
        scl <= ~scl;
end

always @(posedge dft_clk or negedge h_rst_b) begin
    if(!h_rst_b) begin
        h_select_fifo_q_r <= 4'h0;
        h_select_reg0_q_r <= 1'b0;
        h_rdnw_q_r <= 1'b0;             
    end
    else begin
        h_rdnw_q_r <= h_rdnw;                          
        h_select_reg0_q_r <= h_select_reg0_d_w;          
        h_select_fifo_q_r <= h_select_fifo_d_w;
    end
end

endmodule