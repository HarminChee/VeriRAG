`timescale 1ns / 1ps
`timescale 1ns / 1ps
module FSM
(
	input wire clk,rst, 
	input wire Funct_Select,
	input wire [3:0] Count_CT,
	input wire [3:0] Count_F,
	output reg [3:0]C_Digit, 
	output reg [3:0]C_7Seg  
);
wire [3:0] Multiplexed_Count;
Mux_2x1 instancia_MUX_2x1 (
    .Seleccion(Funct_Select), 
    .D1(Count_CT), 
    .D0(Count_F), 
    .Y(Multiplexed_Count)
    );
localparam [3:0]
Eval_Funct_Select = 4'b0000,
Send_PNumb_CT = 4'b0001, 
Send_SNumb_CT = 4'b0010, 
Send_TNumb_CT = 4'b0011, 
Send_CNumb_CT = 4'b0100, 
Send_PNumb_F = 4'b0101, 
Send_SNumb_F = 4'b0110, 
Send_TNumb_F = 4'b0111, 
Send_CNumb_F = 4'b1000; 
reg [3:0] state, state_next; 
always@(posedge clk, posedge rst)
begin
	if(rst)
		state <= Eval_Funct_Select;
	else
		state <= state_next;
end
always@*
begin
	state_next = state;
	C_Digit = 0;
	C_7Seg = 0;
