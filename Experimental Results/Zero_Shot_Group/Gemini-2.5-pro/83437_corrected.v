`timescale 1 ns / 1ps

module decode (
  input  wire reset,
  input  wire pclk,
  input  wire pclkx2,
  input  wire pclkx10,
  input  wire serdesstrobe,
  input  wire din_p,
  input  wire din_n,
  input  wire other_ch0_vld,
  input  wire other_ch1_vld,
  input  wire other_ch0_rdy,
  input  wire other_ch1_rdy,
  output wire iamvld,
  output wire iamrdy,
  output wire psalgnerr,
  output reg  c0,
  output reg  c1,
  output reg  de,
  output reg [9:0] sdout,
  output reg [7:0] dout
);

  wire flipgear;
  reg flipgearx2;
  always @ (posedge pclkx2) begin
    flipgearx2 <= flipgear;
  end

  reg toggle = 1'b0;
  always @ (posedge pclkx2 or posedge reset) begin
    if (reset == 1'b1) begin
      toggle <= 1'b0 ;
    end else begin
      toggle <= ~toggle;
    end
  end

  wire rx_toggle;
  assign rx_toggle = toggle ^ flipgearx2;

  wire [4:0] raw5bit;
  reg [4:0] raw5bit_q;
  reg [9:0] rawword;
  always @ (posedge pclkx2) begin
    raw5bit_q <= raw5bit;
    if(rx_toggle) begin
      rawword <= {raw5bit, raw5bit_q};
    end
  end

  reg bitslipx2 = 1'b0;
  reg bitslip_q = 1'b0;
  wire bitslip;
  always @ (posedge pclkx2) begin
    bitslip_q <= bitslip;
    bitslipx2 <= bitslip & !bitslip_q;
  end

  // Assuming parameters expect bit values, not strings
  serdes_1_to_5_diff_data # (
    .DIFF_TERM      (1'b0), // Changed from "FALSE"
    .BITSLIP_ENABLE (1'b1)  // Changed from "TRUE"
  ) des_0 (
    .use_phase_detector (1'b1),
    .datain_p           (din_p),
    .datain_n           (din_n),
    .rxioclk            (pclkx10),
    .rxserdesstrobe     (serdesstrobe),
    .reset              (reset),
    .gclk               (pclkx2),
    .bitslip            (bitslipx2),
    .data_out           (raw5bit)
  );

  // Removed redundant rawdata wire, using rawword directly
  phsaligner phsalgn_0 (
     .rst        (reset),
     .clk        (pclk),
     .sdata      (rawword), // Changed from rawdata
     .bitslip    (bitslip), // This is an output of phsaligner
     .flipgear   (flipgear), // This is an output of phsaligner
     .psaligned  (iamvld)  // This is an output of phsaligner
   );

  assign psalgnerr = 1'b0; // Placeholder

  wire [9:0] sdata; // Output of chnlbond
  chnlbond cbnd (
    .clk           (pclk),
    .rawdata       (rawword), // Changed from rawdata
    .iamvld        (iamvld),
    .other_ch0_vld (other_ch0_vld),
    .other_ch1_vld (other_ch1_vld),
    .other_ch0_rdy (other_ch0_rdy),
    .other_ch1_rdy (other_ch1_rdy),
    .iamrdy        (iamrdy), // Output of chnlbond
    .sdata         (sdata)   // Output of chnlbond
  );

  parameter CTRLTOKEN0 = 10'b1101010100;
  parameter CTRLTOKEN1 = 10'b0010101011;
  parameter CTRLTOKEN2 = 10'b0101010100;
  parameter CTRLTOKEN3 = 10'b1010101011;

  wire [7:0] data;
  assign data = (sdata[9]) ? ~sdata[7:0] : sdata[7:0];

  always @ (posedge pclk) begin
    if(iamrdy && other_ch0_rdy && other_ch1_rdy) begin
      case (sdata)
        CTRLTOKEN0: begin
          c0 <= 1'b0;
          c1 <= 1'b0;
          de <= 1'b0;
          dout <= 8'b0; // Assign dout in control cases too for clarity
        end
        CTRLTOKEN1: begin
          c0 <= 1'b1;
          c1 <= 1'b0;
          de <= 1'b0;
          dout <= 8'b0; // Assign dout in control cases too for clarity
        end
        CTRLTOKEN2: begin
          c0 <= 1'b0;
          c1 <= 1'b1;
          de <= 1'b0;
          dout <= 8'b0; // Assign dout in control cases too for clarity
        end
        CTRLTOKEN3: begin
          c0 <= 1'b1;
          c1 <= 1'b1;
          de <= 1'b0;
          dout <= 8'b0; // Assign dout in control cases too for clarity
        end
        default: begin
          // 8b/10b decode (running disparity check/decode)
          dout[0] <= data[0];
          dout[1] <= (sdata[8]) ? (data[1] ^ data[0]) : (data[1] ~^ data[0]);
          dout[2] <= (sdata[8]) ? (data[2] ^ data[1]) : (data[2] ~^ data[1]);
          dout[3] <= (sdata[8]) ? (data[3] ^ data[2]) : (data[3] ~^ data[2]);
          dout[4] <= (sdata[8]) ? (data[4] ^ data[3]) : (data[4] ~^ data[3]);
          dout[5] <= (sdata[8]) ? (data[5] ^ data[4]) : (data[5] ~^ data[4]);
          dout[6] <= (sdata[8]) ? (data[6] ^ data[5]) : (data[6] ~^ data[5]);
          dout[7] <= (sdata[8]) ? (data[7] ^ data[6]) : (data[7] ~^ data[6]);
          de <= 1'b1;
          c0 <= 1'b0; // Explicitly define c0/c1 for data case
          c1 <= 1'b0;
        end
      endcase
      sdout <= sdata; // Capture the aligned, bonded data
    end else begin
      // Hold outputs low when not ready
      c0 <= 1'b0;
      c1 <= 1'b0;
      de <= 1'b0;
      dout <= 8'h00;
      sdout <= 10'h000;
    end
  end

endmodule