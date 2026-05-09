module shift4(
    input wire clk,
    input wire rst_n,
    output reg [3:0] data
);

parameter NP = 21;  
parameter INI = 1;  
reg load_shift;
wire serin;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        load_shift <= 1'b0;
        data <= INI;
    end else begin
        load_shift <= 1'b1;
        if (load_shift == 1'b0)
            data <= INI;
        else 
            data <= {data[2:0], serin};
    end
end

assign serin = data[3];

endmodule