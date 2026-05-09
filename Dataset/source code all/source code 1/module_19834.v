`timescale 1ns / 1ps
`timescale 1ns / 1ps
module FSM_Convert_Float_To_Fixed(
    input wire CLK, 
    input wire RST_FF, 
    input wire Exp_out, 
    input wire Begin_FSM_FF, 
    input wire [7:0] Exp, 
    output reg EN_REG1, 
    output reg LOAD, 
    output reg MS_1, 
    output reg ACK_FF, 
    output reg EN_MS_1,
    output reg EN_REG2,
    output reg RST
    );
parameter [3:0]  
     a = 4'b0000,
     b = 4'b0001,
     c = 4'b0010,
     d = 4'b0011,
     e = 4'b0100,
     f = 4'b0101,
     g = 4'b0110,
     h = 4'b0111,
     i = 4'b1000;
reg [3:0] state_reg, state_next ; 
always @(posedge CLK, posedge RST_FF)
	if (RST_FF) begin
		state_reg <= a;	
	end
	else begin
		state_reg <= state_next;
	end
    always @*
    begin
        state_next = state_reg;    
        EN_REG1 = 1'b0;
        EN_REG2 = 1'b0;
        ACK_FF = 1'b0;
        EN_MS_1=1'b0;
        MS_1=1'b0;
        LOAD = 1'b0;
        RST = 1'b0;
        case(state_reg)
            a: 
            begin  
                if(Begin_FSM_FF) 
                    begin
                    RST = 1'b1;
                    ACK_FF = 1'b0;    
                    state_next = b;
                    end
                else
                    state_next = a;       
            end
            b: 
            begin
                EN_REG1 = 1'b1;    
                state_next = c;
            end
            c:
            begin
                EN_MS_1 = 1'b1;
                if(Exp == 8'b01111111)
                    state_next = i;
                else
                state_next = d;
            end
            d:
            begin
                EN_MS_1 = 1'b1;
                MS_1 = 1'b1;
                state_next = e;
            end
            e:
            begin
                state_next = f;
            end 
            f:
            begin
                LOAD = 1'b1;
                state_next = g;
            end
            g:
            begin
                EN_REG2 = 1'b1;
                state_next = h;
            end
            h:
            begin
                ACK_FF = 1'b1;
                if(RST_FF)
                     state_next = a;
                else
                    state_next = h;
            end
            i:
            begin
                state_next = f;
            end
       default:
       state_next=a;
       endcase
    end
endmodule
