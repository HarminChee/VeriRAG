module ps2lab1(
  input  CLOCK_50,
  input  [3:0]  KEY,
  input  [17:0]  SW,
  output reg [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
  output reg [8:0]  LEDG,  
  output reg [17:0]  LEDR,  
  input	PS2_DAT,
  input	PS2_CLK,
  inout  [35:0]  GPIO_0, GPIO_1
);

assign  GPIO_0    =  36'hzzzzzzzzz;
assign  GPIO_1    =  36'hzzzzzzzzz;

wire RST;
assign RST = KEY[0];
assign LEDR[17:0] = SW[17:0];
assign LEDG = 9'b0;

wire reset = 1'b0;
wire [7:0] scan_code;
reg [7:0] history [0:3];
wire read, scan_ready;

oneshot pulser(
   .pulse_out(read),
   .trigger_in(scan_ready),
   .clk(CLOCK_50)
);

keyboard kbd(
  .keyboard_clk(PS2_CLK),
  .keyboard_data(PS2_DAT),
  .clock50(CLOCK_50),
  .reset(reset),
  .read(read),
  .scan_ready(scan_ready),
  .scan_code(scan_code)
);

hex_7seg dsp0(
  .hex(history[0][3:0]),
  .seg(HEX0)
);

hex_7seg dsp1(
  .hex(history[0][7:4]),
  .seg(HEX1)
);

hex_7seg dsp2(
  .hex(history[1][3:0]),
  .seg(HEX2)
);

hex_7seg dsp3(
  .hex(history[1][7:4]),
  .seg(HEX3)
);

hex_7seg dsp4(
  .hex(history[2][3:0]),
  .seg(HEX4)
);

hex_7seg dsp5(
  .hex(history[2][7:4]),
  .seg(HEX5)
);

hex_7seg dsp6(
  .hex(history[3][3:0]),
  .seg(HEX6)
);

hex_7seg dsp7(
  .hex(history[3][7:4]),
  .seg(HEX7)
);

always @(posedge scan_ready)
begin
	history[3] <= history[2];
	history[2] <= history[1];
	history[1] <= history[0];
	history[0] <= scan_code;
end

endmodule

module oneshot (
    output reg pulse_out,
    input trigger_in,
    input clk
);
    reg [1:0] state;
    always @(posedge clk)
    begin
        case (state)
            2'b00: 
                if (trigger_in) begin
                    state <= 2'b01;
                    pulse_out <= 1'b1;
                end
            2'b01: begin
                state <= 2'b10;
                pulse_out <= 1'b0;
            end
            2'b10: 
                if (!trigger_in)
                    state <= 2'b00;
            default: state <= 2'b00;
        endcase
    end
endmodule

module keyboard (
    input keyboard_clk,
    input keyboard_data,
    input clock50,
    input reset,
    input read,
    output reg scan_ready,
    output reg [7:0] scan_code
);
    reg [3:0] count;
    reg [10:0] shift_reg;
    always @(negedge keyboard_clk or posedge reset)
    begin
        if (reset)
        begin
            count <= 0;
            shift_reg <= 0;
            scan_ready <= 0;
        end
        else
        begin
            if (count < 11)
            begin
                shift_reg[0] <= keyboard_data;
                shift_reg[10:1] <= shift_reg[9:0];
                count <= count + 1;
            end
            if (count == 11)
            begin
                scan_ready <= 1;
                scan_code <= shift_reg[8:1];
                count <= 0;
            end
        end
    end
    always @(posedge clock50)
        if (read) scan_ready <= 0;
endmodule

module hex_7seg (
    input [3:0] hex,
    output reg [6:0] seg
);
    always @(*)
    begin
        case (hex)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end
endmodule