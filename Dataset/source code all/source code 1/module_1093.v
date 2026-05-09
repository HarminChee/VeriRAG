`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module mig_7series_v2_0_qdr_rld_if_post_fifo #
  (
   parameter TCQ   = 100,             
   parameter DEPTH = 4,               
   parameter WIDTH = 32               
   )
  (
   input              clk,            
   input              rst,            
   input              empty_in,
   input              rd_en_in,
   input [WIDTH-1:0]  d_in,           
   output             empty_out,
   output [WIDTH-1:0] d_out           
   );
  localparam PTR_BITS 
             = (DEPTH == 2) ? 1 : 
               (((DEPTH == 3) || (DEPTH == 4)) ? 2 : 'bx);
  integer i;
  reg [WIDTH-1:0]    mem[0:DEPTH-1];
  reg                my_empty;
  reg                my_full;
  reg [PTR_BITS-1:0] rd_ptr ;
  reg [PTR_BITS-1:0] wr_ptr ;
  task updt_ptrs;
    input rd;
    input wr;
    reg [1:0] next_rd_ptr;
    reg [1:0] next_wr_ptr;
    begin
      next_rd_ptr = (rd_ptr + 1'b1)%DEPTH;
      next_wr_ptr = (wr_ptr + 1'b1)%DEPTH;
      casez ({rd, wr, my_empty, my_full})
        4'b00zz: ; 
        4'b0100: begin
          wr_ptr <= #TCQ next_wr_ptr;
          my_full <= #TCQ (next_wr_ptr == rd_ptr);
        end
        4'b0110: begin
          wr_ptr <= #TCQ next_wr_ptr;
          my_empty <= #TCQ 1'b0;
        end     
        4'b1000: begin
          rd_ptr <= #TCQ next_rd_ptr;
          my_empty <= #TCQ (next_rd_ptr == wr_ptr);
        end
        4'b1001: begin
          rd_ptr <= #TCQ next_rd_ptr;
          my_full <= #TCQ 1'b0;
        end
        4'b1100, 4'b1101, 4'b1110: begin
          rd_ptr <= #TCQ next_rd_ptr;
          wr_ptr <= #TCQ next_wr_ptr;
        end
        4'b0101, 4'b1010: ;
        default: begin
          $display("ERR %m @%t: Bad access: rd:%b,wr:%b,empty:%b,full:%b", 
                   $time, rd, wr, my_empty, my_full);    
          rd_ptr <= 2'bxx;
          wr_ptr <= 2'bxx;
        end
      endcase
    end
  endtask
wire [WIDTH-1:0] mem_out;
  assign d_out = my_empty ? d_in : mem_out;
  assign empty_out = empty_in & my_empty;
  always @(posedge clk) 
    if (rst) begin
      my_empty <= 1'b1;
      my_full <= 1'b0;
      rd_ptr <= 'b0;
      wr_ptr <= 'b0;
    end else begin
      if (my_empty && !my_full && rd_en_in && !empty_in) ;
      else
        updt_ptrs(rd_en_in, ~empty_in);
    end
wire wr_en;
assign wr_en = (!rd_en_in & !empty_in & !my_full)
             | (rd_en_in & !empty_in & !my_empty);
always @ (posedge clk)
begin
  if (wr_en)
    mem[wr_ptr] <= #TCQ d_in;
end
assign mem_out = mem [rd_ptr];
endmodule
