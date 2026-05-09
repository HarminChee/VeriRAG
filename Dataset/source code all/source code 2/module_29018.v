`timescale 1ps/1ps
`define RD              3'b001;
`define RDP             3'b011;
`define WR              3'b000;
`define WRP             3'b010;
`define REFRESH         3'b100;
`timescale 1ps/1ps
`define RD              3'b001;
`define RDP             3'b011;
`define WR              3'b000;
`define WRP             3'b010;
`define REFRESH         3'b100;
module cmd_gen #
  (
   parameter TCQ           = 100,
   parameter FAMILY = "SPARTAN6",
   parameter BL_WIDTH      = 6,          
   parameter MEM_BURST_LEN = 8,
   parameter nCK_PER_CLK   = 4,
   parameter PORT_MODE = "BI_MODE",
   parameter NUM_DQ_PINS   = 8,
   parameter DATA_PATTERN  = "DGEN_ALL", 
   parameter CMD_PATTERN  = "CGEN_ALL",    
   parameter ADDR_WIDTH    = 30,
   parameter BANK_WIDTH    = 3,
   parameter DWIDTH        = 32,
   parameter PIPE_STAGES   = 0,
   parameter MEM_COL_WIDTH = 10,       
   parameter PRBS_EADDR_MASK_POS = 32'hFFFFD000,
   parameter PRBS_SADDR_MASK_POS =  32'h00002000,
   parameter PRBS_EADDR = 32'h00002000,
   parameter PRBS_SADDR  = 32'h00002000
   )
  (
   input           clk_i,
   input [9:0]          rst_i,
   input           run_traffic_i,
   input                    mem_pattern_init_done_i,
   input [31:0]             start_addr_i,   
   input [31:0]             end_addr_i,
   input [31:0]             cmd_seed_i,    
   input                    load_seed_i,   
   input [2:0]              addr_mode_i,  
   input [3:0]              data_mode_i,  
   input [3:0]              instr_mode_i, 
   input [1:0]              bl_mode_i,  
   input                    mode_load_i,
   input [BL_WIDTH - 1:0]              fixed_bl_i,      
   input [2:0]              fixed_instr_i,   
   input [31:0]             fixed_addr_i, 
   input [31:0]             bram_addr_i,  
   input [2:0]              bram_instr_i,
   input [5:0]              bram_bl_i,
   input                    bram_valid_i,
   output                   bram_rdy_o,
   input                    reading_rd_data_i,
   input           rdy_i,
   output  [31:0]  addr_o,     
   output  [2:0]   instr_o,    
   output  [BL_WIDTH - 1:0]   bl_o,       
   output          cmd_o_vld  ,    
   output  reg     mem_init_done_o
  );
   localparam PRBS_ADDR_WIDTH = 32;
   localparam INSTR_PRBS_WIDTH = 16;
   localparam BL_PRBS_WIDTH    = 16;
localparam BRAM_DATAL_MODE       =    4'b0000;
localparam FIXED_DATA_MODE       =    4'b0001;
localparam ADDR_DATA_MODE        =    4'b0010;
localparam HAMMER_DATA_MODE      =    4'b0011;
localparam NEIGHBOR_DATA_MODE    =    4'b0100;
localparam WALKING1_DATA_MODE    =    4'b0101;
localparam WALKING0_DATA_MODE    =    4'b0110;
localparam PRBS_DATA_MODE        =    4'b0111;
reg [BL_WIDTH+2:0] INC_COUNTS;
reg [2:0]  addr_mode_reg;
reg [1:0]  bl_mode_reg;
reg [31:0] addr_counts;
reg [31:0] addr_counts_next_r;
reg [BANK_WIDTH-1:0] bank_counts;
wire  [14:0]  prbs_bl;
reg [2:0] instr_out;
wire [14:0] prbs_instr_a;
wire [14:0] prbs_instr_b;
reg  [BL_WIDTH - 1:0]   prbs_brlen;
wire [31:0] prbs_addr;
wire [31:0] seq_addr;
wire [31:0] fixed_addr;
reg [31:0] addr_out ;
reg [BL_WIDTH - 1:0]  bl_out;
reg [BL_WIDTH - 1:0] bl_out_reg;
reg mode_load_d1;
reg mode_load_d2;
reg mode_load_pulse;
wire [BL_WIDTH+35:0] pipe_data_o;
wire     cmd_clk_en;
wire     pipe_out_vld;
reg force_bl1;
reg bl_out_clk_en;
reg [BL_WIDTH+35:0] pipe_data_in;
reg instr_vld;
reg bl_out_vld;
reg gen_addr_larger ;
reg [BL_WIDTH-1:0] buf_avail_r;
reg [BL_WIDTH-1:0] rd_data_received_counts;
reg [BL_WIDTH-1:0] rd_data_counts_asked;
    reg [15:0] rd_data_received_counts_total;
