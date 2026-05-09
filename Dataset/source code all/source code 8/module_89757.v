`timescale 1ns / 1ps
`timescale 1ns / 1ps
module posted_pkt_builder(
    input clk,
    input rst,
    input [15:0] req_id, 
	 input posted_fifo_full,
    input go,
    output reg ack,
    input [63:0] dmawad,
    input [9:0] length,
    output reg [63:0] header_data_out,
    output reg header_data_wren
);
localparam IDLE = 4'h0; 
localparam HEAD1 = 4'h1; 
localparam HEAD2 = 4'h2;
localparam WAIT_FOR_GO_DEASSERT = 4'h3;
localparam rsvd = 1'b0; 
localparam MWr = 5'b00000; 
localparam TC = 3'b000;    
localparam TD = 1'b0;      
localparam EP = 1'b0;      
localparam ATTR = 2'b00; 
localparam LastBE = 4'b1111; 
localparam FirstBE = 4'b1111;
wire [1:0] fmt;
reg [3:0] state;
reg [63:0] dmawad_reg;
reg   rst_reg;
always@(posedge clk) rst_reg <= rst;
assign fmt[1:0] = (dmawad_reg[63:32] == 0) ? 2'b10 : 2'b11;
always@(posedge clk)begin
  if(rst_reg)begin
    dmawad_reg[63:0] <= 0;
  end else if(go)begin
    dmawad_reg <= dmawad;
  end
end
always @ (posedge clk) begin
  if (rst_reg) begin
      header_data_out <= 0;
      header_data_wren <= 1'b0;
      ack <= 1'b0;
      state <= IDLE;
  end else begin
      case (state)
        IDLE : begin
           header_data_out <= 0;
           header_data_wren <= 1'b0;
           ack <= 1'b0;
           if(go & ~posted_fifo_full)   
             state<= HEAD1;
           else
             state<= IDLE;
         end
         HEAD1 : begin
           header_data_out <= {rsvd,fmt[1:0],MWr,rsvd,TC,rsvd,rsvd,rsvd,rsvd,
                               TD,EP,ATTR,rsvd,rsvd,length[9:0],req_id[15:0],
                               8'b00000000 ,LastBE,FirstBE};
           ack <= 0;
           header_data_wren <= 1'b1;
           state <= HEAD2;
         end
         HEAD2 : begin
             header_data_out <= (fmt[0]==1'b1) 
                                ? {dmawad_reg[63:2],2'b00} 
                                : {dmawad_reg[31:2], 2'b00, dmawad_reg[63:32]};
             header_data_wren <= 1'b1;
             ack <= 1'b1; 
             state <= WAIT_FOR_GO_DEASSERT;
         end
         WAIT_FOR_GO_DEASSERT: begin 
             header_data_out <= 0;
             header_data_wren <= 1'b0;
             ack <= 1'b0;
             state <= IDLE;
         end
         default : begin
             header_data_out <= 0;
             header_data_wren <= 1'b0;
             ack <= 1'b0; 
             state <= IDLE;
         end
      endcase
   end
 end
endmodule
