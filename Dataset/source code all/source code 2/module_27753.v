`default_nettype none
`timescale 1ns / 1ps
`default_nettype none
`timescale 1ns / 1ps
module flash_interface(
  input  wire        clk,  
  input  wire        reset,
  input  wire [7:0]  instruction,
  input  wire        execute,
  input  wire [8:0]  bytes_to_read,
  output wire        busy,
  input  wire [7:0]   write_buffer_data,
  input  wire         write_buffer_write,
  output wire         write_buffer_full,
  output wire [7:0]   read_buffer_q,
  output wire         read_buffer_empty,
  input  wire         read_buffer_read,
  output wire        flash_dq0,
  input  wire        flash_dq1,
  output wire        flash_wb,
  output wire        flash_holdb,
  output wire        flash_c,
  output reg         flash_sb
);
localparam IDLE         = 3'd0,
           DATA_WRITE_0 = 3'd1,
           DATA_WRITE   = 3'd2,
           DATA_READ_0  = 3'd3,
           DATA_READ    = 3'd4;
localparam CLK_DIV = 2;
wire update_in;  
wire update_out; 
wire       write_buffer_empty;
wire [7:0] write_buffer_q;
wire [8:0] write_buffer_usedw;
wire [8:0] read_buffer_usedw;
reg [CLK_DIV:0] clk_div1;
reg [CLK_DIV:0] clk_div2;
reg [7:0] input_shifter;
reg [7:0] output_shifter;
reg [3:0] bit_counter;
reg [8:0] bytes_read;
reg [8:0] bytes_to_read_int;
reg        write_buffer_read;
reg        read_buffer_write;
reg [7:0]  read_buffer_data;
reg [2:0] state;
reg       busy_int;
assign update_in  =  clk_div1[CLK_DIV] & ~clk_div2[CLK_DIV]; 
assign update_out = ~clk_div1[CLK_DIV] &  clk_div2[CLK_DIV]; 
assign flash_c = clk_div2[CLK_DIV] & ~flash_sb;
assign flash_dq0 = output_shifter[7];
assign flash_wb = 1;
assign flash_holdb = 1;
assign busy = busy_int | execute;
always @( posedge clk ) begin
  if ( reset ) begin
    clk_div2 <= 0;
    clk_div1 <= 0;
  end
  else begin
    clk_div2 <= clk_div1;
    clk_div1 <= clk_div1 + 1;
  end
end
always @( posedge clk ) begin
  write_buffer_read <= 0;
  read_buffer_write <= 0;
  if ( reset ) begin
    flash_sb <= 1;
    state <= IDLE;
    busy_int <= 1;
  end
  else begin
    case ( state )
      IDLE: begin
        busy_int <= 0;
        if ( execute ) begin
          state <= DATA_WRITE_0;
          output_shifter <= instruction;
          bytes_to_read_int <= bytes_to_read;
          busy_int <= 1;
        end
      end
      DATA_WRITE_0: begin
        if ( update_out ) begin
          state <= DATA_WRITE;
          flash_sb <= 0;
          bit_counter <= 0;
        end
      end
      DATA_WRITE: begin
        if ( update_out ) begin
          bit_counter <= bit_counter + 4'd1;
          output_shifter <= {output_shifter[6:0], 1'b0};
          if ( bit_counter == 4'd7 ) begin
            bit_counter <= 0;
            if ( !write_buffer_empty ) begin
              output_shifter <= write_buffer_q;
              write_buffer_read <= 1;
            end
            else if ( bytes_to_read_int > 0 ) begin
              state <= DATA_READ;
              output_shifter <= 0;
              bytes_read <= 0;
            end
            else begin
              state <= IDLE;
              flash_sb <= 1;
              busy_int <= 0;
            end
          end
        end
      end
      DATA_READ: begin
        if ( update_in ) begin
          bit_counter <= bit_counter + 4'd1;
          input_shifter <= {input_shifter[6:0], flash_dq1};
          if ( bit_counter == 4'd7 ) begin
            read_buffer_data <= {input_shifter[6:0], flash_dq1};
            read_buffer_write <= 1;
            bytes_read <= bytes_read + 9'd1;
          end
        end
        else if ( update_out ) begin
          if ( bit_counter == 4'd8 ) begin
            bit_counter <= 4'b0;
            if ( bytes_read == bytes_to_read_int ) begin
              flash_sb <= 1;
              state <= IDLE;
              busy_int <= 0;
            end
          end
        end
      end
    endcase
  end
end
fifo8_256 write_buffer (
  .clock ( clk ),
  .sclr ( reset ),
  .data ( write_buffer_data ),
  .wrreq ( write_buffer_write ),
  .full ( write_buffer_full ),
  .rdreq ( write_buffer_read ),
  .empty ( write_buffer_empty ),
  .q ( write_buffer_q ),
  .usedw ( write_buffer_usedw )
);
fifo8_256 read_buffer (
  .clock ( clk ),
  .sclr ( reset ),
  .data ( read_buffer_data ),
  .wrreq ( read_buffer_write ),
  .full (  ),
  .rdreq ( read_buffer_read ),
  .empty ( read_buffer_empty ),
  .q ( read_buffer_q ),
  .usedw ( read_buffer_usedw )
);
endmodule