reg instr_vld_dly1;
reg first_load_pulse;
reg mem_init_done;
reg refresh_cmd_en ;
reg [9:0] refresh_timer;
reg       refresh_prbs;
reg       cmd_vld;
reg run_traffic_r;
reg cmd_clk_en_r;
reg finish_init;
reg mem_init_done_r;   
reg first_mode_load_pulse_r1;
reg first_mode_load_pulse_set;
reg mode_load_pulse_r1;
reg n_gen_write_only;
reg [9:0]force_rd_counts;
reg force_rd;
reg [31:0] calc_end_address;
reg bl_64;
always @ (posedge clk_i)
 if (rst_i[0])
     mem_init_done_o <= #TCQ 1'b0;
 else if (cmd_clk_en_r)
     mem_init_done_o <= #TCQ mem_init_done_r;
always @ (posedge clk_i)
begin
     run_traffic_r <= #TCQ run_traffic_i;
end     
assign addr_o       = pipe_data_o[31:0];
assign instr_o      = pipe_data_o[34:32];
assign bl_o         = pipe_data_o[(BL_WIDTH - 2 + 35):35];
assign cmd_o_vld    = pipe_data_o[BL_WIDTH  + 35] & run_traffic_r;
assign pipe_out_vld = pipe_data_o[BL_WIDTH  + 35] & run_traffic_r;
assign pipe_data_o = pipe_data_in;
always @(posedge clk_i) begin                    
     instr_vld        <=  #TCQ  (cmd_clk_en | (mode_load_pulse & first_load_pulse));
     bl_out_clk_en    <=  #TCQ  (cmd_clk_en | (mode_load_pulse & first_load_pulse));
     bl_out_vld       <=  #TCQ  bl_out_clk_en;
 end
always @ (posedge clk_i) begin
 if (rst_i[0])
    first_load_pulse <= #TCQ 1'b1;
 else if (mode_load_pulse)
    first_load_pulse <= #TCQ 1'b0;
 else
    first_load_pulse <= #TCQ first_load_pulse;
 end
generate
if (CMD_PATTERN == "CGEN_BRAM")  begin: cv1
always @(posedge clk_i) begin 
    cmd_vld          <=  #TCQ (cmd_clk_en ); 
end
end endgenerate
generate
if (CMD_PATTERN != "CGEN_BRAM")  begin: cv2
always @(posedge clk_i) begin 
    cmd_vld          <=  #TCQ (cmd_clk_en | (mode_load_pulse & first_load_pulse )); 
end
end endgenerate
assign cmd_clk_en =  ( rdy_i & pipe_out_vld & run_traffic_i ||  mode_load_pulse && (CMD_PATTERN == "CGEN_BRAM"));
integer i;
always @ (posedge clk_i)
if (rst_i[1])
   bl_64 <= 1'b0;
else if (data_mode_i == 7 || data_mode_i == 8 || data_mode_i == 9)
   bl_64 <= 1'b1;
else
   bl_64 <= 1'b0;
    always @ (posedge clk_i) begin
    if (rst_i[1])
       pipe_data_in[31:0] <= #TCQ    start_addr_i;
    else if (instr_vld)
           if (data_mode_i == 5 || data_mode_i == 6)
               if (FAMILY == "VIRTEX6")
                 pipe_data_in[31:0] <= #TCQ    {addr_out[31:6], 6'h00};
               else
                   pipe_data_in[31:0] <= #TCQ    {addr_out[31:6], 6'h00};  
           else if (bl_64)
            if  (nCK_PER_CLK == 4)
                  if (FAMILY == "VIRTEX6")
                 pipe_data_in[31:0] <= #TCQ    {addr_out[31:11], 11'h000};
            else
                     pipe_data_in[31:0] <= #TCQ     {addr_out[31:9], 9'h000};
               else
                  if (FAMILY == "VIRTEX6")
                 pipe_data_in[31:0] <= #TCQ    {addr_out[31:10], 10'h000};
                  else
                     pipe_data_in[31:0] <= #TCQ     {addr_out[31:9], 9'h000};
         else if (gen_addr_larger && mem_init_done)
              pipe_data_in[31:0] <= #TCQ  {end_addr_i[31:8],8'h0};
           else           
            pipe_data_in[31:0] <= #TCQ    {addr_out[31:2], 2'b00};
