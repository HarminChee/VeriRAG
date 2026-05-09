module cachefill_arbiter #(parameter WIDTH=32, parameter NUMPORTS=4)
( 
  input  clk,
  input  resetn,
  input  [NUMPORTS*WIDTH-1:0] addr,
  input  [NUMPORTS-1:0] read,
  output [NUMPORTS-1:0] waitrequest,
  output [WIDTH-1:0] fill_addr,
  output fill_read,
  input  fill_waitrequest
);
  reg  [(NUMPORTS+1)*WIDTH-1:0] queued_addr;
  reg  [(NUMPORTS+1)-1:0] queued_read;
  generate
  genvar p;
    for (p=0; p<NUMPORTS; p=p+1)
    begin : port_gen
      always@(posedge clk or negedge resetn)
        if (!resetn)
        begin
          queued_addr[p*WIDTH +: WIDTH]<=0;
          queued_read[p]<=0;
        end
        else if (fill_waitrequest && !queued_read[p])
        begin
          queued_addr[p*WIDTH +: WIDTH]<=addr[p*WIDTH +: WIDTH];
          queued_read[p]<=read[p];
        end
        else if (!fill_waitrequest)
          if (!queued_read[p+1])
          begin
            queued_addr[p*WIDTH +: WIDTH]<=addr[p*WIDTH +: WIDTH];
            queued_read[p]<=read[p];
          end
          else
          begin
            queued_addr[p*WIDTH +: WIDTH]<=queued_addr[(p+1)*WIDTH +: WIDTH];
            queued_read[p]<=queued_read[p+1];
          end
    end
  endgenerate
  always@(posedge clk) queued_read[NUMPORTS]=1'b0;
  always@(posedge clk) queued_addr[NUMPORTS*WIDTH +: WIDTH]=0;
  assign fill_addr=queued_addr[WIDTH-1:0];
  assign fill_read=queued_read[0];
  assign waitrequest=(fill_waitrequest) ? queued_read : queued_read>>1;
endmodule
module pipe(
    d,
    clk,
    resetn,
    en,
    squash,
    q
    );
