`default_nettype none
`timescale 1ps/1ps

module trainsim
(
    input wire        rst,
    input wire        clk,
    input wire [4:0]  sensor,
    output reg [2:0]  sw,
    output reg [1:0]  dira,
    output reg [1:0]  dirb
);    
    localparam ABOUT = 0;
    localparam AIN   = 1;
    localparam BIN   = 2;
    localparam ASTOP = 3;
    localparam BSTOP = 4;
    reg [2:0]  state;
    wire [1:0] s12 = {sensor[1], sensor[2]};
    wire [1:0] s13 = {sensor[1], sensor[3]};
    wire [1:0] s24 = {sensor[2], sensor[4]};

    always @(posedge clk) begin
        sw[2] <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= ABOUT;
        else
            case (state)
                ABOUT:
                    case (s12)
                        2'b00:    state <= ABOUT;
                        2'b01:    state <= BIN;
                        2'b10:    state <= AIN;
                        2'b11:    state <= AIN;
                        default: state <= ABOUT;
                    endcase
                AIN:
                    case (s24)
                        2'b00:    state <= AIN;
                        2'b01:    state <= ABOUT;
                        2'b10:    state <= BSTOP;
                        2'b11:    state <= ABOUT;
                        default: state <= ABOUT;
                    endcase
                BIN:        
                    case (s13)
                        2'b00:    state <= BIN;
                        2'b01:    state <= ABOUT;
                        2'b10:    state <= ASTOP;
                        2'b11:    state <= ABOUT;
                        default: state <= ABOUT;
                    endcase
                ASTOP:
                    if (sensor[3])
                        state <= AIN;
                    else
                        state <= ASTOP;
                BSTOP:
                    if (sensor[4])
                        state <= BIN;
                    else
                        state <= BSTOP;
                default:
                    state <= ABOUT;
            endcase
    end

    always @(state) begin
        case (state)
            ABOUT: begin
                sw[0] <= 0;
                sw[1] <= 0;
                dira <= 2'b01;
                dirb <= 2'b01;
            end
            AIN: begin
                sw[0] <= 0;
                sw[1] <= 0;
                dira <= 2'b01;
                dirb <= 2'b01;
            end
            BIN: begin
                sw[0] <= 1;
                sw[1] <= 1;
                dira <= 2'b01;
                dirb <= 2'b01;
            end
            ASTOP: begin
                sw[0] <= 1;
                sw[1] <= 1;
                dira <= 2'b00;
                dirb <= 2'b01;
            end
            BSTOP: begin
                sw[0] <= 0;
                sw[1] <= 0;
                dira <= 2'b01;
                dirb <= 2'b00;
            end
            default: begin
                sw[0] <= 0;
                sw[1] <= 0;
                dira <= 2'b00;
                dirb <= 2'b00;
            end        
        endcase
    end
endmodule

module LFSR8_11D
(
    input wire       clk,
    output reg [7:0] LFSR = 8'hff
);
    wire feedback = LFSR[7] ^ (LFSR[6:0] == 7'b0000000);
    always @(posedge clk) begin
        LFSR[7:1] <= LFSR[6:0];
        LFSR[0] <= feedback;
    end
endmodule