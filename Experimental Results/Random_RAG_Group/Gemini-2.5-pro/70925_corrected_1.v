`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module dvi_gen_top (
  input  wire        rst_n_pad_i,
  input  wire        dvi_clk_i,
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
  input  wire [7:0]  blue_data_i,
  input  wire        test_i // Added test mode input
);
  wire          locked;
  wire          reset;
  wire          clk50m, clk50m_bufg;
  wire          pwrup;
  assign clk50m = dvi_clk_i;
  BUFG clk50m_bufgbufg (.I(clk50m), .O(clk50m_bufg));
  wire pclk_lckd;
  wire RSTBTN;
  assign RSTBTN = ~rst_n_pad_i;

  // DFT signals
  wire dft_clk;
  wire dft_reset; // Active high reset for DFT
  assign dft_clk = dvi_clk_i; // Use primary clock for test
  assign dft_reset = test_i ? ~rst_n_pad_i : 1'b0; // Use inverted primary reset for test, active high

  // Consider SRLs as potentially needing specific DFT handling (e.g., bypass, scan wrap) by downstream tools.
  // Ensure surrounding logic is DFT compliant.
  SRL16E #(.INIT(16'h1)) pwrup_0 (
    .Q(pwrup),
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1),
    .CE(pclk_lckd), // CE driven by internal signal - check DFT tool handling
    .CLK(clk50m_bufg), // Clock OK (PI derived)
    .D(1'b0)
    // Implicitly reset by initialization or requires specific DFT strategy
  );
  wire busy;
  reg switch = 1'b0;
  reg [15:0] hlen_q, vlen_q;

  always @ (posedge clk50m_bufg or posedge dft_reset)
  begin
    if (dft_reset) begin
      switch <= 1'b0;
    end else begin
      // Avoid using output of potentially non-DFT-friendly SRL 'pwrup' directly in combinational path to FF D-input if possible,
      // but keeping functional logic here. DFT tools might need to constrain/handle this path.
      switch <= pwrup | ({hlen_q,vlen_q} != {hlen,vlen}); // Functional logic
    end
  end

  wire gopclk;
  SRL16E SRL16E_0 ( // Consider SRLs as potentially needing specific DFT handling
    .Q(gopclk),
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1),
    .CE(1'b1),
    .CLK(clk50m_bufg), // Clock OK (PI derived)
    .D(switch)
    // Implicitly reset by initialization or requires specific DFT strategy
  );
  defparam SRL16E_0.INIT = 16'h0;

  reg [7:0] pclk_M, pclk_D;

  always @(posedge clk50m_bufg or posedge dft_reset)
  begin
    if (dft_reset) begin
       hlen_q <= 16'b0;
       vlen_q <= 16'b0;
       pclk_M <= 8'b0;
       pclk_D <= 8'b0;
    end else begin
       hlen_q <= hlen;
       vlen_q <= vlen;
       if (switch) begin // Functional logic for pclk_M, pclk_D
         case ({hlen,vlen})
           32'h031f01c1:
           begin
             pclk_M <= 8'd54 - 8'd1;
             pclk_D <= 8'd125 - 8'd1;
           end
           32'h031f020c:
           begin
             pclk_M <= 8'd63 - 8'd1;
             pclk_D <= 8'd125 - 8'd1;
           end
           32'h03ff0270:
           begin
             pclk_M <= 8'd96 - 8'd1;
             pclk_D <= 8'd125 - 8'd1;
           end
           32'h04ef0330:
           begin
             pclk_M <= 8'd202 - 8'd1;
             pclk_D <= 8'd163 - 8'd1;
           end
           32'h033f01bc:
           begin
             pclk_M <= 8'd4 - 8'd1;
             pclk_D <= 8'd9 - 8'd1;
           end
           32'h035f0208:
           begin
             pclk_M <= 8'd121 - 8'd1;
             pclk_D <= 8'd224 - 8'd1;
           end
           32'h041f0273:
           begin
             pclk_M <= 8'd152 - 8'd1;
             pclk_D <= 8'd191 - 8'd1;
           end
           32'h033f01fc:
           begin
             pclk_M <= 8'd31 - 8'd1;
             pclk_D <= 8'd61 - 8'd1;
           end
           32'h05c703d8:
           begin
             pclk_M <= 8'd7 - 8'd1;
             pclk_D <= 8'd4 - 8'd1;
           end
           32'h040f0299:
           begin
             pclk_M <= 8'd64 - 8'd1;
             pclk_D <= 8'd77 - 8'd1;
           end
           32'h053f0325:
           begin
             pclk_M <= 8'd13 - 8'd1;
             pclk_D <= 8'd10 - 8'd1;
           end
           32'h035f0211:
           begin
             pclk_M <= 8'd111 - 8'd1;
             pclk_D <= 8'd202 - 8'd1;
           end
           32'h068f037b:
           begin
             pclk_M <= 8'd205 - 8'd1;
             pclk_D <= 8'd114 - 8'd1;
           end
           32'h043f0290:
           begin
             pclk_M <= 8'd193 - 8'd1;
             pclk_D <= 8'd225 - 8'd1;
           end
           32'h052f0325:
           begin
             pclk_M <= 8'd140 - 8'd1;
             pclk_D <= 8'd109 - 8'd1;
           end
           32'h061f048c:
           begin
             pclk_M <= 8'd217 - 8'd1;
             pclk_D <= 8'd99 - 8'd1;
           end
           32'h043f027f:
           begin
             pclk_M <= 8'd188 - 8'd1;
             pclk_D <= 8'd225 - 8'd1;
           end
           32'h054f0336:
           begin
             pclk_M <= 8'd137 - 8'd1;
             pclk_D <= 8'd102 - 8'd1;
           end
           32'h05c1037e:
           begin
             pclk_M <= 8'd19 - 8'd1;
             pclk_D <= 8'd12 - 8'd1;
           end
           32'h06af041d:
           begin
             pclk_M <= 8'd249 - 8'd1;
             pclk_D <= 8'd115 - 8'd1;
           end
           32'h0697042a:
           begin
             pclk_M <= 8'd67 - 8'd1;
             pclk_D <= 8'd31 - 8'd1;
           end
           32'h06970447:
           begin
             pclk_M <= 8'd111 - 8'd1;
             pclk_D <= 8'd50 - 8'd1;
           end
           32'h068f0428:
           begin
             pclk_M <= 8'd73 - 8'd1;
             pclk_D <= 8'd34 - 8'd1;
           end
           32'h057f0335:
           begin
             pclk_M <= 8'd25 - 8'd1;
             pclk_D <= 8'd18 - 8'd1;
           end
           32'h060f038b:
           begin
             pclk_M <= 8'd208 - 8'd1;
             pclk_D <= 8'd123 - 8'd1;
           end
           32'h069f042b:
           begin
             pclk_M <= 8'd213 - 8'd1;
             pclk_D <= 8'd98 - 8'd1;
           end
           32'h086f04e1:
           begin
             pclk_M <= 8'd81 - 8'd1;
             pclk_D <= 8'd25 - 8'd1;
           end
           32'h06ef038b:
           begin
             pclk_M <= 8'd209 - 8'd1;
             pclk_D <= 8'd108 - 8'd1;
           end
           32'h06af0427:
           begin
             pclk_M <= 8'd247 - 8'd1;
             pclk_D <= 8'd113 - 8'd1;
           end
           32'h059f0321:
           begin
             pclk_M <= 8'd255 - 8'd1;
             pclk_D <= 8'd184 - 8'd1;
           end
           32'h067f0427:
           begin
             pclk_M <= 8'd17 - 8'd1;
             pclk_D <= 8'd8 - 8'd1;
           end
           32'h05ff0385:
           begin
             pclk_M <= 8'd133 - 8'd1;
             pclk_D <= 8'd80 - 8'd1;
           end
           32'h06bf042f:
           begin
             pclk_M <= 8'd249 - 8'd1;
             pclk_D <= 8'd112 - 8'd1;
           end
           32'h08bf0440:
           begin
             pclk_M <= 8'd161 - 8'd1;
             pclk_D <= 8'd55 - 8'd1;
           end
           32'h081f04db:
           begin
             pclk_M <= 8'd59 - 8'd1;
             pclk_D <= 8'd19 - 8'd1;
           end
           32'h069f042f:
           begin
             pclk_M <= 8'd24 - 8'd1;
             pclk_D <= 8'd11 - 8'd1;
           end
           32'h095705d1:
           begin
             pclk_M <= 8'd201 - 8'd1;
             pclk_D <= 8'd47 - 8'd1;
           end
           32'h027f0193:
           begin
             pclk_M <= 8'd76 - 8'd1;
             pclk_D <= 8'd245 - 8'd1;
           end
           32'h018f00e0:
           begin
             pclk_M <= 8'd27 - 8'd1;
             pclk_D <= 8'd250 - 8'd1;
           end
           32'h018f0105:
           begin
             pclk_M <= 8'd21 - 8'd1;
             pclk_D <= 8'd167 - 8'd1;
           end
           32'h01ff0137:
           begin
             pclk_M <= 8'd37 - 8'd1;
             pclk_D <= 8'd193 - 8'd1;
           end
           32'h020f0139:
           begin
             pclk_M <= 8'd38 - 8'd1;
             pclk_D <= 8'd191 - 8'd1;
           end
           32'h0207014c:
           begin
             pclk_M <= 8'd16 - 8'd1;
             pclk_D <= 8'd77 - 8'd1;
           end
           32'h02670137:
           begin
             pclk_M <= 8'd3 - 8'd1;
             pclk_D <= 8'd13 - 8'd1;
           end
           32'h02770139:
           begin
             pclk_M <= 8'd5 - 8'd1;
             pclk_D <= 8'd21 - 8'd1;
           end
           32'h026f014c:
           begin
             pclk_M <= 8'd63 - 8'd1;
             pclk_D <= 8'd253 - 8'd1;
           end
           32'h0a1f04d9:
           begin
             pclk_M <= 8'd173 - 8'd1; // Added missing assignment
             pclk_D <= 8'd41 - 8'd1;  // Added missing assignment
           end // **** Added missing end ****
           default: // Added default case
           begin
             pclk_M <= 8'b0; // Or some default value
             pclk_D <= 8'b0; // Or some default value
           end
         endcase
       end // if (switch)
    end // else: !if(dft_reset)
  end // always

  // Instantiation of the rest of the design (assuming dvi_gen is the core logic)
  // Pass DFT compliant signals where necessary
  dvi_gen dvi_gen_inst (
    .RSTBTN(RSTBTN), // Original reset usage, consider impact
    .reset(dft_reset), // Using DFT reset for internal core reset
    .clk50m(clk50m_bufg), // Using buffered clock
    .pwrup(pwrup), // From SRL
    .gopclk(gopclk), // From SRL
    .pclk_M(pclk_M),
    .pclk_D(pclk_D),
    .pclk_lckd(pclk_lckd), // Output from core
    .pclk_o(pclk_o), // Output from core
    .hlen(hlen_q), // Using registered version
    .vlen(vlen_q), // Using registered version
    .hsync_i(hsync_i),
    .vsync_i(vsync_i),
    .blank_i(blank_i),
    .red_data_i(red_data_i),
    .green_data_i(green_data_i),
    .blue_data_i(blue_data_i),
    .TMDS(TMDS),
    .TMDSB(TMDSB),
    .test_i(test_i) // Pass test mode signal if needed by core
  );

endmodule

// Placeholder for the dvi_gen module - actual implementation not provided/corrected
// Ensure internal logic within dvi_gen adheres to DFT rules (PI clocks, PI resets or test-controllable resets)
module dvi_gen (
    input wire RSTBTN,
    input wire reset, // DFT reset
    input wire clk50m, // DFT clock
    input wire pwrup,
    input wire gopclk,
    input wire [7:0] pclk_M,
    input wire [7:0] pclk_D,
    output wire pclk_lckd,
    output wire pclk_o,
    input wire [15:0] hlen,
    input wire [15:0] vlen,
    input wire hsync_i,
    input wire vsync_i,
    input wire blank_i,
    input wire [7:0] red_data_i,
    input wire [7:0] green_data_i,
    input wire [7:0] blue_data_i,
    output wire [3:0] TMDS,
    output wire [3:0] TMDSB,
    input wire test_i
);

    // Internal logic of dvi_gen would go here
    // All flip-flops should use clk50m (or another PI-derived clock)
    // All flip-flops should use 'reset' (the DFT-controlled reset) or be reset via scan chain initialization
    // Avoid internally generated clocks/resets unless properly handled for DFT

    // Dummy assignments to satisfy port connections
    assign pclk_lckd = 1'b0;
    assign pclk_o = 1'b0;
    assign TMDS = 4'b0;
    assign TMDSB = 4'b0;

endmodule

// BUFG primitive placeholder
module BUFG (input I, output O);
    assign O = I;
endmodule

// SRL16E primitive placeholder
module SRL16E (
    output Q,
    input A0, A1, A2, A3,
    input CE,
    input CLK,
    input D
);
    parameter INIT = 16'h0000;
    reg [15:0] shift_reg = INIT;
    wire [3:0] addr = {A3, A2, A1, A0};

    always @(posedge CLK) begin
        if (CE) begin
            shift_reg <= {shift_reg[14:0], D};
        end
    end
    assign Q = shift_reg[addr];

endmodule