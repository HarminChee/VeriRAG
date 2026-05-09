`timescale 1ns / 1ps
`timescale 1ns / 1ps
module completer_pkt_gen(
    input clk,
    input rst,
    input [6:0] bar_hit, 
    input comp_req, 
    input [31:0] MEM_addr, 
    input [15:0] MEM_req_id,
    input [15:0] comp_id, 
    input [7:0] MEM_tag, 
    output reg comp_fifo_wren,
    output reg [63:0] comp_fifo_data
);
localparam IDLE = 4'h0; 
localparam HEAD1 = 4'h1; 
localparam HEAD2 = 4'h2;
localparam rsvd = 1'b0;
localparam fmt = 2'b10; 
localparam CplD = 5'b01010; 
localparam TC = 3'b000;
localparam TD = 1'b0;
localparam EP = 1'b0;
localparam ATTR = 2'b00;
localparam Length = 10'b0000000001; 
localparam ByteCount = 12'b000000000100; 
localparam BCM = 1'b0;
    reg [3:0] state;
    reg [6:0] bar_hit_reg;
    reg [26:0] MEM_addr_reg;
    reg [15:0] MEM_req_id_reg;
    reg [15:0] comp_id_reg;
    reg [7:0] MEM_tag_reg;
reg   rst_reg;
always@(posedge clk) rst_reg <= rst;
always@(posedge clk)begin
    if(comp_req)begin
      bar_hit_reg <= bar_hit;
      MEM_addr_reg[26:0] <= MEM_addr[26:0];
      MEM_req_id_reg <= MEM_req_id;
      comp_id_reg <= comp_id;
      MEM_tag_reg <= MEM_tag;
    end
end
always @ (posedge clk) begin
  if (rst_reg) begin
      comp_fifo_data <= 0;
      comp_fifo_wren <= 1'b0;
      state <= IDLE;
  end else begin
      case (state)
        IDLE : begin
           comp_fifo_data <= 0;
           comp_fifo_wren <= 1'b0; 
           if(comp_req)
             state<= HEAD1;
           else
             state<= IDLE;
         end
         HEAD1 : begin 
             comp_fifo_data <= {bar_hit_reg[6:0],MEM_addr_reg[26:2],            
                                rsvd,fmt,CplD,rsvd,TC,rsvd,rsvd,rsvd,rsvd,
                                TD,EP,ATTR,rsvd,rsvd,Length};  
             comp_fifo_wren <= 1'b1; 
             state <= HEAD2;
         end
         HEAD2 : begin 
             comp_fifo_data <= {comp_id_reg[15:0],3'b000, BCM,ByteCount,
                                MEM_req_id_reg[15:0],MEM_tag_reg[7:0],rsvd,
                                MEM_addr_reg[6:0]};
             comp_fifo_wren <= 1'b1; 
             state <= IDLE;
         end
         default : begin
             comp_fifo_data <= 0;
             comp_fifo_wren <= 1'b0; 
             state <= IDLE;
         end
      endcase
   end
 end
endmodule
