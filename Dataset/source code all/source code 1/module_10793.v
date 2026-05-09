`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module mig_7series_v2_0_ddr_phy_tempmon #
(
  parameter TCQ             = 100,      
  parameter TEMP_INCDEC     = 1465,   
  parameter TEMP_HYST       = 1,
  parameter TEMP_MIN_LIMIT  = 12'h8ac,
  parameter TEMP_MAX_LIMIT  = 12'hca4
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
  localparam TEMP_INCDEC_OFFSET = ((TEMP_INCDEC * 4096) / 50400) ;
  localparam IDLE      = 11'b000_0000_0001;
  localparam INIT      = 11'b000_0000_0010;
  localparam FOUR_INC  = 11'b000_0000_0100;
  localparam THREE_INC = 11'b000_0000_1000;
  localparam TWO_INC   = 11'b000_0001_0000;
  localparam ONE_INC   = 11'b000_0010_0000;
  localparam NEUTRAL   = 11'b000_0100_0000;
  localparam ONE_DEC   = 11'b000_1000_0000;
  localparam TWO_DEC   = 11'b001_0000_0000;
  localparam THREE_DEC = 11'b010_0000_0000;
  localparam FOUR_DEC  = 11'b100_0000_0000;
  reg         pi_f_dec;     
  reg         pi_f_inc;     
  reg         pi_f_dec_nxt; 
  reg         pi_f_inc_nxt; 
  reg  [10:0] tempmon_state;
  reg  [10:0] tempmon_state_nxt;
  reg         tempmon_state_init;
  reg         tempmon_init_complete;
  reg  [11:0] four_inc_max_limit;
  reg  [11:0] three_inc_max_limit;
  reg  [11:0] two_inc_max_limit;
  reg  [11:0] one_inc_max_limit;
  reg  [11:0] neutral_max_limit;
  reg  [11:0] one_dec_max_limit;
  reg  [11:0] two_dec_max_limit;
  reg  [11:0] three_dec_max_limit;
  reg  [11:0] three_inc_min_limit;
  reg  [11:0] two_inc_min_limit;
  reg  [11:0] one_inc_min_limit;
  reg  [11:0] neutral_min_limit;
  reg  [11:0] one_dec_min_limit;
  reg  [11:0] two_dec_min_limit;
  reg  [11:0] three_dec_min_limit;
  reg  [11:0] four_dec_min_limit;
  reg  [11:0] device_temp_init;
  reg         tempmon_sample_en_101;
  reg         tempmon_sample_en_102;
  reg  [11:0] device_temp_101;
  reg  [11:0] device_temp_capture_102;
  reg         update_temp_102;
  reg         temp_cmp_four_inc_max_102;
  reg         temp_cmp_three_inc_max_102;
  reg         temp_cmp_two_inc_max_102;
  reg         temp_cmp_one_inc_max_102;
  reg         temp_cmp_neutral_max_102;
  reg         temp_cmp_one_dec_max_102;
  reg         temp_cmp_two_dec_max_102;
  reg         temp_cmp_three_dec_max_102;
  reg         temp_cmp_three_inc_min_102;
  reg         temp_cmp_two_inc_min_102;
  reg         temp_cmp_one_inc_min_102;
  reg         temp_cmp_neutral_min_102;
  reg         temp_cmp_one_dec_min_102;
  reg         temp_cmp_two_dec_min_102;
  reg         temp_cmp_three_dec_min_102;
  reg         temp_cmp_four_dec_min_102;
  wire [11:0] four_inc_max_limit_nxt  = device_temp_init - 7*TEMP_INCDEC_OFFSET; 
  wire [11:0] three_inc_max_limit_nxt = device_temp_init - 5*TEMP_INCDEC_OFFSET;
  wire [11:0] two_inc_max_limit_nxt   = device_temp_init - 3*TEMP_INCDEC_OFFSET;
  wire [11:0] one_inc_max_limit_nxt   = device_temp_init -   TEMP_INCDEC_OFFSET; 
  wire [11:0] neutral_max_limit_nxt   = device_temp_init +   TEMP_INCDEC_OFFSET; 
  wire [11:0] one_dec_max_limit_nxt   = device_temp_init + 3*TEMP_INCDEC_OFFSET;
  wire [11:0] two_dec_max_limit_nxt   = device_temp_init + 5*TEMP_INCDEC_OFFSET;
  wire [12:0] three_dec_max_limit_tmp = device_temp_init + 7*TEMP_INCDEC_OFFSET; 
  wire [11:0] three_dec_max_limit_nxt = three_dec_max_limit_tmp[12] ? 12'hFFF : three_dec_max_limit_tmp[11:0];
  wire [11:0] three_inc_min_limit_nxt = four_inc_max_limit  - HYST_OFFSET; 
  wire [11:0] two_inc_min_limit_nxt   = three_inc_max_limit - HYST_OFFSET;
  wire [11:0] one_inc_min_limit_nxt   = two_inc_max_limit   - HYST_OFFSET;
  wire [11:0] neutral_min_limit_nxt   = one_inc_max_limit   - HYST_OFFSET; 
  wire [11:0] one_dec_min_limit_nxt   = neutral_max_limit   - HYST_OFFSET;
  wire [11:0] two_dec_min_limit_nxt   = one_dec_max_limit   - HYST_OFFSET;
  wire [11:0] three_dec_min_limit_nxt = two_dec_max_limit   - HYST_OFFSET;
  wire [11:0] four_dec_min_limit_nxt  = three_dec_max_limit - HYST_OFFSET; 
  wire        device_temp_high = device_temp > TEMP_MAX_LIMIT;
  wire        device_temp_low  = device_temp < TEMP_MIN_LIMIT;
  wire [11:0] device_temp_100  =     ( { 12 {  device_temp_high                     } } & TEMP_MAX_LIMIT )
                                   | ( { 12 {                      device_temp_low  } } & TEMP_MIN_LIMIT )
                                   | ( { 12 { ~device_temp_high & ~device_temp_low  } } & device_temp );
  wire [11:0] device_temp_init_nxt      = tempmon_state_init  ? device_temp_101 : device_temp_init;
  wire        tempmon_init_complete_nxt = tempmon_state_init  ? 1'b1            : tempmon_init_complete;
  wire        update_temp_101           =  tempmon_init_complete & ~tempmon_sample_en_102 & tempmon_sample_en_101;
  wire [11:0] device_temp_capture_101   =  update_temp_101 ? device_temp_101 : device_temp_capture_102;
  wire        temp_cmp_four_inc_max_101  = device_temp_101 >= four_inc_max_limit  ;
  wire        temp_cmp_three_inc_max_101 = device_temp_101 >= three_inc_max_limit ;
  wire        temp_cmp_two_inc_max_101   = device_temp_101 >= two_inc_max_limit   ;
  wire        temp_cmp_one_inc_max_101   = device_temp_101 >= one_inc_max_limit   ;
  wire        temp_cmp_neutral_max_101   = device_temp_101 >= neutral_max_limit   ;
  wire        temp_cmp_one_dec_max_101   = device_temp_101 >= one_dec_max_limit   ;
  wire        temp_cmp_two_dec_max_101   = device_temp_101 >= two_dec_max_limit   ;
  wire        temp_cmp_three_dec_max_101 = device_temp_101 >= three_dec_max_limit ;
  wire        temp_cmp_three_inc_min_101 = device_temp_101 < three_inc_min_limit ;
  wire        temp_cmp_two_inc_min_101   = device_temp_101 < two_inc_min_limit   ;
  wire        temp_cmp_one_inc_min_101   = device_temp_101 < one_inc_min_limit   ;
  wire        temp_cmp_neutral_min_101   = device_temp_101 < neutral_min_limit   ;
  wire        temp_cmp_one_dec_min_101   = device_temp_101 < one_dec_min_limit   ;
  wire        temp_cmp_two_dec_min_101   = device_temp_101 < two_dec_min_limit   ;
  wire        temp_cmp_three_dec_min_101 = device_temp_101 < three_dec_min_limit ;
  wire        temp_cmp_four_dec_min_101  = device_temp_101 < four_dec_min_limit  ;
  wire        temp_gte_four_inc_max  = update_temp_102 & temp_cmp_four_inc_max_102;
  wire        temp_gte_three_inc_max = update_temp_102 & temp_cmp_three_inc_max_102;
  wire        temp_gte_two_inc_max   = update_temp_102 & temp_cmp_two_inc_max_102;
  wire        temp_gte_one_inc_max   = update_temp_102 & temp_cmp_one_inc_max_102;
  wire        temp_gte_neutral_max   = update_temp_102 & temp_cmp_neutral_max_102;
  wire        temp_gte_one_dec_max   = update_temp_102 & temp_cmp_one_dec_max_102;
  wire        temp_gte_two_dec_max   = update_temp_102 & temp_cmp_two_dec_max_102;
  wire        temp_gte_three_dec_max = update_temp_102 & temp_cmp_three_dec_max_102;
  wire        temp_lte_three_inc_min = update_temp_102 & temp_cmp_three_inc_min_102;
  wire        temp_lte_two_inc_min   = update_temp_102 & temp_cmp_two_inc_min_102;
  wire        temp_lte_one_inc_min   = update_temp_102 & temp_cmp_one_inc_min_102;
  wire        temp_lte_neutral_min   = update_temp_102 & temp_cmp_neutral_min_102;
  wire        temp_lte_one_dec_min   = update_temp_102 & temp_cmp_one_dec_min_102;
  wire        temp_lte_two_dec_min   = update_temp_102 & temp_cmp_two_dec_min_102;
  wire        temp_lte_three_dec_min = update_temp_102 & temp_cmp_three_dec_min_102;
  wire        temp_lte_four_dec_min  = update_temp_102 & temp_cmp_four_dec_min_102;
  always @(*) begin
    tempmon_state_nxt = tempmon_state;
    tempmon_state_init = 1'b0;
    pi_f_inc_nxt = 1'b0;
    pi_f_dec_nxt = 1'b0;
    casez (tempmon_state)
      IDLE: begin
        if (calib_complete) tempmon_state_nxt = INIT;
      end
      INIT: begin
        tempmon_state_nxt = NEUTRAL;
        tempmon_state_init = 1'b1;
      end
      FOUR_INC: begin
        if (temp_gte_four_inc_max) begin
	  tempmon_state_nxt = THREE_INC;
          pi_f_dec_nxt = 1'b1;
        end
      end
      THREE_INC: begin
        if (temp_gte_three_inc_max) begin
	  tempmon_state_nxt = TWO_INC;
          pi_f_dec_nxt = 1'b1;
        end
	else if (temp_lte_three_inc_min) begin
	  tempmon_state_nxt = FOUR_INC;
          pi_f_inc_nxt = 1'b1;
        end
      end
      TWO_INC: begin
        if (temp_gte_two_inc_max) begin
	  tempmon_state_nxt = ONE_INC;
          pi_f_dec_nxt = 1'b1;
        end
	else if (temp_lte_two_inc_min) begin
	  tempmon_state_nxt = THREE_INC;
          pi_f_inc_nxt = 1'b1;
        end
      end
      ONE_INC: begin
        if (temp_gte_one_inc_max) begin
	  tempmon_state_nxt = NEUTRAL;
          pi_f_dec_nxt = 1'b1;
        end
	else if (temp_lte_one_inc_min) begin
	  tempmon_state_nxt = TWO_INC;
          pi_f_inc_nxt = 1'b1;
        end
      end
      NEUTRAL: begin
        if (temp_gte_neutral_max) begin
	  tempmon_state_nxt = ONE_DEC;
          pi_f_dec_nxt = 1'b1;
        end
	else if (temp_lte_neutral_min) begin
	  tempmon_state_nxt = ONE_INC;
          pi_f_inc_nxt = 1'b1;
        end
      end
      ONE_DEC: begin
        if (temp_gte_one_dec_max) begin
	  tempmon_state_nxt = TWO_DEC;
          pi_f_dec_nxt = 1'b1;
        end
	else if (temp_lte_one_dec_min) begin
	  tempmon_state_nxt = NEUTRAL;
          pi_f_inc_nxt = 1'b1;
        end
      end
      TWO_DEC: begin
        if (temp_gte_two_dec_max) begin
	  tempmon_state_nxt = THREE_DEC;
          pi_f_dec_nxt = 1'b1;
        end
	else if (temp_lte_two_dec_min) begin
	  tempmon_state_nxt = ONE_DEC;
          pi_f_inc_nxt = 1'b1;
        end
      end
      THREE_DEC: begin
        if (temp_gte_three_dec_max) begin
	  tempmon_state_nxt = FOUR_DEC;
          pi_f_dec_nxt = 1'b1;
        end
	else if (temp_lte_three_dec_min) begin
	  tempmon_state_nxt = TWO_DEC;
          pi_f_inc_nxt = 1'b1;
        end
      end
      FOUR_DEC: begin
	if (temp_lte_four_dec_min) begin
	  tempmon_state_nxt = THREE_DEC;
          pi_f_inc_nxt = 1'b1;
        end
      end
      default: begin
	  tempmon_state_nxt = IDLE;
      end
    endcase
  end 
reg [71:0] tempmon_state_name;
always @(*) casez (tempmon_state)
   IDLE      : tempmon_state_name = "IDLE";
   INIT      : tempmon_state_name = "INIT";
   FOUR_INC  : tempmon_state_name = "FOUR_INC";
   THREE_INC : tempmon_state_name = "THREE_INC";
   TWO_INC   : tempmon_state_name = "TWO_INC";
   ONE_INC   : tempmon_state_name = "ONE_INC";
   NEUTRAL   : tempmon_state_name = "NEUTRAL";
   ONE_DEC   : tempmon_state_name = "ONE_DEC";
   TWO_DEC   : tempmon_state_name = "TWO_DEC";
   THREE_DEC : tempmon_state_name = "THREE_DEC";
   FOUR_DEC  : tempmon_state_name = "FOUR_DEC";
   default   : tempmon_state_name = "BAD_STATE";
endcase
  assign tempmon_pi_f_inc = pi_f_inc;
  assign tempmon_pi_f_dec = pi_f_dec;
  assign tempmon_sel_pi_incdec = pi_f_inc | pi_f_dec;
  always @(posedge clk) begin
    if(rst) begin
      tempmon_state           <= #TCQ 11'b000_0000_0001;
      pi_f_inc                <= #TCQ 1'b0;
      pi_f_dec                <= #TCQ 1'b0;
      four_inc_max_limit      <= #TCQ 12'b0;
      three_inc_max_limit     <= #TCQ 12'b0;
      two_inc_max_limit       <= #TCQ 12'b0;
      one_inc_max_limit       <= #TCQ 12'b0;
      neutral_max_limit       <= #TCQ 12'b0;
      one_dec_max_limit       <= #TCQ 12'b0;
      two_dec_max_limit       <= #TCQ 12'b0;
      three_dec_max_limit     <= #TCQ 12'b0;
      three_inc_min_limit     <= #TCQ 12'b0;
      two_inc_min_limit       <= #TCQ 12'b0;
      one_inc_min_limit       <= #TCQ 12'b0;
      neutral_min_limit       <= #TCQ 12'b0;
      one_dec_min_limit       <= #TCQ 12'b0;
      two_dec_min_limit       <= #TCQ 12'b0;
      three_dec_min_limit     <= #TCQ 12'b0;
      four_dec_min_limit      <= #TCQ 12'b0;
      device_temp_init        <= #TCQ 12'b0;
      tempmon_init_complete   <= #TCQ 1'b0;
      tempmon_sample_en_101   <= #TCQ 1'b0;
      tempmon_sample_en_102   <= #TCQ 1'b0;
      device_temp_101         <= #TCQ 12'b0;
      device_temp_capture_102 <= #TCQ 12'b0;
    end
    else begin
      tempmon_state           <= #TCQ tempmon_state_nxt;
      pi_f_inc                <= #TCQ pi_f_inc_nxt;
      pi_f_dec                <= #TCQ pi_f_dec_nxt;
      four_inc_max_limit      <= #TCQ four_inc_max_limit_nxt;
      three_inc_max_limit     <= #TCQ three_inc_max_limit_nxt;
      two_inc_max_limit       <= #TCQ two_inc_max_limit_nxt;
      one_inc_max_limit       <= #TCQ one_inc_max_limit_nxt;
      neutral_max_limit       <= #TCQ neutral_max_limit_nxt;
      one_dec_max_limit       <= #TCQ one_dec_max_limit_nxt;
      two_dec_max_limit       <= #TCQ two_dec_max_limit_nxt;
      three_dec_max_limit     <= #TCQ three_dec_max_limit_nxt;
      three_inc_min_limit     <= #TCQ three_inc_min_limit_nxt;
      two_inc_min_limit       <= #TCQ two_inc_min_limit_nxt;
      one_inc_min_limit       <= #TCQ one_inc_min_limit_nxt;
      neutral_min_limit       <= #TCQ neutral_min_limit_nxt;
      one_dec_min_limit       <= #TCQ one_dec_min_limit_nxt;
      two_dec_min_limit       <= #TCQ two_dec_min_limit_nxt;
      three_dec_min_limit     <= #TCQ three_dec_min_limit_nxt;
      four_dec_min_limit      <= #TCQ four_dec_min_limit_nxt;
      device_temp_init        <= #TCQ device_temp_init_nxt;
      tempmon_init_complete   <= #TCQ tempmon_init_complete_nxt;
      tempmon_sample_en_101   <= #TCQ tempmon_sample_en;
      tempmon_sample_en_102   <= #TCQ tempmon_sample_en_101;
      device_temp_101         <= #TCQ device_temp_100;
      device_temp_capture_102 <= #TCQ device_temp_capture_101;
    end
  end
  always @(posedge clk) begin
      temp_cmp_four_inc_max_102  <= #TCQ temp_cmp_four_inc_max_101;
      temp_cmp_three_inc_max_102 <= #TCQ temp_cmp_three_inc_max_101;
      temp_cmp_two_inc_max_102   <= #TCQ temp_cmp_two_inc_max_101;
      temp_cmp_one_inc_max_102   <= #TCQ temp_cmp_one_inc_max_101;
      temp_cmp_neutral_max_102   <= #TCQ temp_cmp_neutral_max_101;
      temp_cmp_one_dec_max_102   <= #TCQ temp_cmp_one_dec_max_101;
      temp_cmp_two_dec_max_102   <= #TCQ temp_cmp_two_dec_max_101;
      temp_cmp_three_dec_max_102 <= #TCQ temp_cmp_three_dec_max_101;
      temp_cmp_three_inc_min_102 <= #TCQ temp_cmp_three_inc_min_101;
      temp_cmp_two_inc_min_102   <= #TCQ temp_cmp_two_inc_min_101;
      temp_cmp_one_inc_min_102   <= #TCQ temp_cmp_one_inc_min_101;
      temp_cmp_neutral_min_102   <= #TCQ temp_cmp_neutral_min_101;
      temp_cmp_one_dec_min_102   <= #TCQ temp_cmp_one_dec_min_101;
      temp_cmp_two_dec_min_102   <= #TCQ temp_cmp_two_dec_min_101;
      temp_cmp_three_dec_min_102 <= #TCQ temp_cmp_three_dec_min_101;
      temp_cmp_four_dec_min_102  <= #TCQ temp_cmp_four_dec_min_101;
      update_temp_102            <= #TCQ update_temp_101;
  end
endmodule
