`timescale 1ns / 1ps
`timescale 1ns / 1ps
module amm_master_qsys_with_pcie_reconf_registers (
                                                     address,
                                                     byteenable,
                                                     chipselect,
                                                     clk,
                                                     clken,
                                                     reset,
                                                     reset_req,
                                                     write,
                                                     writedata,
                                                     readdata
                                                  )
;
  parameter INIT_FILE = "amm_master_qsys_with_pcie_reconf_registers.hex";
  output  [ 31: 0] readdata;
  input   [  6: 0] address;
  input   [  3: 0] byteenable;
  input            chipselect;
  input            clk;
  input            clken;
  input            reset;
  input            reset_req;
  input            write;
  input   [ 31: 0] writedata;
  wire             clocken0;
  reg     [ 31: 0] readdata;
  wire    [ 31: 0] readdata_ram;
  wire             wren;
  always @(posedge clk)
    begin
      if (clken)
          readdata <= readdata_ram;
    end
  assign wren = chipselect & write;
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
           the_altsyncram.lpm_hint = "ENABLE_RUNTIME_MOD=YES, INSTANCE_NAME=RCNF",
           the_altsyncram.lpm_type = "altsyncram",
           the_altsyncram.maximum_depth = 128,
           the_altsyncram.numwords_a = 128,
           the_altsyncram.operation_mode = "SINGLE_PORT",
           the_altsyncram.outdata_reg_a = "UNREGISTERED",
           the_altsyncram.ram_block_type = "AUTO",
           the_altsyncram.read_during_write_mode_mixed_ports = "DONT_CARE",
           the_altsyncram.width_a = 32,
           the_altsyncram.width_byteena_a = 4,
           the_altsyncram.widthad_a = 7;
endmodule
