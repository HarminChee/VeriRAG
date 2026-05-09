module shift4(input wire test_i, input wire scan_load, input wire clk, output reg [3:0] data);
parameter NP = 21;  
parameter INI = 1;  
wire clk_pres;
reg load_shift = 0;
wire serin;
wire dft_load;
assign dft_load = test_i ? scan_load : load_shift;

prescaler #(.N(NP))
  pres1 (
    .clk_in(clk),
    .clk_out(clk_pres)
  );

always @(posedge(clk_pres)) begin
    load_shift <= 1;
end

always @(posedge(clk_pres)) begin
  if (dft_load == 0)  
    data <= INI;
  else
    data <= {data[2:0], serin};
end

assign serin = data[3];
endmodule