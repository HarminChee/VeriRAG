`timescale 1ps/1ps
`timescale 1ps/1ps
module rd_data_gen #
   (
   parameter TCQ           = 100,
   parameter FAMILY = "VIRTEX7", 
   parameter nCK_PER_CLK   = 4,            
   parameter MEM_BURST_LEN = 8,
   parameter START_ADDR = 32'h00000000,
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
   input        mode_load_i,
   output  cmd_rdy_o,             
   input   cmd_valid_i,           
   output reg cmd_start_o,
   input [31:0] simple_data0 ,
   input [31:0] simple_data1 ,
   input [31:0] simple_data2 ,
   input [31:0] simple_data3 ,
   input [31:0] simple_data4 ,
   input [31:0] simple_data5 ,
   input [31:0] simple_data6 ,
   input [31:0] simple_data7 ,
   input [31:0] fixed_data_i,   
   input [ADDR_WIDTH-1:0] addr_i, 
   input [BL_WIDTH-1:0]   bl_i,   
   output                 user_bl_cnt_is_1_o,
   input   data_rdy_i,           
   output   reg data_valid_o,       
   output  [DWIDTH-1:0] data_o 
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
reg [BL_WIDTH:0]user_burst_cnt;
reg [31:0] w3data;
reg        prefetch;
assign data_port_fifo_rdy = data_rdy_i;
reg user_bl_cnt_is_1;
assign user_bl_cnt_is_1_o = user_bl_cnt_is_1;
always @ (posedge clk_i)
begin
if (data_port_fifo_rdy)
    if ((user_burst_cnt == 2  && FAMILY == "SPARTAN6")
        || (user_burst_cnt == 2  &&  FAMILY == "VIRTEX6")
        )
         user_bl_cnt_is_1 <= #TCQ 1'b1;
    else
        user_bl_cnt_is_1 <= #TCQ 1'b0;
end
always @(cmd_valid_i,data_port_fifo_rdy,cmd_rdy,user_bl_cnt_is_1,prefetch)
begin
       cmd_start = cmd_valid_i   & cmd_rdy  & ( data_port_fifo_rdy | prefetch) ;
       cmd_start_o = cmd_valid_i & cmd_rdy & ( data_port_fifo_rdy | prefetch) ;
end
always @( posedge clk_i)
begin
  if ( rst_i[0] )
    user_burst_cnt <= #TCQ   'd0;
  else if(cmd_valid_i && cmd_rdy && ( data_port_fifo_rdy | prefetch) )  begin
       if (FAMILY == "SPARTAN6" && bl_i[5:0] == 6'b000000)
          user_burst_cnt <= #TCQ 7'b1000000;
       else if (FAMILY == "VIRTEX6" && bl_i[BL_WIDTH - 1:0] == {BL_WIDTH {1'b0}})
          user_burst_cnt <= #TCQ {1'b1, {BL_WIDTH-1{1'b0}}};      
       else
          user_burst_cnt <= #TCQ {1'b0,bl_i };
       end
  else if(data_port_fifo_rdy) 
     if (user_burst_cnt != 6'd0)
        user_burst_cnt <= #TCQ   user_burst_cnt - 1'b1;
     else
        user_burst_cnt <= #TCQ   'd0;
end 
always @( posedge clk_i)
begin
  if ( rst_i[0] )
    prefetch <= #TCQ   1'b1;
  else if (data_port_fifo_rdy || cmd_start)
    prefetch <= #TCQ   1'b0;
  else if (user_burst_cnt == 0 && ~data_port_fifo_rdy)
    prefetch <= #TCQ   1'b1;
end
assign cmd_rdy_o = cmd_rdy  ;
always @( posedge clk_i)
begin
  if ( rst_i[0] )
    cmd_rdy <= #TCQ   1'b1;
  else if (cmd_valid_i && cmd_rdy && (data_port_fifo_rdy || prefetch ))
       cmd_rdy <= #TCQ   1'b0;
  else if  ((data_port_fifo_rdy && user_burst_cnt == 2 && MEM_BURST_LEN == 8)  ||
            (data_port_fifo_rdy && user_burst_cnt == 2 && MEM_BURST_LEN == 4))
      cmd_rdy <= #TCQ   1'b1;
end
always @ (data_port_fifo_rdy)
if (FAMILY == "SPARTAN6")
    data_valid_o = data_port_fifo_rdy;
else
    data_valid_o = data_port_fifo_rdy;
generate
if (FAMILY == "SPARTAN6") begin : SP6_DGEN
s7ven_data_gen #
(  
   .TCQ               (TCQ),
   .DMODE           ("READ"),
   .nCK_PER_CLK       (nCK_PER_CLK),
   .FAMILY          (FAMILY),
   .ADDR_WIDTH      (32 ),
   .BL_WIDTH        (BL_WIDTH       ),    
   .MEM_BURST_LEN   (MEM_BURST_LEN),
   .DWIDTH          (DWIDTH       ),
   .DATA_PATTERN    (DATA_PATTERN  ),
   .NUM_DQ_PINS      (NUM_DQ_PINS  ),
   .SEL_VICTIM_LINE   (SEL_VICTIM_LINE),
   .START_ADDR        (START_ADDR),
   .COLUMN_WIDTH     (COLUMN_WIDTH)
 )
 s7ven_data_gen
 (
   .clk_i              (clk_i         ),        
   .rst_i              (rst_i[1]      ),
   .data_rdy_i         (data_rdy_i    ),
   .mem_init_done_i    (1'b1),
   .wr_data_mask_gen_i (1'b0),
   .prbs_fseed_i       (prbs_fseed_i),
   .mode_load_i        (mode_load_i),
   .data_mode_i        (data_mode_i   ),  
   .cmd_startA         (cmd_start    ),  
   .cmd_startB         (cmd_start    ),   
   .cmd_startC         (cmd_start    ),   
   .cmd_startD         (cmd_start    ),   
   .cmd_startE         (cmd_start    ),   
   .m_addr_i           (addr_i),
   .simple_data0       (simple_data0),
   .simple_data1       (simple_data1),
   .simple_data2       (simple_data2),
   .simple_data3       (simple_data3),
   .simple_data4       (simple_data4),
   .simple_data5       (simple_data5),
   .simple_data6       (simple_data6),
   .simple_data7       (simple_data7),
   .fixed_data_i       (fixed_data_i),
   .addr_i             (addr_i        ),       
   .user_burst_cnt     (user_burst_cnt),
   .fifo_rdy_i         (data_port_fifo_rdy    ),   
   .data_o             (data_o        ),
   .data_mask_o        (),
   .bram_rd_valid_o    ()
  );
end
endgenerate
generate
if (FAMILY == "VIRTEX6") begin : V_DGEN
s7ven_data_gen #
(  
   .TCQ               (TCQ),
   .DMODE           ("READ"),
   .nCK_PER_CLK       (nCK_PER_CLK),
   .FAMILY          (FAMILY),
   .ADDR_WIDTH      (32 ),
   .BL_WIDTH        (BL_WIDTH       ),    
   .MEM_BURST_LEN   (MEM_BURST_LEN),
   .DWIDTH          (DWIDTH       ),
   .DATA_PATTERN    (DATA_PATTERN  ),
   .NUM_DQ_PINS      (NUM_DQ_PINS  ),
   .SEL_VICTIM_LINE   (SEL_VICTIM_LINE),
   .START_ADDR        (START_ADDR),
   .COLUMN_WIDTH     (COLUMN_WIDTH)
 )
 s7ven_data_gen
 (
   .clk_i              (clk_i         ),        
   .rst_i              (rst_i[1]      ),
   .data_rdy_i         (data_rdy_i    ),
   .mem_init_done_i    (1'b1),
   .wr_data_mask_gen_i (1'b0),
   .prbs_fseed_i       (prbs_fseed_i),
   .mode_load_i        (mode_load_i),
   .data_mode_i        (data_mode_i   ),  
   .cmd_startA         (cmd_start    ),  
   .cmd_startB         (cmd_start    ),   
   .cmd_startC         (cmd_start    ),   
   .cmd_startD         (cmd_start    ),   
   .cmd_startE         (cmd_start    ),   
   .m_addr_i           (addr_i),
   .simple_data0       (simple_data0),
   .simple_data1       (simple_data1),
   .simple_data2       (simple_data2),
   .simple_data3       (simple_data3),
   .simple_data4       (simple_data4),
   .simple_data5       (simple_data5),
   .simple_data6       (simple_data6),
   .simple_data7       (simple_data7),
   .fixed_data_i       (fixed_data_i),
   .addr_i             (addr_i        ),       
   .user_burst_cnt     (user_burst_cnt),
   .fifo_rdy_i         (data_port_fifo_rdy    ),   
   .data_o             (data_o        ),
   .data_mask_o        (),
   .bram_rd_valid_o    ()
  );
end
endgenerate
endmodule 
