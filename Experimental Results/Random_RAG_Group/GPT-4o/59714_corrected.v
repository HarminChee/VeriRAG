module shift4(input wire clk, input wire test_i, input wire scan_serin, output reg [3:0] data);
parameter NP = 21;  
parameter INI = 1;  
wire clk_pres;
reg load_shift = 0;
wire serin;
wire dft_serin;
assign dft_serin = test_i ? scan_serin : serin;

prescaler #(.N(NP))
  pres1 (
    .clk_in(clk),
    .clk_out(clk_pres)
  );

always @(posedge(clk_pres)) begin
    load_shift <= 1;
end

always @(posedge(clk_pres)) begin
  if (load_shift == 0)  
    data <= INI;
  else
    data <= {data[2:0], dft_serin};
end

assign serin = data[3];

endmodule