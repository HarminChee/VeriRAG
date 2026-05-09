`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module dvi_gen_top (
  input  wire        rst_n_pad_i,
  input  wire        dvi_clk_i,
  input  wire        test_i,
  input  wire        scan_chain_rst,
  input  wire [15:0] hlen,
  input  wire [15:0] vlen,
  output wire [3:0]  TMDS,
  output wire [3:0]  TMDSB,
  output wire        pclk_o,
  input  wire        hsync_i, 
  input  wire        vsync_i, 
  input  wire        blank_i, 
  input  wire [7:0]  red_data_i,
  input  wire [7:0]  green_data_i,
  input  wire [7:0]  blue_data_i
);
  wire          locked;
  wire          reset;
  wire          clk50m, clk50m_bufg;
  wire          pwrup;
  assign clk50m = dvi_clk_i;
  BUFG clk50m_bufgbufg (.I(clk50m), .O(clk50m_bufg));
  wire pclk_lckd;
  wire RSTBTN;
  wire clk50m_dft;
  wire rst_dft;
  assign clk50m_dft = test_i ? dvi_clk_i : clk50m_bufg;
  assign rst_dft = test_i ? scan_chain_rst : ~rst_n_pad_i;
  assign RSTBTN = ~rst_n_pad_i; 
  SRL16E #(.INIT(16'h1)) pwrup_0 (
    .Q(pwrup),
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1),
    .CE(pclk_lckd),
    .CLK(clk50m_dft),
    .D(1'b0)
  );
  wire busy;
  reg switch = 1'b0;
  reg [15:0] hlen_q, vlen_q;
  always @ (posedge clk50m_dft or posedge rst_dft)
  begin
    if (rst_dft)
      switch <= 1'b0;
    else
      switch <= pwrup | ({hlen_q,vlen_q} != {hlen,vlen});
  end
  wire gopclk;
  SRL16E SRL16E_0 (
    .Q(gopclk),
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1),
    .CE(1'b1),
    .CLK(clk50m_dft),
    .D(switch)
  );
  defparam SRL16E_0.INIT = 16'h0;
  reg [7:0] pclk_M, pclk_D;
  always @(posedge clk50m_dft or posedge rst_dft)
  begin
    if (rst_dft) begin
      hlen_q <= 16'h0;
      vlen_q <= 16'h0;
      pclk_M <= 8'h0;
      pclk_D <= 8'h0;
    end
    else begin
      hlen_q <= hlen;
      vlen_q <= vlen;
      if (switch) begin
        case ({hlen,vlen})
          32'h031f01c1:  
          begin
            pclk_M <= 8'd54 - 8'd1;
            pclk_D <= 8'd125 - 8'd1;
          end
          // ... rest of the case statements remain unchanged ...
          default:
          begin
            pclk_M <= 8'd2 - 8'd1;
            pclk_D <= 8'd4 - 8'd1;
          end
        endcase
      end
    end
  end
  // ... rest of module remains unchanged ...
endmodule