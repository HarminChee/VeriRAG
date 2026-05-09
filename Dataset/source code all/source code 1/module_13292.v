module system_controller_altera (
   clk_i, rst_i, nrst_i,
   clk_sys_i, rst_sys_i
   ) ;
   input wire clk_sys_i;
   input wire rst_sys_i;
   output wire clk_i;
   output reg  rst_i;
   output wire nrst_i;
   wire        LOCKED;
   altera_syscon_pll pll(
                         .areset(rst_sys_i),
	                     .inclk0(clk_sys_i),
	                     .c0(clk_i),
	                     .locked(LOCKED)
                         );
   reg [3:0]  rst_count;   
   assign nrst_i = ~rst_i;
   always @(posedge clk_sys_i)
     if (rst_sys_i | ~LOCKED) begin
        rst_i <= 1;       
        rst_count <= 4'hF;        
     end else begin
        if (LOCKED) begin
           if (rst_count) begin
              rst_count <= rst_count - 1;              
           end else begin
              rst_i <= 0;              
           end           
        end        
     end 
endmodule 
