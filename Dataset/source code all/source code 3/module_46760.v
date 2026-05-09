`timescale 1ps/1ps
`timescale 1ps/1ps
module mig_7series_v2_3_tg_prbs_gen #
  (
   parameter TCQ         = 100,        
   parameter PRBS_WIDTH  = 10,         
   parameter nCK_PER_CLK = 4           
   )
  (
   input                      clk_i,          
   input                      clk_en_i,       
   input                      rst_i,          
   input [PRBS_WIDTH-1:0]     prbs_seed_i,    
   output [2*nCK_PER_CLK-1:0] prbs_o,         
   output [31:0]              ReSeedcounter_o 
  );
  function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
  endfunction
  localparam PRBS_SEQ_LEN_CYCLES = (2**PRBS_WIDTH) / (2*nCK_PER_CLK);
  localparam PRBS_SEQ_LEN_CYCLES_BITS = clogb2(PRBS_SEQ_LEN_CYCLES);
  reg [PRBS_WIDTH-1:0]                lfsr_reg_r;
  wire [PRBS_WIDTH-1:0]               next_lfsr_reg;
  reg [PRBS_WIDTH-1:0]                reseed_cnt_r;
  reg                                 reseed_prbs_r;
  reg [PRBS_SEQ_LEN_CYCLES_BITS-1:0]  sample_cnt_r;
  genvar                              i;
  assign ReSeedcounter_o = {{(32-PRBS_WIDTH){1'b0}}, reseed_cnt_r};
  always @ (posedge clk_i)
    if (rst_i)
      reseed_cnt_r <= 'b0;
    else if (clk_en_i)
      if (reseed_cnt_r == {PRBS_WIDTH {1'b1}})
        reseed_cnt_r <= 'b0;
      else
        reseed_cnt_r <= reseed_cnt_r + 1;
  always @(posedge clk_i)
    if (rst_i) begin
      sample_cnt_r <= #TCQ 'b0;
      reseed_prbs_r   <= #TCQ 1'b0;
    end else if (clk_en_i) begin
      sample_cnt_r <= #TCQ sample_cnt_r + 1;
      if (sample_cnt_r == PRBS_SEQ_LEN_CYCLES - 2)
        reseed_prbs_r <= #TCQ 1'b1;
      else
        reseed_prbs_r <= #TCQ 1'b0;
    end
  always @(posedge clk_i)
    if (rst_i)
      lfsr_reg_r <= #TCQ prbs_seed_i;
    else if (clk_en_i)
      if (reseed_prbs_r)
        lfsr_reg_r <= #TCQ prbs_seed_i;
      else begin
        lfsr_reg_r <= #TCQ next_lfsr_reg;
      end
  generate
    if (PRBS_WIDTH == 8) begin: gen_next_lfsr_prbs8
      if (nCK_PER_CLK == 2) begin: gen_ck_per_clk2
        assign next_lfsr_reg[7] = lfsr_reg_r[3];
        assign next_lfsr_reg[6] = lfsr_reg_r[2];
        assign next_lfsr_reg[5] = lfsr_reg_r[1];
        assign next_lfsr_reg[4] = lfsr_reg_r[0];
        assign next_lfsr_reg[3] = ~(lfsr_reg_r[7] ^ lfsr_reg_r[5] ^
                                    lfsr_reg_r[4] ^ lfsr_reg_r[3]);
        assign next_lfsr_reg[2] = ~(lfsr_reg_r[6] ^ lfsr_reg_r[4] ^
                                    lfsr_reg_r[3] ^ lfsr_reg_r[2]);
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[5] ^ lfsr_reg_r[3] ^
                                    lfsr_reg_r[2] ^ lfsr_reg_r[1]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[4] ^ lfsr_reg_r[2] ^
                                    lfsr_reg_r[1] ^ lfsr_reg_r[0]);
      end else if (nCK_PER_CLK == 4) begin: gen_ck_per_clk4
        assign next_lfsr_reg[7] = ~(lfsr_reg_r[7] ^ lfsr_reg_r[5] ^
                                    lfsr_reg_r[4] ^ lfsr_reg_r[3]);
        assign next_lfsr_reg[6] = ~(lfsr_reg_r[6] ^ lfsr_reg_r[4] ^
                                    lfsr_reg_r[3] ^ lfsr_reg_r[2]) ;
        assign next_lfsr_reg[5] = ~(lfsr_reg_r[5] ^ lfsr_reg_r[3] ^
                                    lfsr_reg_r[2] ^ lfsr_reg_r[1]);
        assign next_lfsr_reg[4] = ~(lfsr_reg_r[4] ^ lfsr_reg_r[2] ^
                                    lfsr_reg_r[1] ^ lfsr_reg_r[0]);
        assign next_lfsr_reg[3] = ~(lfsr_reg_r[3] ^ lfsr_reg_r[1] ^
                                    lfsr_reg_r[0] ^ next_lfsr_reg[7]);
        assign next_lfsr_reg[2] = ~(lfsr_reg_r[2]    ^ lfsr_reg_r[0] ^
                                    next_lfsr_reg[7] ^ next_lfsr_reg[6]);
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[1]    ^ next_lfsr_reg[7] ^
                                    next_lfsr_reg[6] ^ next_lfsr_reg[5]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[0]    ^ next_lfsr_reg[6] ^
                                    next_lfsr_reg[5] ^ next_lfsr_reg[4]);
      end
    end else if (PRBS_WIDTH == 10) begin: gen_next_lfsr_prbs10
      if (nCK_PER_CLK == 2) begin: gen_ck_per_clk2
        assign next_lfsr_reg[9] = lfsr_reg_r[5];
        assign next_lfsr_reg[8] = lfsr_reg_r[4];
        assign next_lfsr_reg[7] = lfsr_reg_r[3];
        assign next_lfsr_reg[6] = lfsr_reg_r[2];
        assign next_lfsr_reg[5] = lfsr_reg_r[1];
        assign next_lfsr_reg[4] = lfsr_reg_r[0];
        assign next_lfsr_reg[3] = ~(lfsr_reg_r[9] ^ lfsr_reg_r[6]);
        assign next_lfsr_reg[2] = ~(lfsr_reg_r[8] ^ lfsr_reg_r[5]);
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[7] ^ lfsr_reg_r[4]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[6] ^ lfsr_reg_r[3]);
      end else if (nCK_PER_CLK == 4) begin: gen_ck_per_clk4
        assign next_lfsr_reg[9] = lfsr_reg_r[1];
        assign next_lfsr_reg[8] = lfsr_reg_r[0];
        assign next_lfsr_reg[7] = ~(lfsr_reg_r[9] ^ lfsr_reg_r[6]);
        assign next_lfsr_reg[6] = ~(lfsr_reg_r[8] ^ lfsr_reg_r[5]);
        assign next_lfsr_reg[5] = ~(lfsr_reg_r[7] ^ lfsr_reg_r[4]);
        assign next_lfsr_reg[4] = ~(lfsr_reg_r[6] ^ lfsr_reg_r[3]);
        assign next_lfsr_reg[3] = ~(lfsr_reg_r[5] ^ lfsr_reg_r[2]);
        assign next_lfsr_reg[2] = ~(lfsr_reg_r[4] ^ lfsr_reg_r[1]);
        assign next_lfsr_reg[1] = ~(lfsr_reg_r[3] ^ lfsr_reg_r[0]);
        assign next_lfsr_reg[0] = ~(lfsr_reg_r[2] ^ next_lfsr_reg[7]);
      end
    end
  endgenerate
  generate
    for (i = 0; i < 2*nCK_PER_CLK; i = i + 1) begin: gen_prbs_transpose
      assign prbs_o[i] = lfsr_reg_r[PRBS_WIDTH-1-i];
    end
  endgenerate
endmodule
