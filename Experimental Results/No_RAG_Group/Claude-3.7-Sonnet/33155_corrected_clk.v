module system_controller_xilinx (
                                 clk_i, rst_i, nrst_i,
                                 clk_sys_i, rst_sys_i
                                 ) ;
   input wire clk_sys_i;
   input wire rst_sys_i;
   output wire clk_i;
   output reg  rst_i;
   output wire nrst_i;
   wire        xclk_buf;
   wire        clk_buf;
   
   IBUF clk_ibuf(.I(clk_sys_i), .O(xclk_buf));
   
   BUFGCE clk_buf_inst (
                   .CE(1'b1),
                   .O(clk_i), 
                   .I(xclk_buf)
                   );

   wire LOCKED;
   assign nrst_i = ~rst_i;
   
   reg [3:0]  rst_count;   
   
   always @(posedge clk_i)
     if (rst_sys_i) begin
        rst_i <= 1;       
        rst_count <= 4'hF;        
     end else begin
        if (rst_count) begin
           rst_count <= rst_count - 1;              
        end else begin
           rst_i <= 0;              
        end           
     end 
endmodule