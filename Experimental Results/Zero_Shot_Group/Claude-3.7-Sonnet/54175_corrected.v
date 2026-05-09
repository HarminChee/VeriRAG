module S4L2(clock_50mhz, clock_1hz, segmentos, anodo, estado);
input clock_50mhz;
output reg clock_1hz;
output reg [6:0] segmentos = 7'h3F;
output reg anodo = 0;
output reg [3:0] estado = 0;
reg [25:0] cuenta_para_1hz = 0;

parameter [6:0] cero   = 7'h3F;
parameter [6:0] uno    = 7'h06;
parameter [6:0] dos    = 7'h5B;
parameter [6:0] tres   = 7'h4F;
parameter [6:0] cuatro = 7'h66;
parameter [6:0] cinco  = 7'h6D;
parameter [6:0] seis   = 7'h7D;
parameter [6:0] siete  = 7'h07;
parameter [6:0] ocho   = 7'h7F;
parameter [6:0] nueve  = 7'h6F;
parameter [6:0] ha     = 7'h77;
parameter [6:0] hb     = 7'h7C;
parameter [6:0] hc     = 7'h39;
parameter [6:0] hd     = 7'h5E;
parameter [6:0] he     = 7'h79;
parameter [6:0] hf     = 7'h71;

always @(posedge clock_50mhz)
begin
    if(cuenta_para_1hz == 25_000_000)
    begin
        clock_1hz <= ~clock_1hz;
        cuenta_para_1hz <= 0;
    end
    else
        cuenta_para_1hz <= cuenta_para_1hz + 1;
end

always @(posedge clock_1hz)
begin
    case(estado)
        4'h0: estado <= 4'h1;
        4'h1: estado <= 4'h2;
        4'h2: estado <= 4'h3;
        4'h3: estado <= 4'h4;
        4'h4: estado <= 4'h5;
        4'h5: estado <= 4'h6;
        4'h6: estado <= 4'h7;
        4'h7: estado <= 4'h8;
        4'h8: estado <= 4'h9;
        4'h9: estado <= 4'hA;
        4'hA: estado <= 4'hB;
        4'hB: estado <= 4'hC;
        4'hC: estado <= 4'hD;
        4'hD: estado <= 4'hE;
        4'hE: estado <= 4'hF;
        4'hF: estado <= 4'h0;
        default: estado <= 4'h0;
    endcase
end

always @(*)
begin
    case(estado)
        4'h0: segmentos = ~cero;
        4'h1: segmentos = ~uno;
        4'h2: segmentos = ~dos;
        4'h3: segmentos = ~tres;
        4'h4: segmentos = ~cuatro;
        4'h5: segmentos = ~cinco;
        4'h6: segmentos = ~seis;
        4'h7: segmentos = ~siete;
        4'h8: segmentos = ~ocho;
        4'h9: segmentos = ~nueve;
        4'hA: segmentos = ~ha;
        4'hB: segmentos = ~hb;
        4'hC: segmentos = ~hc;
        4'hD: segmentos = ~hd;
        4'hE: segmentos = ~he;
        4'hF: segmentos = ~hf;
        default: segmentos = ~cero;
    endcase
end

endmodule