`timescale 1ps/1ps
`timescale 1ps/1ps
module mcb_soft_calibration_top  # (
  parameter       C_MEM_TZQINIT_MAXCNT  = 10'h512,  
  parameter       C_MC_CALIBRATION_MODE = "CALIBRATION", 
  parameter       SKIP_IN_TERM_CAL  = 1'b0,     
  parameter       SKIP_DYNAMIC_CAL  = 1'b0,     
  parameter       SKIP_DYN_IN_TERM  = 1'b0,     
  parameter       C_SIMULATION      = "FALSE",  
  parameter       C_MEM_TYPE        = "DDR"	
  )
  (
  input   wire        UI_CLK,                 
  input   wire        RST,                    
  input   wire        IOCLK,                  
  output  wire        DONE_SOFTANDHARD_CAL,   
  input   wire        PLL_LOCK,               
  input   wire        SELFREFRESH_REQ,     
  input   wire        SELFREFRESH_MCB_MODE,
  output  wire         SELFREFRESH_MCB_REQ ,
  output  wire         SELFREFRESH_MODE,    
  output  wire        MCB_UIADD,              
  output  wire        MCB_UISDI,              
  input   wire        MCB_UOSDO,
  input   wire        MCB_UODONECAL,
  input   wire        MCB_UOREFRSHFLAG,
  output  wire        MCB_UICS,
  output  wire        MCB_UIDRPUPDATE,
  output  wire        MCB_UIBROADCAST,
  output  wire  [4:0] MCB_UIADDR,
  output  wire        MCB_UICMDEN,
  output  wire        MCB_UIDONECAL,
  output  wire        MCB_UIDQLOWERDEC,
  output  wire        MCB_UIDQLOWERINC,
  output  wire        MCB_UIDQUPPERDEC,
  output  wire        MCB_UIDQUPPERINC,
  output  wire        MCB_UILDQSDEC,
  output  wire        MCB_UILDQSINC,
  output  wire        MCB_UIREAD,
  output  wire        MCB_UIUDQSDEC,
  output  wire        MCB_UIUDQSINC,
  output  wire        MCB_RECAL,
  output  wire        MCB_SYSRST,
  output  wire        MCB_UICMD,
  output  wire        MCB_UICMDIN,
  output  wire  [3:0] MCB_UIDQCOUNT,
  input   wire  [7:0] MCB_UODATA,
  input   wire        MCB_UODATAVALID,
  input   wire        MCB_UOCMDREADY,
  input   wire        MCB_UO_CAL_START,
  inout   wire        RZQ_Pin,
  inout   wire        ZIO_Pin,
  output  wire            CKE_Train
  );
  wire IODRP_ADD;
  wire IODRP_SDI;
  wire RZQ_IODRP_SDO;
  wire RZQ_IODRP_CS;
  wire ZIO_IODRP_SDO;
  wire ZIO_IODRP_CS;
  wire IODRP_SDO;
  wire IODRP_CS;
  wire IODRP_BKST;
  wire RZQ_ZIO_ODATAIN;
  wire RZQ_ZIO_TRISTATE;
  wire RZQ_TOUT;
  wire ZIO_TOUT;
  wire [7:0] Max_Value;
  wire ZIO_IN;
  wire RZQ_IN;
  reg     ZIO_IN_R1, ZIO_IN_R2;
  reg     RZQ_IN_R1, RZQ_IN_R2;
  assign RZQ_ZIO_ODATAIN  = ~RST;
  assign RZQ_ZIO_TRISTATE = ~RST;
  assign IODRP_BKST       = 1'b0;  
mcb_soft_calibration #(
  .C_MEM_TZQINIT_MAXCNT (C_MEM_TZQINIT_MAXCNT),
  .C_MC_CALIBRATION_MODE(C_MC_CALIBRATION_MODE),
  .SKIP_IN_TERM_CAL     (SKIP_IN_TERM_CAL),
  .SKIP_DYNAMIC_CAL     (SKIP_DYNAMIC_CAL),
  .SKIP_DYN_IN_TERM     (SKIP_DYN_IN_TERM),
  .C_SIMULATION         (C_SIMULATION),
  .C_MEM_TYPE           (C_MEM_TYPE)
  ) 
