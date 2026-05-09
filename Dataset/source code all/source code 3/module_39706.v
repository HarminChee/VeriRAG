`timescale 1 ns / 10 ps
`timescale 1 ns / 10 ps
module mc_datmsk
  #
  (
   parameter            BYTES = 4
   )
  (
   input                  mclock,
   input                  mc_dat_pop,
   input                  pipe_enable,
   input [3:0]            ifb_dev_sel,
   input [BYTES-1:0]      hst_byte_mask,
   input [BYTES-1:0]      de_byte_mask,
   input [BYTES-1:0]      de_byte_zmask,
   input [BYTES-1:0]      de_byte_mask_fast,
   input [BYTES-1:0]      new_z_mask,
   input [3:0]            vga_wen,
   input                  rc_rd_sel,       
   input                  z_en,
   input                  z_ro,
   output reg [BYTES-1:0] ram_dqm          
   );
  reg [BYTES-1:0] de_byte_mask_1; 
  reg [BYTES-1:0] de_byte_mask_2; 
  always @(posedge mclock) begin
    if (pipe_enable) begin
      de_byte_mask_1 <= de_byte_mask;
      de_byte_mask_2 <= de_byte_mask_1; 
      casex ({z_en, z_ro, ifb_dev_sel})
	{1'bx, 1'bx, 4'h4}: ram_dqm <= ~(16'h0);
	{1'bx, 1'bx, 4'h3}: ram_dqm <= ~hst_byte_mask;
        {1'b0, 1'bx, 4'h1}: ram_dqm <= ~de_byte_mask_fast;
        {1'b1, 1'bx, 4'h1}: ram_dqm <= ~(de_byte_mask_fast | new_z_mask);
        {1'b1, 1'bx, 4'h6}: ram_dqm <= ~(de_byte_mask_fast | new_z_mask); 
        {1'b0, 1'bx, 4'h6}: ram_dqm <= ~de_byte_mask_2; 
        {1'bx, 1'bx, 4'h7}: ram_dqm <= ~{4{vga_wen}};
        {1'bx, 1'b0, 4'h8}: ram_dqm <= ~(de_byte_zmask | new_z_mask);
        {1'bx, 1'b1, 4'h8}: ram_dqm <= 16'h0;
      endcase
    end 
  end
endmodule 
