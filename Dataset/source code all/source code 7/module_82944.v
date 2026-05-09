`timescale 1ns / 1ps
`timescale 1ns / 1ps
module bram_256x4M (
                        address,
                        byteenable,
                        chipselect,
                        clk,
                        clken,
                        reset,
                        write,
                        writedata,
                        readdata
                     )
;
parameter DEPTH  = 4194304;
parameter NWORDS_A = 4194304;
parameter ADDR_WIDTH = 22; 
  output  [255: 0] readdata;
  input   [ 21: 0] address;
  input   [ 31: 0] byteenable;
  input            chipselect;
  input            clk;
  input            clken;
  input            reset;
  input            write;
  input   [255: 0] writedata;
  reg     [255: 0] readdata;
  wire    [255: 0] readdata_ram;
  wire             wren;
  always @(posedge clk)
    begin
      if (clken)
          readdata <= readdata_ram;
    end
  assign wren = chipselect & write;
  altsyncram the_altsyncram
    (
      .address_a (address),
      .byteena_a (byteenable),
      .clock0 (clk),
      .clocken0 (clken),
      .data_a (writedata),
      .q_a (readdata_ram),
      .wren_a (wren)
    );
  defparam the_altsyncram.byte_size = 8,
           the_altsyncram.init_file = "UNUSED",
           the_altsyncram.lpm_type = "altsyncram",
           the_altsyncram.maximum_depth = DEPTH,
           the_altsyncram.numwords_a = NWORDS_A,
           the_altsyncram.operation_mode = "SINGLE_PORT",
           the_altsyncram.outdata_reg_a = "UNREGISTERED",
           the_altsyncram.ram_block_type = "AUTO",
           the_altsyncram.read_during_write_mode_mixed_ports = "DONT_CARE",
           the_altsyncram.width_a = 256,
           the_altsyncram.width_byteena_a = 32,
           the_altsyncram.widthad_a = ADDR_WIDTH;
endmodule
