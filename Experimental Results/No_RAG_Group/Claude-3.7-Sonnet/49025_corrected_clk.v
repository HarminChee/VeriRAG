`timescale 1ns/1ps
`default_nettype none
`define BYPASS  5'o00
`define CONTROL 5'o02
`define BRKBANK 5'o03
`define BRKADDR 5'o04
`define RWBANK  5'o05
`define RWADDR  5'o06
`define RWCHAN  5'o07
`define RWDATA  5'o10
`define REG_A   5'o20
`define REG_L   5'o21
`define REG_Q   5'o22
`define REG_Z   5'o23
`define REG_BB  5'o24
`define REG_G   5'o25
`define REG_SQ  5'o26
`define REG_S   5'o27
`define REG_B   5'o30
`define REG_X   5'o31
`define REG_Y   5'o32
`define REG_U   5'o33
`define STEP_INST 1'b1
`define STEP_MCT  1'b0

module jtag_monitor(
    input wire clk,  // Primary input clock
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
    assign write_bus = {MWL16, MWL15, MWL14, MWL13, MWL12, MWL11, MWL10, MWL09, MWL08, MWL07, MWL06, MWL05, MWL04, MWL03, MWL02, MWL01};
    
    wire [15:0] direct_sq;
    assign direct_sq = {MSQEXT, MSQ16, MSQ14, MSQ13, MSQ12, MSQ11, MSQ10, 9'b0};
    
    wire [2:0] stage;
    assign stage = {MST3, MST2, MST1};
    
    reg suppress_mstp = 1'b0;
    reg tcsaj_in_progress = 1'b0;
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
    
    reg bypass_reg = 0;
    reg [15:0] tmp_reg;
    reg [15:0] cntrl_reg = 16'o0;
    reg [15:0] break_bank = 16'o0;
    reg [15:0] break_addr = 16'o0;
    reg [15:0] rw_bank = 16'o0;
    reg [15:0] rw_addr = 16'o0;
    reg [15:0] rw_data = 16'o0;
    reg [15:0] a_reg = 16'o0;
    reg [15:0] l_reg = 16'o0;
    reg [15:0] q_reg = 16'o0;
    reg [15:0] z_reg = 16'o0;
    reg [15:0] bb_reg = 16'o0;
    reg [15:0] g_reg = 16'o0;
    reg [15:0] s_reg = 16'o0;
    reg [15:0] b_reg = 16'o0;
    reg [15:0] x_reg = 16'o0;
    reg [15:0] y_reg = 16'o0;
    reg [15:0] u_reg = 16'o0;
    
    wire step;
    wire step_type;
    wire break_inst;
    wire fetch_data;
    wire store_data;
    wire read_chan;
    wire load_chan;
    wire transfer_control;
    
    assign MSTP   = cntrl_reg[0] && !suppress_mstp; 
    assign MSTRT  = cntrl_reg[1]; 
    assign step   = cntrl_reg[2]; 
    assign step_type = cntrl_reg[3]; 
    assign break_inst = cntrl_reg[4]; 
    assign fetch_data = cntrl_reg[5]; 
    assign store_data = cntrl_reg[6]; 
    assign read_chan  = cntrl_reg[7]; 
    assign load_chan  = cntrl_reg[8]; 
    assign transfer_control  = cntrl_reg[9]; 
    assign NHALGA = cntrl_reg[10]; 
    
    wire tdi;
    reg tdo = 0;
    wire [4:0] ir_in;
    wire cdr, sdr, e1dr;
    
    vjtag VJTAG ( 
        .tdi                (tdi),
        .tdo                (tdo),
        .ir_in              (ir_in),
        .virtual_state_cdr  (cdr),
        .virtual_state_sdr  (sdr),
        .virtual_state_e1dr (e1dr),
        .tck                (clk)  // Use primary input clock
    );

    // Main logic using primary input clock
    always @(posedge clk) begin
        // ... existing code ...
    end

    // JTAG interface logic using primary input clock 
    always @(posedge clk) begin
        // ... existing code ...
    end

endmodule