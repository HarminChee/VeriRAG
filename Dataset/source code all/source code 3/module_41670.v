`timescale 1ps/1ps
`timescale 1ps/1ps
module init_mem_pattern_ctr #
  (
   parameter TCQ           = 100,  
   parameter FAMILY         = "SPARTAN6",      
   parameter TST_MEM_INSTR_MODE = "R_W_INSTR_MODE", 
   parameter MEM_BURST_LEN  = 8,                    
   parameter BL_WIDTH       = 6,
   parameter NUM_DQ_PINS              = 4,              
   parameter CMD_PATTERN    = "CGEN_ALL",           
   parameter BEGIN_ADDRESS  = 32'h00000000, 
   parameter END_ADDRESS  = 32'h00000fff,   
   parameter ADDR_WIDTH     = 30,
   parameter DWIDTH        = 32,
   parameter CMD_SEED_VALUE   = 32'h12345678,
   parameter DATA_SEED_VALUE  = 32'hca345675,
   parameter DATA_MODE     = 4'b0010,
   parameter PORT_MODE     = "BI_MODE", 
   parameter EYE_TEST      = "FALSE"   
   )
  (
   input           clk_i,
   input           rst_i,
   input          memc_cmd_en_i,
   input          memc_wr_en_i,
   input          vio_modify_enable,            
   input [3:0]    vio_instr_mode_value,
   input [3:0]    vio_data_mode_value,
   input [2:0]    vio_addr_mode_value,
   input [1:0]    vio_bl_mode_value,
   input          vio_data_mask_gen,
   input [BL_WIDTH - 1:0]    vio_fixed_bl_value,  
   input           memc_init_done_i,
   input           cmp_error,
   output reg          run_traffic_o,
   output [31:0]             start_addr_o,   
   output [31:0]             end_addr_o,
   output [31:0]             cmd_seed_o,    
   output [31:0]             data_seed_o,
   output  reg                  load_seed_o,   
   output reg [2:0]              addr_mode_o,  
   output reg [3:0]              instr_mode_o, 
   output reg [1:0]              bl_mode_o,    
   output reg [3:0]              data_mode_o,   
   output reg                   mode_load_o,
   output reg [BL_WIDTH-1:0]              fixed_bl_o,      
   output reg [2:0]              fixed_instr_o,   
   output reg                 mem_pattern_init_done_o
  );
parameter IDLE           = 5'b00001,
          INIT_MEM_WRITE = 5'b00010,
          INIT_MEM_READ  = 5'b00100,
          TEST_MEM       = 5'b01000,
          CMP_ERROR      = 5'b10000;
