`timescale 1ns / 1ps
`timescale 1ns / 1ps
module wasca_performance_counter_0 (
                                      address,
                                      begintransfer,
                                      clk,
                                      reset_n,
                                      write,
                                      writedata,
                                      readdata
                                   )
;
  output  [ 31: 0] readdata;
  input   [  2: 0] address;
  input            begintransfer;
  input            clk;
  input            reset_n;
  input            write;
  input   [ 31: 0] writedata;
  wire             clk_en;
  reg     [ 63: 0] event_counter_0;
  reg     [ 63: 0] event_counter_1;
  wire             global_enable;
  wire             global_reset;
  wire             go_strobe_0;
  wire             go_strobe_1;
  wire    [ 31: 0] read_mux_out;
  reg     [ 31: 0] readdata;
  wire             stop_strobe_0;
  wire             stop_strobe_1;
  reg     [ 63: 0] time_counter_0;
  reg     [ 63: 0] time_counter_1;
  reg              time_counter_enable_0;
  reg              time_counter_enable_1;
  wire             write_strobe;
  assign clk_en = -1;
  assign write_strobe = write & begintransfer;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          time_counter_0 <= 0;
      else if ((time_counter_enable_0 & global_enable) | global_reset)
          if (global_reset)
              time_counter_0 <= 0;
          else 
            time_counter_0 <= time_counter_0 + 1;
    end
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          event_counter_0 <= 0;
      else if ((go_strobe_0 & global_enable) | global_reset)
          if (global_reset)
              event_counter_0 <= 0;
          else 
            event_counter_0 <= event_counter_0 + 1;
    end
  assign stop_strobe_0 = (address == 0) && write_strobe;
  assign go_strobe_0 = (address == 1) && write_strobe;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          time_counter_enable_0 <= 0;
      else if (clk_en)
          if (stop_strobe_0 | global_reset)
              time_counter_enable_0 <= 0;
          else if (go_strobe_0)
              time_counter_enable_0 <= -1;
    end
  assign global_enable = time_counter_enable_0 | go_strobe_0;
  assign global_reset = stop_strobe_0 && writedata[0];
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          time_counter_1 <= 0;
      else if ((time_counter_enable_1 & global_enable) | global_reset)
          if (global_reset)
              time_counter_1 <= 0;
          else 
            time_counter_1 <= time_counter_1 + 1;
    end
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          event_counter_1 <= 0;
      else if ((go_strobe_1 & global_enable) | global_reset)
          if (global_reset)
              event_counter_1 <= 0;
          else 
            event_counter_1 <= event_counter_1 + 1;
    end
  assign stop_strobe_1 = (address == 4) && write_strobe;
  assign go_strobe_1 = (address == 5) && write_strobe;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          time_counter_enable_1 <= 0;
      else if (clk_en)
          if (stop_strobe_1 | global_reset)
              time_counter_enable_1 <= 0;
          else if (go_strobe_1)
              time_counter_enable_1 <= -1;
    end
  assign read_mux_out = ({32 {(address == 0)}} & time_counter_0[31 : 0]) |
    ({32 {(address == 1)}} & time_counter_0[63 : 32]) |
    ({32 {(address == 2)}} & event_counter_0) |
    ({32 {(address == 4)}} & time_counter_1[31 : 0]) |
    ({32 {(address == 5)}} & time_counter_1[63 : 32]) |
    ({32 {(address == 6)}} & event_counter_1);
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          readdata <= 0;
      else if (clk_en)
          readdata <= read_mux_out;
    end
endmodule