end
reg force_wrcmd_gen;
   always @ (posedge clk_i) begin
    if (rst_i[0])
         force_wrcmd_gen <= #TCQ  1'b0;
    else if (buf_avail_r == 63)
         force_wrcmd_gen <= #TCQ  1'b0;
    else if (instr_vld_dly1 && pipe_data_in[32]== 1 && pipe_data_in[41:35] > 16)
         force_wrcmd_gen <= #TCQ  1'b1;
    end
reg [3:0]instr_mode_reg;
 always @ (posedge clk_i)
 begin
      instr_mode_reg <= #TCQ  instr_mode_i;
 end 
 always @ (posedge clk_i)
 begin
    if (rst_i[2]) begin
       pipe_data_in[40:32] <= #TCQ    'b0;
       end
    else if (instr_vld) begin
      if (instr_mode_reg == 0) begin
              pipe_data_in[34:32] <= #TCQ    instr_out;
              end
      else if (instr_out[2]) begin
              pipe_data_in[34:32] <= #TCQ    3'b100;
              end
      else if ( FAMILY == "SPARTAN6" && PORT_MODE == "RD_MODE")
      begin
            pipe_data_in[34:32] <= #TCQ  {instr_out[2:1],1'b1};
              end
      else if ((force_wrcmd_gen || buf_avail_r <=  15) && FAMILY == "SPARTAN6" &&  PORT_MODE != "RD_MODE")
      begin
            pipe_data_in[34:32] <= #TCQ    {instr_out[2],2'b00};
              end
      else begin
             pipe_data_in[34:32] <= #TCQ    instr_out; 
              end
     if (bl_mode_i[1:0] == 2'b00)                                        
          pipe_data_in[BL_WIDTH-1+35:35] <=  #TCQ   bl_out;
     else
        begin
        if (data_mode_i == 7 ) 
           pipe_data_in[BL_WIDTH-1+35:35] <=   #TCQ  bl_out;
        else if (data_mode_i == 4 ) 
           pipe_data_in[BL_WIDTH-1+35:35] <=   #TCQ  10'd8;
        else  
          if (gen_addr_larger && mem_pattern_init_done_i)  
                    pipe_data_in[BL_WIDTH-1+35:35] <=   #TCQ  10'd8;
          else if (force_bl1 && mem_pattern_init_done_i)
                    pipe_data_in[BL_WIDTH-1+35:35] <=  #TCQ   10'd2; 
          else
                    pipe_data_in[BL_WIDTH-1+35:35] <=   #TCQ  bl_out;  
        end
   end  
 end 
always @ (posedge clk_i) 
begin
     if (rst_i[2])
        pipe_data_in[BL_WIDTH   + 35] <=  #TCQ   'b0;
     else if (cmd_vld)
        pipe_data_in[BL_WIDTH  + 35] <=  #TCQ   instr_vld;
     else if (rdy_i && pipe_out_vld)
        pipe_data_in[BL_WIDTH + 35] <=  #TCQ   1'b0;
 end
 always @ (posedge clk_i)
    instr_vld_dly1  <=  #TCQ instr_vld;
always @ (posedge clk_i) begin
 if (rst_i[0]) begin
    rd_data_counts_asked <= #TCQ  'b0;
  end else if (instr_vld_dly1 && pipe_data_in[32]== 1) begin
    if (pipe_data_in[(BL_WIDTH  +35):35] == 0)
       rd_data_counts_asked <=  #TCQ rd_data_counts_asked + (6'd64) ;
    else
       rd_data_counts_asked <=  #TCQ rd_data_counts_asked + (pipe_data_in[(BL_WIDTH - 1 +35):35]) ;
    end
 end
always @ (posedge clk_i) begin
 if (rst_i[0]) begin
     rd_data_received_counts <= #TCQ  'b0;
     rd_data_received_counts_total <= #TCQ  'b0;
  end else if(reading_rd_data_i) begin
     rd_data_received_counts <= #TCQ  rd_data_received_counts + 1'b1;
     rd_data_received_counts_total <= #TCQ  rd_data_received_counts_total + 1'b1;
     end
 end
 always @ (posedge clk_i)
     buf_avail_r <= #TCQ  (rd_data_received_counts + 10'd64) - rd_data_counts_asked;
localparam BRAM_ADDR       = 2'b00;
localparam FIXED_ADDR      = 2'b01;
localparam PRBS_ADDR       = 2'b10;
localparam SEQUENTIAL_ADDR = 2'b11;
always @ (posedge clk_i) begin
   if (rst_i[3])
        if (CMD_PATTERN == "CGEN_BRAM")
         addr_mode_reg  <= #TCQ    3'b000;
        else                                     
         addr_mode_reg  <= #TCQ    3'b011;
   else if (mode_load_pulse)
         addr_mode_reg  <= #TCQ    addr_mode_i;
end
always @ (posedge clk_i) begin
   if (mode_load_pulse) begin
        bl_mode_reg    <= #TCQ    bl_mode_i ;
   end
   mode_load_d1         <= #TCQ    mode_load_i;
   mode_load_d2         <= #TCQ    mode_load_d1;
end
always @ (posedge clk_i)
     mode_load_pulse <= #TCQ  mode_load_d1 & ~mode_load_d2;
always @ (posedge clk_i) begin
if (rst_i[3])
  addr_out <= #TCQ    start_addr_i;
else
   case({addr_mode_reg})
         3'b000: addr_out <= #TCQ    bram_addr_i;
         3'b001: addr_out <= #TCQ    fixed_addr;
         3'b010: if (FAMILY == "VIRTEX6")
                    if (data_mode_i == 5)        
                         addr_out <= #TCQ    {prbs_addr[31:BL_WIDTH+1], {BL_WIDTH+1{1'b0}}}; 
                    else
                     addr_out <= #TCQ    {prbs_addr[31:BL_WIDTH], {BL_WIDTH{1'b0}}}; 
                 else
                     addr_out <= #TCQ    {prbs_addr}; 
         3'b011: addr_out <= #TCQ    {2'b0,seq_addr[29:0]};
         3'b100: addr_out <= #TCQ    {2'b00,seq_addr[6:2],seq_addr[23:0]};
         3'b101: addr_out <= #TCQ    {prbs_addr[31:20],seq_addr[19:0]} ;
         default : addr_out <= #TCQ    'b0;
   endcase
