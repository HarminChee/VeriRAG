module a25_wishbone
(
input                       i_clk,
input                       i_port0_req,
output                      o_port0_ack,
input                       i_port0_write,
input       [127:0]         i_port0_wdata,
input       [15:0]          i_port0_be,
input       [31:0]          i_port0_addr,
output      [127:0]         o_port0_rdata,
input                       i_port1_req,
output                      o_port1_ack,
input                       i_port1_write,
input       [127:0]         i_port1_wdata,
input       [15:0]          i_port1_be,
input       [31:0]          i_port1_addr,
output      [127:0]         o_port1_rdata,
input                       i_port2_req,
output                      o_port2_ack,
input                       i_port2_write,
input       [127:0]         i_port2_wdata,
input       [15:0]          i_port2_be,
input       [31:0]          i_port2_addr,
output      [127:0]         o_port2_rdata,
output reg  [31:0]          o_wb_adr = 'd0,
output reg  [15:0]          o_wb_sel = 'd0,
output reg                  o_wb_we  = 'd0,
output reg  [127:0]         o_wb_dat = 'd0,
output reg                  o_wb_cyc = 'd0,
output reg                  o_wb_stb = 'd0,
input       [127:0]         i_wb_dat,
input                       i_wb_ack,
input                       i_wb_err
);
localparam WBUF = 3;
wire [0:0]                  wbuf_valid          [WBUF-1:0];
wire [0:0]                  wbuf_accepted       [WBUF-1:0];
wire [0:0]                  wbuf_write          [WBUF-1:0];
wire [127:0]                wbuf_wdata          [WBUF-1:0];
wire [15:0]                 wbuf_be             [WBUF-1:0];
wire [31:0]                 wbuf_addr           [WBUF-1:0];
wire [0:0]                  wbuf_rdata_valid    [WBUF-1:0];
wire                        new_access;
reg  [WBUF-1:0]             serving_port = 'd0;
a25_wishbone_buf u_a25_wishbone_buf_p0 (
    .i_clk          ( i_clk                 ),
    .i_req          ( i_port0_req           ),
    .o_ack          ( o_port0_ack           ),
    .i_write        ( i_port0_write         ),
    .i_wdata        ( i_port0_wdata         ),
    .i_be           ( i_port0_be            ),
    .i_addr         ( i_port0_addr          ),
    .o_rdata        ( o_port0_rdata         ),
    .o_valid        ( wbuf_valid       [0]  ),
    .i_accepted     ( wbuf_accepted    [0]  ),
    .o_write        ( wbuf_write       [0]  ),
    .o_wdata        ( wbuf_wdata       [0]  ),
    .o_be           ( wbuf_be          [0]  ),
    .o_addr         ( wbuf_addr        [0]  ),
    .i_rdata        ( i_wb_dat              ),
    .i_rdata_valid  ( wbuf_rdata_valid [0]  )
    );
a25_wishbone_buf u_a25_wishbone_buf_p1 (
    .i_clk          ( i_clk                 ),
    .i_req          ( i_port1_req           ),
    .o_ack          ( o_port1_ack           ),
    .i_write        ( i_port1_write         ),
    .i_wdata        ( i_port1_wdata         ),
    .i_be           ( i_port1_be            ),
    .i_addr         ( i_port1_addr          ),
    .o_rdata        ( o_port1_rdata         ),
    .o_valid        ( wbuf_valid        [1] ),
    .i_accepted     ( wbuf_accepted     [1] ),
    .o_write        ( wbuf_write        [1] ),
    .o_wdata        ( wbuf_wdata        [1] ),
    .o_be           ( wbuf_be           [1] ),
    .o_addr         ( wbuf_addr         [1] ),
    .i_rdata        ( i_wb_dat              ),
    .i_rdata_valid  ( wbuf_rdata_valid  [1] )
    );
a25_wishbone_buf u_a25_wishbone_buf_p2 (
    .i_clk          ( i_clk                 ),
    .i_req          ( i_port2_req           ),
    .o_ack          ( o_port2_ack           ),
    .i_write        ( i_port2_write         ),
    .i_wdata        ( i_port2_wdata         ),
    .i_be           ( i_port2_be            ),
    .i_addr         ( i_port2_addr          ),
    .o_rdata        ( o_port2_rdata         ),
    .o_valid        ( wbuf_valid        [2] ),
    .i_accepted     ( wbuf_accepted     [2] ),
    .o_write        ( wbuf_write        [2] ),
    .o_wdata        ( wbuf_wdata        [2] ),
    .o_be           ( wbuf_be           [2] ),
    .o_addr         ( wbuf_addr         [2] ),
    .i_rdata        ( i_wb_dat              ),
    .i_rdata_valid  ( wbuf_rdata_valid  [2] )
    );    
assign new_access       = !o_wb_stb || i_wb_ack;
assign wbuf_accepted[0] = new_access &&  wbuf_valid[0];
assign wbuf_accepted[1] = new_access && !wbuf_valid[0] &&  wbuf_valid[1];
assign wbuf_accepted[2] = new_access && !wbuf_valid[0] && !wbuf_valid[1] && wbuf_valid[2];
always @(posedge i_clk)
    begin
    if (new_access)
        begin
        if (wbuf_valid[0])
            begin
            o_wb_adr        <= wbuf_addr [0];
            o_wb_sel        <= wbuf_be   [0];
            o_wb_we         <= wbuf_write[0];
            o_wb_dat        <= wbuf_wdata[0];
            o_wb_cyc        <= 1'd1;
            o_wb_stb        <= 1'd1;
            serving_port    <= 3'b001;
            end
        else if (wbuf_valid[1])
            begin
            o_wb_adr        <= wbuf_addr [1];
            o_wb_sel        <= wbuf_be   [1];
            o_wb_we         <= wbuf_write[1];
            o_wb_dat        <= wbuf_wdata[1];
            o_wb_cyc        <= 1'd1;
            o_wb_stb        <= 1'd1;
            serving_port    <= 3'b010;
            end
        else if (wbuf_valid[2])
            begin
            o_wb_adr        <= wbuf_addr [2];
            o_wb_sel        <= wbuf_be   [2];
            o_wb_we         <= wbuf_write[2];
            o_wb_dat        <= wbuf_wdata[2];
            o_wb_cyc        <= 1'd1;
            o_wb_stb        <= 1'd1;
            serving_port    <= 3'b100;
            end
        else
            begin
            o_wb_cyc        <= 1'd0;
            o_wb_stb        <= 1'd0;
            o_wb_we         <= 1'd0;
            o_wb_adr        <= 'd0;
            o_wb_dat        <= 'd0;
            serving_port    <= 3'b000;
            end    
        end
    end
assign {wbuf_rdata_valid[2], wbuf_rdata_valid[1], wbuf_rdata_valid[0]} = {3{i_wb_ack & ~ o_wb_we}} & serving_port;
endmodule
