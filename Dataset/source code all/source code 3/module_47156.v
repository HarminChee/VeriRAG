module oh_par2ser #(parameter PW = 64, 
		    parameter SW = 1,  
		    parameter CW = $clog2(PW/SW)  
		    )
   (
    input 	    clk, 
    input 	    nreset, 
    input [PW-1:0]  din, 
    output [SW-1:0] dout, 
    output 	    access_out,
    input 	    load, 
    input 	    shift, 
    input [7:0]     datasize, 
    input 	    lsbfirst, 
    input 	    fill, 
    input 	    wait_in, 
    output 	    wait_out 
    );
   reg [PW-1:0]    shiftreg;
   reg [CW-1:0]    count;
   wire 	   start_transfer;
   wire 	   busy;
   assign start_transfer = load &  ~wait_in & ~busy;
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       count[CW-1:0] <= 'b0;   
     else if(start_transfer)
       count[CW-1:0] <= datasize[CW-1:0];  
     else if(shift & busy)
       count[CW-1:0] <= count[CW-1:0] - 1'b1;
   assign busy = |count[CW-1:0];
   assign access_out = busy;
   assign wait_out  = wait_in | busy;
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       shiftreg[PW-1:0] = 'b0;   
     else if(start_transfer)
       shiftreg[PW-1:0] = din[PW-1:0];
     else if(shift & lsbfirst)		 
       shiftreg[PW-1:0] = {{(SW){fill}}, shiftreg[PW-1:SW]};
     else if(shift)
       shiftreg[PW-1:0] = {shiftreg[PW-SW-1:0],{(SW){fill}}};
   assign dout[SW-1:0] = lsbfirst ? shiftreg[SW-1:0] : 
			            shiftreg[PW-1:PW-SW];	
endmodule 
