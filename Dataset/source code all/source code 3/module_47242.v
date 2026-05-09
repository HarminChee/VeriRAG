module fifo36_to_gpmc16
#(
    parameter FIFO_SIZE = 9,
    parameter MIN_OCC16 = 2
)
(
    input fifo_clk, input fifo_rst,
    input [35:0] in_data,
    input in_src_rdy,
    output in_dst_rdy,
    input gpif_clk, input gpif_rst,
    output [15:0] out_data,
    output valid,
    input enable,
    output eof,
    output reg has_data
);
    wire [15:0] fifo_occ;
    always @(posedge gpif_clk)
        has_data <= (fifo_occ >= MIN_OCC16);
    wire [35:0] data_int;
    wire src_rdy_int, dst_rdy_int;
    fifo_2clock_cascade #(.WIDTH(36), .SIZE(6)) fifo_2clk
     (.wclk(fifo_clk), .datain(in_data), .src_rdy_i(in_src_rdy), .dst_rdy_o(in_dst_rdy), .space(),
      .rclk(gpif_clk), .dataout(data_int), .src_rdy_o(src_rdy_int), .dst_rdy_i(dst_rdy_int), .occupied(),
      .arst(fifo_rst | gpif_rst));
    wire [18:0] data19_int;
    wire data19_src_rdy_int, data19_dst_rdy_int;
    fifo36_to_fifo19 #(.LE(1)) f36_to_f19
     (.clk(gpif_clk), .reset(gpif_rst), .clear(1'b0),
      .f36_datain(data_int), .f36_src_rdy_i(src_rdy_int), .f36_dst_rdy_o(dst_rdy_int),
      .f19_dataout(data19_int), .f19_src_rdy_o(data19_src_rdy_int), .f19_dst_rdy_i(data19_dst_rdy_int) );
    wire [17:0] data18_int;
    fifo_cascade #(.WIDTH(18), .SIZE(FIFO_SIZE+1)) occ_ctrl_fifo
     (.clk(gpif_clk), .reset(gpif_rst), .clear(1'b0),
      .datain(data19_int[17:0]), .src_rdy_i(data19_src_rdy_int), .dst_rdy_o(data19_dst_rdy_int), .space(),
      .dataout(data18_int), .src_rdy_o(valid), .dst_rdy_i(enable), .occupied(fifo_occ));
    assign out_data = data18_int[15:0];
    assign eof = data18_int[17];
endmodule 
