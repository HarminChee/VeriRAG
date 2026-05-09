`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module xlr8_xf #(
                 parameter STGI_XF_CTRL_ADR   = 8'h10,
                 parameter STGI_XF_STATUS_ADR = 8'h11,
                 parameter STGI_XF_R0_ADR     = 8'h0C, 
                 parameter STGI_XF_R1_ADR     = 8'h0D,
                 parameter STGI_XF_R2_ADR     = 8'h0E,
                 parameter STGI_XF_R3_ADR     = 8'h0F,
                 parameter STGI_XF_PRELOAD_DELTA = 8'h03,
                 parameter STGI_XF_P0_LATENCY = 8'h01,    
                 parameter STGI_XF_P1_LATENCY = 8'h02,    
                 parameter STGI_XF_P2_LATENCY = 8'h05,    
                 parameter STGI_XF_P3_LATENCY = 8'h03,    
                 parameter STGI_XF_P4_LATENCY = 8'h1C,    
                 parameter STGI_XF_P5_LATENCY = 8'h06,    
                 parameter STGI_XF_P6_LATENCY = 8'h01,    
                 parameter STGI_XF_P7_LATENCY = 8'h01     
         )
   (cp2,
    ireset,
    adr,
    dbus_in,
    dbus_out,
    iore,
    iowe,
    out_en,
    core_ramadr,
    core_ramre,
    core_ramwe,
    core_dm_sel,
    gprf,
    xf_dataa,
    xf_datab,
    xf_en,
    xf_p0_result,
    xf_p1_result,
    xf_p2_result,
    xf_p3_result,
    xf_p4_result,
    xf_p5_result,
    xf_p6_result,
    xf_p7_result
    );
   input               ireset;
   input               cp2;
   input [5:0]         adr;
   input [7:0]         dbus_in;
   output[7:0]         dbus_out;
   input               iore;
   input               iowe;
   output              out_en;
   input [7:0]         core_ramadr;
   input               core_ramre;
   input               core_ramwe;
   input               core_dm_sel;
   input [8*32-1:0]     gprf;
   output [31:0]        xf_dataa;
   output [31:0]        xf_datab;
   output [7:0]         xf_en;          
   input [31:0]         xf_p0_result;
   input [31:0]         xf_p1_result;
   input [31:0]         xf_p2_result;
   input [31:0]         xf_p3_result;
   input [31:0]         xf_p4_result;
   input [31:0]         xf_p5_result;
   input [31:0]         xf_p6_result;
   input [31:0]         xf_p7_result;
   localparam STGI_XF_P0_CMD  = 3'h0;
   localparam STGI_XF_P1_CMD  = 3'h1;
   localparam STGI_XF_P2_CMD  = 3'h2;
   localparam STGI_XF_P3_CMD  = 3'h3;
   localparam STGI_XF_P4_CMD  = 3'h4;
   localparam STGI_XF_P5_CMD  = 3'h5;
   localparam STGI_XF_P6_CMD  = 3'h6;
   localparam STGI_XF_P7_CMD  = 3'h7;
   localparam CTRL_DM_LOC   = (STGI_XF_CTRL_ADR   >= 16'h60) ? 1 : 0;
   localparam STATUS_DM_LOC = (STGI_XF_STATUS_ADR >= 16'h60) ? 1 : 0;
   localparam R_DM_LOC      = (STGI_XF_R0_ADR     >= 16'h60) ? 1 : 0;
   logic [31:0]         result; 
   logic [7:0]  ctrl_reg;
   logic [7:0]  status_reg;
   logic [31:0] xf_dataa;
   logic [31:0] xf_datab;
   logic [7:0]  xf_sel;
   logic [2:0]  current_cmd;
   logic [7:0]  port_complete;
   logic        fp_complete;
   logic        function_start;
   logic        function_active;
   logic [7:0]  result_tc;
   logic ctrl_adr;
   logic status_adr;
   logic r0_adr;
   logic r1_adr;
   logic r2_adr;
   logic r3_adr;
   logic ctrl_re;
   logic ctrl_we;
   logic status_re;
   logic r0_re;
   logic r1_re;
   logic r2_re;
   logic r3_re;
   logic [7:0]         xf_en;          
   assign ctrl_adr   = CTRL_DM_LOC   ? 
                       (core_dm_sel && core_ramadr == STGI_XF_CTRL_ADR) :
                       ({2'h0,adr} == STGI_XF_CTRL_ADR);
   assign status_adr = STATUS_DM_LOC ? 
                       (core_dm_sel && core_ramadr == STGI_XF_STATUS_ADR) :
                       ({2'h0,adr} == STGI_XF_STATUS_ADR);
   assign r0_adr    = R_DM_LOC     ? 
                       (core_dm_sel && core_ramadr == STGI_XF_R0_ADR) :
                       ({2'h0,adr} == STGI_XF_R0_ADR);
   assign r1_adr    = R_DM_LOC     ? 
                       (core_dm_sel && core_ramadr == STGI_XF_R1_ADR) :
                       ({2'h0,adr} == STGI_XF_R1_ADR);
   assign r2_adr     = R_DM_LOC      ? 
                       (core_dm_sel && core_ramadr == STGI_XF_R2_ADR) :
                       ({2'h0,adr} == STGI_XF_R2_ADR);
   assign r3_adr     = R_DM_LOC      ? 
                       (core_dm_sel && core_ramadr == STGI_XF_R3_ADR) :
                       ({2'h0,adr} == STGI_XF_R3_ADR);
   assign ctrl_re   = ctrl_adr   && (CTRL_DM_LOC   ? core_ramre : iore);
   assign ctrl_we   = ctrl_adr   && (CTRL_DM_LOC   ? core_ramwe : iowe);
   assign status_re = status_adr && (STATUS_DM_LOC ? core_ramre : iore);
   assign r0_re     = r0_adr     && (R_DM_LOC      ? core_ramre : iore);
   assign r1_re     = r1_adr     && (R_DM_LOC      ? core_ramre : iore);
   assign r2_re     = r2_adr     && (R_DM_LOC      ? core_ramre : iore);
   assign r3_re     = r3_adr     && (R_DM_LOC      ? core_ramre : iore);
   assign dbus_out = ({8{ctrl_re}}   & ctrl_reg)        |
                     ({8{status_re}} & status_reg)      |
                     ({8{r0_re}}     & result[7:0])     |
                     ({8{r1_re}}     & result[15:8])    |
                     ({8{r2_re}}     & result[23:16])   |
                     ({8{r3_re}}     & result[31:24]);
   assign out_en   = ctrl_re   ||
                     status_re ||
                     r0_re     ||
                     r1_re     ||
                     r2_re     ||
                     r3_re;
   always@(posedge cp2 or negedge ireset) begin: ctrlreg
      if (!ireset) begin
         ctrl_reg <= 8'h00;
      end
      else begin
         ctrl_reg <= (ctrl_we) ? {1'b0, dbus_in[6:0]} : ctrl_reg;
      end
   end
   assign current_cmd = (ctrl_we) ? dbus_in[2:0] : ctrl_reg[2:0];
   assign function_start = ctrl_we & (dbus_in[6] == 1'b1);
   always@(posedge cp2 or negedge ireset)
     begin
        if (!ireset) begin
           function_active <= 1'h0;
        end
        else begin
           if (function_start && ~fp_complete) begin
              function_active <= 1'b1;
           end else if (fp_complete) begin
              function_active = 1'b0;
           end
        end
     end
   always@(posedge cp2 or negedge ireset)
     begin
        if (!ireset) begin
           status_reg <= 8'h00;
        end
        else begin
           if (fp_complete) begin
              status_reg[7] <= 1'b1;
              status_reg[6] <= ~|xf_sel; 
              status_reg[5:0] <= 6'h0;
           end else if (function_start) begin 
              status_reg <= 8'h00;
           end else if (dbus_out[7] && status_re) begin 
              status_reg[7] <= 1'b0;
           end
        end 
     end 
   always@(posedge cp2 or negedge ireset)
     begin
        if (!ireset) begin
           xf_dataa <= 32'h00000000;
           xf_datab <= 32'h00000000;
        end
        else begin   
           xf_dataa <= gprf[22*8 +: 4*8];
           xf_datab <= gprf[18*8 +: 4*8];
        end
     end 
   always_comb begin
      xf_sel[0] = (current_cmd == STGI_XF_P0_CMD) && (STGI_XF_P0_LATENCY != 8'd0);
      xf_sel[1] = (current_cmd == STGI_XF_P1_CMD) && (STGI_XF_P1_LATENCY != 8'd0);
      xf_sel[2] = (current_cmd == STGI_XF_P2_CMD) && (STGI_XF_P2_LATENCY != 8'd0);
      xf_sel[3] = (current_cmd == STGI_XF_P3_CMD) && (STGI_XF_P3_LATENCY != 8'd0);
      xf_sel[4] = (current_cmd == STGI_XF_P4_CMD) && (STGI_XF_P4_LATENCY != 8'd0);
      xf_sel[5] = (current_cmd == STGI_XF_P5_CMD) && (STGI_XF_P5_LATENCY != 8'd0);
      xf_sel[6] = (current_cmd == STGI_XF_P6_CMD) && (STGI_XF_P6_LATENCY != 8'd0);
      xf_sel[7] = (current_cmd == STGI_XF_P7_CMD) && (STGI_XF_P7_LATENCY != 8'd0);
   end
   always_comb xf_en = xf_sel & {8{function_start}};
   always_comb begin
      port_complete[0] = (((STGI_XF_PRELOAD_DELTA >= STGI_XF_P0_LATENCY) && function_start) ||
                          ((result_tc == STGI_XF_P0_LATENCY) && function_active)) && 
                         (current_cmd == STGI_XF_P0_CMD);
      port_complete[1] = (((STGI_XF_PRELOAD_DELTA >= STGI_XF_P1_LATENCY) && function_start) ||
                          ((result_tc == STGI_XF_P1_LATENCY) && function_active)) && 
                         (current_cmd == STGI_XF_P1_CMD);
      port_complete[2] = (((STGI_XF_PRELOAD_DELTA >= STGI_XF_P2_LATENCY) && function_start) ||
                          ((result_tc == STGI_XF_P2_LATENCY) && function_active)) && 
                         (current_cmd == STGI_XF_P2_CMD);
      port_complete[3] = (((STGI_XF_PRELOAD_DELTA >= STGI_XF_P3_LATENCY) && function_start) ||
                          ((result_tc == STGI_XF_P3_LATENCY) && function_active)) && 
                         (current_cmd == STGI_XF_P3_CMD);
      port_complete[4] = (((STGI_XF_PRELOAD_DELTA >= STGI_XF_P4_LATENCY) && function_start) ||
                          ((result_tc == STGI_XF_P4_LATENCY) && function_active)) && 
                         (current_cmd == STGI_XF_P4_CMD);
      port_complete[5] = (((STGI_XF_PRELOAD_DELTA >= STGI_XF_P5_LATENCY) && function_start) ||
                          ((result_tc == STGI_XF_P5_LATENCY) && function_active)) && 
                         (current_cmd == STGI_XF_P5_CMD);
      port_complete[6] = (((STGI_XF_PRELOAD_DELTA >= STGI_XF_P6_LATENCY) && function_start) ||
                          ((result_tc == STGI_XF_P6_LATENCY) && function_active)) && 
                         (current_cmd == STGI_XF_P6_CMD);
      port_complete[7] = (((STGI_XF_PRELOAD_DELTA >= STGI_XF_P7_LATENCY) && function_start) ||
                          ((result_tc == STGI_XF_P7_LATENCY) && function_active)) && 
                         (current_cmd == STGI_XF_P7_CMD);
   end
   assign fp_complete = |port_complete;
   always@(posedge cp2 or negedge ireset)
     begin: resulttimingchain
        if (!ireset) begin
           result_tc <= STGI_XF_PRELOAD_DELTA;
           result <= 32'h00000000;
        end
        else begin
           if ((result_tc > STGI_XF_PRELOAD_DELTA) || function_start) begin 
                result_tc <= result_tc + 1;
           end
           if (fp_complete) begin: snagresults
              result_tc <= STGI_XF_PRELOAD_DELTA;
              case (port_complete)
                8'h01: result <= xf_p0_result;
                8'h02: result <= xf_p1_result;
                8'h04: result <= xf_p2_result;
                8'h08: result <= xf_p3_result;
                8'h10: result <= xf_p4_result;
                8'h20: result <= xf_p5_result;
                8'h40: result <= xf_p6_result;
                8'h80: result <= xf_p7_result;
                default: result <= result;
              endcase 
           end 
        end
     end 
   wire _unused_ok = &{1'b0,
                       gprf[255:208],gprf[143:0], 
                       1'b0};
endmodule 
