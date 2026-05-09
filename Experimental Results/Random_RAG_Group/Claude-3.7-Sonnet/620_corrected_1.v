module userio_osd
(
  input   test_i,
  input   clk,            
  input   clk7_en,
  input   clk7n_en,
  input   reset,        
  input   c1,          
  input   c3,
  input   sol,        
  input   sof,        
  input   varbeamen,
  input   [7:0] osd_ctrl,    
  input   _scs,        
  input   sdi,           
  output  sdo,         
  input   sck,           
  output  osd_blank,      
  output  osd_pixel,      
  output  reg osd_enable = 0,      
  output  reg key_disable = 0,      
  output  reg [1:0] lr_filter = 0,
  output  reg [1:0] hr_filter = 0,
  output  reg [6:0] memory_config = 7'b0_00_01_01,
  output  reg [4:0] chipset_config = 0,
  output  reg [3:0] floppy_config = 0,
  output  reg [1:0] scanline = 0,
  output  reg [1:0] dither = 0,
  output  reg [2:0] ide_config = 0,    
  output  reg [3:0] cpu_config = 0,
  output  reg [1:0] autofire_config = 0,
  output  reg       cd32pad = 0,
  output  reg usrrst=1'b0,
  output  reg cpurst=1'b1,
  output  reg cpuhlt=1'b1,
  output  wire fifo_full,
  output  reg            host_cs,
  output  wire [ 24-1:0] host_adr,
  output  reg            host_we,
  output  reg  [  2-1:0] host_bs,
  output  wire [ 16-1:0] host_wdat,
  input   wire [ 16-1:0] host_rdat,
  input   wire           host_ack
);

reg [4:0] t_chipset_config;
reg [2:0] t_ide_config;
reg [1:0] t_cpu_config;
reg [5:0] t_memory_config;

wire dft_clk;
assign dft_clk = test_i ? clk : clk7_en;

always @(posedge clk or negedge reset)
  if (!reset)
  begin
    t_chipset_config <= 5'b0;
    t_ide_config <= 3'b0;
    t_cpu_config <= 2'b0;
    t_memory_config <= 6'b0;
  end
  else
  begin
    t_chipset_config <= chipset_config;
    t_ide_config <= ide_config;
    t_cpu_config <= cpu_config[1:0];
    t_memory_config <= memory_config[5:0];
  end

always @(posedge dft_clk or negedge reset)
  if (!reset)
  begin
    chipset_config <= 5'b0;
    ide_config <= 3'b0;
    cpu_config[1:0] <= 2'b0;
    memory_config[5:0] <= 6'b0;
  end
  else
  begin
    chipset_config <= t_chipset_config;
    ide_config <= t_ide_config;
    cpu_config[1:0] <= t_cpu_config;
    memory_config[5:0] <= t_memory_config;
  end

endmodule