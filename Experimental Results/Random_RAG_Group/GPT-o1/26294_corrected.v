module digits(
    input wire mclk,
    input wire [3:0] enable,
    input wire [15:0] values,
    output reg [6:0] seg = 7'b1111111,
    output reg [3:0] digit = 4'b1111
);
reg [14:0] counter = 0;
reg [1:0] index = 2'b00;
wire [3:0] number;

assign number =
    (index == 2'b00) ? values[3:0] :
    (index == 2'b01) ? values[7:4] :
    (index == 2'b10) ? values[11:8] :
    values[15:12];

always @(posedge mclk) begin
    if(counter == 24999) begin
        counter <= 0;
        index <= index + 1;
    end else begin
        counter <= counter + 1;
    end
end

always @(posedge mclk) begin
    case(index)
        2'b00: digit <= {3'b111, ~enable[0]};
        2'b01: digit <= {2'b11, ~enable[1], 1'b1};
        2'b10: digit <= {1'b1, ~enable[2], 2'b11};
        2'b11: digit <= {~enable[3], 3'b111};
        default: digit <= 4'b1111;
    endcase

    case(number)
        4'h0 : seg <= ~(7'b0111111);
        4'h1 : seg <= ~(7'b0000110);
        4'h2 : seg <= ~(7'b1011011);
        4'h3 : seg <= ~(7'b1001111);
        4'h4 : seg <= ~(7'b1100110);
        4'h5 : seg <= ~(7'b1101101);
        4'h6 : seg <= ~(7'b1111101);
        4'h7 : seg <= ~(7'b0000111);
        4'h8 : seg <= ~(7'b1111111);
        4'h9 : seg <= ~(7'b1101111);
        4'hA : seg <= ~(7'b1110111);
        4'hB : seg <= ~(7'b1111100);
        4'hC : seg <= ~(7'b0111001);
        4'hD : seg <= ~(7'b1011110);
        4'hE : seg <= ~(7'b1111001);
        4'hF : seg <= ~(7'b1110001);
        default : seg <= ~(7'b0000000);
    endcase
end

endmodule