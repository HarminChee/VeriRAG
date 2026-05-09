module tube (
             input [2:0] h_addr,
             input       h_cs_b,
`ifdef SEPARATE_HOST_DATABUSSES_D
             input [7:0]  h_data_in,
             output [7:0] h_data_out,
`else 
             inout [7:0] h_data,
`endif 
             input       h_phi2,
             input       scan_phi,
             input       test_i,
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

   // ... existing code ...

   wire dft_h_phi2;
   assign dft_h_phi2 = test_i ? scan_phi : h_phi2;

   // Remaining state for host side reg 0, note that FIFO is unaffected by soft reset
   always @ ( negedge dft_h_phi2 or negedge h_rst_b )
     if ( ! h_rst_b )
       h_reg0_q_r <= 7'b0;
     else
       h_reg0_q_r <= h_reg0_d_w;

   // Latch host side register select signals on phi2 - found that the L1B CPLD was
   // more robust when this was done avoiding bus hold issues ?
   always @ (posedge dft_h_phi2 or negedge h_rst_b)
     begin
        if ( ! h_rst_b )
          begin
             h_select_fifo_q_r <= 4'h0;
             h_select_reg0_q_r <= 1'b0;
             h_rdnw_q_r <= 1'b0;             
          end
        else
          begin
             h_rdnw_q_r <= h_rdnw;                          
             h_select_reg0_q_r    <= h_select_reg0_d_w;          
             h_select_fifo_q_r[0] <= h_select_fifo_d_w[0];
             h_select_fifo_q_r[1] <= h_select_fifo_d_w[1];
             h_select_fifo_q_r[2] <= h_select_fifo_d_w[2];
             h_select_fifo_q_r[3] <= h_select_fifo_d_w[3];      
          end  
     end

   // ... existing code ...

endmodule