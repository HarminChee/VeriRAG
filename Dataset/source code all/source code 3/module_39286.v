module comparator_tb1(SW, status_leds, seg7_0, seg7_1, seg7_2, seg7_3);
   parameter n = 2;
   output wire [9:0] status_leds;							
   output wire [0:6] seg7_0, seg7_1, seg7_2, seg7_3;	
	input wire [9:0] SW;
	wire eqbit, gtbit, ltbit;
   wire eqdbbit, gtdbbit, ltdbbit;		
   wire negative_is_allowed = SW[9]; 	
   reg unsigned [2*n-1:0] x, y;				
   reg x_negative, y_negative;       	
   always @(SW)
   begin: switchAssignments
		x[0] = SW[4];	
		x[1] = SW[5];
		x[2] = SW[6];
		x[3] = SW[7];
		y[0] = SW[0];
		y[1] = SW[1];
		y[2] = SW[2];
		y[3] = SW[3];
		if (x_negative)		
			x = ~x + 4'b0001; 
		if (y_negative)		
			y = ~y + 4'b0001;	
   end
   assign status_leds[9] = negative_is_allowed;
   assign status_leds[8] = 1'b0;	
	always @(negative_is_allowed, SW)
	begin: determineNegative
		x_negative = SW[7] & negative_is_allowed; 
		y_negative = SW[3] & negative_is_allowed;
	end
   wire [n:0] eqcarry, gtcarry, ltcarry;
   assign eqcarry[0] = 1;	
   assign gtcarry[0] = 0;	
   assign ltcarry[0] = 0;
   generate
      genvar k;
 	      for (k = 0; k < 2*n; k = k + 2)  
	      begin: comparestage
			   doublencomparator dnc((x[2*n-1-k]), (x[2*n-2-k]), (y[2*n-1-k]), (y[2*n-2-k]),
	                              (eqcarry[k/2]), (gtcarry[k/2]), (ltcarry[k/2]),
	                              (eqcarry[k/2+1]), (gtcarry[k/2+1]), (ltcarry[k/2+1]));  
			end
   endgenerate
   assign eqbit = eqcarry[n] & ~(x_negative ^ y_negative); 
   assign gtbit = ((~gtcarry[n] & y_negative) | (gtcarry[n] & ~x_negative)) & ~eqbit;
   assign ltbit = ~(eqbit | gtbit);
   assign status_leds[7] = eqbit;
   assign status_leds[6] = gtbit;
	assign status_leds[5] = ltbit;
	seg7 hex2(.bnum(x), .led(seg7_2));	
	seg7 hex0(.bnum(y), .led(seg7_0));	
	assign seg7_3[0:5] = 6'b111111;
	assign seg7_1[0:5] = 6'b111111;
	assign seg7_3[6] = ~x_negative;		
	assign seg7_1[6] = ~y_negative;
   assign eqdbbit = (x == y) & (x_negative == y_negative);
   assign gtdbbit = ((~(x > y) & y_negative) | ((x > y) & ~x_negative)) & ~eqdbbit;	
   assign ltdbbit = ~(eqdbbit | gtdbbit);
   assign status_leds[3] = eqdbbit;
   assign status_leds[2] = gtdbbit;
   assign status_leds[1] = ltdbbit;
   assign status_leds[0] = {eqdbbit, gtdbbit, ltdbbit} == {eqbit, gtbit, ltbit};	
endmodule 
