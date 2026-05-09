`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module altpcierd_icm_rx (clk, rstn,
                        rx_req, rx_ack, rx_desc, rx_data, rx_be,
                    rx_ws, rx_dv, rx_dfr, rx_abort, rx_retry, rx_mask,
                    rx_stream_ready, rx_stream_valid, rx_stream_data, rx_stream_mask
                          );
   input         clk;
   input         rstn;
   input         rx_req;             
   input[135:0]  rx_desc;            
   input[63:0]   rx_data;            
   input[7:0]    rx_be;              
   input         rx_dv;              
   input         rx_dfr;             
   output        rx_ack;             
   output        rx_abort;           
   output        rx_retry;           
   output        rx_ws;              
   output        rx_mask;            
   input         rx_stream_ready;       
   output        rx_stream_valid;       
   output[107:0] rx_stream_data;    
   input         rx_stream_mask;
   wire          rx_ack;
   wire          rx_abort;
   wire          rx_retry;
   wire          rx_ws;
   reg           rx_mask;
   wire          fifo_empty;
   wire          fifo_almostfull;
   wire          fifo_wr;
   wire          fifo_rd;
   wire[107:0]   fifo_wrdata;
   wire[107:0]   fifo_rddata;
   reg           stream_ready_del;
   reg           rx_stream_valid;
   reg[107:0]    rx_stream_data;
   reg           not_fifo_almost_full_del;  
   reg           fifo_rd_del;               
   altpcierd_icm_rxbridge rx_altpcierd_icm_rxbridge (
            .clk(clk), .rstn(rstn),
            .rx_req(rx_req), .rx_desc(rx_desc), .rx_dv(rx_dv), .rx_dfr(rx_dfr),
         .rx_data(rx_data), .rx_be(rx_be), .rx_ws(rx_ws), .rx_ack(rx_ack),
         .rx_abort(rx_abort), .rx_retry(rx_retry), .rx_mask(),
         .stream_ready(not_fifo_almost_full_del),
         .stream_wr(fifo_wr), .stream_wrdata(fifo_wrdata)
   );
   always @ (posedge clk or negedge rstn) begin
       if (~rstn) begin
         not_fifo_almost_full_del <= 1'b1;
      end
      else begin
          not_fifo_almost_full_del <= ~fifo_almostfull;
      end
   end
   altpcierd_icm_fifo    #(
       .RAMTYPE  ("RAM_BLOCK_TYPE=AUTO")
      )fifo_131x4 (
                           .clock        (clk),
                           .aclr         (~rstn),
                           .data         (fifo_wrdata),
                     .wrreq        (fifo_wr),
                     .rdreq        (fifo_rd & ~fifo_empty),
                     .q            (fifo_rddata),
                     .full         ( ),
                     .almost_full  (fifo_almostfull),
                     .almost_empty ( ),
                     .empty        (fifo_empty));
   always @ (posedge clk or negedge rstn) begin
       if (~rstn) begin
         stream_ready_del <= 1'b0;
         rx_mask          <= 1'b0;
      end
      else begin
          stream_ready_del <= rx_stream_ready;
         rx_mask          <= rx_stream_mask;
      end
   end
   assign fifo_rd = stream_ready_del & ~fifo_empty;     
   always @ (posedge clk or negedge rstn) begin
       if (~rstn) begin
          rx_stream_data  <= 107'h0;
         fifo_rd_del     <= 1'b0;
         rx_stream_valid <= 1'b0;
      end
      else begin
          rx_stream_data  <= fifo_rddata;
         fifo_rd_del     <= fifo_rd & ~fifo_empty;
         rx_stream_valid <= fifo_rd_del;              
      end
   end
endmodule
