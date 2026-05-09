module sseg_decode #(
  parameter REG = 0,          
  parameter INV = 1           
)(
  input  wire           clk,
  input  wire           rst,
  input  wire [  4-1:0] num,  
  output wire [  7-1:0] sseg  
);
reg [  7-1:0] sseg_decode;
always @ (*)
begin
  case(num)
    4'h0    : sseg_decode = 7'b0111111;
    4'h1    : sseg_decode = 7'b0000110;
    4'h2    : sseg_decode = 7'b1011011;
    4'h3    : sseg_decode = 7'b1001111;
    4'h4    : sseg_decode = 7'b1100110;
    4'h5    : sseg_decode = 7'b1101101;
    4'h6    : sseg_decode = 7'b1111101;
    4'h7    : sseg_decode = 7'b0000111;
    4'h8    : sseg_decode = 7'b1111111;
    4'h9    : sseg_decode = 7'b1101111;
    4'ha    : sseg_decode = 7'b1110111;
    4'hb    : sseg_decode = 7'b1111100;
    4'hc    : sseg_decode = 7'b0111001;
    4'hd    : sseg_decode = 7'b1011110;
    4'he    : sseg_decode = 7'b1111001;
    4'hf    : sseg_decode = 7'b1110001;
    default : sseg_decode = 7'b0000000;
  endcase
end
generate if (REG == 1) begin
  reg [  7-1:0] sseg_reg;
  always @ (posedge clk, posedge rst) begin
    if (rst)
      sseg_reg <= #1 7'h0;
    else
      sseg_reg <= #1 INV ? ~sseg_decode : sseg_decode;
  end
  assign sseg = sseg_reg;
end else begin
  assign sseg = INV ? ~sseg_decode : sseg_decode;
end
endgenerate
endmodule
