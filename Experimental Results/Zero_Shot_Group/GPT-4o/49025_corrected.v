`timescale 1ns/1ps
`default_nettype none

module jtag_monitor(
    input wire SIM_CLK,
    output wire MSTRT,     
    output wire MSTP,      
    output wire MDT01,  
    output wire MDT02,
    output wire MDT03,
    output wire MDT04,
    output wire MDT05,
    output wire MDT06,
    output wire MDT07,
    output wire MDT08,
    output wire MDT09,
    output wire MDT10,
    output wire MDT11,
    output wire MDT12,
    output wire MDT13,
    output wire MDT14,
    output wire MDT15,
    output wire MDT16,
    output reg MONPAR = 0, 
    output reg MREAD = 0,  
    output reg MLOAD = 0,  
    output reg MRDCH = 0,  
    output reg MLDCH = 0,  
    output reg MTCSAI = 0, 
    output reg MONWBK = 0, 
    output reg MNHRPT = 0, 
    output reg MNHNC = 0,  
    output reg MNHSBF = 0, 
    output reg MAMU = 0,   
    output wire NHALGA,    
    output reg DBLTST = 0, 
    output reg DOSCAL = 0, 
    input wire MT01,       
    input wire MT02,
    input wire MT03,
    input wire MT04,
    input wire MT05,
    input wire MT06,
    input wire MT07,
    input wire MT08,
    input wire MT09,
    input wire MT10,
    input wire MT11,
    input wire MT12,
    input wire MWL01,      
    input wire MWL02,
    input wire MWL03,
    input wire MWL04,
    input wire MWL05,
    input wire MWL06,
    input wire MWL07,
    input wire MWL08,
    input wire MWL09,
    input wire MWL10,
    input wire MWL11,
    input wire MWL12,
    input wire MWL13,
    input wire MWL14,
    input wire MWL15,
    input wire MWL16,
    input wire MSQ16,      
    input wire MSQ14,
    input wire MSQ13,
    input wire MSQ12,
    input wire MSQ11,
    input wire MSQ10,
    input wire MSQEXT,
    input wire MST1,       
    input wire MST2,
    input wire MST3,
    input wire MNISQ,      
    input wire MWAG,       
    input wire MWLG,       
    input wire MWQG,       
    input wire MWZG,       
    input wire MWBBEG,     
    input wire MWEBG,      
    input wire MWFBG,      
    input wire MWG,        
    input wire MWSG,       
    input wire MWBG,       
    input wire MWCH,       
    input wire MRGG,       
    input wire MREQIN,     
    input wire MTCSA_n    
);

    wire [15:0] write_bus;
    assign write_bus = {MWL16, MWL15, MWL14, MWL13, MWL12, MWL11, MWL10, MWL09, 
                        MWL08, MWL07, MWL06, MWL05, MWL04, MWL03, MWL02, MWL01};

    reg [15:0] monitor_data;
    assign MDT01 = monitor_data[0];
    assign MDT02 = monitor_data[1];
    assign MDT03 = monitor_data[2];
    assign MDT04 = monitor_data[3];
    assign MDT05 = monitor_data[4];
    assign MDT06 = monitor_data[5];
    assign MDT07 = monitor_data[6];
    assign MDT08 = monitor_data[7];
    assign MDT09 = monitor_data[8];
    assign MDT10 = monitor_data[9];
    assign MDT11 = monitor_data[10];
    assign MDT12 = monitor_data[11];
    assign MDT13 = monitor_data[12];
    assign MDT14 = monitor_data[13];
    assign MDT15 = monitor_data[14];
    assign MDT16 = monitor_data[15];

    reg [15:0] cntrl_reg = 16'o0;
    reg [15:0] rw_data = 16'o0;

    assign MSTP = cntrl_reg[0]; 
    assign MSTRT = cntrl_reg[1]; 

    always @(posedge SIM_CLK) begin
        if (MWAG) begin
            rw_data <= write_bus;
        end
    end

endmodule