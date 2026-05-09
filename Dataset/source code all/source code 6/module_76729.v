module debouncer (
   clean_out,
   clk, noisy_in
   );
   parameter N  = 20; 
   input  clk;        
   input  noisy_in;   
   output clean_out;  
   wire        expired;   
   wire        sync_in;
   reg [N-1:0] counter;
   wire        filtering;
   synchronizer #(1) synchronizer(.out		(sync_in),
			          .in		(noisy_in),
			          .clk		(clk),
			          .reset	(1'b0));
   always @ (posedge clk)
     if(sync_in)
       counter[N-1:0]={(N){1'b1}};
     else if(filtering)
       counter[N-1:0]=counter[N-1:0]-1'b1;
   assign filtering =|counter[N-1:0];
   assign clean_out = filtering | sync_in;
endmodule 
