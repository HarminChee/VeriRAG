module e16_clock_divider(
   test_i,
   clk_out, clk_out90,
   clk_in, reset, div_cfg
   );
   input       test_i;
   input       clk_in;    
   input       reset;
   input [3:0] div_cfg;   
   output      clk_out;   
   output      clk_out90; 
   reg        clk_out_reg;
   reg [5:0]  counter;   
   reg [5:0]  div_cfg_dec;
   wire div2_sel;   
   wire posedge_match;
   wire negedge_match;  
   wire posedge90_match;
   wire negedge90_match; 
   wire clk_out90_div2;
   wire clk_out90_div4;
   wire clk_out90_div2_in;
   wire clk_out90_div4_in;
   wire dft_clk_out;
   wire dft_clk_out90;

   always @ (div_cfg[3:0])
     begin
	casez (div_cfg[3:0])
	  4'b0000 : div_cfg_dec[5:0] = 6'b000010;  
	  4'b0001 : div_cfg_dec[5:0] = 6'b000100;  
	  4'b0010 : div_cfg_dec[5:0] = 6'b001000;  
	  4'b0011 : div_cfg_dec[5:0] = 6'b010000;  
	  4'b01?? : div_cfg_dec[5:0] = 6'b100000;  
          4'b1??? : div_cfg_dec[5:0] = 6'b100000;  
	  default : div_cfg_dec[5:0] = 6'b000000;
	endcase 
     end 

   assign div2_sel = div_cfg[3:0]==4'b0;

   always @ (posedge clk_in or posedge reset)
     if (reset)
       counter[5:0] <= 6'b000001;   
     else if(posedge_match)
       counter[5:0] <= 6'b000001;
     else
       counter[5:0] <= (counter[5:0]+6'b000001);

   assign posedge_match    = (counter[5:0]==div_cfg_dec[5:0]);
   assign negedge_match    = (counter[5:0]=={1'b0,div_cfg_dec[5:1]}); 
   assign posedge90_match  = (counter[5:0]==({2'b00,div_cfg_dec[5:2]}));
   assign negedge90_match  = (counter[5:0]==({2'b00,div_cfg_dec[5:2]}+{1'b0,div_cfg_dec[5:1]})); 

   always @ (posedge clk_in)
     if(posedge_match)
       clk_out_reg <= 1'b1;
     else if(negedge_match)
       clk_out_reg <= 1'b0;

   assign dft_clk_out = test_i ? clk_in : clk_out_reg;
   assign dft_clk_out90 = test_i ? clk_in : clk_out90;
   assign clk_out = dft_clk_out;
   assign clk_out90 = dft_clk_out90;

endmodule