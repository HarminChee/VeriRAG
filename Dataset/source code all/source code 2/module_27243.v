`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module of_pre_fifo #
  (
   parameter TCQ   = 100,             
   parameter DEPTH = 4,               
   parameter WIDTH = 32               
   )
  (
   input              clk,            
   input              rst,            
   input              full_in,        
   input              wr_en_in,       
   input [WIDTH-1:0]  d_in,           
   output             wr_en_out,      
   output [WIDTH-1:0] d_out           
   );
  localparam PTR_BITS 
             = (DEPTH == 2) ? 1 : 
               ((DEPTH == 3) || (DEPTH == 4)) ? 2 : 
               (((DEPTH == 5) || (DEPTH == 6) || 
                 (DEPTH == 7) || (DEPTH == 8)) ? 3 : 'bx);
  integer i;
  reg [WIDTH-1:0]    mem[0:DEPTH-1];
  reg                my_empty;
  reg                my_full;
  reg [PTR_BITS-1:0] rd_ptr;
  reg [PTR_BITS-1:0] wr_ptr;
  wire [PTR_BITS-1:0] nxt_rd_ptr;
  wire [PTR_BITS-1:0] nxt_wr_ptr;
  wire [WIDTH-1:0] mem_out;
  wire wr_en;
  task updt_ptrs;
    input rd;
    input wr;
    reg [2:0] next_rd_ptr;
    reg [2:0] next_wr_ptr;
    begin
      casez ({rd, wr, my_empty, my_full})
        4'b0100: begin
        end
        4'b0110: begin
        end     
        4'b1000: begin
        end
        4'b1001: begin
        end
        4'b1100: begin
        end
        4'b1101: begin
        end
        default: begin
          $display("ERR %m @%t Illegal pointer sequence!", $time);
        end
      endcase
    end
  endtask
  assign d_out = my_empty ? d_in : mem_out;
  assign wr_en_out = (!my_empty || wr_en_in);
  always @(posedge clk) 
    if (rst) begin
    end else begin
      casez ({my_empty, my_full, full_in, wr_en_in})
        4'b0z00: begin
        end
        4'b0z01: begin
        end
        4'bz011: begin
        end
        4'b0010, 4'b0110, 4'b1000, 4'b1001, 4'b1010: ; 
        4'b0111: begin
          $display("ERR %m @%t Both FIFOs full and a write came in!", 
                   $time);
        end
        default: begin
          $display("ERR %m @%t Illegal access sequence!", $time);
        end
      endcase
    end
assign wr_en = wr_en_in & ((!my_empty & !full_in)|(!my_full & full_in));
always @ (posedge clk)
begin
  if (wr_en)
    mem[wr_ptr] <= #TCQ d_in;
end
assign mem_out = mem [rd_ptr];
assign nxt_rd_ptr = (rd_ptr + 1'b1)%DEPTH;
always @ (posedge clk)
begin
  if (rst)
  begin
    rd_ptr <= 'b0;
  end
  else if ((!my_empty) & (!full_in))
  begin 
    rd_ptr <= nxt_rd_ptr;
  end
end
always @ (posedge clk)
begin
  if (rst)
  begin
    my_empty <= 1'b1;
  end
  else if (my_empty & !my_full & full_in & wr_en_in)
  begin
    my_empty <= 1'b0;
  end
  else if (!my_empty & !my_full & !full_in & !wr_en_in)
  begin
    my_empty <= (nxt_rd_ptr == wr_ptr);
  end
end
assign nxt_wr_ptr = (wr_ptr + 1'b1)%DEPTH;
always @ (posedge clk)
begin
  if (rst)
  begin
    wr_ptr <= 'b0;
  end
  else if ( (wr_en_in) & ( (!my_empty & !full_in) | (!my_full & full_in) ) )
  begin 
    wr_ptr <= nxt_wr_ptr;
  end
end
always @ (posedge clk)
begin
  if (rst)
  begin
    my_full <= 1'b0;
  end
  else if (!my_empty & my_full & !full_in & !wr_en_in)
  begin
    my_full <= 1'b0;
  end
  else if (!my_empty & !my_full & full_in & wr_en_in)
  begin
    my_full <= (nxt_wr_ptr == rd_ptr);
  end
end
endmodule
