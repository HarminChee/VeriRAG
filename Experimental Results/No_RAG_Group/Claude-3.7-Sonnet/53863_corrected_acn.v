`define CFG_FAKECLK   1      
`define CFG_MDW       32     
`define CFG_DW        32     
`define CFG_AW        32     
`define CFG_LW        8      
`define CFG_NW        13     

module e16_clock_divider(
   clk_out, clk_out90,
   clk_in, reset_in, div_cfg
   );
   input       clk_in;    
   input       reset_in;
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

   always @ (posedge clk_in)
     if (reset_in)
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

   assign clk_out    = clk_out_reg;

   // ... rest of code unchanged ...

endmodule