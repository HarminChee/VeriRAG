module user_logic
(
  DQ0_T,                             
  DQ0_O,
  DQ0_I,
  DQ1_T,                             
  DQ1_O,
  DQ1_I,
  DQ2_T,                             
  DQ2_O,
  DQ2_I,
  DQ3_T,                             
  DQ3_O,
  DQ3_I,
  DQ4_T,                             
  DQ4_O,
  DQ4_I,
  DQ5_T,                             
  DQ5_O,
  DQ5_I,
  DQ6_T,                             
  DQ6_O,
  DQ6_I,
  DQ7_T,                             
  DQ7_O,
  DQ7_I,
  Bus2IP_Clk,                     
  Bus2IP_Reset,                   
  Bus2IP_Addr,                    
  Bus2IP_Data,                    
  Bus2IP_BE,                      
  Bus2IP_RNW,                     
  Bus2IP_CS,                      
  Bus2IP_RdCE,                    
  Bus2IP_WrCE,                    
  IP2Bus_Data,                    
  IP2Bus_Ack,                     
  IP2Bus_Retry,                   
  IP2Bus_Error,                   
  IP2Bus_ToutSup,                 
  IP2Bus_PostedWrInh              
); 
parameter C_AWIDTH                       = 32;
parameter C_DWIDTH                       = 32;
parameter C_NUM_CS                       = 1;
parameter C_NUM_CE                       = 1;
output                             DQ0_T;
output                             DQ1_T;
output                             DQ2_T;
output                             DQ3_T;
output                             DQ4_T;
output                             DQ5_T;
output                             DQ6_T;
output                             DQ7_T;
output                             DQ0_O;
output                             DQ1_O;
output                             DQ2_O;
output                             DQ3_O;
output                             DQ4_O;
output                             DQ5_O;
output                             DQ6_O;
output                             DQ7_O;
input                              DQ0_I;
input                              DQ1_I;
input                              DQ2_I;
input                              DQ3_I;
input                              DQ4_I;
input                              DQ5_I;
input                              DQ6_I;
input                              DQ7_I;
input                                     Bus2IP_Clk;
input                                     Bus2IP_Reset;
input      [0 : C_AWIDTH-1]               Bus2IP_Addr;
input      [0 : C_DWIDTH-1]               Bus2IP_Data;
input      [0 : C_DWIDTH/8-1]             Bus2IP_BE;
input                                     Bus2IP_RNW;
input      [0 : C_NUM_CS-1]               Bus2IP_CS;
input      [0 : C_NUM_CE-1]               Bus2IP_RdCE;
input      [0 : C_NUM_CE-1]               Bus2IP_WrCE;
output     [0 : C_DWIDTH-1]               IP2Bus_Data;
output                                    IP2Bus_Ack;
output                                    IP2Bus_Retry;
output                                    IP2Bus_Error;
output                                    IP2Bus_ToutSup;
output                                    IP2Bus_PostedWrInh;
  wire [ 7:0] OWM_rd_data;
  wire [31:0] OWM_wt_data;
  wire [31:0] OWM_addr;
     assign OWM_wt_data = Bus2IP_Data;
     assign OWM_addr    = Bus2IP_Addr;
  reg  [ 2:0] OWM_rdwt_cycle;
  reg         OWM_wt_n;
  reg         OWM_rd_n;
  reg         OWM_rdwt_ack;
  reg         OWM_toutsup;
     always @ (posedge Bus2IP_Clk or posedge Bus2IP_Reset)
     begin
        if (Bus2IP_Reset)
        begin
           OWM_rdwt_cycle <= 3'b000;
           OWM_wt_n       <= 1'b1;
           OWM_rd_n       <= 1'b1;
           OWM_rdwt_ack   <= 1'b0;
           OWM_toutsup    <= 1'b0;
        end
        else
        begin
           if      (              ~Bus2IP_CS) OWM_rdwt_cycle <= 3'b000;
           else if (OWM_rdwt_cycle == 3'b111) OWM_rdwt_cycle <= 3'b111;
           else                               OWM_rdwt_cycle <= OWM_rdwt_cycle + 1;
           OWM_wt_n     <= ~(   Bus2IP_CS & ~Bus2IP_RNW & (OWM_rdwt_cycle == 1)
                              | Bus2IP_CS & ~Bus2IP_RNW & (OWM_rdwt_cycle == 2)
                            );
           OWM_rd_n     <= ~(   Bus2IP_CS &  Bus2IP_RNW & (OWM_rdwt_cycle == 1)
                              | Bus2IP_CS &  Bus2IP_RNW & (OWM_rdwt_cycle == 2)
                              | Bus2IP_CS &  Bus2IP_RNW & (OWM_rdwt_cycle == 3)
                              | Bus2IP_CS &  Bus2IP_RNW & (OWM_rdwt_cycle == 4)
                            );
           OWM_rdwt_ack <= Bus2IP_CS & (OWM_rdwt_cycle == 4);
           OWM_toutsup  <= ~OWM_toutsup & Bus2IP_CS & (OWM_rdwt_cycle == 0)
                         |  OWM_toutsup & Bus2IP_CS & ~OWM_rdwt_ack;
        end
     end
  	OWM owm_instance
  	 (
  	   .ADDRESS(OWM_addr[4:2]),                   
      .ADS_bar(1'b0),
      .CLK(Bus2IP_Clk),
      .EN_bar(1'b0),
      .MR(Bus2IP_Reset),
      .RD_bar(OWM_rd_n),
      .WR_bar(OWM_wt_n),
      .INTR(IP2Bus_IntrEvent),	
  	   .STPZ(),
      .DATA_IN(OWM_wt_data[7:0]),
      .DATA_OUT(OWM_rd_data),
      .DQ0_T(DQ0_T),
      .DQ0_O(DQ0_O),
      .DQ0_I(DQ0_I),
      .DQ1_T(DQ1_T),
      .DQ1_O(DQ1_O),
      .DQ1_I(DQ1_I),
      .DQ2_T(DQ2_T),
      .DQ2_O(DQ2_O),
      .DQ2_I(DQ2_I),
      .DQ3_T(DQ3_T),
      .DQ3_O(DQ3_O),
      .DQ3_I(DQ3_I),
      .DQ4_T(DQ4_T),
      .DQ4_O(DQ4_O),
      .DQ4_I(DQ4_I),
      .DQ5_T(DQ5_T),
      .DQ5_O(DQ5_O),
      .DQ5_I(DQ5_I),
      .DQ6_T(DQ6_T),
      .DQ6_O(DQ6_O),
      .DQ6_I(DQ6_I),
      .DQ7_T(DQ7_T),
      .DQ7_O(DQ7_O),
      .DQ7_I(DQ7_I)
  	 );
     assign IP2Bus_Data    = {32{OWM_rdwt_ack}} & {24'h000000, OWM_rd_data};
     assign IP2Bus_Ack     = OWM_rdwt_ack;
     assign IP2Bus_ToutSup = OWM_toutsup;
  assign IP2Bus_Error       = 0;
  assign IP2Bus_Retry       = 0;
  assign IP2Bus_PostedWrInh = 1;
endmodule
