`timescale 1ns / 1ps
`timescale 1ns / 1ps
module rx_trn_monitor(
	input  wire         clk,
	input  wire         rst,
	input  wire         rd_dma_start,  
	input  wire  [31:0] dmarad,        
	input  wire  [31:0] dmarxs,        
	output reg          rd_dma_done,   
	input  wire         read_last,
	input  wire         Wait_for_TX_desc,
	input  wire         transferstart,     
	output reg [4:0]  rx_waddr,
	output reg [31:0] rx_wdata,
	output reg        rx_we,
	output wire [4:0] rx_raddr,
	input [31:0]      rx_rdata,
	output reg        pending_comp_done,
	input [31:0]      completion_pending,
	input wire [63:0] trn_rd,
	input wire [7:0] trn_rrem_n,
	input wire trn_rsof_n,
	input wire trn_reof_n,
	input wire trn_rsrc_rdy_n,
	input wire trn_rsrc_dsc_n,
	input wire trn_rerrfwd_n,
	input wire [6:0] trn_rbar_hit_n,
	input wire [11:0] trn_rfc_npd_av,
	input wire [7:0] trn_rfc_nph_av,
	input wire [11:0] trn_rfc_pd_av,
	input wire [7:0] trn_rfc_ph_av,
	input wire [11:0] trn_rfc_cpld_av,
	input wire [7:0] trn_rfc_cplh_av,
	input wire fourdw_n_threedw, 
	input wire payload,
	input wire [2:0] tc, 
	input wire td, 
	input wire ep,  
	input wire [1:0] attr,
	input wire [9:0] dw_length,
	input wire [15:0] MEM_req_id,
	input wire [7:0] MEM_tag,
	input wire [15:0]   CMP_comp_id,
	input wire [2:0]CMP_compl_stat,
	input wire  CMP_bcm,
	input wire [11:0] CMP_byte_count,
	input wire [63:0] MEM_addr,  
	input wire [15:0] CMP_req_id,
	input wire [7:0] CMP_tag,
	input wire [6:0] CMP_lower_addr,
	input wire    MRd,
	input wire    MWr,
	input wire    CplD,
	input wire    Msg,
	input wire    UR,
	input wire header_fields_valid,
	input wire data_valid,
	output reg isDes,   
	output wire [27:6] mem_dest_addr,
	output reg [10:0] mem_dma_size,
	output wire mem_dma_start,
	output wire [9:0] np_rx_cnt_qw,
	output reg [9:0] Debug30RXEngine
);
localparam IDLE            = 5'b00000;
localparam CALC_NEXT_ADDR  = 5'b00001;
localparam WRITEBACK_ADDR  = 5'b00010;
localparam WRITEBACK_ADDR2 = 5'b00011;
localparam AS_IDLE         = 2'b00;
localparam REGISTER_CALC   = 2'b01;
localparam WAIT_FOR_REG    = 2'b10;
reg [63:0] trn_rd_d1;
reg [7:0] trn_rrem_d1_n;
reg trn_rsof_d1_n;
reg trn_reof_d1_n;
reg trn_rsrc_rdy_d1_n;
reg trn_rsrc_dsc_d1_n;
reg trn_rerrfwd_d1_n;
reg [6:0] trn_rbar_hit_d1_n;
reg [11:0] trn_rfc_npd_av_d1;
reg [7:0] trn_rfc_nph_av_d1;
reg [11:0] trn_rfc_pd_av_d1;
reg [7:0] trn_rfc_ph_av_d1;
reg [11:0] trn_rfc_cpld_av_d1;
reg [7:0] trn_rfc_cplh_av_d1;
reg [27:6] cur_dest_addr; 
reg [4:0] memctrl_state;
reg [1:0] addsub_state;
wire header_fields_valid_one;
wire [27:6] next_mem_dest_addr;
reg data_valid_reg;
reg CplD_r1, CplD_r2;
reg add_calc = 0;
reg sub_calc = 0;
reg add_complete;
reg sub_complete;
reg stay_2x;
reg update_dmarxs_div8_reg;
reg [9:0] dmarxs_div8_reg_new;
reg [9:0] dw_length_d1;
reg [9:0] dmarxs_div8_reg;
reg [9:0] dmarxs_div8_now;
wire rd_dma_done_early, rd_dma_done_early_one;
reg rd_dma_done_i; 
wire rd_dma_done_one; 
reg   rst_reg;
always@(posedge clk) rst_reg <= rst;
always@(posedge clk) begin
   Debug30RXEngine[9:0]   <= dmarxs_div8_now[9:0];
end
wire rd_dma_start_one;
reg rd_dma_start_reg;
rising_edge_detect rd_dma_start_one_inst(
                .clk(clk),
                .rst(rst_reg),
                .in(rd_dma_start_reg),
                .one_shot_out(rd_dma_start_one)
                );
