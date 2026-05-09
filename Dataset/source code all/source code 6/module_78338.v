module adbg_or1k_biu
  (
   tck_i,
   rst_i,
   data_i,
   data_o,
   addr_i,
   strobe_i,
   rd_wrn_i,           
   rdy_o,
   cpu_clk_i,
   cpu_addr_o,
   cpu_data_i,
   cpu_data_o,
   cpu_stb_o,
   cpu_we_o,
   cpu_ack_i
   );
   input tck_i;
   input rst_i;
   input [31:0] data_i;  
   output [31:0] data_o;
   input [31:0]  addr_i;
   input 	 strobe_i;
   input 	 rd_wrn_i;
   output 	 rdy_o;
   input 	 cpu_clk_i;
   output [31:0] cpu_addr_o;
   input [31:0]  cpu_data_i;
   output [31:0] cpu_data_o;
   output 	 cpu_stb_o;
   output 	 cpu_we_o;
   input 	 cpu_ack_i;
   reg 		 rdy_o;
   reg 		 cpu_stb_o;
   reg [31:0] 	 addr_reg;
   reg [31:0] 	 data_in_reg;  
   reg [31:0] 	 data_out_reg;  
   reg 		 wr_reg;
   reg 		 str_sync;  
   reg 		 rdy_sync;  
   reg 		 rdy_sync_tff1;
   reg 		 rdy_sync_tff2;
   reg 		 rdy_sync_tff2q;  
   reg 		 str_sync_wbff1;
   reg 		 str_sync_wbff2;
   reg 		 str_sync_wbff2q;  
   reg 		 data_o_en;    
   reg 		 rdy_sync_en;  
   wire 	 start_toggle;  
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) begin
	   addr_reg <= 32'h0;
	   data_in_reg <= 32'h0;
	   wr_reg <= 1'b0;
	end
	else
	  if(strobe_i && rdy_o) begin
	     addr_reg <= addr_i;
	     if(!rd_wrn_i) data_in_reg <= data_i;
	     wr_reg <= ~rd_wrn_i;
	  end 
     end
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) str_sync <= 1'b0;
	else if(strobe_i && rdy_o) str_sync <= ~str_sync;
     end 
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) begin
           rdy_sync_tff1 <= 1'b0;
           rdy_sync_tff2 <= 1'b0;
           rdy_sync_tff2q <= 1'b0;
           rdy_o <= 1'b1; 
	end
	else begin  
	   rdy_sync_tff1 <= rdy_sync;       
	   rdy_sync_tff2 <= rdy_sync_tff1;
	   rdy_sync_tff2q <= rdy_sync_tff2;  
	   if(strobe_i && rdy_o) rdy_o <= 1'b0;
	   else if(rdy_sync_tff2 != rdy_sync_tff2q) rdy_o <= 1'b1;
	end
     end 
   assign cpu_data_o = data_in_reg;
   assign cpu_we_o = wr_reg;
   assign cpu_addr_o = addr_reg;
   assign data_o = data_out_reg;
  always @ (posedge cpu_clk_i or posedge rst_i)
	  begin
	     if(rst_i) begin
		str_sync_wbff1 <= 1'b0;
		str_sync_wbff2 <= 1'b0;
		str_sync_wbff2q <= 1'b0;      
	     end
	     else begin
		str_sync_wbff1 <= str_sync;
		str_sync_wbff2 <= str_sync_wbff1;
		str_sync_wbff2q <= str_sync_wbff2;  
	     end
	  end
   assign start_toggle = (str_sync_wbff2 != str_sync_wbff2q);
   always @ (posedge cpu_clk_i or posedge rst_i)
     begin
	if(rst_i) data_out_reg <= 32'h0;
	else if(data_o_en) data_out_reg <= cpu_data_i;
     end
   always @ (posedge cpu_clk_i or posedge rst_i)
     begin
	if(rst_i) rdy_sync <= 1'b0;
	else if(rdy_sync_en) rdy_sync <= ~rdy_sync;
     end 
   reg cpu_fsm_state;
   reg next_fsm_state;
`define STATE_IDLE     1'h0
`define STATE_TRANSFER 1'h1
   always @ (posedge cpu_clk_i or posedge rst_i)
     begin
	if(rst_i) cpu_fsm_state <= `STATE_IDLE;
	else cpu_fsm_state <= next_fsm_state; 
     end
   always @ (cpu_fsm_state or start_toggle or cpu_ack_i)
     begin
	case (cpu_fsm_state)
          `STATE_IDLE:
            begin
               if(start_toggle && !cpu_ack_i) next_fsm_state <= `STATE_TRANSFER;  
               else next_fsm_state <= `STATE_IDLE;
            end
          `STATE_TRANSFER:
            begin
               if(cpu_ack_i) next_fsm_state <= `STATE_IDLE;
               else next_fsm_state <= `STATE_TRANSFER;
            end
	endcase
     end
   always @ (cpu_fsm_state or start_toggle or cpu_ack_i or wr_reg)
     begin
	rdy_sync_en <= 1'b0;
	data_o_en <= 1'b0;
	cpu_stb_o <= 1'b0;
	case (cpu_fsm_state)
          `STATE_IDLE:
            begin
               if(start_toggle) begin
		  cpu_stb_o <= 1'b1;
		  if(cpu_ack_i) begin
                     rdy_sync_en <= 1'b1;
		  end
		  if (cpu_ack_i && !wr_reg) begin  
                     data_o_en <= 1'b1;
		  end
               end
            end
          `STATE_TRANSFER:
            begin
               cpu_stb_o <= 1'b1;  
               if(cpu_ack_i) begin
                  data_o_en <= 1'b1;
                  rdy_sync_en <= 1'b1;
               end
            end
	endcase
     end
endmodule