mcb_soft_calibration_inst (
  .UI_CLK               (UI_CLK),  
  .RST                  (RST),             
  .PLL_LOCK             (PLL_LOCK), 
  .SELFREFRESH_REQ      (SELFREFRESH_REQ),    
  .SELFREFRESH_MCB_MODE  (SELFREFRESH_MCB_MODE),
  .SELFREFRESH_MCB_REQ   (SELFREFRESH_MCB_REQ ),
  .SELFREFRESH_MODE     (SELFREFRESH_MODE),   
  .DONE_SOFTANDHARD_CAL (DONE_SOFTANDHARD_CAL),
  .IODRP_ADD            (IODRP_ADD),       
  .IODRP_SDI            (IODRP_SDI),       
  .RZQ_IN               (RZQ_IN_R2),         
  .RZQ_IODRP_SDO        (RZQ_IODRP_SDO),   
  .RZQ_IODRP_CS         (RZQ_IODRP_CS),   
  .ZIO_IN               (ZIO_IN_R2),         
  .ZIO_IODRP_SDO        (ZIO_IODRP_SDO),   
  .ZIO_IODRP_CS         (ZIO_IODRP_CS),   
  .MCB_UIADD            (MCB_UIADD),      
  .MCB_UISDI            (MCB_UISDI),      
  .MCB_UOSDO            (MCB_UOSDO),      
  .MCB_UODONECAL        (MCB_UODONECAL), 
  .MCB_UOREFRSHFLAG     (MCB_UOREFRSHFLAG), 
  .MCB_UICS             (MCB_UICS),         
  .MCB_UIDRPUPDATE      (MCB_UIDRPUPDATE),  
  .MCB_UIBROADCAST      (MCB_UIBROADCAST),  
  .MCB_UIADDR           (MCB_UIADDR),        
  .MCB_UICMDEN          (MCB_UICMDEN),       
  .MCB_UIDONECAL        (MCB_UIDONECAL),
  .MCB_UIDQLOWERDEC     (MCB_UIDQLOWERDEC),
  .MCB_UIDQLOWERINC     (MCB_UIDQLOWERINC),
  .MCB_UIDQUPPERDEC     (MCB_UIDQUPPERDEC),
  .MCB_UIDQUPPERINC     (MCB_UIDQUPPERINC),
  .MCB_UILDQSDEC        (MCB_UILDQSDEC),
  .MCB_UILDQSINC        (MCB_UILDQSINC),
  .MCB_UIREAD           (MCB_UIREAD),        
  .MCB_UIUDQSDEC        (MCB_UIUDQSDEC),
  .MCB_UIUDQSINC        (MCB_UIUDQSINC),
  .MCB_RECAL            (MCB_RECAL),         
  .MCB_UICMD            (MCB_UICMD        ),
  .MCB_UICMDIN          (MCB_UICMDIN      ),
  .MCB_UIDQCOUNT        (MCB_UIDQCOUNT    ),
  .MCB_UODATA           (MCB_UODATA       ),
  .MCB_UODATAVALID      (MCB_UODATAVALID  ),
  .MCB_UOCMDREADY       (MCB_UOCMDREADY   ),
  .MCB_UO_CAL_START     (MCB_UO_CAL_START),
  .MCB_SYSRST           (MCB_SYSRST       ), 
  .Max_Value            (Max_Value        ),  
  .CKE_Train            (CKE_Train)
);
always@(posedge UI_CLK,posedge RST)
if (RST)        
   begin
        ZIO_IN_R1 <= 1'b0; 
        ZIO_IN_R2 <= 1'b0;
        RZQ_IN_R1 <= 1'b0; 
        RZQ_IN_R2 <= 1'b0;         
   end
else
   begin
        ZIO_IN_R1 <= ZIO_IN;
        ZIO_IN_R2 <= ZIO_IN_R1;
        RZQ_IN_R1 <= RZQ_IN;
        RZQ_IN_R2 <= RZQ_IN_R1;
   end
IOBUF IOBUF_RZQ (
    .O  (RZQ_IN),
    .IO (RZQ_Pin),
    .I  (RZQ_OUT),
    .T  (RZQ_TOUT)
    );
IODRP2 IODRP2_RZQ       (
      .DATAOUT(),
      .DATAOUT2(),
      .DOUT(RZQ_OUT),
      .SDO(RZQ_IODRP_SDO),
      .TOUT(RZQ_TOUT),
      .ADD(IODRP_ADD),
      .BKST(IODRP_BKST),
      .CLK(UI_CLK),
      .CS(RZQ_IODRP_CS),
      .IDATAIN(RZQ_IN),
      .IOCLK0(IOCLK),
      .IOCLK1(1'b1),
      .ODATAIN(RZQ_ZIO_ODATAIN),
      .SDI(IODRP_SDI),
      .T(RZQ_ZIO_TRISTATE)
      );
generate 
if ((C_MEM_TYPE == "DDR" || C_MEM_TYPE == "DDR2" || C_MEM_TYPE == "DDR3") &&
     (SKIP_IN_TERM_CAL == 1'b0)
     ) begin : gen_zio
IOBUF IOBUF_ZIO (
    .O  (ZIO_IN),
    .IO (ZIO_Pin),
    .I  (ZIO_OUT),
    .T  (ZIO_TOUT)
    );
IODRP2 IODRP2_ZIO       (
      .DATAOUT(),
      .DATAOUT2(),
      .DOUT(ZIO_OUT),
      .SDO(ZIO_IODRP_SDO),
      .TOUT(ZIO_TOUT),
      .ADD(IODRP_ADD),
      .BKST(IODRP_BKST),
      .CLK(UI_CLK),
      .CS(ZIO_IODRP_CS),
      .IDATAIN(ZIO_IN),
      .IOCLK0(IOCLK),
      .IOCLK1(1'b1),
      .ODATAIN(RZQ_ZIO_ODATAIN),
      .SDI(IODRP_SDI),
      .T(RZQ_ZIO_TRISTATE)
      );
end 
endgenerate
endmodule
