module tube (
             input test_mode,
             input [2:0] h_addr,
             input       h_cs_b,
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
             output reg  p_rst_b,
             output      p_nmi_b,
             output      p_irq_b
             );
   
`ifdef OMIT_DMA_PINS_D   
   wire       dack_b_w = 1'b1;
`else
 `ifdef ENABLE_DMA_D
   wire       dack_b_w = dack_b;
 `else   
   wire       dack_b_w = 1'b1;
 `endif   
`endif

   wire       p_r3_two_bytes_available_w;
   
   wire [3:0] h_select_fifo_d_w;
   wire       h_select_reg0_d_w;      
   reg        h_select_reg0_q_r;   
   reg [3:0]  h_select_fifo_q_r;
   reg [3:0]  p_select_fifo_r;
   reg        h_rdnw_q_r;
   reg        n_flag;
   
   reg [7:0]    h_data_r;
   reg [7:0]    p_data_r;
   reg          p_nmi_b_r;
          
   reg [6:0]    h_reg0_q_r;
   reg [5:0]    p_reg0_q_r;   
   
   wire [7:0]   p_data_w;
   wire [7:0]   h_data_w;

   wire [3:0]   p_data_available_w;
   wire [3:0]   p_full_w;
   wire [3:0]   h_data_available_w;
   wire [3:0]   h_full_w;
   
   wire [6:0]   h_reg0_d_w;
   wire         local_rst_b_w;
   wire         ph_zero_r3_bytes_avail_w;

   // Assign to primary IOs
`ifndef OMIT_DMA_PINS_D
   assign drq = h_reg0_q_r[ `M_IDX] & !p_nmi_b_r;
`endif   

   assign h_irq_b = ( h_reg0_q_r[`Q_IDX] & h_data_available_w[3] ) ? 1'b0 : `H_INTERRUPT_OFF_D;
   assign p_nmi_b = (p_nmi_b_r) ?  `P_INTERRUPT_OFF_D : 1'b0;
   assign p_irq_b = ( (h_reg0_q_r[`I_IDX] & p_data_available_w[0]) | (h_reg0_q_r[`J_IDX] & p_data_available_w[3]) ) ? 1'b0 : `P_INTERRUPT_OFF_D;

   always @(posedge h_phi2 or negedge h_rst_b)
     if (!h_rst_b)
       p_rst_b <= 1'b0;
     else 
       p_rst_b <= (!h_reg0_q_r[`P_IDX] & h_rst_b);

`ifdef SEPARATE_HOST_DATABUSSES_D
   wire [7:0] 	h_data;
   assign h_data = h_data_in;
   assign h_data_out = h_data_r;
`else
   assign h_data = ( h_rdnw && !h_cs_b && h_phi2 ) ? h_data_r : 8'bzzzzzzzz;
`endif

`ifdef SEPARATE_PARASITE_DATABUSSES_D
   wire [7:0] 	p_data;
   assign p_data = p_data_in;
   assign p_data_out = p_data_r;
`else
   assign p_data = ( p_rdnw && !p_cs_b ) ? p_data_r : 8'bzzzzzzzz;   
`endif
   
   // Rest of module remains unchanged
   // ... existing code ...
   
endmodule