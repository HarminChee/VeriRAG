`timescale 1ps/1ps
`timescale 1ps/1ps
module rd_data_gen #
   (
   parameter TCQ           = 100,
   parameter FAMILY = "SPARTAN6", 
   parameter MEM_BURST_LEN = 8,
   parameter ADDR_WIDTH = 32,
   parameter BL_WIDTH = 6,
   parameter DWIDTH = 32,
   parameter DATA_PATTERN = "DGEN_ALL", 
   parameter NUM_DQ_PINS   = 8,
   parameter SEL_VICTIM_LINE = 3,  
   parameter COLUMN_WIDTH = 10
 )
 (
   input   clk_i,                 
   input [4:0]  rst_i, 
   input [31:0] prbs_fseed_i,
   input [3:0]  data_mode_i,   
   output  cmd_rdy_o,             
   input   cmd_valid_i,           
   output  last_word_o,   
   input [ADDR_WIDTH-1:0] m_addr_i, 
   input [DWIDTH-1:0] fixed_data_i,   
   input [ADDR_WIDTH-1:0] addr_i, 
   input [BL_WIDTH-1:0]   bl_i,   
   output                 user_bl_cnt_is_1_o,
   input   data_rdy_i,           
   output   reg data_valid_o,       
   output  [DWIDTH-1:0] data_o, 
   input  rd_mdata_en
);  
wire [31:0]       prbs_data; 
reg              cmd_start;
reg [31:0]        adata; 
reg [31:0]        hdata; 
reg [31:0]        ndata; 
reg [31:0]        w1data; 
reg [NUM_DQ_PINS*4-1:0]        v6_w1data; 
reg [31:0]        w0data; 
reg [DWIDTH-1:0] data;
reg               cmd_rdy;
reg               data_valid;
reg [6:0]user_burst_cnt;
reg       data_rdy_r1,data_rdy_r2;   
reg       next_count_is_one;
reg       cmd_valid_r1;
reg [31:0] w3data;
assign data_port_fifo_rdy = data_rdy_i;
always @ (posedge clk_i)
begin
      data_rdy_r1 <= #TCQ data_rdy_i;
      data_rdy_r2 <= #TCQ data_rdy_r1;
      cmd_valid_r1 <= #TCQ cmd_valid_i;
end      
always @ (posedge clk_i)
begin
if (user_burst_cnt == 2 && data_rdy_i)
     next_count_is_one <= #TCQ 1'b1;
else
     next_count_is_one <= #TCQ 1'b0;
end
reg user_bl_cnt_is_1;
assign user_bl_cnt_is_1_o = user_bl_cnt_is_1;
always @ (posedge clk_i)
begin
if ((user_burst_cnt == 2 && data_port_fifo_rdy && FAMILY == "SPARTAN6")
    || (user_burst_cnt == 2 && data_port_fifo_rdy &&  FAMILY == "VIRTEX6")
   )
     user_bl_cnt_is_1 <= #TCQ 1'b1;
else
     user_bl_cnt_is_1 <= #TCQ 1'b0;
end
reg cmd_start_b;
always @(cmd_valid_i,cmd_valid_r1,cmd_rdy,user_bl_cnt_is_1,rd_mdata_en)
begin
   if (FAMILY == "SPARTAN6") begin
       cmd_start = cmd_valid_i & cmd_rdy ;
       cmd_start_b = cmd_valid_i & cmd_rdy ;
       end
   else if (MEM_BURST_LEN == 4 && FAMILY == "VIRTEX6")  begin
       cmd_start =  rd_mdata_en;  
       cmd_start_b =  rd_mdata_en;  
           end
   else if (MEM_BURST_LEN == 8 && FAMILY == "VIRTEX6")   begin
       cmd_start = (~cmd_valid_r1 & cmd_valid_i) | user_bl_cnt_is_1;  
       cmd_start_b = (~cmd_valid_r1 & cmd_valid_i) | user_bl_cnt_is_1;  
       end
