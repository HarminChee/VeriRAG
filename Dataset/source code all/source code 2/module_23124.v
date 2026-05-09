`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module bios_internal
	(
	 input hb_clk,
	 input hresetn,
	input	 bios_clk,
	input	 bios_wdat,
	input	 bios_csn,
	output	 reg bios_rdat
	);
	reg [31:0]  instruction_address_reg;
	reg [23:0]  read_address;
	wire [15:0] rdata16;
   reg [4:0] 	    counter;
   reg [1:0] 	    prom_cs;
	parameter read_cmd = 8'b00000011;
   parameter IDLE = 0, DATA_OUT = 1, WAIT = 2, DATA_OUT1 = 3;
   always @(posedge hb_clk, negedge hresetn) begin
      if (!hresetn) begin
	 instruction_address_reg <= 'h0;
	 counter <= 0;
	 prom_cs <= IDLE;
      end else begin
	 case (prom_cs)
	   IDLE: begin
	      if (!bios_csn && bios_clk) begin
		 counter <= counter + 1;
		 instruction_address_reg[~counter] <= bios_wdat;
		 if (counter == 'h1e) begin
		    prom_cs <= WAIT;
		    counter <= 0;
		 end
	      end else if (bios_csn)
		counter <= 0;
	   end 
	   WAIT: prom_cs <= DATA_OUT;
	   DATA_OUT: begin
	      if (!bios_csn && !bios_clk) begin
		 counter <= counter + 1;
		 prom_cs <= DATA_OUT1;
	      end else if (bios_csn)
		 prom_cs <= IDLE;
	   end
	   DATA_OUT1: begin
	      if (!bios_csn && !bios_clk) begin
		 counter <= counter + 1;
		 if (counter == 'hf) 
		   instruction_address_reg <= instruction_address_reg + 2;
		 if (~|counter) prom_cs <= IDLE;
	      end else if (bios_csn)
		 prom_cs <= IDLE;
	   end
	 endcase 
      end 
   end 
   wire [2:0] inv_counter;
   assign inv_counter = ~counter[2:0];
   always @* 
      bios_rdat = rdata16[{~counter[3], inv_counter}];
   bios_rom u_bios_rom
     (
      .clock		(bios_clk),
      .address	(instruction_address_reg[15:1]), 
      .q		(rdata16)		
      );
endmodule
