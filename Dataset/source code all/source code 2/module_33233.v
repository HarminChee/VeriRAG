module asyn_fifo_read #(
    parameter                  FWFTEN    = 1,  
    parameter                  ADDRWIDTH = 6,
    parameter   [ADDRWIDTH:0]  FIFODEPTH = 44,
    parameter   [ADDRWIDTH:0]  MINBIN2   = 0,
    parameter   [ADDRWIDTH:0]  MAXBIN2   = 7
) (
    input  wire                    r_clk    ,
    input  wire                    r_rst_n  ,
    input  wire                    r_en     ,
    input  wire [ADDRWIDTH:0]      w2r_ptr  ,
    output reg  [ADDRWIDTH-1:0]    rbin     ,
    output reg  [ADDRWIDTH:0]      rptr     ,
    output                         inc      ,
    output reg                     r_valid  ,
    output reg  [ADDRWIDTH:0]      r_counter,
    output reg                     r_error
);
wire    zero = (r_counter == {(ADDRWIDTH+1){1'b0}} );
wire    fwft = FWFTEN ? (!r_valid && !zero) : 1'b0;
assign  inc  = (r_en && !zero) || fwft;
reg  [ADDRWIDTH:0]  rbin2;
wire [ADDRWIDTH:0]  rbnext = (rbin2>=MINBIN2 && rbin2<MAXBIN2) ?
                             (rbin2 + 1'b1) : MINBIN2;
always @(posedge r_clk or negedge r_rst_n)
    if (!r_rst_n)
        rbin2 <= MINBIN2;
    else if (inc)
        rbin2 <= rbnext;
always @(posedge r_clk or negedge r_rst_n)
    if (!r_rst_n)
        rbin <= {ADDRWIDTH{1'b0}};
    else if (inc)
        rbin <= rbnext[ADDRWIDTH] ? rbnext[ADDRWIDTH-1:0] :
                    (rbnext[ADDRWIDTH-1:0] - MINBIN2[ADDRWIDTH-1:0]);
wire [ADDRWIDTH:0]  rptr_gray = {1'b0,rbnext[ADDRWIDTH:1]} ^ rbnext;
always @(posedge r_clk or negedge r_rst_n)
    if (!r_rst_n)
        rptr <= (MINBIN2>>1) ^ MINBIN2;
    else if (inc)
        rptr <= rptr_gray;
reg [ADDRWIDTH:0] w2r_bin;
always @(w2r_ptr)
begin: GrayToBin
    integer i;
    for (i=ADDRWIDTH; i>=0; i=i-1)
        w2r_bin[i] = ^(w2r_ptr>>i);
end
wire [ADDRWIDTH:0] distance = ( (w2r_bin >= rbin2) ?
                                (w2r_bin  - rbin2) :
                                (w2r_bin  - rbin2 - (MINBIN2<<1) )
                              ) - inc;
always @(posedge r_clk or negedge r_rst_n)
    if (!r_rst_n)
        r_counter <= {(ADDRWIDTH+1){1'b0}};
    else
        r_counter <= distance;
always @(posedge r_clk or negedge r_rst_n)
    if (!r_rst_n)
        r_valid <= 1'b0;
    else if (r_en || fwft)
        r_valid <= !zero;
always @(posedge r_clk or negedge r_rst_n)
    if (!r_rst_n)
        r_error <= 1'b0;
    else
        r_error <= (r_counter > FIFODEPTH);
endmodule
