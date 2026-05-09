module DdrCtl1(test_i,clock0,clock90,reset,inst,inst_en,page,ready,ddr_clock0,ddr_clock90,ddr_clock270,ddr_cke,ddr_csn,ddr_rasn,ddr_casn,ddr_wen,ddr_ba,ddr_addr,ddr_dm,ddr_dq,ddr_dqs);
   input wire test_i;
   input wire         clock0;
   input wire         clock90;
   input wire         reset;
   input wire [11:0]  inst;
   input wire         inst_en;
   output wire [31:0] page;
   output wire        ready;
   input  wire         ddr_clock0;
   input  wire         ddr_clock90;
   input  wire 	      ddr_clock270;
   output reg         ddr_cke;
   output reg         ddr_csn;
   output reg         ddr_rasn;
   output reg         ddr_casn;
   output reg         ddr_wen;
   output reg [1:0]   ddr_ba;
   output reg [12:0]  ddr_addr;
   output wire [1:0]  ddr_dm;
   inout wire [15:0]  ddr_dq;
   inout wire [1:0]   ddr_dqs;
   wire               i_Ready;
   reg [2:0]          s_IntfState;
   reg [31:0]         s_IntfAddress;
   reg [31:0]         s_IntfPage;
   reg                i_IntfDoRead;
   reg                i_IntfDoWrite;
   reg [3:0]          s_CoreState;
   reg [4:0]          i_CoreCommand;
   reg [1:0]          i_CoreBank;
   reg [12:0]         i_CoreAddr;
   reg                i_CoreTakeCommand0;
   reg                i_CoreTakeCommand1;
   reg                i_CoreTakeCommand2;
   reg                i_CoreTakeCommand3;
   reg                i_CoreRefreshDone;
   reg                i_CoreReadDone;
   reg                i_CoreWriteDone;
   reg [4:0]          s_InitState;
   reg [4:0]          i_InitCommand;
   reg [1:0]          i_InitBank;
   reg [12:0]         i_InitAddr;
   reg                i_InitTakeCommand0;
   reg                i_InitTakeCommand1;
   reg                i_InitDone;
   reg                i_InitDo200us;
   reg                i_InitDo200;
   reg [8:0]          s_AutoRefreshCounter;
   reg                i_AutoRefreshDoRefresh;
   reg [13:0]         s_InitCnt200usCounter;
   reg                i_InitCnt200usDone;
   reg [7:0]          s_InitCnt200Counter;
   reg                i_InitCnt200Done;
   reg [15:0]         s_HalfPage0;
   reg [15:0] 	      s_HalfPage1;
   wire [3:0]         w_InstCode;
   wire [7:0]         w_InstImm;
   reg [256*8-1:0]    d_Input;
   reg [256*8-1:0]    d_IntfState;
   reg [256*8-1:0]    d_CoreState;
   reg [256*8-1:0]    d_InitState;
   reg [256*8-1:0]    d_AutoRefreshCounter;
   reg [256*8-1:0]    d_InitCnt200usCounter;
   reg [256*8-1:0]    d_InitCnt200Counter;
   wire dftclock0;
   wire dftclock90;
   wire dftddr_clock0;
   wire dftddr_clock90;
   assign page = s_IntfPage;
   assign ready = i_Ready;
   assign dftclock0 = test_i ? clock0 : ddr_clock0;
   assign dftclock90 = test_i ? clock90 : ddr_clock90;
   always @ * begin
      if (i_InitDone) begin
         if (i_CoreTakeCommand0 ) begin
            ddr_cke = i_CoreCommand[4];
            ddr_csn = i_CoreCommand[3];
            ddr_rasn = i_CoreCommand[2];
            ddr_casn = i_CoreCommand[1];
            ddr_wen = i_CoreCommand[0];
            ddr_ba = i_CoreBank;
            ddr_addr = i_CoreAddr;
         end
         else begin
            ddr_cke = 1;
            ddr_csn = 0;
            ddr_rasn = 1;
            ddr_casn = 1;
            ddr_wen = 1;
            ddr_ba = 2'b00;
            ddr_addr = 13'b0000000000000;
         end
      end 
      else begin
         if (i_InitTakeCommand0 ) begin
            ddr_cke = i_InitCommand[4];
            ddr_csn = i_InitCommand[3];
            ddr_rasn = i_InitCommand[2];
            ddr_casn = i_InitCommand[1];
            ddr_wen = i_InitCommand[0];
            ddr_ba = i_InitBank;
            ddr_addr = i_InitAddr;
         end
         else begin
            ddr_cke = 1;
            ddr_csn = 0;
            ddr_rasn = 1;
            ddr_casn = 1;
            ddr_wen = 1;
            ddr_ba = 2'b00;
            ddr_addr = 13'b0000000000000;
         end
      end 
   end 
   assign ddr_dm = 2'b00;
   assign ddr_dq = i_CoreTakeCommand1 ? (dftclock90 == 0 ? s_IntfPage[31:16] : s_IntfPage[15:0]) : 16'bzzzzzzzzzzzzzzzz;
   assign ddr_dqs = (i_CoreTakeCommand2 || i_CoreTakeCommand3) ? {clock0,clock0} : 2'bzz;
   assign w_InstCode = inst[11:8];
   assign w_InstImm = inst[7:0];
   assign i_Ready = s_IntfState == `DdrCtl1_IntfState_Ready &&
                    s_CoreState == `DdrCtl1_CoreState_Ready &&
                    w_InstCode != `DdrCtl1_RDP &&
                    w_InstCode != `DdrCtl1_WRP;
   always @ (posedge clock0) begin
      if (reset) begin
         s_IntfState   <= `DdrCtl1_IntfState_Reset;
         s_IntfAddress <= 0;
         s_IntfPage    <= 0;
         i_IntfDoRead  <= 0;
         i_IntfDoWrite <= 0;
      end
      else begin
         case (s_IntfState)
           `DdrCtl1_IntfState_Reset: begin
              s_IntfState   <= `DdrCtl1_IntfState_WaitInit;
              s_IntfAddress <= 0;
              s_IntfPage    <= 0;
              i_IntfDoRead  <= 0;
              i_IntfDoWrite <= 0;
           end
           `DdrCtl1_IntfState_WaitInit: begin
              if (i_InitDone) begin
                 s_IntfState   <= `DdrCtl1_IntfState_Ready;
                 s_IntfAddress <= 0;
                 s_IntfPage    <= 0;
		 i_IntfDoRead  <= 0;
		 i_IntfDoWrite <= 0;
              end
              else begin
                 s_IntfState   <= `DdrCtl1_IntfState_WaitInit;
                 s_IntfAddress <= 0;
                 s_IntfPage    <= 0;
		 i_IntfDoRead  <= 0;
		 i_IntfDoWrite <= 0;
              end
           end 
           `DdrCtl1_IntfState_Ready: begin
              if (inst_en) begin
                 case (w_InstCode)
                   `DdrCtl1_NOP: begin
                      s_IntfState   <= `DdrCtl1_IntfState_Ready;
                      s_IntfAddress <= s_IntfAddress;
                      s_IntfPage    <= s_IntfPage;
		      i_IntfDoRead  <= 0;
		      i_IntfDoWrite <= 0;
                   end
                   `DdrCtl1_LA0: begin
                      s_IntfState   <= `DdrCtl1_IntfState_Ready;
                      s_IntfAddress <= {s_IntfAddress[31:8],w_InstImm};
                      s_IntfPage    <= s_IntfPage;
		      i_IntfDoRead  <= 0;
		      i_IntfDoWrite <= 0;
                   end
                   `DdrCtl1_LA1: begin
                      s_IntfState   <= `DdrCtl1_IntfState_Ready;
                      s_IntfAddress <= {s_IntfAddress[31:16],w_InstImm,s_IntfAddress[7:0]};
                      s_IntfPage    <= s_IntfPage;
		      i_IntfDoRead  <= 0;
		      i_IntfDoWrite <= 0;
                   end
                   `DdrCtl1_LA2: begin
                      s_IntfState   <= `DdrCtl1_IntfState_Ready;
                      s_IntfAddress <= {s_IntfAddress[31:24],w_InstImm,s_IntfAddress[15:0]};
                      s_IntfPage    <= s_IntfPage;
		      i_IntfDoRead  <= 0;
		      i_IntfDoWrite <= 0;
                   end
                   `DdrCtl1_LA3: begin
                      s_IntfState   <= `DdrCtl1_IntfState_Ready;
                      s_IntfAddress <= {w_InstImm,s_IntfAddress[23:0]};
                      s_IntfPage    <= s_IntfPage;
		      i_IntfDoRead  <= 0;
		      i_IntfDoWrite <= 0;
                   end
                   `DdrCtl1_LD0: begin
                      s_IntfState   <= `DdrCtl1_IntfState_Ready;
                      s_IntfAddress <= s_IntfAddress;
                      s_IntfPage    <= {s_IntfPage[31:8],w_InstImm};
		      i_IntfDoRead  <= 0;
		      i_IntfDoWrite <= 0;
                   end
                   `DdrCtl1_LD1: begin
                      s_IntfState   <= `DdrCtl1_IntfState_Ready;
                      s_IntfAddress <= s_IntfAddress;
                      s_IntfPage    <= {s_IntfPage[31:16],w_InstImm,s_IntfPage[7:0]};
		      i_IntfDoRead  <= 0;
		      i_IntfDoWrite <= 0;
                   end
                   `DdrCtl1_LD2: begin
                      s_IntfState   <= `DdrCtl1_IntfState_Ready;
                      s_IntfAddress <= s_IntfAddress;
                      s_IntfPage    <= {s_IntfPage[31:24],w_InstImm,s_IntfPage[15:0]};
		      i_IntfDoRead  <= 0;
		      i_IntfDoWrite <= 0;
                   end
                   `DdrCtl1_LD3: begin
                      s_IntfState   <= `DdrCtl1_IntfState_Ready;
                      s_IntfAddress <= s_IntfAddress;
                      s_IntfPage    <= {w_InstImm,s_IntfPage[23:0]};
		      i_IntfDoRead  <= 0;
		      i_IntfDoWrite <= 0;
                   end
                   `DdrCtl1_RDP: begin
                      s_IntfState   <= `DdrCtl1_IntfState_WaitRead;
                      s_IntfAddress <= s_IntfAddress;
                      s_IntfPage    <= s_IntfPage;
		      i_IntfDoRead  <= 0;
		      i_IntfDoWrite <= 0;
                   end
                   `DdrCtl1_WRP: begin
                      s_IntfState   <= `DdrCtl1_IntfState_WaitWrite;
                      s_IntfAddress <= s_IntfAddress;
                      s_IntfPage    <= s_IntfPage;
		      i_IntfDoRead  <= 0;
		      i_IntfDoWrite <= 0;
                   end
                   default: begin
                      s_IntfState   <= `DdrCtl1_IntfState_Error;
                      s_IntfAddress <= 0;
                      s_IntfPage    <= 0;
		      i_IntfDoRead  <= 0;
		      i_IntfDoWrite <= 0;
                   end
                 endcase 
              end 
              else begin
                 s_IntfState   <= `DdrCtl1_IntfState_Ready;
                 s_IntfAddress <= s_IntfAddress;
                 s_IntfPage    <= s_IntfPage;
		 i_IntfDoRead  <= 0;
		 i_IntfDoWrite <= 0;
              end 
           end 
           `DdrCtl1_IntfState_WaitRead: begin
              if (i_CoreReadDone) begin
                 s_IntfState   <= `DdrCtl1_IntfState_Ready;
                 s_IntfAddress <= s_IntfAddress;
                 s_IntfPage    <= {s_HalfPage0,s_HalfPage1};
		 i_IntfDoRead  <= 0;
		 i_IntfDoWrite <= 0;
              end
              else begin
                 s_IntfState   <= `DdrCtl1_IntfState_WaitRead;
                 s_IntfAddress <= s_IntfAddress;
                 s_IntfPage    <= s_IntfPage;
		 i_IntfDoRead  <= 1;
		 i_IntfDoWrite <= 0;
              end
           end 
           `DdrCtl1_IntfState_WaitWrite: begin
              if (i_CoreWriteDone) begin
                 s_IntfState   <= `DdrCtl1_IntfState_Ready;
                 s_IntfAddress <= s_IntfAddress;
                 s_IntfPage    <= s_IntfPage;
		 i_IntfDoRead  <= 0;
		 i_IntfDoWrite <= 0;
              end
              else begin
                 s_IntfState   <= `DdrCtl1_IntfState_WaitWrite;
                 s_IntfAddress <= s_IntfAddress;
                 s_IntfPage    <= s_IntfPage;
		 i_IntfDoRead  <= 0;
		 i_IntfDoWrite <= 1;
              end
           end 
           `DdrCtl1_IntfState_Error: begin
              s_IntfState   <= `DdrCtl1_IntfState_Error;
              s_IntfAddress <= 0;
              s_IntfPage    <= 0;
              i_IntfDoRead  <= 0;
              i_IntfDoWrite <= 0;
           end
           default: begin
              s_IntfState   <= `DdrCtl1_IntfState_Error;
              s_IntfAddress <= 0;
              s_IntfPage    <= 0;
              i_IntfDoRead  <= 0;
              i_IntfDoWrite <= 0;
           end
         endcase 
      end 
   end 
   always @ (posedge clock0) begin
      if (reset) begin
         s_CoreState <= `DdrCtl1_CoreState_Reset;
         i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
         i_CoreBank        <= 0;
         i_CoreAddr        <= 0;
         i_CoreTakeCommand0 <= 0;
         i_CoreTakeCommand1 <= 0;
         i_CoreTakeCommand2 <= 0;
         i_CoreTakeCommand3 <= 0;
         i_CoreRefreshDone <= 0;
         i_CoreReadDone    <= 0;
         i_CoreWriteDone   <= 0;
      end
      else begin
         case (s_CoreState)
           `DdrCtl1_CoreState_Reset: begin
              s_CoreState <= `DdrCtl1_CoreState_WaitInit;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
           `DdrCtl1_CoreState_WaitInit: begin
              if (i_InitDone) begin
                 s_CoreState <= `DdrCtl1_CoreState_Ready;
		 i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
		 i_CoreBank        <= 0;
		 i_CoreAddr        <= 0;
		 i_CoreTakeCommand0 <= 0;
		 i_CoreTakeCommand1 <= 0;
		 i_CoreTakeCommand2 <= 0;
		 i_CoreTakeCommand3 <= 0;
		 i_CoreRefreshDone <= 0;
		 i_CoreReadDone    <= 0;
		 i_CoreWriteDone   <= 0;
              end
              else begin
                 s_CoreState <= `DdrCtl1_CoreState_WaitInit;
		 i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
		 i_CoreBank        <= 0;
		 i_CoreAddr        <= 0;
		 i_CoreTakeCommand0 <= 0;
		 i_CoreTakeCommand1 <= 0;
		 i_CoreTakeCommand2 <= 0;
		 i_CoreTakeCommand3 <= 0;
		 i_CoreRefreshDone <= 0;
		 i_CoreReadDone    <= 0;
		 i_CoreWriteDone   <= 0;
              end
           end 
           `DdrCtl1_CoreState_Ready: begin
              if (i_AutoRefreshDoRefresh) begin
                 s_CoreState <= `DdrCtl1_CoreState_Refresh_AutoRefresh;
		 i_CoreCommand     <= `DdrCtl1_DdrCommand_AutoRefresh;
		 i_CoreBank        <= 0;
		 i_CoreAddr        <= 0;
		 i_CoreTakeCommand0 <= 1;
		 i_CoreTakeCommand1 <= 0;
		 i_CoreTakeCommand2 <= 0;
		 i_CoreTakeCommand3 <= 0;
		 i_CoreRefreshDone <= 0;
		 i_CoreReadDone    <= 0;
		 i_CoreWriteDone   <= 0;
              end
              else if (i_IntfDoRead) begin
                 s_CoreState <= `DdrCtl1_CoreState_Read_Activate;
		 i_CoreCommand     <= `DdrCtl1_DdrCommand_Activate;
		 i_CoreBank        <= s_IntfAddress[31:30];
		 i_CoreAddr        <= {s_IntfAddress[29:13],3'b000};
		 i_CoreTakeCommand0 <= 1;
		 i_CoreTakeCommand1 <= 0;
		 i_CoreTakeCommand2 <= 0;
		 i_CoreTakeCommand3 <= 0;
		 i_CoreRefreshDone <= 0;
		 i_CoreReadDone    <= 0;
		 i_CoreWriteDone   <= 0;
              end
              else if (i_IntfDoWrite) begin
                 s_CoreState <= `DdrCtl1_CoreState_Write_Activate;
		 i_CoreCommand     <= `DdrCtl1_DdrCommand_Activate;
		 i_CoreBank        <= s_IntfAddress[31:30];
		 i_CoreAddr        <= {s_IntfAddress[29:13],3'b000};
		 i_CoreTakeCommand0 <= 1;
		 i_CoreTakeCommand1 <= 0;
		 i_CoreTakeCommand2 <= 0;
		 i_CoreTakeCommand3 <= 0;
		 i_CoreRefreshDone <= 0;
		 i_CoreReadDone    <= 0;
		 i_CoreWriteDone   <= 0;
              end
              else begin
                 s_CoreState <= `DdrCtl1_CoreState_Ready;
		 i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
		 i_CoreBank        <= 0;
		 i_CoreAddr        <= 0;
		 i_CoreTakeCommand0 <= 0;
		 i_CoreTakeCommand1 <= 0;
		 i_CoreTakeCommand2 <= 0;
		 i_CoreTakeCommand3 <= 0;
		 i_CoreRefreshDone <= 0;
		 i_CoreReadDone    <= 0;
		 i_CoreWriteDone   <= 0;
              end
           end 
           `DdrCtl1_CoreState_Refresh_AutoRefresh: begin
              s_CoreState <= `DdrCtl1_CoreState_Refresh_Wait0;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
           `DdrCtl1_CoreState_Refresh_Wait0: begin
              s_CoreState <= `DdrCtl1_CoreState_Refresh_Wait1;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
           `DdrCtl1_CoreState_Refresh_Wait1: begin
              s_CoreState <= `DdrCtl1_CoreState_Refresh_Wait2;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
           `DdrCtl1_CoreState_Refresh_Wait2: begin
              s_CoreState <= `DdrCtl1_CoreState_Ready;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 1;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
           `DdrCtl1_CoreState_Read_Activate: begin
              s_CoreState <= `DdrCtl1_CoreState_Read_Read;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_Read;
              i_CoreBank        <= s_IntfAddress[31:30];
              i_CoreAddr        <= {s_IntfAddress[29:13],3'b000};
              i_CoreTakeCommand0 <= 1;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
           `DdrCtl1_CoreState_Read_Read: begin
              s_CoreState <= `DdrCtl1_CoreState_Read_Wait0;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 1;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
           `DdrCtl1_CoreState_Read_Wait0: begin
              s_CoreState <= `DdrCtl1_CoreState_Read_Wait1;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 1;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
           `DdrCtl1_CoreState_Read_Wait1: begin
              s_CoreState <= `DdrCtl1_CoreState_Ready;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 1;
              i_CoreWriteDone   <= 0;
           end
           `DdrCtl1_CoreState_Write_Activate: begin
              s_CoreState <= `DdrCtl1_CoreState_Write_Write;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_Write;
              i_CoreBank        <= s_IntfAddress[31:30];
              i_CoreAddr        <= {s_IntfAddress[29:13],3'b000};
              i_CoreTakeCommand0 <= 1;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
           `DdrCtl1_CoreState_Write_Write: begin
              s_CoreState <= `DdrCtl1_CoreState_Write_Wait0;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 1;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
           `DdrCtl1_CoreState_Write_Wait0: begin
              s_CoreState <= `DdrCtl1_CoreState_Write_Wait1;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 1;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
           `DdrCtl1_CoreState_Write_Wait1: begin
              s_CoreState <= `DdrCtl1_CoreState_Ready;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 1;
           end
           `DdrCtl1_CoreState_Error: begin
              s_CoreState <= `DdrCtl1_CoreState_Error;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
           default: begin
              s_CoreState <= `DdrCtl1_CoreState_Error;
              i_CoreCommand     <= `DdrCtl1_DdrCommand_NoOperation;
              i_CoreBank        <= 0;
              i_CoreAddr        <= 0;
              i_CoreTakeCommand0 <= 0;
              i_CoreTakeCommand1 <= 0;
              i_CoreTakeCommand2 <= 0;
              i_CoreTakeCommand3 <= 0;
              i_CoreRefreshDone <= 0;
              i_CoreReadDone    <= 0;
              i_CoreWriteDone   <= 0;
           end
         endcase 
      end 
   end 
   always @ (posedge clock0) begin
      if (reset) begin
         s_InitState <= `DdrCtl1_InitState_Reset;
         i_InitCommand     <= `DdrCtl1_DdrCommand_NoOperation;
         i_InitBank        <= 0;
         i_InitAddr        <= 0;
         i_InitTakeCommand0 <= 0;
         i_InitTakeCommand1 <= 0;
         i_InitDone        <= 0;
         i_InitDo200us     <= 0;
         i_InitDo200       <= 0;
      end
      else begin
         case (s_InitState)
           `DdrCtl1_InitState_Reset: begin
              s_InitState <= `DdrCtl1_InitState_PowerUp;
              i_InitCommand     <= `DdrCtl1_DdrCommand_PowerUp;
              i_InitBank        <= 0;
              i_InitAddr        <= 0;
              i_InitTakeCommand0 <= 1;
              i_InitTakeCommand1 <= 0;
              i_InitDone        <= 0;
              i_InitDo200us     <=