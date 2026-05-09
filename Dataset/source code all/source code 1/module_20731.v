`timescale 1ns / 1ps
`timescale 1ns / 1ps
module altpciexpav_stif_a2p_fixtrans
  #(parameter CB_A2P_ADDR_MAP_NUM_ENTRIES = 16 ,
    parameter CB_A2P_ADDR_MAP_PASS_THRU_BITS = 12 ,
    parameter CG_AVALON_S_ADDR_WIDTH = 32 ,
    parameter CG_PCI_ADDR_WIDTH = 32 ,
    parameter [1023:0] CB_A2P_ADDR_MAP_FIXED_TABLE = 0 
    )
  (
   input [CG_AVALON_S_ADDR_WIDTH-1:0] PbaAddress_i,   
   input                              PbaAddrVld_i,   
   output reg [CG_PCI_ADDR_WIDTH-1:0] PciAddr_o,      
   output reg [1:0]                   PciAddrSpace_o,   
   output reg                         PciAddrVld_o,   
   input [11:2]                       AdTrAddress_i,  
   input                              AdTrReadVld_i,  
   output reg [31:0]                  AdTrReadData_o, 
   output reg                         AdTrReadVld_o   
   ) ;
   reg [3:0]                           table_index ;
   reg [3:0]                          entry_index;                            
   reg [63:0]                         table_addr ;
   reg [63:0]                         table_read ;
   localparam [1:0] ADSP_CONFIG = 2'b11 ;
   localparam [1:0] ADSP_IO =     2'b10 ;
   localparam [1:0] ADSP_MEM64 =  2'b01 ;
   localparam [1:0] ADSP_MEM32 =  2'b00 ;
   function [63:0] validate_entry ;
      input [3:0] index ;
      reg [63:0] valid_entry ;
      reg [63:0] table_entry ;
      begin
         if ((|index) !== 1'bX)
           begin
              valid_entry = 64'h0000000000000000 ;
              table_entry = CB_A2P_ADDR_MAP_FIXED_TABLE[(((index+1)*64)-1)-:64] ;
              valid_entry[(CG_PCI_ADDR_WIDTH-1):CB_A2P_ADDR_MAP_PASS_THRU_BITS]
                = table_entry[(CG_PCI_ADDR_WIDTH-1):CB_A2P_ADDR_MAP_PASS_THRU_BITS] ;
              case (table_entry[1:0])
                ADSP_CONFIG : 
                  begin
                     valid_entry[1:0]   = ADSP_CONFIG ;
                     valid_entry[63:24] = 40'h0000000000 ;
                  end
                ADSP_IO : 
                  begin
                     valid_entry[1:0]   = ADSP_IO ;
                     valid_entry[63:32] = 32'h00000000 ;
                  end
                ADSP_MEM64, ADSP_MEM32 :
                  begin
                     if (CG_PCI_ADDR_WIDTH > 32)
                       begin
                          if (|valid_entry[63:32] == 1'b1)
                            valid_entry[1:0]   = ADSP_MEM64 ;
                          else
                            valid_entry[1:0]   = ADSP_MEM32 ;
                          if  ( (valid_entry[1:0] == ADSP_MEM64) && (table_entry[1:0] != ADSP_MEM64) )
                          $display("WARNING: CB_A2P_ADDR_MAP_FIXED_TABLE specified 32 bit memory space, but upper bits were non zero, assuming 64 bit memory space") ;
                          else if  ( (valid_entry[1:0] == ADSP_MEM32) && (table_entry[1:0] != ADSP_MEM32) )
                          $display("WARNING: CB_A2P_ADDR_MAP_FIXED_TABLE specified 64 bit memory space, but upper bits were zero, assuming 32 bit memory space") ;
                       end
                     else
                       begin
                          valid_entry[1:0]   = ADSP_MEM32 ;
                          valid_entry[63:32] = 32'h00000000 ;
                          if (table_entry[0] == 1'b1)
                          $display("WARNING: CB_A2P_ADDR_MAP_FIXED_TABLE specified 64 bit memory space, but CG_PCI_ADDR_WIDTH is 32 bits, forcing 32 bit memory space") ;
                       end 
                  end 
                default :
                  begin
                  	 valid_entry[63:32] = 32'h00000000 ;
                     $display("ERROR: MetaCharacters in Address Space (bits[1:0]) field of CB_A2P_ADDR_MAP_FIXED_TABLE") ;
                     $stop ;
                  end
              endcase 
              validate_entry = valid_entry ;
           end 
         else
           begin
              validate_entry = {64{1'b0}} ;
           end 
      end 
   endfunction 
   localparam TABLE_INDEX_LSB = (CG_AVALON_S_ADDR_WIDTH > CB_A2P_ADDR_MAP_PASS_THRU_BITS) ?
                                CB_A2P_ADDR_MAP_PASS_THRU_BITS : CG_AVALON_S_ADDR_WIDTH-1 ;
   always @(PbaAddress_i or PbaAddrVld_i)
     begin
         table_index = PbaAddress_i[CG_AVALON_S_ADDR_WIDTH-1:
                                   TABLE_INDEX_LSB] % 
                      CB_A2P_ADDR_MAP_NUM_ENTRIES ;
        table_addr = validate_entry(table_index) ;
        PciAddrSpace_o = table_addr[1:0] ;
        table_addr[CB_A2P_ADDR_MAP_PASS_THRU_BITS-1:0] 
          = PbaAddress_i[CB_A2P_ADDR_MAP_PASS_THRU_BITS-1:0] ;
        PciAddr_o  = table_addr[CG_PCI_ADDR_WIDTH-1:0] ;
        PciAddrVld_o = PbaAddrVld_i ;
     end 
   always @*
    begin
    	 entry_index = ((AdTrAddress_i >> 1) % 
                           CB_A2P_ADDR_MAP_NUM_ENTRIES) ;
    end
   always @*
     begin
        table_read 
          = validate_entry(entry_index) ;
        if (AdTrAddress_i[2] == 1'b1)
          AdTrReadData_o = table_read[63:32] ;
        else
          AdTrReadData_o = table_read[31:0] ;
        AdTrReadVld_o = AdTrReadVld_i ; 
     end
endmodule 
