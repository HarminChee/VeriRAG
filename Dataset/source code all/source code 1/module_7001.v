`timescale 1ns / 1ps
`timescale 1ns / 1ps
module altpciexpav_stif_a2p_addrtrans 
  #(
    parameter CB_A2P_ADDR_MAP_IS_FIXED = 1 ,
    parameter CB_A2P_ADDR_MAP_NUM_ENTRIES = 1 ,
    parameter CB_A2P_ADDR_MAP_PASS_THRU_BITS = 24 , 
    parameter CG_AVALON_S_ADDR_WIDTH = 24 ,
    parameter CG_PCI_ADDR_WIDTH = 64 ,
    parameter CG_PCI_DATA_WIDTH = 64 ,
    parameter [1023:0] CB_A2P_ADDR_MAP_FIXED_TABLE = 0,
    parameter INTENDED_DEVICE_FAMILY = "Stratix" ,
    parameter A2P_ADDR_TRANS_TR_OUTREG = 0,
    parameter A2P_ADDR_TRANS_RA_OUTREG = 0
    ) 
  (
   input                              PbaClk_i,        
   input                              PbaRstn_i,       
   input [CG_AVALON_S_ADDR_WIDTH-1:0] PbaAddress_i,    
   input [(CG_PCI_DATA_WIDTH/8)-1:0]  PbaByteEnable_i, 
   input                              PbaAddrVld_i,    
   output reg [CG_PCI_ADDR_WIDTH-1:0]     PciAddr_o,       
   output reg [1:0]                       PciAddrSpace_o,  
   output reg                           PciAddrVld_o,    
   input                              CraClk_i,        
   input                              CraRstn_i,       
   input [11:2]                       AdTrAddress_i,   
   input [3:0]                        AdTrByteEnable_i,
   input                              AdTrWriteVld_i,  
   input [31:0]                       AdTrWriteData_i, 
   input                              AdTrReadVld_i,   
   output     [31:0]                  AdTrReadData_o,  
   output                             AdTrReadVld_o    
   ) ;
 wire [CG_PCI_ADDR_WIDTH-1:0]     pci_address;      
 reg  [1:0]                       pci_address_space;  
 reg                              pci_address_valid;    
 wire  [1:0]                       pci_address_space_d;  
 wire                              pci_address_valid_d;    
