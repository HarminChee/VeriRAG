`timescale 1ns / 1ps
`timescale 1ns / 1ps
module ac97_asfifo
  #(parameter    DATA_WIDTH    = 8,
                 ADDRESS_WIDTH = 4,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
    (output wire [DATA_WIDTH-1:0]        Data_out, 
     output reg                          Empty_out,
     input wire                          ReadEn_in,
     input wire                          RClk,        
     input wire  [DATA_WIDTH-1:0]        Data_in,  
     output reg                          Full_out,
     input wire                          WriteEn_in,
     input wire                          WClk,
     input wire                          Clear_in);
    reg   [DATA_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];
    wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite, pNextWordToRead;
    wire                                EqualAddresses;
    wire                                NextWriteAddressEn, NextReadAddressEn;
    wire                                Set_Status, Rst_Status;
    reg                                 Status;
    wire                                PresetFull, PresetEmpty;
    assign  Data_out = Mem[pNextWordToRead];
    always @ (posedge WClk)
        if (WriteEn_in & !Full_out)
            Mem[pNextWordToWrite] <= Data_in;
    assign NextWriteAddressEn = WriteEn_in & ~Full_out;
    assign NextReadAddressEn  = ReadEn_in  & ~Empty_out;
    ac97_graycounter #(
		.COUNTER_WIDTH( ADDRESS_WIDTH )
    ) GrayCounter_pWr (
        .GrayCount_out(pNextWordToWrite),
        .Enable_in(NextWriteAddressEn),
        .Clear_in(Clear_in),
        .Clk(WClk)
       );
    ac97_graycounter #(
		.COUNTER_WIDTH( ADDRESS_WIDTH )
    ) GrayCounter_pRd (
        .GrayCount_out(pNextWordToRead),
        .Enable_in(NextReadAddressEn),
        .Clear_in(Clear_in),
        .Clk(RClk)
       );
    assign EqualAddresses = (pNextWordToWrite == pNextWordToRead);
    assign Set_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ~^ pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ^  pNextWordToRead[ADDRESS_WIDTH-2]);
    assign Rst_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ^  pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ~^ pNextWordToRead[ADDRESS_WIDTH-2]);
    always @ (Set_Status, Rst_Status, Clear_in) 
        if (Rst_Status | Clear_in)
            Status = 0;  
        else if (Set_Status)
            Status = 1;  
    assign PresetFull = Status & EqualAddresses;  
    always @ (posedge WClk, posedge PresetFull) 
        if (PresetFull)
            Full_out <= 1;
        else
            Full_out <= 0;
    assign PresetEmpty = ~Status & EqualAddresses;  
    always @ (posedge RClk, posedge PresetEmpty)  
        if (PresetEmpty)
            Empty_out <= 1;
        else
            Empty_out <= 0;
endmodule