parameter WIDTH=32;
parameter DEPTH=1;
parameter RESETVALUE={WIDTH{1'b0}};
input [WIDTH-1:0]  d;
input              clk;
input              resetn;
input  [DEPTH-1:0] en;
input  [DEPTH-1:0] squash;
output [WIDTH*DEPTH-1:0] q;
reg [WIDTH*DEPTH-1:0] q;
integer i;
  always@(posedge clk or negedge resetn)
  begin
    if ( !resetn )
      q[ WIDTH-1:0 ]<=RESETVALUE;
    else if ( squash[0] )
      q[ WIDTH-1:0 ]<=RESETVALUE;
    else if (en[0])
      q[ WIDTH-1:0 ]<=d;
    for (i=1; i<DEPTH; i=i+1)
      if (!resetn)
        q[i*WIDTH +: WIDTH ]<=RESETVALUE;
      else if ( squash[i] )
        q[i*WIDTH +: WIDTH ]<=RESETVALUE;
      else if (en[i])
        q[i*WIDTH +: WIDTH ]<=q[(i-1)*WIDTH +: WIDTH ];
  end
endmodule
module acl_const_cache 
#(
  parameter NUMPORTS=13,       
  parameter LOG2SIZE=10,       
  parameter LOG2WIDTH=5,       
  parameter AWIDTH=32,         
  parameter WIDTH=2**LOG2WIDTH,
  parameter MWIDTH=WIDTH,
  parameter MAWIDTH=AWIDTH-$clog2(MWIDTH/WIDTH), 
  parameter BURSTWIDTH=6
)
(
  input   clk,
  input   clk2x,
  input   resetn,
  output [MAWIDTH-1:0]     fill_addr,  
  output                   fill_read,
  input                    fill_waitrequest,
  input                    fill_readdatavalid,
  input  [MWIDTH-1:0]      fill_readdata,
  input tri0               flush_cache,
  input                         snoop_clk,
  input                         snoop_overflow,
  input  [MAWIDTH-1:0]          snoop_addr,  
  input  [BURSTWIDTH-1:0]       snoop_burst,
  input                         snoop_write,
  output                        snoop_ready,
  input      [NUMPORTS*AWIDTH-1:0]      rdport_addr,  
  input      [NUMPORTS-1:0]             rdport_read,
  output     [NUMPORTS-1:0]             rdport_waitrequest,
  output     [NUMPORTS-1:0]             rdport_readdatavalid,
  output reg [NUMPORTS*WIDTH-1:0]       rdport_readdata
);
  localparam USE2XCLOCK=(NUMPORTS>1);
  localparam CACHE_LATENCY=(USE2XCLOCK ? 4 : 2) + 1;
  localparam LOG2NUMCACHEENTRIES=LOG2SIZE-(LOG2WIDTH-3);
  localparam TAGSIZE=AWIDTH-(LOG2SIZE-LOG2WIDTH+3);
  `define TAGRANGE AWIDTH-1:LOG2SIZE-LOG2WIDTH+3
  `define OFFSETRANGE LOG2SIZE-(LOG2WIDTH-3)-1:0
  localparam DEVICE_BLOCKRAM_BITS = 8192; 
  localparam SNOOP_BURSTWIDTH = BURSTWIDTH + $clog2(MWIDTH/WIDTH);
  reg  [NUMPORTS-1:0]             _rdport_readdatavalid;
  reg  [NUMPORTS-1:0] hit;        
  reg  [NUMPORTS-1:0] miss;       
  wire [NUMPORTS-1:0] hit_comb;   
  wire [NUMPORTS-1:0] miss_comb;  
  wire [NUMPORTS-1:0] en;         
  wire [NUMPORTS-1:0] rotate;     
  wire [NUMPORTS-1:0] cache_valid;
  wire [NUMPORTS-1:0] cache_read;
  wire [NUMPORTS*AWIDTH-1:0] cache_addr_full;
  wire [NUMPORTS*LOG2NUMCACHEENTRIES-1:0] cache_addr;
  wire [NUMPORTS-1:0]             cache_readdatavalid;
  wire [NUMPORTS*WIDTH-1:0]       cache_readdata;
  wire [NUMPORTS-1:0] cache_waitrequest;
  wire [NUMPORTS*TAGSIZE-1:0] cache_tagout;
  wire [AWIDTH-1:0] fill_readdata_addr;
  reg  [AWIDTH-1:0] fill_readdata_addr_r;
  reg fill_readdatavalid_r;
  reg [WIDTH-1:0] fill_readdata_r;
  wire [AWIDTH-1:0]     fill_cc_addr;  
  reg  [AWIDTH-1:0] valid_addr;
  reg               valid_writedata;
  reg               valid_write;
  wire [AWIDTH-1:0] invalidate_addr;
  wire              invalidate_en;
  wire snoop_stall;
  localparam [1:0] s_INVALIDATE=2'b00;
  localparam [1:0] s_FILL=2'b01;
  localparam [1:0] s_FLUSH=2'b10;
  wire [1:0] valid_sel;
  reg  [LOG2NUMCACHEENTRIES-1:0] flush_counter;
  reg                            flushing;
  wire                           flush_overflow;
  wire                           do_flush;  
  wire [CACHE_LATENCY*AWIDTH-1:0] queued_addr[NUMPORTS-1:0];
  wire [CACHE_LATENCY-1:0]        queued_read[NUMPORTS-1:0];
  wire [AWIDTH-1:0]               _cache_addr_full[NUMPORTS-1:0];
  wire [AWIDTH-1:0]               compare_addr[NUMPORTS-1:0];
  wire [NUMPORTS-1:0]             compare_read;
  wire [AWIDTH-1:0]               miss_addr[NUMPORTS-1:0];
  wire [NUMPORTS-1:0]             miss_read;
  reg  [NUMPORTS-1:0]             miss_issued;
  reg  [NUMPORTS*AWIDTH-1:0] upstream_arb_addr;
  reg  [NUMPORTS-1:0] upstream_arb_read;
  wire [NUMPORTS-1:0] miss_waitrequest;
  wire                           clockcross_overflow;
  reg  [1:0] state[NUMPORTS-1:0];
  reg  [3:0] count[NUMPORTS-1:0]; 
  localparam p_PIPELINE=2'b00;
  localparam p_FILL=2'b01;
  localparam p_MISS=2'b10;
  localparam p_DRAIN=2'b11;
  generate
  genvar p;
  for (p=0; p<NUMPORTS; p=p+1)
  begin : portgen
    always@(posedge clk or negedge resetn)
    begin
      if (!resetn)
      begin
        state[p] <= p_PIPELINE;
        count[p] <= {4{1'b0}};
      end
      else
      begin
        case (state[p])
          p_PIPELINE: 
          begin
            state[p]<= (miss[p]) ? p_FILL : p_PIPELINE;
            count[p]<=CACHE_LATENCY-1;
          end
          p_FILL:
          begin
            state[p]<= (count[p]==0) ? p_MISS : p_FILL;
            count[p]<=count[p]-2'b01;
          end
          p_MISS:
          begin
            state[p]<= (hit[p]) ? p_DRAIN : p_MISS;
            count[p]<=CACHE_LATENCY-1;
          end
          p_DRAIN:
          begin
            state[p]<= (count[p]==0) ? p_PIPELINE : p_DRAIN;
            count[p]<=count[p]-2'b01;
          end
        endcase
      end
    end
    pipe # (.WIDTH(AWIDTH), .DEPTH(CACHE_LATENCY)) request_queue 
    ( .clk(clk), .resetn(resetn), 
      .en({CACHE_LATENCY{en[p]}}),
      .d( rotate[p] ? queued_addr[p][(CACHE_LATENCY-1)*AWIDTH +: AWIDTH] : 
                      rdport_addr[p*AWIDTH +: AWIDTH]),
      .q( queued_addr[p]));
    pipe # (.WIDTH(1), .DEPTH(CACHE_LATENCY)) request_queue_read
    ( .clk(clk), .resetn(resetn), 
      .en({CACHE_LATENCY{en[p]}}),
      .d( (!rotate[p]) ?  rdport_read[p] :
        queued_read[p][CACHE_LATENCY-1]), 
      .q( queued_read[p]));
    assign en[p]=((state[p]==p_PIPELINE && !miss[p]) || (state[p]==p_MISS && hit[p]) || state[p]==p_DRAIN) && !cache_waitrequest[p];
    assign rotate[p]=state[p]==p_DRAIN || flushing;
    assign cache_read[p]=(state[p]==p_PIPELINE) ? 
      rdport_read[p] :
      queued_read[p][CACHE_LATENCY-1] ; 
    assign cache_addr_full[p*AWIDTH +: AWIDTH]=(state[p]==p_PIPELINE) ? 
      rdport_addr[p*AWIDTH +: AWIDTH] :
      queued_addr[p][(CACHE_LATENCY-1)*AWIDTH +: AWIDTH];
    assign _cache_addr_full[p]=cache_addr_full[p*AWIDTH +: AWIDTH];
    assign cache_addr[p*LOG2NUMCACHEENTRIES +: LOG2NUMCACHEENTRIES] = _cache_addr_full[p][`OFFSETRANGE];
    assign compare_addr[p]= (state[p]==p_MISS || (state[p]==p_FILL && count[p]==0)) ? 
      queued_addr[p][(CACHE_LATENCY-1)*AWIDTH +: AWIDTH] :
      queued_addr[p][(CACHE_LATENCY-2)*AWIDTH +: AWIDTH] ;
    assign compare_read[p]= (state[p]==p_MISS || (state[p]==p_FILL && count[p]==0)) ?
      queued_read[p][CACHE_LATENCY-1] :
      queued_read[p][CACHE_LATENCY-2] ;
    always@(posedge clk or negedge resetn)
    begin
      if (!resetn)
        miss_issued[p] <= 1'b0;
      else if (state[p]==p_MISS && hit[p])  
        miss_issued[p]=1'b0;
      else if (miss_read[p] && !miss_waitrequest[p])
        miss_issued[p]=1'b1;
    end
    assign miss_addr[p]=queued_addr[p][(CACHE_LATENCY-1)*AWIDTH +: AWIDTH];
    assign miss_read[p]= queued_read[p][CACHE_LATENCY-1] && 
      ((miss[p] && state[p]==p_PIPELINE) || 
       (!miss_issued[p] && (state[p]==p_FILL || (state[p]==p_MISS && !hit[p]))));
    always@(posedge clk or negedge resetn)
      if (!resetn)
      begin
        hit[p]<=1'b0;
        miss[p]<=1'b0;
      end
      else
      begin
        hit[p]<=hit_comb[p];
        miss[p]<=miss_comb[p];
      end
    assign hit_comb[p]=cache_valid[p]===1'b1 && compare_read[p] &&
      (cache_tagout[p*TAGSIZE +: TAGSIZE]==compare_addr[p][`TAGRANGE]);
    assign miss_comb[p]=compare_read[p] && (cache_valid[p]!==1'b1 ||
      (cache_tagout[p*TAGSIZE +: TAGSIZE]!=compare_addr[p][`TAGRANGE]));
    assign rdport_waitrequest[p]=cache_waitrequest[p] || flushing ||
      !((state[p]==p_PIPELINE && !miss[p]) || (state[p]==p_MISS && hit[p]));
    assign rdport_readdatavalid[p]=_rdport_readdatavalid[p] && 
      (state[p]==p_PIPELINE ||state[p]==p_MISS);
    always@(posedge clk)
      _rdport_readdatavalid[p]<=cache_readdatavalid[p] && hit_comb[p];
    always@(posedge clk)
      rdport_readdata[p*WIDTH +: WIDTH]<=cache_readdata[p*WIDTH +: WIDTH];
  end
  endgenerate
  generate
  if (MWIDTH > WIDTH)
  begin
    reg  [AWIDTH-1:0] fill_readdata_addr_r0; 
    reg fill_readdatavalid_r0;
    reg [MWIDTH-1:0] fill_readdata_r0;
    always@(posedge clk)
      fill_readdatavalid_r<=fill_readdatavalid_r0;
    always@(posedge clk)
      fill_readdata_r<=fill_readdata_r0[fill_readdata_addr_r0[$clog2(MWIDTH/WIDTH)-1:0]*WIDTH +: WIDTH];
    always@(posedge clk)  
      fill_readdata_addr_r<=fill_readdata_addr_r0;
    always@(posedge clk) fill_readdatavalid_r0<=fill_readdatavalid;
    always@(posedge clk) fill_readdata_r0<=fill_readdata;
    always@(posedge clk) fill_readdata_addr_r0<=fill_readdata_addr;
  end
  else
  begin
    always@(posedge clk)
      fill_readdatavalid_r<=fill_readdatavalid;
    always@(posedge clk)
      fill_readdata_r<=fill_readdata;
    always@(posedge clk)  
      fill_readdata_addr_r<=fill_readdata_addr;
  end
  endgenerate
  assign fill_addr = fill_cc_addr >> $clog2(MWIDTH/WIDTH);
  acl_multireadport_mem 
  #(
    .LOG2DEPTH(LOG2NUMCACHEENTRIES),
    .WIDTH(1),
    .NUMPORTS(NUMPORTS),
    .USE2XCLOCK(USE2XCLOCK),
    .DEDICATED_BROADCAST_PORT(1)
  )
  valid (
    .clk(clk),
    .clk2x(clk2x),
    .resetn(resetn),
    .broadcast_addr(valid_addr),
    .broadcast_writedata(valid_writedata),
    .broadcast_read(),
    .broadcast_write(valid_write),
    .rdport_addr(cache_addr),
    .rdport_read(cache_read),
    .rdport_waitrequest(cache_waitrequest),
    .rdport_readdatavalid(),
    .rdport_readdata(cache_valid)
  );
  acl_multireadport_mem 
  #(
    .LOG2DEPTH(LOG2NUMCACHEENTRIES),
    .WIDTH(TAGSIZE),
    .NUMPORTS(NUMPORTS),
    .USE2XCLOCK(USE2XCLOCK),
    .DEDICATED_BROADCAST_PORT(1)
  )
  tag (
    .clk(clk),
    .clk2x(clk2x),
    .resetn(resetn),
    .broadcast_addr(fill_readdata_addr_r[`OFFSETRANGE]),
    .broadcast_writedata(fill_readdata_addr_r[`TAGRANGE]),
    .broadcast_write(fill_readdatavalid_r),
    .rdport_addr(cache_addr),
    .rdport_read(cache_read),
    .rdport_waitrequest(),
    .rdport_readdatavalid(),
    .rdport_readdata(cache_tagout)
  );
  acl_multireadport_mem 
  #(
    .LOG2DEPTH(LOG2NUMCACHEENTRIES), 
    .WIDTH(WIDTH),
    .NUMPORTS(NUMPORTS),
    .USE2XCLOCK(USE2XCLOCK),
    .DEDICATED_BROADCAST_PORT(1)
  )
  data (
    .clk(clk),
    .clk2x(clk2x),
    .resetn(resetn),
    .broadcast_addr(fill_readdata_addr_r[`OFFSETRANGE]),
    .broadcast_writedata(fill_readdata_r),
    .broadcast_write(fill_readdatavalid_r),
    .rdport_addr(cache_addr),
    .rdport_read(cache_read),
    .rdport_waitrequest(),
    .rdport_readdatavalid(cache_readdatavalid),
    .rdport_readdata(cache_readdata)
  );
  scfifo  scfifo_component (
    .clock (clk),
    .data (fill_cc_addr),
    .rdreq ((fill_readdatavalid)),
    .sclr (),
    .wrreq ((fill_read&~fill_waitrequest)),
    .empty (),
    .full (),
    .q (fill_readdata_addr),
    .aclr (~resetn),
    .almost_empty (),
    .almost_full (),
    .usedw ());
  defparam
    scfifo_component.add_ram_output_register = "OFF",
    scfifo_component.intended_device_family = "Stratix IV",
    scfifo_component.lpm_numwords = DEVICE_BLOCKRAM_BITS/AWIDTH,
    scfifo_component.lpm_showahead = "ON",
    scfifo_component.lpm_type = "scfifo",
    scfifo_component.lpm_width = AWIDTH,
    scfifo_component.lpm_widthu = $clog2(DEVICE_BLOCKRAM_BITS/AWIDTH),
    scfifo_component.overflow_checking = "ON",
    scfifo_component.underflow_checking = "ON",
    scfifo_component.use_eab = "ON";
  integer pa;
  always@*
  begin
    upstream_arb_addr={NUMPORTS*AWIDTH{1'b0}};
    upstream_arb_read={NUMPORTS{1'b0}};
    for (pa=NUMPORTS-1; pa>=0; pa=pa-1)
    begin
      upstream_arb_addr={NUMPORTS*AWIDTH{1'b0}} | 
        (upstream_arb_addr<<AWIDTH) | 
        miss_addr[pa];
      upstream_arb_read={NUMPORTS{1'b0}} | (upstream_arb_read<<1) | 
        (miss_read[pa]);
    end
  end
  cachefill_arbiter #(.WIDTH(AWIDTH), .NUMPORTS(NUMPORTS)) arb (
      .clk(clk),
      .resetn(resetn),
      .addr(upstream_arb_addr),
      .read(upstream_arb_read),
      .waitrequest(miss_waitrequest),
      .fill_addr(fill_cc_addr),
      .fill_read(fill_read),
      .fill_waitrequest(fill_waitrequest));
  assign do_flush = (flush_counter==0 && (flush_cache || flush_overflow));
  always@(posedge clk or negedge resetn)
    if (!resetn)
      flush_counter<={LOG2NUMCACHEENTRIES{1'b0}};
    else if (do_flush)
      flush_counter<={LOG2NUMCACHEENTRIES{1'b1}};
    else if (flush_counter!=0 && valid_sel==s_FLUSH)
      flush_counter<=flush_counter-1;
  always@(posedge clk)
    flushing<=do_flush || !(flush_counter==0);
  acl_snoop 
  #(
    .LOG2SIZE(LOG2SIZE),
    .LOG2WIDTH(LOG2WIDTH),
    .AWIDTH(AWIDTH),
    .WIDTH(WIDTH),
    .BURSTWIDTH(SNOOP_BURSTWIDTH)
  ) snoop_datapath (
    .clk(clk),
    .resetn(resetn),
    .flush(flushing),
    .fill_readdata_addr(fill_readdata_addr_r),
    .fill_readdatavalid(fill_readdatavalid_r),
    .snoop_clk(snoop_clk),
    .snoop_overflow(snoop_overflow),
    .snoop_addr({64'b0,snoop_addr} * MWIDTH/WIDTH),
    .snoop_burst(snoop_burst * MWIDTH/WIDTH),
    .snoop_valid(snoop_write),
    .snoop_stall(snoop_stall),
    .invalidate_addr(invalidate_addr),
    .invalidate_en(invalidate_en),
    .invalidate_waitrequest((valid_sel!=s_INVALIDATE)),
    .overflow(flush_overflow));
  assign snoop_ready = ~snoop_stall;
  assign valid_sel = (fill_readdatavalid_r) ? s_FILL : 
                        (flushing) ? s_FLUSH : s_INVALIDATE;
  always@*
    valid_addr<= (valid_sel==s_FLUSH) ? flush_counter : 
                    (valid_sel==s_INVALIDATE) ? invalidate_addr :
                      fill_readdata_addr_r[`OFFSETRANGE];
  always@*
    valid_write<= (valid_sel==s_FLUSH) ? 1'b1 :
                    (valid_sel==s_INVALIDATE) ? invalidate_en :
                      fill_readdatavalid_r;
  always@*
    valid_writedata<= (valid_sel==s_FLUSH) ? 1'b0 :
                    (valid_sel==s_INVALIDATE) ? 1'b0 : 1'b1;
endmodule
module cachefill_arbiter #(parameter WIDTH=32, parameter NUMPORTS=4)
( 
  input  clk,
  input  resetn,
  input  [NUMPORTS*WIDTH-1:0] addr,
  input  [NUMPORTS-1:0] read,
  output [NUMPORTS-1:0] waitrequest,
  output [WIDTH-1:0] fill_addr,
  output fill_read,
  input  fill_waitrequest
);
  reg  [(NUMPORTS+1)*WIDTH-1:0] queued_addr;
  reg  [(NUMPORTS+1)-1:0] queued_read;
  generate
  genvar p;
    for (p=0; p<NUMPORTS; p=p+1)
    begin : port_gen
      always@(posedge clk or negedge resetn)
        if (!resetn)
        begin
          queued_addr[p*WIDTH +: WIDTH]<=0;
          queued_read[p]<=0;
        end
        else if (fill_waitrequest && !queued_read[p])
        begin
          queued_addr[p*WIDTH +: WIDTH]<=addr[p*WIDTH +: WIDTH];
          queued_read[p]<=read[p];
        end
        else if (!fill_waitrequest)
          if (!queued_read[p+1])
          begin
            queued_addr[p*WIDTH +: WIDTH]<=addr[p*WIDTH +: WIDTH];
            queued_read[p]<=read[p];
          end
          else
          begin
            queued_addr[p*WIDTH +: WIDTH]<=queued_addr[(p+1)*WIDTH +: WIDTH];
            queued_read[p]<=queued_read[p+1];
          end
    end
  endgenerate
  always@(posedge clk) queued_read[NUMPORTS]=1'b0;
  always@(posedge clk) queued_addr[NUMPORTS*WIDTH +: WIDTH]=0;
  assign fill_addr=queued_addr[WIDTH-1:0];
  assign fill_read=queued_read[0];
  assign waitrequest=(fill_waitrequest) ? queued_read : queued_read>>1;
endmodule
module pipe(
    d,
    clk,
    resetn,
    en,
    squash,
    q
    );
parameter WIDTH=32;
parameter DEPTH=1;
parameter RESETVALUE={WIDTH{1'b0}};
input [WIDTH-1:0]  d;
input              clk;
input              resetn;
input  [DEPTH-1:0] en;
input  [DEPTH-1:0] squash;
output [WIDTH*DEPTH-1:0] q;
reg [WIDTH*DEPTH-1:0] q;
integer i;
  always@(posedge clk or negedge resetn)
  begin
    if ( !resetn )
      q[ WIDTH-1:0 ]<=RESETVALUE;
    else if ( squash[0] )
      q[ WIDTH-1:0 ]<=RESETVALUE;
    else if (en[0])
      q[ WIDTH-1:0 ]<=d;
    for (i=1; i<DEPTH; i=i+1)
      if (!resetn)
        q[i*WIDTH +: WIDTH ]<=RESETVALUE;
      else if ( squash[i] )
        q[i*WIDTH +: WIDTH ]<=RESETVALUE;
      else if (en[i])
        q[i*WIDTH +: WIDTH ]<=q[(i-1)*WIDTH +: WIDTH ];
  end
endmodule
