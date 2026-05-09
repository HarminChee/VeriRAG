`timescale 1ps/1ps
  module read_posted_fifo #
  (
   parameter TCQ           = 100,  
   parameter FAMILY     = "SPARTAN6",  
   parameter MEM_BURST_LEN = 4,
   parameter ADDR_WIDTH = 32,
   parameter BL_WIDTH = 6
  )
  (
   input                   clk_i, 
   input                   rst_i,
   output reg                 cmd_rdy_o, 
   input                   cmd_valid_i, 
   input                   data_valid_i,
   input [ADDR_WIDTH-1:0]  addr_i, 
   input [BL_WIDTH-1:0]    bl_i,
   input                   user_bl_cnt_is_1,
   input [2:0]           cmd_sent, 
   input [5:0]           bl_sent  ,
   input                 cmd_en_i ,
   input                   gen_rdy_i, 
   output                  gen_valid_o, 
   output [ADDR_WIDTH-1:0] gen_addr_o, 
   output [BL_WIDTH-1:0]   gen_bl_o,
   output [6:0]           rd_buff_avail_o,
   input                   rd_mdata_fifo_empty,
   output                  rd_mdata_en
   ); 
reg empty_r;
reg rd_first_data;
   wire full;
   wire empty;
   wire wr_en;
   reg rd_en;
   reg data_valid_r;
   reg user_bl_cnt_not_1;
    reg [6:0] buf_avail_r;
    reg [6:0] rd_data_received_counts;
    reg [6:0] rd_data_counts_asked;
      reg dfifo_has_enough_room;
    reg [1:0] wait_cnt;
    reg wait_done;
  assign rd_mdata_en = rd_en;
   assign rd_buff_avail_o = buf_avail_r;
   always @ (posedge clk_i)
       cmd_rdy_o <= #TCQ !full  & dfifo_has_enough_room & wait_done;
   always @ (posedge clk_i)
   begin
   if (rst_i)
       wait_cnt <= #TCQ 'b0;
   else if (cmd_rdy_o && cmd_valid_i)
       wait_cnt <= #TCQ 2'b10;
   else if (wait_cnt > 0)
         wait_cnt <= #TCQ wait_cnt - 1;
   end
   always @(posedge clk_i)
   begin
   if (rst_i)
      wait_done <= #TCQ 1'b1;
   else if (cmd_rdy_o && cmd_valid_i)
      wait_done <= #TCQ 1'b0;
   else if (wait_cnt == 0)
      wait_done <= #TCQ 1'b1;
   else
      wait_done <= #TCQ 1'b0;
   end
   reg dfifo_has_enough_room_d1;
   always @ (posedge clk_i)
   begin 
       dfifo_has_enough_room <= #TCQ (buf_avail_r >= 62  ) ? 1'b1: 1'b0;
       dfifo_has_enough_room_d1 <= #TCQ dfifo_has_enough_room ;
   end
   assign wr_en    = cmd_valid_i & !full  & dfifo_has_enough_room_d1 & wait_done;
   always @ (posedge clk_i)
       data_valid_r <= #TCQ data_valid_i;
  always @ (posedge clk_i)
  begin
  if (data_valid_i && user_bl_cnt_is_1)  
     user_bl_cnt_not_1 <= #TCQ 1'b1;
  else     
     user_bl_cnt_not_1 <= #TCQ 1'b0;
  end  
 always @ (posedge clk_i)
 begin
 if (rst_i) begin
    rd_data_counts_asked <= #TCQ 'b0;
    end
 else if (cmd_en_i && cmd_sent[0] == 1) begin
    rd_data_counts_asked <= #TCQ rd_data_counts_asked + (bl_sent + 7'b0000001) ;
    end
 end
 always @ (posedge clk_i)
 begin
 if (rst_i) begin
     rd_data_received_counts <= #TCQ 'b0;
     end
 else if (data_valid_i) begin
     rd_data_received_counts <= #TCQ rd_data_received_counts + 1;
     end     
 end
 always @ (posedge clk_i)
     buf_avail_r <= #TCQ 64 - (rd_data_counts_asked - rd_data_received_counts);
   always @(gen_rdy_i, empty,empty_r,rd_mdata_fifo_empty,rd_first_data ,data_valid_i,data_valid_r,user_bl_cnt_not_1)
   begin
        if (FAMILY == "SPARTAN6")
            rd_en = gen_rdy_i & !empty;
        else 
             if ( MEM_BURST_LEN == 4)
                   rd_en = (~empty & empty_r & ~rd_first_data) | (~rd_mdata_fifo_empty & ~empty ) | (user_bl_cnt_not_1 & data_valid_i);
             else
                   rd_en = (data_valid_i & ~data_valid_r) | (user_bl_cnt_not_1 & data_valid_i);
        end
   always @ (posedge clk_i)
        empty_r <= #TCQ empty;
   always @ (posedge clk_i)
   begin 
   if (rst_i)
       rd_first_data <= #TCQ 1'b0;
   else if (~empty && empty_r)
       rd_first_data <= #TCQ 1'b1;
   end   
   assign gen_valid_o = !empty;
   afifo #
   (
    .TCQ               (TCQ),
    .DSIZE         (BL_WIDTH+ADDR_WIDTH),
    .FIFO_DEPTH    (16),
    .ASIZE         (4),
    .SYNC          (1)  
   )
   rd_fifo
   (
    .wr_clk        (clk_i),
    .rst           (rst_i),
    .wr_en         (wr_en),
    .wr_data       ({bl_i,addr_i}),
    .rd_en         (rd_en),
    .rd_clk        (clk_i),
    .rd_data       ({gen_bl_o,gen_addr_o}),
    .full          (full),
    .empty         (empty),
    .almost_full   ()
   );
endmodule 
`timescale 1ps/1ps
  module read_posted_fifo #
  (
   parameter TCQ           = 100,  
   parameter FAMILY     = "SPARTAN6",  
   parameter MEM_BURST_LEN = 4,
   parameter ADDR_WIDTH = 32,
   parameter BL_WIDTH = 6
  )
  (
   input                   clk_i, 
   input                   rst_i,
   output reg                 cmd_rdy_o, 
   input                   cmd_valid_i, 
   input                   data_valid_i,
   input [ADDR_WIDTH-1:0]  addr_i, 
   input [BL_WIDTH-1:0]    bl_i,
   input                   user_bl_cnt_is_1,
   input [2:0]           cmd_sent, 
   input [5:0]           bl_sent  ,
   input                 cmd_en_i ,
   input                   gen_rdy_i, 
   output                  gen_valid_o, 
   output [ADDR_WIDTH-1:0] gen_addr_o, 
   output [BL_WIDTH-1:0]   gen_bl_o,
   output [6:0]           rd_buff_avail_o,
   input                   rd_mdata_fifo_empty,
   output                  rd_mdata_en
   ); 
