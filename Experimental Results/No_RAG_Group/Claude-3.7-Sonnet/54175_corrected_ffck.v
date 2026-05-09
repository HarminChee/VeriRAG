module S4L2(
    input clock_50mhz,
    input rst_n,
    output reg [6:0] segmentos,
    output reg anodo,
    output reg [3:0] estado
);

reg [25:0] cuenta_para_1hz;

parameter [6:0] cero     =   ~7'h3F;
parameter [6:0] uno      =   ~7'h06;
parameter [6:0] dos      =   ~7'h5B;
parameter [6:0] tres     =   ~7'h4F;
parameter [6:0] cuatro   =   ~7'h66;
parameter [6:0] cinco    =   ~7'h6D;
parameter [6:0] seis     =   ~7'h7D;
parameter [6:0] siete    =   ~7'h07;
parameter [6:0] ocho     =   ~7'h7F;
parameter [6:0] nueve    =   ~7'h6F;
parameter [6:0] ha       =   ~7'h77;
parameter [6:0] hb       =   ~7'h7C;
parameter [6:0] hc       =   ~7'h39;
parameter [6:0] hd       =   ~7'h5E;
parameter [6:0] he       =   ~7'h79;
parameter [6:0] hf       =   ~7'h71;

reg [3:0] counter;

always @(posedge clock_50mhz or negedge rst_n)
begin
    if (!rst_n) begin
        cuenta_para_1hz <= 26'd0;
        counter <= 4'd0;
    end
    else begin
        if (cuenta_para_1hz == 25_000_000) begin
            cuenta_para_1hz <= 26'd0;
            counter <= counter + 1'b1;
        end
        else begin
            cuenta_para_1hz <= cuenta_para_1hz + 1'b1;
        end
    end
end

always @(posedge clock_50mhz or negedge rst_n)
begin
    if (!rst_n) begin
        estado <= 4'd0;
    end
    else begin
        if (cuenta_para_1hz == 25_000_000) begin
            case(estado)
                4'd0:  estado <= 4'd1;
                4'd1:  estado <= 4'd2;
                4'd2:  estado <= 4'd3;
                4'd3:  estado <= 4'd4;
                4'd4:  estado <= 4'd5;
                4'd5:  estado <= 4'd6;
                4'd6:  estado <= 4'd7;
                4'd7:  estado <= 4'd8;
                4'd8:  estado <= 4'd9;
                4'd9:  estado <= 4'd10;
                4'd10: estado <= 4'd11;
                4'd11: estado <= 4'd12;
                4'd12: estado <= 4'd13;
                4'd13: estado <= 4'd14;
                4'd14: estado <= 4'd15;
                4'd15: estado <= 4'd0;
                default: estado <= 4'd0;
            endcase
        end
    end
end

always @(posedge clock_50mhz or negedge rst_n)
begin
    if (!rst_n) begin
        segmentos <= 7'h3F;
        anodo <= 1'b0;
    end
    else begin
        case(estado)
            4'd0:  segmentos <= cero;
            4'd1:  segmentos <= uno;
            4'd2:  segmentos <= dos;
            4'd3:  segmentos <= tres;
            4'd4:  segmentos <= cuatro;
            4'd5:  segmentos <= cinco;
            4'd6:  segmentos <= seis;
            4'd7:  segmentos <= siete;
            4'd8:  segmentos <= ocho;
            4'd9:  segmentos <= nueve;
            4'd10: segmentos <= ha;
            4'd11: segmentos <= hb;
            4'd12: segmentos <= hc;
            4'd13: segmentos <= hd;
            4'd14: segmentos <= he;
            4'd15: segmentos <= hf;
            default: segmentos <= cero;
        endcase
    end
end

endmodule