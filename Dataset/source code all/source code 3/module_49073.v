module soc_pif8
(
    input               clk_i,
    input               rst_i,
    output [7:0]        periph0_addr_o,
    output [31:0]       periph0_data_o,
    input [31:0]        periph0_data_i,
    output reg          periph0_we_o,
    output reg          periph0_stb_o,
    output [7:0]        periph1_addr_o,
    output [31:0]       periph1_data_o,
    input [31:0]        periph1_data_i,
    output reg          periph1_we_o,
    output reg          periph1_stb_o,
    output [7:0]        periph2_addr_o,
    output [31:0]       periph2_data_o,
    input [31:0]        periph2_data_i,
    output reg          periph2_we_o,
    output reg          periph2_stb_o,
    output [7:0]        periph3_addr_o,
    output [31:0]       periph3_data_o,
    input [31:0]        periph3_data_i,
    output reg          periph3_we_o,
    output reg          periph3_stb_o,
    output [7:0]        periph4_addr_o,
    output [31:0]       periph4_data_o,
    input [31:0]        periph4_data_i,
    output reg          periph4_we_o,
    output reg          periph4_stb_o,
    output [7:0]        periph5_addr_o,
    output [31:0]       periph5_data_o,
    input [31:0]        periph5_data_i,
    output reg          periph5_we_o,
    output reg          periph5_stb_o,
    output [7:0]        periph6_addr_o,
    output [31:0]       periph6_data_o,
    input [31:0]        periph6_data_i,
    output reg          periph6_we_o,
    output reg          periph6_stb_o,
    output [7:0]        periph7_addr_o,
    output [31:0]       periph7_data_o,
    input [31:0]        periph7_data_i,
    output reg          periph7_we_o,
    output reg          periph7_stb_o,
    input [31:0]        io_addr_i,
    input [31:0]        io_data_i,
    output reg [31:0]   io_data_o,
    input               io_we_i,
    input               io_stb_i,
    output reg          io_ack_o
);
assign              periph0_addr_o = io_addr_i[7:0];
assign              periph0_data_o = io_data_i;
assign              periph1_addr_o = io_addr_i[7:0];
assign              periph1_data_o = io_data_i;
assign              periph2_addr_o = io_addr_i[7:0];
assign              periph2_data_o = io_data_i;
assign              periph3_addr_o = io_addr_i[7:0];
assign              periph3_data_o = io_data_i;
assign              periph4_addr_o = io_addr_i[7:0];
assign              periph4_data_o = io_data_i;
assign              periph5_addr_o = io_addr_i[7:0];
assign              periph5_data_o = io_data_i;
assign              periph6_addr_o = io_addr_i[7:0];
assign              periph6_data_o = io_data_i;
assign              periph7_addr_o = io_addr_i[7:0];
assign              periph7_data_o = io_data_i;
always @ *
begin
   periph0_we_o         = 1'b0;
   periph0_stb_o        = 1'b0;
   periph1_we_o         = 1'b0;
   periph1_stb_o        = 1'b0;
   periph2_we_o         = 1'b0;
   periph2_stb_o        = 1'b0;
   periph3_we_o         = 1'b0;
   periph3_stb_o        = 1'b0;
   periph4_we_o         = 1'b0;
   periph4_stb_o        = 1'b0;
   periph5_we_o         = 1'b0;
   periph5_stb_o        = 1'b0;
   periph6_we_o         = 1'b0;
   periph6_stb_o        = 1'b0;
   periph7_we_o         = 1'b0;
   periph7_stb_o        = 1'b0;
   case (io_addr_i[11:8])
   4'd 0 :
   begin
       periph0_we_o         = io_we_i;
       periph0_stb_o        = io_stb_i;
   end
   4'd 1 :
   begin
       periph1_we_o         = io_we_i;
       periph1_stb_o        = io_stb_i;
   end
   4'd 2 :
   begin
       periph2_we_o         = io_we_i;
       periph2_stb_o        = io_stb_i;
   end
   4'd 3 :
   begin
       periph3_we_o         = io_we_i;
       periph3_stb_o        = io_stb_i;
   end
   4'd 4 :
   begin
       periph4_we_o         = io_we_i;
       periph4_stb_o        = io_stb_i;
   end
   4'd 5 :
   begin
       periph5_we_o         = io_we_i;
       periph5_stb_o        = io_stb_i;
   end
   4'd 6 :
   begin
       periph6_we_o         = io_we_i;
       periph6_stb_o        = io_stb_i;
   end
   4'd 7 :
   begin
       periph7_we_o         = io_we_i;
       periph7_stb_o        = io_stb_i;
   end
   default :
      ;
   endcase
end
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i == 1'b1)
   begin
       io_data_o <= 32'b0;
       io_ack_o  <= 1'b0;
   end
   else
   begin
       if (io_stb_i)
       begin
           case (io_addr_i[11:8])
           4'd 0 : io_data_o  <= periph0_data_i;
           4'd 1 : io_data_o  <= periph1_data_i;
           4'd 2 : io_data_o  <= periph2_data_i;
           4'd 3 : io_data_o  <= periph3_data_i;
           4'd 4 : io_data_o  <= periph4_data_i;
           4'd 5 : io_data_o  <= periph5_data_i;
           4'd 6 : io_data_o  <= periph6_data_i;
           4'd 7 : io_data_o  <= periph7_data_i;
           default :  io_data_o  <= 32'h00000000;
           endcase
       end
       io_ack_o  <= io_stb_i;
   end
end
endmodule
