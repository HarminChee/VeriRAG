`timescale 1ns/1ns
`timescale 1ns/1ns
module pcie_reset_delay_v6 # (
  parameter PL_FAST_TRAIN = "FALSE",
  parameter REF_CLK_FREQ = 0,   
  parameter TCQ = 1
)
(
  input  wire        ref_clk,
  input  wire        sys_reset_n,
  output             delayed_sys_reset_n
);
  localparam         TBIT =  (PL_FAST_TRAIN == "FALSE") ?  ((REF_CLK_FREQ == 1) ? 20: (REF_CLK_FREQ == 0) ? 20 : 21) : 2;
  reg [7:0]          reg_count_7_0;
  reg [7:0]          reg_count_15_8;
  reg [7:0]          reg_count_23_16;
  wire [23:0]        concat_count;
  assign concat_count = {reg_count_23_16, reg_count_15_8, reg_count_7_0};
  always @(posedge ref_clk or negedge sys_reset_n) begin
    if (!sys_reset_n) begin
      reg_count_7_0 <= #TCQ 8'h0;
      reg_count_15_8 <= #TCQ 8'h0;
      reg_count_23_16 <= #TCQ 8'h0;
    end else begin
      if (delayed_sys_reset_n != 1'b1) begin
        reg_count_7_0   <= #TCQ reg_count_7_0 + 1'b1;
        reg_count_15_8  <= #TCQ (reg_count_7_0 == 8'hff)? reg_count_15_8  + 1'b1 : reg_count_15_8 ;
        reg_count_23_16 <= #TCQ ((reg_count_15_8 == 8'hff) & (reg_count_7_0 == 8'hff)) ? reg_count_23_16 + 1'b1 : reg_count_23_16;
      end 
    end
  end
  assign delayed_sys_reset_n = concat_count[TBIT]; 
endmodule
