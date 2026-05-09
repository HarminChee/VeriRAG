module digits(
    input wire mclk,
    input wire[3:0] enable,
    input wire[15:0] values,
    output reg[6:0] seg,
    output reg[3:0] digit
);

reg[14:0] counter = 0;
reg clk1khz_src = 0;
reg[1:0] index = 0;
wire clk1khz;
wire[4:0] number;

BUFG clk1khz_bufg (
    .I(clk1khz_src),
    .O(clk1khz)
);

assign number = 
    (index == 0) ? values[3:0] :
    (index == 1) ? values[7:4] :
    (index == 2) ? values[11:8] :
    values[15:12];

always @(posedge mclk)
begin
    if (counter == 24999)
    begin
        counter <= 0;
        clk1khz_src <= ~clk1khz_src;
    end
    else
    begin
        counter <= counter + 1;
    end
end

always @(posedge clk1khz)
begin
    index <= (index == 3) ? 0 : index + 1;

    case (index)
        0: digit <= {3'b111, ~enable[0]};
        1: digit <= {3'b111, ~enable[1]};
        2: digit <= {3'b111, ~enable[2]};
        3: digit <= {3'b111, ~enable[3]};
        default: digit <= 4'b1111;
    endcase

    case (number)
        4'h0: seg <= ~7'b0111111;
        4'h1: seg <= ~7'b0000110;
        4'h2: seg <= ~7'b1011011;
        4'h3: seg <= ~7'b1001111;
        4'h4: seg <= ~7'b1100110;
        4'h5: seg <= ~7'b1101101;
        4'h6: seg <= ~7'b1111101;
        4'h7: seg <= ~7'b0000111;
        4'h8: seg <= ~7'b1111111;
        4'h9: seg <= ~7'b1101111;
        4'hA: seg <= ~7'b1110111;
        4'hB: seg <= ~7'b1111100;
        4'hC: seg <= ~7'b0111001;
        4'hD: seg <= ~7'b1011110;
        4'hE: seg <= ~7'b1111001;
        4'hF: seg <= ~7'b1110001;
        default: seg <= ~7'b0000000;
    endcase
end

endmodule