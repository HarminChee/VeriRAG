module sha256_stream
  (input 	  clk,
   input 	  rst,
   input [511:0]  s_tdata_i,
   input 	  s_tlast_i,
   input 	  s_tvalid_i,
   output 	  s_tready_o,
   output [255:0] digest_o,
   output 	  digest_valid_o);
   reg 		  first_block;
   always @(posedge clk) begin
      if (s_tvalid_i & s_tready_o)
	first_block <= s_tlast_i;
      if (rst) begin
	 first_block <= 1'b1;
      end
   end
   sha256_core core
     (.clk     (clk),
      .reset_n (~rst),
      .init(s_tvalid_i & first_block),
      .next(s_tvalid_i & !first_block),
      .block(s_tdata_i),
      .ready(s_tready_o),
      .digest       (digest_o),
      .digest_valid (digest_valid_o));
endmodule
