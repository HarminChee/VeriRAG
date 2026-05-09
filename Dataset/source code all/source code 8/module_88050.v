module acl_profiler_external_memory
#(
  parameter BURSTCOUNT_WIDTH=6
)
(
  input clk,
  input resetn,
  input [BURSTCOUNT_WIDTH-1:0] burstcount_in,
  input readdatavalid_in,
  input write_in,
  input read_in,
  input waitrequest_in,
  output reg read_count_enable_out,
  output reg write_count_enable_out,
  output reg read_burst_count_enable_out,
  output reg [BURSTCOUNT_WIDTH-1:0] read_burst_count_value_out,
  output reg write_burst_count_enable_out,
  output reg [BURSTCOUNT_WIDTH-1:0] write_burst_count_value_out,
  output reg read_burst_count_dup_enable_out,
  output reg write_burst_count_dup_enable_out
);
  logic new_read_request, new_write_request, new_request;
  logic write_burst_in_progress;
  logic [BURSTCOUNT_WIDTH-1:0] r_burst_counter;
  logic read_burst_count_en;
  logic write_burst_count_en;
  assign read_burst_count_enable_out = read_burst_count_en;
  assign read_burst_count_dup_enable_out = read_burst_count_en;
  assign write_burst_count_enable_out = write_burst_count_en;
  assign write_burst_count_dup_enable_out = write_burst_count_en;
  assign new_read_request = read_in && !waitrequest_in;
  assign new_write_request = write_in && !waitrequest_in && !write_burst_in_progress;
  assign new_request = new_read_request || new_write_request;
  assign write_burst_in_progress = (r_burst_counter > 1);
  always@(posedge clk or negedge resetn)
  begin
    if (!resetn)
      begin
        read_count_enable_out <= '0;
        write_count_enable_out <= '0;
        read_burst_count_en <= '0;
        write_burst_count_en <= '0;
        read_burst_count_value_out <= '0;
        write_burst_count_value_out <= '0;
      end
    else
      begin
        read_count_enable_out <= readdatavalid_in;
        write_count_enable_out <= write_in && !waitrequest_in;
        read_burst_count_en<= read_in && new_request;
        write_burst_count_en<= write_in && new_request;
        read_burst_count_value_out <= burstcount_in;
        write_burst_count_value_out <= burstcount_in;
      end
  end
  always@(posedge clk or negedge resetn)
  begin
  if (!resetn)
    begin
      r_burst_counter <= 1;
    end
  else
    begin
      if (new_write_request)
        begin
          r_burst_counter <= burstcount_in;
        end
      else
        begin
          if (write_in && !waitrequest_in)
            begin
              r_burst_counter <= r_burst_counter - 1;
            end
        end
    end
  end
endmodule
