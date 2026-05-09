module oh_regfile # (parameter REGS  = 32,         
		     parameter RW    = 64,         
		     parameter RP    = 5,          
		     parameter WP    = 3,          
		     parameter RAW   = $clog2(REGS)
		     ) 
   (
    input 	       clk,
    input [WP-1:0]     wr_valid, 
    input [WP*RAW-1:0] wr_addr, 
    input [WP*RW-1:0]  wr_data, 
    input [RP-1:0]     rd_valid, 
    input [RP*RAW-1:0] rd_addr, 
    output [RP*RW-1:0] rd_data 
    );
   reg [RW-1:0]        mem[0:REGS-1];
   wire [WP-1:0]       write_en [0:REGS-1];
   wire [RW-1:0]       datamux [0:REGS-1];
   genvar 	       i,j;
   for(i=0;i<REGS;i=i+1) 
     begin: gen_regwrite
	for(j=0;j<WP;j=j+1) 
	  begin: gen_wp	
	     assign write_en[i][j] = wr_valid[j] & (wr_addr[j*RAW+:RAW] == i);
	  end
     end
   for(i=0;i<REGS;i=i+1) 
     begin: gen_wrmux
	oh_mux #(.DW(RW), .N(WP))
	iwrmux(.out (datamux[i][RW-1:0]),
	       .sel (write_en[i][WP-1:0]),
	       .in  (wr_data[WP*RW-1:0]));
     end
   for(i=0;i<REGS;i=i+1) 
     begin: gen_reg
	always @ (posedge clk)
	  if (|write_en[i][WP-1:0])
	    mem[i] <= datamux[i];
end
   for (i=0;i<RP;i=i+1) begin: gen_rdport
      assign rd_data[i*RW+:RW] = {(RW){rd_valid[i]}} & 
				mem[rd_addr[i*RAW+:RAW]];
   end
endmodule 
