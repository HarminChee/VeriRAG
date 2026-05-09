module S4A2(
    input clock_50mhz,
    input scan_en, // Added scan_en input for DFT
    output reg clock_1hz,
    output reg [6:0] segmentos = 7'h3F,
    output reg [3:0] anodos = 4'h0,
    output reg [3:0] estado = 0
);

    // Parameters for 7-segment display (active low)
    parameter [6:0] cero = ~7'h3F;
    parameter [6:0] uno  = ~7'h06;
    parameter [6:0] dos  = ~7'h5B;
    parameter [6:0] tres = ~7'h4F;

    // Internal registers
    reg [25:0] cuenta_para_1hz = 0;
    reg [25:0] cuenta_para_2khz = 0;
    // reg clock_2khz = 0; // Removed internal clock signal
    reg [3:0] rotabit = 0;
    // reg [3:0] contador = 0; // Unused register removed

    // Wires for enables, derived from counters
    wire enable_1hz;
    wire enable_2khz;

    // Generate 1Hz enable signal and clock_1hz output
    // Counter resets after reaching target count - 1
    assign enable_1hz = (cuenta_para_1hz == 25_000_000 - 1);

    always @(posedge clock_50mhz)
    begin
        if (cuenta_para_1hz == 25_000_000 - 1) begin
            cuenta_para_1hz <= 0;
            clock_1hz <= ~clock_1hz; // Toggle output clock
        end else begin
            cuenta_para_1hz <= cuenta_para_1hz + 1;
        end
    end

    // Generate ~2kHz enable signal (approx. 1.96kHz)
    // Counter resets after reaching target count - 1
    assign enable_2khz = (cuenta_para_2khz == 25_000 - 1); // Adjusted count for ~2kHz (50MHz / 25000 = 2kHz)

    always @(posedge clock_50mhz)
    begin
        if (cuenta_para_2khz == 25_000 - 1) begin
            cuenta_para_2khz <= 0;
            // Removed clock_2khz generation
        end else begin
            cuenta_para_2khz <= cuenta_para_2khz + 1;
        end
    end

    // Update rotabit using the primary clock and the 2kHz enable
    // This FF is now clocked by clock_50mhz, fixing CLKNPI
    always @(posedge clock_50mhz)
    begin
        if (enable_2khz) begin // Update only when enabled
            case(rotabit)
                0: rotabit <= 1;
                1: rotabit <= 2;
                2: rotabit <= 3;
                3: rotabit <= 0;
                default: rotabit <= 0; // Added default case
            endcase
        end
    end

    // Combinational logic to drive anodes based on rotabit
    // Changed sensitivity list to @(*) for better practice
    always @(*)
    begin
        case(rotabit)
            0: anodos = 4'b1110; // Select digit 0
            1: anodos = 4'b1101; // Select digit 1
            2: anodos = 4'b1011; // Select digit 2
            3: anodos = 4'b0111; // Select digit 3
            default: anodos = 4'b1111; // Default: all off
        endcase
    end

    // Update estado using the primary clock and the 1Hz enable
    // This FF is now clocked by clock_50mhz, fixing CLKNPI
    always @(posedge clock_50mhz)
    begin
        if (enable_1hz) begin // Update only when enabled
            case(estado)
                0: estado <= 1;
                1: estado <= 2;
                2: estado <= 3;
                3: estado <= 0;
                default: estado <= 0; // Added default case
            endcase
        end
    end

    // Combinational logic to drive segments based on rotabit (displaying 0, 1, 2, 3 cyclically)
    // Changed sensitivity list to @(*) for better practice
    // This logic seems intended to display the digit corresponding to rotabit
    always @(*)
    begin
        case(rotabit) // Should probably depend on the value to display, not rotabit itself?
                      // Assuming it displays the index 'rotabit'
            0: segmentos = cero;
            1: segmentos = uno;
            2: segmentos = dos;
            3: segmentos = tres;
            default: segmentos = ~7'h00; // Default: blank
        endcase
    end

endmodule