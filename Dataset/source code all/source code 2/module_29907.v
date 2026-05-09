`timescale 1 ns / 10 ps
`timescale 1 ns / 10 ps
module cpu_rd 
  (
   input             g_memwr,
   input             g_cpu_cycle_done,
   input             g_cpu_data_done,
   input             c_misc_b1,
   input             h_svga_sel,   
   input             hreset_n,
   input             g_memrd,
   input             cpu_rd_gnt,
   input             svga_ack,
   input             t_data_ready_n,
   input             mem_clk,    	         
   input [31:0]      m_t_mem_data_in,  
   output reg        cpu_rd_req, 	
   output reg        cpu_rd_svga_req,    
   output reg [31:0] g_graph_data_in,
   output            m_memrd_ready_n,
   output reg        m_cpurd_state1,
   output reg        m_cpurd_s0,
   output            en_cpurd_addr
   );
  reg 		     cpurd_s2;
  reg 		     cpurd_s3;
  reg 		     cpurd_s4;
  reg [2:0] 	     current_state;
  reg [2:0] 	     next_state;
  wire [22:3] 	     int_mem_addr;  
  wire [22:3] 	     int_rdmem_add;
  wire [63:0] 	     mem_data_df1;
  wire 		     dummy_out_1;
  wire 		     int_d_dly;
  wire 		     mem_clk_dly;
  parameter 	     cpurd_state0 = 3'b000,
                     cpurd_state1 = 3'b001,
	             cpurd_state2 = 3'b011,
	             cpurd_state4 = 3'b111,
	             cpurd_state3 = 3'b110;
  always @ (posedge mem_clk or negedge hreset_n) begin
    if (!hreset_n) current_state <= cpurd_state0;
    else              current_state <= next_state;
  end
  always @* begin
    m_cpurd_s0        = 1'b0;
    cpu_rd_req 	      = 1'b0;
    m_cpurd_state1    = 1'b0;
    cpu_rd_svga_req   = 1'b0;
    cpurd_s2          = 1'b0;
    cpurd_s3          = 1'b0;
    cpurd_s4          = 1'b0;
    case (current_state) 
      cpurd_state0: begin
	m_cpurd_s0 = 1'b1;
        if (g_memrd & h_svga_sel & c_misc_b1) 
	  next_state = cpurd_state1;
	else
	  next_state = cpurd_state0;
      end
      cpurd_state1:
	begin
	  cpu_rd_req     = 1'b1;
	  m_cpurd_state1 = 1'b1;
	  if (cpu_rd_gnt) 
	    next_state = cpurd_state2;
	  else
	    next_state = cpurd_state1;
	end
      cpurd_state2:
	begin
	  cpu_rd_req      = 1'b1;
	  cpu_rd_svga_req = 1'b1;
	  cpurd_s2        = 1'b1;
	  if (svga_ack) 
	    next_state = cpurd_state4;
	  else 
	    next_state = cpurd_state2;
	end
      cpurd_state4:
	begin
	  cpurd_s4	    = 1'b1;
	  cpu_rd_req        = 1'b1;
	  if (g_cpu_cycle_done)
	    next_state   = cpurd_state3;
	  else
	    next_state   = cpurd_state2;
	end
      cpurd_state3:
	begin 
	  cpu_rd_req = 1'b1;
          cpurd_s3   = 1'b1;
	  if (g_cpu_data_done) 
	    next_state = cpurd_state0;
	  else
	    next_state = cpurd_state3;
	end
    endcase
  end  			
  assign en_cpurd_addr = g_memwr & cpu_rd_gnt;      
  assign   m_memrd_ready_n = ~(g_cpu_cycle_done& cpu_rd_gnt & ~t_data_ready_n);
  always @* g_graph_data_in = m_t_mem_data_in;
endmodule       
