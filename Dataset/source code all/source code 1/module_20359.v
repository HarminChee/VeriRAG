`timescale 1ps/1ps
`timescale 1ps/1ps
module pcie3_7x_0_pcie_bram_7vx_16k #(
  parameter IMPL_TARGET = "HARD",         
  parameter NO_DECODE_LOGIC = "TRUE",     
  parameter INTERFACE_SPEED = "500 MHZ",  
  parameter COMPLETION_SPACE = "16 KB"    
)
(
  input               clk_i,    
  input               reset_i,  
  input    [9:0]      waddr0_i, 
  input    [9:0]      waddr1_i, 
  input    [9:0]      waddr2_i, 
  input    [9:0]      waddr3_i, 
  input  [127:0]      wdata_i,  
  input   [15:0]      wdip_i,   
  input    [7:0]      wen_i,    
  input    [9:0]      raddr0_i, 
  input    [9:0]      raddr1_i, 
  input    [9:0]      raddr2_i, 
  input    [9:0]      raddr3_i, 
  output [127:0]      rdata_o,  
  output  [15:0]      rdop_o,   
  input    [7:0]      ren_i     
);
  localparam           TCQ                         =  1;
  genvar              i;
  wire     [79:0]     waddr;
  wire     [79:0]     raddr;
  wire      [7:0]     wen;
  wire      [7:0]     ren;
  wire    [255:0]     rdata_w;
  wire     [31:0]     rdop_w;
  wire    [255:0]     wdata_w;
  wire     [31:0]     wdip_w;
  reg                 raddr0_q = 1'b0;
  reg                 raddr0_qq = 1'b0;
  assign wen = {wen_i[7], wen_i[6], wen_i[5], wen_i[4], wen_i[3], wen_i[2], wen_i[1], wen_i[0]};
  assign ren = {ren_i[7], ren_i[6], ren_i[5], ren_i[4], ren_i[3], ren_i[2], ren_i[1], ren_i[0]};
  generate 
    if ((INTERFACE_SPEED == "500 MHZ") || (NO_DECODE_LOGIC == "TRUE")) begin :  SPEED_500MHz_OR_NO_DECODE_LOGIC
      assign waddr = {waddr3_i, waddr3_i, waddr2_i, waddr2_i, waddr1_i, waddr1_i, waddr0_i, waddr0_i};
      assign raddr = {raddr3_i, raddr3_i, raddr2_i, raddr2_i, raddr1_i, raddr1_i, raddr0_i, raddr0_i};
      for (i = 0; i < 8; i = i + 1) begin : RAMB18E1
        RAMB18E1 #(
          .SIM_DEVICE ("7SERIES"),
          .DOA_REG ( 1 ),
          .DOB_REG ( 1 ),
          .SRVAL_A ( 18'h00000 ),
          .INIT_FILE ( "NONE" ),
          .RAM_MODE ( "TDP" ),
          .READ_WIDTH_A ( 18 ),
          .READ_WIDTH_B ( 18 ),
          .RSTREG_PRIORITY_A ( "REGCE" ),
          .RSTREG_PRIORITY_B ( "REGCE" ),
          .SIM_COLLISION_CHECK ( "ALL" ),
          .INIT_A ( 18'h00000 ),
          .INIT_B ( 18'h00000 ),
          .WRITE_MODE_A ( "WRITE_FIRST" ),
          .WRITE_MODE_B ( "WRITE_FIRST" ),
          .WRITE_WIDTH_A ( 18 ),
          .WRITE_WIDTH_B ( 18 ),
          .SRVAL_B ( 18'h00000 ))
        u_fifo (
          .CLKARDCLK(clk_i),
          .CLKBWRCLK(clk_i),
          .ENARDEN(1'b1),
          .ENBWREN(ren[i]),
          .REGCEAREGCE(1'b0),
          .REGCEB(1'b1 ),
          .RSTRAMARSTRAM(1'b0),
          .RSTRAMB(1'b0),
          .RSTREGARSTREG(1'b0),
          .RSTREGB(1'b0),
          .ADDRARDADDR({waddr[(10*i)+9:(10*i)+0], 4'b0}),
          .ADDRBWRADDR({raddr[(10*i)+9:(10*i)+0], 4'b0}),
          .DIADI(wdata_i[(16*i)+15:(16*i)+0]),
          .DIPADIP(wdip_i[(2*i)+1:(2*i)+0]),
          .DIBDI({16'b0}),
          .DIPBDIP(2'b0),
          .DOADO(),
          .DOBDO(rdata_o[(16*i)+15:(16*i)+0]),            
          .DOPADOP(),
          .DOPBDOP(rdop_o[(2*i)+1:(2*i)+0]),               
          .WEA({wen[i], wen[i]}),
          .WEBWE({1'b0, 1'b0, 1'b0, 1'b0})
        );
      end
    end else begin : SPEED_250MHz
      always @(posedge clk_i) begin
        if (reset_i) begin
          raddr0_q <= #(TCQ) 1'b0;
          raddr0_qq <= #(TCQ) 1'b0;
        end else begin
          raddr0_q <= #(TCQ) raddr0_i[9];
          raddr0_qq <= #(TCQ) raddr0_q;
        end
      end
      assign rdata_o = raddr0_qq ? rdata_w[255:128] : rdata_w[127:0]; 
      assign rdop_o = raddr0_qq ?  rdop_w[31:16] : rdop_w[15:0];
      assign wdata_w = {wdata_i, wdata_i};
      assign wdip_w = {wdip_i, wdip_i};
      assign waddr = {44'b0, waddr0_i[8:0], waddr1_i[8:0], waddr2_i[8:0], waddr3_i[8:0]};
      assign raddr = {44'b0, raddr0_i[8:0], raddr1_i[8:0], raddr2_i[8:0], raddr3_i[8:0]};
      for (i = 0; i < 4; i = i + 1) begin : RAMB36E1
        RAMB36E1 #(
          .SIM_DEVICE ("7SERIES"),
          .DOA_REG ( 1 ),
          .DOB_REG ( 1 ),
          .EN_ECC_READ ( "FALSE" ),
          .EN_ECC_WRITE ( "FALSE" ),
          .INIT_A ( 36'h000000000 ),
          .INIT_B ( 36'h000000000 ),
          .INIT_FILE ( "NONE" ),
          .RAM_EXTENSION_A ( "NONE" ),
          .RAM_EXTENSION_B ( "NONE" ),
          .RAM_MODE ( "SDP" ),
          .RDADDR_COLLISION_HWCONFIG ( "DELAYED_WRITE" ),
          .READ_WIDTH_A ( 72 ),
          .READ_WIDTH_B ( 0 ),
          .RSTREG_PRIORITY_A ( "REGCE" ),
          .RSTREG_PRIORITY_B ( "REGCE" ),
          .SIM_COLLISION_CHECK ( "ALL" ),
          .SRVAL_A ( 36'h000000000 ),
          .SRVAL_B ( 36'h000000000 ),
          .WRITE_MODE_A ( "WRITE_FIRST" ),
          .WRITE_MODE_B ( "WRITE_FIRST" ),
          .WRITE_WIDTH_A ( 0 ),
          .WRITE_WIDTH_B ( 72 )
        )
        u_fifo (
          .CASCADEINA(1'b0),
          .CASCADEINB(1'b0),
          .CASCADEOUTA( ),
          .CASCADEOUTB( ),
          .CLKARDCLK(clk_i),
          .CLKBWRCLK(clk_i),
          .DBITERR( ),
          .ENARDEN(((i > 1) ? (raddr0_i[9] & ren[2*i]) : (~raddr0_i[9] & ren[2*i]))),
          .ENBWREN(1'b1 ),
          .INJECTDBITERR(1'b0),
          .INJECTSBITERR(1'b0),
          .REGCEAREGCE(1'b1 ),
          .REGCEB(1'b0),
          .RSTRAMARSTRAM(1'b0),
          .RSTRAMB(1'b0),
          .RSTREGARSTREG(1'b0),
          .RSTREGB(1'b0),
          .SBITERR( ),
          .ADDRARDADDR({1'b1 , raddr[(9*i)+8:(9*i)+0], 6'b0}),
          .ADDRBWRADDR({1'b1 , waddr[(9*i)+8:(9*i)+0], 6'b0}),
          .DIADI(wdata_w[(2*32*i)+31:(2*32*i)+0]),
          .DIBDI(wdata_w[(2*32*i)+63:(2*32*i)+32]),
          .DIPADIP(wdip_w[(2*4*i)+3:(2*4*i)+0]),
          .DIPBDIP(wdip_w[(2*4*i)+7:(2*4*i)+4]),
          .DOADO(rdata_w[(2*32*i)+31:(2*32*i)+0]),
          .DOBDO(rdata_w[(2*32*i)+63:(2*32*i)+32]),
          .DOPADOP(rdop_w[(2*4*i)+3:(2*4*i)+0]),
          .DOPBDOP(rdop_w[(2*4*i)+7:(2*4*i)+4]),
          .ECCPARITY(),
          .RDADDRECC(),
          .WEA(4'b0),
          .WEBWE({8{((i > 1) ? (waddr0_i[9] & wen[2*i]) : (~waddr0_i[9] & wen[2*i]))}})
        );
      end
    end
  endgenerate
endmodule 
