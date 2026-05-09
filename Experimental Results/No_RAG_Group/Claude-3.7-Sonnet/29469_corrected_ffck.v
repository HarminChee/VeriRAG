Here is the corrected Verilog code:


module SevenSegment(
    output reg [6:0] display,
    output reg [3:0] digit,
    input wire [15:0] nums,
    input wire rst,
    input wire clk,
    input wire scan_clk
);
    reg [3:0] display_num;
    reg [1:0] digit_select;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            digit_select <= 2'b00;
        end else begin
            digit_select <= digit_select + 2'b01;
        end
    end

    always @(posedge scan_clk or posedge rst) begin
        if (rst) begin
            display_num <= 4'b0000;
            digit <= 4'b1111;
        end else begin
            case (digit_select)
                2'b00: begin
                    display_num <= nums[3:0];
                    digit <= 4'b1110;
                end
                2'b01: begin
                    display_num <= nums[7:4];
                    digit <= 4'b1101;
                end
                2'b10: begin
                    display_num <= nums[11:8];
                    digit <= 4'b1011;
                end
                2'b11: begin
                    display_num <= nums[15:12];
                    digit <= 4'b0111;
                end
            endcase
        end
    end

    always @(*) begin
        case (display_num)
            4'h0: display = 7'b1000000;
            4'h1: display = 7'b1111001;
            4'h2: display = 7'b0100100;
            4'h3: display = 7'b0110000;
            4'h4: display = 7'b0011001;
            4'h5: display = 7'b0010010;
            4'h6: display = 7'b0000010;
            4'h7: display = 7'b1111000;
            4'h8: display = 7'b0000000;
            4'h9: display = 7'b0010000;
            default: display = 7'b1111111;
        endcase
    end
endmodule