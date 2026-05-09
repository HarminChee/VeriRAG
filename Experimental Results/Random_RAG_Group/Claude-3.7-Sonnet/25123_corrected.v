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
    input wire FLAG2,
    input wire test_mode
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
wire clk_mux;
assign clk_mux = test_mode ? fx3_rst : fx3_clk;
IBUFG #(
      .IBUF_LOW_PWR("TRUE"),  
      .IOSTANDARD("DEFAULT")  
   ) IBUFG_inst (
      .O(BUS_CLK), 
      .I(clk_mux)  
);
reg [7:0] DATA_BYTE_RD [3:0];
reg [7:0] DATA_BYTE_WR [3:0];
wire [1:0] BYTE;
assign BYTE = ReqCount[1:0]-1;
reg WR_BYTE;
always@ (posedge BUS_CLK or negedge fx3_rst)
    if (!fx3_rst)
        DATA_BYTE_RD[BYTE] <= 8'h0;
    else
        DATA_BYTE_RD[BYTE] <= DataOut[7:0];
reg RD_FINISH;
always @ (posedge BUS_CLK or negedge fx3_rst)
begin 
    if (!fx3_rst) begin
        fx3_ack <= 1'b0;
        fx3_rd_finish <= 1'b0;
        fx3_rdy <= 1'b0;
        DATA_MISO <= 32'h0;
    end
    else begin
        fx3_ack <= RD_VALID; 
        fx3_rd_finish <= RD_FINISH;
        fx3_rdy <= RDY;
        if(BUS_BYTE_ACCESS) begin
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
end
// ... existing code ...
endmodule