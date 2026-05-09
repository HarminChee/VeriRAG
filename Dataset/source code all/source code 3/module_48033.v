module power_trig
#(
    parameter WIDTH = 24,
    parameter BASE = 0
)
(
    input clock, 
    input reset, 
    input clear, 
    input enable, 
    input set_stb, input [7:0] set_addr, input [31:0] set_data,
    input [WIDTH-1:0] frontend_i,
    input [WIDTH-1:0] frontend_q,
    output [WIDTH-1:0] ddc_in_i,
    output [WIDTH-1:0] ddc_in_q,
    input [31:0] ddc_out_sample,
    input ddc_out_strobe, 
    output ddc_out_enable, 
    output [31:0] bb_sample,
    output bb_strobe 
);
    assign ddc_in_i = frontend_i;
    assign ddc_in_q = frontend_q;
    assign ddc_out_enable = enable;
   reg [8:0] 	  wr_addr;
   wire [8:0] 	  rd_addr;
   reg 		  triggered, triggerable;
   wire 	  trigger;
   wire [31:0] 	  delayed_sample;
   wire [31:0] 	  thresh;
   setting_reg #(.my_addr(BASE+0)) sr_0
     (.clk(clk),.rst(reset),.strobe(set_stb),.addr(set_addr),
      .in(set_data),.out(thresh),.changed());
   assign rd_addr = wr_addr + 1; 
   ram_2port  #(.DWIDTH(32),.AWIDTH(9)) delay_line
     (.clka(clk),.ena(1),.wea(ddc_out_strobe),.addra(wr_addr),.dia(ddc_out_sample),.doa(),
      .clkb(clk),.enb(ddc_out_strobe),.web(1'b0),.addrb(rd_addr),.dib(32'hFFFF),.dob(delayed_sample));
   always @(posedge clock)
     if(reset | ~enable)
       wr_addr <= 0;
     else
       if(ddc_out_strobe)
	 wr_addr <= wr_addr + 1;
   always @(posedge clock)
     if(reset | ~enable)
       triggerable <= 0;
     else if(wr_addr == 9'h1FF)  
       triggerable <= 1;
   reg 			      stb_d1, stb_d2;
   always @(posedge clock) stb_d1 <= ddc_out_strobe;
   always @(posedge clock) stb_d2 <= stb_d1;
   assign bb_sample = delayed_sample;
   assign bb_strobe = stb_d1 & triggered;
   wire [17:0] 		      mult_in = stb_d1 ? { ddc_out_sample[15],ddc_out_sample[15:0], 1'b0 } : 
			      { ddc_out_sample[31], ddc_out_sample[31:16], 1'b0 };
   wire [35:0] 		      prod;
   reg [31:0] 		      sum;
   MULT18X18S mult (.P(prod), .A(mult_in), .B(mult_in), .C(clock), .CE(ddc_out_strobe | stb_d1), .R(reset) );
   always @(posedge clock)
     if(stb_d1)
       sum <= prod[35:4];
     else if(stb_d2)
       sum <= sum + prod[35:4];
   always @(posedge clock)
     if(reset | ~enable | ~triggerable)
       triggered <= 0;
     else if(trigger)
       triggered <= 1;
   assign trigger = (sum > thresh);
endmodule 
