module t(input wire clk,
         input wire rst_n);
   wire dut_done;
   reg [1:0] state;
   always @(posedge clk or negedge rst_n) begin
      if (! rst_n) begin
         state <= 0;
      end else begin
         if (state == 2'd0) begin
            state <= 2'd1;
         end
         else if (state == 2'd1) begin
            state <= dut_done ? 2'd2 : 2'd1;
         end
         else begin
            $write("*-* All Finished *-*\n");
            $finish;
         end
      end
   end
   wire dut_rst_n = rst_n & (state != 0);
   wire done;
   dut dut_i (.clk   (clk),
              .rst_n (dut_rst_n),
              .done  (dut_done));
endmodule
module dut (input wire  clk,
            input wire  rst_n,
            output wire done);
   reg [3:0] counter;
   always @(posedge clk or negedge rst_n) begin
      if (rst_n & ! clk) begin
         $display("[%0t] %%Error: Oh dear! 'always @(posedge clk or negedge rst_n)' block triggered with clk=%0d, rst_n=%0d.",
                  $time, clk, rst_n);
         $stop;
      end
      if (! rst_n) begin
         counter <= 4'd0;
      end else begin
         counter <= counter < 4'd15 ? counter + 4'd1 : counter;
      end
   end
   assign done = rst_n & (counter == 4'd15);
endmodule
module t(input wire clk,
         input wire rst_n);
   wire dut_done;
   reg [1:0] state;
   always @(posedge clk or negedge rst_n) begin
      if (! rst_n) begin
         state <= 0;
      end else begin
         if (state == 2'd0) begin
            state <= 2'd1;
         end
         else if (state == 2'd1) begin
            state <= dut_done ? 2'd2 : 2'd1;
         end
         else begin
            $write("*-* All Finished *-*\n");
            $finish;
         end
      end
   end
   wire dut_rst_n = rst_n & (state != 0);
   wire done;
   dut dut_i (.clk   (clk),
              .rst_n (dut_rst_n),
              .done  (dut_done));
endmodule
