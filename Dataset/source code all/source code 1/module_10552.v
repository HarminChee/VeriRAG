`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pc_ctrl_pm0 #(
  parameter DATA_W_IN_BYTES           = 4,
  parameter ADDR_W_IN_BITS            = 32,
  parameter DCADDR_LOW_BIT_W          = 8
) (
  input  wire [31:0]      accum_low_period,
  input  wire [15:0]      pulse_per_second,
  input  wire             ready_to_read   ,
  output reg  [31:0]      clk_freq         = 32'd100000000,
  output reg  [31:0]      clk_subsample    = 32'd0,
  output reg              enable           = 1'd1,
  output reg              use_one_pps_in   = 1'd0,
  input  wire                                       reg_bank_rd_start, 
  output wire                                       reg_bank_rd_done,  
  input  wire [DCADDR_LOW_BIT_W - 1:0]              reg_bank_rd_addr,  
  output reg  [(DATA_W_IN_BYTES*8) - 1:0]           reg_bank_rd_data=0,
  input  wire                                       reg_bank_wr_start, 
  output wire                                       reg_bank_wr_done,  
  input  wire [DCADDR_LOW_BIT_W - 1:0]              reg_bank_wr_addr,  
  input  wire [(DATA_W_IN_BYTES*8) - 1:0]           reg_bank_wr_data,  
  input  wire                                       ACLK             , 
  input  wire                                       ARESETn            
);
assign reg_bank_wr_done = reg_bank_wr_start;
assign reg_bank_rd_done = reg_bank_rd_start;
always @(posedge ACLK) begin
   if(!ARESETn) begin
      clk_freq         <= 32'd100000000;
      clk_subsample    <= 32'd0;
      enable           <= 1'd1;
      use_one_pps_in   <= 1'd0;
   end else begin
      if(reg_bank_wr_start) begin
         case (reg_bank_wr_addr[DCADDR_LOW_BIT_W-1:2])
         0 : begin
             enable           <= reg_bank_wr_data[0:0];
         end
         1 : begin
             use_one_pps_in   <= reg_bank_wr_data[0:0];
         end
         2 : begin
             clk_freq         <= reg_bank_wr_data[31:0];
         end
         3 : begin
             clk_subsample    <= reg_bank_wr_data[31:0];
         end
         endcase
      end
   end
end
always @(*) begin
    reg_bank_rd_data = 'd0;
    case (reg_bank_rd_addr[DCADDR_LOW_BIT_W-1:2])
    0 : begin
         reg_bank_rd_data[0:0]    = enable;
    end
    1 : begin
         reg_bank_rd_data[0:0]    = use_one_pps_in;
    end
    2 : begin
         reg_bank_rd_data[31:0]   = clk_freq;
    end
    3 : begin
         reg_bank_rd_data[31:0]   = clk_subsample;
    end
    4 : begin
         reg_bank_rd_data[15:0]   = pulse_per_second;
    end
    5 : begin
         reg_bank_rd_data[31:0]   = accum_low_period;
    end
    6 : begin
         reg_bank_rd_data[0:0]    = ready_to_read;
    end
    endcase
end
endmodule
