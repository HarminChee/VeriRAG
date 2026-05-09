module SmallLpf #(
    parameter WIDTH     = 8, 
    parameter FILT_BITS = 8  
)
(
    input  clk,                       
    input  rst,                       
    input  en,                        
    input  signed [WIDTH-1:0] dataIn, 
    output signed [WIDTH-1:0] dataOut 
);
reg signed [WIDTH+FILT_BITS-1:0] filter;
assign dataOut = filter[WIDTH+FILT_BITS-1:FILT_BITS];
always @(posedge clk) begin
    if (rst) begin
        filter <= 'd0;
    end
    else if (en) begin
        filter <= filter + dataIn - dataOut;
    end
end
endmodule
