module S4A2(
    input clock_50mhz,
    output reg [6:0] segmentos,
    output reg [3:0] anodos,
    output reg [3:0] estado
);

reg [25:0] cuenta_para_2khz;
reg [3:0] rotabit;
reg [3:0] contador;

parameter [6:0] cero = ~7'h3F;
parameter [6:0] uno = ~7'h06;
parameter [6:0] dos = ~7'h5B;
parameter [6:0] tres = ~7'h4F;

reg [1:0] div_count;
wire clock_2khz;
wire clock_1hz;

// Clock divider for 2kHz
always @(posedge clock_50mhz) begin
    cuenta_para_2khz <= cuenta_para_2khz + 1;
    if(cuenta_para_2khz == 2_550_000) begin
        cuenta_para_2khz <= 0;
    end
end

assign clock_2khz = (cuenta_para_2khz == 2_550_000);
assign clock_1hz = (cuenta_para_2khz == 25_000_000);

always @(posedge clock_50mhz) begin
    if(clock_2khz) begin
        case(rotabit)
            0: rotabit <= 1;
            1: rotabit <= 2;
            2: rotabit <= 3;
            3: rotabit <= 0;
        endcase
    end
end

always @(posedge clock_50mhz) begin
    if(clock_1hz) begin
        case(estado)
            0: estado <= 1;
            1: estado <= 2;
            2: estado <= 3;
            3: estado <= 0;
        endcase
    end
end

always @(*) begin
    case(rotabit)
        0: anodos = 4'b1110;
        1: anodos = 4'b1101;
        2: anodos = 4'b1011;
        3: anodos = 4'b0111;
        default: anodos = 4'b1111;
    endcase
end

always @(*) begin
    case(rotabit)
        0: segmentos = cero;
        1: segmentos = uno;
        2: segmentos = dos;
        3: segmentos = tres;
        default: segmentos = cero;
    endcase
end

endmodule