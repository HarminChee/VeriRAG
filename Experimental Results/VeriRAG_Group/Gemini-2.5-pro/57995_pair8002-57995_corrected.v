module S4A2(
    input clock_50mhz,
    input reset, // Added reset input for DFT
    input test_i, // Added test mode input for DFT
    output reg clock_1hz,
    output reg [6:0] segmentos, // Removed initial value, reset will handle
    output reg [3:0] anodos,     // Removed initial value, reset will handle
    output reg [3:0] estado      // Removed initial value, reset will handle
);

// Internal signals
reg [25:0] cuenta_para_1hz = 0;
reg [25:0] cuenta_para_2khz = 0;
reg clock_2khz = 0;
reg [1:0] rotabit = 0; // Adjusted width based on usage (0 to 3 requires 2 bits)

// Parameters for 7-segment display (inverted logic)
parameter [6:0] cero = ~7'h3F;
parameter [6:0] uno  = ~7'h06;
parameter [6:0] dos  = ~7'h5B;
parameter [6:0] tres = ~7'h4F;

// DFT Clock MUXes
wire dft_clock_1hz;
wire dft_clock_2khz;

assign dft_clock_1hz = test_i ? clock_50mhz : clock_1hz;
assign dft_clock_2khz = test_i ? clock_50mhz : clock_2khz;

// 1Hz Clock Generation
always @(posedge clock_50mhz or posedge reset)
begin
    if (reset) begin
        cuenta_para_1hz <= 0;
        clock_1hz <= 1'b0; // Reset state for clock
    end else begin
        if (cuenta_para_1hz == 25_000_000 - 1) begin // Adjusted count for correct period
            clock_1hz <= ~clock_1hz;
            cuenta_para_1hz <= 0;
        end else begin
            cuenta_para_1hz <= cuenta_para_1hz + 1;
        end
    end
end

// 2kHz Clock Generation (approx. target based on original count)
// Note: Original count 2_550_000 from 50MHz is ~9.8Hz. Assuming target was closer to 2kHz.
// Let's keep the original division factor for consistency, but note it's not 2kHz.
// 50MHz / (2 * 2_550_000) = ~9.8 Hz. Recalculating for ~2kHz: 50M / (2 * 12500) = 2kHz
parameter DIV_2KHZ = 12500; // For ~2kHz
// parameter DIV_2KHZ = 2_550_000; // Original value resulting in ~9.8Hz

always @(posedge clock_50mhz or posedge reset)
begin
    if (reset) begin
        cuenta_para_2khz <= 0;
        clock_2khz <= 1'b0; // Reset state for clock
    end else begin
        if (cuenta_para_2khz == DIV_2KHZ - 1) begin // Adjusted count
            clock_2khz <= ~clock_2khz;
            cuenta_para_2khz <= 0;
        end else begin
            cuenta_para_2khz <= cuenta_para_2khz + 1;
        end
    end
end

// Rotabit counter (controls anode selection)
always @(posedge dft_clock_2khz or posedge reset) // Use DFT MUXed clock
begin
    if (reset) begin
        rotabit <= 0;
    end else begin
        case(rotabit)
            2'd0: rotabit <= 2'd1;
            2'd1: rotabit <= 2'd2;
            2'd2: rotabit <= 2'd3;
            2'd3: rotabit <= 2'd0;
            default: rotabit <= 2'd0; // Prevent latching X
        endcase
    end
end

// Anode Control (combinational)
always @(*) // Changed to combinational sensitivity list
begin
    case(rotabit)
        2'd0: anodos = 4'b1110; // Activate digit 0
        2'd1: anodos = 4'b1101; // Activate digit 1
        2'd2: anodos = 4'b1011; // Activate digit 2
        2'd3: anodos = 4'b0111; // Activate digit 3
        default: anodos = 4'b1111; // All off
    endcase
end

// State counter (controls displayed digit pattern)
always @(posedge dft_clock_1hz or posedge reset) // Use DFT MUXed clock
begin
    if (reset) begin
        estado <= 0;
    end else begin
        case(estado)
            4'd0: estado <= 4'd1;
            4'd1: estado <= 4'd2;
            4'd2: estado <= 4'd3;
            4'd3: estado <= 4'd0; // Assuming it should cycle 0-1-2-3
            default: estado <= 4'd0; // Prevent latching X
        endcase
    end
end

// Segment Control (combinational based on active anode)
// Original logic displayed 0, 1, 2, 3 sequentially on ALL digits simultaneously
// based on rotabit. This seems incorrect for typical multiplexed display.
// Assuming the intent was to show the value of 'estado' on the active digit selected by 'rotabit'
// OR to show fixed digits 0, 1, 2, 3 on positions 0, 1, 2, 3 respectively.
// Let's implement the latter as it matches the original structure more closely.
always @(*) // Changed to combinational sensitivity list
begin
    case(rotabit) // Display fixed number based on active digit position
        2'd0: segmentos = cero; // Digit 0 shows '0'
        2'd1: segmentos = uno;  // Digit 1 shows '1'
        2'd2: segmentos = dos;  // Digit 2 shows '2'
        2'd3: segmentos = tres; // Digit 3 shows '3'
        default: segmentos = 7'hFF; // All segments off
    endcase
end

endmodule