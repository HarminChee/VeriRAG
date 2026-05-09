`timescale 1ns / 1ps
`timescale 1ns / 1ps
module controlador_teclado_ps2
(
input wire clk, reset,
input wire ps2data, ps2clk,
input wire [7:0] port_id,
input wire read_strobe,
output wire [7:0] ascii_code
);
wire [10:0] dout;
wire rx_done_tick;
wire gotten_code_flag;
wire [7:0] key_code;
reg [7:0] key_code_reg, key_code_next;
reg [1:0] state_current, state_next;
localparam [1:0] hold_key_code = 2'b0, read_key_code = 2'b01, reset_key_code = 2'b10;
receptor_teclado_ps2 instancia_receptor_teclado_ps2   
(
.clk(clk),
.reset(reset),
.ps2data(ps2data),
.ps2clk(ps2clk),
.rx_en(1'b1),
.rx_done_tick(rx_done_tick),
.dout(dout)
);
identificador_teclas instancia_identificador_teclas
(
.clk(clk),
.reset(reset),
.rx_done_tick(rx_done_tick),
.dout(dout[8:1]),
.gotten_code_flag(gotten_code_flag) 
);
keycode_to_ascii instancia_keycode_to_ascii
(
.key_code(key_code),
.ascii_code(ascii_code)
);
always@(posedge clk)
begin
	if(reset) begin
		key_code_reg <= 8'b0;
		state_current <= hold_key_code;
	end
	else begin
		key_code_reg <= key_code_next;
		state_current <= state_next;
	end
end
always@*
	begin
		case(state_current)
			hold_key_code:
			begin
			key_code_next = key_code_reg;
				if(gotten_code_flag) state_next = read_key_code;
				else state_next = state_current;
			end
			read_key_code:
			begin	
			key_code_next = dout[8:1]; 
				if(port_id == 8'h02 && read_strobe == 1) state_next = reset_key_code;
				else state_next = state_current;
			end
			reset_key_code:
			begin
			key_code_next = 8'b0;
				state_next = hold_key_code;
			end
			default:
			begin
				key_code_next = key_code_reg;
				state_next = state_current;
			end
		endcase
	end
assign key_code = key_code_reg;
endmodule
