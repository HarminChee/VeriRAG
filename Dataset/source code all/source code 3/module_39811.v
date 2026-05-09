module Encoder #(parameter DATA_BITS = 128, PARITY_BITS = 9)
	(Data_in_08p, Data_valid_08p,reset_b, clk,
     Data_out_10p, Parity_out_10p); 
	parameter k = DATA_BITS;
	parameter r = PARITY_BITS;
	input wire clk, reset_b, Data_valid_08p;
	input wire [k:1] Data_in_08p;
	output reg [k:1] Data_out_10p; 
	output reg [r:1] Parity_out_10p; 
	reg [k:1] Data;
	reg [r:1] Parity;
	reg data_valid_int; 
	always @(posedge clk or negedge reset_b) begin
	  if(~reset_b) begin
		Data <= 'd0;
		data_valid_int <= 'd0;
	    Data_out_10p <= 'd0;
	    Parity_out_10p <= 'd0;
	  end		
	else if(Data_valid_08p) begin
	    data_valid_int <= Data_valid_08p;
		Data <= Data_in_08p;
		if(data_valid_int) begin
	    	Data_out_10p <= Data;
	    	Parity_out_10p <= Parity;
		end	
  	end
   end
	reg [k+r-1:1] data_parity_i; 
	integer i,j,l,cnt;
	reg a;
	always @(Data) begin	  
	  j = 1; l = 1;
	  while ( (j<k+r) || (l<=k)) begin
	    if ( j == ((~j+1)&j)) begin	
	      data_parity_i[j] = 1'b0;
	      j = j+1;
	    end
	    else begin
	      data_parity_i[j] = Data[l];
	      j = j+1; l = l+1;
	    end
	  end
	  for(i=1;i<r;i=i+1) begin
	  	cnt = 1;
		  a = cnt[i-1] & data_parity_i[1];
		  for(cnt=2;cnt<(k+r);cnt=cnt+1) begin
		  	a = a ^ (data_parity_i[cnt] & cnt[i-1]);
		  end
		  Parity[i]	= a;
	  end 
	  Parity[r] = (^Parity[r-1:1])^(^data_parity_i); 
	end
endmodule
