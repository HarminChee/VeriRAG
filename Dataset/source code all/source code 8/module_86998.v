module acl_debug_mem
#(
  parameter WIDTH=16,          
  parameter SIZE=10 
)
(
  input  logic clk,
  input  logic resetn,
  input  logic             write,
  input  logic [WIDTH-1:0] data[SIZE]
);
  localparam ADDRWIDTH=$clog2(SIZE);
  logic [ADDRWIDTH-1:0] addr;
  logic do_write;
  always@(posedge clk or negedge resetn)
    if (!resetn)
      addr <= {ADDRWIDTH{1'b0}};
    else if (addr != {ADDRWIDTH{1'b0}})
      addr <= addr + 2'b01;
    else if (write)
      addr <= addr + 2'b01;
  assign do_write = write | (addr != {ADDRWIDTH{1'b0}});
	altsyncram	altsyncram_component (
				.address_a (addr),
				.clock0 (clk),
				.data_a (data[addr]),
				.wren_a (do_write),
				.q_a (),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.intended_device_family = "Stratix IV",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=ACLDEBUGMEM",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = SIZE,
		altsyncram_component.widthad_a = ADDRWIDTH,
		altsyncram_component.width_a = WIDTH,
		altsyncram_component.operation_mode = "SINGLE_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.read_during_write_mode_port_a = "DONT_CARE",
		altsyncram_component.width_byteena_a = 1;
endmodule
