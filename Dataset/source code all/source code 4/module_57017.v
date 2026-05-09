module sub_mod (
   q, test_out,
   test_inout,
   data, clk, reset
   );
   input [7:0] data ;
   input       clk, reset;
   inout       test_inout;  
   output [7:0] q;
   output 	test_out;  
   logic [7:0] 	que;
   assign q = que;
   always @ ( posedge clk)
     if (~reset) begin
        que <= 8'b0;
     end else begin
        que <= data;
     end
endmodule
module t (
   out,
   data, up_down, clk, reset
   );
   output [7:0] out;
   input [7:0] 	data;
   input 	up_down, clk, reset;
   reg [7:0] 	out;
   logic [7:0] 	q_out;
   always @(posedge clk)
     if (reset) begin 
        out <= 8'b0 ;
     end else if (up_down) begin
        out <= out + 1;
     end else begin
        out <= q_out;
     end
   sub_mod sub_mod
     (
      .clk(clk),
      .data(data),
      .reset(reset),
      .q(q_out)
      );
endmodule
module sub_mod (
   q, test_out,
   test_inout,
   data, clk, reset
   );
   input [7:0] data ;
   input       clk, reset;
   inout       test_inout;  
   output [7:0] q;
   output 	test_out;  
   logic [7:0] 	que;
   assign q = que;
   always @ ( posedge clk)
     if (~reset) begin
        que <= 8'b0;
     end else begin
        que <= data;
     end
endmodule
