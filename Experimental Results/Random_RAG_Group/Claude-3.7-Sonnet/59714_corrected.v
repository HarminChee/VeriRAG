module shift4(
    input wire clk,
    input wire test_i,
    input wire rst_n,
    output reg [3:0] data
);

parameter NP = 21;  
parameter INI = 1;  

wire clk_pres;
reg load_shift = 0;
wire serin;
wire dft_clk;

prescaler #(.N(NP))
  pres1 (
    .clk_in(clk),
    .clk_out(clk_pres)
  );

assign dft_clk = test_i ? clk : clk_pres;

always @(posedge dft_clk or negedge rst_n) begin
    if (!rst_n)
        load_shift <= 0;
    else
        load_shift <= 1;
end

always @(posedge dft_clk or negedge rst_n) begin
    if (!rst_n)
        data <= 4'b0;
    else if (load_shift == 0)  
        data <= INI;
    else
        data <= {data[2:0], serin};
end

assign serin = data[3];

endmodule