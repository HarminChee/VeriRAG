`timescale 1ns / 1ps
`timescale 1ns / 1ps
module rx_isolation #(
    FIFO_FULL_THRESHOLD = 11'd256
)
(
   input [63:0]   axi_str_tdata_from_xgmac,
   input [7:0]    axi_str_tkeep_from_xgmac,
   input          axi_str_tvalid_from_xgmac,
   input          axi_str_tlast_from_xgmac,
   input          axi_str_tready_from_fifo,
   output [63:0]  axi_str_tdata_to_fifo,   
   output [7:0]   axi_str_tkeep_to_fifo,   
   output         axi_str_tvalid_to_fifo,
   output         axi_str_tlast_to_fifo,
   input          user_clk, 
   input          reset
);
reg [63:0]   axi_str_tdata_from_xgmac_r;
reg [7:0]    axi_str_tkeep_from_xgmac_r;
reg          axi_str_tvalid_from_xgmac_r;
reg          axi_str_tlast_from_xgmac_r;
wire[10:0] fifo_occupacy_count;
wire s_axis_tvalid;
reg [10:0] wcount_r; 
wire fifo_has_space;
localparam IDLE = 1'd0,
           STREAMING = 1'd1;
reg curr_state_r;
rx_fifo rx_fifo_inst (
  .s_aclk(user_clk),                    
  .s_aresetn(~reset),              
  .s_axis_tvalid(s_axis_tvalid),      
  .s_axis_tready(),      
  .s_axis_tdata(axi_str_tdata_from_xgmac_r),        
  .s_axis_tkeep(axi_str_tkeep_from_xgmac_r),        
  .s_axis_tlast(axi_str_tlast_from_xgmac_r),        
  .m_axis_tvalid(axi_str_tvalid_to_fifo),      
  .m_axis_tready(axi_str_tready_from_fifo),      
  .m_axis_tdata(axi_str_tdata_to_fifo),        
  .m_axis_tkeep(axi_str_tkeep_to_fifo),        
  .m_axis_tlast(axi_str_tlast_to_fifo),        
  .axis_data_count(fifo_occupacy_count)  
);
assign fifo_has_space = (fifo_occupacy_count < FIFO_FULL_THRESHOLD);
assign s_axis_tvalid = axi_str_tvalid_from_xgmac_r & (((wcount_r == 0) & fifo_has_space) | (curr_state_r == STREAMING));
always @(posedge user_clk) begin
    axi_str_tdata_from_xgmac_r <= axi_str_tdata_from_xgmac;
    axi_str_tkeep_from_xgmac_r <= axi_str_tkeep_from_xgmac;
    axi_str_tvalid_from_xgmac_r <= axi_str_tvalid_from_xgmac;
    axi_str_tlast_from_xgmac_r <= axi_str_tlast_from_xgmac;
end
always @(posedge user_clk)
    if (reset)
        wcount_r <= 0;
    else if (axi_str_tvalid_from_xgmac_r & ~axi_str_tlast_from_xgmac_r)
        wcount_r <= wcount_r + 1;
    else if (axi_str_tvalid_from_xgmac_r & axi_str_tlast_from_xgmac_r)
        wcount_r <= 0;
always @(posedge user_clk)
    if (reset)
        curr_state_r <= IDLE;
    else 
        case (curr_state_r) 
            IDLE: if ((wcount_r == 0) & fifo_has_space & axi_str_tvalid_from_xgmac_r)
                    curr_state_r <= STREAMING;
            STREAMING: if (axi_str_tvalid_from_xgmac_r & axi_str_tlast_from_xgmac_r)
                    curr_state_r <= IDLE;
        endcase
endmodule
