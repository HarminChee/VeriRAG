module flash_ctrl(
  input clk, 
  input rst,
  output reg data_oe,
  input [7:0] core_data_out, 
  output reg  [7:0] core_data_in, 
  input [31:0] instruction,  
  input c_data_in_rdy,  
  input c_data_out_rdy, 
  input iq_empty, 
  output ack_mode_read, 
  output reg req_core_data, 
  output reg output_dval, 
  output flash_rdy,
  output reg oCE_N,
  output reg oCLE,
  output reg oALE,
  output reg oWE_N, 
  output reg oRE_N,
  output reg oWP_N,
  input iRB_N,
  input [7:0] flash_q,  
  output reg [7:0] flash_data 
);
`define countWidth 12
parameter STANDBY_0 = 0;
parameter STANDBY_1 = 8;
parameter BUS_IDLE_0 = 1;
parameter BUS_IDLE_1 = 9;
parameter COMMAND_INPUT_0 = 2;
parameter COMMAND_INPUT_1 = 10;
parameter ADDRESS_INPUT_0 = 3;
parameter ADDRESS_INPUT_1 = 11;
parameter DATA_INPUT_0 = 4;
parameter DATA_INPUT_1 = 12;
parameter DATA_OUTPUT_0 = 5;
parameter DATA_OUTPUT_1 = 13;
parameter DATA_OUTPUT_END_0 = 6;
parameter DATA_OUTPUT_END_1 = 14;
parameter WRITE_PROTECT_0 = 7;
parameter WRITE_PROTECT_1 = 15;
parameter IDLEDATA = 8'haa; 
reg mode_done;
reg new_mode;
reg [3:0] state;
reg [`countWidth-1:0] c;
wire [3:0] flash_mode;
wire [11:0] repeat_counter;
assign flash_mode = instruction[3:0]; 
assign repeat_counter = instruction[15:4]; 
assign ack_mode_read = ( iRB_N && (c == `countWidth'd0) ) ? mode_done : 1'd0;
assign flash_rdy = iRB_N;
always@(posedge clk or negedge rst) begin
  if(rst == 1'b0) begin
    state <= WRITE_PROTECT_0;
  end else begin
    case(state)
      STANDBY_0:
        state <= STANDBY_1; 
      STANDBY_1:
        if(iq_empty)
          state <= STANDBY_0;
        else
          state <= flash_mode;
      BUS_IDLE_0:
        state <= BUS_IDLE_1; 
      BUS_IDLE_1:
          if(iq_empty)
            state <= STANDBY_0;
          else
            state <= flash_mode;
      COMMAND_INPUT_0:
        if(c_data_in_rdy)
          state <= COMMAND_INPUT_1;
        else
          state <= COMMAND_INPUT_0;
      COMMAND_INPUT_1:
        if(iq_empty)
          state <= STANDBY_0;
        else
          state <= flash_mode;
      ADDRESS_INPUT_0:
        if(c_data_in_rdy)
          state <= ADDRESS_INPUT_1;
        else
          state <= ADDRESS_INPUT_0;
      ADDRESS_INPUT_1:
        if(iq_empty)
          state <= STANDBY_0;
        else
          state <= flash_mode;
      DATA_INPUT_0:
        if(c_data_in_rdy)
          state <= DATA_INPUT_1;
        else
          state <= DATA_OUTPUT_0;
      DATA_INPUT_1:
        if(iq_empty)
          state <= STANDBY_0;
        else
          state <= flash_mode;
      DATA_OUTPUT_0:
        if(c_data_out_rdy)
          state <= DATA_OUTPUT_1;
        else
          state <= DATA_OUTPUT_0;
      DATA_OUTPUT_1:
        if(iq_empty)
          state <= STANDBY_0;
        else
          state <= flash_mode;
      DATA_OUTPUT_END_0: 
        if(c_data_out_rdy)
          state <= DATA_OUTPUT_END_1;
        else
          state <= DATA_OUTPUT_END_0;
      DATA_OUTPUT_END_1:
        if(iq_empty)
          state <= STANDBY_0;
        else
          state <= flash_mode;
      WRITE_PROTECT_0:
		    state <= WRITE_PROTECT_1; 
		  WRITE_PROTECT_1:
		    if(iq_empty)
		      state <= STANDBY_0;
		    else
		      state <= flash_mode;
      default:
        state <= WRITE_PROTECT_0; 
    endcase
  end
end 
always@(posedge clk or negedge rst) begin 
  if(rst == 1'b0) begin
    oCE_N <= 1'b1;
    oCLE <= 1'b0;
    oALE <= 1'b0;
    oWE_N <= 1'b1;
    oRE_N <= 1'b1;
    oWP_N <= 1'b1; 
    flash_data <= IDLEDATA;
    data_oe <= 1'b0; 
    mode_done <= 1'b0;
    req_core_data <= 1'b0;
    output_dval <= 1'b0;
  end else begin
    case(state)
      STANDBY_0: begin
        oCE_N <= 1'b1;
        oCLE <= 1'b0; 
        oALE <= 1'b0; 
        oWE_N <= 1'b1; 
        oRE_N <= 1'b1; 
        oWP_N <= 1'b1; 
        flash_data <= IDLEDATA;
        data_oe <= 1'b0; 
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      STANDBY_1: begin
        oCE_N <= 1'b1;
        oCLE <= 1'b0; 
        oALE <= 1'b0; 
        oWE_N <= 1'b1; 
        oRE_N <= 1'b1; 
        oWP_N <= 1'b1; 
        flash_data <= IDLEDATA;
        data_oe <= 1'b0; 
        mode_done <= 1'b0; 
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      BUS_IDLE_0: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0; 
        oALE <= 1'b0; 
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1; 
        flash_data <= IDLEDATA;
        data_oe <= 1'b0; 
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      BUS_IDLE_1: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0; 
        oALE <= 1'b0; 
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1; 
        flash_data <= IDLEDATA;
        data_oe <= 1'b0; 
        mode_done <= 1'b0;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      COMMAND_INPUT_0: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b1;
        oALE <= 1'b0;
        oWE_N <= 1'b0; 
        oRE_N <= 1'b1;
        oWP_N <= 1'b1; 
        flash_data <= core_data_out;
        data_oe <= 1'b1;
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      COMMAND_INPUT_1: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b1;
        oALE <= 1'b0;
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1;
        flash_data <= core_data_out;
        data_oe <= 1'b1;
        mode_done <= 1'b0;
        req_core_data <= 1'b1; 
        output_dval <= 1'b0;
      end
     ADDRESS_INPUT_0: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b1;
        oWE_N <= 1'b0;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1;
        flash_data <= core_data_out;
        data_oe <= 1'b1;
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end  
      ADDRESS_INPUT_1: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b1;
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1;
        flash_data <= core_data_out;
        data_oe <= 1'b1;
        mode_done <= 1'b0;
        req_core_data <= 1'b1;
        output_dval <= 1'b0;
      end   
      DATA_INPUT_0: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b0;
        oWE_N <= 1'b0;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1;
        flash_data <= core_data_out;
        data_oe <= 1'b1;
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      DATA_INPUT_1: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b0;
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1;
        flash_data <= core_data_out;
        data_oe <= 1'b1;
        mode_done <= 1'b0;
        req_core_data <= 1'b1; 
        output_dval <= 1'b0;
      end
      DATA_OUTPUT_0: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b0;
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1; 
        flash_data <= IDLEDATA;
        data_oe <= 1'b1;
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b1;
      end
      DATA_OUTPUT_1: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b0;
        oWE_N <= 1'b1;
        oRE_N <= 1'b0;
        oWP_N <= 1'b1; 
        flash_data <= IDLEDATA;
        data_oe <= 1'b1;
        mode_done <= 1'b0;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      DATA_OUTPUT_END_0: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b0;
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1; 
        flash_data <= IDLEDATA;
        data_oe <= 1'b1;
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b1; 
      end
      DATA_OUTPUT_END_1: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b0;
        oWE_N <= 1'b1;
        oRE_N <= 1'b1; 
        oWP_N <= 1'b1; 
        flash_data <= IDLEDATA;
        data_oe <= 1'b1;
        mode_done <= 1'b0;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      WRITE_PROTECT_0: begin 
        oCE_N <= 1'b1; 
        oCLE <= 1'b0; 
        oALE <= 1'b0; 
        oWE_N <= 1'b1; 
        oRE_N <= 1'b1; 
        oWP_N <= 1'b0;
        flash_data <=  IDLEDATA;
        data_oe <= 1'b0;
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      WRITE_PROTECT_1: begin 
        oCE_N <= 1'b1; 
        oCLE <= 1'b0; 
        oALE <= 1'b0; 
        oWE_N <= 1'b1; 
        oRE_N <= 1'b1; 
        oWP_N <= 1'b0;
        flash_data <= IDLEDATA;
        data_oe <= 1'b0;
        mode_done <= 1'b0;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      default: begin  
        oCE_N <= 1'b1;
        oCLE <= 1'b0; 
        oALE <= 1'b0; 
        oWE_N <= 1'b1; 
        oRE_N <= 1'b1; 
        oWP_N <= 
        flash_data <= IDLEDATA;
        data_oe <= 1'b0;
        mode_done <= 1'b0; 
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
    endcase
  end 
end 
always@(posedge clk or negedge rst) begin
  if(rst == 1'b0)
    core_data_in <= IDLEDATA;
  else if(output_dval)
    core_data_in <= flash_q;
  else
    core_data_in <= IDLEDATA;
end 
always@(posedge clk or negedge rst) begin
  if(rst == 1'b0) begin
    c <= `countWidth'd0;
    new_mode <= 1'b0;
  end else begin
    if(ack_mode_read)
      new_mode <= 1'b1;
    else
      new_mode <= 1'b0;
    if(new_mode)
      c <= repeat_counter;
    else if(mode_done & (c > `countWidth'd0) )
      c <= c - 1'd1;
    else
      c <= c;
  end 
end 
endmodule