always@(posedge clk) 
        rd_dma_start_reg <= rd_dma_start;
always @ (posedge clk)
begin
    trn_rd_d1[63:0]          <= trn_rd[63:0]         ;
    trn_rrem_d1_n[7:0]       <= trn_rrem_n[7:0]      ;
    trn_rsof_d1_n            <= trn_rsof_n           ;
    trn_reof_d1_n            <= trn_reof_n           ;
    trn_rsrc_rdy_d1_n        <= trn_rsrc_rdy_n       ;
    trn_rsrc_dsc_d1_n        <= trn_rsrc_dsc_n       ;
    trn_rerrfwd_d1_n         <= trn_rerrfwd_n        ;
    trn_rbar_hit_d1_n[6:0]   <= trn_rbar_hit_n[6:0]  ;
    trn_rfc_npd_av_d1[11:0]  <= trn_rfc_npd_av[11:0] ;
    trn_rfc_nph_av_d1[7:0]   <= trn_rfc_nph_av[7:0]  ;
    trn_rfc_pd_av_d1[11:0]   <= trn_rfc_pd_av[11:0]  ;
    trn_rfc_ph_av_d1[7:0]    <= trn_rfc_ph_av[7:0]   ;
    trn_rfc_cpld_av_d1[11:0] <= trn_rfc_cpld_av[11:0];
    trn_rfc_cplh_av_d1[7:0]  <= trn_rfc_cplh_av[7:0] ;
