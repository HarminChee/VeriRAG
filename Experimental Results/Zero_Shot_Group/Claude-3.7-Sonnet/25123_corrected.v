`timescale 1ps/1ps
`default_nettype none
module FX3_IF (
    inout wire [31:0] fx3_bus,
    input wire fx3_wr,
    input wire fx3_oe,
    input wire fx3_cs,
    input wire fx3_clk,  
    output reg fx3_rdy, 
    output reg fx3_ack,
    output reg fx3_rd_finish,		
    input wire fx3_rst,
    output wire         BUS_CLK,  
    output wire         BUS_RST,
    output reg          BUS_WR,
    output reg          BUS_RD,
    output reg [31:0]   BUS_ADD,
    inout wire [31:0]   BUS_DATA,
    input wire          BUS_BYTE_ACCESS,
    input wire FLAG1,
    input wire FLAG2
);

wire [31:0] DataOut; 
reg [31:0] DataIn;  

assign BUS_DATA = BUS_WR ? DataIn[31:0]: 32'bz;
assign DataOut[31:0] = BUS_WR ? 32'bz : BUS_DATA;

genvar gen;
reg  [31:0] DATA_MISO; 
wire [31:0] DATA_MOSI; 
reg  [31:0] ReqCountLimit;
reg  [31:0] ReqCount;
reg  OE;
reg  CS;
reg  FLAG1_reg;
reg  FLAG2_reg;
reg RD_VALID;
reg RDY;

assign BUS_RST = fx3_rst;

IBUFG #(
      .IBUF_LOW_PWR("TRUE"),  
      .IOSTANDARD("DEFAULT")  
   ) IBUFG_inst (
      .O(BUS_CLK), 
      .I(fx3_clk)  
);

reg [7:0] DATA_BYTE_RD [3:0];
reg [7:0] DATA_BYTE_WR [3:0];
wire [1:0] BYTE;
assign BYTE = ReqCount[1:0];

reg WR_BYTE;

always@ (posedge BUS_CLK)
    DATA_BYTE_RD[BYTE] <= DataOut[7:0];

reg RD_FINISH;

