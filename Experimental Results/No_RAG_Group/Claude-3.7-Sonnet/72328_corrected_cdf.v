module decode_nok #(
  parameter CHANNEL = "BLUE"
)
(
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
  input  wire videopreamble,    
  input  wire dilndpreamble,    
  input  wire test_mode,        // Added test mode input

  output wire iamvld,           
  output wire iamrdy,           
  output wire psalgnerr,        
  output reg  c0,
  output reg  c1,
  output reg  vde,
  output reg  ade,
  output reg [9:0] sdout,       
  output reg [3:0] adout,       
  output reg [7:0] vdout
);

  wire flipgear;
  reg flipgearx2;
  reg toggle;
  wire rx_toggle;
  wire [4:0] raw5bit;
  reg [4:0] raw5bit_q;
  reg [9:0] rawword;
  reg bitslipx2;
  reg bitslip_q;
  wire bitslip;
  wire [9:0] rawdata;
  wire [9:0] sdata;
  wire [7:0] data;
  reg control;
  reg control_q;
  wire control_end;
  reg videoperiod;
  reg dilndperiod;
  reg clk_data;

  // Clock mux for test mode
  wire gated_pclk;
  assign gated_pclk = test_mode ? pclk : clk_data;

  always @(posedge pclkx2 or posedge reset) begin
    if (reset) begin
      toggle <= 1'b0;
      clk_data <= 1'b0;
    end else begin
      toggle <= ~toggle;
      clk_data <= toggle;
    end
  end

  always @(posedge pclkx2) begin
    flipgearx2 <= flipgear;
    raw5bit_q <= raw5bit;
    if(rx_toggle)
      rawword <= {raw5bit, raw5bit_q};
  end

  assign rx_toggle = toggle ^ flipgearx2;

  always @(posedge pclkx2) begin
    bitslip_q <= bitslip;
    bitslipx2 <= bitslip & !bitslip_q;
  end

  serdes_1_to_5_diff_data_nok #(
    .DIFF_TERM("FALSE"),
    .BITSLIP_ENABLE("TRUE")
  ) des_0 (
    .use_phase_detector(1'b1),
    .datain_p(din_p),
    .datain_n(din_n), 
    .rxioclk(pclkx10),
    .rxserdesstrobe(serdesstrobe),
    .reset(reset),
    .gclk(pclkx2),
    .bitslip(bitslipx2),
    .data_out(raw5bit)
  );

  assign rawdata = rawword;

  phsaligner_nok #(
    .CHANNEL(CHANNEL)
  ) phsalgn_0 (
    .rst(reset),
    .clk(gated_pclk),
    .sdata(rawdata),
    .bitslip(bitslip),
    .flipgear(flipgear),
    .psaligned(iamvld)
  );

  assign psalgnerr = 1'b0;

  chnlbond cbnd (
    .clk(gated_pclk),
    .rawdata(rawdata),
    .iamvld(iamvld),
    .other_ch0_vld(other_ch0_vld),
    .other_ch1_vld(other_ch1_vld), 
    .other_ch0_rdy(other_ch0_rdy),
    .other_ch1_rdy(other_ch1_rdy),
    .iamrdy(iamrdy),
    .sdata(sdata)
  );

  parameter CTRLTOKEN0 = 10'b1101010100;
  parameter CTRLTOKEN1 = 10'b0010101011;
  parameter CTRLTOKEN2 = 10'b0101010100;
  parameter CTRLTOKEN3 = 10'b1010101011;

  assign data = (sdata[9]) ? ~sdata[7:0] : sdata[7:0];

  always @(posedge gated_pclk) begin
    control_q <= control;
  end

  assign control_end = !control & control_q;

  always @(posedge gated_pclk) begin
    if(control)
      videoperiod <= 1'b0;
    else if(control_end && videopreamble)
      videoperiod <= 1'b1;
  end

  always @(posedge gated_pclk) begin
    if(control)
      dilndperiod <= 1'b0;
    else if(control_end && dilndpreamble)
      dilndperiod <= 1'b1;
  end

  always @(posedge gated_pclk) begin
    if(iamrdy && other_ch0_rdy && other_ch1_rdy) begin
      case (sdata)
        CTRLTOKEN0: begin
          c0 <= 1'b0;
          c1 <= 1'b0;
          vde <= 1'b0;
          ade <= 1'b0;
          control <= 1'b1;
        end

        CTRLTOKEN1: begin
          c0 <= 1'b1;
          c1 <= 1'b0;
          vde <= 1'b0;
          ade <= 1'b0;
          control <= 1'b1;
        end

        CTRLTOKEN2: begin
          c0 <= 1'b0;
          c1 <= 1'b1;
          vde <= 1'b0;
          ade <= 1'b0;
          control <= 1'b1;
        end

        CTRLTOKEN3: begin
          c0 <= 1'b1;
          c1 <= 1'b1;
          vde <= 1'b0;
          ade <= 1'b0;
          control <= 1'b1;
        end

        default: begin
          control <= 1'b0;

          if(videoperiod) begin
            vdout[0] <= data[0];
            vdout[1] <= (sdata[8]) ? (data[1] ^ data[0]) : (data[1] ~^ data[0]);
            vdout[2] <= (sdata[8]) ? (data[2] ^ data[1]) : (data[2] ~^ data[1]);
            vdout[3] <= (sdata[8]) ? (data[3] ^ data[2]) : (data[3] ~^ data[2]);
            vdout[4] <= (sdata[8]) ? (data[4] ^ data[3]) : (data[4] ~^ data[3]);
            vdout[5] <= (sdata[8]) ? (data[5] ^ data[4]) : (data[5] ~^ data[4]);
            vdout[6] <= (sdata[8]) ? (data[6] ^ data[5]) : (data[6] ~^ data[5]);
            vdout[7] <= (sdata[8]) ? (data[7] ^ data[6]) : (data[7] ~^ data[6]);

            ade <= 1'b0;
            vde <= 1'b1;
          end else if((CHANNEL == "BLUE") || dilndperiod) begin
            case (sdata)
              10'b1010011100: begin adout <= 4'b0000; ade <= 1'b1; vde <= 1'b0; end
              10'b1001100011: begin adout <= 4'b0001; ade <= 1'b1; vde <= 1'b0; end
              10'b1011100100: begin adout <= 4'b0010; ade <= 1'b1; vde <= 1'b0; end
              10'b1011100010: begin adout <= 4'b0011; ade <= 1'b1; vde <= 1'b0; end
              10'b0101110001: begin adout <= 4'b0100; ade <= 1'b1; vde <= 1'b0; end
              10'b0100011110: begin adout <= 4'b0101; ade <= 1'b1; vde <= 1'b0; end
              10'b0110001110: begin adout <= 4'b0110; ade <= 1'b1; vde <= 1'b0; end
              10'b0100111100: begin adout <= 4'b0111; ade <= 1'b1; vde <= 1'b0; end
              10'b1011001100: begin
                if((CHANNEL == "BLUE") && control_q)
                  ade <= 1'b0;
                else begin
                  adout <= 4'b1000;
                  ade <= 1'b1;
                end
                vde <= 1'b0;
              end
              10'b0100111001: begin adout <= 4'b1001; ade <= 1'b1; vde <= 1'b0; end
              10'b0110011100: begin adout <= 4'b1010; ade <= 1'b1; vde <= 1'b0; end
              10'b1011000110: begin adout <= 4'b1011; ade <= 1'b1; vde <= 1'b0; end
              10'b1010001110: begin adout <= 4'b1100; ade <= 1'b1; vde <= 1'b0; end
              10'b1001110001: begin adout <= 4'b1101; ade <= 1'b1; vde <= 1'b0; end
              10'b0101100011: begin adout <= 4'b1110; ade <= 1'b1; vde <= 1'b0; end
              10'b1011000011: begin adout <= 4'b1111; ade <= 1'b1; vde <= 1'b0; end
              default:        begin adout <= adout;   ade <= 1'b0; vde <= 1'b0; end
            endcase
          end
        end
      endcase

      sdout <= sdata;
    end else begin
      c0 <= 1'b0;
      c1 <= 1'b0;
      vde <= 1'b0;
      ade <= 1'b0;
      vdout <= 8'h0;
      adout <= 4'h0;
      sdout <= 10'h0;
    end
  end

endmodule