`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module mig_7series_v4_0_fi_xor #
(
  parameter integer DQ_WIDTH               = 72,
  parameter integer DQS_WIDTH              = 9,
  parameter integer nCK_PER_CLK            = 4
)
(
  input  wire                              clk           , 
  input  wire [2*nCK_PER_CLK*DQ_WIDTH-1:0] wrdata_in     , 
  output wire [2*nCK_PER_CLK*DQ_WIDTH-1:0] wrdata_out    , 
  input  wire                              wrdata_en     , 
  input  wire [DQS_WIDTH-1:0]              fi_xor_we     ,
  input  wire [DQ_WIDTH-1:0]               fi_xor_wrdata
);
localparam DQ_PER_DQS = DQ_WIDTH / DQS_WIDTH;
reg [DQ_WIDTH-1:0]              fi_xor_data = {DQ_WIDTH{1'b0}};
generate
begin
  genvar i;
  for (i = 0; i < DQS_WIDTH; i = i + 1) begin : assign_fi_xor_data
    always @(posedge clk) begin
      if (wrdata_en) begin
        fi_xor_data[i*DQ_PER_DQS+:DQ_PER_DQS] <= {DQ_PER_DQS{1'b0}};
      end
      else if (fi_xor_we[i]) begin
        fi_xor_data[i*DQ_PER_DQS+:DQ_PER_DQS] <= fi_xor_wrdata[i*DQ_PER_DQS+:DQ_PER_DQS];
      end 
      else begin
        fi_xor_data[i*DQ_PER_DQS+:DQ_PER_DQS] <= fi_xor_data[i*DQ_PER_DQS+:DQ_PER_DQS];
      end
    end
  end
end
endgenerate
assign wrdata_out[0+:DQ_WIDTH] = wrdata_in[0+:DQ_WIDTH] ^ fi_xor_data[0+:DQ_WIDTH];
assign wrdata_out[DQ_WIDTH+:(2*nCK_PER_CLK-1)*DQ_WIDTH] = wrdata_in[DQ_WIDTH+:(2*nCK_PER_CLK-1)*DQ_WIDTH];
endmodule
`default_nettype wire