reg [CG_PCI_ADDR_WIDTH-1:0]       RawAddr ;
wire [CG_PCI_ADDR_WIDTH-1:0]       RawAddr_d ;
always @(posedge CraClk_i or negedge CraRstn_i)
  begin
     if(~CraRstn_i)
       begin
         RawAddr <= 0;
         pci_address_space <= 0;
         pci_address_valid   <= 0;
       end
     else
       begin
          RawAddr <= RawAddr_d; 
          pci_address_space <= pci_address_space_d;    
          pci_address_valid   <= pci_address_valid_d;
       end
  end
   localparam [1:0] ADSP_CONFIG = 2'b11 ;
   localparam [1:0] ADSP_IO =     2'b10 ;
   localparam [1:0] ADSP_MEM64 =  2'b01 ;
   localparam [1:0] ADSP_MEM32 =  2'b00 ;
   wire [CG_AVALON_S_ADDR_WIDTH-1:0]       ByteAddr ;
   function [CG_AVALON_S_ADDR_WIDTH-1:0] ModifyByteAddr ;
      input [CG_AVALON_S_ADDR_WIDTH-1:0] PbaAddress ;
      input [(CG_PCI_DATA_WIDTH/8)-1:0] PbaByteEnable ;
      reg [7:0] FullBE ;
      begin
         ModifyByteAddr[CG_AVALON_S_ADDR_WIDTH-1:3] = PbaAddress[CG_AVALON_S_ADDR_WIDTH-1:3] ;
         if (CG_PCI_DATA_WIDTH == 64)
           FullBE = PbaByteEnable ;
         else
           FullBE = {4'b0000,PbaByteEnable} ;
         casez (FullBE)
           8'b???????1 :
             ModifyByteAddr[2:0] = {PbaAddress[2],2'b00} ;
           8'b??????10 :
             ModifyByteAddr[2:0] = {PbaAddress[2],2'b01} ;
           8'b?????100 :
             ModifyByteAddr[2:0] = {PbaAddress[2],2'b10} ;
           8'b????1000 :
             ModifyByteAddr[2:0] = {PbaAddress[2],2'b11} ;
           8'b???10000 :
             ModifyByteAddr[2:0] = 3'b100 ;
           8'b??100000 :
             ModifyByteAddr[2:0] = 3'b101 ;
           8'b?1000000 :
             ModifyByteAddr[2:0] = 3'b110 ;
           8'b10000000 :
             ModifyByteAddr[2:0] = 3'b111 ;
           default :
             ModifyByteAddr[2:0] = PbaAddress[2:0] ;
         endcase 
      end
   endfunction 
   function [CG_PCI_ADDR_WIDTH-1:0] ModifyCfgIO ;
      input [CG_PCI_ADDR_WIDTH-1:0] RawAddr ;
      input [1:0] AddrSpace ;
      begin
         ModifyCfgIO = {CG_PCI_ADDR_WIDTH{1'b0}} ;
         case (AddrSpace)
           ADSP_CONFIG :
             begin
                if (RawAddr[23:16] == 8'h00)
                  begin
                     if (CG_PCI_DATA_WIDTH == 64)
                       ModifyCfgIO[10:3] = RawAddr[10:3] ;
                     else
                       ModifyCfgIO[10:2] = RawAddr[10:2] ;
                     if (RawAddr[15:11] < 21)
                       begin
                          ModifyCfgIO[RawAddr[15:11]+11] = 1'b1 ;
                       end
                     else
                       begin
                       	 ModifyCfgIO[10:3] = 8'h0;
                          $display("ERROR: Attempt to issue a Type 0 Cfg transaction to a device number that can't be One-Hot encoded in bits 31:11") ;
                          $stop ;
                       end 
                  end 
                else
                  begin
                     ModifyCfgIO[0] = 1'b1 ;
                     if (CG_PCI_DATA_WIDTH == 64)
                       ModifyCfgIO[23:3] = RawAddr[23:3] ;
                     else
                       ModifyCfgIO[23:2] = RawAddr[23:2] ;
                  end 
             end 
           ADSP_IO :
             begin
                ModifyCfgIO = RawAddr ;
             end
           default :
             begin
                if (CG_PCI_DATA_WIDTH == 64)
                  ModifyCfgIO[CG_PCI_ADDR_WIDTH-1:3] = RawAddr[CG_PCI_ADDR_WIDTH-1:3] ;
                else
                  ModifyCfgIO[CG_PCI_ADDR_WIDTH-1:2] = RawAddr[CG_PCI_ADDR_WIDTH-1:2] ;
             end
         endcase 
      end
   endfunction
   assign ByteAddr = ModifyByteAddr(PbaAddress_i,PbaByteEnable_i) ;
   generate
      if (CB_A2P_ADDR_MAP_IS_FIXED == 0)
        begin
          altpciexpav_stif_a2p_vartrans  
            #(.CB_A2P_ADDR_MAP_NUM_ENTRIES(CB_A2P_ADDR_MAP_NUM_ENTRIES),
              .CB_A2P_ADDR_MAP_PASS_THRU_BITS(CB_A2P_ADDR_MAP_PASS_THRU_BITS),
              .CG_AVALON_S_ADDR_WIDTH(CG_AVALON_S_ADDR_WIDTH),
              .CG_PCI_ADDR_WIDTH(CG_PCI_ADDR_WIDTH),
              .INTENDED_DEVICE_FAMILY(INTENDED_DEVICE_FAMILY),
              .A2P_ADDR_TRANS_TR_OUTREG(A2P_ADDR_TRANS_TR_OUTREG),
              .A2P_ADDR_TRANS_RA_OUTREG(A2P_ADDR_TRANS_RA_OUTREG)
              )
              vartrans
              (
               .PbaClk_i(PbaClk_i),
               .PbaRstn_i(PbaRstn_i),
               .PbaAddress_i(ByteAddr),
               .PbaAddrVld_i(PbaAddrVld_i),
               .PciAddr_o(RawAddr_d),
               .PciAddrSpace_o(pci_address_space_d),
               .PciAddrVld_o(pci_address_valid_d),
               .CraClk_i(CraClk_i),
               .CraRstn_i(CraRstn_i),
               .AdTrAddress_i(AdTrAddress_i),
               .AdTrByteEnable_i(AdTrByteEnable_i),
               .AdTrWriteVld_i(AdTrWriteVld_i),
               .AdTrWriteData_i(AdTrWriteData_i),
               .AdTrReadVld_i(AdTrReadVld_i),
               .AdTrReadData_o(AdTrReadData_o),
               .AdTrReadVld_o(AdTrReadVld_o)
               ) ;   
        end 
      else
        begin
          altpciexpav_stif_a2p_fixtrans  
            #(.CB_A2P_ADDR_MAP_NUM_ENTRIES(CB_A2P_ADDR_MAP_NUM_ENTRIES),
              .CB_A2P_ADDR_MAP_PASS_THRU_BITS(CB_A2P_ADDR_MAP_PASS_THRU_BITS),
              .CG_AVALON_S_ADDR_WIDTH(CG_AVALON_S_ADDR_WIDTH),
              .CG_PCI_ADDR_WIDTH(CG_PCI_ADDR_WIDTH),
              .CB_A2P_ADDR_MAP_FIXED_TABLE(CB_A2P_ADDR_MAP_FIXED_TABLE)
              )
              fixtrans
              (
               .PbaAddress_i(ByteAddr),
               .PbaAddrVld_i(PbaAddrVld_i),
               .PciAddr_o(RawAddr_d),
               .PciAddrSpace_o(pci_address_space_d),
               .PciAddrVld_o(pci_address_valid_d),
               .AdTrAddress_i(AdTrAddress_i),
               .AdTrReadVld_i(AdTrReadVld_i),
               .AdTrReadData_o(AdTrReadData_o),
               .AdTrReadVld_o(AdTrReadVld_o)
               ) ;   
        end 
   endgenerate
   assign pci_address = ModifyCfgIO(RawAddr,pci_address_space) ;
always @(posedge CraClk_i or negedge CraRstn_i)
  begin
     if(~CraRstn_i)
       begin
         PciAddr_o <= 0;
         PciAddrSpace_o <= 0;
         PciAddrVld_o   <= 0;
       end
     else
       begin
          PciAddr_o <= pci_address; 
          PciAddrSpace_o <= pci_address_space;    
          PciAddrVld_o   <= pci_address_valid;
       end
  end
endmodule 
