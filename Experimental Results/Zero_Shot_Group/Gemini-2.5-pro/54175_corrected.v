module S4L2(
    input clock_50mhz,
    output reg clock_1hz = 0, // Initialize clock_1hz
    output reg [6:0] segmentos = ~7'h3F, // Initialize to 'cero' for consistency
    output reg anodo = 0, // Unused in current logic but kept as per original
    output reg [3:0] estado = 0
);

    // Internal counter for 1Hz generation
    reg [25:0] cuenta_para_1hz = 0;

    // Parameters for 7-segment display (common anode assumed due to '~')
    parameter [6:0] cero   = ~7'h3F;
    parameter [6:0] uno    = ~7'h06;
    parameter [6:0] dos    = ~7'h5B;
    parameter [6:0] tres   = ~7'h4F;
    parameter [6:0] cuatro = ~7'h66;
    parameter [6:0] cinco  = ~7'h6D;
    parameter [6:0] seis   = ~7'h7D;
    parameter [6:0] siete  = ~7'h07;
    parameter [6:0] ocho   = ~7'h7F;
    parameter [6:0] nueve  = ~7'h6F;
    parameter [6:0] ha     = ~7'h77; // A
    parameter [6:0] hb     = ~7'h7C; // b
    parameter [6:0] hc     = ~7'h39; // C
    parameter [6:0] hd     = ~7'h5E; // d
    parameter [6:0] he     = ~7'h79; // E
    parameter [6:0] hf     = ~7'h71; // F

    // Clock divider: generates a 1Hz *toggle* (0.5Hz frequency) signal
    // Corrected: Use non-blocking assignments (<=) in sequential block
    always @(posedge clock_50mhz)
    begin
        if (cuenta_para_1hz == 25_000_000 - 1) // Count 0 to 24,999,999 (25M cycles)
        begin
            cuenta_para_1hz <= 0;
            clock_1hz <= ~clock_1hz; // Toggle the 1Hz clock signal
        end
        else
        begin
            cuenta_para_1hz <= cuenta_para_1hz + 1;
        end
    end

    // State machine: cycles through states 0 to 15 on the rising edge of clock_1hz
    // Corrected: No major errors here, non-blocking assignments already used correctly
    always @(posedge clock_1hz)
    begin
        case (estado)
            0:  estado <= 1;
            1:  estado <= 2;
            2:  estado <= 3;
            3:  estado <= 4;
            4:  estado <= 5;
            5:  estado <= 6;
            6:  estado <= 7;
            7:  estado <= 8;
            8:  estado <= 9;
            9:  estado <= 10; // State A
            10: estado <= 11; // State b
            11: estado <= 12; // State C
            12: estado <= 13; // State d
            13: estado <= 14; // State E
            14: estado <= 15; // State F
            15: estado <= 0;  // State 0
            default: estado <= 0; // Default case for safety
        endcase
    end

    // Output logic: maps the current state to the 7-segment display pattern
    // Corrected: No major errors here, blocking assignments are suitable for combinational logic
    //            Added default case for robustness, although all states were covered.
    always @(*) // Use @(*) for combinational logic sensitivity list
    begin
        case (estado)
            0:  segmentos = cero;
            1:  segmentos = uno;
            2:  segmentos = dos;
            3:  segmentos = tres;
            4:  segmentos = cuatro;
            5:  segmentos = cinco;
            6:  segmentos = seis;
            7:  segmentos = siete;
            8:  segmentos = ocho;
            9:  segmentos = nueve;
            10: segmentos = ha;
            11: segmentos = hb;
            12: segmentos = hc;
            13: segmentos = hd;
            14: segmentos = he;
            15: segmentos = hf;
            default: segmentos = ~7'h00; // All segments off or an error pattern
        endcase
    end

endmodule