module S4A2(
    input wire clock_50mhz,
    input wire rst_n, // Added asynchronous reset (active low)
    input wire test_i, // Test mode input

    output reg clock_1hz,
    output reg [6:0] segmentos,
    output reg [3:0] anodos,
    output reg [3:0] estado
);

// Parameters for segment display (directly defined negated values for common cathode)
// Assuming common anode based on original code's anodos logic (active low)
// If common cathode, remove the '~' or use original parameters.
localparam [6:0] CERO = ~7'h3F; // 7'b1000000
localparam [6:0] UNO  = ~7'h06; // 7'b1111001
localparam [6:0] DOS  = ~7'h5B; // 7'b0100100
localparam [6:0] TRES = ~7'h4F; // 7'b0110000

// Parameter for 2kHz clock generation
localparam COUNT_2KHZ = 12_500; // 50MHz / (2kHz * 2 toggle rate) = 12,500

// Internal registers
reg [25:0] cuenta_para_1hz;
reg [25:0] cuenta_para_2khz;
reg clock_2khz;
reg [3:0] rotabit;

// Generate 1Hz clock
always @(posedge clock_50mhz or negedge rst_n) begin
    if (!rst_n) begin
        cuenta_para_1hz <= 26'b0;
        clock_1hz <= 1'b0;
    end else begin
        if (cuenta_para_1hz == 25_000_000 - 1) begin
            clock_1hz <= ~clock_1hz;
            cuenta_para_1hz <= 26'b0;
        end else begin
            cuenta_para_1hz <= cuenta_para_1hz + 1;
        end
    end
end

// Generate 2kHz clock (approximate toggle rate)
always @(posedge clock_50mhz or negedge rst_n) begin
    if (!rst_n) begin
        cuenta_para_2khz <= 26'b0;
        clock_2khz <= 1'b0;
    end else begin
        if (cuenta_para_2khz == COUNT_2KHZ - 1) begin
            clock_2khz <= ~clock_2khz;
            cuenta_para_2khz <= 26'b0;
        end else begin
            cuenta_para_2khz <= cuenta_para_2khz + 1;
        end
    end
end

// DFT Muxing for internally generated clocks feeding FFs
// Selects primary clock 'clock_50mhz' in test mode (test_i=1)
// Selects functional clock otherwise (test_i=0)
wire dft_clk_for_rotabit = test_i ? clock_50mhz : clock_2khz;
wire dft_clk_for_estado = test_i ? clock_50mhz : clock_1hz;

// Rotabit logic clocked by DFT-muxed clock
always @(posedge dft_clk_for_rotabit or negedge rst_n) begin
    if (!rst_n) begin
        rotabit <= 4'b0;
    end else begin
        case(rotabit)
            4'd0: rotabit <= 4'd1;
            4'd1: rotabit <= 4'd2;
            4'd2: rotabit <= 4'd3;
            4'd3: rotabit <= 4'd0;
            default: rotabit <= 4'd0; // Default case for safety
        endcase
    end
end

// Anode control (combinational based on rotabit)
// Use @(*) for combinational logic sensitivity list
always @(*) begin
    case(rotabit)
        4'd0: anodos = 4'b1110; // Anode 0 active
        4'd1: anodos = 4'b1101; // Anode 1 active
        4'd2: anodos = 4'b1011; // Anode 2 active
        4'd3: anodos = 4'b0111; // Anode 3 active
        default: anodos = 4'b1110; // Default assignment
    endcase
end

// Estado logic clocked by DFT-muxed clock
always @(posedge dft_clk_for_estado or negedge rst_n) begin
    if (!rst_n) begin
        estado <= 4'b0;
    end else begin
        case(estado)
            4'd0: estado <= 4'd1;
            4'd1: estado <= 4'd2;
            4'd2: estado <= 4'd3;
            4'd3: estado <= 4'd0;
            default: estado <= 4'd0; // Default case for safety
        endcase
    end
end

// Segment control (combinational based on rotabit)
// Displays 0, 1, 2, 3 sequentially as anodes rotate
// Use @(*) for combinational logic sensitivity list
always @(*) begin
    case(rotabit) // Display pattern depends on active anode (rotabit)
        4'd0: segmentos = CERO;
        4'd1: segmentos = UNO;
        4'd2: segmentos = DOS;
        4'd3: segmentos = TRES;
        default: segmentos = CERO; // Default assignment
    endcase
end

endmodule