end
always @( posedge clk_i)
begin
  if ( rst_i[0] )
    user_burst_cnt <= #TCQ   'd0;
  else if(cmd_start)  begin
       if (bl_i == 6'b000000)
          user_burst_cnt <= #TCQ 7'b1000000;
       else
          user_burst_cnt <= #TCQ bl_i;
      end
  else if(data_port_fifo_rdy) 
     if (user_burst_cnt != 6'd0)
        user_burst_cnt <= #TCQ   user_burst_cnt - 1'b1;
     else
        user_burst_cnt <= #TCQ   'd0;
end
reg u_bcount_2;
always @ (posedge clk_i)
begin
if ((user_burst_cnt == 2  && data_rdy_i )|| (cmd_start && bl_i == 1))
    u_bcount_2 <= #TCQ   1'b1;
else if (last_word_o)
    u_bcount_2 <= #TCQ   1'b0;
end    
assign  last_word_o = u_bcount_2 & data_rdy_i;
assign cmd_rdy_o = cmd_rdy;
always @( posedge clk_i)
begin
  if ( rst_i[0] )
    cmd_rdy <= #TCQ   1'b1;
  else if (cmd_start)
       cmd_rdy <= #TCQ   1'b0;
  else if  ((data_port_fifo_rdy && user_burst_cnt == 1)) 
      cmd_rdy <= #TCQ   1'b1;
end
always @ (posedge clk_i)
begin
  if (rst_i[0])  
    data_valid <= #TCQ   'd0;
  else if (user_burst_cnt == 6'd1 && data_port_fifo_rdy)
    data_valid <= #TCQ   1'b0;
  else if(( user_burst_cnt >= 6'd1) || cmd_start) 
    data_valid <= #TCQ   1'b1;
end
always @ (data_valid, data_port_fifo_rdy)
if (FAMILY == "SPARTAN6")
    data_valid_o = data_valid;
else
    data_valid_o = data_port_fifo_rdy;
generate
if (FAMILY == "SPARTAN6") begin : SP6_DGEN
sp6_data_gen #
( 
   .TCQ               (TCQ),
   .ADDR_WIDTH      (32 ),
   .BL_WIDTH        (BL_WIDTH       ),
   .DWIDTH          (DWIDTH       ),
   .DATA_PATTERN    (DATA_PATTERN  ),
   .NUM_DQ_PINS      (NUM_DQ_PINS  ),
   .COLUMN_WIDTH     (COLUMN_WIDTH)
 )
 sp6_data_gen
 (
   .clk_i              (clk_i         ),        
   .rst_i              (rst_i[1]         ), 
   .data_rdy_i         (data_rdy_i    ),
   .prbs_fseed_i       (prbs_fseed_i),
   .data_mode_i        (data_mode_i   ),  
   .cmd_startA         (cmd_start    ),  
   .cmd_startB         (cmd_start    ),   
   .cmd_startC         (cmd_start    ),   
   .cmd_startD         (cmd_start    ),   
   .cmd_startE         (cmd_start    ),
   .fixed_data_i         (fixed_data_i),
   .addr_i             (addr_i        ),       
   .user_burst_cnt     (user_burst_cnt),
   .fifo_rdy_i         (data_port_fifo_rdy    ),   
   .data_o             (data_o        )  
  );
end
endgenerate
generate
if (FAMILY == "VIRTEX6") begin : V6_DGEN
v6_data_gen #
(  
   .TCQ               (TCQ),
   .ADDR_WIDTH      (32 ),
   .BL_WIDTH        (BL_WIDTH       ),    
   .MEM_BURST_LEN   (MEM_BURST_LEN),
   .DWIDTH          (DWIDTH       ),
   .DATA_PATTERN    (DATA_PATTERN  ),
   .NUM_DQ_PINS      (NUM_DQ_PINS  ),
   .SEL_VICTIM_LINE   (SEL_VICTIM_LINE),
   .COLUMN_WIDTH     (COLUMN_WIDTH)
 )
 v6_data_gen
 (
   .clk_i              (clk_i         ),        
   .rst_i              (rst_i[1]      ),
   .data_rdy_i         (data_rdy_i    ),
   .prbs_fseed_i       (prbs_fseed_i),
   .data_mode_i        (data_mode_i   ),  
   .cmd_startA         (cmd_start    ),  
   .cmd_startB         (cmd_start    ),   
   .cmd_startC         (cmd_start    ),   
   .cmd_startD         (cmd_start    ),   
   .cmd_startE         (cmd_start    ),   
   .m_addr_i           (addr_i),
   .fixed_data_i       (fixed_data_i),
   .addr_i             (addr_i        ),       
   .user_burst_cnt     (user_burst_cnt),
   .fifo_rdy_i         (data_port_fifo_rdy    ),   
   .data_o             (data_o        )
  );
end
endgenerate
endmodule 
