`timescale 1ns / 1ps
`timescale 1ns / 1ps
module egress_fifo_wrapper(
    input  wire RST,
    input  wire WRCLK,
    input  wire WREN,
    input  wire [127:0] DI,
    output wire FULL,
    output wire ALMOSTFULL,
    input  wire RDCLK,
    input  wire RDEN,
    output reg [127:0] DO,
    output wire EMPTY,
    output wire ALMOSTEMPTY
    );
localparam EMPTY_STATE = 2'b00;
localparam DEASSERT_EMPTY = 2'b01;
localparam RDEN_PASS = 2'b10;
localparam WAIT = 2'b11;
wire        full_a;
wire        almostfull_a;
wire        full_b;
wire        almostfull_b;
wire        almostempty_a;
wire        almostempty_b;
wire        empty_a;
wire        empty_b;
wire        empty_or;
reg         empty_reg;
wire        almostempty_or;
reg         almostempty_reg;
reg         rden_reg;
wire        rden_fifo;
reg [1:0] state;
`ifndef SINGLECYCLE
reg rden_d1; 
`endif
wire [127:0] do_fifo;
FIFO36_72 #( 
.ALMOST_EMPTY_OFFSET (9'h005),
.ALMOST_FULL_OFFSET  (9'h114),
.DO_REG              (1),
.EN_ECC_WRITE        ("FALSE"),
.EN_ECC_READ         ("FALSE"),
.EN_SYN              ("FALSE"),
.FIRST_WORD_FALL_THROUGH ("FALSE"))
egress_fifo_a(
.ALMOSTEMPTY (almostempty_a), 
.ALMOSTFULL  (almostfull_a), 
.DBITERR     (), 
.DO          (do_fifo[63:0]), 
.DOP         (), 
.ECCPARITY   (), 
.EMPTY       (empty_a),
.FULL        (full_a), 
.RDCOUNT     (), 
.RDERR       (), 
.SBITERR     (), 
.WRCOUNT     (), 
.WRERR       (),          
.DI          (DI[63:0]), 
.DIP         (), 
.RDCLK       (RDCLK), 
.RDEN        (rden_fifo),
.RST         (RST), 
.WRCLK       (WRCLK), 
.WREN        (WREN)
);
FIFO36_72 #( 
.ALMOST_EMPTY_OFFSET (9'h005),
.ALMOST_FULL_OFFSET  (9'h114),
.DO_REG              (1),
.EN_ECC_WRITE        ("FALSE"),
.EN_ECC_READ         ("FALSE"),
.EN_SYN              ("FALSE"),
.FIRST_WORD_FALL_THROUGH ("FALSE"))
egress_fifo_b(
.ALMOSTEMPTY (almostempty_b), 
.ALMOSTFULL  (almostfull_b), 
.DBITERR     (), 
.DO          (do_fifo[127:64]), 
.DOP         (), 
.ECCPARITY   (), 
.EMPTY       (empty_b),
.FULL        (full_b), 
.RDCOUNT     (), 
.RDERR       (), 
.SBITERR     (), 
.WRCOUNT     (), 
.WRERR       (),          
.DI          (DI[127:64]), 
.DIP         (), 
.RDCLK       (RDCLK), 
.RDEN        (rden_fifo),
.RST         (RST), 
.WRCLK       (WRCLK), 
.WREN        (WREN)
);
assign empty_or = empty_a | empty_b;
assign almostempty_or = almostempty_a | almostempty_b;
assign ALMOSTFULL = almostfull_a | almostfull_b; 
assign FULL = full_a | full_b; 
assign EMPTY = empty_reg; 
`ifdef SINGLECYCLE
assign rden_fifo = (RDEN | rden_reg) & ~empty_or; 
`else
assign rden_fifo = (rden_d1 | rden_reg) & ~empty_or; 
`endif
always@(posedge RDCLK)begin
   almostempty_reg <= almostempty_or;
end
always@(posedge RDCLK)begin
  if(RDEN)
        DO[127:0] <= do_fifo[127:0];
end
`ifndef SINGLECYCLE
always@(posedge RDCLK)begin
  if(state == RDEN_PASS & (empty_or & RDEN))
      rden_d1 <= 1'b0;
  else if(state == RDEN_PASS & ~(empty_or & RDEN))
      rden_d1 <= RDEN;
end
`endif
always@(posedge RDCLK)begin
    if(RST)begin
        state <= EMPTY_STATE;
        empty_reg <= 1;
        rden_reg <= 0;
    end else begin
        case(state)
           EMPTY_STATE:begin
                   empty_reg <= 1'b1;
                   if(~empty_or)begin
                       rden_reg <= 1'b1;
                       state <= DEASSERT_EMPTY;
                   end else begin
                       rden_reg <= 1'b0;
                       state <= EMPTY_STATE;
                   end
            end
            DEASSERT_EMPTY:begin 
                   empty_reg <= 1'b0;
                   rden_reg <= 1'b0;
                   state <= RDEN_PASS;
            end
            RDEN_PASS:begin 
                    rden_reg <= 1'b0;
                    if(empty_or & RDEN)begin
                       empty_reg <= 1'b1;
                       `ifdef SINGLECYCLE
                         state <= EMPTY_STATE;
                       `else
                         state <= WAIT;
                       `endif
                    end else begin
                       empty_reg <= 1'b0;
                       state <= RDEN_PASS;
                    end
             end
             `ifndef SINGLECYCLE
             WAIT:begin
                  empty_reg <= 1'b1;
                  rden_reg <= 1'b0;
                  state <= EMPTY_STATE;
             end
             `endif
             default:begin
                  state <= EMPTY_STATE;
                  empty_reg <= 1;
                  rden_reg <= 0;
             end
           endcase
     end
end     
endmodule
