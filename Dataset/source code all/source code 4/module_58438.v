`timescale 1ns / 1ps
`timescale 1ns / 1ps
module tlast_gen
#(
    parameter TDATA_WIDTH    = 8,
    parameter PKT_LENGTH = 1024*1024
)
(
    input                            aclk,
    input                            resetn,
    input                            s_axis_tvalid,
    output                           s_axis_tready,
    input  [TDATA_WIDTH-1:0]         s_axis_tdata,
    output                           m_axis_tvalid,
    input                            m_axis_tready,
    output                           m_axis_tlast,
    output [TDATA_WIDTH-1:0]         m_axis_tdata
);
    wire                           new_sample;
    reg [$clog2(PKT_LENGTH):0] cnt = 0;
    assign s_axis_tready = m_axis_tready;
    assign m_axis_tvalid = s_axis_tvalid;
    assign m_axis_tdata  = s_axis_tdata;
    assign new_sample = s_axis_tvalid & s_axis_tready;
    always @ (posedge aclk) begin
        if (~resetn | (m_axis_tlast & new_sample))
            cnt <= 0;
        else
            if (new_sample)
                cnt <= cnt + 1'b1;
    end
    assign m_axis_tlast = (cnt == PKT_LENGTH-1);
endmodule
