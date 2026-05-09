`timescale 1ns / 1ps

module seg7x16(
     input clk,
     input reset,
     input cs,
     input [31:0] i_data,
     output [7:0] o_seg,
     output [7:0] o_sel
    );

    // Counter for clock division
    reg [14:0] cnt;
    always @ (posedge clk, posedge reset) begin
      if (reset)
        cnt <= 15'b0;
      else
        cnt <= cnt + 1'b1;
    end

    // Slow clock for 7-segment multiplexing
    wire seg7_clk = cnt[14];

    // Counter for selecting which digit to display (0-7)
    reg [2:0] seg7_addr;
    always @ (posedge seg7_clk, posedge reset) begin
       if(reset)
          seg7_addr <= 3'b000;
        else
          seg7_addr <= seg7_addr + 1'b1;
    end

    // Register to store the input data
    reg [31:0] i_data_store;
    always @ (posedge clk, posedge reset) begin
       if(reset)
          i_data_store <= 32'b0;
       else if(cs) // Latch data only when chip select is active
          i_data_store <= i_data;
       // else: keep previous value (implicit)
    end

    // Combinational logic for digit selection (active low)
    reg [7:0] o_sel_r;
    always @ (*) begin
       case(seg7_addr)
          3'd0 : o_sel_r = 8'b11111110; // Select digit 0
          3'd1 : o_sel_r = 8'b11111101; // Select digit 1
          3'd2 : o_sel_r = 8'b11111011; // Select digit 2
          3'd3 : o_sel_r = 8'b11110111; // Select digit 3
          3'd4 : o_sel_r = 8'b11101111; // Select digit 4
          3'd5 : o_sel_r = 8'b11011111; // Select digit 5
          3'd6 : o_sel_r = 8'b10111111; // Select digit 6
          3'd7 : o_sel_r = 8'b01111111; // Select digit 7
          default: o_sel_r = 8'b11111111; // Default: All digits off
        endcase
    end

    // Combinational logic to select the 4-bit data for the current digit
    reg [3:0] seg_data_r; // Corrected size to 4 bits
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
          default: seg_data_r = 4'b0000; // Default value
        endcase
    end

    // Sequential logic for segment decoding (registered output)
    reg [7:0] o_seg_r;
    always @ (posedge clk, posedge reset) begin // Use main clock for registering output
       if(reset) begin
          o_seg_r <= 8'hFF; // Segments off during reset
       end else begin
          // Decode the 4-bit data selected by seg_data_r
          case(seg_data_r) // Use the combinational seg_data_r
            4'h0 : o_seg_r <= 8'hC0; // 0 (GFEDCBA, active low)
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
            default: o_seg_r <= 8'hFF; // Default: All segments off
          endcase
       end
    end

    // Assign registered values to outputs
    assign o_sel = o_sel_r;
    assign o_seg = o_seg_r;

endmodule