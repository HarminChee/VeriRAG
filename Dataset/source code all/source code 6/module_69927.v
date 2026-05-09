`timescale 1ps/1ps
`ifndef TCQ
 `define TCQ 100
`endif
`timescale 1ps/1ps
`ifndef TCQ
 `define TCQ 100
`endif
module v6_data_gen #
(  parameter TCQ        = 100,
   parameter EYE_TEST   = "FALSE",
   parameter ADDR_WIDTH = 32,
   parameter MEM_BURST_LEN = 8,
   parameter BL_WIDTH = 6,
   parameter DWIDTH = 32,
   parameter DATA_PATTERN = "DGEN_ALL", 
   parameter NUM_DQ_PINS   = 8,
   parameter COLUMN_WIDTH = 10,
   parameter SEL_VICTIM_LINE = 3  
 )
 (
   input   clk_i,                 
   input   rst_i, 
   input [31:0] prbs_fseed_i,
   input [3:0]  data_mode_i,   
   input        data_rdy_i,
   input   cmd_startA,  
   input   cmd_startB,         
   input   cmd_startC,         
   input   cmd_startD,         
   input   cmd_startE, 
   input [ADDR_WIDTH-1:0]  m_addr_i,          
   input [DWIDTH-1:0]     fixed_data_i,    
   input [ADDR_WIDTH-1:0]  addr_i,          
   input [6:0]    user_burst_cnt,   
   input   fifo_rdy_i,           
   output  [NUM_DQ_PINS*4-1:0] data_o   
);  
wire [31:0]       prbs_data; 
reg [35:0] acounts;
wire [NUM_DQ_PINS*4-1:0]        adata; 
reg [NUM_DQ_PINS*4-1:0]        hdata; 
reg [NUM_DQ_PINS*4-1:0]        hdata_c; 
reg [NUM_DQ_PINS*4-1:0]        ndata; 
reg [NUM_DQ_PINS*4-1:0]  w1data; 
reg [NUM_DQ_PINS*4-1:0]  w1trash; 
reg [NUM_DQ_PINS*4-1:0]        w0data; 
reg [NUM_DQ_PINS*4-1:0] data;
reg burst_count_reached2;
reg               data_valid;
reg [2:0] walk_cnt;
reg [ADDR_WIDTH-1:0] user_address;
reg sel_w1gen_logic;
wire [4*NUM_DQ_PINS -1 :0] ZEROS;
wire [4*NUM_DQ_PINS -1 :0] ONES;
reg [7:0] BLANK;
reg [7:0] SHIFT_0;
reg [7:0] SHIFT_1;
reg [7:0] SHIFT_2;
reg [7:0] SHIFT_3;
reg [7:0] SHIFT_4;
reg [7:0] SHIFT_5;
reg [7:0] SHIFT_6;
reg [7:0] SHIFT_7;
reg [4*NUM_DQ_PINS -1 :0] sel_victimline_r;
wire data_clk_en;
wire [NUM_DQ_PINS*4-1:0] full_prbs_data;
reg [NUM_DQ_PINS*4-1:0] h_prbsdata;
assign ZEROS = 'b0;
assign ONES = 'b1;
integer i,j,k;
reg [BL_WIDTH-1:0] user_bl;
localparam BRAM_DATAL_MODE       =    4'b0000;
localparam FIXED_DATA_MODE       =    4'b0001;
localparam ADDR_DATA_MODE        =    4'b0010;                                     
localparam HAMMER_DATA_MODE      =    4'b0011;
localparam NEIGHBOR_DATA_MODE    =    4'b0100;
localparam WALKING1_DATA_MODE    =    4'b0101;
localparam WALKING0_DATA_MODE    =    4'b0110;
localparam PRBS_DATA_MODE        =    4'b0111;
assign data_o = data;
assign full_prbs_data = {DWIDTH/32{prbs_data}};
reg [3:0] data_mode_rr_a;
reg [3:0] data_mode_rr_b;
reg [3:0] data_mode_rr_c;
always @ (posedge clk_i)
begin
  data_mode_rr_a <= #TCQ data_mode_i;
  data_mode_rr_b <= #TCQ data_mode_i;
  data_mode_rr_c <= #TCQ data_mode_i;
end  
always @ (data_mode_i,rst_i) begin
  if (data_mode_i == 3'b101 || data_mode_i == 3'b100  || rst_i) begin 
    BLANK   = 8'h00;
    SHIFT_0 = 8'h01;
    SHIFT_1 = 8'h02;    
    SHIFT_2 = 8'h04;    
    SHIFT_3 = 8'h08;    
    SHIFT_4 = 8'h10;    
    SHIFT_5 = 8'h20;    
    SHIFT_6 = 8'h40;    
    SHIFT_7 = 8'h80;    
    end
    else  begin  
    BLANK   = 8'hff;
    SHIFT_0 = 8'hfe;
    SHIFT_1 = 8'hfd;    
    SHIFT_2 = 8'hfb;    
    SHIFT_3 = 8'hf7;    
    SHIFT_4 = 8'hef;    
    SHIFT_5 = 8'hdf;    
    SHIFT_6 = 8'hbf;    
    SHIFT_7 = 8'h7f;    
    end
