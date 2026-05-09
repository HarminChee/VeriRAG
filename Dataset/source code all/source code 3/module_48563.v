module user_logic
(
  Radio1SHDN,		
  Radio2SHDN,		
  Radio3SHDN,		
  Radio4SHDN,		
  Radio1TxEn,		
  Radio2TxEn,		
  Radio3TxEn,		
  Radio4TxEn,		
  Radio1RxEn,		
  Radio2RxEn,		
  Radio3RxEn,		
  Radio4RxEn,		
  Radio1LD,
  Radio2LD,
  Radio3LD,
  Radio4LD,
  Bus2IP_Clk,                     
  Bus2IP_Reset,                   
  Bus2IP_Data,                    
  Bus2IP_BE,                      
  Bus2IP_RdCE,                    
  Bus2IP_WrCE,                    
  IP2Bus_Data,                    
  IP2Bus_Ack,                     
  IP2Bus_Retry,                   
  IP2Bus_Error,                   
  IP2Bus_ToutSup                  
); 
parameter C_DWIDTH                       = 32;
parameter C_NUM_CE                       = 1;
output				Radio1SHDN;
output				Radio2SHDN;
output				Radio3SHDN;
output				Radio4SHDN;
output				Radio1TxEn;
output				Radio2TxEn;
output				Radio3TxEn;
output				Radio4TxEn;
output				Radio1RxEn;
output				Radio2RxEn;
output				Radio3RxEn;
output				Radio4RxEn;
input				Radio1LD;
input				Radio2LD;
input				Radio3LD;
input				Radio4LD;
input                                     Bus2IP_Clk;
input                                     Bus2IP_Reset;
input      [0 : C_DWIDTH-1]               Bus2IP_Data;
input      [0 : C_DWIDTH/8-1]             Bus2IP_BE;
input      [0 : C_NUM_CE-1]               Bus2IP_RdCE;
input      [0 : C_NUM_CE-1]               Bus2IP_WrCE;
output     [0 : C_DWIDTH-1]               IP2Bus_Data;
output                                    IP2Bus_Ack;
output                                    IP2Bus_Retry;
output                                    IP2Bus_Error;
output                                    IP2Bus_ToutSup;
  reg        [0 : C_DWIDTH-1]               slv_reg0;
  wire       [0 : 0]                        slv_reg_write_select;
  wire       [0 : 0]                        slv_reg_read_select;
  reg        [0 : C_DWIDTH-1]               slv_ip2bus_data;
  wire                                      slv_read_ack;
  wire                                      slv_write_ack;
  integer                                   byte_index, bit_index;
  assign Radio1SHDN	= slv_reg0[31];
  assign Radio2SHDN	= slv_reg0[30];
  assign Radio3SHDN	= slv_reg0[29];
  assign Radio4SHDN	= slv_reg0[28];
  assign Radio1TxEn	= slv_reg0[27];
  assign Radio2TxEn	= slv_reg0[26];
  assign Radio3TxEn	= slv_reg0[25];
  assign Radio4TxEn	= slv_reg0[24];
  assign Radio1RxEn	= slv_reg0[23];
  assign Radio2RxEn	= slv_reg0[22];
  assign Radio3RxEn	= slv_reg0[21];
  assign Radio4RxEn	= slv_reg0[20];
  assign
    slv_reg_write_select = Bus2IP_WrCE[0:0],
    slv_reg_read_select  = Bus2IP_RdCE[0:0],
    slv_write_ack        = Bus2IP_WrCE[0],
    slv_read_ack         = Bus2IP_RdCE[0];
  always @( posedge Bus2IP_Clk )
    begin: SLAVE_REG_WRITE_PROC
      if ( Bus2IP_Reset == 1 )
        begin
          slv_reg0 <= 0;
        end
      else
        case ( slv_reg_write_select )
          1'b1 :
            for ( byte_index = 0; byte_index <= (C_DWIDTH/8)-1; byte_index = byte_index+1 )
              if ( Bus2IP_BE[byte_index] == 1 )
                for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1 )
                  slv_reg0[bit_index] <= Bus2IP_Data[bit_index];
          default : ;
        endcase
    end 
  always @( slv_reg_read_select or slv_reg0 )
    begin: SLAVE_REG_READ_PROC
      case ( slv_reg_read_select )
        1'b1 : slv_ip2bus_data <= {16'b0, Radio4LD, Radio3LD, Radio2LD, Radio1LD, slv_reg0[20:31]};
        default : slv_ip2bus_data <= 0;
      endcase
    end 
  assign IP2Bus_Data        = slv_ip2bus_data;
  assign IP2Bus_Ack         = slv_write_ack || slv_read_ack;
  assign IP2Bus_Error       = 0;
  assign IP2Bus_Retry       = 0;
  assign IP2Bus_ToutSup     = 0;
endmodule