always @ (posedge BUS_CLK)
begin 
 	fx3_ack <= RD_VALID; 
 	fx3_rd_finish <= RD_FINISH;
	fx3_rdy <= RDY;
	
	if(BUS_RST)
	   DATA_MISO <= 0;
	else if(BUS_BYTE_ACCESS) begin
	   if(BYTE==0)
	       DATA_MISO <= { {3{8'b0}}, DataOut[7:0]};
	   else if(BYTE==1)
	       DATA_MISO <= { {2{8'b0}}, DataOut[7:0], DATA_BYTE_RD[0]};
	   else if(BYTE==2)
	       DATA_MISO <= {8'b0, DataOut[7:0], DATA_BYTE_RD[1], DATA_BYTE_RD[0]};
	   else
	       DATA_MISO <= {DataOut[7:0], DATA_BYTE_RD[2], DATA_BYTE_RD[1], DATA_BYTE_RD[0]};
    end
	else
	   DATA_MISO <= DataOut;
end

reg first_word_written_check;

always @ (posedge BUS_CLK)
begin 
 	if(BUS_BYTE_ACCESS)
 	   BUS_WR <= (fx3_wr | WR_BYTE);
 	else
 	   BUS_WR <= fx3_wr;
 	   
 	OE <= fx3_oe;
 	CS <= fx3_cs;
 	FLAG1_reg <= FLAG1;
    FLAG2_reg <= FLAG2;
    
    if(!CS | !BUS_BYTE_ACCESS)
        first_word_written_check <= 0;
        
 	if(BUS_BYTE_ACCESS & (fx3_wr | BUS_WR) & ((ReqCount+1) < ReqCountLimit)) begin
 	   if(((ReqCount[1:0]==0)|(ReqCount[1:0]==3)) & (!first_word_written_check)) begin
 	       {DATA_BYTE_WR[2], DATA_BYTE_WR[1], DATA_BYTE_WR[0], DataIn[7:0]} <= DATA_MOSI;
           first_word_written_check <= 1;
 	   end
 	   else if((ReqCount[1:0]==0) & first_word_written_check) begin
 	       DataIn[7:0] <= DATA_BYTE_WR[0];
 	       first_word_written_check <= 0;
 	   end
 	   else if(ReqCount[1:0]==1)
           DataIn[7:0] <= DATA_BYTE_WR[1];
       else if(ReqCount[1:0]==2)
           DataIn[7:0] <= DATA_BYTE_WR[2];
	end
	else
	   DataIn <= DATA_MOSI;
end

parameter IDLE        = 0;
parameter IN_ADDR     = 1;
parameter WR_ADDR_INC = 2;
parameter IN_COUNT    = 3;
parameter FINISH_RD   = 4;
parameter RD_ADDR_INC = 5;
parameter RD_WAIT     = 6;
parameter WAIT        = 7;

reg [4:0] state, next_state;

always @ (posedge BUS_CLK)
    if (BUS_RST)
      state <= IDLE;
    else
      state <= next_state;

always @ (*) begin
    case(state)
        IDLE :
            if (CS & !OE & !first_word_written_check) 
                next_state = IN_ADDR;
            else
                next_state = IDLE;
                
        IN_ADDR :
            next_state = IN_COUNT;
            
        IN_COUNT :
            if (OE)
                next_state = RD_ADDR_INC;
            else if (BUS_WR)      
                next_state = WR_ADDR_INC;
            else
                next_state = WAIT;
                
        WR_ADDR_INC :
            if(BUS_BYTE_ACCESS)
            begin
                if (BUS_WR & ((ReqCount+1) != ReqCountLimit))
                    next_state = WR_ADDR_INC;
                else if ((ReqCount+1) == ReqCountLimit)
                    next_state = IDLE;
                else
                    next_state = WR_ADDR_INC;
            end
            else 
            begin
                if (BUS_WR)
                    next_state = WR_ADDR_INC;
                else if (!CS)
                    next_state = IDLE;
                else
                    next_state = WR_ADDR_INC;
            end
            
        RD_ADDR_INC :
            if (OE & (ReqCount != ReqCountLimit)) 
                next_state = RD_ADDR_INC;
            else if (ReqCount == ReqCountLimit)
                next_state = FINISH_RD;
            else
                next_state = RD_ADDR_INC;
                
        FINISH_RD:
            next_state = IDLE;
            
        RD_WAIT :
            next_state = IDLE;
            
        WAIT :
            if (OE)
               next_state = RD_ADDR_INC;
            else if (BUS_WR)
               next_state = WR_ADDR_INC;
            else
               next_state = WAIT;
               
        default : next_state = IDLE;
    endcase
end

always @ (posedge BUS_CLK)
begin
    if (BUS_RST) 
    begin
        BUS_ADD <= 32'd0;
        ReqCountLimit <= 32'd0;
        ReqCount <= 32'd0;
        BUS_RD <= 0;
        RD_VALID <= 0;
        RDY <= 0;
        RD_FINISH <= 0;
        WR_BYTE <= 0;
    end
    else
    begin
        case(state)
            IDLE:
            begin
                ReqCountLimit <= 32'd0;
                ReqCount <= 32'd0;
                BUS_RD <= 0;
                RDY <= 0;
            end
            
            IN_ADDR:
            begin
                BUS_ADD <= DataIn[31:0];
                RD_FINISH <= 0;
                RDY <= 1; 
            end
            
            IN_COUNT:
            begin
                if (OE)
                    BUS_RD <= 1;
                else if (BUS_WR)
                begin
                    if(BUS_BYTE_ACCESS) 
                    begin
                        BUS_ADD[31:0] <= BUS_ADD[31:0] + 1;
                        ReqCount <= ReqCount + 1;
                    end
                    else 
                        BUS_ADD[31:0] <= BUS_ADD[31:0] + 4;
                end
                else
                begin
                    ReqCountLimit <= (DataIn[31:0]);
                    if (BUS_BYTE_ACCESS)
                        RDY <= 0; 
                    else
                        RDY <= 1;
                    if (fx3_wr & BUS_BYTE_ACCESS)
                        WR_BYTE <= 1; 
                end 
            end
            
            WR_ADDR_INC:
            begin
                if(BUS_BYTE_ACCESS) 
                begin
                    if (BUS_WR & ((ReqCount+1) != ReqCountLimit))
                    begin
                        BUS_ADD[31:0] <= BUS_ADD[31:0] + 1;
                        ReqCount <= ReqCount + 1;
                        if(ReqCount[1:0] == 2'b11 && ((ReqCount+4) < ReqCountLimit))
                            RDY <= 1; 
                        else
                            RDY <= 0;
                    end
                    if (ReqCount+2 >= ReqCountLimit)
                        WR_BYTE <= 0;
                end
                else
                    if (BUS_WR)
                        BUS_ADD[31:0] <= BUS_ADD[31:0] + 4;
            end
            
            RD_ADDR_INC:
            begin
                if (OE & (ReqCount != ReqCountLimit))  
                begin
                    if(BUS_BYTE_ACCESS)
                    begin
                        BUS_ADD[31:0] <= BUS_ADD + 1;
                        ReqCount <= ReqCount + 1;
                        if(ReqCount + 1 == ReqCountLimit)
                            BUS_RD <= 0;
                        else
                            BUS_RD <= 1;
                        if(ReqCount[1:0] == 2'b11 || ReqCount + 1 == ReqCountLimit)
                            RD_VALID <= 1;
                        else
                            RD_VALID <= 0;
                    end
                    else
                    begin
                        BUS_ADD[31:0] <= BUS_ADD + 4;
                        ReqCount <= ReqCount + 4;
                        if(ReqCount + 4 == ReqCountLimit)
                            BUS_RD <= 0;
                        else
                            BUS_RD <= 1;
                        RD_VALID <= 1;
                    end
                end
                else if (ReqCount == ReqCountLimit)
                begin
                    BUS_RD <= 0;
                    RD_VALID <= 0;
                    RD_FINISH <= 1;
                end  
            end
            
            WAIT:
            begin
                if (OE)
                    BUS_RD <= 1;
                else if (BUS_WR)
                begin
                    if(BUS_BYTE_ACCESS) 
                    begin
                        BUS_ADD[31:0] <= BUS_ADD[31:0] + 1;
                        ReqCount <= ReqCount + 1;
                        RDY <= 0; 
                        if(ReqCountLimit == 2)
                            WR_BYTE <= 0; 
                    end
                    else 
                        BUS_ADD[31:0] <= BUS_ADD[31:0] + 4;
                end
                else if (fx3_wr & BUS_BYTE_ACCESS)
                begin
                    if(ReqCountLimit > 1)
                        WR_BYTE <= 1;
                    if ((ReqCount+4) < ReqCountLimit)
                        RDY <= 1; 
                end
            end
            
            default: ;
        endcase
    end
end

generate
for (gen = 0; gen < 32; gen = gen + 1) 
	begin : tri_buf 
		IOBUF #(
			.DRIVE(12), 
			.IBUF_LOW_PWR("FALSE"),  
			.IOSTANDARD("LVCMOS33"), 
			.SLEW("FAST") 
		) IOBUF_inst (
			.O(DATA_MOSI[gen]),     
			.IO(fx3_bus[gen]),   
			.I(DATA_MISO[gen]),     
			.T(!(fx3_oe & fx3_cs))      
		);
	end
endgenerate

endmodule