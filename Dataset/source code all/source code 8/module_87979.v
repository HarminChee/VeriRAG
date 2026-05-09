`timescale 1ps/1ps
`timescale 1ps/1ps
module mig_7series_v1_9_ddr_prbs_gen #
  (
   parameter TCQ         = 100,        
   parameter PRBS_WIDTH  = 64          
   )
  (
   input                      clk_i,          
   input                      clk_en_i,       
   input                      rst_i,          
   input [PRBS_WIDTH-1:0]     prbs_seed_i,    
   input                      phy_if_empty,   
   input                      prbs_rdlvl_start, 
   output [PRBS_WIDTH-1:0]    prbs_o 
  );
  function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
  endfunction
  localparam PRBS_SEQ_LEN_CYCLES = 128;
  localparam PRBS_SEQ_LEN_CYCLES_BITS = clogb2(PRBS_SEQ_LEN_CYCLES);
  reg                                 phy_if_empty_r;
  reg                                 reseed_prbs_r;
  reg [PRBS_SEQ_LEN_CYCLES_BITS-1:0]  sample_cnt_r;
  reg [PRBS_WIDTH - 1 :0]             prbs;  
  reg [PRBS_WIDTH :1]                 lfsr_q;
  always @(posedge clk_i) begin
    phy_if_empty_r <= #TCQ phy_if_empty;
  end
  always @(posedge clk_i)
  begin
    if (rst_i || ~clk_en_i) begin
      sample_cnt_r    <= #TCQ 'b0;
      reseed_prbs_r   <= #TCQ 1'b0;
    end else if (clk_en_i && (~phy_if_empty_r || ~prbs_rdlvl_start)) begin
      sample_cnt_r    <= #TCQ sample_cnt_r + 1;
      if (sample_cnt_r == PRBS_SEQ_LEN_CYCLES - 2)
        reseed_prbs_r <= #TCQ 1'b1;
      else
        reseed_prbs_r <= #TCQ 1'b0;
    end
  end
  always @ (posedge clk_i)
  begin
    if ((reseed_prbs_r && clk_en_i) || rst_i || ~clk_en_i) begin
      lfsr_q[4:1]          <= #TCQ prbs_seed_i[3:0] | 4'h5;
      lfsr_q[PRBS_WIDTH:5] <= #TCQ prbs_seed_i[PRBS_WIDTH-1:4];
    end
    else if (clk_en_i && (~phy_if_empty_r || ~prbs_rdlvl_start)) begin
      lfsr_q[PRBS_WIDTH:31] <= #TCQ lfsr_q[PRBS_WIDTH-1:30];
      lfsr_q[30]            <= #TCQ lfsr_q[16] ^ lfsr_q[13] ^ lfsr_q[5]  ^ lfsr_q[1];
      lfsr_q[29:9]          <= #TCQ lfsr_q[28:8];
      lfsr_q[8]             <= #TCQ lfsr_q[32] ^ lfsr_q[7];
      lfsr_q[7]             <= #TCQ lfsr_q[32] ^ lfsr_q[6];
      lfsr_q[6:4]           <= #TCQ lfsr_q[5:3];
      lfsr_q[3]             <= #TCQ lfsr_q[32] ^ lfsr_q[2];
      lfsr_q[2]             <= #TCQ lfsr_q[1] ;
      lfsr_q[1]             <= #TCQ lfsr_q[32];
    end
  end
  always @ (lfsr_q[PRBS_WIDTH:1]) begin
    prbs = lfsr_q[PRBS_WIDTH:1];
  end
  assign prbs_o = prbs;
endmodule
