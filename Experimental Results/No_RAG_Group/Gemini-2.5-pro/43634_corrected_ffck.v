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
        cnt <= 15'd0;
      else
        cnt <= cnt + 1'b1;

    // Generate enable signal for seg7_addr update
    // This replaces the internally generated clock posedge seg7_clk
    // seg7_addr should update when cnt reaches the value that causes cnt[14] to rise (e.g., 15'h3FFF -> 15'h4000)
    wire seg7_addr_en = (cnt == 15'h3FFF);

	 reg [2:0] seg7_addr;
	 // Clock seg7_addr with the primary clock 'clk' and use the enable signal
	 always @ (posedge clk, posedge reset)
	   if(reset)
		  seg7_addr <= 3'd0;
		else if (seg7_addr_en) // Update only when enabled
		  seg7_addr <= seg7_addr + 1'b1;

	 reg [7:0] o_sel_r;
	 // Combinational logic remains the same, driven by the updated seg7_addr
	 always @ (*) begin
	   case(seg7_addr)
		  3'd7 : o_sel_r = 8'b01111111;
		  3'd6 : o_sel_r = 8'b10111111;
		  3'd5 : o_sel_r = 8'b11011111;
		  3'd4 : o_sel_r = 8'b11101111;
		  3'd3 : o_sel_r = 8'b11110111;
		  3'd2 : o_sel_r = 8'b11111011;
		  3'd1 : o_sel_r = 8'b11111101;
		  3'd0 : o_sel_r = 8'b11111110;
		  default : o_sel_r = 8'b11111110; // Default assignment
		endcase
     end

	 reg [31:0] i_data_store;
	 // This FF is clocked by the primary clock 'clk', which is fine
	 always @ (posedge clk, posedge reset)
	   if(reset)
		  i_data_store <= 32'd0;
		else if(cs)
		  i_data_store <= i_data;

	 reg [7:0] seg_data_r;
	 // Combinational logic remains the same, driven by the updated seg7_addr
	 always @ (*) begin
	   case(seg7_addr)
		  3'd0 : seg_data_r = i_data_store[3:0];
		  3'd1 : seg_data_r = i_data_store[7:4];
		  3'd2 : seg_data_r = i_data_store[11:8];
		  3'd3 : seg_data_r = i_data_store[15:12];
		  3'd4 : seg_data_r = i_data_store[19:16];
		  3'd5 : seg_data_r = i_data_store[23:20];
		  3'd6 : seg_data_r = i_data_store[27:24];
		  3'd7 : seg_data_r = i_data_store[31:28];
		  default : seg_data_r = 4'b0; // Default assignment
		endcase
     end

	 reg [7:0] o_seg_r;
	 // This FF is clocked by the primary clock 'clk', which is fine
	 always @ (posedge clk, posedge reset)
	   if(reset)
		  o_seg_r <= 8'hFF; // Reset to blank display
		else begin
		  // Decode seg_data_r to 7-segment display pattern
		  case(seg_data_r[3:0]) // Assuming seg_data_r holds 4-bit data per segment
		    4'h0 : o_seg_r <= 8'hC0; // 0
          4'h1 : o_seg_r <= 8'hF9; // 1
          4'h2 : o_seg_r <= 8'hA4; // 2
          4'h3 : o_seg_r <= 8'hB0; // 3
          4'h4 : o_seg_r <= 8'h99; // 4
          4'h5 : o_seg_r <= 8'h92; // 5
          4'h6 : o_seg_r <= 8'h82; // 6
          4'h7 : o_seg_r <= 8'hF8; // 7
          4'h8 : o_seg_r <= 8'h80; // 8
          4'h9 : o_seg_r <= 8'h90; // 9
          4'hA : o_seg_r <= 8'h88; // A
          4'hB : o_seg_r <= 8'h83; // b
          4'hC : o_seg_r <= 8'hC6; // C
          4'hD : o_seg_r <= 8'hA1; // d
          4'hE : o_seg_r <= 8'h86; // E
          4'hF : o_seg_r <= 8'h8E; // F
          default: o_seg_r <= 8'hFF; // Default to blank
		  endcase
        end

	 // Output assignments remain the same
	 assign o_sel = o_sel_r;
	 assign o_seg = o_seg_r;

endmodule