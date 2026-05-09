`timescale 1ns/100ps
module util_adc_pack (
  clk,
  chan_enable_0,
  chan_valid_0,
  chan_data_0,
  chan_enable_1,
  chan_valid_1,
  chan_data_1,
  chan_enable_2,
  chan_valid_2,
  chan_data_2,
  chan_enable_3,
  chan_valid_3,
  chan_data_3,
  chan_enable_4,
  chan_valid_4,
  chan_data_4,
  chan_enable_5,
  chan_valid_5,
  chan_data_5,
  chan_enable_6,
  chan_valid_6,
  chan_data_6,
  chan_enable_7,
  chan_valid_7,
  chan_data_7,
  ddata,
  dvalid,
  dsync
  );
  parameter CHANNELS    = 8 ; 
  parameter DATA_WIDTH  = 16; 
  input           clk;
  input                       chan_enable_0;
  input                       chan_valid_0;
  input   [(DATA_WIDTH-1):0]  chan_data_0;
  input                       chan_enable_1;
  input                       chan_valid_1;
  input   [(DATA_WIDTH-1):0]  chan_data_1;
  input                       chan_enable_2;
  input                       chan_valid_2;
  input   [(DATA_WIDTH-1):0]  chan_data_2;
  input                       chan_enable_3;
  input                       chan_valid_3;
  input   [(DATA_WIDTH-1):0]  chan_data_3;
  input                       chan_enable_4;
  input                       chan_valid_4;
  input   [(DATA_WIDTH-1):0]  chan_data_4;
  input                       chan_enable_5;
  input                       chan_valid_5;
  input   [(DATA_WIDTH-1):0]  chan_data_5;
  input                       chan_enable_6;
  input                       chan_valid_6;
  input   [(DATA_WIDTH-1):0]  chan_data_6;
  input                       chan_valid_7;
  input                       chan_enable_7;
  input   [(DATA_WIDTH-1):0]  chan_data_7;
  output  [(DATA_WIDTH*CHANNELS-1):0] ddata;
  output                              dvalid;
  output                              dsync;
  reg  [(DATA_WIDTH*CHANNELS-1):0]    packed_data = 0;
  reg  [(DATA_WIDTH*CHANNELS-1):0]    temp_data_0 = 0;
  reg  [(DATA_WIDTH*CHANNELS-1):0]    temp_data_1 = 0;
  reg  [3:0]      enable_cnt;
  reg  [2:0]      enable_cnt_0;
  reg  [2:0]      enable_cnt_1;
  reg  [7:0]      path_enabled = 0;
  reg  [7:0]      path_enabled_d1 = 0;
  reg  [6:0]      counter_0 = 0;
  reg  [7:0]      en1 = 0;
  reg  [7:0]      en2 = 0;
  reg  [7:0]      en4 = 0;
  reg             dvalid = 0;
  reg  [(DATA_WIDTH*CHANNELS-1):0]  ddata = 0;
  reg  [(DATA_WIDTH-1):0]           chan_data_0_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_1_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_2_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_3_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_4_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_5_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_6_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_7_r;
  wire            chan_valid;
  assign dsync        = dvalid;
  assign chan_valid   = chan_valid_0 | chan_valid_1 | chan_valid_2 | chan_valid_3 | chan_valid_4 | chan_valid_5 | chan_valid_6 | chan_valid_7 ;
  always @(posedge clk)
  begin
    enable_cnt   = enable_cnt_0 + enable_cnt_1;
    enable_cnt_0 = chan_enable_0 + chan_enable_1 + chan_enable_2 + chan_enable_3;
    if (CHANNELS == 8)
    begin
      enable_cnt_1 = chan_enable_4 + chan_enable_5 + chan_enable_6 + chan_enable_7;
    end
    else
    begin
      enable_cnt_1 = 0;
    end
  end
  always @(posedge clk)
  begin
    if(chan_valid == 1'b1)
    begin
      chan_data_0_r <= chan_data_0;
      chan_data_1_r <= chan_data_1;
      chan_data_2_r <= chan_data_2;
      chan_data_3_r <= chan_data_3;
      chan_data_4_r <= chan_data_4;
      chan_data_5_r <= chan_data_5;
      chan_data_6_r <= chan_data_6;
      chan_data_7_r <= chan_data_7;
    end
  end
  always @(chan_data_0_r, chan_data_1_r, chan_data_2_r, chan_data_3_r, chan_enable_0, chan_enable_1, chan_enable_2, chan_enable_3 )
  begin
    casex ({chan_enable_3,chan_enable_2,chan_enable_1,chan_enable_0})
      4'bxxx1: temp_data_0[(DATA_WIDTH-1):0] = chan_data_0_r;
      4'bxx10: temp_data_0[(DATA_WIDTH-1):0] = chan_data_1_r;
      4'bx100: temp_data_0[(DATA_WIDTH-1):0] = chan_data_2_r;
      4'b1000: temp_data_0[(DATA_WIDTH-1):0] = chan_data_3_r;
      default: temp_data_0 [(DATA_WIDTH-1):0] = 0;
    endcase
    casex ({chan_enable_3,chan_enable_2,chan_enable_1,chan_enable_0})
      4'bxx11: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_1_r;
      4'bx110: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_2_r;
      4'bx101: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_2_r;
      4'b1001: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_3_r;
      4'b1010: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_3_r;
      4'b1100: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_3_r;
      default: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = 0;
    endcase
    casex ({chan_enable_3,chan_enable_2,chan_enable_1,chan_enable_0})
      4'bx111: temp_data_0[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_2_r;
      4'b1011: temp_data_0[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_3_r;
      4'b1101: temp_data_0[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_3_r;
      4'b1110: temp_data_0[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_3_r;
      default: temp_data_0[3*DATA_WIDTH-1:2*DATA_WIDTH] = 0;
    endcase
    case ({chan_enable_3,chan_enable_2,chan_enable_1,chan_enable_0})
      4'b1111: temp_data_0[4*DATA_WIDTH-1:3*DATA_WIDTH] = chan_data_3_r;
      default: temp_data_0[4*DATA_WIDTH-1:3*DATA_WIDTH] = 0;
    endcase
  end
  always @(chan_data_4_r, chan_data_5_r, chan_data_6_r, chan_data_7_r, chan_enable_4, chan_enable_5, chan_enable_6, chan_enable_7)
  begin
    casex ({chan_enable_7,chan_enable_6,chan_enable_5,chan_enable_4})
      4'bxxx1: temp_data_1[(DATA_WIDTH-1):0] = chan_data_4_r;
      4'bxx10: temp_data_1[(DATA_WIDTH-1):0] = chan_data_5_r;
      4'bx100: temp_data_1[(DATA_WIDTH-1):0] = chan_data_6_r;
      4'b1000: temp_data_1[(DATA_WIDTH-1):0] = chan_data_7_r;
      default: temp_data_1[(DATA_WIDTH-1):0] = 0;
    endcase
    casex ({chan_enable_7,chan_enable_6,chan_enable_5,chan_enable_4})
      4'bxx11: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_5_r;
      4'bx110: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_6_r;
      4'bx101: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_6_r;
      4'b1001: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_7_r;
      4'b1010: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_7_r;
      4'b1100: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_7_r;
      default: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = 0;
    endcase
    casex ({chan_enable_7,chan_enable_6,chan_enable_5,chan_enable_4})
      4'bx111: temp_data_1[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_6_r;
      4'b1011: temp_data_1[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_7_r;
      4'b1101: temp_data_1[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_7_r;
      4'b1110: temp_data_1[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_7_r;
      default: temp_data_1[3*DATA_WIDTH-1:2*DATA_WIDTH] = 0;
    endcase
    case ({chan_enable_7,chan_enable_6,chan_enable_5,chan_enable_4})
      4'b1111: temp_data_1[4*DATA_WIDTH-1:3*DATA_WIDTH] = chan_data_7_r;
      default: temp_data_1[4*DATA_WIDTH-1:3*DATA_WIDTH] = 0;
    endcase
  end
  always @(enable_cnt)
  begin
    case(enable_cnt)
     4'h1: path_enabled = 8'h01;
     4'h2: path_enabled = 8'h02;
     4'h4: path_enabled = 8'h08;
     4'h8: path_enabled = 8'h80;
     default: path_enabled = 8'h0;
    endcase
  end
  always @(temp_data_0, temp_data_1, enable_cnt_0)
  begin
    packed_data = temp_data_0 | temp_data_1 << (enable_cnt_0 * DATA_WIDTH);
  end
  always @(counter_0, path_enabled)
  begin
    case (counter_0)
      0:
      begin
        en1 = path_enabled[0];
        en2 = {2{path_enabled[1]}};
        en4 = {4{path_enabled[3]}};
      end
      1:
      begin
        en1 = path_enabled[0]       << 1;
        en2 = {2{path_enabled[1]}}  << 0;
        en4 = {4{path_enabled[3]}}  << 0;
      end
      2:
      begin
        en1 = path_enabled[0]       << 2;
        en2 = {2{path_enabled[1]}}  << 2;
        en4 = {4{path_enabled[3]}}  << 0;
      end
      3:
      begin
        en1 = path_enabled[0]       << 3;
        en2 = {2{path_enabled[1]}}  << 2;
        en4 = {4{path_enabled[3]}}  << 0;
      end
      4:
      begin
        if (CHANNELS == 8)
        begin
          en1 = path_enabled[0]       << 4;
          en2 = {2{path_enabled[1]}}  << 4;
          en4 = {4{path_enabled[3]}}  << 4;
        end
        else
        begin
          en1 = path_enabled[0];
          en2 = {2{path_enabled[1]}};
          en4 = {4{path_enabled[3]}};
        end
      end
      5:
      begin
        en1 = path_enabled[0]       << 5;
        en2 = {2{path_enabled[1]}}  << 4;
        en4 = {4{path_enabled[3]}}  << 4;
      end
      6:
      begin
        en1 = path_enabled[0]       << 6;
        en2 = {2{path_enabled[1]}}  << 6;
        en4 = {4{path_enabled[3]}}  << 4;
      end
      7:
      begin
        en1 = path_enabled[0]       << 7;
        en2 = {2{path_enabled[1]}}  << 6;
        en4 = {4{path_enabled[3]}}  << 4;
      end
      8:
      begin
        en1 = path_enabled[0]       << 0;
        en2 = {2{path_enabled[1]}}  << 0;
        en4 = {4{path_enabled[3]}}  << 0;
      end
      default:
      begin
        en1 = 8'h0;
        en2 = 8'h0;
        en4 = 8'h0;
      end
    endcase
  end
  always @(posedge clk)
  begin
    path_enabled_d1 <= path_enabled;
    if (path_enabled == 8'h0 || path_enabled_d1 != path_enabled )
    begin
      counter_0 <= 7'h0;
    end
    else
    begin
      if( chan_valid == 1'b1)
      begin
        if (counter_0 > (CHANNELS - 1) )
        begin
          counter_0 <= counter_0 - CHANNELS + enable_cnt;
        end
        else
        begin
          counter_0 <= counter_0 + enable_cnt;
        end
        if ((counter_0 == (CHANNELS - enable_cnt)) || (path_enabled == (8'h1 << (CHANNELS - 1)) ))
        begin
          dvalid  <= 1'b1;
        end
        else
        begin
          dvalid  <= 1'b0;
        end
      end
      else
      begin
        dvalid      <= 1'b0;
      end
    end
  end
  generate
  if ( CHANNELS == 8 )
  begin
    always @(posedge clk)
    begin
      if ((en1[0] | en2[0] | en4[0] | path_enabled[CHANNELS-1]) == 1'b1)
      begin
        ddata[(DATA_WIDTH-1):0]     <=  packed_data[(DATA_WIDTH-1):0];
      end
      if( en1[1] == 1'b1)
      begin
        ddata[2*DATA_WIDTH-1:DATA_WIDTH]    <= packed_data[(DATA_WIDTH-1):0];
      end
      if ( (en2[1] | en4[1] | path_enabled[CHANNELS-1]) == 1'b1)
      begin
        ddata[2*DATA_WIDTH-1:DATA_WIDTH]    <= packed_data[2*DATA_WIDTH-1:DATA_WIDTH];
      end
      if ((en1[2] | en2[2]) == 1'b1)
      begin
        ddata[3*DATA_WIDTH-1:2*DATA_WIDTH]    <= packed_data[(DATA_WIDTH-1):0];
      end
      if ((en4[2] | path_enabled[CHANNELS-1]) == 1'b1)
      begin
        ddata[3*DATA_WIDTH-1:2*DATA_WIDTH]    <= packed_data[3*DATA_WIDTH-1:2*DATA_WIDTH];
      end
      if (en1[3] == 1'b1)
      begin
        ddata[4*DATA_WIDTH-1:3*DATA_WIDTH] <= packed_data[(DATA_WIDTH-1):0];
      end
      if (en2[3] == 1'b1)
      begin
        ddata[4*DATA_WIDTH-1:3*DATA_WIDTH] <= packed_data[2*DATA_WIDTH-1:DATA_WIDTH];
      end
      if ((en4[3] | path_enabled[CHANNELS-1]) == 1'b1)
      begin
        ddata[4*DATA_WIDTH-1:3*DATA_WIDTH] <= packed_data[4*DATA_WIDTH-1:3*DATA_WIDTH];
      end
      if ((en1[4] | en2[4] | en4[4]) == 1'b1)
      begin
        ddata[5*DATA_WIDTH-1:4*DATA_WIDTH] <= packed_data[(DATA_WIDTH-1):0];
      end
      if (path_enabled[CHANNELS-1] == 1'b1)
      begin
        ddata[5*DATA_WIDTH-1:4*DATA_WIDTH] <= packed_data[5*DATA_WIDTH-1:4*DATA_WIDTH];
      end
      if (en1[5] == 1'b1)
      begin
        ddata[6*DATA_WIDTH-1:5*DATA_WIDTH] <= packed_data[(DATA_WIDTH-1):0];
      end
      if ((en2[5] | en4[5]) == 1'b1)
      begin
        ddata[6*DATA_WIDTH-1:5*DATA_WIDTH] <= packed_data[2*DATA_WIDTH-1:DATA_WIDTH];
      end
      if (path_enabled[CHANNELS-1] == 1'b1)
      begin
        ddata[6*DATA_WIDTH-1:5*DATA_WIDTH] <= packed_data[6*DATA_WIDTH-1:5*DATA_WIDTH];
      end
      if ((en1[6] | en2[6]) == 1'b1)
      begin
        ddata[7*DATA_WIDTH-1:6*DATA_WIDTH] <= packed_data[(DATA_WIDTH-1):0];
      end
      if (en4[6] == 1'b1)
      begin
        ddata[7*DATA_WIDTH-1:6*DATA_WIDTH] <= packed_data[3*DATA_WIDTH-1:2*DATA_WIDTH];
      end
      if (path_enabled[CHANNELS-1] == 1'b1)
      begin
        ddata[7*DATA_WIDTH-1:6*DATA_WIDTH] <= packed_data[7*DATA_WIDTH-1:6*DATA_WIDTH];
      end
      if (en1[7] == 1'b1)
      begin
        ddata[8*DATA_WIDTH-1:7*DATA_WIDTH]  <= packed_data[(DATA_WIDTH-1):0];
      end
      if (en2[7] == 1'b1)
      begin
        ddata[8*DATA_WIDTH-1:7*DATA_WIDTH]  <= packed_data[2*DATA_WIDTH-1:DATA_WIDTH];
      end
      if (en4[7] == 1'b1)
      begin
        ddata[8*DATA_WIDTH-1:7*DATA_WIDTH]  <= packed_data[4*DATA_WIDTH-1:3*DATA_WIDTH];
      end
      if (path_enabled[CHANNELS-1] == 1'b1)
      begin
        ddata[8*DATA_WIDTH-1:7*DATA_WIDTH]  <= packed_data[8*DATA_WIDTH-1:7*DATA_WIDTH];
      end
    end
  end
  else
  begin
    always @(posedge clk)
    begin
      if ((en1[0] | en2[0] | path_enabled[3] ) == 1'b1)
      begin
        ddata[(DATA_WIDTH-1):0]     <=  packed_data[(DATA_WIDTH-1):0];
      end
      if( en1[1] == 1'b1)
      begin
        ddata[2*DATA_WIDTH-1:DATA_WIDTH]    <= packed_data[(DATA_WIDTH-1):0];
      end
      if ( (en2[1] | | path_enabled[3] )== 1'b1)
      begin
        ddata[2*DATA_WIDTH-1:DATA_WIDTH]    <= packed_data[2*DATA_WIDTH-1:DATA_WIDTH];
      end
      if ((en1[2] | en2[2]) == 1'b1)
      begin
        ddata[3*DATA_WIDTH-1:2*DATA_WIDTH]    <= packed_data[(DATA_WIDTH-1):0];
      end
      if (( path_enabled[3]) == 1'b1)
      begin
        ddata[3*DATA_WIDTH-1:2*DATA_WIDTH]    <= packed_data[3*DATA_WIDTH-1:2*DATA_WIDTH];
      end
      if (en1[3] == 1'b1)
      begin
        ddata[4*DATA_WIDTH-1:3*DATA_WIDTH] <= packed_data[(DATA_WIDTH-1):0];
      end
      if (en2[3] == 1'b1)
      begin
        ddata[4*DATA_WIDTH-1:3*DATA_WIDTH] <= packed_data[2*DATA_WIDTH-1:DATA_WIDTH];
      end
      if (path_enabled[3] == 1'b1)
      begin
        ddata[4*DATA_WIDTH-1:3*DATA_WIDTH] <= packed_data[4*DATA_WIDTH-1:3*DATA_WIDTH];
      end
    end
  end
  endgenerate
  endmodule
`timescale 1ns/100ps
module util_adc_pack (
  clk,
  chan_enable_0,
  chan_valid_0,
  chan_data_0,
  chan_enable_1,
  chan_valid_1,
  chan_data_1,
  chan_enable_2,
  chan_valid_2,
  chan_data_2,
  chan_enable_3,
  chan_valid_3,
  chan_data_3,
  chan_enable_4,
  chan_valid_4,
  chan_data_4,
  chan_enable_5,
  chan_valid_5,
  chan_data_5,
  chan_enable_6,
  chan_valid_6,
  chan_data_6,
  chan_enable_7,
  chan_valid_7,
  chan_data_7,
  ddata,
  dvalid,
  dsync
  );
  parameter CHANNELS    = 8 ; 
  parameter DATA_WIDTH  = 16; 
  input           clk;
  input                       chan_enable_0;
  input                       chan_valid_0;
  input   [(DATA_WIDTH-1):0]  chan_data_0;
  input                       chan_enable_1;
  input                       chan_valid_1;
  input   [(DATA_WIDTH-1):0]  chan_data_1;
  input                       chan_enable_2;
  input                       chan_valid_2;
  input   [(DATA_WIDTH-1):0]  chan_data_2;
  input                       chan_enable_3;
  input                       chan_valid_3;
  input   [(DATA_WIDTH-1):0]  chan_data_3;
  input                       chan_enable_4;
  input                       chan_valid_4;
  input   [(DATA_WIDTH-1):0]  chan_data_4;
  input                       chan_enable_5;
  input                       chan_valid_5;
  input   [(DATA_WIDTH-1):0]  chan_data_5;
  input                       chan_enable_6;
  input                       chan_valid_6;
  input   [(DATA_WIDTH-1):0]  chan_data_6;
  input                       chan_valid_7;
  input                       chan_enable_7;
  input   [(DATA_WIDTH-1):0]  chan_data_7;
  output  [(DATA_WIDTH*CHANNELS-1):0] ddata;
  output                              dvalid;
  output                              dsync;
  reg  [(DATA_WIDTH*CHANNELS-1):0]    packed_data = 0;
  reg  [(DATA_WIDTH*CHANNELS-1):0]    temp_data_0 = 0;
  reg  [(DATA_WIDTH*CHANNELS-1):0]    temp_data_1 = 0;
  reg  [3:0]      enable_cnt;
  reg  [2:0]      enable_cnt_0;
  reg  [2:0]      enable_cnt_1;
  reg  [7:0]      path_enabled = 0;
  reg  [7:0]      path_enabled_d1 = 0;
  reg  [6:0]      counter_0 = 0;
  reg  [7:0]      en1 = 0;
  reg  [7:0]      en2 = 0;
  reg  [7:0]      en4 = 0;
  reg             dvalid = 0;
  reg  [(DATA_WIDTH*CHANNELS-1):0]  ddata = 0;
  reg  [(DATA_WIDTH-1):0]           chan_data_0_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_1_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_2_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_3_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_4_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_5_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_6_r;
  reg  [(DATA_WIDTH-1):0]           chan_data_7_r;
  wire            chan_valid;
  assign dsync        = dvalid;
  assign chan_valid   = chan_valid_0 | chan_valid_1 | chan_valid_2 | chan_valid_3 | chan_valid_4 | chan_valid_5 | chan_valid_6 | chan_valid_7 ;
  always @(posedge clk)
  begin
    enable_cnt   = enable_cnt_0 + enable_cnt_1;
    enable_cnt_0 = chan_enable_0 + chan_enable_1 + chan_enable_2 + chan_enable_3;
    if (CHANNELS == 8)
    begin
      enable_cnt_1 = chan_enable_4 + chan_enable_5 + chan_enable_6 + chan_enable_7;
    end
    else
    begin
      enable_cnt_1 = 0;
    end
  end
  always @(posedge clk)
  begin
    if(chan_valid == 1'b1)
    begin
      chan_data_0_r <= chan_data_0;
      chan_data_1_r <= chan_data_1;
      chan_data_2_r <= chan_data_2;
      chan_data_3_r <= chan_data_3;
      chan_data_4_r <= chan_data_4;
      chan_data_5_r <= chan_data_5;
      chan_data_6_r <= chan_data_6;
      chan_data_7_r <= chan_data_7;
    end
  end
  always @(chan_data_0_r, chan_data_1_r, chan_data_2_r, chan_data_3_r, chan_enable_0, chan_enable_1, chan_enable_2, chan_enable_3 )
  begin
    casex ({chan_enable_3,chan_enable_2,chan_enable_1,chan_enable_0})
      4'bxxx1: temp_data_0[(DATA_WIDTH-1):0] = chan_data_0_r;
      4'bxx10: temp_data_0[(DATA_WIDTH-1):0] = chan_data_1_r;
      4'bx100: temp_data_0[(DATA_WIDTH-1):0] = chan_data_2_r;
      4'b1000: temp_data_0[(DATA_WIDTH-1):0] = chan_data_3_r;
      default: temp_data_0 [(DATA_WIDTH-1):0] = 0;
    endcase
    casex ({chan_enable_3,chan_enable_2,chan_enable_1,chan_enable_0})
      4'bxx11: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_1_r;
      4'bx110: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_2_r;
      4'bx101: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_2_r;
      4'b1001: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_3_r;
      4'b1010: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_3_r;
      4'b1100: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_3_r;
      default: temp_data_0[2*DATA_WIDTH-1:DATA_WIDTH] = 0;
    endcase
    casex ({chan_enable_3,chan_enable_2,chan_enable_1,chan_enable_0})
      4'bx111: temp_data_0[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_2_r;
      4'b1011: temp_data_0[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_3_r;
      4'b1101: temp_data_0[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_3_r;
      4'b1110: temp_data_0[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_3_r;
      default: temp_data_0[3*DATA_WIDTH-1:2*DATA_WIDTH] = 0;
    endcase
    case ({chan_enable_3,chan_enable_2,chan_enable_1,chan_enable_0})
      4'b1111: temp_data_0[4*DATA_WIDTH-1:3*DATA_WIDTH] = chan_data_3_r;
      default: temp_data_0[4*DATA_WIDTH-1:3*DATA_WIDTH] = 0;
    endcase
  end
  always @(chan_data_4_r, chan_data_5_r, chan_data_6_r, chan_data_7_r, chan_enable_4, chan_enable_5, chan_enable_6, chan_enable_7)
  begin
    casex ({chan_enable_7,chan_enable_6,chan_enable_5,chan_enable_4})
      4'bxxx1: temp_data_1[(DATA_WIDTH-1):0] = chan_data_4_r;
      4'bxx10: temp_data_1[(DATA_WIDTH-1):0] = chan_data_5_r;
      4'bx100: temp_data_1[(DATA_WIDTH-1):0] = chan_data_6_r;
      4'b1000: temp_data_1[(DATA_WIDTH-1):0] = chan_data_7_r;
      default: temp_data_1[(DATA_WIDTH-1):0] = 0;
    endcase
    casex ({chan_enable_7,chan_enable_6,chan_enable_5,chan_enable_4})
      4'bxx11: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_5_r;
      4'bx110: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_6_r;
      4'bx101: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_6_r;
      4'b1001: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_7_r;
      4'b1010: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_7_r;
      4'b1100: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = chan_data_7_r;
      default: temp_data_1[2*DATA_WIDTH-1:DATA_WIDTH] = 0;
    endcase
    casex ({chan_enable_7,chan_enable_6,chan_enable_5,chan_enable_4})
      4'bx111: temp_data_1[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_6_r;
      4'b1011: temp_data_1[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_7_r;
      4'b1101: temp_data_1[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_7_r;
      4'b1110: temp_data_1[3*DATA_WIDTH-1:2*DATA_WIDTH] = chan_data_7_r;
      default: temp_data_1[3*DATA_WIDTH-1:2*DATA_WIDTH] = 0;
    endcase
    case ({chan_enable_7,chan_enable_6,chan_enable_5,chan_enable_4})
      4'b1111: temp_data_1[4*DATA_WIDTH-1:3*DATA_WIDTH] = chan_data_7_r;
      default: temp_data_1[4*DATA_WIDTH-1:3*DATA_WIDTH] = 0;
    endcase
  end
  always @(enable_cnt)
  begin
    case(enable_cnt)
     4'h1: path_enabled = 8'h01;
     4'h2: path_enabled = 8'h02;
     4'h4: path_enabled = 8'h08;
     4'h8: path_enabled = 8'h80;
     default: path_enabled = 8'h0;
    endcase
  end
  always @(temp_data_0, temp_data_1, enable_cnt_0)
  begin
    packed_data = temp_data_0 | temp_data_1 << (enable_cnt_0 * DATA_WIDTH);
  end
  always @(counter_0, path_enabled)
  begin
    case (counter_0)
      0:
      begin
        en1 = path_enabled[0];
        en2 = {2{path_enabled[1]}};
        en4 = {4{path_enabled[3]}};
      end
      1:
      begin
        en1 = path_enabled[0]       << 1;
        en2 = {2{path_enabled[1]}}  << 0;
        en4 = {4{path_enabled[3]}}  << 0;
      end
      2:
      begin
        en1 = path_enabled[0]       << 2;
        en2 = {2{path_enabled[1]}}  << 2;
        en4 = {4{path_enabled[3]}}  << 0;
      end
      3:
      begin
        en1 = path_enabled[0]       << 3;
        en2 = {2{path_enabled[1]}}  << 2;
        en4 = {4{path_enabled[3]}}  << 0;
      end
      4:
      begin
        if (CHANNELS == 8)
        begin
          en1 = path_enabled[0]       << 4;
          en2 = {2{path_enabled[1]}}  << 4;
          en4 = {4{path_enabled[3]}}  << 4;
        end
        else
        begin
          en1 = path_enabled[0];
          en2 = {2{path_enabled[1]}};
          en4 = {4{path_enabled[3]}};
        end
      end
      5:
      begin
        en1 = path_enabled[0]       << 5;
        en2 = {2{path_enabled[1]}}  << 4;
        en4 = {4{path_enabled[3]}}  << 4;
      end
      6:
      begin
        en1 = path_enabled[0]       << 6;
        en2 = {2{path_enabled[1]}}  << 6;
        en4 = {4{path_enabled[3]}}  << 4;
      end
      7:
      begin
        en1 = path_enabled[0]       << 7;
        en2 = {2{path_enabled[1]}}  << 6;
        en4 = {4{path_enabled[3]}}  << 4;
      end
      8:
      begin
        en1 = path_enabled[0]       << 0;
        en2 = {2{path_enabled[1]}}  << 0;
        en4 = {4{path_enabled[3]}}  << 0;
      end
      default:
      begin
        en1 = 8'h0;
        en2 = 8'h0;
        en4 = 8'h0;
      end
    endcase
  end
  always @(posedge clk)
  begin
    path_enabled_d1 <= path_enabled;
    if (path_enabled == 8'h0 || path_enabled_d1 != path_enabled )
    begin
      counter_0 <= 7'h0;
    end
    else
    begin
      if( chan_valid == 1'b1)
      begin
        if (counter_0 > (CHANNELS - 1) )
        begin
          counter_0 <= counter_0 - CHANNELS + enable_cnt;
        end
        else
        begin
          counter_0 <= counter_0 + enable_cnt;
        end
        if ((counter_0 == (CHANNELS - enable_cnt)) || (path_enabled == (8'h1 << (CHANNELS - 1)) ))
        begin
          dvalid  <= 1'b1;
        end
        else
        begin
          dvalid  <= 1'b0;
        end
      end
      else
      begin
        dvalid      <= 1'b0;
      end
    end
  end
  generate
  if ( CHANNELS == 8 )
  begin
    always @(posedge clk)
    begin
      if ((en1[0] | en2[0] | en4[0] | path_enabled[CHANNELS-1]) == 1'b1)
      begin
        ddata[(DATA_WIDTH-1):0]     <=  packed_data[(DATA_WIDTH-1):0];
      end
      if( en1[1] == 1'b1)
      begin
        ddata[2*DATA_WIDTH-1:DATA_WIDTH]    <= packed_data[(DATA_WIDTH-1):0];
      end
      if ( (en2[1] | en4[1] | path_enabled[CHANNELS-1]) == 1'b1)
      begin
        ddata[2*DATA_WIDTH-1:DATA_WIDTH]    <= packed_data[2*DATA_WIDTH-1:DATA_WIDTH];
      end
      if ((en1[2] | en2[2]) == 1'b1)
      begin
        ddata[3*DATA_WIDTH-1:2*DATA_WIDTH]    <= packed_data[(DATA_WIDTH-1):0];
      end
      if ((en4[2] | path_enabled[CHANNELS-1]) == 1'b1)
      begin
        ddata[3*DATA_WIDTH-1:2*DATA_WIDTH]    <= packed_data[3*DATA_WIDTH-1:2*DATA_WIDTH];
      end
      if (en1[3] == 1'b1)
      begin
        ddata[4*DATA_WIDTH-1:3*DATA_WIDTH] <= packed_data[(DATA_WIDTH-1):0];
      end
      if (en2[3] == 1'b1)
      begin
        ddata[4*DATA_WIDTH-1:3*DATA_WIDTH] <= packed_data[2*DATA_WIDTH-1:DATA_WIDTH];
      end
      if ((en4[3] | path_enabled[CHANNELS-1]) == 1'b1)
      begin
        ddata[4*DATA_WIDTH-1:3*DATA_WIDTH] <= packed_data[4*DATA_WIDTH-1:3*DATA_WIDTH];
      end
      if ((en1[4] | en2[4] | en4[4]) == 1'b1)
      begin
        ddata[5*DATA_WIDTH-1:4*DATA_WIDTH] <= packed_data[(DATA_WIDTH-1):0];
      end
      if (path_enabled[CHANNELS-1] == 1'b1)
      begin
        ddata[5*DATA_WIDTH-1:4*DATA_WIDTH] <= packed_data[5*DATA_WIDTH-1:4*DATA_WIDTH];
      end
      if (en1[5] == 1'b1)
      begin
        ddata[6*DATA_WIDTH-1:5*DATA_WIDTH] <= packed_data[(DATA_WIDTH-1):0];
      end
      if ((en2[5] | en4[5]) == 1'b1)
      begin
        ddata[6*DATA_WIDTH-1:5*DATA_WIDTH] <= packed_data[2*DATA_WIDTH-1:DATA_WIDTH];
      end
      if (path_enabled[CHANNELS-1] == 1'b1)
      begin
        ddata[6*DATA_WIDTH-1:5*DATA_WIDTH] <= packed_data[6*DATA_WIDTH-1:5*DATA_WIDTH];
      end
      if ((en1[6] | en2[6]) == 1'b1)
      begin
        ddata[7*DATA_WIDTH-1:6*DATA_WIDTH] <= packed_data[(DATA_WIDTH-1):0];
      end
      if (en4[6] == 1'b1)
      begin
        ddata[7*DATA_WIDTH-1:6*DATA_WIDTH] <= packed_data[3*DATA_WIDTH-1:2*DATA_WIDTH];
      end
      if (path_enabled[CHANNELS-1] == 1'b1)
      begin
        ddata[7*DATA_WIDTH-1:6*DATA_WIDTH] <= packed_data[7*DATA_WIDTH-1:6*DATA_WIDTH];
      end
      if (en1[7] == 1'b1)
      begin
        ddata[8*DATA_WIDTH-1:7*DATA_WIDTH]  <= packed_data[(DATA_WIDTH-1):0];
      end
      if (en2[7] == 1'b1)
      begin
        ddata[8*DATA_WIDTH-1:7*DATA_WIDTH]  <= packed_data[2*DATA_WIDTH-1:DATA_WIDTH];
      end
      if (en4[7] == 1'b1)
      begin
        ddata[8*DATA_WIDTH-1:7*DATA_WIDTH]  <= packed_data[4*DATA_WIDTH-1:3*DATA_WIDTH];
      end
      if (path_enabled[CHANNELS-1] == 1'b1)
      begin
        ddata[8*DATA_WIDTH-1:7*DATA_WIDTH]  <= packed_data[8*DATA_WIDTH-1:7*DATA_WIDTH];
      end
    end
  end
  else
  begin
    always @(posedge clk)
    begin
      if ((en1[0] | en2[0] | path_enabled[3] ) == 1'b1)
      begin
        ddata[(DATA_WIDTH-1):0]     <=  packed_data[(DATA_WIDTH-1):0];
      end
      if( en1[1] == 1'b1)
      begin
        ddata[2*DATA_WIDTH-1:DATA_WIDTH]    <= packed_data[(DATA_WIDTH-1):0];
      end
      if ( (en2[1] | | path_enabled[3] )== 1'b1)
      begin
        ddata[2*DATA_WIDTH-1:DATA_WIDTH]    <= packed_data[2*DATA_WIDTH-1:DATA_WIDTH];
      end
      if ((en1[2] | en2[2]) == 1'b1)
      begin
        ddata[3*DATA_WIDTH-1:2*DATA_WIDTH]    <= packed_data[(DATA_WIDTH-1):0];
      end
      if (( path_enabled[3]) == 1'b1)
      begin
        ddata[3*DATA_WIDTH-1:2*DATA_WIDTH]    <= packed_data[3*DATA_WIDTH-1:2*DATA_WIDTH];
      end
      if (en1[3] == 1'b1)
      begin
        ddata[4*DATA_WIDTH-1:3*DATA_WIDTH] <= packed_data[(DATA_WIDTH-1):0];
      end
      if (en2[3] == 1'b1)
      begin
        ddata[4*DATA_WIDTH-1:3*DATA_WIDTH] <= packed_data[2*DATA_WIDTH-1:DATA_WIDTH];
      end
      if (path_enabled[3] == 1'b1)
      begin
        ddata[4*DATA_WIDTH-1:3*DATA_WIDTH] <= packed_data[4*DATA_WIDTH-1:3*DATA_WIDTH];
      end
    end
  end
  endgenerate
  endmodule
