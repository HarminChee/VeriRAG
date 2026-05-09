`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module mig_7series_v2_0_ddr_if_post_fifo #
  (
   parameter TCQ   = 100,             
   parameter DEPTH = 4,               
   parameter WIDTH = 32               
   )
  (
   input              clk,            
   input              rst,            
   input [3:0]        empty_in,
   input              rd_en_in,
   input [WIDTH-1:0]  d_in,           
   output             empty_out,
   output             byte_rd_en,
   output [WIDTH-1:0] d_out           
   );
  localparam PTR_BITS 
             = (DEPTH == 2) ? 1 : 
               (((DEPTH == 3) || (DEPTH == 4)) ? 2 : 'bx);
  integer i;
  reg [WIDTH-1:0]    mem[0:DEPTH-1];
  (* max_fanout = 40 *) reg [4:0]          my_empty ;
  (* max_fanout = 40 *) reg [1:0]          my_full ;
  reg [PTR_BITS-1:0] rd_ptr ;
  (* KEEP = "TRUE" *) reg [PTR_BITS-1:0] rd_ptr_timing ;
  reg [PTR_BITS-1:0] wr_ptr ;
  wire [WIDTH-1:0]   mem_out;
  (* max_fanout = 40 *) wire               wr_en ;
  task updt_ptrs;
    input rd;
    input wr;
    reg [1:0] next_rd_ptr;
    reg [1:0] next_wr_ptr;
    begin
      next_rd_ptr = (rd_ptr + 1'b1)%DEPTH;
      next_wr_ptr = (wr_ptr + 1'b1)%DEPTH;
      casez ({rd, wr, my_empty[1], my_full[1]})
        4'b00zz: ; 
        4'b0100: begin
          wr_ptr  <= #TCQ next_wr_ptr;
          my_full[0] <= #TCQ (next_wr_ptr == rd_ptr);
          my_full[1] <= #TCQ (next_wr_ptr == rd_ptr);
        end
        4'b0110: begin
          wr_ptr   <= #TCQ next_wr_ptr;
          my_empty <= #TCQ 5'b00000;
        end     
        4'b1000: begin
          rd_ptr   <= #TCQ next_rd_ptr;
          rd_ptr_timing   <= #TCQ next_rd_ptr;
          my_empty[0] <= #TCQ (next_rd_ptr == wr_ptr);
          my_empty[1] <= #TCQ (next_rd_ptr == wr_ptr);
          my_empty[2] <= #TCQ (next_rd_ptr == wr_ptr);
          my_empty[3] <= #TCQ (next_rd_ptr == wr_ptr);
          my_empty[4] <= #TCQ (next_rd_ptr == wr_ptr);
        end
        4'b1001: begin
          rd_ptr <= #TCQ next_rd_ptr;
          rd_ptr_timing <= #TCQ next_rd_ptr;
          my_full[0] <= #TCQ 1'b0;
          my_full[1] <= #TCQ 1'b0;
        end
        4'b1100, 4'b1101, 4'b1110: begin
          rd_ptr <= #TCQ next_rd_ptr;
          rd_ptr_timing <= #TCQ next_rd_ptr;
          wr_ptr <= #TCQ next_wr_ptr;
        end
        4'b0101, 4'b1010: ;
        default: begin
          $display("ERR %m @%t: Bad access: rd:%b,wr:%b,empty:%b,full:%b", 
                   $time, rd, wr, my_empty[1], my_full[1]);    
          rd_ptr <=  #TCQ 2'bxx;
          rd_ptr_timing <=  #TCQ 2'bxx;
          wr_ptr <=  #TCQ 2'bxx;
        end
      endcase
    end
  endtask
  assign d_out = my_empty[4] ? d_in : mem_out;
  assign empty_out = empty_in[0] & my_empty[0];
  assign byte_rd_en = !empty_in[3] || !my_empty[3];
  always @(posedge clk) 
    if (rst) begin
      my_empty <=  #TCQ 5'b11111;
      my_full  <=  #TCQ 2'b00;
      rd_ptr   <=  #TCQ 'b0;
      rd_ptr_timing   <=  #TCQ 'b0;
      wr_ptr   <=  #TCQ 'b0;
    end else begin
      if (my_empty[1] && !my_full[1] && rd_en_in && !empty_in[1]) ;
      else
        updt_ptrs(rd_en_in, !empty_in[1]);
    end
  assign wr_en = (!empty_in[2] & ((!rd_en_in & !my_full[0]) |
                                  (rd_en_in & !my_empty[2])));
  always @ (posedge clk)
  begin
    if (wr_en)
      mem[wr_ptr] <= #TCQ d_in;
  end
  assign mem_out = mem[rd_ptr_timing];
endmodule
