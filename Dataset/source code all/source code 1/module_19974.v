module uart_rx(
  input wire clock,           
  input wire rxd,             
  output reg [7:0] rx_data,  
  output reg rx_full = 1'b0,  
  input wire ack              
);
parameter divide_count = 178;
reg [9:0] divider = 0;  
parameter IDLE = 0, READING = 1, STOP_BIT = 2;
reg [1:0] state = 0;
reg [7:0] shifter;
reg [2:0] shift_count;
reg [2:0] rxd_sync;
reg [2:0] bit_timer;
always @(posedge clock) begin
  if (ack == 1'b1) begin
    rx_full <= 1'b0;
  end
  rxd_sync <= {rxd_sync[1:0], rxd};
  if (state == IDLE) begin
    divider = 3;
    if (rxd_sync[2] == 0) begin
      bit_timer <= 3'd5;
      state <= READING;
      shift_count <= 7;
    end
  end else begin  
    if (divider != divide_count) begin
      divider <= divider + 10'd1;
    end else begin
      divider <= 1;
      if (bit_timer != 0) begin
        bit_timer <= bit_timer - 3'd1;
      end else begin
        if (state == STOP_BIT) begin
          if (rxd_sync[2] == 1'b1) begin
            rx_full <= 1'b1;
            rx_data <= shifter;
          end;
          state <= IDLE;
        end else begin
          shifter <= {rxd_sync[2], shifter[7:1]};
          if (shift_count == 0) begin
            state <= STOP_BIT;
          end else begin
            shift_count <= shift_count - 3'd1;
          end
        end
        bit_timer <= 3;
      end
    end
    if (divider == 0) begin
    end
  end
end
endmodule
