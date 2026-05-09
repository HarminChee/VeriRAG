module oh_clockdiv 
   (
    input 	 clk, 
    input 	 nreset, 
    input 	 clkchange, 
    input 	 clken, 
    input [7:0]  clkdiv, 
    input [15:0] clkphase0, 
    input [15:0] clkphase1, 
    output 	 clkout0, 
    output 	 clkrise0, 
    output 	 clkfall0, 
    output 	 clkout1, 
    output 	 clkrise1, 
    output 	 clkfall1, 
    output 	 clkstable    
    );
   reg [7:0] counter;
   reg 	     clkout0_reg;
   reg 	     clkout1_reg;
   reg 	     clkout1_shift;
   reg [2:0] period;
   wire      period_match;
   wire [3:0] clk1_sel;
   wire [3:0] clk1_sel_sh;
   wire [1:0] clk0_sel;
   wire [1:0] clk0_sel_sh;
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       period[2:0] <= 'b0;   
     else if (clkchange)
       period[2:0] <='b0;      
     else if(period_match & ~clkstable)
       period[2:0] <= period[2:0] +1'b1;
   assign clkstable = (period[2:0]==3'b111);
   always @ (posedge clk or negedge nreset)
     if (!nreset)
       counter[7:0]   <= 'b0;
     else if(clken)
       if(period_match)
	 counter[7:0] <= 'b0;
       else
	 counter[7:0] <= counter[7:0] + 1'b1;
   assign period_match = (counter[7:0]==clkdiv[7:0]);   
   assign clkrise0     = (counter[7:0]==clkphase0[7:0]);   
   assign clkfall0     = (counter[7:0]==clkphase0[15:8]);   
   assign clkrise1     = (counter[7:0]==clkphase1[7:0]);   
   assign clkfall1     = (counter[7:0]==clkphase1[15:8]);   
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       clkout0_reg <= 1'b0;      
     else if(clkrise0)
       clkout0_reg <= 1'b1;
     else if(clkfall0)
       clkout0_reg <= 1'b0;
   assign clk0_sel[1] =  (clkdiv[7:0]==8'd0);   
   assign clk0_sel[0] = ~(clkdiv[7:0]==8'd0);
   oh_lat0 #(.DW(2)) 
   latch_clk0 (.out (clk0_sel_sh[1:0]),
	       .clk (clk),
	       .in  (clk0_sel[1:0]));
   oh_clockmux #(.N(2))
   mux_clk0 (.clkout(clkout0),
	     .en(clk0_sel[1:0]),
	     .clkin({clk, clkout0_reg}));
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       clkout1_reg <= 1'b0;      
     else if(clkrise1)
       clkout1_reg <= 1'b1;
     else if(clkfall1)
       clkout1_reg <= 1'b0;
   always @ (negedge clk)
     clkout1_shift <= clkout1_reg;
   assign clk1_sel[3] =  1'b0;               
   assign clk1_sel[2] = (clkdiv[7:0]==8'd0); 
   assign clk1_sel[1] = (clkdiv[7:0]==8'd1); 
   assign clk1_sel[0] = |clkdiv[7:1];        
   oh_lat0 #(.DW(4)) 
   latch_clk1 (.out (clk1_sel_sh[3:0]),
	       .clk (clk),
	       .in  (clk1_sel[3:0]));
   oh_clockmux #(.N(4))
   mux_clk1 (.clkout(clkout1),
	     .en(clk1_sel[3:0]),
	     .clkin({1'b0, clk, clkout1_shift, clkout1_reg}));
endmodule 
