module control_registers
(
    input              up_rstn,
    input              up_clk,
    input              up_wreq,
    input      [13:0]  up_waddr,
    input      [31:0]  up_wdata,
    output reg         up_wack,
    input              up_rreq,
    input      [13:0]  up_raddr,
    output reg [31:0]  up_rdata,
    output reg         up_rack,
    input  [31:0]  err_i,
    output [10:0]  pwm_open_o,
    output [31:0]  reference_speed_o,
    output [31:0]  kp_o,
    output [31:0]  ki_o,
    output [31:0]  kd_o,
    output [31:0]  kp1_o,
    output [31:0]  ki1_o,
    output [31:0]  kd1_o,
    output         run_o,
    output         break_o,
    output         dir_o,
    output         star_delta_o,
    output [ 1:0]  sensors_o,
    output [ 3:0]  gpo_o,
    output         oloop_matlab_o,
    output         calibrate_adcs_o
);
reg [31:0] control_r;
reg [31:0] reference_speed_r;
reg [31:0] kp_r;
reg [31:0] ki_r;
reg [31:0] kp1_r;
reg [31:0] ki1_r;
reg [31:0] kd1_r;
reg [31:0] pwm_open_r;
reg [31:0] pwm_break_r;
reg [31:0] status_r;
reg [31:0] reserved_r1;
reg [31:0] kd_r;
reg [10:0] gpo_r;
wire        up_wreq_s;
wire        up_rreq_s;
assign up_wreq_s = (up_waddr[13:4] == 10'h00) ? up_wreq : 1'b0;
assign up_rreq_s = (up_raddr[13:4] == 10'h00) ? up_rreq : 1'b0;
assign run_o                    = control_r[0];     
assign break_o                  = control_r[2];     
assign dir_o                    = control_r[3];     
assign star_delta_o             = control_r[4];     
assign sensors_o                = control_r[9:8];   
assign calibrate_adcs_o         = control_r[16];
assign oloop_matlab_o           = control_r[12];    
assign gpo_o                    = control_r[23:20];
assign pwm_open_o               = pwm_open_r[10:0];       
assign reference_speed_o        = reference_speed_r;
assign kp_o                     = kp_r;             
assign ki_o                     = ki_r;             
assign kd_o                     = kd_r;             
assign kp1_o                    = kp1_r;
assign kd1_o                    = kd1_r;
assign ki1_o                    = ki1_r;
always @(negedge up_rstn or posedge up_clk)
begin
   if (up_rstn == 0)
   begin
       up_wack              <= 1'b0;
       control_r            <= 'h0;
       reference_speed_r    <= 'd1000;
       kp_r                 <= 'd6554;
       ki_r                 <= 'd26;
       kd_r                 <= 'd655360;
       kp1_r                <= 'd0;
       ki1_r                <= 'd0;
       kd1_r                <= 'd0;
       pwm_open_r           <= 'h5ff;
       pwm_break_r          <= 'd0;
       status_r             <= 'd0;
   end
   else
   begin
       up_wack  <= up_wreq_s;
       if ((up_wreq_s == 1'b1) && (up_waddr[3:0] == 4'h3))
       begin
           reserved_r1          <= up_wdata;
       end
       if ((up_wreq_s == 1'b1) && (up_waddr[3:0] == 4'h4))
       begin
           control_r            <= up_wdata;
       end
       if ((up_wreq_s == 1'b1) && (up_waddr[3:0] == 4'h5))
       begin
           reference_speed_r    <= up_wdata;
       end
       if ((up_wreq_s == 1'b1) && (up_waddr[3:0] == 4'h6))
       begin
           kp_r                 <= up_wdata;
       end
       if ((up_wreq_s == 1'b1) && (up_waddr[3:0] == 4'h7))
       begin
           ki_r                 <= up_wdata;
       end
       if ((up_wreq_s == 1'b1) && (up_waddr[3:0] == 4'h8))
       begin
           kd_r                 <= up_wdata;
       end
       if ((up_wreq_s == 1'b1) && (up_waddr[3:0] == 4'h9))
       begin
           kp1_r                <= up_wdata;
       end
       if ((up_wreq_s == 1'b1) && (up_waddr[3:0] == 4'ha))
       begin
           ki1_r                <= up_wdata;
       end
       if ((up_wreq_s == 1'b1) && (up_waddr[3:0] == 4'hb))
       begin
           kd1_r                <= up_wdata;
       end
       if ((up_wreq_s == 1'b1) && (up_waddr[3:0] == 4'hc))
       begin
           pwm_open_r          <= up_wdata;
       end
       if ((up_wreq_s == 1'b1) && (up_waddr[3:0] == 4'hd))
       begin
           pwm_break_r         <= up_wdata;
       end
       if ((up_wreq_s == 1'b1) && (up_waddr[3:0] == 4'he))
       begin
           status_r            <= up_wdata;
       end
   end
end
always @(negedge up_rstn or posedge up_clk)
begin
    if (up_rstn == 0) begin
        up_rack <= 'd0;
        up_rdata <= 'd0;
    end
    else
    begin
        up_rack <= up_rreq_s;
        if (up_rreq_s == 1'b1) begin
            case (up_raddr[3:0])
                4'h3: up_rdata <= reserved_r1;
                4'h4: up_rdata <= control_r;
                4'h5: up_rdata <= reference_speed_r;
                4'h6: up_rdata <= kp_r;
                4'h7: up_rdata <= ki_r;
                4'h8: up_rdata <= kd_r;
                4'h9: up_rdata <= kp1_r;
                4'ha: up_rdata <= ki1_r;
                4'hb: up_rdata <= kd1_r;
                4'hc: up_rdata <= pwm_open_r;
                4'hd: up_rdata <= pwm_break_r;
                4'he: up_rdata <= status_r;
                4'hf: up_rdata <= err_i;
                default: up_rdata <= 0;
            endcase
        end
        else
        begin
            up_rdata <= 32'd0;
        end
    end
end
endmodule
