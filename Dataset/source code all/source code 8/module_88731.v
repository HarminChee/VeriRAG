module fpu_intfloat_conv_except
  (	
	clk, rst, opa, opb, inf, ind, qnan, snan, opa_nan, opb_nan,
	opa_00, opb_00, opa_inf, opb_inf, opa_dn, opb_dn
	);
   input		clk;
   input 		rst;
   input [31:0] 	opa, opb;
   output		inf, ind, qnan, snan, opa_nan, opb_nan;
   output		opa_00, opb_00;
   output		opa_inf, opb_inf;
   output		opa_dn;
   output		opb_dn;
   wire [7:0] 		expa, expb;		
   wire [22:0] 		fracta, fractb;		
   reg 			expa_ff, infa_f_r, qnan_r_a, snan_r_a;
   reg 			expb_ff, infb_f_r, qnan_r_b, snan_r_b;
   reg 			inf, ind, qnan, snan;	
   reg 			opa_nan, opb_nan;
   reg 			expa_00, expb_00, fracta_00, fractb_00;
   reg 			opa_00, opb_00;
   reg 			opa_inf, opb_inf;
   reg 			opa_dn, opb_dn;
   assign   expa = opa[30:23];
   assign   expb = opb[30:23];
   assign fracta = opa[22:0];
   assign fractb = opb[22:0];
   always @(posedge clk or posedge rst)
     if (rst)
       expa_ff <= 1'b0;
     else
       expa_ff <=  &expa;
   always @(posedge clk or posedge rst)
     if (rst)     
       expb_ff <= 1'b0;
     else
       expb_ff <=  &expb;
   always @(posedge clk or posedge rst) 
     if (rst) 
       infa_f_r <= 1'b0; 
     else
       infa_f_r <=  !(|fracta);
   always @(posedge clk or posedge rst) 
     if (rst)
       infb_f_r <= 1'b0; 
     else
       infb_f_r <=  !(|fractb);
   always @(posedge clk or posedge rst) 
     if (rst) 
       qnan_r_a <= 1'b0; 
     else
       qnan_r_a <=   fracta[22];
   always @(posedge clk or posedge rst) 
     if (rst) 
       snan_r_a <= 1'b0; 
     else
       snan_r_a <=  !fracta[22] & |fracta[21:0];
   always @(posedge clk or posedge rst) 
     if (rst) 
       qnan_r_b <= 1'b0; 
     else
       qnan_r_b <=   fractb[22];
   always @(posedge clk or posedge rst) 
     if (rst) 
       snan_r_b <= 1'b0; 
     else
       snan_r_b <=  !fractb[22]; 
   always @(posedge clk or posedge rst) 
     if (rst) 
       ind <= 1'b0; 
     else
       ind  <=  (expa_ff & infa_f_r); 
   always @(posedge clk or posedge rst) 
     if (rst)
       inf <= 1'b0; 
     else
       inf  <=  (expa_ff & infa_f_r); 
   always @(posedge clk or posedge rst) 
     if (rst) 
       qnan <= 1'b0; 
     else
       qnan <=  (expa_ff & qnan_r_a); 
   always @(posedge clk or posedge rst) 
     if (rst) 
       snan <= 1'b0; 
     else
       snan <=  (expa_ff & snan_r_a); 
   always @(posedge clk or posedge rst) 
     if (rst) 
       opa_nan <= 1'b0; 
     else
       opa_nan <=  &expa & (|fracta[22:0]);
   always @(posedge clk or posedge rst) 
     if (rst) 
       opb_nan <= 1'b0; 
     else
       opb_nan <=  &expb & (|fractb[22:0]);
   always @(posedge clk or posedge rst) 
     if (rst) 
       opa_inf <= 1'b0; 
     else
       opa_inf <=  (expa_ff & infa_f_r);
   always @(posedge clk or posedge rst) 
     if (rst) 
       opb_inf <= 1'b0; 
     else
       opb_inf <=  (expb_ff & infb_f_r);
   always @(posedge clk or posedge rst) 
     if (rst)
       expa_00 <= 1'b0; 
     else
       expa_00 <=  !(|expa);
   always @(posedge clk or posedge rst) 
     if (rst)
       expb_00 <= 1'b0;
     else
       expb_00 <=  !(|expb);
   always @(posedge clk or posedge rst) 
     if (rst)
       fracta_00 <= 1'b0; 
     else
       fracta_00 <=  !(|fracta);
   always @(posedge clk or posedge rst) 
     if (rst) 
       fractb_00 <= 1'b0; 
     else
       fractb_00 <=  !(|fractb);
   always @(posedge clk or posedge rst) 
     if (rst) 
       opa_00 <= 1'b0; 
     else
       opa_00 <=  expa_00 & fracta_00;
   always @(posedge clk or posedge rst) 
     if (rst) 
       opb_00 <= 1'b0; 
     else
       opb_00 <=  expb_00 & fractb_00;
   always @(posedge clk or posedge rst) 
     if (rst)
       opa_dn <= 1'b0; 
     else
       opa_dn <=  expa_00;
   always @(posedge clk or posedge rst) 
     if (rst) 
       opb_dn <= 1'b0; 
     else
       opb_dn <=  expb_00;
endmodule 