end
assign   rx_raddr[4:0] = CMP_tag[4:0]; 
always@(posedge clk)begin
   if(rst_reg)begin
      memctrl_state <= IDLE;
      cur_dest_addr[27:6] <= 0;
		isDes <= 0;                      
      rx_waddr <= 0;
      rx_wdata <= 0;
      rx_we <= 1'b0;
      pending_comp_done <= 1'b0;
   end else begin
      case(memctrl_state)
         IDLE:begin
            rx_waddr[4:0] <= 5'b00000;
            rx_wdata[31:0] <= 32'h00000000;
            rx_we <= 1'b0;
            pending_comp_done <= 1'b0;
             if(header_fields_valid_one && CplD)begin    
                memctrl_state <=  CALC_NEXT_ADDR; 
                cur_dest_addr[27:6] <= rx_rdata[21:0];
					 isDes <= rx_rdata[31];                    
             end else begin
                memctrl_state <= IDLE;
             end
         end
         CALC_NEXT_ADDR:begin 
            memctrl_state <= WRITEBACK_ADDR;
         end
         WRITEBACK_ADDR:begin 
            memctrl_state <= WRITEBACK_ADDR2;
            rx_waddr[4:0] <= rx_raddr[4:0];
            rx_wdata[31:0] <= {10'b0000000000, next_mem_dest_addr[27:6]};
            rx_we <= 1'b1;
            if(dw_length[9:0] == CMP_byte_count[11:2]) 
                pending_comp_done <= 1'b1;
            else
                pending_comp_done <= 1'b0;
         end
         WRITEBACK_ADDR2:begin 
            memctrl_state <= IDLE;
         end
         default:begin
            cur_dest_addr[27:6] <= 0;
            rx_waddr <= 0;
            rx_wdata <= 0;
            rx_we <= 1'b0;
            pending_comp_done <= 1'b0;
         end
      endcase
    end
  end  
rising_edge_detect header_fields_valid_one_inst(  
                .clk(clk),
                .rst(rst_reg),
                .in(header_fields_valid), 
                .one_shot_out(header_fields_valid_one)
                );    
assign  next_mem_dest_addr[27:6] = (dw_length[9:0] != 10'b0000000000) 
                                 ? cur_dest_addr[27:6] + dw_length[9:4]  
                                 : cur_dest_addr[27:6] + 7'b1000000;     
assign mem_dest_addr[27:6] = cur_dest_addr[27:6];
always@(posedge clk)begin
   if(rst_reg)begin
      mem_dma_size[10:0] <= 11'b00000000000;
   end else begin
      if(CplD & header_fields_valid_one)begin   
         mem_dma_size[10:0] <= (dw_length[9:0] != 10'b0000000000) 
                               ? {1'b0,dw_length[9:0]}
                               : 11'b10000000000;
      end
   end
end
always@(posedge clk)begin
   if(rst_reg)begin
      data_valid_reg <= 1'b0;
   end else begin
      data_valid_reg <= data_valid;
   end
end
always@(posedge clk)begin
   CplD_r1 <= CplD;
   CplD_r2 <= CplD_r1;
end
assign mem_dma_start = data_valid_reg & ~data_valid & CplD_r2;          
always@(posedge clk) dmarxs_div8_reg[9:0] <= dmarxs[12:3];
always@(posedge clk) begin
   if (header_fields_valid_one & CplD)
      dw_length_d1[9:0] <= dw_length[9:0];
end
always@(posedge clk)begin  
     if (rst_reg | (~transferstart))
	      add_calc <=  1'b0;
     else if(rd_dma_start_one) 
         add_calc <=  1'b1;
     else if (add_complete) 
         add_calc <=  1'b0;
end
always@(posedge clk)begin  
        if (rst_reg | (~transferstart))
	         sub_calc <=  1'b0;
        else if(~trn_reof_d1_n & ~trn_rsrc_rdy_d1_n & CplD & ~Wait_for_TX_desc) 
            sub_calc <=  1'b1;
        else if (sub_complete) 
            sub_calc <=  1'b0;
end
always@(posedge clk)begin
     if(rst_reg | (~transferstart))begin
        dmarxs_div8_reg_new[9:0] <=  0;
        update_dmarxs_div8_reg <=  1'b0;
        add_complete <=  1'b0;
        sub_complete <=  1'b0;
        stay_2x <= 1'b0;
        addsub_state <=  AS_IDLE;
     end else begin
        case(addsub_state)
           AS_IDLE: begin
              update_dmarxs_div8_reg <=  1'b0;
              if(add_calc)begin
                    dmarxs_div8_reg_new[9:0] <=  dmarxs_div8_now[9:0] 
                                               + dmarxs_div8_reg[9:0];
                    if(~stay_2x)begin
                       addsub_state <= AS_IDLE;
                       add_complete <= 1'b0;
                       update_dmarxs_div8_reg <= 1'b0;
                       stay_2x <= 1'b1;
                    end else begin
                       addsub_state <= REGISTER_CALC;
                       add_complete <= 1'b1;
                       update_dmarxs_div8_reg <= 1'b1;
                       stay_2x <= 1'b0;
                    end
              end else if (sub_calc)begin
                    dmarxs_div8_reg_new[9:0] <=  dmarxs_div8_now[9:0] 
                                               - {1'b0, dw_length_d1[9:1]};
                    if(~stay_2x)begin
                       addsub_state <= AS_IDLE;
                       sub_complete <= 1'b0;
                       update_dmarxs_div8_reg <= 1'b0;
                       stay_2x <= 1'b1;
                    end else begin
                       addsub_state <= REGISTER_CALC;
                       sub_complete <= 1'b1;
                       update_dmarxs_div8_reg <= 1'b1;
                       stay_2x <= 1'b0;
                    end
              end else begin
                    dmarxs_div8_reg_new[9:0] <=  dmarxs_div8_now[9:0];
                    addsub_state <=  AS_IDLE;
                    sub_complete <=  1'b0;
                    add_complete <=  1'b0;
                    stay_2x <= 1'b0;
              end
           end
           REGISTER_CALC:begin 
              sub_complete <=  1'b0;
              add_complete <=  1'b0;
              addsub_state <= WAIT_FOR_REG;
              update_dmarxs_div8_reg <=  1'b1;
              stay_2x <= 1'b0;
            end
           WAIT_FOR_REG:begin 
              update_dmarxs_div8_reg <=  1'b0;
              stay_2x <= 1'b0;
              addsub_state <=  AS_IDLE;
           end
           default:begin
              dmarxs_div8_reg_new[9:0] <=  0;
              update_dmarxs_div8_reg <=  1'b0;
              add_complete <=  1'b0;
              sub_complete <=  1'b0;
              stay_2x <= 1'b0;
              addsub_state <=  AS_IDLE;
           end
        endcase
      end
end
always@(posedge clk)begin
  if(rst_reg | (~transferstart))begin
      dmarxs_div8_now[9:0] <=  0;
  end else if(update_dmarxs_div8_reg)begin
      dmarxs_div8_now[9:0] <=  dmarxs_div8_reg_new[9:0];
  end
end  
always@(posedge clk)begin
        rd_dma_done_i <= (dmarxs_div8_now[9:0] == 0) ? 1'b1 :  1'b0;
end
assign rd_dma_done_early = (dmarxs_div8_now[9:0] == 10'h000) ? 1'b1 :  1'b0;
rising_edge_detect rd_dma_done_one_inst(
                .clk(clk),
                .rst(rst),
                .in(rd_dma_done_i),
                .one_shot_out(rd_dma_done_one)
                );
rising_edge_detect rd_dma_done_early_one_inst(
                .clk(clk),
                .rst(rst),
                .in(rd_dma_done_early),
                .one_shot_out(rd_dma_done_early_one)
                );
always@(posedge clk)begin
   if(read_last || dmarxs[12:11] == 0)
      rd_dma_done <= rd_dma_done_one;
   else  
      rd_dma_done <= rd_dma_done_early_one;
end
assign np_rx_cnt_qw[9:0] = dmarxs_div8_now[9:0];
endmodule
