`timescale 1ns / 1ps
`timescale 1ns / 1ps
module system_acl_iface_acl_kernel_interface_sys_description_rom (
                                                                    address,
                                                                    byteenable,
                                                                    chipselect,
                                                                    clk,
                                                                    clken,
                                                                    debugaccess,
                                                                    reset,
                                                                    reset_req,
                                                                    write,
                                                                    writedata,
                                                                    readdata
                                                                 )
;
  parameter INIT_FILE = "sys_description.hex";
  output  [ 63: 0] readdata;
  input   [  8: 0] address;
  input   [  7: 0] byteenable;
  input            chipselect;
  input            clk;
  input            clken;
  input            debugaccess;
  input            reset;
  input            reset_req;
  input            write;
  input   [ 63: 0] writedata;
  wire             clocken0;
  reg     [ 63: 0] readdata;
  wire    [ 63: 0] readdata_ram;
  wire             wren;
  always @(posedge clk)
    begin
      if (clken)
          readdata <= readdata_ram;
    end
  assign wren = chipselect & write & debugaccess;
  assign clocken0 = clken & ~reset_req;
  altsyncram the_altsyncram
    (
      .address_a (address),
      .byteena_a (byteenable),
      .clock0 (clk),
      .clocken0 (clocken0),
      .data_a (writedata),
      .q_a (readdata_ram),
      .wren_a (wren)
    );
  defparam the_altsyncram.byte_size = 8,
           the_altsyncram.init_file = INIT_FILE,
           the_altsyncram.lpm_type = "altsyncram",
           the_altsyncram.maximum_depth = 512,
           the_altsyncram.numwords_a = 512,
           the_altsyncram.operation_mode = "SINGLE_PORT",
           the_altsyncram.outdata_reg_a = "UNREGISTERED",
           the_altsyncram.ram_block_type = "AUTO",
           the_altsyncram.read_during_write_mode_mixed_ports = "DONT_CARE",
           the_altsyncram.width_a = 64,
           the_altsyncram.width_byteena_a = 8,
           the_altsyncram.widthad_a = 9;
endmodule
