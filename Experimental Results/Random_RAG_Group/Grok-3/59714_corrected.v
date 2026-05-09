module shift4 (
    input wire test_i,
    input wire clk,
    input wire rst,
    output reg [3:0] data
);
parameter NP = 21;
parameter INI = 1;
wire clk_pres;
wire dft_clk;
reg load_shift = 0;
wire serin;

prescaler #(.N(NP))
  pres1 (
    .clk_in(clk),
    .clk_out(clk_pres)
  );

assign dft_clk = test_i ? clk : clk_pres;

always @(posedge dft_clk or posedge rst) begin
    if (rst) begin
        load_shift <= 0;
    end else begin
        load_shift <= 1;
    end
end

always @(posedge dft_clk or posedge rst) begin
    if (rst) begin
        data <= INI;
    end else if (load_shift == 0) begin
        data <= INI;
    end else begin
        data <= {data[2:0], serin};
    end
end

assign serin = data[3];

endmodule