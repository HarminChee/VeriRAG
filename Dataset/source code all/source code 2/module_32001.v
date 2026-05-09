module vga_sync
(
  input  wire       clk,    
  input  wire       rst,
  output wire       hsync,  
  output wire       vsync,  
  output wire       en,     
  output wire [9:0] x,      
  output wire [9:0] y,      
  output wire [9:0] x_next, 
  output wire [9:0] y_next  
);
localparam H_DISP  = 640;  
localparam H_FP    = 16;   
localparam H_RT    = 96;   
localparam H_BP    = 48;   
localparam V_DISP  = 480;  
localparam V_FP    = 10;   
localparam V_RT    = 2;    
localparam V_BP    = 29;   
reg  [1:0] q_mod4_cnt;
reg  [1:0] d_mod4_cnt;
reg  [9:0] q_hcnt, q_vcnt;
reg  [9:0] d_hcnt, d_vcnt;
reg  q_hsync, q_vsync, q_en;
reg  d_hsync, d_vsync, d_en;
always @(posedge clk) begin
  q_mod4_cnt <= d_mod4_cnt;
  q_hcnt     <= d_hcnt;
  q_vcnt     <= d_vcnt;
  q_hsync    <= d_hsync;
  q_vsync    <= d_vsync;
  q_en       <= d_en;
end
wire pix_pulse;     
wire line_pulse;    
wire screen_pulse;  
assign pix_pulse    = (q_mod4_cnt == 0);
assign line_pulse   = pix_pulse  && (q_hcnt == (H_DISP + H_FP + H_RT + H_BP - 1));
assign screen_pulse = line_pulse && (q_vcnt == (V_DISP + V_FP + V_RT + V_BP - 1));
assign hsync  = q_hsync;
assign vsync  = q_vsync;
assign x      = q_hcnt;
assign y      = q_vcnt;
assign x_next = d_hcnt;
assign y_next = (y == (V_DISP + V_FP + V_RT + V_BP - 10'h001)) ? 10'h000 : (q_vcnt + 10'h001);
assign en     = q_en;
always @ (*) begin
  if (rst) begin
    d_mod4_cnt  =   2'b00;
    d_hcnt      =   9'h000;
    d_vcnt      =   9'h000;
    d_hsync     =   1'b0;
    d_en        =   1'b0;
  end
  else begin
    d_mod4_cnt  = q_mod4_cnt + 2'h1;
    d_hcnt      = (line_pulse)   ? 10'h000 : ((pix_pulse)  ? q_hcnt + 10'h001 : q_hcnt);
    d_vcnt      = (screen_pulse) ? 10'h000 : ((line_pulse) ? q_vcnt + 10'h001 : q_vcnt);
    d_hsync     = (q_hcnt >= (H_DISP + H_FP)) && (q_hcnt < (H_DISP + H_FP + H_RT));
    d_vsync     = (q_vcnt >= (V_DISP + V_FP)) && (q_vcnt < (V_DISP + V_FP + V_RT));
    d_en        = (q_hcnt < H_DISP) && (q_vcnt < V_DISP);
  end
end
endmodule
