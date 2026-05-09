`timescale 1ps/1ps
`timescale 1ps/1ps
module data_prbs_gen #
  (
    parameter TCQ           = 100,
    parameter EYE_TEST   = "FALSE",
    parameter PRBS_WIDTH = 32,                                                                       
    parameter SEED_WIDTH = 32    
   )
  (
   input           clk_i,
   input           clk_en,
   input           rst_i,
   input [31:0] prbs_fseed_i,
   input           prbs_seed_init,  
   input [PRBS_WIDTH - 1:0]  prbs_seed_i,
   output  [PRBS_WIDTH - 1:0]  prbs_o     
  );
reg [PRBS_WIDTH - 1 :0] prbs;  
reg [PRBS_WIDTH :1] lfsr_q;
integer i;
always @ (posedge clk_i)
begin
   if (prbs_seed_init && EYE_TEST == "FALSE"  || rst_i )  
      begin
        lfsr_q <= #TCQ  {prbs_seed_i + prbs_fseed_i[31:0] + 32'h55555555};
      end
   else   if (clk_en) begin
        lfsr_q[32:9] <= #TCQ  lfsr_q[31:8];
        lfsr_q[8]    <= #TCQ  lfsr_q[32] ^ lfsr_q[7];
        lfsr_q[7]    <= #TCQ  lfsr_q[32] ^ lfsr_q[6];
        lfsr_q[6:4]  <= #TCQ  lfsr_q[5:3];
        lfsr_q[3]    <= #TCQ  lfsr_q[32] ^ lfsr_q[2];
        lfsr_q[2]    <= #TCQ  lfsr_q[1] ;
        lfsr_q[1]    <= #TCQ  lfsr_q[32];
         end
end
always @ (lfsr_q[PRBS_WIDTH:1]) begin
       prbs = lfsr_q[PRBS_WIDTH:1];
end
assign prbs_o = prbs;
endmodule
