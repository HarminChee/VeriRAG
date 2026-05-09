module antares_mux_4_1 #(parameter WIDTH = 32)
    (
     input [1:0]            select,
     input [WIDTH-1:0]      in0,
     input [WIDTH-1:0]      in1,
     input [WIDTH-1:0]      in2,
     input [WIDTH-1:0]      in3,
     output reg [WIDTH-1:0] out
     );
    always @ ( in0 or in1 or in2 or in3 or select) begin
        case (select)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
        endcase 
    end 
endmodule 
