`timescale 1ps/1ps
`timescale 1ps/1ps
module cmd_prbs_gen #
  (
   parameter TCQ           = 100,
   parameter FAMILY     = "SPARTAN6",
   parameter MEM_BURST_LEN = 8,
   parameter ADDR_WIDTH = 29,
   parameter DWIDTH     = 32,
   parameter PRBS_CMD   = "ADDRESS", 
   parameter PRBS_WIDTH = 64,          
   parameter SEED_WIDTH = 32,           
   parameter PRBS_EADDR_MASK_POS = 32'hFFFFD000,
   parameter PRBS_SADDR_MASK_POS =  32'h00002000,
   parameter PRBS_EADDR  = 32'h00002000,
   parameter PRBS_SADDR  = 32'h00002000
   )
  (
   input         clk_i,
   input         prbs_seed_init,  
   input         clk_en,
   input [SEED_WIDTH-1:0]  prbs_seed_i,
   output[SEED_WIDTH-1:0]  prbs_o     
  );
wire[ADDR_WIDTH - 1:0] ZEROS;
reg [SEED_WIDTH - 1:0] prbs;
reg [PRBS_WIDTH :1] lfsr_q;
assign ZEROS = 'b0;
generate
  if(PRBS_CMD == "ADDRESS" && PRBS_WIDTH == 64) begin :gen64_taps
    always @ (posedge clk_i) begin
      if(prbs_seed_init) begin
        lfsr_q <= #TCQ {31'b0,prbs_seed_i};
      end else if(clk_en) begin
        lfsr_q[64] <= #TCQ lfsr_q[64] ^ lfsr_q[63];
        lfsr_q[63] <= #TCQ lfsr_q[62];
        lfsr_q[62] <= #TCQ lfsr_q[64] ^ lfsr_q[61];
        lfsr_q[61] <= #TCQ lfsr_q[64] ^ lfsr_q[60];
        lfsr_q[60:2] <= #TCQ lfsr_q[59:1];
        lfsr_q[1] <= #TCQ lfsr_q[64];
      end
    end
    always @(lfsr_q[32:1]) begin
      prbs = lfsr_q[32:1];
    end
  end
endgenerate
function integer logb2;
  input [31:0] in;
  integer i;
  begin
    i = in;
      for(logb2=1; i>0; logb2=logb2+1)
        i = i >> 1;
  end
endfunction
generate
  if(PRBS_CMD == "ADDRESS" && PRBS_WIDTH == 32) begin :gen32_taps
    always @ (posedge clk_i) begin
      if(prbs_seed_init) begin 
        lfsr_q <= #TCQ {prbs_seed_i};
      end else if(clk_en) begin
        lfsr_q[32:9] <= #TCQ lfsr_q[31:8];
        lfsr_q[8]    <= #TCQ lfsr_q[32] ^ lfsr_q[7];
        lfsr_q[7]    <= #TCQ lfsr_q[32] ^ lfsr_q[6];
        lfsr_q[6:4]  <= #TCQ lfsr_q[5:3];
        lfsr_q[3]    <= #TCQ lfsr_q[32] ^ lfsr_q[2];
        lfsr_q[2]    <= #TCQ lfsr_q[1] ;
        lfsr_q[1]    <= #TCQ lfsr_q[32];
      end
    end
    integer i;
    always @(lfsr_q[32:1]) begin
     if (FAMILY == "SPARTAN6" ) begin  
      for(i = logb2(DWIDTH) + 1; i <= SEED_WIDTH - 1; i = i + 1)
       if(PRBS_SADDR_MASK_POS[i] == 1)
          prbs[i] = PRBS_SADDR[i] | lfsr_q[i+1];
       else if(PRBS_EADDR_MASK_POS[i] == 1)
          prbs[i] = PRBS_EADDR[i] & lfsr_q[i+1];
       else
          prbs[i] =  lfsr_q[i+1];
       prbs[logb2(DWIDTH )  :0] = {logb2(DWIDTH ) + 1{1'b0}};         
      end
    else begin
     for(i = logb2(MEM_BURST_LEN) - 2; i <= SEED_WIDTH - 1; i = i + 1)
       if(PRBS_SADDR_MASK_POS[i] == 1)
          prbs[i] = PRBS_SADDR[i] | lfsr_q[i+1];
       else if(PRBS_EADDR_MASK_POS[i] == 0)
          prbs[i] = PRBS_EADDR[i] & lfsr_q[i+1];
       else
          prbs[i] = 1'b0;
     prbs[logb2(MEM_BURST_LEN)-3:0] = {logb2(MEM_BURST_LEN) -3{1'b0}};
    end  
  end  
end endgenerate
generate
  if(PRBS_CMD == "INSTR" | PRBS_CMD == "BLEN") begin :gen20_taps
    always @(posedge clk_i) begin
      if(prbs_seed_init) begin
        lfsr_q <= #TCQ {5'b0,prbs_seed_i[14:0]};
      end else if(clk_en) begin
        lfsr_q[20]   <= #TCQ lfsr_q[19];
        lfsr_q[19]   <= #TCQ lfsr_q[18];
        lfsr_q[18]   <= #TCQ lfsr_q[20] ^lfsr_q[17];
        lfsr_q[17:2] <= #TCQ lfsr_q[16:1];
        lfsr_q[1]    <= #TCQ lfsr_q[20];
      end
    end
    always @ (lfsr_q[SEED_WIDTH - 1:1], ZEROS) begin
        prbs = {ZEROS[SEED_WIDTH - 1:7],lfsr_q[6:1]};
    end
  end
endgenerate
assign prbs_o = prbs;
endmodule
