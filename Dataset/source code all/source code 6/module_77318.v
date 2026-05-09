`timescale 1ns/1ps
  module pulse_synchronizer
    ( input pulse_in_clkA,
      input clkA,
      output pulse_out_clkB,
      input clkB,
      input reset_clkA,
      input reset_clkB
      );
   reg 	    ackA;
   reg 	    ackB;
   reg 	    ackA_synch;
   reg 	    ackA_clkB;
   reg 	    ackB_synch;
   reg 	    ackB_clkA;
   reg 	    pulse_in_clkA_d1;
   reg 	    ackA_clkB_d1;
   reg 	    ackB_d1;
   always @(posedge clkA) begin
      if(reset_clkA) begin
	 ackA <= 0;
      end
      else if(!pulse_in_clkA_d1 & pulse_in_clkA) begin
	 ackA <= 1;
      end
      else if(ackB_clkA) begin
	 ackA <= 0;
      end
   end 
   always @(posedge clkB) begin
      if(reset_clkB) begin
	 ackB <= 0;
      end
      else if(!ackA_clkB_d1 & ackA_clkB) begin
	 ackB <= 1;
      end
      else if(!ackA_clkB) begin
	 ackB <= 0;
      end
   end 
   assign pulse_out_clkB = ackB & !ackB_d1;
   always @(posedge clkA) begin
      if(reset_clkA) begin
	 pulse_in_clkA_d1 <= 0;
	 ackB_synch <= 0;
	 ackB_clkA <= 0;
      end
      else begin
	 pulse_in_clkA_d1 <= pulse_in_clkA;
	 ackB_synch <= ackB;
	 ackB_clkA <= ackB_synch;
      end
   end
   always @(posedge clkB) begin
      if(reset_clkB) begin
	 ackB_d1 <= 0;
	 ackA_synch <= 0;
	 ackA_clkB <= 0;
	 ackA_clkB_d1 <= 0;
      end
      else begin
	 ackB_d1 <= ackB;
	 ackA_synch <= ackA;
	 ackA_clkB <= ackA_synch;
	 ackA_clkB_d1 <= ackA_clkB;
      end
   end
endmodule 
`timescale 1ns/1ps
  module pulse_synchronizer
    ( input pulse_in_clkA,
      input clkA,
      output pulse_out_clkB,
      input clkB,
      input reset_clkA,
      input reset_clkB
      );
   reg 	    ackA;
   reg 	    ackB;
   reg 	    ackA_synch;
   reg 	    ackA_clkB;
   reg 	    ackB_synch;
   reg 	    ackB_clkA;
   reg 	    pulse_in_clkA_d1;
   reg 	    ackA_clkB_d1;
   reg 	    ackB_d1;
   always @(posedge clkA) begin
      if(reset_clkA) begin
	 ackA <= 0;
      end
      else if(!pulse_in_clkA_d1 & pulse_in_clkA) begin
	 ackA <= 1;
      end
      else if(ackB_clkA) begin
	 ackA <= 0;
      end
   end 
   always @(posedge clkB) begin
      if(reset_clkB) begin
	 ackB <= 0;
      end
      else if(!ackA_clkB_d1 & ackA_clkB) begin
	 ackB <= 1;
      end
      else if(!ackA_clkB) begin
	 ackB <= 0;
      end
   end 
   assign pulse_out_clkB = ackB & !ackB_d1;
   always @(posedge clkA) begin
      if(reset_clkA) begin
	 pulse_in_clkA_d1 <= 0;
	 ackB_synch <= 0;
	 ackB_clkA <= 0;
      end
      else begin
	 pulse_in_clkA_d1 <= pulse_in_clkA;
	 ackB_synch <= ackB;
	 ackB_clkA <= ackB_synch;
      end
   end
   always @(posedge clkB) begin
      if(reset_clkB) begin
	 ackB_d1 <= 0;
	 ackA_synch <= 0;
	 ackA_clkB <= 0;
	 ackA_clkB_d1 <= 0;
      end
      else begin
	 ackB_d1 <= ackB;
	 ackA_synch <= ackA;
	 ackA_clkB <= ackA_synch;
	 ackA_clkB_d1 <= ackA_clkB;
      end
   end
endmodule 
