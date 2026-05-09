`timescale 1ns/100ps
`timescale 1ns/100ps
module firdecim_m4_n12(
   dsp_out, outValid,
   dsp_in0, dsp_in1, dsp_in2, dsp_in3, ein, new_e, clk, rst, inValid
   );
   parameter OWIDTH = 16;
   parameter IWIDTH = 8;
   parameter ACCUMWIDTH = 24;
   parameter CNTWIDTH = 2;  
   output signed [(OWIDTH-1):0] dsp_out;
   output 			outValid;
   input signed [(IWIDTH-1):0] 	dsp_in0;   
   input signed [(IWIDTH-1):0] 	dsp_in1;
   input signed [(IWIDTH-1):0] 	dsp_in2;
   input signed [(IWIDTH-1):0] 	dsp_in3;
   input signed [(OWIDTH-1):0] 	ein;
   input 			new_e;
   input 			clk;
   input 			rst;
   input 			inValid;
   reg signed [15:0] 		eff0;       
   reg signed [15:0] 		eff1;
   reg signed [15:0] 		eff2;
   reg signed [15:0] 		eff3;
   reg signed [15:0] 		eff4;
   reg signed [15:0] 		eff5;
   reg signed [15:0] 		eff6;
   reg signed [15:0] 		eff7;
   reg signed [15:0] 		eff8;
   reg signed [15:0] 		eff9;
   reg signed [15:0] 		effA;
   reg signed [15:0] 		effB;
   reg signed [(ACCUMWIDTH-1):0] mul00;      
   reg signed [(ACCUMWIDTH-1):0] mul01;
   reg signed [(ACCUMWIDTH-1):0] mul02;
   reg signed [(ACCUMWIDTH-1):0] mul03;
   reg signed [(ACCUMWIDTH-1):0] mul10;
   reg signed [(ACCUMWIDTH-1):0] mul11;
   reg signed [(ACCUMWIDTH-1):0] mul12;
   reg signed [(ACCUMWIDTH-1):0] mul13;
   reg signed [(ACCUMWIDTH-1):0] mul20;
   reg signed [(ACCUMWIDTH-1):0] mul21;
   reg signed [(ACCUMWIDTH-1):0] mul22;
   reg signed [(ACCUMWIDTH-1):0] mul23;
   reg signed [(ACCUMWIDTH-1):0] acc0;       
   reg signed [(ACCUMWIDTH-1):0] acc1;
   reg signed [(ACCUMWIDTH-1):0] acc2;
   reg 				 inValid_z;
   reg [(CNTWIDTH-1):0] 	 cnt;
   reg 				 outValid;
   reg signed [(OWIDTH-1):0] 	 dsp_out;   
   wire signed [(ACCUMWIDTH-1):0] result;   
   always @ (posedge clk or posedge rst)
     if (rst)
       begin
          eff0[15:0] <= 16'd0;
          eff1[15:0] <= 16'd0;
          eff2[15:0] <= 16'd0;
          eff3[15:0] <= 16'd0;
          eff4[15:0] <= 16'd0;
          eff5[15:0] <= 16'd0;
          eff6[15:0] <= 16'd0;
          eff7[15:0] <= 16'd0;
          eff8[15:0] <= 16'd0;
          eff9[15:0] <= 16'd0;
          effA[15:0] <= 16'd0;
          effB[15:0] <= 16'd0;
       end 
     else if (new_e)
       begin
          eff0[15:0] <= ein[15:0];
          eff1[15:0] <= eff0[15:0];
          eff2[15:0] <= eff1[15:0];
          eff3[15:0] <= eff2[15:0];
          eff4[15:0] <= eff3[15:0];
          eff5[15:0] <= eff4[15:0];
          eff6[15:0] <= eff5[15:0];
          eff7[15:0] <= eff6[15:0];
          eff8[15:0] <= eff7[15:0];
          eff9[15:0] <= eff8[15:0];
          effA[15:0] <= eff9[15:0];
          effB[15:0] <= effA[15:0];
       end 
     else if (inValid)
       begin
          eff0[15:0] <= eff4[15:0];
          eff1[15:0] <= eff5[15:0];
          eff2[15:0] <= eff6[15:0];
          eff3[15:0] <= eff7[15:0];
          eff4[15:0] <= eff8[15:0];
          eff5[15:0] <= eff9[15:0];
          eff6[15:0] <= effA[15:0];
          eff7[15:0] <= effB[15:0];
          eff8[15:0] <= eff0[15:0];
          eff9[15:0] <= eff1[15:0];
          effA[15:0] <= eff2[15:0];
          effB[15:0] <= eff3[15:0];          
    end 
   always @ (posedge clk or posedge rst)
     if (rst)
       begin
          cnt[(CNTWIDTH-1):0]   <= {(CNTWIDTH){1'b0}};
       end
     else
       begin
          cnt[(CNTWIDTH-1):0]   <= (cnt == 2) ? 
				   0 : 
				   cnt[(CNTWIDTH-1):0] + inValid;
       end
   always @ (posedge clk or posedge rst)
     if (rst)
       begin
          mul00[(ACCUMWIDTH-1):0] <= {(ACCUMWIDTH){1'b0}};
          mul01[(ACCUMWIDTH-1):0] <= {(ACCUMWIDTH){1'b0}};
          mul02[(ACCUMWIDTH-1):0] <= {(ACCUMWIDTH){1'b0}};
          mul03[(ACCUMWIDTH-1):0] <= {(ACCUMWIDTH){1'b0}};
          mul10[(ACCUMWIDTH-1):0] <= {(ACCUMWIDTH){1'b0}};
          mul11[(ACCUMWIDTH-1):0] <= {(ACCUMWIDTH){1'b0}};
          mul12[(ACCUMWIDTH-1):0] <= {(ACCUMWIDTH){1'b0}};
          mul13[(ACCUMWIDTH-1):0] <= {(ACCUMWIDTH){1'b0}};
          mul20[(ACCUMWIDTH-1):0] <= {(ACCUMWIDTH){1'b0}};
          mul21[(ACCUMWIDTH-1):0] <= {(ACCUMWIDTH){1'b0}};
          mul22[(ACCUMWIDTH-1):0] <= {(ACCUMWIDTH){1'b0}};
          mul23[(ACCUMWIDTH-1):0] <= {(ACCUMWIDTH){1'b0}};
       end 
     else if (inValid)
       begin
          mul00[(ACCUMWIDTH-1):0] <= dsp_in0 * eff0;
          mul01[(ACCUMWIDTH-1):0] <= dsp_in1 * eff1;
          mul02[(ACCUMWIDTH-1):0] <= dsp_in2 * eff2;
          mul03[(ACCUMWIDTH-1):0] <= dsp_in3 * eff3;
          mul10[(ACCUMWIDTH-1):0] <= dsp_in0 * eff8;
          mul11[(ACCUMWIDTH-1):0] <= dsp_in1 * eff9;
          mul12[(ACCUMWIDTH-1):0] <= dsp_in2 * effA;
          mul13[(ACCUMWIDTH-1):0] <= dsp_in3 * effB;
          mul20[(ACCUMWIDTH-1):0] <= dsp_in0 * eff4;
          mul21[(ACCUMWIDTH-1):0] <= dsp_in1 * eff5;
          mul22[(ACCUMWIDTH-1):0] <= dsp_in2 * eff6;
          mul23[(ACCUMWIDTH-1):0] <= dsp_in3 * eff7;
       end 
   always @ (posedge clk or posedge rst)
     if (rst)
       begin
          acc0[(ACCUMWIDTH-1):0]  <= {(ACCUMWIDTH){1'b0}};
          acc1[(ACCUMWIDTH-1):0]  <= {(ACCUMWIDTH){1'b0}};
          acc2[(ACCUMWIDTH-1):0]  <= {(ACCUMWIDTH){1'b0}};
       end
     else if (inValid_z)
       begin
          acc0[(ACCUMWIDTH-1):0]  <= mul00 + mul01 + mul02 + mul03 + 
				     ({(ACCUMWIDTH){cnt[(CNTWIDTH-1):0]==(2)|
						    cnt[(CNTWIDTH-1):0]==(0)} } 
				      & acc0[(ACCUMWIDTH-1):0]                 );
          acc1[(ACCUMWIDTH-1):0]  <= mul10 + mul11 + mul12 + mul13 + 
				     ({(ACCUMWIDTH){cnt[(CNTWIDTH-1):0]==(1)|
						    cnt[(CNTWIDTH-1):0]==(0)} } 
				      & acc1[(ACCUMWIDTH-1):0]                 );
          acc2[(ACCUMWIDTH-1):0]  <= mul20 + mul21 + mul22 + mul23 + 
				     ({(ACCUMWIDTH){cnt[(CNTWIDTH-1):0]==(1)|
						    cnt[(CNTWIDTH-1):0]==(2)} } 
				      & acc2[(ACCUMWIDTH-1):0]                 );
       end
   assign result[(ACCUMWIDTH-1):0] = ({(ACCUMWIDTH){cnt==1}} & acc0[(ACCUMWIDTH-1):0]) |
				     ({(ACCUMWIDTH){cnt==2}} & acc1[(ACCUMWIDTH-1):0]) |
				     ({(ACCUMWIDTH){cnt==0}} & acc2[(ACCUMWIDTH-1):0]) ;
   always @ (posedge clk or posedge rst)
     if (rst)
       begin
          inValid_z            <= 0;
          outValid             <= 0;
          dsp_out[(OWIDTH-1):0]<= {(OWIDTH){1'b0}};
       end
     else
       begin
          inValid_z            <= inValid;
          outValid             <= inValid_z;
          dsp_out[(OWIDTH-1):0]<= inValid_z ? 
				  result[(ACCUMWIDTH-3):(ACCUMWIDTH-OWIDTH-2)] : 
				  dsp_out[(OWIDTH-1):0];
       end
endmodule 
