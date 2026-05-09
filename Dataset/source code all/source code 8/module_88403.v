module sounder_rx(clk_i,rst_i,ena_i,sum_strobe_i,ref_strobe_i,
		  mask_i,degree_i,rx_in_i_i,rx_in_q_i,rx_i_o,rx_q_o);
   input         clk_i;		
   input         rst_i;         
   input         ena_i;		
   input         sum_strobe_i;  
   input         ref_strobe_i;  
   input  [15:0] mask_i;	
   input  [4:0]  degree_i;	
   input  [15:0] rx_in_i_i;	
   input  [15:0] rx_in_q_i;	
   output [15:0] rx_i_o;	
   output [15:0] rx_q_o;	
   reg  [31:0] sum_i, sum_q;
   reg  [31:0] total_i, total_q;
   wire [31:0] i_ext, q_ext;
   sign_extend #(16,32) i_extender(rx_in_i_i, i_ext);
   sign_extend #(16,32) q_extender(rx_in_q_i, q_ext);
   wire pn_ref;
   lfsr ref_code
     ( .clk_i(clk_i),.rst_i(rst_i),.ena_i(ena_i),.strobe_i(ref_strobe_i),.mask_i(mask_i),.pn_o(pn_ref) );
   wire [31:0] prod_i = pn_ref ? i_ext : -i_ext;
   wire [31:0] prod_q = pn_ref ? q_ext : -q_ext;
   always @(posedge clk_i)
     if (rst_i | ~ena_i)
       begin
	  sum_i <= #5 0;
	  sum_q <= #5 0;
	  total_i <= #5 0;
	  total_q <= #5 0;
       end
     else
       if (sum_strobe_i)
	 begin
	    total_i <= #5 sum_i;
	    total_q <= #5 sum_q;
	    sum_i <= #5 prod_i;
	    sum_q <= #5 prod_q;
	 end
       else
	 begin
	    sum_i <= #5 sum_i + prod_i;
	    sum_q <= #5 sum_q + prod_q;
	 end
   wire [5:0]  offset = (5'd16-degree_i);
   wire [31:0] scaled_i = total_i << offset;
   wire [31:0] scaled_q = total_q << offset;
   assign rx_i_o = scaled_i[31:16];
   assign rx_q_o = scaled_q[31:16];
endmodule 
