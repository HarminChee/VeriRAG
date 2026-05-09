`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module mig_7series_v1_9_ddr_phy_tempmon #
(
  parameter TCQ             = 100,      
  parameter BAND1_TEMP_MIN  = 0,        
  parameter BAND2_TEMP_MIN  = 12,       
  parameter BAND3_TEMP_MIN  = 46,       
  parameter BAND4_TEMP_MIN  = 82,       
  parameter TEMP_HYST       = 5
)
(
  input           clk,                  
  input           rst,                  
  input           calib_complete,       
  input           tempmon_sample_en,    
  input   [11:0]  device_temp,          
  output          tempmon_pi_f_inc,     
  output          tempmon_pi_f_dec,     
  output          tempmon_sel_pi_incdec 
);
  localparam HYST_OFFSET = (TEMP_HYST * 4096) / 504;
  localparam BAND1_OFFSET = ((BAND1_TEMP_MIN + 273) * 4096) / 504;
  localparam BAND2_OFFSET = ((BAND2_TEMP_MIN + 273) * 4096) / 504;
  localparam BAND3_OFFSET = ((BAND3_TEMP_MIN + 273) * 4096) / 504;
  localparam BAND4_OFFSET = ((BAND4_TEMP_MIN + 273) * 4096) / 504;
  localparam BAND0_DEC_OFFSET =
    BAND1_OFFSET - HYST_OFFSET > 0    ? BAND1_OFFSET - HYST_OFFSET : 0    ;
  localparam BAND1_INC_OFFSET =
    BAND1_OFFSET + HYST_OFFSET < 4096 ? BAND1_OFFSET + HYST_OFFSET : 4096 ;
  localparam BAND1_DEC_OFFSET =
    BAND2_OFFSET - HYST_OFFSET > 0    ? BAND2_OFFSET - HYST_OFFSET : 0    ;
  localparam BAND2_INC_OFFSET =
    BAND2_OFFSET + HYST_OFFSET < 4096 ? BAND2_OFFSET + HYST_OFFSET : 4096 ;
  localparam BAND2_DEC_OFFSET =
    BAND3_OFFSET - HYST_OFFSET > 0    ? BAND3_OFFSET - HYST_OFFSET : 0    ;
  localparam BAND3_INC_OFFSET =
    BAND3_OFFSET + HYST_OFFSET < 4096 ? BAND3_OFFSET + HYST_OFFSET : 4096 ;
  localparam BAND3_DEC_OFFSET =
    BAND4_OFFSET - HYST_OFFSET > 0    ? BAND4_OFFSET - HYST_OFFSET : 0    ;
  localparam BAND4_INC_OFFSET =
    BAND4_OFFSET + HYST_OFFSET < 4096 ? BAND4_OFFSET + HYST_OFFSET : 4096 ;
  localparam INIT   = 2'b00;
  localparam IDLE   = 2'b01;
  localparam UPDATE = 2'b10;
  localparam WAIT   = 2'b11;
  reg [2:0]                       tempmon_state       = INIT;
  reg [2:0]                       tempmon_next_state  = INIT;
  reg   [11:0]                    previous_temp     = 12'b0;
  reg [2:0]                       target_band       = 3'b000;
  reg [2:0]                       current_band      = 3'b000;
  reg                             pi_f_inc          = 1'b0;
  reg                             pi_f_dec          = 1'b0;
  reg                             sel_pi_incdec     = 1'b0;
  reg                             device_temp_lt_previous_temp = 1'b0;
  reg                             device_temp_gt_previous_temp = 1'b0;
  reg                             device_temp_lt_band1 = 1'b0;
  reg                             device_temp_lt_band2 = 1'b0;
  reg                             device_temp_lt_band3 = 1'b0;
  reg                             device_temp_lt_band4 = 1'b0;
  reg                             device_temp_lt_band0_dec = 1'b0;
  reg                             device_temp_lt_band1_dec = 1'b0;
  reg                             device_temp_lt_band2_dec = 1'b0;
  reg                             device_temp_lt_band3_dec = 1'b0;
  reg                             device_temp_gt_band1_inc = 1'b0;
  reg                             device_temp_gt_band2_inc = 1'b0;
  reg                             device_temp_gt_band3_inc = 1'b0;
  reg                             device_temp_gt_band4_inc = 1'b0;
  reg                             current_band_lt_target_band = 1'b0;
  reg                             current_band_gt_target_band = 1'b0;
  reg                             target_band_gt_1 = 1'b0;
  reg                             target_band_gt_2 = 1'b0;
  reg                             target_band_gt_3 = 1'b0;
  reg                             target_band_lt_1 = 1'b0;
  reg                             target_band_lt_2 = 1'b0;
  reg                             target_band_lt_3 = 1'b0;
  assign tempmon_pi_f_inc = pi_f_inc;
  assign tempmon_pi_f_dec = pi_f_dec;
  assign tempmon_sel_pi_incdec = sel_pi_incdec;
  always @(posedge clk)
    if(rst)
      tempmon_state <= #TCQ INIT;
    else
      tempmon_state <= #TCQ tempmon_next_state;
  always @(tempmon_state or calib_complete or tempmon_sample_en) begin
    tempmon_next_state = tempmon_state;
    case(tempmon_state)
      INIT:
        if(calib_complete)
          tempmon_next_state = IDLE;
      IDLE:
        if(tempmon_sample_en)
          tempmon_next_state = UPDATE;
      UPDATE:
        tempmon_next_state = WAIT;
      WAIT:
        if(~tempmon_sample_en)
          tempmon_next_state = IDLE;
      default:
        tempmon_next_state = INIT;
    endcase
  end
  always @(posedge clk)
    if((tempmon_state == INIT) || (tempmon_state == UPDATE))
      previous_temp <= #TCQ device_temp;
  always @(posedge clk) begin
    device_temp_lt_previous_temp <= #TCQ (device_temp < previous_temp) ? 1'b1 : 1'b0;
    device_temp_gt_previous_temp <= #TCQ (device_temp > previous_temp) ? 1'b1 : 1'b0;     
    device_temp_lt_band1 <= #TCQ (device_temp < BAND1_OFFSET) ? 1'b1 : 1'b0;
    device_temp_lt_band2 <= #TCQ (device_temp < BAND2_OFFSET) ? 1'b1 : 1'b0;
    device_temp_lt_band3 <= #TCQ (device_temp < BAND3_OFFSET) ? 1'b1 : 1'b0;
    device_temp_lt_band4 <= #TCQ (device_temp < BAND4_OFFSET) ? 1'b1 : 1'b0;
    device_temp_lt_band0_dec <= #TCQ (device_temp < BAND0_DEC_OFFSET) ? 1'b1 : 1'b0;
    device_temp_lt_band1_dec <= #TCQ (device_temp < BAND1_DEC_OFFSET) ? 1'b1 : 1'b0;
    device_temp_lt_band2_dec <= #TCQ (device_temp < BAND2_DEC_OFFSET) ? 1'b1 : 1'b0;
    device_temp_lt_band3_dec <= #TCQ (device_temp < BAND3_DEC_OFFSET) ? 1'b1 : 1'b0;
    device_temp_gt_band1_inc <= #TCQ (device_temp > BAND1_INC_OFFSET) ? 1'b1 : 1'b0;
    device_temp_gt_band2_inc <= #TCQ (device_temp > BAND2_INC_OFFSET) ? 1'b1 : 1'b0;
    device_temp_gt_band3_inc <= #TCQ (device_temp > BAND3_INC_OFFSET) ? 1'b1 : 1'b0;
    device_temp_gt_band4_inc <= #TCQ (device_temp > BAND4_INC_OFFSET) ? 1'b1 : 1'b0;
    target_band_gt_1 <= #TCQ (target_band > 3'b001) ? 1'b1 : 1'b0;
    target_band_gt_2 <= #TCQ (target_band > 3'b010) ? 1'b1 : 1'b0;
    target_band_gt_3 <= #TCQ (target_band > 3'b011) ? 1'b1 : 1'b0;
    target_band_lt_1 <= #TCQ (target_band < 3'b001) ? 1'b1 : 1'b0;
    target_band_lt_2 <= #TCQ (target_band < 3'b010) ? 1'b1 : 1'b0;
    target_band_lt_3 <= #TCQ (target_band < 3'b011) ? 1'b1 : 1'b0;
    if(tempmon_state == INIT) begin
      if(device_temp_lt_band1)
        target_band <= #TCQ 3'b000;
      else if(device_temp_lt_band2)
        target_band <= #TCQ 3'b001;
      else if(device_temp_lt_band3)
        target_band <= #TCQ 3'b010;
      else if(device_temp_lt_band4)
        target_band <= #TCQ 3'b011;
      else
        target_band <= #TCQ 3'b100;
    end
    else if(tempmon_state == IDLE) begin
      if(device_temp_gt_previous_temp) begin
        if(device_temp_gt_band4_inc)
          target_band <= #TCQ 3'b100;
        else if(device_temp_gt_band3_inc && target_band_lt_3)
          target_band <= #TCQ 3'b011;
        else if(device_temp_gt_band2_inc && target_band_lt_2)
          target_band <= #TCQ 3'b010;
        else if(device_temp_gt_band1_inc && target_band_lt_1)
          target_band <= #TCQ 3'b001;
      end
      else if(device_temp_lt_previous_temp) begin
        if(device_temp_lt_band0_dec)
          target_band <= #TCQ 3'b000;
        else if(device_temp_lt_band1_dec && target_band_gt_1)
          target_band <= #TCQ 3'b001;
        else if(device_temp_lt_band2_dec && target_band_gt_2)
          target_band <= #TCQ 3'b010;
        else if(device_temp_lt_band3_dec && target_band_gt_3)
          target_band <= #TCQ 3'b011;
      end
    end
  end
  always @(posedge clk) begin
    current_band_lt_target_band = (current_band < target_band) ? 1'b1 : 1'b0;
    current_band_gt_target_band = (current_band > target_band) ? 1'b1 : 1'b0;     
    if(tempmon_state == INIT) begin
      if(device_temp_lt_band1)
        current_band <= #TCQ 3'b000;
      else if(device_temp_lt_band2)
        current_band <= #TCQ 3'b001;
      else if(device_temp_lt_band3)
        current_band <= #TCQ 3'b010;
      else if(device_temp_lt_band4)
        current_band <= #TCQ 3'b011;
      else
        current_band <= #TCQ 3'b100;
    end
    else if(tempmon_state == UPDATE) begin
      if(current_band_lt_target_band)
        current_band <= #TCQ current_band + 1;
      else if(current_band_gt_target_band)
        current_band <= #TCQ current_band - 1;
    end
  end
  always @(posedge clk) begin
    if(rst) begin
      pi_f_inc <= #TCQ 1'b0;
      pi_f_dec <= #TCQ 1'b0;
      sel_pi_incdec <= #TCQ 1'b0;
    end
    else if(tempmon_state == UPDATE) begin
      if(current_band_lt_target_band) begin
        sel_pi_incdec <= #TCQ 1'b1;
        pi_f_dec <= #TCQ 1'b1;
      end
      else if(current_band_gt_target_band) begin
        sel_pi_incdec <= #TCQ 1'b1;
        pi_f_inc <= #TCQ 1'b1;
      end
    end
    else begin
      pi_f_inc <= #TCQ 1'b0;
      pi_f_dec <= #TCQ 1'b0;
      sel_pi_incdec <= #TCQ 1'b0;
    end
  end
endmodule