end
generate
if (CMD_PATTERN == "CGEN_PRBS" || CMD_PATTERN == "CGEN_ALL" ) begin: gen_prbs_addr
cmd_prbs_gen #
  ( 
    .TCQ               (TCQ),
    .FAMILY      (FAMILY),
    .ADDR_WIDTH          (32),
    .DWIDTH     (DWIDTH),
    .MEM_BURST_LEN    (MEM_BURST_LEN),
    .PRBS_WIDTH (32),
    .SEED_WIDTH (32),
    .PRBS_EADDR_MASK_POS          (PRBS_EADDR_MASK_POS ),
    .PRBS_SADDR_MASK_POS           (PRBS_SADDR_MASK_POS  ),
    .PRBS_EADDR         (PRBS_EADDR),
    .PRBS_SADDR          (PRBS_SADDR )
   )
   addr_prbs_gen
  (
   .clk_i            (clk_i),
   .clk_en           (cmd_clk_en),
   .prbs_seed_init   (mode_load_pulse),
   .prbs_seed_i      (cmd_seed_i[31:0]),
   .prbs_o           (prbs_addr)
  );
end
endgenerate
always @ (posedge clk_i) begin
if (addr_out[31:8] >= end_addr_i[31:8])
    gen_addr_larger <=     1'b1;
else
    gen_addr_larger <=     1'b0;
end
generate
if (FAMILY == "SPARTAN6" ) begin : INC_COUNTS_S
always @ (posedge clk_i)
if (mem_init_done)
    INC_COUNTS <= #TCQ  (DWIDTH/8)*(bl_out_reg);
else  begin
    if (fixed_bl_i == 0)
       INC_COUNTS <= #TCQ  (DWIDTH/8)*(64);
    else
       INC_COUNTS <= #TCQ  (DWIDTH/8)*(fixed_bl_i);
    end
end
endgenerate
localparam MEM_BURST_INT = MEM_BURST_LEN ;
generate
if (FAMILY == "VIRTEX6" ) begin : INC_COUNTS_V
always @ (posedge clk_i) begin
    if (rst_i[3])
        INC_COUNTS <= fixed_bl_i;
    else
       if (nCK_PER_CLK == 4)
           INC_COUNTS <= #TCQ  bl_out * (MEM_BURST_INT);
       else  
           if (MEM_BURST_LEN == 8)
              INC_COUNTS <= #TCQ  bl_out * (MEM_BURST_INT/2);
           else
             INC_COUNTS <= #TCQ  bl_out * (MEM_BURST_INT);
