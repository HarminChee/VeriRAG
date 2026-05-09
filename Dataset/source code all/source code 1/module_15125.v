`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pc_ctrl_axi4_reg_if #(
  parameter DATA_W_IN_BYTES       = 4,
  parameter ADDR_W_IN_BITS        = 32,
  parameter DCADDR_LOW_BIT_W      = 8,
  parameter DCADDR_STROBE_MEM_SEG = 2 
) (
   input  wire [(ADDR_W_IN_BITS)-1 : 0]              S_AXI_AWADDR,      
   input  wire [2 : 0]                               S_AXI_AWPROT,      
   input  wire                                       S_AXI_AWVALID,     
   output reg                                        S_AXI_AWREADY=0,   
   input  wire [(DATA_W_IN_BYTES*8) - 1:0]           S_AXI_WDATA,       
   input  wire [DATA_W_IN_BYTES-1 : 0]               S_AXI_WSTRB,       
   input  wire                                       S_AXI_WVALID,      
   output reg                                        S_AXI_WREADY=0,    
   output reg  [1 : 0]                               S_AXI_BRESP=0,     
   output reg                                        S_AXI_BVALID=0,    
   input  wire                                       S_AXI_BREADY,      
   input  wire [(ADDR_W_IN_BITS)-1 : 0]              S_AXI_ARADDR,      
   input  wire [2 : 0]                               S_AXI_ARPROT,      
   input  wire                                       S_AXI_ARVALID,     
   output reg                                        S_AXI_ARREADY=0,   
   output reg  [(DATA_W_IN_BYTES*8) - 1:0]           S_AXI_RDATA=0,     
   output wire [1 : 0]                               S_AXI_RRESP,       
   output reg                                        S_AXI_RVALID=0,    
   input  wire                                       S_AXI_RREADY,      
   output wire [DCADDR_STROBE_MEM_SEG - 1:0]         reg_bank_rd_start, 
   input  wire [DCADDR_STROBE_MEM_SEG - 1:0]         reg_bank_rd_done,  
   output wire [DCADDR_LOW_BIT_W - 1:0]              reg_bank_rd_addr,  
   input  wire [(DATA_W_IN_BYTES*8) - 1:0]           reg_bank_rd_data,  
   output wire [(ADDR_W_IN_BITS)-1:DCADDR_LOW_BIT_W] decode_rd_addr,    
   output wire [DCADDR_STROBE_MEM_SEG - 1:0]         reg_bank_wr_start, 
   input  wire [DCADDR_STROBE_MEM_SEG - 1:0]         reg_bank_wr_done,  
   output wire [DCADDR_LOW_BIT_W - 1:0]              reg_bank_wr_addr,  
   output reg  [(DATA_W_IN_BYTES*8) - 1:0]           reg_bank_wr_data=0,
   input  wire                                       ACLK             , 
   input  wire                                       ARESETn            
);
localparam access_state_idle             = 0; 
localparam access_state_rd_start         = 1; 
localparam access_state_rd_wait_complete = 2; 
localparam access_state_rd_wait_ready    = 3; 
localparam access_state_wr_start         = 4; 
localparam access_state_wr_wait_complete = 5; 
localparam access_state_wr_wait_ready    = 6; 
reg  [2:0]                                 access_state=0; 
reg                                        start_read  =0; 
reg                                        start_write =0; 
wire [DCADDR_STROBE_MEM_SEG - 1:0]         read_decode;    
wire [DCADDR_STROBE_MEM_SEG - 1:0]         write_decode;   
reg  [(ADDR_W_IN_BITS)-1 : 0]              rd_addr=0;      
reg  [(ADDR_W_IN_BITS)-1 : 0]              wr_addr=0;      
wire [(ADDR_W_IN_BITS)-1:DCADDR_LOW_BIT_W] decode_wr_addr;
assign S_AXI_RRESP = 'd0; 
assign reg_bank_rd_addr = rd_addr[DCADDR_LOW_BIT_W -1 : 0];
assign reg_bank_wr_addr = wr_addr[DCADDR_LOW_BIT_W -1 : 0];
assign decode_rd_addr = rd_addr[(ADDR_W_IN_BITS)-1:DCADDR_LOW_BIT_W];
assign decode_wr_addr = wr_addr[(ADDR_W_IN_BITS)-1:DCADDR_LOW_BIT_W];
genvar i;
generate
   for (i = 0; i < DCADDR_STROBE_MEM_SEG ; i = i + 1) begin
      assign read_decode[i] = decode_rd_addr == i;
      assign write_decode[i] = decode_wr_addr == i;
      assign reg_bank_rd_start[i] = start_read & read_decode[i];
      assign reg_bank_wr_start[i] = start_write & write_decode[i];
   end
endgenerate
assign out_of_range_read = start_read & (reg_bank_rd_start=='d0);
assign out_of_range_write = start_write & (reg_bank_wr_start=='d0);
always @(posedge ACLK) begin
   if (|reg_bank_rd_done) begin
      S_AXI_RDATA <= reg_bank_rd_data;
   end else begin
      S_AXI_RDATA <= S_AXI_RDATA;
   end
end
always @(posedge ACLK) begin
  if(!ARESETn)begin
    access_state       <= access_state_idle;
      start_read         <= 1'd0;
      start_write        <= 1'd0;
    S_AXI_AWREADY      <= 1'd0;
        S_AXI_WREADY       <= 1'd0;
        S_AXI_BVALID       <= 1'd0;
        S_AXI_ARREADY      <= 1'd0;
  end else begin
    access_state       <= access_state;
    S_AXI_AWREADY      <= 1'd0; 
    S_AXI_WREADY       <= 1'd0; 
    S_AXI_BVALID       <= S_AXI_BVALID; 
    start_write        <= 1'd0; 
    S_AXI_ARREADY      <= 1'd0; 
    start_read         <= 1'd0; 
    case(access_state)
    access_state_idle : begin
      S_AXI_RVALID <= 1'd0; 
      if(S_AXI_ARVALID) begin
          S_AXI_ARREADY    <= 1'd1;                      
        access_state     <= access_state_rd_start;     
        rd_addr          <= S_AXI_ARADDR;              
        start_read       <= 1'd1;                      
      end else begin
        if(S_AXI_AWVALID & S_AXI_WVALID) begin
          access_state     <= access_state_wr_start; 
          wr_addr          <= S_AXI_AWADDR;          
          reg_bank_wr_data <= S_AXI_WDATA;
          S_AXI_AWREADY    <= 1'd1;                  
          S_AXI_WREADY     <= 1'd1;
          start_write      <= 1'd1;                  
        end
      end
    end
    access_state_rd_start : begin
      S_AXI_ARREADY <= 1'd0; 
      if (|reg_bank_rd_done | out_of_range_read) begin
        S_AXI_RVALID <= 1'd1;
        access_state <= access_state_rd_wait_ready;
      end else begin
         access_state <= access_state_rd_wait_complete;
      end
    end
    access_state_rd_wait_complete : begin
            if (|reg_bank_rd_done | out_of_range_read) begin
                S_AXI_RVALID <= 1'd1;
                   access_state <= access_state_rd_wait_ready;
            end
        end
    access_state_rd_wait_ready : begin
           if (S_AXI_RREADY) begin
              S_AXI_RVALID <= 1'd0;
              access_state <= access_state_idle;
           end
        end
    access_state_wr_start : begin
      S_AXI_AWREADY <= 1'd0;
      S_AXI_WREADY  <= 1'd0;
      if (|reg_bank_wr_done | out_of_range_write) begin
          S_AXI_BVALID <= 1'd1;
        access_state <= access_state_wr_wait_ready;
      end else begin
        access_state <= access_state_wr_wait_complete;
      end
    end
        access_state_wr_wait_complete : begin
          if (|reg_bank_wr_done | out_of_range_write) begin
              S_AXI_BVALID <= 1'd1;
            access_state <= access_state_wr_wait_ready;
          end else begin
            access_state <= access_state_wr_wait_complete;
          end
        end
        access_state_wr_wait_ready : begin
          if (S_AXI_BREADY) begin
              S_AXI_BVALID <= 1'd0;
            access_state <= access_state_idle;
          end
        end
    default : access_state <= access_state;
    endcase
  end
end
endmodule
