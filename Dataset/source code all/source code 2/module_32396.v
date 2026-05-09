module add1_8b(
  input wire [7:0] x,
  input wire clk,
  input wire input_valid,
  output wire input_ready,
  output wire out_valid,
  input wire out_ready,
  output wire [7:0] out
);
  reg [7:0] add8_inst0_in0;
  reg [7:0] add8_inst0_in1;
  wire [7:0] add8_inst0_out;
  add8 add8_inst0 (
    .input0(add8_inst0_in0),
    .input1(add8_inst0_in1),
    .out(add8_inst0_out)
  );
  reg [7:0] x_flopped;
  reg [7:0] literal_1 = 1;
  reg [7:0] add_2;
  localparam StateBits = 2;
  localparam
    StateIdle = 2'd0,
    StateBusy0 = 2'd1,
    StateDone = 2'd2;
  reg [StateBits - 1:0] state = StateIdle;
  reg [StateBits - 1:0] state_next;
  always @ (*) begin
    state_next = state;
    case (state)
      StateIdle: begin
        if (input_valid) begin
          state_next = StateBusy0;
        end
      end
      StateBusy0: begin
        state_next = StateDone;
      end
      StateDone: begin
        if (out_ready) begin
          state_next = StateIdle;
        end
      end
      default: begin
        state_next = 2'dx;
      end
    endcase
  end
  reg [7:0] x_flopped_next;
  reg [7:0] add_2_next;
  reg out_valid_reg;
  reg input_ready_reg;
  always @ (*) begin
    x_flopped_next = x_flopped;
    add_2_next = add_2;
    add8_inst0_in0 = x_flopped;
    add8_inst0_in1 = literal_1;
    out_valid_reg = 0;
    input_ready_reg = 0;
    case (state)
      StateIdle: begin
        input_ready_reg = 1;
        x_flopped_next = x;
      end
      StateBusy0: begin
        add8_inst0_in0 = x_flopped;
        add8_inst0_in1 = literal_1;
        add_2_next = add8_inst0_out;
      end
      StateDone: begin
        out_valid_reg = 1;
      end
    endcase
  end
  always @ (posedge clk) begin
    state <= state_next;
    x_flopped <= x_flopped_next;
    add_2 <= add_2_next;
  end
  assign out = add_2;
  assign out_valid = out_valid_reg;
  assign input_ready = input_ready_reg;
endmodule
module add8(
  input wire [7:0] input0,
  input wire [7:0] input1,
  output wire [7:0] out
);
  assign out = input0 + input1;
endmodule
module add1_8b(
  input wire [7:0] x,
  input wire clk,
  input wire input_valid,
  output wire input_ready,
  output wire out_valid,
  input wire out_ready,
  output wire [7:0] out
);
  reg [7:0] add8_inst0_in0;
  reg [7:0] add8_inst0_in1;
  wire [7:0] add8_inst0_out;
  add8 add8_inst0 (
    .input0(add8_inst0_in0),
    .input1(add8_inst0_in1),
    .out(add8_inst0_out)
  );
  reg [7:0] x_flopped;
  reg [7:0] literal_1 = 1;
  reg [7:0] add_2;
  localparam StateBits = 2;
  localparam
    StateIdle = 2'd0,
    StateBusy0 = 2'd1,
    StateDone = 2'd2;
  reg [StateBits - 1:0] state = StateIdle;
  reg [StateBits - 1:0] state_next;
  always @ (*) begin
    state_next = state;
    case (state)
      StateIdle: begin
        if (input_valid) begin
          state_next = StateBusy0;
        end
      end
      StateBusy0: begin
        state_next = StateDone;
      end
      StateDone: begin
        if (out_ready) begin
          state_next = StateIdle;
        end
      end
      default: begin
        state_next = 2'dx;
      end
    endcase
  end
  reg [7:0] x_flopped_next;
  reg [7:0] add_2_next;
  reg out_valid_reg;
  reg input_ready_reg;
  always @ (*) begin
    x_flopped_next = x_flopped;
    add_2_next = add_2;
    add8_inst0_in0 = x_flopped;
    add8_inst0_in1 = literal_1;
    out_valid_reg = 0;
    input_ready_reg = 0;
    case (state)
      StateIdle: begin
        input_ready_reg = 1;
        x_flopped_next = x;
      end
      StateBusy0: begin
        add8_inst0_in0 = x_flopped;
        add8_inst0_in1 = literal_1;
        add_2_next = add8_inst0_out;
      end
      StateDone: begin
        out_valid_reg = 1;
      end
    endcase
  end
  always @ (posedge clk) begin
    state <= state_next;
    x_flopped <= x_flopped_next;
    add_2 <= add_2_next;
  end
  assign out = add_2;
  assign out_valid = out_valid_reg;
  assign input_ready = input_ready_reg;
endmodule
