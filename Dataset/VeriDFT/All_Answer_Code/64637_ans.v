`timescale 1ns /1ns
`ifdef TWOSTATE_HOST_INTERRUPTS_D
 `define H_INTERRUPT_OFF_D 1'b1
`else
 `define H_INTERRUPT_OFF_D 1'bz
`endif
`ifdef TWOSTATE_PARASITE_INTERRUPTS_D
 `define P_INTERRUPT_OFF_D 1'b1
`else
 `define P_INTERRUPT_OFF_D 1'bz
`endif
`define S_IDX 7
`define T_IDX 6
`define P_IDX 5   
`define V_IDX 4
`define M_IDX 3
`define J_IDX 2
`define I_IDX 1
`define Q_IDX 0   
`timescale 1ns /1ns
`ifdef TWOSTATE_HOST_INTERRUPTS_D
 `define H_INTERRUPT_OFF_D 1'b1
`else
 `define H_INTERRUPT_OFF_D 1'bz
`endif
`ifdef TWOSTATE_PARASITE_INTERRUPTS_D
 `define P_INTERRUPT_OFF_D 1'b1
`else
 `define P_INTERRUPT_OFF_D 1'bz
`endif
`define S_IDX 7
`define T_IDX 6
`define P_IDX 5   
`define V_IDX 4
`define M_IDX 3
`define J_IDX 2
`define I_IDX 1
`define Q_IDX 0   
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
			 input scan_phi,
			 input		test_i,
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
   wire         ph_zero_r3_bytes_avail_w   ;
   wire dft_h_phi2;
`ifndef OMIT_DMA_PINS_D
   assign drq = h_reg0_q_r[ `M_IDX] & !p_nmi_b_r  ;
