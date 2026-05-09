module hex_ssd (
    input wire [15:0] BIN,
    input wire clk,
    input wire rst,
    output reg [0:6] SSD
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            SSD <= 7'b0000001;
        end else begin
            case(BIN)
                0: SSD <= 7'b0000001;
                1: SSD <= 7'b1001111;
                2: SSD <= 7'b0010010;
                3: SSD <= 7'b0000110;
                4: SSD <= 7'b1001100;
                5: SSD <= 7'b0100100;
                6: SSD <= 7'b0100000;
                7: SSD <= 7'b0001111;
                8: SSD <= 7'b0000000;
                9: SSD <= 7'b0001100;
                10: SSD <= 7'b0001000;
                11: SSD <= 7'b1100000;
                12: SSD <= 7'b0110001;
                13: SSD <= 7'b1000010;
                14: SSD <= 7'b0110000;
                15: SSD <= 7'b0111000;
                default: SSD <= 7'b0000001;
            endcase
        end
    end
endmodule

module lab4_part4 (
    input wire CLOCK_50,
    input wire rst,
    input wire [3:0] KEY,
    output wire [15:0] LEDR,
    output wire [0:6] HEX7,
    output wire [0:6] HEX6,
    output wire [0:6] HEX5,
    output wire [0:6] HEX4,
    output wire [0:6] HEX3,
    output wire [0:6] HEX2,
    output wire [0:6] HEX1,
    output wire [0:6] HEX0
);
    wire [25:0] Q;
    wire [15:0] Q2;
    reg Clr, Clr2;
    wire dft_clk;

    assign dft_clk = rst ? CLOCK_50 : CLOCK_50;

    counter_26bit C0 (
        .en(1'b1),
        .clk(dft_clk),
        .rst(Clr),
        .count(Q)
    );

    counter_16bit DISPLAY (
        .en(1'b1),
        .clk(dft_clk),
        .rst(Clr2),
        .count(Q2)
    );

    always @(posedge dft_clk or posedge rst) begin
        if (rst) begin
            Clr <= 1'b0;
        end else begin
            if (Q >= 50000000) begin
                Clr <= 1'b1;
            end else begin
                Clr <= 1'b0;
            end
        end
    end

    always @(posedge Clr or posedge rst) begin
        if (rst) begin
            Clr2 <= 1'b0;
        end else begin
            if (Q2 >= 9) begin
                Clr2 <= 1'b1;
            end else begin
                Clr2 <= 1'b0;
            end
        end
    end

    t_flipflop T0 (
        .T(1'b1),
        .clk(Clr),
        .rst(rst),
        .Q(LEDR[4])
    );

    b2d_ssd H0 (
        .X(Q2[3:0]),
        .clk(dft_clk),
        .rst(rst),
        .SSD(HEX0)
    );

    assign HEX7 = 7'b1111111;
    assign HEX6 = 7'b1111111;
    assign HEX5 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX2 = 7'b1111111;
    assign HEX1 = 7'b1111111;
endmodule

module b2d_ssd (
    input wire [3:0] X,
    input wire clk,
    input wire rst,
    output reg [0:6] SSD
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            SSD <= 7'b0000001;
        end else begin
            case(X)
                0: SSD <= 7'b0000001;
                1: SSD <= 7'b1001111;
                2: SSD <= 7'b0010010;
                3: SSD <= 7'b0000110;
                4: SSD <= 7'b1001100;
                5: SSD <= 7'b0100100;
                6: SSD <= 7'b0100000;
                7: SSD <= 7'b0001111;
                8: SSD <= 7'b0000000;
                9: SSD <= 7'b0001100;
                default: SSD <= 7'b0000001;
            endcase
        end
    end
endmodule

module counter_26bit (
    input wire en,
    input wire clk,
    input wire rst,
    output reg [25:0] count
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 26'b0;
        end else if (en) begin
            count <= count + 1;
        end
    end
endmodule

module counter_16bit (
    input wire en,
    input wire clk,
    input wire rst,
    output reg [15:0] count
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 16'b0;
        end else if (en) begin
            count <= count + 1;
        end
    end
endmodule

module t_flipflop (
    input wire T,
    input wire clk,
    input wire rst,
    output reg Q
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Q <= 1'b0;
        end else if (T) begin
            Q <= ~Q;
        end
    end
endmodule