end
always @ (data_mode_rr_a,fixed_data_i,h_prbsdata,adata,hdata,ndata,w1data,full_prbs_data)
begin
   case(data_mode_rr_a)
         4'b0000: data = h_prbsdata;
         4'b0001: data = fixed_data_i;   
         4'b0010: data = adata;   
         4'b0011: data = hdata;   
         4'b0100: data = ndata;   
         4'b0101: data = w1data;    
         4'b0110: data = w1data;  
         4'b0111: data = full_prbs_data;
         default : data = 'b0;
   endcase
end
function [4*NUM_DQ_PINS-1:0] Data_Gen (input integer i );
 integer j;
  begin
    j = i/2;
    Data_Gen = {4*NUM_DQ_PINS{1'b0}};
        if(i %2) begin
             Data_Gen[(0*NUM_DQ_PINS+j*8)+:8] = 8'b00010000;
             Data_Gen[(1*NUM_DQ_PINS+j*8)+:8] = 8'b00100000;
             Data_Gen[(2*NUM_DQ_PINS+j*8)+:8] = 8'b01000000;
             Data_Gen[(3*NUM_DQ_PINS+j*8)+:8] = 8'b10000000;
        end else begin
            Data_Gen[(0*NUM_DQ_PINS+j*8)+:8] = 8'b00000001;
            Data_Gen[(1*NUM_DQ_PINS+j*8)+:8] = 8'b00000010;
            Data_Gen[(2*NUM_DQ_PINS+j*8)+:8] = 8'b00000100;
            Data_Gen[(3*NUM_DQ_PINS+j*8)+:8] = 8'b00001000;
        end
  end
endfunction
function [4*NUM_DQ_PINS-1:0] Data_GenW0 (input integer i);
 integer j;
  begin
    j = i/2;
    Data_GenW0 = {4*NUM_DQ_PINS{1'b1}};
        if(i %2) begin
             Data_GenW0[(0*NUM_DQ_PINS+j*8)+:8] = 8'b11101111;
             Data_GenW0[(1*NUM_DQ_PINS+j*8)+:8] = 8'b11011111;
             Data_GenW0[(2*NUM_DQ_PINS+j*8)+:8] = 8'b10111111;
             Data_GenW0[(3*NUM_DQ_PINS+j*8)+:8] = 8'b01111111;
        end else begin
            Data_GenW0[(0*NUM_DQ_PINS+j*8)+:8] = 8'b11111110;
            Data_GenW0[(1*NUM_DQ_PINS+j*8)+:8] = 8'b11111101;
            Data_GenW0[(2*NUM_DQ_PINS+j*8)+:8] = 8'b11111011;
            Data_GenW0[(3*NUM_DQ_PINS+j*8)+:8] = 8'b11110111;
        end
  end
endfunction
always @ (posedge clk_i) begin
 if (data_mode_rr_c[2:0] == 3'b101  || data_mode_rr_c[2:0] == 3'b100 || data_mode_rr_c[2:0] == 3'b110)   
     sel_w1gen_logic <= #TCQ 1'b1;
 else
     sel_w1gen_logic <= #TCQ 1'b0;
end
generate
if (NUM_DQ_PINS == 8 && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0"  || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_8_PATTERN
always @ (posedge clk_i)
begin
if( (fifo_rdy_i ) || cmd_startC )
 if (cmd_startC ) 
    begin
    if (sel_w1gen_logic) begin  
             case (addr_i[3])
                 0: begin 
                    if (data_mode_i == 4'b0101)
                    w1data <= #TCQ Data_Gen(0);
                    else
                    w1data <= #TCQ Data_GenW0(0);
                    end
                 1:  begin 
                    if (data_mode_i == 4'b0101)
                    w1data <= #TCQ Data_Gen(1);
                    else
                    w1data <= #TCQ Data_GenW0(1);
                    end
                 default :begin
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
                    end
             endcase         
     end 
   end 
   else if( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
               end           
  end  
end 
endgenerate  
generate
if (NUM_DQ_PINS == 16 && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_16_PATTERN
always @ (posedge clk_i)   
begin     
if( (fifo_rdy_i ) || cmd_startC )
 if (cmd_startC )  
    begin
    if (sel_w1gen_logic) begin  
             case (addr_i[4:3])
                 0: begin 
                    if (data_mode_i == 4'b0101)
                    w1data <= #TCQ Data_Gen(0);
                    else
                    w1data <= #TCQ Data_GenW0(0);
                    end
                 1:  begin 
                    if (data_mode_i == 4'b0101)
                    w1data <= #TCQ Data_Gen(1);
                    else
                    w1data <= #TCQ Data_GenW0(1);
                    end
                  2: begin 
                    if (data_mode_i == 4'b0101)
                    w1data <= #TCQ Data_Gen(2);
                    else
                    w1data <= #TCQ Data_GenW0(2);
                    end
                 3:  begin 
                    if (data_mode_i == 4'b0101)
                    w1data <= #TCQ Data_Gen(3);
                    else
                    w1data <= #TCQ Data_GenW0(3);
                    end
                   default :begin
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
                    end
             endcase         
     end 
   end 
   else if( MEM_BURST_LEN == 8) begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
               end           
  end  
end   
endgenerate 
  generate
    if ((NUM_DQ_PINS == 24 ) && (DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_NEIGHBOR"
                                || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_24_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
            if (sel_w1gen_logic) begin
               case (addr_i[7:3])
                 0, 6, 12,
                 18, 24, 30 :
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1, 7, 13,
                 19, 25, 31 : 
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                 2,8,14,20,26         : 
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3,9,15,21,27         :
                                 if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                                 else
                                  w1data <=#TCQ  Data_GenW0(3);
                4, 10,
                16, 22, 28 : 
                           if (data_mode_i == 4'b0101)
                               w1data <= #TCQ  Data_Gen(4);
                           else
                               w1data <= #TCQ Data_GenW0(4);
                 5, 11,
                 17, 23, 29 : 
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
            endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if (NUM_DQ_PINS == 32 && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_32_PATTERN
      always @ (posedge clk_i) begin
         if( (fifo_rdy_i ) || cmd_startC )
           if (cmd_startC ) begin
             if (sel_w1gen_logic) begin
               case (addr_i[6:4])
                 0: 
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                 2:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
           endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 40 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_40_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
            if (sel_w1gen_logic) begin
               case (addr_i[7:4])
                 0, 10:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1, 11:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                 2, 12:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3, 13:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4, 14:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5, 15:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
                 8:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(8);
                              else
                                  w1data <= #TCQ Data_GenW0(8);
                 9:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(9);
                              else
                                  w1data <= #TCQ Data_GenW0(9);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
            endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 48 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_48_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
            if (sel_w1gen_logic) begin
               case (addr_i[7:4])
                 0, 12:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1, 13:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                 2, 14:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3, 15:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
                 8:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(8);
                              else
                                  w1data <= #TCQ Data_GenW0(8);
                 9:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(9);
                              else
                                  w1data <= #TCQ Data_GenW0(9);
                 10:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(10);
                              else
                                  w1data <= #TCQ Data_GenW0(10);
                 11:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(11);
                              else
                                  w1data <= #TCQ Data_GenW0(11);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
            endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 56 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_56_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
            if (sel_w1gen_logic) begin
               case (addr_i[8:5])
                 0, 14:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1, 15:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                 2:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
                 8:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(8);
                              else
                                  w1data <= #TCQ Data_GenW0(8);
                 9:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(9);
                              else
                                  w1data <= #TCQ Data_GenW0(9);
                 10:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(10);
                              else
                                  w1data <= #TCQ Data_GenW0(10);
                 11:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(11);
                              else
                                  w1data <= #TCQ Data_GenW0(11);
                 12:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(12);
                              else
                                  w1data <= #TCQ Data_GenW0(12);
                 13:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(13);
                              else
                                  w1data <= #TCQ Data_GenW0(13);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
            endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 64 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_64_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
             if (sel_w1gen_logic) begin
               case (addr_i[8:5])
                 0:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                 2:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
                 8:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(8);
                              else
                                  w1data <= #TCQ Data_GenW0(8);
                 9:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(9);
                              else
                                  w1data <= #TCQ Data_GenW0(9);
                 10:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(10);
                              else
                                  w1data <= #TCQ Data_GenW0(10);
                 11:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(11);
                              else
                                  w1data <= #TCQ Data_GenW0(11);
                 12:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(12);
                              else
                                  w1data <= #TCQ Data_GenW0(12);
                 13:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(13);
                              else
                                  w1data <= #TCQ Data_GenW0(13);
                 14:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(14);
                              else
                                  w1data <= #TCQ Data_GenW0(14);
                 15:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(15);
                              else
                                  w1data <= #TCQ Data_GenW0(15);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
            endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 72 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_72_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
            if (sel_w1gen_logic) begin
              case (addr_i[9:5])
                 0, 18:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1, 19:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                 2, 20:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3, 21:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4, 22:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5, 23:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6, 24:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7, 25:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
                8, 26:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(8);
                              else
                                  w1data <= #TCQ Data_GenW0(8);
                 9, 27:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(9);
                              else
                                  w1data <= #TCQ Data_GenW0(9);
                 10, 28:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(10);
                              else
                                  w1data <= #TCQ Data_GenW0(10);
                 11, 29:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(11);
                              else
                                  w1data <= #TCQ Data_GenW0(11);
                 12, 30:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(12);
                              else
                                  w1data <= #TCQ Data_GenW0(12);
                 13, 31:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(13);
                              else
                                  w1data <= #TCQ Data_GenW0(13);
                 14:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(14);
                              else
                                  w1data <= #TCQ Data_GenW0(14);
                 15:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(15);
                              else
                                  w1data <= #TCQ Data_GenW0(15);
                 16:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(16);
                              else
                                  w1data <= #TCQ Data_GenW0(16);
                 17:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(17);
                              else
                                  w1data <= #TCQ Data_GenW0(17);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
            endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 80 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_80_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
            if (sel_w1gen_logic) begin
              case (addr_i[9:5])
                 0, 20:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1, 21:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                 2, 22:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3, 23:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4, 24:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5, 25:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6, 26:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7, 27:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
                 8, 28:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(8);
                              else
                                  w1data <= #TCQ Data_GenW0(8);
                 9, 29:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(9);
                              else
                                  w1data <= #TCQ Data_GenW0(9);
                 10, 30:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(10);
                              else
                                  w1data <= #TCQ Data_GenW0(10);
                 11, 31:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(11);
                              else
                                  w1data <= #TCQ Data_GenW0(11);
                 12:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(12);
                              else
                                  w1data <= #TCQ Data_GenW0(12);
                 13:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(13);
                              else
                                  w1data <= #TCQ Data_GenW0(13);
                 14:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(14);
                              else
                                  w1data <= #TCQ Data_GenW0(14);
                 15:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(15);
                              else
                                  w1data <= #TCQ Data_GenW0(15);
                 16:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(16);
                              else
                                  w1data <= #TCQ Data_GenW0(16);
                 17:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(17);
                              else
                                  w1data <= #TCQ Data_GenW0(17);
                  18:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(18);
                              else
                                  w1data <= #TCQ Data_GenW0(18);
                 19:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(19);
                              else
                                  w1data <= #TCQ Data_GenW0(19);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
            endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 88 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_88_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
            if (sel_w1gen_logic) begin
              case (addr_i[9:5])
                 0, 22:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1, 23:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                 2, 24:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3, 25:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4, 26:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5, 27:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6, 28:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7, 29:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
                 8, 30:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(8);
                              else
                                  w1data <= #TCQ Data_GenW0(8);
                 9, 31:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(9);
                              else
                                  w1data <= #TCQ Data_GenW0(9);
                 10:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(10);
                              else
                                  w1data <= #TCQ Data_GenW0(10);
                 11:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(11);
                              else
                                  w1data <= #TCQ Data_GenW0(11);
                 12:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(12);
                              else
                                  w1data <= #TCQ Data_GenW0(12);
                 13:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(13);
                              else
                                  w1data <= #TCQ Data_GenW0(13);
                 14:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(14);
                              else
                                  w1data <= #TCQ Data_GenW0(14);
                 15:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(15);
                              else
                                  w1data <= #TCQ Data_GenW0(15);
                 16:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(16);
                              else
                                  w1data <= #TCQ Data_GenW0(16);
                 17:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(17);
                              else
                                  w1data <= #TCQ Data_GenW0(17);
                 18:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(18);
                              else
                                  w1data <= #TCQ Data_GenW0(18);
                 19:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(19);
                              else
                                  w1data <= #TCQ Data_GenW0(19);
                 20:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(20);
                              else
                                  w1data <= #TCQ Data_GenW0(20);
                 21:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(21);
                              else
                                  w1data <= #TCQ Data_GenW0(21);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
            endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 96 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_96_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
            if (sel_w1gen_logic) begin
               case (addr_i[9:5])
                 0, 24:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1, 25:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                  2, 26:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3, 27:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4, 28:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5, 29:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6, 30:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7, 31:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
                 8:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(8);
                              else
                                  w1data <= #TCQ Data_GenW0(8);
                 9:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(9);
                              else
                                  w1data <= #TCQ Data_GenW0(9);
                 10:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(10);
                              else
                                  w1data <= #TCQ Data_GenW0(10);
                 11:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(11);
                              else
                                  w1data <= #TCQ Data_GenW0(11);
                 12:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(12);
                              else
                                  w1data <= #TCQ Data_GenW0(12);
                 13:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(13);
                              else
                                  w1data <= #TCQ Data_GenW0(13);
                 14:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(14);
                              else
                                  w1data <= #TCQ Data_GenW0(14);
                 15:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(15);
                              else
                                  w1data <= #TCQ Data_GenW0(15);
                 16:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(16);
                              else
                                  w1data <= #TCQ Data_GenW0(16);
                 17:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(17);
                              else
                                  w1data <= #TCQ Data_GenW0(17);
                 18:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(18);
                              else
                                  w1data <= #TCQ Data_GenW0(18);
                 19:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(19);
                              else
                                  w1data <= #TCQ Data_GenW0(19);
                 20:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(20);
                              else
                                  w1data <= #TCQ Data_GenW0(20);
                 21:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(21);
                              else
                                  w1data <= #TCQ Data_GenW0(21);
                 22:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(22);
                              else
                                  w1data <= #TCQ Data_GenW0(22);
                 23:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(23);
                              else
                                  w1data <= #TCQ Data_GenW0(23);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
            endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 104 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_104_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
            if (sel_w1gen_logic) begin
               case (addr_i[9:5])
                 0, 26:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1, 27:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                  2, 28:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3, 29:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4, 30:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5, 31:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6 :
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
                  8:  
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(8);
                               else
                                   w1data <= #TCQ Data_GenW0(8);
                  9:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(9);
                               else
                                   w1data <= #TCQ Data_GenW0(9);
                  10:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(10);
                               else
                                   w1data <= #TCQ Data_GenW0(10);
                  11:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(11);
                               else
                                   w1data <= #TCQ Data_GenW0(11);
                  12:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(12);
                               else
                                   w1data <= #TCQ Data_GenW0(12);
                  13:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(13);
                               else
                                   w1data <= #TCQ Data_GenW0(13);
                  14:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(14);
                               else
                                   w1data <= #TCQ Data_GenW0(14);
                  15:
                                  if (data_mode_i == 4'b0101)
                                      w1data <= #TCQ Data_Gen(15);
                                  else
                                      w1data <= #TCQ Data_GenW0(15);
                    16:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(16);
                                 else
                                     w1data <= #TCQ Data_GenW0(16);
                    17:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(17);
                                 else
                                     w1data <= #TCQ Data_GenW0(17);
                    18:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(18);
                                 else
                                     w1data <= #TCQ Data_GenW0(18);
                    19:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(19);
                                 else
                                     w1data <= #TCQ Data_GenW0(19);
                    20:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(20);
                                 else
                                     w1data <= #TCQ Data_GenW0(20);
                    21:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(21);
                                 else
                                     w1data <= #TCQ Data_GenW0(21);
                    22:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(22);
                                 else
                                     w1data <= #TCQ Data_GenW0(22);
                    23:
                                  if (data_mode_i == 4'b0101)
                                      w1data <= #TCQ Data_Gen(23);
                                  else
                                      w1data <= #TCQ Data_GenW0(23);
                    24:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(24);
                              else
                                  w1data <= #TCQ Data_GenW0(24);
                    25:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(25);
                              else
                                  w1data <= #TCQ Data_GenW0(25);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;                  
            endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if((NUM_DQ_PINS == 112 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_112_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
            if (sel_w1gen_logic) begin
               case (addr_i[9:5])
                 0, 28:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1, 29:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                 2, 30:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3, 31:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6 :
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
                  8:  
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(8);
                               else
                                   w1data <= #TCQ Data_GenW0(8);
                  9:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(9);
                               else
                                   w1data <= #TCQ Data_GenW0(9);
                  10:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(10);
                               else
                                   w1data <= #TCQ Data_GenW0(10);
                  11:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(11);
                               else
                                   w1data <= #TCQ Data_GenW0(11);
                  12:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(12);
                               else
                                   w1data <= #TCQ Data_GenW0(12);
                  13:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(13);
                               else
                                   w1data <= #TCQ Data_GenW0(13);
                  14:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(14);
                               else
                                   w1data <= #TCQ Data_GenW0(14);
                  15:
                                  if (data_mode_i == 4'b0101)
                                      w1data <= #TCQ Data_Gen(15);
                                  else
                                      w1data <= #TCQ Data_GenW0(15);
                    16:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(16);
                                 else
                                     w1data <= #TCQ Data_GenW0(16);
                    17:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(17);
                                 else
                                     w1data <= #TCQ Data_GenW0(17);
                    18:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(18);
                                 else
                                     w1data <= #TCQ Data_GenW0(18);
                    19:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(19);
                                 else
                                     w1data <= #TCQ Data_GenW0(19);
                    20:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(20);
                                 else
                                     w1data <= #TCQ Data_GenW0(20);
                    21:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(21);
                                 else
                                     w1data <= #TCQ Data_GenW0(21);
                    22:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(22);
                                 else
                                     w1data <= #TCQ Data_GenW0(22);
                    23:
                                  if (data_mode_i == 4'b0101)
                                      w1data <= #TCQ Data_Gen(23);
                                  else
                                      w1data <= #TCQ Data_GenW0(23);
                    24:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(24);
                              else
                                  w1data <= #TCQ Data_GenW0(24);
                    25:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(25);
                              else
                                  w1data <= #TCQ Data_GenW0(25);
                    26:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(26);
                              else
                                  w1data <= #TCQ Data_GenW0(26);
                    27:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(27);
                              else
                                  w1data <= #TCQ Data_GenW0(27);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
            endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 120 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_120_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
            if (sel_w1gen_logic) begin
               case (addr_i[9:5])
                  0, 30:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                  1, 31:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                  2:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                  3:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6 :
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
                  8:  
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(8);
                               else
                                   w1data <= #TCQ Data_GenW0(8);
                  9:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(9);
                               else
                                   w1data <= #TCQ Data_GenW0(9);
                  10:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(10);
                               else
                                   w1data <= #TCQ Data_GenW0(10);
                  11:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(11);
                               else
                                   w1data <= #TCQ Data_GenW0(11);
                  12:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(12);
                               else
                                   w1data <= #TCQ Data_GenW0(12);
                  13:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(13);
                               else
                                   w1data <= #TCQ Data_GenW0(13);
                  14:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(14);
                               else
                                   w1data <= #TCQ Data_GenW0(14);
                  15:
                                  if (data_mode_i == 4'b0101)
                                      w1data <= #TCQ Data_Gen(15);
                                  else
                                      w1data <= #TCQ Data_GenW0(15);
                    16:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(16);
                                 else
                                     w1data <= #TCQ Data_GenW0(16);
                    17:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(17);
                                 else
                                     w1data <= #TCQ Data_GenW0(17);
                    18:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(18);
                                 else
                                     w1data <= #TCQ Data_GenW0(18);
                    19:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(19);
                                 else
                                     w1data <= #TCQ Data_GenW0(19);
                    20:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(20);
                                 else
                                     w1data <= #TCQ Data_GenW0(20);
                    21:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(21);
                                 else
                                     w1data <= #TCQ Data_GenW0(21);
                    22:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(22);
                                 else
                                     w1data <= #TCQ Data_GenW0(22);
                    23:
                                  if (data_mode_i == 4'b0101)
                                      w1data <= #TCQ Data_Gen(23);
                                  else
                                      w1data <= #TCQ Data_GenW0(23);
                    24:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(24);
                              else
                                  w1data <= #TCQ Data_GenW0(24);
                    25:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(25);
                              else
                                  w1data <= #TCQ Data_GenW0(25);
                    26:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(26);
                              else
                                  w1data <= #TCQ Data_GenW0(26);
                    27:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(27);
                              else
                                  w1data <= #TCQ Data_GenW0(27);
                    28:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(28);
                              else
                                  w1data <= #TCQ Data_GenW0(28);
                    29:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(29);
                              else
                                  w1data <= #TCQ Data_GenW0(29);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
              endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 128 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_128_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
             if (sel_w1gen_logic) begin
               case (addr_i[10:6])
                 0:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                  2:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                  3:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6 :
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
                  8:  
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(8);
                               else
                                   w1data <= #TCQ Data_GenW0(8);
                  9:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(9);
                               else
                                   w1data <= #TCQ Data_GenW0(9);
                  10:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(10);
                               else
                                   w1data <= #TCQ Data_GenW0(10);
                  11:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(11);
                               else
                                   w1data <= #TCQ Data_GenW0(11);
                  12:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(12);
                               else
                                   w1data <= #TCQ Data_GenW0(12);
                  13:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(13);
                               else
                                   w1data <= #TCQ Data_GenW0(13);
                  14:
                               if (data_mode_i == 4'b0101)
                                   w1data <= #TCQ Data_Gen(14);
                               else
                                   w1data <= #TCQ Data_GenW0(14);
                  15:
                                  if (data_mode_i == 4'b0101)
                                      w1data <= #TCQ Data_Gen(15);
                                  else
                                      w1data <= #TCQ Data_GenW0(15);
                    16:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(16);
                                 else
                                     w1data <= #TCQ Data_GenW0(16);
                    17:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(17);
                                 else
                                     w1data <= #TCQ Data_GenW0(17);
                    18:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(18);
                                 else
                                     w1data <= #TCQ Data_GenW0(18);
                    19:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(19);
                                 else
                                     w1data <= #TCQ Data_GenW0(19);
                    20:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(20);
                                 else
                                     w1data <= #TCQ Data_GenW0(20);
                    21:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(21);
                                 else
                                     w1data <= #TCQ Data_GenW0(21);
                    22:
                                 if (data_mode_i == 4'b0101)
                                     w1data <= #TCQ Data_Gen(22);
                                 else
                                     w1data <= #TCQ Data_GenW0(22);
                    23:
                                  if (data_mode_i == 4'b0101)
                                      w1data <= #TCQ Data_Gen(23);
                                  else
                                      w1data <= #TCQ Data_GenW0(23);
                    24:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(24);
                              else
                                  w1data <= #TCQ Data_GenW0(24);
                    25:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(25);
                              else
                                  w1data <= #TCQ Data_GenW0(25);
                    26:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(26);
                              else
                                  w1data <= #TCQ Data_GenW0(26);
                    27:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(27);
                              else
                                  w1data <= #TCQ Data_GenW0(27);
                    28:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(28);
                              else
                                  w1data <= #TCQ Data_GenW0(28);
                    29:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(29);
                              else
                                  w1data <= #TCQ Data_GenW0(29);
                    30:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(30);
                              else
                                  w1data <= #TCQ Data_GenW0(30);
                    31:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(31);
                              else
                                  w1data <= #TCQ Data_GenW0(31);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
            endcase
       end
     end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 136 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_136_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
          if (cmd_startC ) begin
            if (sel_w1gen_logic) begin
              case (addr_i[11:6])
               0:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
               1, 35:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
               2, 36:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
               3, 37:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
               4, 38:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
               5, 39:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
               6, 40:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
               7, 41:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                  w1data <= #TCQ Data_GenW0(7);
               8, 42:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(8);
                              else
                                  w1data <= #TCQ Data_GenW0(8);
               9, 43:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(9);
                              else
                                  w1data <= #TCQ Data_GenW0(9);
               10, 44:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(10);
                              else
                                  w1data <= #TCQ Data_GenW0(10);
               11, 45:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(11);
                              else
                                  w1data <= #TCQ Data_GenW0(11);
               12, 46:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(12);
                              else
                                  w1data <= #TCQ Data_GenW0(12);
               13, 47:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(13);
                              else
                                  w1data <= #TCQ Data_GenW0(13);
               14, 48:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(14);
                              else
                                  w1data <= #TCQ Data_GenW0(14);
               15, 49:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(15);
                              else
                                  w1data <= #TCQ Data_GenW0(15);
               16, 50:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(16);
                              else
                                  w1data <= #TCQ Data_GenW0(16);
               17, 51:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(17);
                              else
                                  w1data <= #TCQ Data_GenW0(17);
               18, 52:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(18);
                              else
                                  w1data <= #TCQ Data_GenW0(18);
               19, 53:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(19);
                              else
                                  w1data <= #TCQ Data_GenW0(19);
               20, 54:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(20);
                              else
                                  w1data <= #TCQ Data_GenW0(20);
               21, 55:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(21);
                              else
                                  w1data <= #TCQ Data_GenW0(21);
               22, 56:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(22);
                              else
                                  w1data <= #TCQ Data_GenW0(22);
               23, 57:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(23);
                              else
                                  w1data <= #TCQ Data_GenW0(23);
               24, 58:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(24);
                              else
                                  w1data <= #TCQ Data_GenW0(24);
               25, 59:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(25);
                              else
                                  w1data <= #TCQ Data_GenW0(25);
               26, 60:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(26);
                              else
                                  w1data <= #TCQ Data_GenW0(26);
               27, 61:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(27);
                              else
                                  w1data <= #TCQ Data_GenW0(27);
               28, 62:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(28);
                              else
                                  w1data <= #TCQ Data_GenW0(28);
               29, 63:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(29);
                              else
                                  w1data <= #TCQ Data_GenW0(29);
               30:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(30);
                              else
                                  w1data <= #TCQ Data_GenW0(30);
               31:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(31);
                              else
                                  w1data <= #TCQ Data_GenW0(31);
               32:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(32);
                              else
                                  w1data <= #TCQ Data_GenW0(32);
               33:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(33);
                              else
                                  w1data <= #TCQ Data_GenW0(33);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
             endcase
         end
      end
   else if ( MEM_BURST_LEN == 8)  begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
  generate
    if ((NUM_DQ_PINS == 144 ) && (DATA_PATTERN == "DGEN_NEIGHBOR" || DATA_PATTERN == "DGEN_WALKING1" || DATA_PATTERN == "DGEN_WALKING0" || DATA_PATTERN == "DGEN_ALL"))  begin : WALKING_ONE_144_PATTERN
      always @ (posedge clk_i) begin
        if( (fifo_rdy_i ) || cmd_startC )
           if (cmd_startC ) begin
              if (sel_w1gen_logic) begin
                case (addr_i[11:6])
                 0, 36:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(0);
                              else
                                  w1data <= #TCQ Data_GenW0(0);
                 1, 37 :
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(1);
                              else
                                  w1data <= #TCQ Data_GenW0(1);
                 2, 38:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(2);
                              else
                                  w1data <= #TCQ Data_GenW0(2);
                 3, 39 :
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(3);
                              else
                                  w1data <= #TCQ Data_GenW0(3);
                 4, 40 :
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(4);
                              else
                                  w1data <= #TCQ Data_GenW0(4);
                 5, 41:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(5);
                              else
                                  w1data <= #TCQ Data_GenW0(5);
                 6, 42:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(6);
                              else
                                  w1data <= #TCQ Data_GenW0(6);
                 7, 43:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(7);
                              else
                                 w1data <= #TCQ Data_GenW0(7);
                 8, 44:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(8);
                              else
                                  w1data <= #TCQ Data_GenW0(8);
                 9, 45:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(9);
                              else
                                  w1data <= #TCQ Data_GenW0(9);
                 10, 46:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(10);
                              else
                                  w1data <= #TCQ Data_GenW0(10);
                 11, 47 :
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(11);
                              else
                                  w1data <= #TCQ Data_GenW0(11);
                 12, 48 :
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(12);
                              else
                                  w1data <= #TCQ Data_GenW0(12);
                 13, 49 :
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(13);
                              else
                                  w1data <= #TCQ Data_GenW0(13);
                 14, 50:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(14);
                              else
                                  w1data <= #TCQ Data_GenW0(14);
                 15, 51 :
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(15);
                              else
                                  w1data <= #TCQ Data_GenW0(15);
                 16, 52 :
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(16);
                              else
                                  w1data <= #TCQ Data_GenW0(16);
                 17 , 53:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(17);
                              else
                                  w1data <= #TCQ Data_GenW0(17);
                 18, 54:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(18);
                              else
                                 w1data <= #TCQ Data_GenW0(18);
                 19, 55:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(19);
                              else
                                  w1data <= #TCQ Data_GenW0(19);
                 20, 56:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(20);
                              else
                                  w1data <= #TCQ Data_GenW0(20);
                 21, 57:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(21);
                              else
                                  w1data <= #TCQ Data_GenW0(21);
                 22, 58:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(22);
                              else
                                  w1data <= #TCQ Data_GenW0(22);
                 23, 59:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(23);
                              else
                                  w1data <= #TCQ Data_GenW0(23);
                 24, 60:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(24);
                              else
                                  w1data <= #TCQ Data_GenW0(24);
                 25, 61:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(25);
                              else
                                  w1data <= #TCQ Data_GenW0(25);
                 26, 62:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(26);
                              else
                                  w1data <= #TCQ Data_GenW0(26);
                 27, 63:
                             if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(27);
                              else
                                  w1data <= #TCQ Data_GenW0(27);
                    28:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(28);
                              else
                                  w1data <= #TCQ Data_GenW0(28);
                    29:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(29);
                              else
                                  w1data <= #TCQ Data_GenW0(29);
                    30:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(30);
                              else
                                  w1data <= #TCQ Data_GenW0(30);
                    31:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(31);
                              else
                                  w1data <= #TCQ Data_GenW0(31);
                     32:
                                  if (data_mode_i == 4'b0101)
                                      w1data <= #TCQ Data_Gen(32);
                                  else
                                      w1data <= #TCQ Data_GenW0(32);
                     33:
                                  if (data_mode_i == 4'b0101)
                                      w1data <= #TCQ Data_Gen(33);
                                  else
                                      w1data <= #TCQ Data_GenW0(33);
                     34:
                                  if (data_mode_i == 4'b0101)
                                      w1data <= #TCQ Data_Gen(34);
                                  else
                                      w1data <= #TCQ Data_GenW0(34);
                     35:
                              if (data_mode_i == 4'b0101)
                                  w1data <= #TCQ Data_Gen(35);
                              else
                                  w1data <= #TCQ Data_GenW0(35);
                 default :
                    w1data[4*NUM_DQ_PINS-1:0*NUM_DQ_PINS ] <= #TCQ 'b0;    
              endcase
     end
   end
   else if ( MEM_BURST_LEN == 8) begin
              w1data[4*NUM_DQ_PINS - 1:3*NUM_DQ_PINS] <= #TCQ {w1data[4*NUM_DQ_PINS - 5:3*NUM_DQ_PINS  ],w1data[4*NUM_DQ_PINS - 1:4*NUM_DQ_PINS - 4]};
              w1data[3*NUM_DQ_PINS - 1:2*NUM_DQ_PINS] <= #TCQ {w1data[3*NUM_DQ_PINS - 5:2*NUM_DQ_PINS  ],w1data[3*NUM_DQ_PINS - 1:3*NUM_DQ_PINS - 4]};
              w1data[2*NUM_DQ_PINS - 1:1*NUM_DQ_PINS] <= #TCQ {w1data[2*NUM_DQ_PINS - 5:1*NUM_DQ_PINS  ],w1data[2*NUM_DQ_PINS - 1:2*NUM_DQ_PINS - 4]};
              w1data[1*NUM_DQ_PINS - 1:0*NUM_DQ_PINS] <= #TCQ {w1data[1*NUM_DQ_PINS - 5:0*NUM_DQ_PINS  ],w1data[1*NUM_DQ_PINS - 1:1*NUM_DQ_PINS - 4]};
        end
      end
    end
  endgenerate
always @ (posedge clk_i) begin
for (i=0; i <= 4*NUM_DQ_PINS - 1; i= i+1)
      if (i == SEL_VICTIM_LINE || (i-NUM_DQ_PINS) == SEL_VICTIM_LINE ||
          (i-(NUM_DQ_PINS*2)) ==  SEL_VICTIM_LINE || (i-(NUM_DQ_PINS*3)) == SEL_VICTIM_LINE)
              hdata[i] <= #TCQ 1'b1;
      else if ( i >= 0 && i <= 1*NUM_DQ_PINS - 1)
              hdata[i] <= #TCQ 1'b1;
      else if ( i >= 1*NUM_DQ_PINS && i <= 2*NUM_DQ_PINS - 1)
              hdata[i] <= #TCQ 1'b0;
      else if ( i >= 2*NUM_DQ_PINS && i <= 3*NUM_DQ_PINS - 1)
              hdata[i] <= #TCQ 1'b1;
      else if ( i >= 3*NUM_DQ_PINS && i <= 4*NUM_DQ_PINS - 1)
              hdata[i] <= #TCQ 1'b0;
      else 
              hdata[i] <= 1'b1;
end
always @ (w1data,hdata)
begin
for (i=0; i <= 4*NUM_DQ_PINS - 1; i= i+1)
   ndata[i] = hdata[i] ^ w1data[i];
         end
always @ (full_prbs_data,hdata,SEL_VICTIM_LINE)
begin
for (i=0; i <= 4*NUM_DQ_PINS - 1; i= i+1)
      if (i == SEL_VICTIM_LINE || (i-NUM_DQ_PINS) == SEL_VICTIM_LINE ||
          (i-(NUM_DQ_PINS*2)) == SEL_VICTIM_LINE || (i-(NUM_DQ_PINS*3)) == SEL_VICTIM_LINE)
               h_prbsdata[i] = full_prbs_data[SEL_VICTIM_LINE];
      else
                 h_prbsdata[i] = hdata[i];
         end
generate
if (DATA_PATTERN == "DGEN_ADDR"  || DATA_PATTERN == "DGEN_ALL")  begin : ADDRESS_PATTERN
always @ (posedge clk_i)
begin
  if (cmd_startD) 
         acounts[35:0]  <= #TCQ {4'b0000,addr_i}; 
  else if (fifo_rdy_i && data_rdy_i && MEM_BURST_LEN == 8 )
      if (NUM_DQ_PINS == 8)
         acounts <= #TCQ acounts + 4;
      else if (NUM_DQ_PINS == 16 || NUM_DQ_PINS == 24)
         acounts <= #TCQ acounts + 8;
      else if (NUM_DQ_PINS >= 32 && NUM_DQ_PINS < 64) 
         acounts <= #TCQ acounts + 16;
      else if (NUM_DQ_PINS >= 64 && NUM_DQ_PINS < 128 ) 
         acounts <= #TCQ acounts + 32;
      else if (NUM_DQ_PINS >= 128 && NUM_DQ_PINS < 256 )
         acounts <= #TCQ acounts + 64;
end
assign    adata = {DWIDTH/32{acounts[31:0]}};
end                   
endgenerate
generate
if (EYE_TEST == "TRUE")  begin : d_clk_en1
assign data_clk_en = 1'b1;
end 
endgenerate
generate
if (EYE_TEST == "FALSE")  begin : d_clk_en2
assign data_clk_en = fifo_rdy_i && data_rdy_i && user_burst_cnt > 6'd1;
end 
endgenerate
generate
if (DATA_PATTERN == "DGEN_PRBS"  || DATA_PATTERN == "DGEN_ALL")  begin : PRBS_PATTERN
data_prbs_gen #
  (
    .PRBS_WIDTH (32),  
    .SEED_WIDTH (32),
    .EYE_TEST   (EYE_TEST)
   )
   data_prbs_gen
  (
   .clk_i            (clk_i),
   .rst_i            (rst_i),
   .clk_en           (data_clk_en),
   .prbs_fseed_i     (prbs_fseed_i),
   .prbs_seed_init   (cmd_startE),
   .prbs_seed_i      ({m_addr_i[6],m_addr_i[31],m_addr_i[8],m_addr_i[22],m_addr_i[9],m_addr_i[24],m_addr_i[21],m_addr_i[23],
                       m_addr_i[18],m_addr_i[10],m_addr_i[20],m_addr_i[17],m_addr_i[13],m_addr_i[16],m_addr_i[12],m_addr_i[4],
                       m_addr_i[15:0]}),
   .prbs_o           (prbs_data)
  );       
end        
endgenerate
endmodule 