`endif   
   assign h_irq_b = ( h_reg0_q_r[`Q_IDX] & h_data_available_w[3] ) ? 1'b0 : `H_INTERRUPT_OFF_D ;
   assign p_nmi_b = (p_nmi_b_r) ?  `P_INTERRUPT_OFF_D : 1'b0 ;
   assign p_irq_b = ( (h_reg0_q_r[`I_IDX] & p_data_available_w[0]) | (h_reg0_q_r[`J_IDX] & p_data_available_w[3]) ) ? 1'b0 : `P_INTERRUPT_OFF_D  ;
   assign p_rst_b = (!h_reg0_q_r[`P_IDX] & h_rst_b) ;   
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
   assign h_select_reg0_d_w    = !h_cs_b && ( h_addr == 3'b0);          
   assign h_select_fifo_d_w[0] = !h_cs_b & ( h_addr == 3'h1);
   assign h_select_fifo_d_w[1] = !h_cs_b & ( h_addr == 3'h3);
   assign h_select_fifo_d_w[2] = !h_cs_b & ( h_addr == 3'h5);
   assign h_select_fifo_d_w[3] = !h_cs_b & ( h_addr == 3'h7);        
`ifdef DEBUG_NO_TUBE_D
   assign h_reg0_d_w[`Q_IDX] = 1;
`else   
   assign h_reg0_d_w[`Q_IDX] = (  !h_rdnw && h_select_reg0_q_r) ? ( h_data[ `Q_IDX] ? h_data[`S_IDX] : h_reg0_q_r[ `Q_IDX] ): h_reg0_q_r [ `Q_IDX];
`endif
   assign h_reg0_d_w[`I_IDX] = (  !h_rdnw && h_select_reg0_q_r) ? ( h_data[ `I_IDX] ? h_data[`S_IDX] : h_reg0_q_r[ `I_IDX] ): h_reg0_q_r [ `I_IDX];
   assign h_reg0_d_w[`J_IDX] = (  !h_rdnw && h_select_reg0_q_r) ? ( h_data[ `J_IDX] ? h_data[`S_IDX] : h_reg0_q_r[ `J_IDX] ): h_reg0_q_r [ `J_IDX];
   assign h_reg0_d_w[`V_IDX] = (  !h_rdnw && h_select_reg0_q_r) ? ( h_data[ `V_IDX] ? h_data[`S_IDX] : h_reg0_q_r[ `V_IDX] ): h_reg0_q_r [ `V_IDX];
   assign h_reg0_d_w[`M_IDX] = (  !h_rdnw && h_select_reg0_q_r) ? ( h_data[ `M_IDX] ? h_data[`S_IDX] : h_reg0_q_r[ `M_IDX] ): h_reg0_q_r [ `M_IDX];
   assign h_reg0_d_w[`P_IDX] = (  !h_rdnw && h_select_reg0_q_r) ? ( h_data[ `P_IDX] ? h_data[`S_IDX] : h_reg0_q_r[ `P_IDX] ): h_reg0_q_r [ `P_IDX];
   assign h_reg0_d_w[`T_IDX] = (  !h_rdnw && h_select_reg0_q_r) ? ( h_data[ `T_IDX] ? h_data[`S_IDX] : h_reg0_q_r[ `T_IDX] ): h_reg0_q_r [ `T_IDX];      
   assign local_rst_b_w = ! ( !h_rst_b | h_reg0_q_r[`T_IDX] );   
   always @ ( h_reg0_q_r or
              p_data_available_w or
              ph_zero_r3_bytes_avail_w  or
              p_r3_two_bytes_available_w or
              p_full_w
              )
     begin
       if ( h_reg0_q_r[`V_IDX] == 1'b0 )
         n_flag = ( p_data_available_w[2] | ph_zero_r3_bytes_avail_w  ) ;
       else
         n_flag = ( p_r3_two_bytes_available_w |  ph_zero_r3_bytes_avail_w  ) ;
        if ( h_reg0_q_r[`M_IDX] == 1'b1 )
          if ( h_reg0_q_r[`V_IDX] == 1'b0 )
            p_nmi_b_r = ! ( p_data_available_w[2] | ph_zero_r3_bytes_avail_w  ) ;
          else
            p_nmi_b_r = ! ( p_r3_two_bytes_available_w |  ph_zero_r3_bytes_avail_w  ) ;            
        else
          p_nmi_b_r = 1'b1;        
     end     
   always @ ( p_data_w or 
              p_addr or  
              p_reg0_q_r or            
              p_data_available_w or
              n_flag or
              p_full_w )
     begin
        case ( p_addr )
          3'h0: p_data_r = { p_data_available_w[0], !p_full_w[0], p_reg0_q_r[5:0]};
          3'h1: p_data_r = p_data_w;          
          3'h2: p_data_r = { p_data_available_w[1], !p_full_w[1], 6'b111111};
          3'h3: p_data_r = p_data_w;
          3'h4: p_data_r = { n_flag, !p_full_w[2], 6'b111111};
          3'h5: p_data_r = p_data_w;          
          3'h6: p_data_r = { p_data_available_w[3], !p_full_w[3], 6'b111111};
          3'h7: p_data_r = p_data_w;          
        endcase 
     end     
   always @ ( h_data_w or 
              h_addr or
              h_reg0_q_r or
              h_data_available_w or
              h_full_w )
     begin
        case ( h_addr )
          3'h0: h_data_r = { h_data_available_w[0], !h_full_w[0], h_reg0_q_r[5:0]};
          3'h1: h_data_r = h_data_w;          
          3'h2: h_data_r = { h_data_available_w[1], !h_full_w[1], 6'b111111};
          3'h3: h_data_r = h_data_w;
          3'h4: h_data_r = { h_data_available_w[2], !h_full_w[2], 6'b111111};
          3'h5: h_data_r = h_data_w;          
          3'h6: h_data_r = { h_data_available_w[3], !h_full_w[3], 6'b111111};
          3'h7: h_data_r = h_data_w;
        endcase 
     end     
   hp_bytequad  hp_fifo (
                         .h_rst_b( local_rst_b_w ) ,
                         .h_we_b ( h_rdnw ),
                         .h_selectData( h_select_fifo_q_r ),
                         .h_phi2( h_phi2),
                         .h_data( h_data),
                         .p_selectData( p_select_fifo_r ),
                         .p_phi2(p_phi2),
                         .p_rdnw(p_rdnw),                         
                         .p_data( p_data_w),
                         .one_byte_mode( ! h_reg0_q_r[`V_IDX]),
                         .p_data_available(p_data_available_w),
                         .p_r3_two_bytes_available(p_r3_two_bytes_available_w),
                         .h_full(h_full_w)
                         );
   always @ ( p_addr or p_cs_b or dack_b_w)
     begin
        p_select_fifo_r[0] = !p_cs_b & (( p_addr == 3'h1) & dack_b_w);  
        p_select_fifo_r[1] = !p_cs_b & (( p_addr == 3'h3) & dack_b_w);  
        p_select_fifo_r[2] = !p_cs_b & (( p_addr == 3'h5) | !dack_b_w); 
        p_select_fifo_r[3] = !p_cs_b & (( p_addr == 3'h7) & dack_b_w);  
     end
   ph_bytequad  ph_fifo (
                         .h_rst_b(local_rst_b_w),
                         .h_rd( h_rdnw_q_r ),
                         .h_selectData(  h_select_fifo_q_r),
                         .h_phi2(h_phi2 ),
                         .p_data(p_data),                  
                         .p_selectData(p_select_fifo_r ),
                         .p_phi2(p_phi2),
                         .p_rdnw( (!dack_b_w) ^ p_rdnw),
                         .h_data (h_data_w),                
                         .one_byte_mode( ! h_reg0_q_r[`V_IDX]),  
                         .h_data_available( h_data_available_w),
                         .ph_zero_r3_bytes_avail( ph_zero_r3_bytes_avail_w ),
                         .p_full(p_full_w)
                         );
   assign dft_h_phi2 = test_i ? scan_phi : h_phi2 ;
   always @ ( negedge dft_h_phi2 or negedge h_rst_b )
     if ( ! h_rst_b )
       h_reg0_q_r <= 7'b0;
     else
       h_reg0_q_r <= h_reg0_d_w;
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
   always @ ( posedge p_phi2 or negedge h_rst_b )   
     if ( !h_rst_b )
       p_reg0_q_r <= 6'b000000;
     else
       p_reg0_q_r <= h_reg0_q_r[5:0];
endmodule
