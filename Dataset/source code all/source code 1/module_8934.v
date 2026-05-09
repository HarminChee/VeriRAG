module uart(
  input wire clock,         
  output reg txd = 1'b1,
  input wire [23:0] tx_data,
  output reg tx_empty = 1'b1,     
  input wire transmit       
);
parameter divide_count = 712;
reg [9:0] divider = 0;
reg [29:0] shifter;
reg [4:0] shift_count = 0;
always @(posedge clock) begin
  tx_empty = (shift_count == 0) ? 1'b1 : 1'b0;
  if (tx_empty == 1'b1 && transmit == 1'b1) begin
    $display("accept new byte from tx_data");
    shifter <= {1'b1, tx_data[23:16], 1'b0, 1'b1, tx_data[15:8], 1'b0, 1'b1, tx_data[7:0], 1'b0}; 
    shift_count <= 31;
    tx_empty <= 1'b0;
  end
  if (divider == divide_count) begin
    divider <= 1;
    if (shift_count != 0) begin
      txd <= shifter[0];
      shifter <= {1'b1, shifter[29:1]};
      shift_count <= shift_count - 5'd1;
    end
  end else begin
    divider <= divider + 10'd1;
  end
end
endmodule
