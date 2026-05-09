`timescale 1ps/1ps
`timescale 1ps/1ps
module mig_7series_v2_0_qdr_rld_phy_read_vld_gen #
(
  parameter BURST_LEN   = 4,  
  parameter nCK_PER_CLK = 2,
  parameter TCQ         = 100 
)
(
  input       clk,            
  input       rst_clk,        
  input [nCK_PER_CLK-1:0]   int_rd_cmd_n,   
  input [4:0] valid_latency,  
  input       cal_done,       
  output reg [nCK_PER_CLK-1:0] data_valid,    
  output [4:0] dbg_valid_lat
);
  wire [nCK_PER_CLK-1:0] data_valid_int;
  reg  [nCK_PER_CLK-1:0] data_valid_int_r1;
  reg  [nCK_PER_CLK-1:0] data_valid_int_r2;
  generate
  genvar i;
    for (i=0; i < nCK_PER_CLK; i = i+1) begin : gen_rd_valid
        SRLC32E u_vld_gen_srl_inst (
        .Q    (data_valid_int[i]),
        .Q31  ( ),
        .A    (valid_latency),
        .CE   (1'b1),
        .CLK  (clk),
        .D    (~int_rd_cmd_n[i])
      );
      always @(posedge clk)
      begin
        data_valid_int_r1[i] <=#TCQ data_valid_int[i];
        data_valid_int_r2[i] <=#TCQ data_valid_int_r1[i];
      end
      if (nCK_PER_CLK == 2) begin : gen_data_valid_2
        always @(posedge clk) begin
          if (rst_clk || !cal_done) begin
            data_valid[i] <= #TCQ 0;
          end else begin 
            if (BURST_LEN==2) begin
              data_valid[i] <= #TCQ data_valid_int[i];
            end else if (BURST_LEN==4) begin
              if (i==0)
                data_valid[0] <= #TCQ data_valid_int[0] | data_valid_int_r1[1];
              else 
                data_valid[1] <= #TCQ data_valid_int[0] | data_valid_int[1] ;
            end else begin 
              if (i==0)
                data_valid[0] <= #TCQ data_valid_int[0] | data_valid_int_r1[0] | 
                                      data_valid_int_r1[1] | data_valid_int_r2[1];
              else 
                data_valid[1] <= #TCQ data_valid_int[0] | data_valid_int_r1[0] | 
                                      data_valid_int[1] | data_valid_int_r1[1];
            end
          end
        end 
      end else if (nCK_PER_CLK == 4) begin : gen_data_valid_4
        always @(posedge clk) begin
          if (rst_clk || !cal_done) begin
            data_valid[i] <= #TCQ 0;
          end else begin 
            if (BURST_LEN==2) begin
              data_valid[i] <= #TCQ data_valid_int[i];
            end else if (BURST_LEN==4) begin
              if (i==0)
                data_valid[0] <= #TCQ data_valid_int[0] | data_valid_int_r1[3];
              else if (i==1)
                data_valid[1] <= #TCQ data_valid_int[0] | data_valid_int[1] ;
              else if (i==2)
                data_valid[2] <= #TCQ data_valid_int[1] | data_valid_int[2] ;
              else 
                data_valid[3] <= #TCQ data_valid_int[2] | data_valid_int[3] ; 
            end else begin 
              if (i==0)
                data_valid[0] <= #TCQ data_valid_int[0] | data_valid_int_r1[1] | 
                                      data_valid_int_r1[2] | data_valid_int_r1[3];
              else if (i==1)
                data_valid[1] <= #TCQ data_valid_int[0] | data_valid_int[1] | 
                                      data_valid_int_r1[2] | data_valid_int_r1[3];
              else if (i==2)
                data_valid[2] <= #TCQ data_valid_int[0] | data_valid_int[1] | 
                                      data_valid_int[2] | data_valid_int_r1[3];
              else 
                data_valid[3] <= #TCQ data_valid_int[0] | data_valid_int[1] | 
                                          data_valid_int[2] | data_valid_int[3];
            end
          end 
        end 
      end 
    end 
  endgenerate
  assign dbg_valid_lat = valid_latency;
endmodule
