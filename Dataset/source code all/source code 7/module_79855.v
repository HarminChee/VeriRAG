`timescale 1ns / 1ps
`timescale 1ns / 1ps
module performance_counters(
    input clk,
    input rst,
    input wr_dma_start,
    input wr_dma_done,
    input rd_dma_start,
    input rd_dma_done,
    output reg [31:0] dma_wr_count,
    output reg [31:0] dma_rd_count,
    input read_last,
    input write_last
    );
wire wr_dma_start_one;
wire rd_dma_start_one;
wire wr_dma_done_one;
wire rd_dma_done_one;
reg write_active, read_active;
rising_edge_detect wr_dma_start_one_inst(
                .clk(clk),
                .rst(rst),
                .in(wr_dma_start),
                .one_shot_out(wr_dma_start_one)
                );
rising_edge_detect rd_dma_start_one_inst(
                .clk(clk),
                .rst(rst),
                .in(rd_dma_start),
                .one_shot_out(rd_dma_start_one)
                );
rising_edge_detect wr_dma_done_one_inst(
                .clk(clk),
                .rst(rst),
                .in(wr_dma_done),
                .one_shot_out(wr_dma_done_one)
                );
rising_edge_detect rd_dma_done_one_inst(
                .clk(clk),
                .rst(rst),
                .in(rd_dma_done),
                .one_shot_out(rd_dma_done_one)
                );
always@(posedge clk)begin
   if(rst)begin
      write_active <= 1'b0;
   end else if(wr_dma_start_one | wr_dma_done_one)begin
      case({wr_dma_start_one, wr_dma_done_one, write_last})
         3'b000,3'b001,3'b110,3'b111:begin 
              write_active <= write_active;
         end
         3'b011:begin
              write_active <= 1'b0;
         end
         3'b100,3'b101,3'b010:begin
              write_active <= 1'b1;
         end
         default:begin write_active <= 1'b0;end
      endcase
   end else begin
       write_active <= write_active;  
   end
end
always@(posedge clk)begin
   if(rst)begin
      read_active <= 1'b0;
   end else if(rd_dma_start_one | rd_dma_done_one)begin
      case({rd_dma_start_one, rd_dma_done_one, read_last})
         3'b000,3'b001,3'b110,3'b111:begin  
              read_active <= read_active;
         end
         3'b011:begin
              read_active <= 1'b0;
         end
         3'b100,3'b101,3'b010:begin
              read_active <= 1'b1;
         end
         default:begin read_active <= 1'b0;end
      endcase
   end else begin
       read_active <= read_active;  
   end
end
always@(posedge clk)begin
   if(rst)
      dma_wr_count[31:0] <= 0;
   else if(write_active)
      dma_wr_count <= dma_wr_count + 1;
end      
always@(posedge clk)begin
   if(rst)
      dma_rd_count[31:0] <= 0;
   else if(read_active)
      dma_rd_count <= dma_rd_count + 1;
end    
endmodule
