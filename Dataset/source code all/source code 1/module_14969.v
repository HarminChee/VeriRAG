module test_tools ( ) ;
   reg test_passed = 1'b0;
   reg test_failed = 1'b0;
   reg test_done = 1'b0;
   reg [31:0] test_fail_count = 32'h0000_0000;
   always @(posedge test_passed) begin
      $display("Test Passed @ %d", $time);
      #100 $finish;           
   end
   always @(posedge test_failed) begin
      $display("Test Failed @ %d", $time);
      #100 $finish;           
   end
   always @(posedge test_done) begin
      if (test_fail_count) begin
         test_failed <= 1'b1;         
      end else begin
         test_passed <= 1'b1;         
      end
   end
   task test_case;
      input [32*8-1:0] dstring;
      input [31:0] value;
      input [31:0] expected;
      begin
         if (value !== expected) begin
            test_fail_count <= test_fail_count + 1;         
         end
         $display("%s\t\t0x%h\t\t0x%h\t\t", dstring, value,expected );
      end
   endtask 
endmodule 
