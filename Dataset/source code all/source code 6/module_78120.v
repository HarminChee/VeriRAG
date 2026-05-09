`define OVERVOLT_GRACE 4'd10
`define UNDERVOLT_GRACE 16'd50000
`define OVERVOLT_GRACE 4'd10
`define UNDERVOLT_GRACE 16'd50000
module power_management (
  output reg kill_sw,
  output reg [2:0] sel,
  output error,
  input ack,
  input data,
  input start, 
  input clk 
);
  reg [9:0] wait_cnt; 
  reg [3:0] overvolt_grace_cnt;
  reg [15:0] undervolt_grace_cnt;
  reg error_reg;
  always @(posedge clk)
  if (start == 1'd0)
  begin
    kill_sw <= 1'b0;
    sel <= 3'b111;
    wait_cnt = 10'd0;
    error_reg = 1'b0;
    overvolt_grace_cnt = `OVERVOLT_GRACE;
    undervolt_grace_cnt = `UNDERVOLT_GRACE;
  end
  else
  begin
    kill_sw <= 1'b1;
    if (!error_reg)
      wait_cnt <= wait_cnt + 10'd1;
    if (ack)
      error_reg <= 1'b0;
    if (!error_reg && wait_cnt == 10'd0)
    begin
      if (overvolt_grace_cnt != 4'd0)
        overvolt_grace_cnt <= overvolt_grace_cnt - 4'd1;
      if (undervolt_grace_cnt != 16'd0)
        undervolt_grace_cnt <= undervolt_grace_cnt - 16'd1;
      if (sel == 3'd6)
      begin
        sel <= 3'b000;
      end
      else
        sel <= sel + 3'b001;
    end
    if (&wait_cnt && !(&sel)
        && ((data == 1'b0 && sel[0] == 1'b0 && undervolt_grace_cnt == 6'd0)
        || (data == 1'b1 && sel[0] == 1'b1 && overvolt_grace_cnt == 20'd0)))
    begin
      error_reg <= 1'd1;
    end
  end
  assign error = error_reg;
endmodule
