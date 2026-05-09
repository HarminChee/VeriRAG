`timescale 1ns / 1ps
module seg7x16(
     input clk,
     input reset,
     input cs,
     input [31:0] i_data,
     output [7:0] o_seg,
     output [7:0] o_sel
    );
    reg [14:0] cnt;
    always @ (posedge clk, posedge reset)
      if (reset)
        cnt <= 0;
      else
        cnt <= cnt + 1'b1;
    wire seg7_clk = cnt[14]; 
    reg [2:0] seg7_addr;
    always @ (posedge seg7_clk, posedge reset)
      if(reset)
        seg7_addr <= 0;
      else
        seg7_addr <= seg7_addr + 1'b1;
    reg [7:0] o_sel_r;
    always @ (*)
      case(seg7_addr)
        3'b111 : o_sel_r = 8'b01111111;
        3'b110 : o_sel_r = 8'b10111111;
        3'b101 : o_sel_r = 8'b11011111;
        3'b100 : o_sel_r = 8'b11101111;
        3'b011 : o_sel_r = 8'b11110111;
        3'b010 : o_sel_r = 8'b11111011;
        3'b001 : o_sel_r = 8'b11111101;
        3'b000 : o_sel_r = 8'b11111110;
        default : o_sel_r = 8'b11111111;
      endcase
    reg [31:0] i_data_store;
    always @ (posedge clk, posedge reset)
      if(reset)
        i_data_store <= 0;
      else if(cs)
        i_data_store <= i_data;
    reg [3:0] seg_data_r;
    always @ (*)
      case(seg7_addr)
        3'b000 : seg_data_r = i_data_store[3:0];
        3'b001 : seg_data_r = i_data_store[7:4];
        3'b010 : seg_data_r = i_data_store[11:8];
        3'b011 : seg_data_r = i_data_store[15:12];
        3'b100 : seg_data_r = i_data_store[19:16];
        3'b101 : seg_data_r = i_data_store[23:20];
        3'b110 : seg_data_r = i_data_store[27:24];
        3'b111 : seg_data_r = i_data_store[31:28];
        default : seg_data_r = 4'h0;
      endcase
    reg [7:0] o_seg_r;
    always @ (posedge clk, posedge reset)
      if(reset)
        o_seg_r <= 8'hff;
      else
        case(seg_data_r)
          4'h0 : o_seg_r <= 8'hC0;
          4'h1 : o_seg_r <= 8'hF9;
          4'h2 : o_seg_r <= 8'hA4;
          4'h3 : o_seg_r <= 8'hB0;
          4'h4 : o_seg_r <= 8'h99;
          4'h5 : o_seg_r <= 8'h92;
          4'h6 : o_seg_r <= 8'h82;
          4'h7 : o_seg_r <= 8'hF8;
          4'h8 : o_seg_r <= 8'h80;
          4'h9 : o_seg_r <= 8'h90;
          4'hA : o_seg_r <= 8'h88;
          4'hB : o_seg_r <= 8'h83;
          4'hC : o_seg_r <= 8'hC6;
          4'hD : o_seg_r <= 8'hA1;
          4'hE : o_seg_r <= 8'h86;
          4'hF : o_seg_r <= 8'h8E;
          default : o_seg_r <= 8'hFF;
        endcase
    assign o_sel = o_sel_r;
    assign o_seg = o_seg_r;
endmodule