localparam BRAM_ADDR       = 2'b00;
localparam FIXED_ADDR      = 2'b01;
localparam PRBS_ADDR       = 2'b10;
localparam SEQUENTIAL_ADDR = 2'b11;
localparam  BRAM_INSTR_MODE        =    4'b0000;
localparam  FIXED_INSTR_MODE         =   4'b0001;
localparam  R_W_INSTR_MODE          =   4'b0010;
localparam  RP_WP_INSTR_MODE        =   4'b0011;
localparam R_RP_W_WP_INSTR_MODE     =   4'b0100;
localparam R_RP_W_WP_REF_INSTR_MODE =   4'b0101;
localparam BRAM_BL_MODE          =   2'b00;
localparam FIXED_BL_MODE         =   2'b01;
localparam PRBS_BL_MODE          =   2'b10;
localparam BRAM_DATAL_MODE       =    4'b0000;
localparam FIXED_DATA_MODE       =    4'b0001;
localparam ADDR_DATA_MODE        =    4'b0010;                                     
localparam HAMMER_DATA_MODE      =    4'b0011;
localparam NEIGHBOR_DATA_MODE    =    4'b0100;
localparam WALKING1_DATA_MODE    =    4'b0101;
localparam WALKING0_DATA_MODE    =    4'b0110;
localparam PRBS_DATA_MODE        =    4'b0111;
localparam  RD_INSTR       =  3'b001;
localparam  RDP_INSTR      =  3'b011;
localparam  WR_INSTR       =  3'b000;
localparam  WRP_INSTR      =  3'b010;
localparam  REFRESH_INSTR  =  3'b100;
localparam  NOP_WR_INSTR   =  3'b101;
reg [4:0] current_state;
reg [4:0] next_state;
reg       memc_init_done_reg;
reg AC2_G_E2,AC1_G_E1,AC3_G_E3;
reg upper_end_matched;
reg [31:0] end_boundary_addr;     
reg memc_cmd_en_r;
reg lower_end_matched;   
reg end_addr_reached;
reg run_traffic;
reg bram_mode_enable;
reg [31:0] current_address;
reg [BL_WIDTH-1:0]  fix_bl_value;
reg [3:0] data_mode_sel;
reg [1:0] bl_mode_sel;
reg [2:0] addr_mode;
reg [10:0] INC_COUNTS;
wire [3:0] test_mem_instr_mode;
reg pre_instr_switch;
reg switch_instr;
reg memc_wr_en_r;
always @ (TST_MEM_INSTR_MODE, EYE_TEST)
if ((TST_MEM_INSTR_MODE == "FIXED_INSTR_R_MODE" || TST_MEM_INSTR_MODE == "R_W_INSTR_MODE" ||
     TST_MEM_INSTR_MODE == "RP_WP_INSTR_MODE" || TST_MEM_INSTR_MODE == "R_RP_W_WP_INSTR_MODE" ||
     TST_MEM_INSTR_MODE == "R_RP_W_WP_REF_INSTR_MODE" || TST_MEM_INSTR_MODE == "BRAM_INSTR_MODE" )
    && (EYE_TEST == "TRUE"))
