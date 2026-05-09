`timescale 1ns/1ns
`timescale 1ns/1ns
module ff
    (
     input      CLK,
     input      D,
     output reg Q
     );
    always @ (posedge CLK) begin 
	    Q <= #1 D; 
    end
endmodule
