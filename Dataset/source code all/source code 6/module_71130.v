module cic_interp(clock,reset,enable,rate,strobe_in,strobe_out,signal_in,signal_out);
   parameter bw = 16;
   parameter N = 4;
   parameter log2_of_max_rate = 7;
   parameter maxbitgain = (N-1)*log2_of_max_rate;
   input clock;
   input reset;
   input enable;
   input [7:0] rate;
   input strobe_in,strobe_out;	
   input [bw-1:0] signal_in;
   wire [bw-1:0] 	signal_in;
   output [bw-1:0] signal_out;
   wire [bw-1:0]   signal_out;
   wire [bw+maxbitgain-1:0] signal_in_ext;
   reg [bw+maxbitgain-1:0] integrator [0:N-1];
   reg [bw+maxbitgain-1:0] differentiator [0:N-1];
   reg [bw+maxbitgain-1:0] pipeline [0:N-1];
   integer i;
   sign_extend #(bw,bw+maxbitgain) 
      ext_input (.in(signal_in),.out(signal_in_ext));
   wire    clear_me = reset | ~enable;
   always @(posedge clock)
     if(clear_me)
       for(i=0;i<N;i=i+1)
	 integrator[i] <= #1 0;
     else if (enable & strobe_out)
       begin
	  if(strobe_in)
	    integrator[0] <= #1 integrator[0] + pipeline[N-1];
	  for(i=1;i<N;i=i+1)
	    integrator[i] <= #1 integrator[i] + integrator[i-1];
       end
   always @(posedge clock)
     if(clear_me)
       begin
	  for(i=0;i<N;i=i+1)
	    begin
	       differentiator[i] <= #1 0;
	       pipeline[i] <= #1 0;
 	    end
       end
     else if (enable && strobe_in)
       begin
	  differentiator[0] <= #1 signal_in_ext;
	  pipeline[0] <= #1 signal_in_ext - differentiator[0];
	  for(i=1;i<N;i=i+1)
	    begin
	       differentiator[i] <= #1 pipeline[i-1];
	       pipeline[i] <= #1 pipeline[i-1] - differentiator[i];
	    end
       end
   wire [bw+maxbitgain-1:0] signal_out_unnorm = integrator[N-1];
   cic_int_shifter #(bw)
	cic_int_shifter(rate,signal_out_unnorm,signal_out);
endmodule 
