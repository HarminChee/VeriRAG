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
  input  wire test_mode,
  output wire iamvld,           
  output wire iamrdy,           
  output wire psalgnerr,        
  output reg  c0,
  output reg  c1,
  output reg  de,     
  output reg [9:0] sdout,
  output reg [7:0] dout);

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
  wire toggle_next;
  
  assign toggle_next = test_mode ? 1'b0 : ~toggle;
  
  always @ (posedge pclkx2) begin
    flipgearx2 <= flipgear;
  end

  always @ (posedge pclkx2 or posedge reset)
    if (reset == 1'b1) begin
      toggle <= 1'b0;
    end else begin
      toggle <= toggle_next;
    end

  assign rx_toggle = toggle ^ flipgearx2;

  always @ (posedge pclkx2) begin
    raw5bit_q <= raw5bit;
    if(rx_toggle) 
      rawword <= {raw5bit, raw5bit_q};
  end

  always @ (posedge pclkx2) begin
    bitslip_q <= bitslip;
    bitslipx2 <= bitslip & !bitslip_q;
  end 

  serdes_1_to_5_diff_data # (
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

  phsaligner phsalgn_0 (
     .rst(reset),
     .clk(pclk),
     .sdata(rawdata),
     .bitslip(bitslip),
     .flipgear(flipgear),
     .psaligned(iamvld)
   );

  assign psalgnerr = 1'b0;

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

  assign data = (sdata[9]) ? ~sdata[7:0] : sdata[7:0];

  always @ (posedge pclk) begin
    if(iamrdy && other_ch0_rdy && other_ch1_rdy) begin
      case (sdata) 
        CTRLTOKEN0: begin
          c0 <= 1'b0;
          c1 <= 1'b0;
          de <= 1'b0;
        end
        CTRLTOKEN1: begin
          c0 <= 1'b1;
          c1 <= 1'b0;
          de <= 1'b0;
        end
        CTRLTOKEN2: begin
          c0 <= 1'b0;
          c1 <= 1'b1;
          de <= 1'b0;
        end
        CTRLTOKEN3: begin
          c0 <= 1'b1;
          c1 <= 1'b1;
          de <= 1'b0;
        end
        default: begin 
          dout[0] <= data[0];
          dout[1] <= (sdata[8]) ? (data[1] ^ data[0]) : (data[1] ~^ data[0]);
          dout[2] <= (sdata[8]) ? (data[2] ^ data[1]) : (data[2] ~^ data[1]);
          dout[3] <= (sdata[8]) ? (data[3] ^ data[2]) : (data[3] ~^ data[2]);
          dout[4] <= (sdata[8]) ? (data[4] ^ data[3]) : (data[4] ~^ data[3]);
          dout[5] <= (sdata[8]) ? (data[5] ^ data[4]) : (data[5] ~^ data[4]);
          dout[6] <= (sdata[8]) ? (data[6] ^ data[5]) : (data[6] ~^ data[5]);
          dout[7] <= (sdata[8]) ? (data[7] ^ data[6]) : (data[7] ~^ data[6]);
          de <= 1'b1;
        end                                                                      
      endcase                                                                    
      sdout <= sdata;
    end else begin
      c0 <= 1'b0;
      c1 <= 1'b0;
      de <= 1'b0;
      dout <= 8'h0;
      sdout <= 10'h0;
    end
  end
endmodule