end    
end
endgenerate
generate
if (CMD_PATTERN == "CGEN_SEQUENTIAL" || CMD_PATTERN == "CGEN_ALL" ) begin : seq_addr_gen
    assign seq_addr = addr_counts;
always @ (posedge clk_i)
begin                     
if (rst_i[2])
        first_mode_load_pulse_set <= 1'b0;
else if (mode_load_pulse_r1)
    first_mode_load_pulse_set <= #TCQ  1'b1;
end
always @ (posedge clk_i)
begin
    mode_load_pulse_r1 <= #TCQ  mode_load_pulse;
    first_mode_load_pulse_r1 <= #TCQ  mode_load_pulse & ~first_mode_load_pulse_set;
end
always @ (posedge clk_i) begin
if (rst_i[4])
    mem_init_done_r <= #TCQ    1'b0  ;
else if (cmd_clk_en_r)
    mem_init_done_r <= #TCQ    mem_init_done  ;
end
always @ (posedge clk_i)
    addr_counts_next_r <= #TCQ    addr_counts  + INC_COUNTS   ;
always @ (posedge clk_i)
  cmd_clk_en_r <= #TCQ  cmd_clk_en;
always @ (posedge clk_i) begin
   if (rst_i[4]) begin
        addr_counts <= #TCQ    start_addr_i;
        mem_init_done <= #TCQ  1'b0;
  end 
  else if (cmd_clk_en_r || first_mode_load_pulse_r1)
    if(addr_counts_next_r>= end_addr_i  ) begin
               addr_counts <= #TCQ    start_addr_i;
                mem_init_done <= #TCQ  1'b1;
    end else  
                addr_counts <= #TCQ    addr_counts + INC_COUNTS;
