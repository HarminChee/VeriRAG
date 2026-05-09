module S4A2 (
    input wire clock_50mhz,
    output reg clock_1hz = 1'b0,
    output reg [6:0] segmentos = ~7'h3F, // Initialize for common anode '0'
    output reg [3:0] anodos = 4'b1111,   // Initialize anodes off
    output reg [3:0] estado = 4'd0
);

    // Parameters for 7-segment display (Common Anode)
    parameter [6:0] cero = ~7'h3F;
    parameter [6:0] uno  = ~7'h06;
    parameter [6:0] dos  = ~7'h5B;
    parameter [6:0] tres = ~7'h4F;
    parameter [6:0] blank = ~7'h00; // Segments off for common anode

    // Internal counters and clocks
    reg [24:0] cuenta_para_1hz = 25'd0; // Correct width for 25_000_000
    reg [13:0] cuenta_para_2khz = 14'd0; // Correct width for 12_500
    reg clock_2khz = 1'b0;

    // Internal state for display multiplexing
    reg [1:0] rotabit = 2'd0; // Use 2 bits for 4 states (0-3)

    localparam COUNT_1HZ_LIMIT = 25_000_000 - 1; // For 50MHz -> 1Hz toggle (0.5s period)
    localparam COUNT_2KHZ_LIMIT = 12_500 - 1;    // For 50MHz -> 2kHz toggle (250us period)

    // 1Hz Clock Generation
    always @(posedge clock_50mhz) begin
        if (cuenta_para_1hz == COUNT_1HZ_LIMIT) begin
            cuenta_para_1hz <= 25'd0;
            clock_1hz <= ~clock_1hz;
        end else begin
            cuenta_para_1hz <= cuenta_para_1hz + 1;
        end
    end

    // 2kHz Clock Generation (approx) for display multiplexing
    always @(posedge clock_50mhz) begin
        if (cuenta_para_2khz == COUNT_2KHZ_LIMIT) begin
            cuenta_para_2khz <= 14'd0;
            clock_2khz <= ~clock_2khz;
        end else begin
            cuenta_para_2khz <= cuenta_para_2khz + 1;
        end
    end

    // State Machine (cycles 0 -> 1 -> 2 -> 3 -> 0 every 1Hz edge)
    always @(posedge clock_1hz) begin
        case (estado)
            4'd0: estado <= 4'd1;
            4'd1: estado <= 4'd2;
            4'd2: estado <= 4'd3;
            4'd3: estado <= 4'd0;
            default: estado <= 4'd0; // Reset to known state
        endcase
    end

    // Display Digit Selection Counter (cycles 0 -> 1 -> 2 -> 3 -> 0 every 2kHz edge)
    always @(posedge clock_2khz) begin
        case (rotabit)
            2'd0: rotabit <= 2'd1;
            2'd1: rotabit <= 2'd2;
            2'd2: rotabit <= 2'd3;
            2'd3: rotabit <= 2'd0;
            default: rotabit <= 2'd0; // Should not happen with 2 bits
        endcase
    end

    // Combinational Logic for 7-Segment Display Multiplexing
    // Updates anodes and segments based on current digit (rotabit) and state (estado)
    always @(*) begin
        // Default assignment to avoid latches
        anodos = 4'b1111; // All off
        segmentos = blank; // Blank

        case (rotabit)
            2'd0: begin // Display 'estado' on Digit 0 (rightmost)
                anodos = 4'b1110; // Enable Digit 0
                case (estado)
                    4'd0: segmentos = cero;
                    4'd1: segmentos = uno;
                    4'd2: segmentos = dos;
                    4'd3: segmentos = tres;
                    default: segmentos = blank; // Handle unexpected estado values
                endcase
            end
            2'd1: begin // Blank Digit 1
                anodos = 4'b1101; // Enable Digit 1
                segmentos = blank;
            end
            2'd2: begin // Blank Digit 2
                anodos = 4'b1011; // Enable Digit 2
                segmentos = blank;
            end
            2'd3: begin // Blank Digit 3 (leftmost)
                anodos = 4'b0111; // Enable Digit 3
                segmentos = blank;
            end
            default: begin // Should not happen
                 anodos = 4'b1111;
                 segmentos = blank;
            end
        endcase
    end

endmodule