reg empty_r;
reg rd_first_data;
   wire full;
   wire empty;
   wire wr_en;
   reg rd_en;
   reg data_valid_r;
   reg user_bl_cnt_not_1;
    reg [6:0] buf_avail_r;
    reg [6:0] rd_data_received_counts;
    reg [6:0] rd_data_counts_asked;
      reg dfifo_has_enough_room;
    reg [1:0] wait_cnt;
    reg wait_done;
  assign rd_mdata_en = rd_en;
   assign rd_buff_avail_o = buf_avail_r;
   always @ (posedge clk_i)
       cmd_rdy_o <= #TCQ !full  & dfifo_has_enough_room & wait_done;
   always @ (posedge clk_i)
   begin
   if (rst_i)
       wait_cnt <= #TCQ 'b0;
   else if (cmd_rdy_o && cmd_valid_i)
       wait_cnt <= #TCQ 2'b10;
   else if (wait_cnt > 0)
         wait_cnt <= #TCQ wait_cnt - 1;
   end
   always @(posedge clk_i)
   begin
   if (rst_i)
      wait_done <= #TCQ 1'b1;
   else if (cmd_rdy_o && cmd_valid_i)
      wait_done <= #TCQ 1'b0;
   else if (wait_cnt == 0)
      wait_done <= #TCQ 1'b1;
   else
      wait_done <= #TCQ 1'b0;
   end
   reg dfifo_has_enough_room_d1;
   always @ (posedge clk_i)
   begin 
       dfifo_has_enough_room <= #TCQ (buf_avail_r >= 62  ) ? 1'b1: 1'b0;
       dfifo_has_enough_room_d1 <= #TCQ dfifo_has_enough_room ;
   end
   assign wr_en    = cmd_valid_i & !full  & dfifo_has_enough_room_d1 & wait_done;
   always @ (posedge clk_i)
       data_valid_r <= #TCQ data_valid_i;
  always @ (posedge clk_i)
  begin
  if (data_valid_i && user_bl_cnt_is_1)  
     user_bl_cnt_not_1 <= #TCQ 1'b1;
  else     
     user_bl_cnt_not_1 <= #TCQ 1'b0;
  end  
 always @ (posedge clk_i)
 begin
 if (rst_i) begin
    rd_data_counts_asked <= #TCQ 'b0;
    end
 else if (cmd_en_i && cmd_sent[0] == 1) begin
    rd_data_counts_asked <= #TCQ rd_data_counts_asked + (bl_sent + 7'b0000001) ;
    end
 end
 always @ (posedge clk_i)
 begin
 if (rst_i) begin
     rd_data_received_counts <= #TCQ 'b0;
     end
 else if (data_valid_i) begin
     rd_data_received_counts <= #TCQ rd_data_received_counts + 1;
     end     
 end
 always @ (posedge clk_i)
     buf_avail_r <= #TCQ 64 - (rd_data_counts_asked - rd_data_received_counts);
   always @(gen_rdy_i, empty,empty_r,rd_mdata_fifo_empty,rd_first_data ,data_valid_i,data_valid_r,user_bl_cnt_not_1)
   begin
        if (FAMILY == "SPARTAN6")
            rd_en = gen_rdy_i & !empty;
        else 
             if ( MEM_BURST_LEN == 4)
                   rd_en = (~empty & empty_r & ~rd_first_data) | (~rd_mdata_fifo_empty & ~empty ) | (user_bl_cnt_not_1 & data_valid_i);
             else
                   rd_en = (data_valid_i & ~data_valid_r) | (user_bl_cnt_not_1 & data_valid_i);
        end
   always @ (posedge clk_i)
        empty_r <= #TCQ empty;
   always @ (posedge clk_i)
   begin 
   if (rst_i)
       rd_first_data <= #TCQ 1'b0;
   else if (~empty && empty_r)
       rd_first_data <= #TCQ 1'b1;
   end   
   assign gen_valid_o = !empty;
   afifo #
   (
    .TCQ               (TCQ),
    .DSIZE         (BL_WIDTH+ADDR_WIDTH),
    .FIFO_DEPTH    (16),
    .ASIZE         (4),
    .SYNC          (1)  
   )
   rd_fifo
   (
    .wr_clk        (clk_i),
    .rst           (rst_i),
    .wr_en         (wr_en),
    .wr_data       ({bl_i,addr_i}),
    .rd_en         (rd_en),
    .rd_clk        (clk_i),
    .rd_data       ({gen_bl_o,gen_addr_o}),
    .full          (full),
    .empty         (empty),
    .almost_full   ()
   );
endmodule 
