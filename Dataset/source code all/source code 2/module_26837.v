module nukv_fifogen #(
    parameter ADDR_BITS=5,      
    parameter DATA_SIZE=16     
) 
(
  input wire         clk,
  input wire         rst,
  input  wire [DATA_SIZE-1:0] s_axis_tdata,
  input  wire         s_axis_tvalid,
  output wire         s_axis_tready,
  output wire         s_axis_talmostfull,
  output wire [DATA_SIZE-1:0] m_axis_tdata,
  output wire        m_axis_tvalid,
  input  wire         m_axis_tready
);
wire[(DATA_SIZE+72):0] in_data;
assign in_data[DATA_SIZE-1:0] = {72'b0, s_axis_tdata[DATA_SIZE-1:0]};
reg [1:0] waiter = 0;
wire rd_ok;
assign rd_ok = waiter == 2 ? 1 : 0;
always @(posedge clk) begin 
  if(rst) begin
     waiter <= 0;
  end else begin
    if (waiter<2) begin
      waiter <= waiter+1;
    end
  end
end
genvar x;
generate 
  if (ADDR_BITS<=9) begin
    wire[(DATA_SIZE+71)/72-1:0] in_full;
    wire[(DATA_SIZE+71)/72-1:0] in_almost_full;
    wire[(DATA_SIZE+71)/72-1:0] out_empty;
    wire[(DATA_SIZE+71)/72-1:0] out_almost_empty;
    wire[(DATA_SIZE+71):0] out_data;
    assign m_axis_tdata[DATA_SIZE-1:0] = out_data[DATA_SIZE-1:0];
    assign s_axis_tready = ~rst & (in_almost_full!=0 ? 0 :1);
    assign s_axis_talmostfull = in_almost_full==0 ? 0 :1;
    assign m_axis_tvalid = out_empty==0 ? 1 : 0;
    for (x=0; x<(DATA_SIZE+71)/72; x=x+1) begin
         FIFO36E1 #(
            .ALMOST_EMPTY_OFFSET(13'h0080),    
            .ALMOST_FULL_OFFSET(2**ADDR_BITS-8),     
            .DATA_WIDTH(72),                    
            .DO_REG(1),                        
            .EN_ECC_READ("FALSE"),             
            .EN_ECC_WRITE("FALSE"),            
            .EN_SYN("FALSE"),                  
            .FIFO_MODE("FIFO36_72"),              
            .FIRST_WORD_FALL_THROUGH("TRUE"), 
            .INIT(72'h000000000000000000),     
            .SIM_DEVICE("7SERIES"),            
            .SRVAL(72'h000000000000000000)     
         )
         FIFO36E1_inst (
            .DBITERR(),             
            .ECCPARITY(),         
            .SBITERR(),             
            .DO(out_data[x*72 +: 64]),                       
            .DOP(out_data[x*72+64 +: 8]),                     
            .ALMOSTEMPTY(out_almost_empty[x]),     
            .ALMOSTFULL(in_almost_full[x]),       
            .EMPTY(out_empty[x]),                 
            .FULL(in_full[x]),                   
            .RDCOUNT(),             
            .RDERR(),                 
            .WRCOUNT(),             
            .WRERR(),                 
            .INJECTDBITERR(), 
            .INJECTSBITERR(),
            .RDCLK(clk),                 
            .RDEN(m_axis_tready & rd_ok),                   
            .REGCE(1'b1),                 
            .RST(rst),                     
            .RSTREG(rst),               
            .WRCLK(clk),                 
            .WREN(s_axis_tvalid & rd_ok & ~in_almost_full[x]),                   
            .DI(in_data[x*72 +: 64]),                       
            .DIP(in_data[x*72+64 +: 8])                      
         );
    end
 end else if (ADDR_BITS<=10) begin
    wire[(DATA_SIZE+35)/36-1:0] in_full;
    wire[(DATA_SIZE+35)/36-1:0] in_almost_full;
    wire[(DATA_SIZE+35)/36-1:0] out_empty;
    wire[(DATA_SIZE+35)/36-1:0] out_almost_empty;
    wire[(DATA_SIZE+35):0] out_data;
    assign m_axis_tdata[DATA_SIZE-1:0] = out_data[DATA_SIZE-1:0];
    assign s_axis_tready = ~rst & (in_almost_full!=0 ? 0 : 1);
    assign s_axis_talmostfull = in_almost_full==0 ? 0 :1;
    assign m_axis_tvalid = out_empty==0 ? 1 : 0;
    for (x=0; x<(DATA_SIZE+35)/36; x=x+1) begin
         FIFO36E1 #(
            .ALMOST_EMPTY_OFFSET(13'h0080),    
            .ALMOST_FULL_OFFSET(2**ADDR_BITS-8),     
            .DATA_WIDTH(36),                    
            .DO_REG(1),                        
            .EN_ECC_READ("FALSE"),             
            .EN_ECC_WRITE("FALSE"),            
            .EN_SYN("FALSE"),                  
            .FIFO_MODE("FIFO36"),              
            .FIRST_WORD_FALL_THROUGH("TRUE"), 
            .INIT(36'h000000000000000000),     
            .SIM_DEVICE("7SERIES"),            
            .SRVAL(36'h000000000000000000)     
         )
         FIFO36E1_inst (
            .DBITERR(),             
            .ECCPARITY(),         
            .SBITERR(),             
            .DO(out_data[x*36 +: 32]),                       
            .DOP(out_data[x*36+32 +: 4]),                     
            .ALMOSTEMPTY(out_almost_empty[x]),     
            .ALMOSTFULL(in_almost_full[x]),       
            .EMPTY(out_empty[x]),                 
            .FULL(in_full[x]),                   
            .RDCOUNT(),             
            .RDERR(),                 
            .WRCOUNT(),             
            .WRERR(),                 
            .INJECTDBITERR(), 
            .INJECTSBITERR(),
            .RDCLK(clk),                 
            .RDEN(m_axis_tready & rd_ok),                   
            .REGCE(1'b1),                 
            .RST(rst),                     
            .RSTREG(rst),               
            .WRCLK(clk),                 
            .WREN(s_axis_tvalid & rd_ok & ~in_almost_full[x]),                   
            .DI(in_data[x*36 +: 32]),                       
            .DIP(in_data[x*36+32 +: 4])                      
         );
    end
 end else if (ADDR_BITS<=11) begin
    wire[(DATA_SIZE+17)/18-1:0] in_full;
    wire[(DATA_SIZE+17)/18-1:0] in_almost_full;
    wire[(DATA_SIZE+17)/18-1:0] out_empty;
    wire[(DATA_SIZE+17)/18-1:0] out_almost_empty;
    wire[(DATA_SIZE+17):0] out_data;
    assign m_axis_tdata[DATA_SIZE-1:0] = out_data[DATA_SIZE-1:0];
    assign s_axis_tready = ~rst & (in_almost_full!=0 ? 0 : 1);
    assign s_axis_talmostfull = in_almost_full==0 ? 0 :1;
    assign m_axis_tvalid = out_empty==0 ? 1 : 0;
    for (x=0; x<(DATA_SIZE+17)/18; x=x+1) begin
         FIFO36E1 #(
            .ALMOST_EMPTY_OFFSET(13'h0080),    
            .ALMOST_FULL_OFFSET(2**ADDR_BITS-8),     
            .DATA_WIDTH(18),                    
            .DO_REG(1),                        
            .EN_ECC_READ("FALSE"),             
            .EN_ECC_WRITE("FALSE"),            
            .EN_SYN("FALSE"),                  
            .FIFO_MODE("FIFO18"),              
            .FIRST_WORD_FALL_THROUGH("TRUE"), 
            .INIT(18'h000000000000000000),     
            .SIM_DEVICE("7SERIES"),            
            .SRVAL(18'h000000000000000000)     
         )
         FIFO36E1_inst (
            .DBITERR(),             
            .ECCPARITY(),         
            .SBITERR(),             
            .DO(out_data[x*18 +: 16]),                       
            .DOP(out_data[x*18+16 +: 2]),                     
            .ALMOSTEMPTY(out_almost_empty[x]),     
            .ALMOSTFULL(in_almost_full[x]),       
            .EMPTY(out_empty[x]),                 
            .FULL(in_full[x]),                   
            .RDCOUNT(),             
            .RDERR(),                 
            .WRCOUNT(),             
            .WRERR(),                 
            .INJECTDBITERR(), 
            .INJECTSBITERR(),
            .RDCLK(clk),                 
            .RDEN(m_axis_tready & rd_ok),                   
            .REGCE(1'b1),                 
            .RST(rst),                     
            .RSTREG(rst),               
            .WRCLK(clk),                 
            .WREN(s_axis_tvalid & rd_ok & ~in_almost_full[x]),                   
            .DI(in_data[x*18 +: 16]),                       
            .DIP(in_data[x*18+16 +: 2])                      
         );
    end
 end
endgenerate
endmodule
