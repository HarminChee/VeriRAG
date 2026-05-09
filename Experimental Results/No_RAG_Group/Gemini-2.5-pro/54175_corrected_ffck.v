module S4L2_corrected_ffc(clock_50mhz, clock_1hz, segmentos, anodo,estado);
input clock_50mhz;
output reg clock_1hz;
output reg [6:0] segmentos = 7'h3F;
output reg anodo = 0; // Assuming anodo logic is intended elsewhere or fixed value
output reg [3:0] estado = 0;

reg [25:0] cuenta_para_1hz = 0;
reg enable_1hz = 1'b0; // Clock enable signal

parameter [6:0] cero 	= 	~7'h3F;
parameter [6:0] uno 	= 	~7'h06;
parameter [6:0] dos 	= 	~7'h5B;
parameter [6:0] tres 	= 	~7'h4F;
parameter [6:0] cuatro	=	~7'h66;
parameter [6:0] cinco	= 	~7'h6D;
parameter [6:0] seis 	= 	~7'h7D;
parameter [6:0] siete	= 	~7'h07;
parameter [6:0] ocho 	= 	~7'h7F;
parameter [6:0] nueve	=	~7'h6F;
parameter [6:0] ha 		= 	~7'h77;
parameter [6:0] hb 		= 	~7'h7C;
parameter [6:0] hc 		= 	~7'h39;
parameter [6:0] hd 		= 	~7'h5E;
parameter [6:0] he 		= 	~7'h79;
parameter [6:0] hf 		= 	~7'h71;

// Generate the 1Hz enable signal and the 1Hz output clock toggle
// Both are synchronous to the primary clock_50mhz
always @(posedge clock_50mhz)
begin
  enable_1hz <= 1'b0; // Default value for enable
  if(cuenta_para_1hz == 25_000_000 - 1) // Check if limit is about to be reached
  begin
    clock_1hz <= ~clock_1hz;        // Toggle the output clock signal
    cuenta_para_1hz <= 0;           // Reset counter
    enable_1hz <= 1'b1;             // Assert enable for one cycle
  end
  else
  begin
    cuenta_para_1hz <= cuenta_para_1hz + 1; // Increment counter
    // enable_1hz remains 0 (due to default assignment)
  end
end

// State machine logic, clocked by the primary clock and using the enable signal
always @(posedge clock_50mhz)
begin
  if (enable_1hz) begin // Update state only when enabled
    case(estado)
      0: estado <= 1;
      1: estado <= 2;
      2: estado <= 3;
      3: estado <= 4;
      4: estado <= 5;
      5: estado <= 6;
      6: estado <= 7;
      7: estado <= 8;
      8: estado <= 9;
      9: estado <= 10;
      10: estado <= 11;
      11: estado <= 12;
      12: estado <= 13;
      13: estado <= 14;
      14: estado <= 15;
      15: estado <= 0;
      default: estado <= 0; // Ensure defined behavior for invalid states
    endcase
  end
end

// Combinational logic to drive the 7-segment display based on the current state
// Using @(*) for implicit sensitivity list is generally preferred for combinational blocks
always @(*)
begin
  case(estado)
    0: segmentos = cero;
    1: segmentos = uno;
    2: segmentos = dos;
    3: segmentos = tres;
    4: segmentos = cuatro;
    5: segmentos = cinco;
    6: segmentos = seis;
    7: segmentos = siete;
    8: segmentos = ocho;
    9: segmentos = nueve;
    10: segmentos = ha;
    11: segmentos = hb;
    12: segmentos = hc;
    13: segmentos = hd;
    14: segmentos = he;
    15: segmentos = hf;
    default: segmentos = cero; // Default assignment for safety
  endcase
  // Note: anodo logic is not defined based on inputs/state in the original code, keeping its default
end

endmodule