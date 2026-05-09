module fifo
   #(
  	parameter adr_width = 4,
	parameter dat_width = 8
   )
   (
    input  clk, reset,
    input  rd, wr,
    input  [dat_width-1:0] data_in,
    output [dat_width-1:0] data_out,
    output empty, 
    output full
   );
   parameter depth = (1 << adr_width);
   reg [dat_width-1:0] array_reg [depth-1:0];
   reg [adr_width-1:0] w_ptr_reg, w_ptr_next;
   reg [adr_width-1:0] r_ptr_reg, r_ptr_next;
   reg full_reg, empty_reg, full_next, empty_next;
   wire wr_en;
	reg	[1:0]	orden;
   assign data_out = array_reg[r_ptr_reg];
   assign wr_en = wr & ~full_reg;
   assign full = full_reg;
   assign empty = empty_reg;
   always @(posedge clk) begin
      if (wr_en)
         array_reg[w_ptr_reg] <= data_in;
   end
   always @(posedge clk, posedge reset) begin
      if (reset)
         begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
         end
      else
         begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
         end
   end
	always @(posedge clk)
	begin
		if(!wr&&rd)
		begin
			orden = 2'b01;
		end
		if(wr&&!rd)
		begin
			orden = 2'b10;
		end
		if(wr&&rd)
		begin
			orden = 2'b11;
		end
	end
	always @(posedge clk)
   begin
      if (reset) begin
	w_ptr_next =  0;
        r_ptr_next =  0;       
      end else begin
	      full_next = full_reg;
	      empty_next = empty_reg;
	      case (orden)
		 2'b01: 
		    if (~empty_reg) 
		       begin
		          r_ptr_next = r_ptr_reg + 1;
		          full_next = 1'b0;
		          if (r_ptr_next==w_ptr_reg)
		             empty_next = 1'b1;
		       end
		 2'b10: 
		    if (~full_reg) 
		       begin
		          w_ptr_next = w_ptr_reg + 1;
		          empty_next = 1'b0;
		          if (w_ptr_next==r_ptr_reg)
		             full_next = 1'b1;
		       end
		 2'b11: 
		    begin
		       w_ptr_next =  w_ptr_reg + 1;
		       r_ptr_next = r_ptr_reg + 1;
		    end
	      endcase
	end
   end
endmodule
