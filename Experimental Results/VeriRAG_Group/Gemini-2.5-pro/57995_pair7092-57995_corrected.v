module S4A2(
    input clock_50mhz,
    input test_mode, // Added test mode input
    output reg clock_1hz,
    output reg [6:0] segmentos = 7'h3F,
    output reg [3:0] anodos = 4'h0,
    output reg [3:0] estado = 0
);

reg [25:0] cuenta_para_1hz = 0;
reg [25:0] cuenta_para_2khz = 0;
reg clock_2khz = 0;
reg [3:0] rotabit = 0;
reg [3:0] contador = 0; // Note: contador is declared but not used in the original code

parameter [6:0] cero = ~7'h3F;
parameter [6:0] uno = ~7'h06;
parameter [6:0] dos = ~7'h5B;
parameter [6:0] tres = ~7'h4F;

// DFT clock multiplexing logic
wire dft_clock_1hz;
wire dft_clock_2khz;

assign dft_clock_1hz = test_mode ? clock_50mhz : clock_1hz;
assign dft_clock_2khz = test_mode ? clock_50mhz : clock_2khz;

// 1Hz clock generation logic (unchanged from original)
always @(posedge clock_50mhz)
begin
    cuenta_para_1hz = cuenta_para_1hz + 1;
    if (cuenta_para_1hz == 25_000_000) begin
        clock_1hz <= ~clock_1hz; // Use non-blocking assignment
        cuenta_para_1hz <= 0;    // Use non-blocking assignment
    end
end

// 2kHz clock generation logic (unchanged from original)
always @(posedge clock_50mhz)
begin
    cuenta_para_2khz = cuenta_para_2khz + 1;
    if (cuenta_para_2khz == 2_550_000) begin // Note: Original value might be intended for 20Hz, not 2kHz. 50M/2k = 25000. Corrected value based on original comment might be 12500 for 2kHz. Using original value 2_550_000.
        clock_2khz <= ~clock_2khz; // Use non-blocking assignment
        cuenta_para_2khz <= 0;   // Use non-blocking assignment
    end
end

// Logic clocked by internally generated 2kHz clock (now uses DFT muxed clock)
always @(posedge dft_clock_2khz) // Changed clock source
begin
    case (rotabit)
        0: rotabit <= 1;
        1: rotabit <= 2;
        2: rotabit <= 3;
        3: rotabit <= 0;
        default: rotabit <= 0; // Added default case
    endcase
end

// Combinational logic for anode selection (unchanged sensitivity list)
// Consider making this synchronous if timing issues arise
always @(rotabit) // Sensitivity list remains combinational
begin
    case (rotabit)
        0: anodos = 4'b1110;
        1: anodos = 4'b1101;
        2: anodos = 4'b1011;
        3: anodos = 4'b0111;
        default: anodos = 4'b1111; // Added default case
    endcase
end

// Logic clocked by internally generated 1Hz clock (now uses DFT muxed clock)
always @(posedge dft_clock_1hz) // Changed clock source
begin
    case (estado)
        0: estado <= 1;
        1: estado <= 2;
        2: estado <= 3;
        3: estado <= 0;
        default: estado <= 0; // Added default case
    endcase
end

// Combinational logic for segment display (unchanged sensitivity list)
// Consider making this synchronous if timing issues arise
always @(rotabit) // Sensitivity list remains combinational
begin
    case (rotabit) // Assuming display should show 0, 1, 2, 3 based on active anode
        0: segmentos = cero;
        1: segmentos = uno;
        2: segmentos = dos;
        3: segmentos = tres;
        default: segmentos = 7'h7F; // All segments off for default
    endcase
end

endmodule