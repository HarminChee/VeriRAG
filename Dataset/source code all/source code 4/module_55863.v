module cpu(clk, rst_n, hlt, pc);
  input clk; 
  input rst_n;
  output reg hlt; 
  output [15:0] pc;
  wire [15:0] branchAddr;
  wire flush, stall, globalStall, branch, branchInit, forwardStall, cacheStall;
  HazardControl hazardcontrol(
                              .clk(clk),
                              .rst_n(rst_n),
                              .branch(branch),
                              .branchInit(branchInit),
                              .forwardStall(forwardStall),
                              .cacheStall(cacheStall),
                              .flush(flush),
                              .stall(stall),
                              .globalStall(globalStall));
  assign rd_en = 1'b1; 
  wire hlt_IF;
  wire [15:0] instr_IF, pc_IF;
  InstructionFetch instructionfetch(
                                    .clk(clk),
                                    .rst_n(rst_n),
                                    .branch(branch),
                                    .branchAddr(branchAddr),
                                    .instr(instr_IF),
                                    .stall(stall),
                                    .globalStall(globalStall),
                                    .rd_en(rd_en),
                                    .pcNext(pc),
                                    .branchInit(branchInit),
                                    .pc(pc_IF),
                                    .hlt(hlt_IF));
  reg [15:0] instr_IF_ID, pcNext_IF_ID;
  reg hlt_IF_ID;
  always @(posedge clk or negedge rst_n) begin  
    if(!rst_n) begin
      hlt_IF_ID <= 1'b0;
      pcNext_IF_ID <= 16'h0000;
      instr_IF_ID <= 16'hB0FF;
    end 
    else begin
      if(!stall && !globalStall) begin
        if(flush) begin
          hlt_IF_ID <= 1'b0;
          instr_IF_ID <= 16'hB0FF; 
        end else begin 
          hlt_IF_ID <= hlt_IF;
          instr_IF_ID <= instr_IF;
        end        
        pcNext_IF_ID <= pc;
      end
    end
  end
  wire [15:0] writeData;
  wire [3:0] writeAddr;
  wire writeEnable;
  wire [15:0] p0_ID, p1_ID;
  wire [11:0] imm_ID;
  wire [3:0] p0Addr_ID, p1Addr_ID, regAddr_ID, shamt_ID;
  wire [2:0] aluOp_ID, branchOp_ID;
  wire regWe_ID, memRe_ID, memWe_ID, addz_ID, branch_ID, jal_ID, jr_ID, aluSrc0_ID, aluSrc1_ID, ovEn_ID, zrEn_ID, neEn_ID;
  InstructionDecode instructiondecode(
        .clk(clk),
        .hlt(hlt),
        .writeData(writeData),
        .writeAddr(writeAddr),        
        .writeEnable(writeEnable),
        .instr(instr_IF_ID),
        .p0(p0_ID),
        .p1(p1_ID),
        .imm(imm_ID),
        .p0Addr(p0Addr_ID), 
        .p1Addr(p1Addr_ID),
        .regAddr(regAddr_ID),
        .shamt(shamt_ID),
        .aluOp(aluOp_ID),
        .branchOp(branchOp_ID),
        .regWe(regWe_ID), 
        .memRe(memRe_ID),
        .memWe(memWe_ID),
        .addz(addz_ID),
        .branch(branch_ID),
        .jal(jal_ID),
        .jr(jr_ID),
        .aluSrc0(aluSrc0_ID), 
        .aluSrc1(aluSrc1_ID),
        .ovEn(ovEn_ID), 
        .zrEn(zrEn_ID), 
        .neEn(neEn_ID)
        );
  reg [15:0] p0_ID_EX, p1_ID_EX, pcNext_ID_EX;
  reg [11:0] imm_ID_EX;
  reg [3:0] p0Addr_ID_EX, p1Addr_ID_EX, shamt_ID_EX;
  reg [2:0] aluOp_ID_EX;
  reg aluSrc0_ID_EX, aluSrc1_ID_EX;
  reg [3:0] regAddr_ID_EX;
  reg [2:0] branchOp_ID_EX;
  reg regWe_ID_EX, memRe_ID_EX, memWe_ID_EX, addz_ID_EX, branch_ID_EX, jal_ID_EX, jr_ID_EX, ovEn_ID_EX, zrEn_ID_EX, neEn_ID_EX, hlt_ID_EX;
  always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin
      hlt_ID_EX <= 1'b0;
      p0_ID_EX <= 16'h0000;
      p1_ID_EX <= 16'h0000;
      pcNext_ID_EX <= 16'h0000;
      imm_ID_EX <= 12'h000;
      p0Addr_ID_EX <= 4'h0;
      p1Addr_ID_EX <= 4'h0;
      shamt_ID_EX <= 4'h0;
      aluOp_ID_EX <= 3'b000;
      aluSrc0_ID_EX <= 1'b1;
      aluSrc1_ID_EX <= 1'b1;
      regAddr_ID_EX <= 4'h0;
      regWe_ID_EX <= 1'b0;
      memRe_ID_EX <= 1'b0; 
      memWe_ID_EX <= 1'b0;
      branch_ID_EX <= 1'b0;
      jal_ID_EX <= 1'b0;
      jr_ID_EX <= 1'b0;
      ovEn_ID_EX <= 1'b0;
      zrEn_ID_EX <= 1'b0;
      neEn_ID_EX <= 1'b0;
    end 
    else begin
      if(!stall && !globalStall) begin
        p0_ID_EX <= p0_ID;
        p1_ID_EX <= p1_ID;
        pcNext_ID_EX <= pcNext_IF_ID;
        imm_ID_EX <= imm_ID;
        p0Addr_ID_EX <= p0Addr_ID;
        p1Addr_ID_EX <= p1Addr_ID;
        shamt_ID_EX <= shamt_ID;
        aluOp_ID_EX <= aluOp_ID;
        aluSrc0_ID_EX <= aluSrc0_ID;
        aluSrc1_ID_EX <= aluSrc1_ID;
        branchOp_ID_EX <= branchOp_ID;             
        addz_ID_EX <= addz_ID;
        if(flush) begin
          hlt_ID_EX <= 1'b0;
          regAddr_ID_EX <= 4'h0;
          regWe_ID_EX <= 1'b0;
          memRe_ID_EX <= 1'b0; 
          memWe_ID_EX <= 1'b0;
          branch_ID_EX <= 1'b0;
          jal_ID_EX <= 1'b0;
          jr_ID_EX <= 1'b0;
          ovEn_ID_EX <= 1'b0;
          zrEn_ID_EX <= 1'b0;
          neEn_ID_EX <= 1'b0;
        end
        else begin
          hlt_ID_EX <= hlt_IF_ID;
          regAddr_ID_EX <= regAddr_ID;
          regWe_ID_EX <= regWe_ID;
          memRe_ID_EX <= memRe_ID; 
          memWe_ID_EX <= memWe_ID;
          branch_ID_EX <= branch_ID;
          jal_ID_EX <= jal_ID;
          jr_ID_EX <= jr_ID;
          ovEn_ID_EX <= ovEn_ID;
          zrEn_ID_EX <= zrEn_ID;
          neEn_ID_EX <= neEn_ID;
        end
      end
    end
  end
  wire [15:0] forwardP0_EX, forwardP1_EX;
  reg [15:0] aluResult_EX_MEM, pcNext_EX_MEM, aluResult_MEM_WB, pcNext_MEM_WB, memData_MEM_WB, writeData_WB;
  reg [3:0] regAddr_EX_MEM, regAddr_MEM_WB, writeAddr_WB;
  reg jal_EX_MEM, memRe_EX_MEM, regWe_MEM_WB, jal_MEM_WB, memRe_MEM_WB, writeEnable_WB, regWe_EX_MEM;
  ExecuteForwarding executeforwarding(
                  .p0(p0_ID_EX),
                  .p1(p1_ID_EX),
                  .p0Addr(p0Addr_ID_EX),
                  .p1Addr(p1Addr_ID_EX),
                  .regAddr_EX_MEM(regAddr_EX_MEM), 
                  .regWe_EX_MEM(regWe_EX_MEM),
                  .aluResult_EX_MEM(aluResult_EX_MEM),
                  .jal_EX_MEM(jal_EX_MEM),
                  .pcNext_EX_MEM(pcNext_EX_MEM),
                  .memRe_EX_MEM(memRe_EX_MEM),
                  .regAddr_MEM_WB(regAddr_MEM_WB), 
                  .regWe_MEM_WB(regWe_MEM_WB),
                  .aluResult_MEM_WB(aluResult_MEM_WB),
                  .jal_MEM_WB(jal_MEM_WB),
                  .pcNext_MEM_WB(pcNext_MEM_WB),
                  .memRe_MEM_WB(memRe_MEM_WB),
                  .memData_MEM_WB(memData_MEM_WB),
                  .writeData_WB(writeData_WB),
                  .writeAddr_WB(writeAddr_WB),
                  .writeEnable_WB(writeEnable_WB),
                  .forwardP0(forwardP0_EX),
                  .forwardP1(forwardP1_EX),
                  .forwardStall(forwardStall));
  wire [15:0] aluResult_EX;
  wire ov_EX, zr_EX, ne_EX, regWe_EX, memWe_EX;
  reg ov_EX_MEM, zr_EX_MEM, ne_EX_MEM;
  Execute execute(
                  .p0(forwardP0_EX),
                  .p1(forwardP1_EX),
                  .pcNext(pcNext_ID_EX),
                  .imm(imm_ID_EX),
                  .shamt(shamt_ID_EX),
                  .aluOp(aluOp_ID_EX),
                  .branchOp(branchOp_ID_EX),  
                  .aluSrc0(aluSrc0_ID_EX),
                  .aluSrc1(aluSrc1_ID_EX),
                  .regWe(regWe_ID_EX),
                  .memWe(memWe_ID_EX),
                  .addz(addz_ID_EX),
                  .b(branch_ID_EX),
                  .jal(jal_ID_EX),
                  .jr(jr_ID_EX),
                  .zr_EX_MEM(zr_EX_MEM),
                  .ne_EX_MEM(ne_EX_MEM), 
                  .ov_EX_MEM(ov_EX_MEM),                  
                  .ov_EX(ov_EX),
                  .zr_EX(zr_EX),
                  .ne_EX(ne_EX),
                  .aluResult(aluResult_EX),
                  .regWriteEnable(regWe_EX),
                  .memoryWriteEnable(memWe_EX),
                  .branchAddr(branchAddr),
                  .branch(branch));
  reg [15:0] p1_EX_MEM, memAddr_EX_MEM;
  reg [3:0] p1Addr_EX_MEM;
  reg memWe_EX_MEM, hlt_EX_MEM;
  always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin
      hlt_EX_MEM <= 1'b0;
      aluResult_EX_MEM <= 16'h0000;
      p1_EX_MEM <= 16'h0000; 
      p1Addr_EX_MEM <= 4'h0;
      memAddr_EX_MEM <= 16'h0000;
      memRe_EX_MEM <= 1'b0;
      memWe_EX_MEM <= 1'b0;
      jal_EX_MEM <= 1'b0;
      ov_EX_MEM <= 1'b0;
      zr_EX_MEM <= 1'b0;
      ne_EX_MEM <= 1'b0;
      pcNext_EX_MEM <= 16'h0000;
      regAddr_EX_MEM <= 4'h0;
      regWe_EX_MEM <= 1'b0;
    end
    else begin
      if(!stall && !globalStall) begin
        aluResult_EX_MEM <= aluResult_EX; 
        memAddr_EX_MEM <= aluResult_EX; 
        p1_EX_MEM <= forwardP1_EX; 
        p1Addr_EX_MEM <= p1Addr_ID_EX;
        memRe_EX_MEM <= memRe_ID_EX;
        memWe_EX_MEM <= memWe_EX;
        jal_EX_MEM <= jal_ID_EX;
        if(ovEn_ID_EX) begin
          ov_EX_MEM <= ov_EX;
        end
        else begin
          ov_EX_MEM <= ov_EX_MEM;
        end
        if (zrEn_ID_EX) begin
          zr_EX_MEM <= zr_EX;
        end
        else begin
          zr_EX_MEM <= zr_EX_MEM;
        end
        if (neEn_ID_EX) begin
          ne_EX_MEM <= ne_EX; 
        end
        else begin
          ne_EX_MEM <= ne_EX_MEM;
        end
        pcNext_EX_MEM <= pcNext_ID_EX;
        regAddr_EX_MEM <= regAddr_ID_EX;
        regWe_EX_MEM <= regWe_EX;
        if(flush) begin
          hlt_EX_MEM <= 1'b0;
        end else begin 
          hlt_EX_MEM <= hlt_ID_EX;
        end
      end
    end
  end
  wire [15:0] forwardWrtData_MEM;
  MemoryForwarding memoryforwarding(
    .wrtData(p1_EX_MEM),
    .p1Addr(p1Addr_EX_MEM),
    .regAddr_MEM_WB(regAddr_MEM_WB), 
    .regWe_MEM_WB(regWe_MEM_WB),
    .aluResult_MEM_WB(aluResult_MEM_WB),
    .jal_MEM_WB(jal_MEM_WB),
    .pcNext_MEM_WB(pcNext_MEM_WB),
    .memRe_MEM_WB(memRe_MEM_WB),
    .memData_MEM_WB(memData_MEM_WB),
    .forwardWrtData(forwardWrtData_MEM)
  );
  wire [15:0] memData_MEM; 
  MemoryHierarchy memoryhierarchy(
    .clk(clk),
    .rst_n(rst_n),
    .i_acc(rd_en),
    .d_rd_acc(memRe_EX_MEM),
    .d_wr_acc(memWe_EX_MEM),
    .i_addr(pc_IF),
    .d_addr(memAddr_EX_MEM),
    .d_wrt_data(forwardWrtData_MEM),
    .stall(cacheStall),
    .instr(instr_IF),
    .data(memData_MEM));  
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      hlt <= 1'b0;
      pcNext_MEM_WB <= 16'h0000;
      memData_MEM_WB <= 16'h0000;
      aluResult_MEM_WB <= 16'h0000;
      regAddr_MEM_WB <= 4'h0;
      jal_MEM_WB  <= 1'b0;
      memRe_MEM_WB <= 1'b0;
      regWe_MEM_WB <= 1'b0;
    end
    else begin
      if(!globalStall) begin
        pcNext_MEM_WB <= pcNext_EX_MEM;
        memData_MEM_WB <= memData_MEM;
        aluResult_MEM_WB <= aluResult_EX_MEM;
        regAddr_MEM_WB <= regAddr_EX_MEM;
        jal_MEM_WB <= jal_EX_MEM;
        memRe_MEM_WB <= memRe_EX_MEM;
        regWe_MEM_WB <= regWe_EX_MEM;      
        if(flush) begin
          hlt <= 1'b0;
        end else begin 
          hlt <= hlt_EX_MEM;
        end
      end
    end
  end
  Writeback writeback(
    .jal(jal_MEM_WB),
    .memRe(memRe_MEM_WB),
    .regWe(regWe_MEM_WB),
    .regAddr(regAddr_MEM_WB),
    .pcNext(pcNext_MEM_WB),
    .memData(memData_MEM_WB),
    .aluResult(aluResult_MEM_WB),     
    .writeData(writeData),
    .writeAddr(writeAddr),
    .writeEnable(writeEnable));
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      writeEnable_WB <= 1'b0;
    end
    else begin
      writeData_WB <= writeData;
      writeAddr_WB <= writeAddr;
      writeEnable_WB <= writeEnable;
    end
  end  
endmodule
