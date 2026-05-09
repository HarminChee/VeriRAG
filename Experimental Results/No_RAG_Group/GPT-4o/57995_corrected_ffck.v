module S4A2_corrected_ffc(clock_50mhz, reset, segmentos, anodos, estado);
input clock_50mhz; 							
input reset;
output reg clock_1hz; 						
output reg [6:0] segmentos = 7'h3F; 	
output reg [3:0] anodos = 4'h0; 			
output reg [3:0] estado = 0; 				
reg [25:0] cuenta_para_1hz = 0; 			
reg [25:0] cuenta_para_2khz = 0;
reg [3:0] rotabit = 0; 						
reg [3:0] contador = 0;
parameter [6:0] cero = 	~7'h3F; 			
parameter [6:0] uno 	= 	~7'h06; 
parameter [6:0] dos 	= 	~7'h5B; 
parameter [6:0] tres = 	~7'h4F;

always @(posedge clock_50mhz or posedge reset) 			
begin
    if (reset) begin
        cuenta_para_1hz <= 0;
        cuenta_para_2khz <= 0;
        clock_1hz <= 0;
    end else begin
        cuenta_para_1hz <= cuenta_para_1hz + 1;
        if(cuenta_para_1hz == 25_000_000) begin
            clock_1hz <= ~clock_1hz; 					
            cuenta_para_1hz <= 0; 						
        end

        cuenta_para_2khz <= cuenta_para_2khz + 1;
        if(cuenta_para_2khz == 2_550_000) begin
            cuenta_para_2khz <= 0; 						
        end
    end
end

always @(posedge clock_50mhz or posedge reset)
begin
    if (reset) begin
        rotabit <= 0;
    end else if(cuenta_para_2khz == 2_550_000) begin
        case(rotabit)
            0: rotabit <= 1;
            1: rotabit <= 2;
            2: rotabit <= 3;
            3: rotabit <= 0;
        endcase
    end
end

always @(rotabit)
begin
    case(rotabit)
        0: anodos = 4'b1110;
        1: anodos = 4'b1101;
        2: anodos = 4'b1011;
        3: anodos = 4'b0111;
    endcase
end

always @(posedge clock_1hz or posedge reset)
begin
    if (reset) begin
        estado <= 0;
    end else begin
        case(estado)
            0: estado <= 1;
            1: estado <= 2;
            2: estado <= 3;
            3: estado <= 0;
        endcase
    end
end

always @(rotabit)
begin
    case(rotabit)
        0: segmentos = cero;
        1: segmentos = uno;
        2: segmentos = dos;
        3: segmentos = tres;
    endcase
end

endmodule