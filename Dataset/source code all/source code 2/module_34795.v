`timescale 1ns / 1ps
`timescale 1ns / 1ps
module tx_interface #(
    parameter      FIFO_CNT_WIDTH = 16 
)
(
    output [63:0]   axi_str_tdata_to_xgmac,
    output [7:0]    axi_str_tkeep_to_xgmac,
    output          axi_str_tvalid_to_xgmac,
    output          axi_str_tlast_to_xgmac,
    output          axi_str_tuser_to_xgmac,
    input           axi_str_tready_from_xgmac,
    output          axi_str_tready_to_fifo,
    input [63:0]  axi_str_tdata_from_fifo,   
    input [7:0]   axi_str_tkeep_from_fifo,   
    input         axi_str_tvalid_from_fifo,
    input         axi_str_tlast_from_fifo,
    input          user_clk,
    input          reset
);
reg state_wr;
reg state_rd;
reg pkg_push;
reg cmd_fifo_din;
reg cmd_fifo_wr_en;
reg cmd_fifo_rd_en;
wire cmd_fifo_full;
wire cmd_fifo_empty;
wire [FIFO_CNT_WIDTH-1:0]  wr_data_count ;
  wire [FIFO_CNT_WIDTH-1:0]  left_over_space_in_fifo; 
localparam IDLE = 0;
localparam LOAD = 1;
localparam PUSH = 1;
wire axis_rd_tready;
wire axis_rd_tvalid;
wire axis_rd_tlast;
wire[63:0] axis_rd_tdata;
wire[7:0] axis_rd_tkeep;
wire axis_wr_tready;
wire axis_wr_tvalid;
wire axis_wr_tlast;
wire[63:0] axis_wr_tdata;
wire[7:0] axis_wr_tkeep;
assign axi_str_tready_to_fifo = (left_over_space_in_fifo > 16'h0004) & (!cmd_fifo_full) & axis_wr_tready;
assign axis_wr_tvalid = axi_str_tvalid_from_fifo;
assign axis_wr_tlast = axi_str_tlast_from_fifo;
assign axis_wr_tdata = axi_str_tdata_from_fifo;
assign axis_wr_tkeep = axi_str_tkeep_from_fifo;
assign axis_rd_tready = axi_str_tready_from_xgmac & pkg_push;
assign axi_str_tvalid_to_xgmac = axis_rd_tvalid & pkg_push;
assign axi_str_tlast_to_xgmac = axis_rd_tlast;
assign axi_str_tdata_to_xgmac = axis_rd_tdata;
assign axi_str_tkeep_to_xgmac = axis_rd_tkeep;
assign axi_str_tuser_to_xgmac = 1'b0;
assign left_over_space_in_fifo = {(FIFO_CNT_WIDTH-1){1'b1}} - wr_data_count[FIFO_CNT_WIDTH-2:0];
always @(posedge user_clk)
begin
    if (reset == 1) begin
        cmd_fifo_wr_en <= 1'b0;
        cmd_fifo_din <= 1'b0;
        state_wr <= IDLE;
    end
    else begin
        case (state_wr)
            IDLE: begin
                cmd_fifo_din <= 1'b0;
                cmd_fifo_wr_en <= 1'b0;
                if (axis_wr_tvalid) begin
                    state_wr <= LOAD;
                end
            end
            LOAD: begin
                cmd_fifo_wr_en <= 1'b0;
                if (axis_wr_tlast & axis_wr_tvalid) begin
                    if (!cmd_fifo_full) begin
                        cmd_fifo_din <= 1'b1;
                        cmd_fifo_wr_en <= 1'b1;
                    end
                    state_wr <= IDLE;
                end
            end
        endcase 
    end
end
always @(posedge user_clk)
begin
    if (reset == 1) begin
        state_rd <= IDLE;
        pkg_push <= 1'b0;
        cmd_fifo_rd_en <= 1'b0;
    end
    else begin
        case (state_rd)
            IDLE: begin
                pkg_push <= 1'b0;
                cmd_fifo_rd_en <= 1'b0;
                if (!cmd_fifo_empty) begin
                    pkg_push <= 1'b1;
                    cmd_fifo_rd_en <= 1'b1;
                    state_rd <= PUSH;
                end
            end
            PUSH: begin
                pkg_push <= 1'b1;
                cmd_fifo_rd_en <= 1'b0;
                if (axis_rd_tlast) begin
                    pkg_push <= 1'b0;
                    state_rd <= IDLE;
                end
            end
         endcase
    end
end
  axis_sync_fifo axis_fifo_inst1 (
    .m_axis_tready        (axis_rd_tready           ),
    .s_aresetn            (~reset                   ),
    .s_axis_tready        (axis_wr_tready           ),
    .s_aclk               (user_clk                 ),
    .s_axis_tvalid        (axis_wr_tvalid           ),
    .m_axis_tvalid        (axis_rd_tvalid           ),
    .m_axis_tlast         (axis_rd_tlast            ),
    .s_axis_tlast         (axis_wr_tlast            ),
    .s_axis_tdata         (axis_wr_tdata            ),
    .m_axis_tdata         (axis_rd_tdata            ),
    .s_axis_tkeep         (axis_wr_tkeep            ),
    .m_axis_tkeep         (axis_rd_tkeep            ),
    .axis_data_count   (wr_data_count            )
  );
cmd_fifo_xgemac_txif cmd_fifo_inst (
.clk(user_clk), 
.rst(reset), 
.din(cmd_fifo_din), 
.wr_en(cmd_fifo_wr_en), 
.rd_en(cmd_fifo_rd_en), 
.dout(), 
.full(cmd_fifo_full), 
.empty(cmd_fifo_empty) 
);
endmodule