end
end
endgenerate
always @ (posedge clk_i) begin
   if (rst_i[4]) 
         n_gen_write_only <= 1'b0;
   else if (~n_gen_write_only && addr_counts_next_r>= end_addr_i)
         n_gen_write_only <= 1'b1;
   else if(addr_counts_next_r>= end_addr_i && instr_out[0] == 1'b0) 
         n_gen_write_only <= 1'b0;
end    
generate
if (CMD_PATTERN == "CGEN_FIXED" || CMD_PATTERN == "CGEN_ALL" ) begin : fixed_addr_gen
    assign fixed_addr = (DWIDTH == 32)?  {fixed_addr_i[31:2],2'b0} :
                        (DWIDTH == 64)?  {fixed_addr_i[31:3],3'b0}:
                        (DWIDTH <= 128)? {fixed_addr_i[31:4],4'b0}:
                        (DWIDTH <= 256)? {fixed_addr_i[31:5],5'b0}:
                                         {fixed_addr_i[31:6],6'b0};
  end
endgenerate
generate
if (CMD_PATTERN == "CGEN_BRAM" || CMD_PATTERN == "CGEN_ALL" ) begin : bram_addr_gen
assign bram_rdy_o = run_traffic_i & cmd_clk_en & bram_valid_i | mode_load_pulse;
end
endgenerate
always @ (posedge clk_i) begin
if (rst_i[4])
    force_rd_counts <= #TCQ  'b0;
else if (instr_vld) begin
    force_rd_counts <= #TCQ  force_rd_counts + 1'b1;
    end
end
always @ (posedge clk_i) begin
if (rst_i[4])
    force_rd <= #TCQ  1'b0;
else if (force_rd_counts[3])
    force_rd <= #TCQ  1'b1;
else
    force_rd <= #TCQ  1'b0;
end
always @ (posedge clk_i) begin
if (rst_i[4])
   refresh_timer <= #TCQ  'b0;
else
   refresh_timer <= #TCQ  refresh_timer + 1'b1;
end
always @ (posedge clk_i) begin
if (rst_i[4])
   refresh_cmd_en <= #TCQ  'b0;
else if (refresh_timer == 10'h3ff)
   refresh_cmd_en <= #TCQ  'b1;
else if (cmd_clk_en && refresh_cmd_en)
   refresh_cmd_en <= #TCQ  'b0;
end   
always @ (posedge clk_i) begin
if (FAMILY == "SPARTAN6")
    refresh_prbs <= #TCQ  prbs_instr_b[3] & refresh_cmd_en;
else
    refresh_prbs <= #TCQ  1'b0;
end    
always @ (posedge clk_i) begin
   case(instr_mode_i)
         0: instr_out <= #TCQ    bram_instr_i;
         1: instr_out <= #TCQ    fixed_instr_i;
         2: instr_out <= #TCQ    {2'b00,(prbs_instr_a[0] | force_rd)};
         3: instr_out <= #TCQ    {2'b0,prbs_instr_a[0]};  
         4: instr_out <= #TCQ    {1'b0,prbs_instr_b[0], prbs_instr_a[0]};  
         5: instr_out <= #TCQ    {refresh_prbs ,prbs_instr_b[0], prbs_instr_a[0]};  
         default : instr_out <= #TCQ    {2'b00,1'b1};
   endcase
end
generate  
if (CMD_PATTERN == "CGEN_PRBS" || CMD_PATTERN == "CGEN_ALL" ) begin: gen_prbs_instr
cmd_prbs_gen #
  (
    .TCQ               (TCQ),
    .PRBS_CMD    ("INSTR"),
    .ADDR_WIDTH  (32),
    .SEED_WIDTH  (15),
    .PRBS_WIDTH  (20)
   )
   instr_prbs_gen_a
  (
   .clk_i              (clk_i),
   .clk_en             (cmd_clk_en),
   .prbs_seed_init     (load_seed_i),
   .prbs_seed_i        (cmd_seed_i[14:0]),
   .prbs_o             (prbs_instr_a)
  );
cmd_prbs_gen #
  (
    .PRBS_CMD    ("INSTR"),
    .SEED_WIDTH  (15),
    .PRBS_WIDTH  (20)
   )
   instr_prbs_gen_b
  (
   .clk_i              (clk_i),
   .clk_en             (cmd_clk_en),
   .prbs_seed_init     (load_seed_i),
   .prbs_seed_i        (cmd_seed_i[16:2]),
   .prbs_o             (prbs_instr_b)
  );
end
endgenerate
always @(addr_out,bl_out,end_addr_i,rst_i,buf_avail_r) begin
    if (rst_i[6])
        force_bl1 =   1'b0;
    else if (((addr_out + bl_out* (DWIDTH/8)) >= end_addr_i) || (buf_avail_r  <= 50 && PORT_MODE == "RD_MODE"))
        force_bl1 =   1'b1;
    else
        force_bl1 =   1'b0;
end
always @(posedge clk_i) begin
   if (rst_i[6])
       bl_out_reg <= #TCQ    fixed_bl_i;
   else if (bl_out_vld)
       bl_out_reg <= #TCQ    bl_out;
end
always @ (posedge clk_i) begin
   if (mode_load_pulse || rst_i[3])
        bl_out <= #TCQ    fixed_bl_i ;
   else if (cmd_clk_en) begin
     case({bl_mode_reg})
         0: bl_out <= #TCQ  bram_bl_i  ;
         1: if (data_mode_i == 4)
                bl_out <= #TCQ  10'd8 ;
            else
                bl_out <= #TCQ  fixed_bl_i ;
         2: bl_out <= #TCQ  prbs_brlen;
         default : bl_out <= #TCQ    6'h1;
     endcase
   end
end
generate
if (CMD_PATTERN == "CGEN_PRBS" || CMD_PATTERN == "CGEN_ALL" ) begin: gen_prbs_bl
cmd_prbs_gen #
      (
    .TCQ               (TCQ),      
    .FAMILY      (FAMILY),
    .PRBS_CMD    ("BLEN"),
    .ADDR_WIDTH  (32),
    .SEED_WIDTH  (15),
    .PRBS_WIDTH  (20)
   )
   bl_prbs_gen
  (
   .clk_i             (clk_i),
   .clk_en            (cmd_clk_en),
   .prbs_seed_init    (load_seed_i),
   .prbs_seed_i       (cmd_seed_i[16:2]),
   .prbs_o            (prbs_bl)
  );
end
always @ (prbs_bl)
if (FAMILY == "SPARTAN6" || FAMILY == "MCB")  
    prbs_brlen[5:0]  =  (prbs_bl[5:1] == 5'b00000) ? 6'b000010: {prbs_bl[5:1],1'b0};
else 
     prbs_brlen =  (prbs_bl[BL_WIDTH-1:1] == 5'b00000) ? {{BL_WIDTH-2{1'b0}},2'b10}: {prbs_bl[BL_WIDTH-1:1],1'b0};
endgenerate
endmodule
