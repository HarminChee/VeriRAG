module shift4_corrected_ffc(input wire clk, output reg [3:0] data);
parameter NP = 21;  
parameter INI = 1;  
reg load_shift = 0;
wire serin;

always @(posedge(clk)) begin
    load_shift <= 1;
end

always @(posedge(clk)) begin
  if (load_shift == 0)  
    data <= INI;
  else
    data <= {data[2:0], serin};
end

assign serin = data[3];
endmodule