`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module picouser
  (
  input  wire        BTN_EAST,
  input  wire        BTN_NORTH,
  input  wire        BTN_SOUTH,
  input  wire        BTN_WEST,
  input  wire  [3:0] SW,
  input  wire        ROT_A,
  input  wire        ROT_B,
  input  wire        ROT_CENTER,
  input  wire        rot_clr,
  input  wire        clk,
  output wire  [3:0] btn_out,
  output wire  [3:0] sws_out,
  output reg   [3:0] rot_out
  );
  synchro #(.INITIALIZE("LOGIC0"))
  synchro_sws_3 (.async(SW[3]),.sync(sws_out[3]),.clk(clk));
  synchro #(.INITIALIZE("LOGIC0"))
  synchro_sws_2 (.async(SW[2]),.sync(sws_out[2]),.clk(clk));
  synchro #(.INITIALIZE("LOGIC0"))
  synchro_sws_1 (.async(SW[1]),.sync(sws_out[1]),.clk(clk));
  synchro #(.INITIALIZE("LOGIC0"))
  synchro_sws_0 (.async(SW[0]),.sync(sws_out[0]),.clk(clk));
  synchro #(.INITIALIZE("LOGIC0"))
  synchro_btn_n (.async(BTN_NORTH),.sync(btn_out[3]),.clk(clk));
  synchro #(.INITIALIZE("LOGIC0"))
  synchro_btn_s (.async(BTN_EAST ),.sync(btn_out[2]),.clk(clk));
  synchro #(.INITIALIZE("LOGIC0"))
  synchro_btn_e (.async(BTN_SOUTH),.sync(btn_out[1]),.clk(clk));
  synchro #(.INITIALIZE("LOGIC0"))
  synchro_btn_w (.async(BTN_WEST ),.sync(btn_out[0]),.clk(clk));
  wire        sync_rot_c;
  synchro #(.INITIALIZE("LOGIC0"))
  synchro_rot_c (.async(ROT_CENTER),.sync(sync_rot_c),.clk(clk));
  wire        sync_rot_b;
  synchro #(.INITIALIZE("LOGIC1"))
  synchro_rot_b (.async(ROT_B),.sync(sync_rot_b),.clk(clk));
  wire        sync_rot_a;
  synchro #(.INITIALIZE("LOGIC1"))
  synchro_rot_a (.async(ROT_A),.sync(sync_rot_a),.clk(clk));
  wire        event_rot_c_on;
  wire        event_rot_c_off;
  wire        event_rot_l_one;
  wire        event_rot_r_one;
  spinner spinner_inst (
    .sync_rot_a(sync_rot_a),
    .sync_rot_b(sync_rot_b),
    .event_rot_l(event_rot_l_one),
    .event_rot_r(event_rot_r_one),
    .clk(clk));
  debnce debnce_rot_c (
    .sync(sync_rot_c),
    .event_on(event_rot_c_on),
    .event_off(event_rot_c_off),
    .clk(clk));
  always @(posedge clk)
  begin : status_log
    if (event_rot_c_off) rot_out[3] <= 1'b1;
    else if (rot_clr) rot_out[3] <= 1'b0;
    if (event_rot_c_on) rot_out[2] <= 1'b1;
    else if (rot_clr) rot_out[2] <= 1'b0;
    if (event_rot_l_one) rot_out[1] <= 1'b1;
    else if (rot_clr) rot_out[1] <= 1'b0;
    if (event_rot_r_one) rot_out[0] <= 1'b1;
    else if (rot_clr) rot_out[0] <= 1'b0;
  end
endmodule
