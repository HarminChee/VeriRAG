module integrator
  ( clock,reset,enable,rate,strobe_in,strobe_out,signal_in,signal_out);
   parameter bw = 16;
   parameter maxbitgain = 8;
   input       clock;
   input       reset;
   input       enable;
   input [7:0] rate;
   input       strobe_in;
   input       strobe_out;	
   input  [bw-1:0] signal_in;
   wire   [bw-1:0] signal_out_unreg;
   output [bw-1:0] signal_out;
   reg    [bw-1:0] signal_out;
   wire [bw+maxbitgain-1:0] signal_in_ext;
   reg  [bw+maxbitgain-1:0] accum;
   reg  [bw+maxbitgain-1:0] dump;
   sign_extend #(bw,bw+maxbitgain) 
      ext_input (.in(signal_in),.out(signal_in_ext));
   always @(posedge clock)
     if (reset | ~enable)
       begin
	 accum <= 0;
	 dump <= 0;
       end
     else if (enable && strobe_in)
        if (~strobe_out)
	   accum <= accum + signal_in_ext;
        else
	   begin
	     dump <= accum;
	     accum <= signal_in_ext;
           end
   integ_shifter #(bw)
	shifter(rate,dump,signal_out_unreg);
   always @(posedge clock)
     signal_out <= #1 signal_out_unreg;
endmodule 
