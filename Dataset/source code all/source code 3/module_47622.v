`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module sfa_bif(
  output wire             bram_clk      ,
  output wire             bram_rst      ,
  output reg              bram_en       ,
  output reg   [ 3 : 0]   bram_we       ,
  output wire  [31 : 0]   bram_addr     ,
  output wire  [31 : 0]   bram_din      ,
  input  wire  [31 : 0]   bram_dout     ,
  output wire             sBIF_tready   ,
  input  wire             sBIF_tvalid   ,
  input  wire  [31 : 0]   sBIF_tdata    ,
  input  wire             mBIF_tready   ,
  output wire             mBIF_tvalid   ,
  output wire  [31 : 0]   mBIF_tdata    ,
  input  wire             ap_start      ,
  output reg              ap_done       ,
  output reg              ap_idle       ,
  input  wire             MODE          ,
  input  wire  [23 : 0]   INDEX         ,
  input  wire  [23 : 0]   SIZE          ,
  input  wire  [23 : 0]   STRIDE        ,
  input  wire             ACLK          ,
  input  wire             ARESETN
);
localparam IDEL            = 5'b10000; 
localparam BRAM_READ       = 5'b01000; 
localparam AXIs_SEND       = 5'b00100; 
localparam BRAM_WRITE      = 5'b00010; 
localparam AXIs_Receive    = 5'b00001; 
reg   [ 4 : 0]   state          ;
reg   [15 : 0]   i_reg          ;
wire             condition      ;
wire   [23 : 0]  wINDEX         ;
wire   [23 : 0]  wSIZE          ;
wire   [23 : 0]  wbound         ;
assign wINDEX = $signed(INDEX);
assign wSIZE  = $signed(SIZE);
assign wbound = wINDEX + wSIZE;
assign condition = (i_reg == wbound ? 1'b1 : 1'b0);
assign bram_clk            = ACLK       ;
assign bram_rst            = ~ARESETN   ;
assign bram_din            = sBIF_tdata ;
assign mBIF_tdata          = bram_dout  ;
assign bram_addr           = i_reg << 32'd2;
assign mBIF_tvalid         = (state == AXIs_SEND) ;
assign sBIF_tready         = (state == AXIs_Receive);
always @(posedge ACLK) begin
  if ((state == IDEL) & (ap_start == 0)) begin
    i_reg <= wINDEX;
  end
  else if ((state == BRAM_READ | state == BRAM_WRITE) & (condition != 1)) begin
    i_reg <= i_reg + 1;
  end
end
always @(state or condition) begin
  if ((ap_start != 1) & (state == IDEL)) begin
    ap_idle = 1;
  end
  else begin
    ap_idle = 0;
  end
end
always @(state or condition) begin
  if (ap_start == 1 & SIZE == 24'd0) begin
    ap_done  = 1;
  end
  else if ((state == BRAM_READ | state == AXIs_Receive) & (condition == 1)) begin
    ap_done = 1;
  end
  else begin
    ap_done = 0;
  end
end
always @(state or ap_done) begin
  if ((state == BRAM_READ | state == AXIs_Receive) & (ap_done != 1)) begin
    bram_en = 1;
  end
  else begin
    bram_en = 0;
  end
end
always @(state or ap_done) begin
  if (state == AXIs_Receive & ap_done != 1) begin
    bram_we = 4'hF;
  end
  else begin
    bram_we = 4'h0;
  end
end
always @(posedge ACLK) begin
  if (!ARESETN) begin
    state <= IDEL;
  end
  else begin
    case (state)
      IDEL: begin
        if (ap_start) begin
          if (!MODE) begin
            state <= BRAM_READ;
          end
          else begin
            state <= AXIs_Receive;
          end
        end
      end
      BRAM_READ: begin
        if (condition != 1) begin
          state <= AXIs_SEND;
        end
        else begin
          state <= IDEL;
        end
      end
      AXIs_SEND: begin
        if (mBIF_tready == 1) begin
          state <= BRAM_READ;
        end
        else begin
          state <= AXIs_SEND;
        end
      end
      AXIs_Receive: begin
        if (condition != 1) begin
          if (sBIF_tvalid == 1) begin
            state     <= BRAM_WRITE;
          end
          else begin
            state <= AXIs_Receive;
          end
        end
        else begin
          state <= IDEL;
        end
      end
      BRAM_WRITE: begin
        state <= AXIs_Receive;
      end
    endcase
  end
end
endmodule
