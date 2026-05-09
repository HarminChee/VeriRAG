`timescale 1ns / 1ps
`timescale 1ns / 1ps
module Controlador_reloj_digital(
		input clk,reset,
		output reg_a_d,reg_cs,reg_rd,reg_wr,
		output [7:0]port_id,out_port,fin_lectura_escritura,
		inout [7:0]dato
    );
wire [11:0]address;
wire [17:0]instruction;
wire bram_enable; 
reg [7:0]in_port;
wire write_strobe;
wire k_write_strobe;
wire read_strobe;
wire interrupt;
wire interrupt_ack;
wire sleep;
wire rst;
wire flag_done;
reg [7:0]fin_lectura_escritura;
wire [7:0]out_dato;
reg state_reg_flag,state_next_flag;
assign interrupt = 0;
assign interrupt_ack = 0;
assign sleep = 0;
kcpsm6 microntroller_picoblaze (
    .address(address), 
    .instruction(instruction), 
    .bram_enable(bram_enable), 
    .in_port(in_port), 
    .out_port(out_port), 
    .port_id(port_id), 
    .write_strobe(write_strobe), 
    .k_write_strobe(k_write_strobe), 
    .read_strobe(read_strobe), 
    .interrupt(interrupt), 
    .interrupt_ack(interrupt_ack), 
    .sleep(sleep), 
    .reset(rst), 
    .clk(clk)
    ); 
ROM_programa ROM_0 (
    .address(address), 
    .instruction(instruction), 
    .enable(bram_enable), 
    .rdl(rst), 
    .clk(clk)
    );
escritor_lector_rtc instance_escritor_lector_rtc (
    .clk(clk), 
    .reset(reset), 
    .port_id(port_id), 
    .in_dato(out_port), 
    .write_strobe(write_strobe), 
    .read_strobe(read_strobe), 
    .reg_a_d(reg_a_d), 
    .reg_cs(reg_cs), 
    .reg_rd(reg_rd), 
    .reg_wr(reg_wr), 
    .out_dato(out_dato), 
    .fin_lectura_escritura(flag_done), 
    .dato(dato)
    );
 always @ (posedge clk)
  begin
      case (port_id) 
			8'h0F : in_port <= fin_lectura_escritura;
			8'h10 : in_port <= out_dato;
        default : in_port <= 8'bXXXXXXXX ;  
      endcase
  end
always @ (negedge clk,posedge reset) begin 
	if (reset) state_reg_flag = 1'b0;
	else state_reg_flag = state_next_flag;
end
always@ (*) begin
state_next_flag = state_reg_flag;
	case (state_reg_flag)
	1'b0: begin
		fin_lectura_escritura = 8'h00;
		if (flag_done == 1) state_next_flag = 1'b1;
		else state_next_flag = 1'b0;
		end
	1'b1: begin
		fin_lectura_escritura = 8'h01;
		if(port_id == 8'h0F && read_strobe == 1)  state_next_flag = 1'b0;
		else  state_next_flag = 1'b1; 		
	end
	endcase
end
endmodule