case(state)
		Eval_Funct_Select:
		if(Funct_Select)
		begin
		state_next = Send_PNumb_CT; 
		end
		else
		begin
		state_next = Send_PNumb_F; 
		end
      Send_PNumb_CT:
		begin
		state_next = Send_SNumb_CT;
		C_7Seg = 4'h8;		
		case(Multiplexed_Count)
		4'h0: C_Digit = 4'h0;
		4'h1: C_Digit = 4'h0;
		4'h2: C_Digit = 4'h0;
		4'h3: C_Digit = 4'h0;
		4'h4: C_Digit = 4'h0;
		4'h5: C_Digit = 4'h0;
		4'h6: C_Digit = 4'h0;
		4'h7: C_Digit = 4'h0;
		4'h8: C_Digit = 4'h0;
		4'h9: C_Digit = 4'h0;
		4'hA: C_Digit = 4'h0;
		4'hB: C_Digit = 4'h0;
		4'hC: C_Digit = 4'h0;
		4'hD: C_Digit = 4'h0;
		4'hE: C_Digit = 4'h0;
		4'hF: C_Digit = 4'h1;
		endcase
		end
      Send_SNumb_CT:
		begin
		state_next = Send_TNumb_CT; 
		C_7Seg = 4'h4;
		case(Multiplexed_Count)
		4'h0: C_Digit = 4'h0;
		4'h1: C_Digit = 4'h0;
		4'h2: C_Digit = 4'h1;
		4'h3: C_Digit = 4'h2;
		4'h4: C_Digit = 4'h2;
		4'h5: C_Digit = 4'h3;
		4'h6: C_Digit = 4'h4;
		4'h7: C_Digit = 4'h4;
		4'h8: C_Digit = 4'h5;
		4'h9: C_Digit = 4'h6;
		4'hA: C_Digit = 4'h6;
		4'hB: C_Digit = 4'h7;
		4'hC: C_Digit = 4'h8;
		4'hD: C_Digit = 4'h8;
		4'hE: C_Digit = 4'h9;
		4'hF: C_Digit = 4'h0;
		endcase
		end
      Send_TNumb_CT:
		begin
		state_next = Send_CNumb_CT;
		C_7Seg = 4'h2;			
		case(Multiplexed_Count)
		4'h0: C_Digit = 4'h0;
		4'h1: C_Digit = 4'h6;
		4'h2: C_Digit = 4'h3;
		4'h3: C_Digit = 4'h0;
		4'h4: C_Digit = 4'h6;
		4'h5: C_Digit = 4'h3;
		4'h6: C_Digit = 4'h0;
		4'h7: C_Digit = 4'h6;
		4'h8: C_Digit = 4'h3;
		4'h9: C_Digit = 4'h0;
		4'hA: C_Digit = 4'h6;
		4'hB: C_Digit = 4'h3;
		4'hC: C_Digit = 4'h0;
		4'hD: C_Digit = 4'h6;
		4'hE: C_Digit = 4'h3;
		4'hF: C_Digit = 4'h0;
		endcase
		end
      Send_CNumb_CT:
		begin
		state_next = Eval_Funct_Select;
		C_7Seg = 4'h1;	
		case(Multiplexed_Count)
		4'h0: C_Digit = 4'h0;
		4'h1: C_Digit = 4'h7;
		4'h2: C_Digit = 4'h3;
		4'h3: C_Digit = 4'h0;
		4'h4: C_Digit = 4'h7;
		4'h5: C_Digit = 4'h3;
		4'h6: C_Digit = 4'h0;
		4'h7: C_Digit = 4'h7;
		4'h8: C_Digit = 4'h3;
		4'h9: C_Digit = 4'h0;
		4'hA: C_Digit = 4'h7;
		4'hB: C_Digit = 4'h3;
		4'hC: C_Digit = 4'h0;
		4'hD: C_Digit = 4'h7;
		4'hE: C_Digit = 4'h3;
		4'hF: C_Digit = 4'h0;
		endcase
		end
      Send_PNumb_F:
		begin
		state_next = Send_SNumb_F;
		C_7Seg = 4'h8;	
		case(Multiplexed_Count)
		4'h0: C_Digit = 4'h0;
		4'h1: C_Digit = 4'h0;
		4'h2: C_Digit = 4'h0;
		4'h3: C_Digit = 4'h0;
		4'h4: C_Digit = 4'h0;
		4'h5: C_Digit = 4'h0;
		4'h6: C_Digit = 4'h0;
		4'h7: C_Digit = 4'h0;
		4'h8: C_Digit = 4'h0;
		4'h9: C_Digit = 4'h0;
		4'hA: C_Digit = 4'h0;
		4'hB: C_Digit = 4'h0;
		4'hC: C_Digit = 4'h0;
		4'hD: C_Digit = 4'h0;
		4'hE: C_Digit = 4'h0;
		4'hF: C_Digit = 4'h0;
		endcase
		end
      Send_SNumb_F:
		begin
		state_next = Send_TNumb_F;
		C_7Seg = 4'h4;	
		case(Multiplexed_Count)
		4'h0: C_Digit = 4'h0;
		4'h1: C_Digit = 4'h0;
		4'h2: C_Digit = 4'h0;
		4'h3: C_Digit = 4'h1;
		4'h4: C_Digit = 4'h1;
		4'h5: C_Digit = 4'h1;
		4'h6: C_Digit = 4'h1;
		4'h7: C_Digit = 4'h2;
		4'h8: C_Digit = 4'h2;
		4'h9: C_Digit = 4'h2;
		4'hA: C_Digit = 4'h2;
		4'hB: C_Digit = 4'h3;
		4'hC: C_Digit = 4'h3;
		4'hD: C_Digit = 4'h3;
		4'hE: C_Digit = 4'h3;
		4'hF: C_Digit = 4'h4;
		endcase
		end
      Send_TNumb_F:
		begin
		state_next = Send_CNumb_F;
		C_7Seg = 4'h2;	
		case(Multiplexed_Count)
		4'h0: C_Digit = 4'h3;
		4'h1: C_Digit = 4'h5;
		4'h2: C_Digit = 4'h7;
		4'h3: C_Digit = 4'h0;
		4'h4: C_Digit = 4'h2;
		4'h5: C_Digit = 4'h5;
		4'h6: C_Digit = 4'h7;
		4'h7: C_Digit = 4'h0;
		4'h8: C_Digit = 4'h2;
		4'h9: C_Digit = 4'h5;
		4'hA: C_Digit = 4'h7;
		4'hB: C_Digit = 4'h0;
		4'hC: C_Digit = 4'h2;
		4'hD: C_Digit = 4'h5;
		4'hE: C_Digit = 4'h7;
		4'hF: C_Digit = 4'h0;
		endcase
		end
      Send_CNumb_F:
		begin
		state_next = Eval_Funct_Select;
		C_7Seg = 4'h1;	
		case(Multiplexed_Count)
		4'h0: C_Digit = 4'h0;
		4'h1: C_Digit = 4'h0;
		4'h2: C_Digit = 4'h5;
		4'h3: C_Digit = 4'h0;
		4'h4: C_Digit = 4'h5;
		4'h5: C_Digit = 4'h0;
		4'h6: C_Digit = 4'h5;
		4'h7: C_Digit = 4'h0;
		4'h8: C_Digit = 4'h5;
		4'h9: C_Digit = 4'h0;
		4'hA: C_Digit = 4'h5;
		4'hB: C_Digit = 4'h0;
		4'hC: C_Digit = 4'h5;
		4'hD: C_Digit = 4'h0;
		4'hE: C_Digit = 4'h5;
		4'hF: C_Digit = 4'h0;
		endcase
		end
endcase
end
endmodule
