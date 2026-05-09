module butterfly
  #(
    parameter WIDTH = 32,
    parameter MWIDTH = 1
    )
   (
    input wire                     clk,
    input wire                     rst_n,
    input wire [MWIDTH-1:0]        m_in,
    input wire signed [WIDTH-1:0]  w,
    input wire signed [WIDTH-1:0]  xa,
    input wire signed [WIDTH-1:0]  xb,
    input wire                     x_nd,
    output reg [MWIDTH-1:0]        m_out,
    output wire signed [WIDTH-1:0] ya,
    output wire signed [WIDTH-1:0] yb,
    output reg                     y_nd,
`ifdef DEBUG
    output wire [WIDTH-1:0]        out_msg,
    output wire                    out_msg_nd,
    output wire                    error
`else
    output reg                     error
`endif
    );
   wire signed [WIDTH/2-1:0]        xa_re;
   wire signed [WIDTH/2-1:0]        xa_im;
   assign xa_re = xa[WIDTH-1:WIDTH/2];
   assign xa_im = xa[WIDTH/2-1:0];
   wire signed [WIDTH/2-1: 0]       ya_re;
   wire signed [WIDTH/2-1: 0]       ya_im;
   assign ya = {ya_re, ya_im};
   wire signed [WIDTH/2-1: 0]       yb_re;
   wire signed [WIDTH/2-1: 0]       yb_im;
   assign yb = {yb_re, yb_im};
   reg signed [WIDTH/2-1:0]         xa_re_z;
   reg signed [WIDTH/2-1:0]         xa_im_z;
   wire signed [WIDTH-1:0]          xbw;
   wire signed [WIDTH/2-1:0]        xbw_re;
   wire signed [WIDTH/2-1:0]        xbw_im;
   assign xbw_re = xbw[WIDTH-1:WIDTH/2];
   assign xbw_im = xbw[WIDTH/2-1:0];
   assign ya_re = xa_re_z + xbw_re;
   assign ya_im = xa_im_z + xbw_im;
   assign yb_re = xa_re_z - xbw_re;
   assign yb_im = xa_im_z - xbw_im;
   multiply_complex #(WIDTH) multiply_complex_0
     (.clk(clk),
      .rst_n(rst_n),
      .x(xb),
      .y(w),
      .z(xbw)
      );
`ifdef DEBUG
   reg [5*WIDTH-1:0]               msg;
   reg                             msg_nd;
   wire [WIDTH-1:0]                xa_s;
   wire [WIDTH-1:0]                xbw_s;
   wire [WIDTH-1:0]                ya_s;
   wire [WIDTH-1:0]                yb_s;
   smaller #(WIDTH) smaller_0 ({xa_re_z, xa_im_z}, xa_s);
   smaller #(WIDTH) smaller_1 (xbw, xbw_s);
   smaller #(WIDTH) smaller_2 (ya, ya_s);
   smaller #(WIDTH) smaller_3 (yb, yb_s);
   message_slicer #(5, WIDTH, 48) message_slicer_0
     (clk, rst_n, msg, msg_nd, out_msg, out_msg_nd, error);
`endif
  always @ (posedge clk)
    begin
       if (!rst_n)
         begin
            y_nd <= 1'b0;
`ifndef DEBUG
            error <= 1'b0;
`endif
         end
       else
         begin
`ifdef DEBUG
            msg_nd <= 1'b0;
`endif
            y_nd <= x_nd;
            m_out <= m_in;
            if (x_nd)
              begin
                 xa_re_z <= xa_re/2;
                 xa_im_z <= xa_im/2;
              end
`ifdef DEBUG
            if (y_nd & (xa_s != 0))
              begin
                 msg <= {1'b1, 10'd4, 21'd0, xa_s, xbw_s, ya_s, yb_s};
                 msg_nd <= 1'b1;
              end
`endif
         end
    end
endmodule
