`timescale 1ns / 1ps
`timescale 1ns / 1ps
module rx_mem_data_fsm(
	input  wire         clk,
	input  wire         rst,
	output reg  [127:0] ingress_data,
	output reg    [1:0] ingress_fifo_ctrl,   
	input  wire   [1:0] ingress_fifo_status, 
	output reg    [2:0] ingress_xfer_size,
	output reg   [27:6] ingress_start_addr,
	output reg          ingress_data_req,
	input  wire         ingress_data_ack,
	input  wire         isDes_fifo,           
	input  wire  [27:6] mem_dest_addr_fifo,
	input  wire  [10:0] mem_dma_size_fifo,
	input  wire         mem_dma_start,
	input  wire         mem_trn_fifo_empty,  
	output reg          mem_trn_fifo_rden,   
	input  wire [127:0] data_fifo_data,
	output reg          data_fifo_cntrl,
	input  wire         data_fifo_status,
	output reg          new_des_one,                 
	output wire        [31:0]  SourceAddr_L,
	output wire        [31:0]  SourceAddr_H,
	output wire        [31:0]  DestAddr,
	output wire        [23:0]  FrameSize,
	output wire        [7:0]   FrameControl
);
reg   [4:0]   state;
reg   [9:0]   cnt;
reg [1:0] ingress_fifo_ctrl_pipe = 2'b00;
reg	[10:0] mem_dma_size_fifo_r;
reg	[27:6] mem_dest_addr_fifo_r;
reg [127:0] TX_des_1;
reg [127:0] TX_des_2;
assign SourceAddr_L[31:0] = TX_des_1[95:64];
assign SourceAddr_H[31:0] = TX_des_1[127:96];
assign DestAddr[31:0]     = TX_des_2[31:0];
assign FrameSize[23:0]    = TX_des_2[87:64];
assign FrameControl[7:0]  = TX_des_2[95:88];
reg   rst_reg;
always@(posedge clk) rst_reg <= rst;
reg data_fifo_status_r;
always@(posedge clk) data_fifo_status_r <= data_fifo_status;
localparam IDLE   = 5'b00000;
localparam WREQ   = 5'b00001;
localparam WDATA2 = 5'b00010;
localparam WDONE  = 5'b00011;
localparam MREQ   = 5'b00100;
localparam MREQ2  = 5'b00101;
localparam MREQ_WAIT  = 5'b00110;			
localparam PARSE_TX_DES  = 5'b01000;
localparam READ_TX_DES_1 = 5'b10000;
localparam READ_TX_DES_2 = 5'b11000;
always @ (posedge clk)
begin
  if(rst_reg)
  begin
    state              <= IDLE;
    ingress_xfer_size  <= 3'b000;
    ingress_start_addr <= 22'h000000;
    ingress_data_req   <= 1'b0;
    data_fifo_cntrl    <= 1'b0; 
    mem_trn_fifo_rden  <= 1'b0;
    cnt                <= 10'h000;
	 new_des_one        <= 1'b0;
	 TX_des_1           <= 128'h00000000_00000000_00000000_00000000;
	 TX_des_2           <= 128'h00000000_00000000_00000000_00000000;
	 mem_dma_size_fifo_r 			<= 11'h000;			
	 mem_dest_addr_fifo_r[27:6]	<= 22'h00_0000;			
  end
  else
  begin
    case(state)
      IDLE:   begin
		          new_des_one <= 1'b0;
                if(~mem_trn_fifo_empty)begin
                   mem_trn_fifo_rden <= 1'b1;
                   ingress_data_req   <= 1'b0;
                   state <= MREQ;
                end else begin
                  state  <= IDLE;
                end
              end
      MREQ:  begin 
               mem_trn_fifo_rden <= 1'b0;
					state <= MREQ_WAIT;											
             end
		MREQ_WAIT: begin															
					mem_dma_size_fifo_r 			<= mem_dma_size_fifo;
					mem_dest_addr_fifo_r[27:6]	<= mem_dest_addr_fifo[27:6];
					state <= MREQ2;
				 end
      MREQ2:begin
		         if(isDes_fifo) begin            
						if (~data_fifo_status_r)begin
					      state <= PARSE_TX_DES;
						   data_fifo_cntrl <= 1'b1;        
						end else begin
						   state <= MREQ2;
							data_fifo_cntrl <= 1'b0;
						end
					end else begin
                     state <= WREQ;
							if(mem_dma_size_fifo_r[10]) begin
								ingress_xfer_size <= 3'b110; 				
								cnt               <= 10'h100;
								mem_dma_size_fifo_r  		<= mem_dma_size_fifo_r - 11'b10000000000;
								mem_dest_addr_fifo_r[27:6] <= mem_dest_addr_fifo_r[27:6] + 7'b1000000;
							end else if(mem_dma_size_fifo_r[9]) begin	
								ingress_xfer_size  <= 3'b101;
								cnt                <= 10'h080;
								mem_dma_size_fifo_r <= mem_dma_size_fifo_r - 11'b01000000000;
								mem_dest_addr_fifo_r[27:6] <= mem_dest_addr_fifo_r[27:6] + 7'b0100000;
							end else if(mem_dma_size_fifo_r[8]) begin	
								ingress_xfer_size  <= 3'b100;
								cnt                <= 10'h040;	
								mem_dma_size_fifo_r <= mem_dma_size_fifo_r - 11'b00100000000;
								mem_dest_addr_fifo_r[27:6] <= mem_dest_addr_fifo_r[27:6] + 7'b0010000;
							end else if(mem_dma_size_fifo_r[7]) begin	
								ingress_xfer_size  <= 3'b011;
								cnt                <= 10'h020;	
								mem_dma_size_fifo_r <= mem_dma_size_fifo_r - 11'b00010000000;
								mem_dest_addr_fifo_r[27:6] <= mem_dest_addr_fifo_r[27:6] + 7'b0001000;
							end else if(mem_dma_size_fifo_r[6]) begin	
								ingress_xfer_size  <= 3'b010;
								cnt                <= 10'h010;	
								mem_dma_size_fifo_r <= mem_dma_size_fifo_r - 11'b00001000000;
								mem_dest_addr_fifo_r[27:6] <= mem_dest_addr_fifo_r[27:6] + 7'b0000100;
							end else if(mem_dma_size_fifo_r[5]) begin	
								ingress_xfer_size  <= 3'b001;
								cnt                <= 10'h008;									
								mem_dma_size_fifo_r <= mem_dma_size_fifo_r - 11'b00000100000;
								mem_dest_addr_fifo_r[27:6] <= mem_dest_addr_fifo_r[27:6] + 7'b0000010;
							end else if(mem_dma_size_fifo_r[4]) begin	
								ingress_xfer_size  <= 3'b000;
								cnt                <= 10'h004;
								mem_dma_size_fifo_r <= mem_dma_size_fifo_r - 11'b00000010000;
								mem_dest_addr_fifo_r[27:6] <= mem_dest_addr_fifo_r[27:6] + 7'b0000001;
							end
                     ingress_start_addr[27:6] <= mem_dest_addr_fifo_r[27:6];	
                     ingress_data_req   <= 1'b1;
                 end
				  end
		PARSE_TX_DES:  begin
		                  state <= READ_TX_DES_1;
							   data_fifo_cntrl <= 1'b1;    
		               end
		READ_TX_DES_1: begin
		                  state <= READ_TX_DES_2;
								data_fifo_cntrl <= 1'b0;
								TX_des_2[127:0] <= data_fifo_data[127:0];
								new_des_one <= 1'b0;
		               end
		READ_TX_DES_2: begin
		                  state <= IDLE;                    
								TX_des_2[127:0] <= data_fifo_data[127:0];
								TX_des_1[127:0] <= TX_des_2[127:0];
								new_des_one <= 1'b1;
		               end
      WREQ:   begin          
                if(ingress_data_ack)
                begin
                  state              <= WDATA2;
                  ingress_data_req   <= 1'b0;
                  data_fifo_cntrl    <= 1'b1; 
                end
                else
                begin
                  state <= WREQ;
                end
              end
      WDATA2: begin
                if(cnt == 10'h001)begin
                  state <= WDONE;
                  data_fifo_cntrl    <= 1'b0;
                end else begin
                  cnt                <= cnt - 1'b1;                 
                  data_fifo_cntrl    <= 1'b1;
                  state <= WDATA2;
                end
              end
      WDONE:  begin
                if(mem_dma_size_fifo_r[10:4] == 7'h00)			
						state              <= IDLE;
					 else
						state					 <= MREQ2;
              end  
      default:begin
                state              <= IDLE;
                ingress_xfer_size  <= 3'b000;
                ingress_start_addr <= 22'h000000;
                ingress_data_req   <= 1'b0;
                data_fifo_cntrl    <= 1'b0; 
                mem_trn_fifo_rden  <= 1'b0;
                cnt                <= 10'h000;
					 mem_dma_size_fifo_r				<= 11'h000;						
					 mem_dest_addr_fifo_r[27:6]	<= 22'h00_0000;				
              end
    endcase
  end
end
always@(posedge clk)begin    
      ingress_fifo_ctrl_pipe[1:0] <=  {1'b0,(data_fifo_cntrl&(~isDes_fifo))};
      ingress_fifo_ctrl[1:0] <= ingress_fifo_ctrl_pipe[1:0]; 
      ingress_data[127:0] <= data_fifo_data[127:0]; 
end
endmodule
