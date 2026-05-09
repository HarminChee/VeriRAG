module S4A2_corrected_ffc (
    input clock_50mhz,
    output reg clock_1hz, // Output register, clocked by primary clock + enable
    output reg [6:0] segmentos = ~7'h3F, // Initialize to zero (active low)
    output reg [3:0] anodos = 4'b1111, // Initialize to all off
    output reg [3:0] estado = 0
);

    // Parameters for segment display (active low)
    parameter [6:0] cero = ~7'h3F;
    parameter [6:0] uno  = ~7'h06;
    parameter [6:0] dos  = ~7'h5B;
    parameter [6:0] tres = ~7'h4F;
    parameter [6:0] seg_off = ~7'h00; // All segments off

    // Internal Registers clocked by the primary clock
    reg [25:0] cuenta_para_1hz = 0;
    reg [25:0] cuenta_para_2khz = 0;
    reg [3:0] rotabit = 0;

    // Wires for Enable Signals (Generated Combinationally)
    wire enable_1hz;
    wire enable_2khz;

    // Combinational generation of enable signals based on counter comparison
    // Enable pulses high for one clock_50mhz cycle when the counter reaches its target - 1
    assign enable_1hz = (cuenta_para_1hz == 25_000_000 - 1);
    assign enable_2khz = (cuenta_para_2khz == 2_550_000 - 1);

    // 1Hz Counter and clock_1hz output generation (Clocked by primary clock)
    always @(posedge clock_50mhz) begin
        if (enable_1hz) begin
            cuenta_para_1hz <= 0; // Reset counter when enable is high
            clock_1hz <= ~clock_1hz; // Toggle output register on enable edge
        end else begin
            cuenta_para_1hz <= cuenta_para_1hz + 1; // Increment counter
        end
    end

    // 2kHz Counter (Clocked by primary clock)
    // This counter just generates the enable signal
    always @(posedge clock_50mhz) begin
        if (enable_2khz) begin
            cuenta_para_2khz <= 0; // Reset counter when enable is high
        end else begin
            cuenta_para_2khz <= cuenta_para_2khz + 1; // Increment counter
        end
    end

    // Rotabit Logic (Sequential - Clocked by primary clock, enabled by enable_2khz)
    // This FF updates only when enable_2khz is high
    always @(posedge clock_50mhz) begin
        if (enable_2khz) begin // Update only on the 2kHz enable edge
            case (rotabit)
                0: rotabit <= 1;
                1: rotabit <= 2;
                2: rotabit <= 3;
                3: rotabit <= 0;
                default: rotabit <= 0; // Assign a default for robustness
            endcase
        end
        // If enable_2khz is low, rotabit holds its value implicitly
    end

    // Estado Logic (Sequential - Clocked by primary clock, enabled by enable_1hz)
    // This FF updates only when enable_1hz is high
    always @(posedge clock_50mhz) begin
        if (enable_1hz) begin // Update only on the 1Hz enable edge
            case (estado)
                0: estado <= 1;
                1: estado <= 2;
                2: estado <= 3;
                3: estado <= 0;
                default: estado <= 0; // Assign a default for robustness
            endcase
        end
        // If enable_1hz is low, estado holds its value implicitly
    end

    // Combinational Logic for Anodes (Driven by rotabit state)
    // Use sensitivity list @(*) for combinational logic
    always @(*) begin
        case (rotabit)
            0: anodos = 4'b1110; // Anode 0 active
            1: anodos = 4'b1101; // Anode 1 active
            2: anodos = 4'b1011; // Anode 2 active
            3: anodos = 4'b0111; // Anode 3 active
            default: anodos = 4'b1111; // Default: All anodes off
        endcase
    end

    // Combinational Logic for Segmentos (Driven by rotabit state)
    // Use sensitivity list @(*) for combinational logic
    always @(*) begin
        case (rotabit) // Segments show 0, 1, 2, 3 based on active anode (rotabit)
            0: segmentos = cero;
            1: segmentos = uno;
            2: segmentos = dos;
            3: segmentos = tres;
            default: segmentos = seg_off; // Default: All segments off
        endcase
    end

endmodule