`define DdrCtl1_NOP 4'h0
`define DdrCtl1_LA0 4'h1
`define DdrCtl1_LA1 4'h2
`define DdrCtl1_LA2 4'h3
`define DdrCtl1_LA3 4'h4
`define DdrCtl1_LD0 4'h5
`define DdrCtl1_LD1 4'h6
`define DdrCtl1_LD2 4'h7
`define DdrCtl1_LD3 4'h8
`define DdrCtl1_RDP 4'h9
`define DdrCtl1_WRP 4'hA

`define DdrCtl1_DdrCommand_PowerUp          5'b00000
`define DdrCtl1_DdrCommand_Deselect         5'b11000
`define DdrCtl1_DdrCommand_NoOperation      5'b10111
`define DdrCtl1_DdrCommand_Activate         5'b10011
`define DdrCtl1_DdrCommand_Read             5'b10101
`define DdrCtl1_DdrCommand_Write            5'b10100
`define DdrCtl1_DdrCommand_BurtTerminate    5'b10110
`define DdrCtl1_DdrCommand_PreCharge        5'b10010
`define DdrCtl1_DdrCommand_AutoRefresh      5'b10001
`define DdrCtl1_DdrCommand_SelfRefresh      5'b00001
`define DdrCtl1_DdrCommand_LoadModeRegister 5'b10000

`define DdrCtl1_DdrMode_BurstLength_2       3'b001
`define DdrCtl1_DdrMode_BurstLength_4       3'b010
`define DdrCtl1_DdrMode_BurstLength_8       3'b011

module DdrCtl1 (
  input [4:0] i_InitCommand,
  input [1:0] i_InitBank,
  input [15:0] i_InitAddr,
  input [7:0] s_AutoRefreshCounter,
  input i_AutoRefreshDoRefresh,
  input i_CoreRefreshDone,
  input [9:0] s_InitCnt200usCounter,
  input i_InitCnt200usDone,
  input i_InitDo200us,
  input [7:0] s_InitCnt200Counter,
  input i_InitCnt200Done,
  input i_InitDo200
);

`ifdef SYNTHESIS
  // synthesis logic here
`else
  reg [255:0] d_InitState;
  reg [127:0] d_AutoRefreshCounter;
  reg [127:0] d_InitCnt200usCounter;
  reg [127:0] d_InitCnt200Counter;

  always @ * begin
    case (i_InitCommand)
      `DdrCtl1_DdrCommand_PowerUp: begin
        $sformat(d_InitState, "PWRUP  %2b %4h", i_InitBank, i_InitAddr);
      end
      `DdrCtl1_DdrCommand_Deselect: begin
        $sformat(d_InitState, "DESEL  %2b %4h", i_InitBank, i_InitAddr);
      end
      `DdrCtl1_DdrCommand_NoOperation: begin
        $sformat(d_InitState, "NOP    %2b %4h", i_InitBank, i_InitAddr);
      end
      `DdrCtl1_DdrCommand_Activate: begin
        $sformat(d_InitState, "ACT    %2b %4h", i_InitBank, i_InitAddr);
      end
      `DdrCtl1_DdrCommand_Read: begin
        $sformat(d_InitState, "READ   %2b %4h", i_InitBank, i_InitAddr);
      end
      `DdrCtl1_DdrCommand_Write: begin
        $sformat(d_InitState, "WRITE  %2b %4h", i_InitBank, i_InitAddr);
      end
      `DdrCtl1_DdrCommand_BurtTerminate: begin
        $sformat(d_InitState, "TERM   %2b %4h", i_InitBank, i_InitAddr);
      end
      `DdrCtl1_DdrCommand_PreCharge: begin
        $sformat(d_InitState, "PRECHG %2b %4h", i_InitBank, i_InitAddr);
      end
      `DdrCtl1_DdrCommand_AutoRefresh: begin
        $sformat(d_InitState, "REFRSH %2b %4h", i_InitBank, i_InitAddr);
      end
      `DdrCtl1_DdrCommand_SelfRefresh: begin
        $sformat(d_InitState, "SREF   %2b %4h", i_InitBank, i_InitAddr);
      end
      `DdrCtl1_DdrCommand_LoadModeRegister: begin
        $sformat(d_InitState, "LMR    %2b %4h", i_InitBank, i_InitAddr);
      end
      default: begin
        $sformat(d_InitState, "?");
      end
    endcase
  end

  always @ * begin
    $sformat(d_AutoRefreshCounter, "%3d %s %s",
             s_AutoRefreshCounter,
             i_AutoRefreshDoRefresh ? "DoRefresh" : "NoRefresh",
             i_CoreRefreshDone ? "RefreshDone" : "RefreshNotDone");
  end

  always @ * begin
    $sformat(d_InitCnt200usCounter, "%5d %s %s",
             s_InitCnt200usCounter,
             i_InitCnt200usDone ? "200usDone" : "200usNotDone",
             i_InitDo200us ? "Do200us" : "No200us");
  end

  always @ * begin
    $sformat(d_InitCnt200Counter, "%3d %s %s",
             s_InitCnt200Counter,
             i_InitCnt200Done ? "200Done" : "200NotDone",
             i_InitDo200 ? "Do200" : "No200");
  end
`endif

endmodule
