module rom32(address, data_out);
  input  [31:0] address;
  output [31:0] data_out;
  reg    [31:0] data_out;
  parameter BASE_ADDRESS = 25'd0; 
  wire [5:0] mem_offset;
  wire address_select;
  assign mem_offset = address[7:2];  
  assign address_select = (address[31:8] == BASE_ADDRESS);  
  always @(address_select or mem_offset)
  begin
    if ((address % 4) != 0) $display($time, " rom32 error: unaligned address %d", address);
    if (address_select == 1)
    begin
      case (mem_offset) 
          5'd0 : data_out = { 6'd35, 5'd0, 5'd2, 16'd4 };
          5'd1 : data_out = { 6'd0, 5'd2, 5'd2, 5'd3, 5'd0, 6'd32 };  
          5'd2 : data_out = { 6'd2, 26'd0 };    
          default data_out = 32'hxxxx;
      endcase
      $display($time, " reading data: rom32[%h] => %h", address, data_out);
    end
  end 
endmodule
