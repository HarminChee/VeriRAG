module ctrl_flash #(
  parameter FAW = 22,             
  parameter FDW = 8,              
  parameter QAW = 22,             
  parameter QDW = 32,             
  parameter QSW = QDW/8,          
  parameter DLY = 3,              
  parameter BE  = 1               
)(
  input  wire           clk,
  input  wire           rst,
  input  wire           boot_sel,
  input  wire [QAW-1:0] adr,
  input  wire           cs,
  input  wire           we,
  input  wire [QSW-1:0] sel,
  input  wire [QDW-1:0] dat_w,
  output reg  [QDW-1:0] dat_r,
  output reg            ack,
  output wire           err,
  output reg  [FAW-1:0] fl_adr,
  output reg            fl_ce_n,
  output reg            fl_we_n,
  output reg            fl_oe_n,
  output reg            fl_rst_n,
  output wire [FDW-1:0] fl_dat_w,
  input  wire [FDW-1:0] fl_dat_r
);
reg            nce;
reg            nwe;
reg            noe;
reg            nrst;
always @ (posedge clk, posedge rst) begin
  if (rst) begin
    fl_ce_n  <= #1 1'b1;
    fl_we_n  <= #1 1'b1;
    fl_oe_n  <= #1 1'b0;
    fl_rst_n <= #1 1'b0;
  end else begin
    fl_ce_n  <= #1 1'b0;
    fl_we_n  <= #1 1'b1; 
    fl_oe_n  <= #1 1'b0; 
    fl_rst_n <= #1 1'b1;
  end
end
reg            timer_start;
reg  [  2-1:0] timer;
always @ (posedge clk, posedge rst) begin
  if (rst)
    timer <= #1 2'h0;
  else if (timer_start)
    timer <= #1 DLY-1;
  else if (|timer)
    timer <= #1 timer - 2'h1;
end
localparam S_ID = 3'h0;
localparam S_R1 = 3'h4;
localparam S_R2 = 3'h5;
localparam S_R3 = 3'h6;
localparam S_R4 = 3'h7;
reg  [   3-1:0] state;
always @ (posedge clk, posedge rst) begin
  if (rst) begin
    state <= #1 S_ID;
    timer_start <= #1 1'b0;
    ack <= #1 1'b0;
  end else begin
    if (timer_start) timer_start <= #1 1'b0;
    case (state)
      S_ID : begin
        if (cs) begin
          fl_adr <= #1 {boot_sel^adr[21], adr[20:2], 2'b00};
          timer_start <= #1 1'b1;
          state <= #1 S_R1;
        end
      end
      S_R1 : begin
        if ((~|timer) && !timer_start) begin
          fl_adr <= #1 {boot_sel^adr[21], adr[20:2], 2'b01};
          timer_start <= #1 1'b1;
          state <= #1 S_R2;
          if (BE == 1)
            dat_r[31:24] <= #1 fl_dat_r;
          else
            dat_r[ 7: 0] <= #1 fl_dat_r;
        end
      end
      S_R2 : begin
        if ((~|timer) && !timer_start) begin
          fl_adr <= #1 {boot_sel^adr[21], adr[20:2], 2'b10};
          timer_start <= #1 1'b1;
          state <= #1 S_R3;
          if (BE == 1)
            dat_r[23:16] <= #1 fl_dat_r;
          else
            dat_r[15: 8] <= #1 fl_dat_r;
        end
      end
      S_R3 : begin
        if ((~|timer) && !timer_start) begin
          fl_adr <= #1 {boot_sel^adr[21], adr[20:2], 2'b11};
          timer_start <= #1 1'b1;
          state <= #1 S_R4;
          if (BE == 1)
            dat_r[15: 8] <= #1 fl_dat_r;
          else
            dat_r[23:16] <= #1 fl_dat_r;
        end
      end
      S_R4 : begin
        if (timer == 2'h1) begin
          ack <= #1 1'b1;
        end
        if ((~|timer) && !timer_start) begin
          state <= #1 S_ID;
          ack <= #1 1'b0;
          if (BE == 1)
            dat_r[ 7: 0] <= #1 fl_dat_r;
          else
            dat_r[31:24] <= #1 fl_dat_r;
        end
      end
    endcase
  end
end
assign err      = 1'b0;
assign fl_dat_w = 8'hxx;
endmodule
