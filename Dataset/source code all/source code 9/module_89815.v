`timescale 1ns / 1ps
`timescale 1ns / 1ps
module non_posted_pkt_builder(
    input clk,
    input rst,
    input [15:0] req_id, 
    input go,
    output reg ack,
    input [63:0] dmaras,
    input [31:0] dmarad,
    input [9:0] length,
	 input isDes,
    input [7:0] tag_value,
    input tag_gnt,
    output reg tag_inc,
    output reg [63:0] header_data_out,
    output reg header_data_wren,
    output reg [4:0] tx_waddr,
    output reg [31:0] tx_wdata,
    output reg tx_we
);
localparam IDLE = 4'h0; 
localparam HEAD1 = 4'h1; 
localparam HEAD2 = 4'h2;    
localparam WAIT_FOR_GO_DEASSERT = 4'h3;
localparam rsvd = 1'b0; 
localparam MRd = 5'b00000; 
localparam TC = 3'b000;    
localparam TD = 1'b0;      
localparam EP = 1'b0;      
localparam ATTR = 2'b00;     
localparam LastBE = 4'b1111; 
localparam FirstBE = 4'b1111;
wire [1:0] fmt;
reg [3:0] state;
reg [63:0] dmaras_reg;
reg [31:0] dmarad_reg;
reg   rst_reg;
always@(posedge clk) rst_reg <= rst;
assign fmt[1:0] = (dmaras_reg[63:32] == 0) ? 2'b00 : 2'b01;
always@(posedge clk)begin
  if(rst_reg)begin
    dmaras_reg[63:0] <= 0;
  end else if(go)begin
    dmaras_reg <= dmaras;
  end
end
always@(posedge clk)begin
  if(rst_reg)begin
    dmarad_reg[31:0] <= 0;
  end else if(go)begin
    dmarad_reg <= dmarad;
  end
end
always @ (posedge clk) begin
  if (rst_reg) begin
      header_data_out <= 0;
      header_data_wren <= 1'b0;
      ack <= 1'b0;
      tag_inc <=1'b0;   
      tx_waddr[4:0] <= 0;
      tx_wdata[31:0] <= 0;
      tx_we <= 1'b0;
      state <= IDLE;
  end else begin
      case (state)
        IDLE : begin
           header_data_out <= 0;
           header_data_wren <= 1'b0;
           ack <= 1'b0;
           tag_inc <=1'b0;   
           tx_waddr[4:0] <= 0;
           tx_wdata[31:0] <= 0;
           tx_we <= 1'b0;
           if(go)
             state<= HEAD1;
           else
             state<= IDLE;
         end
         HEAD1 : begin
           header_data_out <= {rsvd,fmt[1:0],MRd,rsvd,TC,rsvd,rsvd,rsvd,rsvd,
                               TD,EP,ATTR,rsvd,rsvd,length[9:0],req_id[15:0],
                               tag_value[7:0],LastBE,FirstBE};
           ack <= 0;
           tag_inc <=1'b0;   
           tx_waddr[4:0] <= 0;
           tx_wdata[31:0] <= 0;
           tx_we <= 1'b0;
           if(tag_gnt == 1'b0)begin
             state <= HEAD1;
             header_data_wren <= 1'b0;
           end else begin
             header_data_wren <= 1'b1;
             state <= HEAD2;
           end
         end
         HEAD2 : begin
             header_data_out <= (fmt[0]==1'b1) 
                                ? {dmaras_reg[63:2],2'b00} 
                                : {dmaras_reg[31:2], 2'b00, dmaras_reg[63:32]};
             header_data_wren <= 1'b1;
             tx_waddr[4:0] <= tag_value[4:0];
             tx_wdata[31:0] <= {isDes,9'b0_0000_0000,dmarad_reg[27:6]};
             tx_we <= 1'b1;
             ack <= 1'b1; 
             tag_inc <=1'b1;
             state <= WAIT_FOR_GO_DEASSERT;
         end
         WAIT_FOR_GO_DEASSERT : begin
             header_data_wren <= 1'b0;
             tx_we <= 1'b0;
             tag_inc <=1'b0; 
             ack <= 1'b0;                
             state <= IDLE;
         end
         default : begin
             header_data_out <= 0;
             header_data_wren <= 1'b0;
             ack <= 1'b0;
             tag_inc <=1'b0;  
             tx_waddr[4:0] <= 0;
             tx_wdata[31:0] <= 0;
             tx_we <= 1'b0;
             state <= IDLE;
         end
      endcase
   end
 end
endmodule
