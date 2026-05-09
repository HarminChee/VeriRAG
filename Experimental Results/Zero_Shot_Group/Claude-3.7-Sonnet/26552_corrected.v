module gearbox(clk, phaseA, phaseB, step_pulse);
	parameter COUNT_BITS = 32;
	parameter CLKF = 53200000;	
  parameter REGTICKSX = 19;
	parameter REGTICKS = 1 << REGTICKSX;	
	parameter STEP_PULSE_TICKS = 5;
	parameter m = 1;
	parameter d = 1;
	parameter MPE = 200 * 32 * 6 / 1600;	
	parameter MXMPE = m * MPE;
	input clk, phaseA, phaseB;
	output step_pulse;
	reg step_pulse;
	reg [COUNT_BITS - 1:0] encoder_position = 0, scaled_encoder_position = 0, scaled_motor_position = 0, step_freq_m, step_freq_d;
	wire encoder_step, encoder_up;
	wire motor_step;
	quad_detector qd(clk, phaseA, phaseB, encoder_step, encoder_up);
	reciprocal_divider rd(clk, step_freq_m, step_freq_d, motor_step);
	reg [31:0] step_pulse_timer = 0;
	//assign step_pulse = step_pulse_timer > 0;
	reg [COUNT_BITS - 1:0] prev_encoder_position = 0;
	reg [31:0] reg_tick_counter = 0;
	always @(posedge clk)	begin
		if (reg_tick_counter == 0) begin
			step_freq_m = 2 * scaled_encoder_position - prev_encoder_position - scaled_motor_position;
			step_freq_d = d << REGTICKSX;  
			$display("%d %d %d %d", scaled_encoder_position, scaled_encoder_position-prev_encoder_position,scaled_motor_position, step_freq_m);
			prev_encoder_position = scaled_encoder_position;
			reg_tick_counter = REGTICKS;
		end else begin
			reg_tick_counter = reg_tick_counter - 1;
		end
	end
	always @(posedge clk) begin
		if (motor_step == 1) begin
			scaled_motor_position = scaled_motor_position + d;
			step_pulse_timer = STEP_PULSE_TICKS;
		end
		if (step_pulse_timer > 0) begin
			step_pulse_timer = step_pulse_timer - 1;
			step_pulse = 1;
		end else begin
			step_pulse = 0;
		end
	end
	always @(posedge encoder_step) begin
		if (encoder_up) begin
			encoder_position = encoder_position + 1;
			scaled_encoder_position = scaled_encoder_position + MXMPE;
		end else begin
			encoder_position = encoder_position - 1;
			scaled_encoder_position = scaled_encoder_position - MXMPE;
		end
	end
endmodule

module quad_detector(clk, phaseA, phaseB, encoder_step, encoder_up);
  input clk, phaseA, phaseB;
  output reg encoder_step, encoder_up;
  reg [1:0] state;

  initial state = 0;

  always @(posedge clk) begin
    case (state)
      2'b00: begin
        if (phaseA && !phaseB) begin
          state <= 2'b01;
          encoder_step <= 1;
          encoder_up <= 1;
        end else if (!phaseA && phaseB) begin
          state <= 2'b10;
          encoder_step <= 1;
          encoder_up <= 0;
        end else begin
          encoder_step <= 0;
        end
      end
      2'b01: begin
        if (phaseA && phaseB) begin
          state <= 2'b11;
          encoder_step <= 1;
          encoder_up <= 1;
        end else if (!phaseA && !phaseB) begin
          state <= 2'b00;
          encoder_step <= 1;
          encoder_up <= 0;
        end else begin
          encoder_step <= 0;
        end
      end
      2'b10: begin
        if (!phaseA && !phaseB) begin
          state <= 2'b00;
          encoder_step <= 1;
          encoder_up <= 1;
        end else if (phaseA && phaseB) begin
          state <= 2'b11;
          encoder_step <= 1;
          encoder_up <= 0;
        end else begin
          encoder_step <= 0;
        end
      end
      2'b11: begin
        if (!phaseA && phaseB) begin
          state <= 2'b10;
          encoder_step <= 1;
          encoder_up <= 1;
        end else if (phaseA && !phaseB) begin
          state <= 2'b01;
          encoder_step <= 1;
          encoder_up <= 0;
        end else begin
          encoder_step <= 0;
        end
      end
    endcase
  end
endmodule

module reciprocal_divider(clk, num, den, quotient);
  input clk;
  input [31:0] num, den;
  output reg quotient;
  reg [63:0] remainder;

  always @(posedge clk) begin
    if (num >= den) begin
      quotient <= 1;
      remainder <= num - den;
    end else begin
      quotient <= 0;
      remainder <= num;
    end
  end

endmodule