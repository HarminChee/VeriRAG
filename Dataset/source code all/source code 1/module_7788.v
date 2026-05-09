module clock_counter(
	input clk_i,		
	input reset_n,		
	output reg clk_o
		);
		reg [14:0] count;								
		always @ (posedge clk_i, negedge reset_n)			
			begin
				count <= count + 1;						
				if(!reset_n)
					begin
						clk_o <= 0;
						count <= 0;						
					end
				else
					if(count >= 5000)	
						begin							
							clk_o <= ~clk_o;	
							count <= 0;					
						end
			end
endmodule
