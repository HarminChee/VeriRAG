`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module controllerPeripheralHdlAdi
          (
           CLK_IN,
           reset,
           clk_enable,
           adc_current1,
           adc_current2,
           encoder_a,
           encoder_b,
           encoder_index,
           axi_controller_mode,
           axi_command,
           axi_velocity_p_gain,
           axi_velocity_i_gain,
           axi_current_p_gain,
           axi_current_i_gain,
           axi_open_loop_bias,
           axi_open_loop_scalar,
           axi_encoder_zero_offset,
           ce_out_0,
           ce_out_1,
           pwm_a,
           pwm_b,
           pwm_c,
           mon_phase_voltage_a,
           mon_phase_voltage_b,
           mon_phase_current_a,
           mon_phase_current_b,
           mon_rotor_position,
           mon_electrical_position,
           mon_rotor_velocity,
           mon_d_current,
           mon_q_current,
           axi_electrical_pos_err
          );
  input   CLK_IN;
  input   reset;
  input   clk_enable;
  input   signed [17:0] adc_current1;  
  input   signed [17:0] adc_current2;  
  input   encoder_a;
  input   encoder_b;
  input   encoder_index;
  input   [1:0] axi_controller_mode;  
  input   signed [17:0] axi_command;  
  input   signed [17:0] axi_velocity_p_gain;  
  input   signed [17:0] axi_velocity_i_gain;  
  input   signed [17:0] axi_current_p_gain;  
  input   signed [17:0] axi_current_i_gain;  
  input   signed [17:0] axi_open_loop_bias;  
  input   signed [17:0] axi_open_loop_scalar;  
  input   signed [17:0] axi_encoder_zero_offset;  
  output  ce_out_0;
  output  ce_out_1;
  output  pwm_a;
  output  pwm_b;
  output  pwm_c;
  output  signed [31:0] mon_phase_voltage_a;  
  output  signed [31:0] mon_phase_voltage_b;  
  output  signed [31:0] mon_phase_current_a;  
  output  signed [31:0] mon_phase_current_b;  
  output  signed [31:0] mon_rotor_position;  
  output  signed [31:0] mon_electrical_position;  
  output  signed [31:0] mon_rotor_velocity;  
  output  signed [31:0] mon_d_current;  
  output  signed [31:0] mon_q_current;  
  output  signed [18:0] axi_electrical_pos_err;  
  wire enb_1_2000_0;
  wire enb_1_2000_1;
  wire enb;
  wire enb_1_1_1;
  reg signed [17:0] Delay1_out1;  
  reg signed [17:0] Delay7_out1;  
  wire Rate_Transition2_out1;
  wire [15:0] Rate_Transition6_out1;  
  wire [15:0] Controller_out1_0;  
  wire [15:0] Controller_out1_1;  
  wire [15:0] Controller_out1_2;  
  wire signed [19:0] Controller_out2_0;  
  wire signed [19:0] Controller_out2_1;  
  wire signed [19:0] Controller_out2_2;  
  wire signed [17:0] Controller_out3_0;  
  wire signed [17:0] Controller_out3_1;  
  wire signed [17:0] Controller_out4;  
  wire signed [17:0] Controller_out5;  
  wire signed [17:0] Controller_out6;  
  wire signed [17:0] Controller_out7_0;  
  wire signed [17:0] Controller_out7_1;  
  wire signed [18:0] Controller_out8;  
  reg  Delay2_out1;
  reg  Delay3_out1;
  reg  Delay4_out1;
  wire Encoder_Peripheral_Hardware_Specification_out1;
  wire [15:0] Encoder_Peripheral_Hardware_Specification_out2;  
  reg  Rate_Transition2_bypass_reg;  
  reg [15:0] Rate_Transition6_bypass_reg;  
  wire [15:0] Controller_out1 [0:2];  
  reg [15:0] Rate_Transition1_out1 [0:2];  
  wire PWM_out1_0;
  wire PWM_out1_1;
  wire PWM_out1_2;
  wire [0:2] PWM_out1;  
  reg  [0:2] Delay5_out1;  
  wire signed [19:0] Controller_out2 [0:2];  
  wire signed [31:0] Data_Type_Conversion_cast;  
  wire signed [31:0] Data_Type_Conversion_cast_1;  
  wire signed [31:0] Data_Type_Conversion_cast_2;  
  wire signed [31:0] Data_Type_Conversion_out1 [0:2];  
  wire signed [17:0] Controller_out3 [0:1];  
  wire signed [31:0] Data_Type_Conversion1_cast;  
  wire signed [31:0] Data_Type_Conversion1_cast_1;  
  wire signed [31:0] Data_Type_Conversion1_out1 [0:1];  
  wire signed [31:0] Data_Type_Conversion2_out1;  
  wire signed [31:0] Data_Type_Conversion3_out1;  
  wire signed [31:0] Data_Type_Conversion4_out1;  
  wire signed [17:0] Controller_out7 [0:1];  
  wire signed [31:0] Data_Type_Conversion5_cast;  
  wire signed [31:0] Data_Type_Conversion5_cast_1;  
  wire signed [31:0] Data_Type_Conversion5_out1 [0:1];  
  controllerPeripheralHdlAdi_tc   u_controllerPeripheralHdlAdi_tc   (.CLK_IN(CLK_IN),
                                                                     .reset(reset),
                                                                     .clk_enable(clk_enable),
                                                                     .enb(enb),
                                                                     .enb_1_1_1(enb_1_1_1),
                                                                     .enb_1_2000_0(enb_1_2000_0),
                                                                     .enb_1_2000_1(enb_1_2000_1)
                                                                     );
  always @(posedge CLK_IN)
    begin : Delay1_process
      if (reset == 1'b1) begin
        Delay1_out1 <= 18'sb000000000000000000;
      end
      else if (enb_1_2000_0) begin
        Delay1_out1 <= adc_current1;
      end
    end
  always @(posedge CLK_IN)
    begin : Delay7_process
      if (reset == 1'b1) begin
        Delay7_out1 <= 18'sb000000000000000000;
      end
      else if (enb_1_2000_0) begin
        Delay7_out1 <= adc_current2;
      end
    end
  always @(posedge CLK_IN)
    begin : Delay2_process
      if (reset == 1'b1) begin
        Delay2_out1 <= 1'b0;
      end
      else if (enb) begin
        Delay2_out1 <= encoder_a;
      end
    end
  always @(posedge CLK_IN)
    begin : Delay3_process
      if (reset == 1'b1) begin
        Delay3_out1 <= 1'b0;
      end
      else if (enb) begin
        Delay3_out1 <= encoder_b;
      end
    end
  always @(posedge CLK_IN)
    begin : Delay4_process
      if (reset == 1'b1) begin
        Delay4_out1 <= 1'b0;
      end
      else if (enb) begin
        Delay4_out1 <= encoder_index;
      end
    end
  Encoder_Peripheral_Hardware_Specification   u_Encoder_Peripheral_Hardware_Specification   (.CLK_IN(CLK_IN),
                                                                                             .reset(reset),
                                                                                             .enb(enb),
                                                                                             .a(Delay2_out1),
                                                                                             .b(Delay3_out1),
                                                                                             .index(Delay4_out1),
                                                                                             .valid(Encoder_Peripheral_Hardware_Specification_out1),
                                                                                             .count(Encoder_Peripheral_Hardware_Specification_out2)  
                                                                                             );
  always @(posedge CLK_IN)
    begin : Rate_Transition2_bypass_process
      if (reset == 1'b1) begin
        Rate_Transition2_bypass_reg <= 1'b0;
      end
      else if (enb_1_2000_1) begin
        Rate_Transition2_bypass_reg <= Encoder_Peripheral_Hardware_Specification_out1;
      end
    end
  assign Rate_Transition2_out1 = (enb_1_2000_1 == 1'b1 ? Encoder_Peripheral_Hardware_Specification_out1 :
              Rate_Transition2_bypass_reg);
  always @(posedge CLK_IN)
    begin : Rate_Transition6_bypass_process
      if (reset == 1'b1) begin
        Rate_Transition6_bypass_reg <= 16'b0000000000000000;
      end
      else if (enb_1_2000_1) begin
        Rate_Transition6_bypass_reg <= Encoder_Peripheral_Hardware_Specification_out2;
      end
    end
  assign Rate_Transition6_out1 = (enb_1_2000_1 == 1'b1 ? Encoder_Peripheral_Hardware_Specification_out2 :
              Rate_Transition6_bypass_reg);
  controllerHdl_controllerHdl   u_Controller   (.CLK_IN(CLK_IN),
                                                .reset(reset),
                                                .enb_1_2000_0(enb_1_2000_0),
                                                .adc_current_0(Delay1_out1),  
                                                .adc_current_1(Delay7_out1),  
                                                .encoder_valid(Rate_Transition2_out1),
                                                .encoder_count(Rate_Transition6_out1),  
                                                .controller_mode(axi_controller_mode),  
                                                .command(axi_command),  
                                                .param_velocity_p_gain(axi_velocity_p_gain),  
                                                .param_velocity_i_gain(axi_velocity_i_gain),  
                                                .param_current_p_gain(axi_current_p_gain),  
                                                .param_current_i_gain(axi_current_i_gain),  
                                                .param_open_loop_bias(axi_open_loop_bias),  
                                                .param_open_loop_scalar(axi_open_loop_scalar),  
                                                .param_encoder_zero_offset(axi_encoder_zero_offset),  
                                                .pwm_compare_0(Controller_out1_0),  
                                                .pwm_compare_1(Controller_out1_1),  
                                                .pwm_compare_2(Controller_out1_2),  
                                                .phase_voltages_0(Controller_out2_0),  
                                                .phase_voltages_1(Controller_out2_1),  
                                                .phase_voltages_2(Controller_out2_2),  
                                                .phase_currents_0(Controller_out3_0),  
                                                .phase_currents_1(Controller_out3_1),  
                                                .rotor_position(Controller_out4),  
                                                .electrical_position(Controller_out5),  
                                                .rotor_velocity(Controller_out6),  
                                                .dq_currents_0(Controller_out7_0),  
                                                .dq_currents_1(Controller_out7_1),  
                                                .electrical_position_err_reg(Controller_out8)  
                                                );
  assign Controller_out1[0] = Controller_out1_0;
  assign Controller_out1[1] = Controller_out1_1;
  assign Controller_out1[2] = Controller_out1_2;
  always @(posedge CLK_IN)
    begin : Rate_Transition1_process
      if (reset == 1'b1) begin
        Rate_Transition1_out1[0] <= 16'b0000000000000000;
        Rate_Transition1_out1[1] <= 16'b0000000000000000;
        Rate_Transition1_out1[2] <= 16'b0000000000000000;
      end
      else if (enb_1_2000_0) begin
        Rate_Transition1_out1[0] <= Controller_out1[0];
        Rate_Transition1_out1[1] <= Controller_out1[1];
        Rate_Transition1_out1[2] <= Controller_out1[2];
      end
    end
  PWM   u_PWM   (.CLK_IN(CLK_IN),
                 .reset(reset),
                 .enb(enb),
                 .c_0(Rate_Transition1_out1[0]),  
                 .c_1(Rate_Transition1_out1[1]),  
                 .c_2(Rate_Transition1_out1[2]),  
                 .pwm_0(PWM_out1_0),  
                 .pwm_1(PWM_out1_1),  
                 .pwm_2(PWM_out1_2)  
                 );
  assign PWM_out1[0] = PWM_out1_0;
  assign PWM_out1[1] = PWM_out1_1;
  assign PWM_out1[2] = PWM_out1_2;
  always @(posedge CLK_IN)
    begin : Delay5_process
      if (reset == 1'b1) begin
        Delay5_out1[0] <= 1'b0;
        Delay5_out1[1] <= 1'b0;
        Delay5_out1[2] <= 1'b0;
      end
      else if (enb) begin
        Delay5_out1[0] <= PWM_out1[0];
        Delay5_out1[1] <= PWM_out1[1];
        Delay5_out1[2] <= PWM_out1[2];
      end
    end
  assign pwm_a = Delay5_out1[0];
  assign pwm_b = Delay5_out1[1];
  assign pwm_c = Delay5_out1[2];
  assign Controller_out2[0] = Controller_out2_0;
  assign Controller_out2[1] = Controller_out2_1;
  assign Controller_out2[2] = Controller_out2_2;
  assign Data_Type_Conversion_cast = Controller_out2[0];
  assign Data_Type_Conversion_out1[0] = Data_Type_Conversion_cast;
  assign Data_Type_Conversion_cast_1 = Controller_out2[1];
  assign Data_Type_Conversion_out1[1] = Data_Type_Conversion_cast_1;
  assign Data_Type_Conversion_cast_2 = Controller_out2[2];
  assign Data_Type_Conversion_out1[2] = Data_Type_Conversion_cast_2;
  assign mon_phase_voltage_a = Data_Type_Conversion_out1[0];
  assign mon_phase_voltage_b = Data_Type_Conversion_out1[1];
  assign Controller_out3[0] = Controller_out3_0;
  assign Controller_out3[1] = Controller_out3_1;
  assign Data_Type_Conversion1_cast = Controller_out3[0];
  assign Data_Type_Conversion1_out1[0] = Data_Type_Conversion1_cast;
  assign Data_Type_Conversion1_cast_1 = Controller_out3[1];
  assign Data_Type_Conversion1_out1[1] = Data_Type_Conversion1_cast_1;
  assign mon_phase_current_a = Data_Type_Conversion1_out1[0];
  assign mon_phase_current_b = Data_Type_Conversion1_out1[1];
  assign Data_Type_Conversion2_out1 = Controller_out4;
  assign mon_rotor_position = Data_Type_Conversion2_out1;
  assign Data_Type_Conversion3_out1 = Controller_out5;
  assign mon_electrical_position = Data_Type_Conversion3_out1;
  assign Data_Type_Conversion4_out1 = Controller_out6;
  assign mon_rotor_velocity = Data_Type_Conversion4_out1;
  assign Controller_out7[0] = Controller_out7_0;
  assign Controller_out7[1] = Controller_out7_1;
  assign Data_Type_Conversion5_cast = Controller_out7[0];
  assign Data_Type_Conversion5_out1[0] = Data_Type_Conversion5_cast;
  assign Data_Type_Conversion5_cast_1 = Controller_out7[1];
  assign Data_Type_Conversion5_out1[1] = Data_Type_Conversion5_cast_1;
  assign mon_d_current = Data_Type_Conversion5_out1[0];
  assign mon_q_current = Data_Type_Conversion5_out1[1];
  assign axi_electrical_pos_err = Controller_out8;
  assign ce_out_0 = enb_1_1_1;
  assign ce_out_1 = enb_1_2000_1;
endmodule  
