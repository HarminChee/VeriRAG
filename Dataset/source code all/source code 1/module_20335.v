module butterfly
  #(
    parameter M_WDTH = 0,
    parameter X_WDTH = 0
    )
   (
    input wire                        clk,
    input wire                        rst_n,
    input wire [M_WDTH-1:0]           m_in,
    input wire signed [2*X_WDTH-1:0]  w,
    input wire signed [2*X_WDTH-1:0]  xa,
    input wire signed [2*X_WDTH-1:0]  xb,
    input wire                        x_nd,
    output reg [M_WDTH-1:0]           m_out,
    output wire signed [2*X_WDTH-1:0] y,
    output reg                        y_nd
    );
   wire signed [X_WDTH-1:0]        w_re;
   wire signed [X_WDTH-1:0]        w_im;
   assign w_re = w[2*X_WDTH-1:X_WDTH];
   assign w_im = w[X_WDTH-1:0];
   wire signed [X_WDTH-1:0]        xa_re;
   wire signed [X_WDTH-1:0]        xa_im;
   assign xa_re = xa[2*X_WDTH-1:X_WDTH];
   assign xa_im = xa[X_WDTH-1:0];
   wire signed [X_WDTH-1:0]        xb_re;
   wire signed [X_WDTH-1:0]        xb_im;
   assign xb_re = xb[2*X_WDTH-1:X_WDTH];
   assign xb_im = xb[X_WDTH-1:0];
   reg signed [X_WDTH-1: 0]        y_re;
   reg signed [X_WDTH-1: 0]        y_im;
   assign y = {y_re, y_im};
   reg signed [M_WDTH-1:0]         m[1:0];
   reg signed [X_WDTH-1:0]         za_re[1:0];
   reg signed [X_WDTH-1:0]         za_im[1:0];
   reg signed [X_WDTH-1:0]         zb_re;
   reg signed [X_WDTH-1:0]         zb_im;
   reg signed [X_WDTH-1:0]         ww_re;
   reg signed [X_WDTH-1:0]         ww_im;
   reg signed                      x_nd_old[2:0];
   reg signed [2*X_WDTH-1:0]         zbw_m1;
   reg signed [2*X_WDTH-1:0]         zbw_m2;
   reg signed [X_WDTH-1:0]         zbw_re;
   wire signed [X_WDTH-1:0]        zbw_im;
   assign zbw_im = (zbw_m1 >>> (X_WDTH-2)) + (zbw_m2 >>> (X_WDTH-2));
   reg signed [X_WDTH-1:0]         zbw_im_old;
   wire signed [X_WDTH:0]            z1_re_big;
   wire signed [X_WDTH:0]            z1_im_big;
   assign z1_re_big = za_re[0] + zbw_re;
   assign z1_im_big = za_im[0] + zbw_im;
   wire signed [X_WDTH:0]            z2_re_big;
   wire signed [X_WDTH:0]            z2_im_big;
   assign z2_re_big = za_re[1] - zbw_re;
   assign z2_im_big = za_im[1] - zbw_im_old;
  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
           y_nd <= 1'b0;
        end
      else
        begin
           x_nd_old[0] <= x_nd;
           x_nd_old[1] <= x_nd_old[0];
           x_nd_old[2] <= x_nd_old[1];
           m[0] <= m_in;
           m[1] <= m[0];
           m_out <= m[1];
           if (x_nd)
             begin
                za_re[0] <= xa_re;
                za_im[0] <= xa_im;
                ww_re <= w_re;
                ww_im <= w_im;
                zb_re <= xb_re;
                zb_im <= xb_im;
                zbw_m1 <= xb_re*w_re;
                zbw_m2 <= xb_im*w_im;
                if (x_nd_old[0])
                  $display("ERROR: BF got new data two steps in a row.");
             end
           if (x_nd_old[0])
             begin
                zbw_m1 <= zb_re*ww_im;
                zbw_m2 <= zb_im*ww_re;
                zbw_re <= (zbw_m1 >>> (X_WDTH-2)) - (zbw_m2 >>> (X_WDTH-2));
             end
           if (x_nd_old[1])
             begin
                za_re[1] <= za_re[0];
                za_im[1] <= za_im[0];
                y_nd <= 1'b1;
                y_re <= z1_re_big >>> 1;
                y_im <= z1_im_big >>> 1;
                zbw_im_old <= zbw_im;
             end
           if (x_nd_old[2])
             begin
                y_nd <= 1'b0;
                y_re <= z2_re_big >>> 1;
                y_im <= z2_im_big >>> 1;
             end
        end
    end
endmodule
