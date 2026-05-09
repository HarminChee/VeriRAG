module settings_bus_16LE
  #(parameter AWIDTH=16, RWIDTH=8)
    (input wb_clk, 
     input wb_rst, 
     input [AWIDTH-1:0] wb_adr_i,
     input [15:0] wb_dat_i,
     input wb_stb_i,
     input wb_we_i,
     output reg wb_ack_o,
     output strobe,
     output reg [7:0] addr,
     output reg [31:0] data);
   reg 		       stb_int;
   always @(posedge wb_clk)
     if(wb_rst)
       begin
	  stb_int <= 1'b0;
	  addr <= 8'd0;
	  data <= 32'd0;
       end
     else if(wb_we_i & wb_stb_i)
       begin
	  addr <= wb_adr_i[RWIDTH+1:2];  
	  if(wb_adr_i[1])
	    begin
	       stb_int <= 1'b1;     
	       data[31:16] <= wb_dat_i;
	    end
	  else
	    begin
	       stb_int <= 1'b0;     
	       data[15:0] <= wb_dat_i;
	    end
       end
     else
       stb_int <= 1'b0;
   always @(posedge wb_clk)
     if(wb_rst)
       wb_ack_o <= 0;
     else
       wb_ack_o <= wb_stb_i & ~wb_ack_o;
   assign strobe = stb_int & wb_ack_o;
endmodule 
