`timescale 1ns / 1ps
`timescale 1ns / 1ps
module ALUfuncionActivacion #(parameter Width = 24, Magnitud = 4, Precision = 19, Signo = 1)
(SELMUX,Enable,M,B,In,Out,Error);
	input [4:0] SELMUX;
	input Enable;
	input signed [Width-1:0] M,B,In;
	output Error;
	output reg signed [Width-1:0] Out = 0;
	wire signed [Width-1:0] Aux,OutSum;
	wire Error1,Error2;
	multiplicadorPuntoFijo #(.Width(Width), .Magnitud(Magnitud), .Precision(Precision),.Signo(Signo))   
	multiplicadorPuntoFijoCopia1 (
    .EnableMul(Enable), 
    .In(In), 
    .Coeff(M), 
    .OutMul(Aux),  
    .Error(Error1)  
    );
	 sumadorPuntoFijo #(.Width(Width), .Magnitud(Magnitud), .Precision(Precision),.Signo(Signo)) 
	 sumadorPuntoFijocopia1 (
    .EnableSum(Enable), 
    .In(B),  
    .Acumulador(Aux),   
    .OutSum(OutSum), 
    .Error(Error2)  
    );
	 always@* begin
		if(Enable) begin
			if(SELMUX==5'd0)
				Out <= 0;
			else if (SELMUX==5'd31)
				Out <= 1; 
			else 
				Out <= OutSum;
		end else begin
			Out <= 0;
		end
	 end
	 assign Error = Error2 | Error1;
endmodule
