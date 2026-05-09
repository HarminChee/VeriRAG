`timescale 1ns/1ps
`timescale 1ns/1ps
module uart_fifo (
  clk,
  rst,
  size,
  write_strobe,
  write_available,
  write_data,
  read_strobe,
  read_count,
  read_data,
  overflow,
  underflow,
  full,
  empty
);
parameter           FIFO_SIZE       = 10;
input                           clk;
input                           rst;
output  wire  [31:0]            size;
input                           write_strobe;
output  wire  [31:0]            write_available;
input         [7:0]             write_data;
input                           read_strobe;
output  reg   [31:0]            read_count;
output  wire  [7:0]             read_data;
output  reg                     overflow;
output  reg                     underflow;
output                          full;
output                          empty;
reg         [FIFO_SIZE - 1: 0]  in_pointer;
reg         [FIFO_SIZE - 1: 0]  out_pointer;
dual_port_bram #(
  .DATA_WIDTH(8),
  .ADDR_WIDTH(FIFO_SIZE),
  .MEM_FILE("NOTHING"),
  .MEM_FILE_LENGTH(0)
) mem (
  .a_clk(clk),
  .a_wr(write_strobe),
  .a_addr(in_pointer),
  .a_din(write_data),
  .b_clk(clk),
  .b_wr(1'b0),
  .b_addr(out_pointer),
  .b_din(8'h0),
  .b_dout(read_data)
);
wire        [FIFO_SIZE - 1: 0]  last;
assign                          size            =  1 << FIFO_SIZE;
assign                          last            = (out_pointer - 1);
assign                          full            = (in_pointer == last);
assign                          empty           = (read_count == 0);
assign                          write_available = size - read_count;
integer                         i;
always @ (posedge clk) begin
  if (rst) begin
    read_count        <=  0;
    in_pointer        <=  0;
    out_pointer       <=  0;
    overflow          <=  0;
    underflow         <=  0;
  end
  else begin
    overflow          <=  0;
    underflow         <=  0;
    if (write_strobe) begin
      if (full && !read_strobe) begin
        $display ("UART CONTROLLER: Overflow condition");
        out_pointer         <=  out_pointer + 1;
        overflow            <=  1;
      end
      else begin
        if (!read_strobe) begin
          read_count          <=  read_count + 1;
        end
      end
      in_pointer            <=  in_pointer + 1;
    end
    if (read_strobe) begin
      if (empty) begin
        underflow           <=  1;
      end
      else begin
        if (full && write_strobe) begin
          overflow          <=  0;
        end
        else begin
          if (!write_strobe) begin
            read_count        <=  read_count - 1;
          end
          out_pointer       <=  out_pointer + 1;
        end
      end
    end
  end
end
endmodule