begin
$display("Invalid Parameter setting! When  EYE_TEST is st to TRUE, only WRITE commands can be generated.");
$stop;
end
always @ (TST_MEM_INSTR_MODE)
if (TST_MEM_INSTR_MODE == "FIXED_INSTR_R_EYE_MODE" && FAMILY == "SPARTAN6")
begin
$display("Error ! Not supported test instruction mode in Spartan 6");
$stop;
end
always @ (vio_fixed_bl_value,vio_data_mode_value)
if (vio_fixed_bl_value >  7'd64 && FAMILY == "SPARTAN6")
begin
$display("Error ! Maximum User Burst Length is 64");
$display("Change a smaller burst size");
$stop;
end
else if ((vio_data_mode_value == 4'h6 || vio_data_mode_value ==  4'h5) && FAMILY == "VIRTEX6")
begin
   $display("Data DQ bus Walking 1's test.");
   $display("A single DQ bit is set to 1 and walk through entire DQ bus to test ");
   $display("if each DQ bit can be set to 0 or 1 ");
   if (NUM_DQ_PINS == 8)begin
       $display("Warning ! Fixed Burst Length in this mode is forced to 64");
       $display("to ensure '1' always appear on DQ0 of each beginning User Burst");
       end
   else begin
       $display("Warning ! Fixed Burst Length in this mode is forced to equal to NUM_DQ_PINS");
       $display("to ensure '1' always appear on DQ0 of each beginning User Burst");
       end
end
always @ (data_mode_o)
if (data_mode_o == 4'h7 && FAMILY == "SPARTAN6")
begin
$display("Error ! Hammer PRBS is not support in MCB-like interface");
$display("Set value to 4'h8  for Psuedo PRBS");
$stop;
end
assign test_mem_instr_mode = (vio_instr_mode_value[3:2] == 2'b11) ? 4'b1111:
                             (vio_instr_mode_value[3:2] == 2'b10) ? 4'b1011:
                             (TST_MEM_INSTR_MODE == "BRAM_INSTR_MODE")  ? 4'b0000:
                             (TST_MEM_INSTR_MODE == "FIXED_INSTR_R_MODE"  ||
                              TST_MEM_INSTR_MODE == "FIXED_INSTR_W_MODE")              ? 4'b0001:
                             (TST_MEM_INSTR_MODE == "R_W_INSTR_MODE")                                    ? 4'b0010:
                             (TST_MEM_INSTR_MODE == "RP_WP_INSTR_MODE"         && FAMILY == "SPARTAN6")  ? 4'b0011:
                             (TST_MEM_INSTR_MODE == "R_RP_W_WP_INSTR_MODE"     && FAMILY == "SPARTAN6")  ? 4'b0100:
                             (TST_MEM_INSTR_MODE == "R_RP_W_WP_REF_INSTR_MODE" && FAMILY == "SPARTAN6")  ? 4'b0101:
                             4'b0010;
 always @ (posedge clk_i)
 begin
 if (data_mode_o == 4)
       fix_bl_value <= 6'd8;
 else if (data_mode_o == 5 || data_mode_o == 6 )                
       if (NUM_DQ_PINS == 8)
                fix_bl_value <= 10'd64;
       else
            fix_bl_value <= NUM_DQ_PINS;
 else if (data_mode_o == 8)
       fix_bl_value <= 10'd64;
 else if (vio_modify_enable == 1'b1)
       if (vio_fixed_bl_value == 0)  
            fix_bl_value <= 10'd64;  
       else
            fix_bl_value <= vio_fixed_bl_value;
 else
       fix_bl_value <= 10'd64;
 end
generate
if (FAMILY == "SPARTAN6" ) begin : INC_COUNTS_S
always @ (posedge clk_i)
    INC_COUNTS <= (DWIDTH/8);
end
endgenerate
generate
if (FAMILY == "VIRTEX6" ) begin : INC_COUNTS_V
always @ (posedge clk_i)
     INC_COUNTS <= MEM_BURST_LEN ;
end
endgenerate
always @ (posedge clk_i)
begin
if (rst_i)
    current_address <= BEGIN_ADDRESS;
else if (memc_wr_en_r && (current_state == INIT_MEM_WRITE && (PORT_MODE == "WR_MODE" || PORT_MODE == "BI_MODE"))
         || (memc_wr_en_r && (current_state == IDLE && PORT_MODE == "RD_MODE")) )
    current_address <= current_address + INC_COUNTS;
else
    current_address <= current_address;
end    
always @ (posedge clk_i)
begin
  if (current_address[29:24] >= end_boundary_addr[29:24])
      AC3_G_E3 <= 1'b1;
  else
      AC3_G_E3 <= 1'b0;
    if (current_address[23:16] >= end_boundary_addr[23:16])
      AC2_G_E2 <= 1'b1;
  else
      AC2_G_E2 <= 1'b0;
  if (current_address[15:8] >= end_boundary_addr[15:8] )
      AC1_G_E1 <= 1'b1;
else
      AC1_G_E1 <= 1'b0;
end
always @(posedge clk_i)
begin
if (rst_i)
     upper_end_matched <= 1'b0;
 else if (memc_cmd_en_i)
     upper_end_matched <= AC3_G_E3 & AC2_G_E2 & AC1_G_E1;
end   
reg [16:0] DEC_COUNTS;
generate
if (FAMILY == "VIRTEX6" ) begin : DEC_COUNTS_V
    always @ (posedge clk_i) 
if ( (DWIDTH >= 128 * 4 && DWIDTH <= 144 * 4))       
     DEC_COUNTS <= #TCQ  64 * fix_bl_value;
else if ( (DWIDTH >= 64  * 4 && DWIDTH < 128 * 4))       
     DEC_COUNTS <= #TCQ  32 * fix_bl_value  ;
else if ((DWIDTH >= 32* 4) && (DWIDTH < 64* 4))   
     DEC_COUNTS <= #TCQ  16 * fix_bl_value   ;
else if ((DWIDTH == 16* 4) || (DWIDTH == 24* 4))  
     DEC_COUNTS <= #TCQ  8 * fix_bl_value;
else if ((DWIDTH == 8 * 4) )
     DEC_COUNTS <= #TCQ  4 * fix_bl_value;
end
endgenerate
always @ (fix_bl_value)
  if(fix_bl_value * MEM_BURST_LEN > END_ADDRESS) begin
   $display("Error ! User Burst Size goes beyond END Address");
   $display("decrease vio_fixed_bl_value or increase END Address range");
   $stop;
   end
always @ (vio_data_mode_value, vio_data_mask_gen)
  if(vio_data_mode_value != 4'b0010  && vio_data_mask_gen) begin
   $display("Error ! Data Mask Generation only supported in Data Mode = Address as Data");
   $stop;
   end   
always @(posedge clk_i)
begin
if (FAMILY == "VIRTEX6")
     end_boundary_addr <= (END_ADDRESS[31:0] - fix_bl_value * MEM_BURST_LEN +1) ;
else
     end_boundary_addr <= (END_ADDRESS[31:0] - fix_bl_value * MEM_BURST_LEN +1) ;
end   
always @(posedge clk_i)
begin
  if (current_address[7:0] >= end_boundary_addr[7:0])
   lower_end_matched <= 1'b1;
  else
   lower_end_matched <= 1'b0;
end   
always @(posedge clk_i)
begin
 if (rst_i)
   pre_instr_switch  <= 1'b0;
else  if (current_address[7:0] >= end_boundary_addr[7:0] ) 
   pre_instr_switch <= 1'b1;
end   
always @(posedge clk_i)
begin
   if ((upper_end_matched && lower_end_matched && FAMILY == "SPARTAN6" && DWIDTH == 32) ||
      (upper_end_matched && lower_end_matched && FAMILY == "SPARTAN6" && DWIDTH == 64) ||   
      (upper_end_matched && DWIDTH == 128 && FAMILY == "SPARTAN6") ||
      (upper_end_matched && lower_end_matched && FAMILY == "VIRTEX6"))
      end_addr_reached <= 1'b1;
   else    
      end_addr_reached <= 1'b0;
end 
always @(posedge clk_i)
begin
   if ((upper_end_matched && pre_instr_switch && FAMILY == "VIRTEX6"))
      switch_instr <= 1'b1;
   else    
      switch_instr <= 1'b0;
end 
 always @ (posedge clk_i)
 begin
      memc_wr_en_r <= memc_wr_en_i;
      memc_init_done_reg <= memc_init_done_i;
end
 always @ (posedge clk_i)
       run_traffic_o <= run_traffic;
 always @ (posedge clk_i)
 begin
    if (rst_i)
        current_state <= 5'b00001;
    else
        current_state <= next_state;
 end
   assign          start_addr_o  = BEGIN_ADDRESS;
   assign          end_addr_o    = END_ADDRESS;
   assign          cmd_seed_o    = CMD_SEED_VALUE;
   assign          data_seed_o   = DATA_SEED_VALUE;
always @ (posedge clk_i)
begin
   if (rst_i)
      mem_pattern_init_done_o <= 1'b0;
   else if (current_state == TEST_MEM )
      mem_pattern_init_done_o <= 1'b1;
end   
reg [3:0] syn1_vio_data_mode_value;
reg [2:0] syn1_vio_addr_mode_value;
 always @ (posedge clk_i)
 begin
   if (rst_i) begin
        syn1_vio_data_mode_value <= 4'b0011;
        syn1_vio_addr_mode_value <= 2'b11;
       end        
 else if (vio_modify_enable == 1'b1) begin
   syn1_vio_data_mode_value <= vio_data_mode_value;
   syn1_vio_addr_mode_value <= vio_addr_mode_value;
   end
 end
 always @ (posedge clk_i)
 begin
 if (rst_i) begin
       data_mode_sel <= DATA_MODE;
       end
 else if (vio_modify_enable == 1'b1) begin
       data_mode_sel <= syn1_vio_data_mode_value;
       end
 end
 always @ (posedge clk_i)
 begin
 if (rst_i )
       bl_mode_sel <= vio_bl_mode_value;
 else if (test_mem_instr_mode[3]) 
       bl_mode_sel  <= 2'b11;
 else if (vio_modify_enable == 1'b1) begin
       bl_mode_sel <= vio_bl_mode_value;
       end
 end
 always @ (posedge clk_i)
 begin
    if (vio_modify_enable) 
       data_mode_o   <= (test_mem_instr_mode[3]) ? 4'b1000: data_mode_sel;
    else
       data_mode_o   <= DATA_MODE;
    addr_mode_o   <= (test_mem_instr_mode[3]) ? 3'b000: addr_mode ;
    if (syn1_vio_addr_mode_value == 0 && vio_modify_enable == 1'b1)
        bram_mode_enable <=  1'b1;
    else
        bram_mode_enable <=  1'b0;
 end
always @ (*)
begin
             load_seed_o   = 1'b0;
             if (CMD_PATTERN == "CGEN_BRAM" || bram_mode_enable )
                 addr_mode = 'b0;
             else
                 addr_mode   = SEQUENTIAL_ADDR;
             if (CMD_PATTERN == "CGEN_BRAM" || bram_mode_enable )
                 instr_mode_o = 'b0;
             else
                 instr_mode_o   = FIXED_INSTR_MODE;
             if (CMD_PATTERN == "CGEN_BRAM" || bram_mode_enable )
                 bl_mode_o = 'b0;
             else
                 bl_mode_o   = FIXED_BL_MODE;
             if (data_mode_o[2:0] == 3'b111)
                if (FAMILY == "VIRTEX6")
                   fixed_bl_o = 10'd256;    
                else    
                   fixed_bl_o = 10'd64;              
             else if (FAMILY == "VIRTEX6")
                 fixed_bl_o = vio_fixed_bl_value;                                                 
             else if (data_mode_o[3:0] == 4'b1000 && FAMILY == "SPARTAN6")
                 fixed_bl_o = 10'd64;  
             else
                  fixed_bl_o    = fix_bl_value;
             mode_load_o   = 1'b0;
             run_traffic = 1'b0;   
             next_state = IDLE;
             if (PORT_MODE == "RD_MODE") begin
               fixed_instr_o = RD_INSTR;
             end
              else if( PORT_MODE == "WR_MODE" || PORT_MODE == "BI_MODE") begin
               fixed_instr_o = WR_INSTR;
             end
case(current_state)
   IDLE:  
        begin
         if(memc_init_done_reg )   
            begin
              if (PORT_MODE == "WR_MODE" || (PORT_MODE == "BI_MODE" && test_mem_instr_mode[3:2] != 2'b11)) begin
                 next_state = INIT_MEM_WRITE;
              mode_load_o = 1'b1;
              run_traffic = 1'b0;
              load_seed_o   = 1'b1;
             end
              else if (PORT_MODE == "RD_MODE" && end_addr_reached || (test_mem_instr_mode == 4'b1111)) begin
                    next_state = TEST_MEM;
                    mode_load_o = 1'b1;
                    run_traffic = 1'b1;
              load_seed_o   = 1'b1;
              end
            end
         else
              begin
              next_state = IDLE;
              run_traffic = 1'b0;
              load_seed_o   = 1'b0;
              end
         end
   INIT_MEM_WRITE:  begin
         if (end_addr_reached  && EYE_TEST == "FALSE"  )
            begin
               next_state = TEST_MEM;
               mode_load_o = 1'b1;
               load_seed_o   = 1'b1;
               run_traffic = 1'b1;
            end   
          else
             begin
               next_state = INIT_MEM_WRITE;
              run_traffic = 1'b1; 
              mode_load_o = 1'b0;
              load_seed_o   = 1'b0;
              if (EYE_TEST == "TRUE")  
                addr_mode   = FIXED_ADDR;
              else if (CMD_PATTERN == "CGEN_BRAM" || bram_mode_enable )
                addr_mode = 'b0;
              else
                addr_mode   = SEQUENTIAL_ADDR;
             if (switch_instr && TST_MEM_INSTR_MODE == "FIXED_INSTR_R_EYE_MODE")
                 fixed_instr_o = RD_INSTR;
             else
                 fixed_instr_o = WR_INSTR;
             end  
        end
   INIT_MEM_READ:  begin
         if (end_addr_reached  )
            begin
               next_state = TEST_MEM;
               mode_load_o = 1'b1;
              load_seed_o   = 1'b1;
            end   
          else
             begin
               next_state = INIT_MEM_READ;
              run_traffic = 1'b0; 
              mode_load_o = 1'b0;
              load_seed_o   = 1'b0;
             end  
        end
   TEST_MEM: begin  
         if (cmp_error)
               next_state = TEST_MEM;
         else
           next_state = TEST_MEM;
           run_traffic = 1'b1;
           if (PORT_MODE == "BI_MODE" && TST_MEM_INSTR_MODE == "FIXED_INSTR_W_MODE")
                fixed_instr_o = WR_INSTR;
           else if (PORT_MODE == "BI_MODE" && ( TST_MEM_INSTR_MODE == "FIXED_INSTR_R_MODE" ||
                    TST_MEM_INSTR_MODE == "FIXED_INSTR_R_EYE_MODE"))
                fixed_instr_o = RD_INSTR;                
           else if (PORT_MODE == "RD_MODE")
              fixed_instr_o = RD_INSTR;
          else if( PORT_MODE == "WR_MODE") 
              fixed_instr_o = WR_INSTR;
           if ((data_mode_o == 3'b111) && FAMILY == "VIRTEX6")
                 fixed_bl_o = 10'd256;
           else if ((FAMILY == "SPARTAN6"))
                 fixed_bl_o = 10'd64;  
           else
                 fixed_bl_o    = fix_bl_value;
           if (data_mode_o == 3'b111) 
                 bl_mode_o     = FIXED_BL_MODE;
           else if (TST_MEM_INSTR_MODE == "FIXED_INSTR_W_MODE")                  
                 bl_mode_o     = FIXED_BL_MODE;
           else if (data_mode_o == 4'b0101 || data_mode_o == 4'b0110) 
                 bl_mode_o     = FIXED_BL_MODE;
           else
                 bl_mode_o     = bl_mode_sel ;
           if (TST_MEM_INSTR_MODE == "FIXED_INSTR_W_MODE")
                 addr_mode   = SEQUENTIAL_ADDR;
           else if (data_mode_o == 4'b0101 || data_mode_o == 4'b0110) 
                 addr_mode   = SEQUENTIAL_ADDR;
           else if (bl_mode_o == PRBS_BL_MODE)  
                addr_mode   = PRBS_ADDR;
           else
                addr_mode   = 3'b010;
           if (TST_MEM_INSTR_MODE == "FIXED_INSTR_R_EYE_MODE"  && FAMILY == "VIRTEX6")
                   instr_mode_o = FIXED_INSTR_MODE;
           else  if(PORT_MODE == "BI_MODE"  && TST_MEM_INSTR_MODE != "FIXED_INSTR_R_EYE_MODE") begin
               if(CMD_PATTERN == "CGEN_BRAM" || bram_mode_enable )
                   instr_mode_o  = BRAM_INSTR_MODE;
               else
                   instr_mode_o  = test_mem_instr_mode;
              end
           else if (PORT_MODE == "RD_MODE" || PORT_MODE == "WR_MODE") begin
               instr_mode_o  = FIXED_INSTR_MODE;
           end
         end
   CMP_ERROR: 
        begin
               next_state = CMP_ERROR;
               bl_mode_o     = bl_mode_sel;
               fixed_instr_o = RD_INSTR;
               addr_mode   = SEQUENTIAL_ADDR;
               if(CMD_PATTERN == "CGEN_BRAM" || bram_mode_enable )
                   instr_mode_o  = BRAM_INSTR_MODE;
               else
                   instr_mode_o  = test_mem_instr_mode;
               run_traffic = 1'b1;       
        end
   default:
          begin
            next_state = IDLE;       
        end
 endcase
 end
endmodule
