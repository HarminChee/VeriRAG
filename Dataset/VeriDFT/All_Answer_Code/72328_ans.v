`timescale 1 ns / 1ps
`timescale 1 ns / 1ps
module decode_nok # (
  parameter CHANNEL = "BLUE"
)
(
  input  wire scan_reset,
  input  wire reset,            
  input  wire pclk,             
  input wire scan_clk,
  input  wire pclkx2,           
  input wire test_i ,
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
  output wire iamvld,           
  output wire iamrdy,           
  output wire psalgnerr,        
  output reg  c0,
  output reg  c1,
  output reg  vde,
  output reg  ade,
  output reg [9:0] sdout,       
  output reg [3:0] adout,       
  output reg [7:0] vdout);     
  wire flipgear;
  reg flipgearx2;
  wire dft_pclkx2,dft_pclk;
  wire dft_reset;
  assign dft_pclk = test_i ? scan_clk : pclk ;
  assign dft_pclkx2 = test_i ? scan_clk : pclkx2 ;
  assign dft_reset = test_i ? scan_reset : reset ;
  always @ (posedge dft_pclkx2) begin
    flipgearx2 <=#1 flipgear;
  end
  reg toggle = 1'b0;
  always @ (posedge dft_pclkx2 or posedge dft_reset)
    if (dft_reset == 1'b1) begin
      toggle <= 1'b0 ;
    end else begin
      toggle <=#1 ~toggle;
    end
  wire rx_toggle;
  assign rx_toggle = toggle ^ flipgearx2; 
  wire [4:0] raw5bit;
  reg [4:0] raw5bit_q;
  reg [9:0] rawword;
  always @ (posedge dft_pclkx2) begin
    raw5bit_q    <=#1 raw5bit;
    if(rx_toggle) 
      rawword <=#1 {raw5bit, raw5bit_q};
  end
  reg bitslipx2 = 1'b0;
  reg bitslip_q = 1'b0;
  wire bitslip;
  always @ (posedge dft_pclkx2) begin
    bitslip_q <=#1 bitslip;
    bitslipx2 <=#1 bitslip & !bitslip_q;
  end 
  serdes_1_to_5_diff_data_nok # (
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
  wire [9:0] rawdata = rawword;
  phsaligner_nok # (
	 .CHANNEL(CHANNEL)
  ) phsalgn_0 (
     .rst(reset),
     .clk(pclk),
     .sdata(rawdata),
     .bitslip(bitslip),
     .flipgear(flipgear),
     .psaligned(iamvld)
   );
  assign psalgnerr = 1'b0;
  wire [9:0] sdata;
  chnlbond cbnd (
    .clk(pclk),
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
  wire [7:0] data;
  assign data = (sdata[9]) ? ~sdata[7:0] : sdata[7:0]; 
  reg control  = 1'b0;
  reg control_q;
  always @ (posedge dft_pclk) begin
    control_q <=#1 control;
  end
  wire control_end;
  assign control_end = !control & control_q;
  reg videoperiod = 1'b0;
  always @ (posedge dft_pclk) begin
    if(control)
      videoperiod <=#1 1'b0;
    else if(control_end && videopreamble)
      videoperiod <=#1 1'b1;
  end
  reg dilndperiod = 1'b0;
  always @ (posedge dft_pclk) begin
    if(control)
      dilndperiod <=#1 1'b0;
    else if(control_end && dilndpreamble)
      dilndperiod <=#1 1'b1;
  end
  always @ (posedge dft_pclk) begin
    if(iamrdy && other_ch0_rdy && other_ch1_rdy) begin
      case (sdata) 
        CTRLTOKEN0: begin
          c0  <=#1 1'b0;
          c1  <=#1 1'b0;
          vde <=#1 1'b0;
		  ade <=#1 1'b0;
		  control <=#1 1'b1;
        end
        CTRLTOKEN1: begin
          c0  <=#1 1'b1;
          c1  <=#1 1'b0;
          vde <=#1 1'b0;
          ade <=#1 1'b0;
          control <=#1 1'b1;
        end
        CTRLTOKEN2: begin
          c0  <=#1 1'b0;
          c1  <=#1 1'b1;
          vde <=#1 1'b0;
          ade <=#1 1'b0;
          control <=#1 1'b1;
        end
        CTRLTOKEN3: begin
          c0  <=#1 1'b1;
          c1  <=#1 1'b1;
          vde <=#1 1'b0;
          ade <=#1 1'b0;
          control <=#1 1'b1;
        end
        default: begin 
		  control <=#1 1'b0;
          if(videoperiod) begin 
            vdout[0] <=#1 data[0];
            vdout[1] <=#1 (sdata[8]) ? (data[1] ^ data[0]) : (data[1] ~^ data[0]);
            vdout[2] <=#1 (sdata[8]) ? (data[2] ^ data[1]) : (data[2] ~^ data[1]);
            vdout[3] <=#1 (sdata[8]) ? (data[3] ^ data[2]) : (data[3] ~^ data[2]);
            vdout[4] <=#1 (sdata[8]) ? (data[4] ^ data[3]) : (data[4] ~^ data[3]);
            vdout[5] <=#1 (sdata[8]) ? (data[5] ^ data[4]) : (data[5] ~^ data[4]);
            vdout[6] <=#1 (sdata[8]) ? (data[6] ^ data[5]) : (data[6] ~^ data[5]);
            vdout[7] <=#1 (sdata[8]) ? (data[7] ^ data[6]) : (data[7] ~^ data[6]);
            ade <=#1 1'b0;
            vde <=#1 1'b1;
		  end else if((CHANNEL == "BLUE") || dilndperiod) begin
            case (sdata)
              10'b1010011100: begin adout <=#1 4'b0000; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b1001100011: begin adout <=#1 4'b0001; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b1011100100: begin adout <=#1 4'b0010; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b1011100010: begin adout <=#1 4'b0011; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b0101110001: begin adout <=#1 4'b0100; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b0100011110: begin adout <=#1 4'b0101; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b0110001110: begin adout <=#1 4'b0110; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b0100111100: begin adout <=#1 4'b0111; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b1011001100: begin 
                if((CHANNEL == "BLUE") && control_q)
                  ade   <=#1 1'b0;
                else begin
                  adout <=#1 4'b1000;
                  ade   <=#1 1'b1;
                end
                vde     <=#1 1'b0;
              end
              10'b0100111001: begin adout <=#1 4'b1001; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b0110011100: begin adout <=#1 4'b1010; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b1011000110: begin adout <=#1 4'b1011; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b1010001110: begin adout <=#1 4'b1100; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b1001110001: begin adout <=#1 4'b1101; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b0101100011: begin adout <=#1 4'b1110; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b1011000011: begin adout <=#1 4'b1111; ade <=#1 1'b1; vde <=#1 1'b0; end
              default:        begin adout <=#1 adout;   ade <=#1 1'b0; vde <=#1 1'b0; end
            endcase
          end
        end                                                                      
      endcase                                                                    
      sdout <=#1 sdata;
    end else begin
      c0    <= 1'b0;
      c1    <= 1'b0;
      vde   <= 1'b0;
      ade   <= 1'b0;
      vdout <= 8'h0;
      adout <= 4'h0;
      sdout <= 10'h0;
    end
  end
endmodule
