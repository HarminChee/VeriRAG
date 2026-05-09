module my6502mc (
    input       [7:0]   opcode,         
    input       [2:0]   cyc_cnt,        
    output  reg [55:0]  opc_inst,       
    output  reg [7:0]   opc_flag,       
    output              opc_src_a_ar,   
    output              opc_src_a_xr,   
    output              opc_src_a_yr,   
    output              opc_src_a_sp,   
    output              opc_src_a_ps,   
    output              opc_src_a_din,  
    output              opc_src_b_din,  
    output              opc_dst_ar,     
    output              opc_dst_xr,     
    output              opc_dst_yr,     
    output              opc_dst_sp,     
    output              opc_dst_ps,     
    output              opc_dst_dout,   
    output              mc_fetch_en,    
    output              mc_din_le,      
    output              mc_pc_chg,      
    output              mc_addr_pc,     
    output              mc_addr_zp,     
    output              mc_addr_abs,    
    output              mc_addr_sp,     
    output              mc_addr_vl,     
    output              mc_addr_vh,     
    output              mc_dout_pch,    
    output              mc_dout_pcl,    
    output              mc_oe_next,     
    output              mc_alu_inst_op, 
    output              mc_alu_add_xr,  
    output              mc_alu_add_yr,  
    output              mc_alu_add_z,   
    output              mc_alu_inc_din, 
    output              mc_alu_inc_reg, 
    output              mc_alu_inc_sp,  
    output              mc_alu_dec_sp,  
    output              mc_brk_if_set,  
    output              mc_br_chk       
);
parameter   NUM_OF_INST = 56;
reg [12:0]  src_dst;
reg [15:0]  mc_exec;
parameter   I_ADC   =  0;
parameter   I_AND   =  1;
parameter   I_ASL   =  2;
parameter   I_BCC   =  3;
parameter   I_BCS   =  4;
parameter   I_BEQ   =  5;
parameter   I_BIT   =  6;
parameter   I_BMI   =  7;
parameter   I_BNE   =  8;
parameter   I_BPL   =  9;
parameter   I_BRK   = 10;
parameter   I_BVC   = 11;
parameter   I_BVS   = 12;
parameter   I_CLC   = 13;
parameter   I_CLD   = 14;
parameter   I_CLI   = 15;
parameter   I_CLV   = 16;
parameter   I_CMP   = 17;
parameter   I_CPX   = 18;
parameter   I_CPY   = 19;
parameter   I_DEC   = 20;
parameter   I_DEX   = 21;
parameter   I_DEY   = 22;
parameter   I_EOR   = 23;
parameter   I_INC   = 24;
parameter   I_INX   = 25;
parameter   I_INY   = 26;
parameter   I_JMP   = 27;
parameter   I_JSR   = 28;
parameter   I_LDA   = 29;
parameter   I_LDX   = 30;
parameter   I_LDY   = 31;
parameter   I_LSR   = 32;
parameter   I_NOP   = 33;
parameter   I_ORA   = 34;
parameter   I_PHA   = 35;
parameter   I_PHP   = 36;
parameter   I_PLA   = 37;
parameter   I_PLP   = 38;
parameter   I_ROL   = 39;
parameter   I_ROR   = 40;
parameter   I_RTI   = 41;
parameter   I_RTS   = 42;
parameter   I_SBC   = 43;
parameter   I_SEC   = 44;
parameter   I_SED   = 45;
parameter   I_SEI   = 46;
parameter   I_STA   = 47;
parameter   I_STX   = 48;
parameter   I_STY   = 49;
parameter   I_TAX   = 50;
parameter   I_TAY   = 51;
parameter   I_TSX   = 52;
parameter   I_TXA   = 53;
parameter   I_TXS   = 54;
parameter   I_TYA   = 55;
parameter   ADC_IMM = 8'h69;
parameter   ADC_ZP  = 8'h65;
parameter   ADC_ZX  = 8'h75;
parameter   ADC_ABS = 8'h6D;
parameter   ADC_AX  = 8'h7D;
parameter   ADC_AY  = 8'h79;
parameter   ADC_IX  = 8'h61;
parameter   ADC_IY  = 8'h71;
parameter   AND_IMM = 8'h29;
parameter   AND_ZP  = 8'h25;
parameter   AND_ZX  = 8'h35;
parameter   AND_ABS = 8'h2D;
parameter   AND_AX  = 8'h3D;
parameter   AND_AY  = 8'h39;
parameter   AND_IX  = 8'h21;
parameter   AND_IY  = 8'h31;
parameter   ASL_ACC = 8'h0A;
parameter   ASL_ZP  = 8'h06;
parameter   ASL_ZX  = 8'h16;
parameter   ASL_ABS = 8'h0E;
parameter   ASL_AX  = 8'h1E;
parameter   BCC     = 8'h90;
parameter   BCS     = 8'hB0;
parameter   BEQ     = 8'hF0;
parameter   BIT_ZP  = 8'h24;
parameter   BIT_ABS = 8'h2C;
parameter   BMI     = 8'h30;
parameter   BNE     = 8'hD0;
parameter   BPL     = 8'h10;
parameter   BRK     = 8'h00;
parameter   BVC     = 8'h50;
parameter   BVS     = 8'h70;
parameter   CLC     = 8'h18;
parameter   CLD     = 8'hD8;
parameter   CLI     = 8'h58;
parameter   CLV     = 8'hB8;
parameter   CMP_IMM = 8'hC9;
parameter   CMP_ZP  = 8'hC5;
parameter   CMP_ZX  = 8'hD5;
parameter   CMP_ABS = 8'hCD;
parameter   CMP_AX  = 8'hDD;
parameter   CMP_AY  = 8'hD9;
parameter   CMP_IX  = 8'hC1;
parameter   CMP_IY  = 8'hD1;
parameter   CPX_IMM = 8'hE0;
parameter   CPX_ZP  = 8'hE4;
parameter   CPX_ABS = 8'hEC;
parameter   CPY_IMM = 8'hC0;
parameter   CPY_ZP  = 8'hC4;
parameter   CPY_ABS = 8'hCC;
parameter   DEC_ZP  = 8'hC6;
parameter   DEC_ZX  = 8'hD6;
parameter   DEC_ABS = 8'hCE;
parameter   DEC_AX  = 8'hDE;
parameter   DEX     = 8'hCA;
parameter   DEY     = 8'h88;
parameter   EOR_IMM = 8'h49;
parameter   EOR_ZP  = 8'h45;
parameter   EOR_ZX  = 8'h55;
parameter   EOR_ABS = 8'h4D;
parameter   EOR_AX  = 8'h5D;
parameter   EOR_AY  = 8'h59;
parameter   EOR_IX  = 8'h41;
parameter   EOR_IY  = 8'h51;
parameter   INC_ZP  = 8'hE6;
parameter   INC_ZX  = 8'hF6;
parameter   INC_ABS = 8'hEE;
parameter   INC_AX  = 8'hFE;
parameter   INX     = 8'hE8;
parameter   INY     = 8'hC8;
parameter   JMP_ABS = 8'h4C;
parameter   JMP_IND = 8'h6C;
parameter   JSR_ABS = 8'h20;
parameter   LDA_IMM = 8'hA9;
parameter   LDA_ZP  = 8'hA5;
parameter   LDA_ZX  = 8'hB5;
parameter   LDA_ABS = 8'hAD;
parameter   LDA_AX  = 8'hBD;
parameter   LDA_AY  = 8'hB9;
parameter   LDA_IX  = 8'hA1;
parameter   LDA_IY  = 8'hB1;
parameter   LDX_IMM = 8'hA2;
parameter   LDX_ZP  = 8'hA6;
parameter   LDX_ZY  = 8'hB6;
parameter   LDX_ABS = 8'hAE;
parameter   LDX_AY  = 8'hBE;
parameter   LDY_IMM = 8'hA0;
parameter   LDY_ZP  = 8'hA4;
parameter   LDY_ZX  = 8'hB4;
parameter   LDY_ABS = 8'hAC;
parameter   LDY_AX  = 8'hBC;
parameter   LSR_ACC = 8'h4A;
parameter   LSR_ZP  = 8'h46;
parameter   LSR_ZX  = 8'h56;
parameter   LSR_ABS = 8'h4E;
parameter   LSR_AX  = 8'h5E;
parameter   NOP     = 8'hEA;
parameter   ORA_IMM = 8'h09;
parameter   ORA_ZP  = 8'h05;
parameter   ORA_ZX  = 8'h15;
parameter   ORA_ABS = 8'h0D;
parameter   ORA_AX  = 8'h1D;
parameter   ORA_AY  = 8'h19;
parameter   ORA_IX  = 8'h01;
parameter   ORA_IY  = 8'h11;
parameter   PHA     = 8'h48;
parameter   PHP     = 8'h08;
parameter   PLA     = 8'h68;
parameter   PLP     = 8'h28;
parameter   ROL_ACC = 8'h2A;
parameter   ROL_ZP  = 8'h26;
parameter   ROL_ZX  = 8'h36;
parameter   ROL_ABS = 8'h2E;
parameter   ROL_AX  = 8'h3E;
parameter   ROR_ACC = 8'h6A;
parameter   ROR_ZP  = 8'h66;
parameter   ROR_ZX  = 8'h76;
parameter   ROR_ABS = 8'h6E;
parameter   ROR_AX  = 8'h7E;
parameter   RTI     = 8'h40;
parameter   RTS     = 8'h60;
parameter   SBC_IMM = 8'hE9;
parameter   SBC_ZP  = 8'hE5;
parameter   SBC_ZX  = 8'hF5;
parameter   SBC_ABS = 8'hED;
parameter   SBC_AX  = 8'hFD;
parameter   SBC_AY  = 8'hF9;
parameter   SBC_IX  = 8'hE1;
parameter   SBC_IY  = 8'hF1;
parameter   SEC     = 8'h38;
parameter   SED     = 8'hF8;
parameter   SEI     = 8'h78;
parameter   STA_ZP  = 8'h85;
parameter   STA_ZX  = 8'h95;
parameter   STA_ABS = 8'h8D;
parameter   STA_AX  = 8'h9D;
parameter   STA_AY  = 8'h99;
parameter   STA_IX  = 8'h81;
parameter   STA_IY  = 8'h91;
parameter   STX_ZP  = 8'h86;
parameter   STX_ZY  = 8'h96;
parameter   STX_ABS = 8'h8E;
parameter   STY_ZP  = 8'h84;
parameter   STY_ZX  = 8'h94;
parameter   STY_ABS = 8'h8C;
parameter   TAX     = 8'hAA;
parameter   TAY     = 8'hA8;
parameter   TSX     = 8'hBA;
parameter   TXA     = 8'h8A;
parameter   TXS     = 8'h9A;
parameter   TYA     = 8'h98;
always @* begin
    opc_inst = {NUM_OF_INST{1'b0}};
    case (opcode)
    ADC_IMM :   opc_inst[I_ADC] = 1'b1;
    ADC_ZP  :   opc_inst[I_ADC] = 1'b1;
    ADC_ZX  :   opc_inst[I_ADC] = 1'b1;
    ADC_ABS :   opc_inst[I_ADC] = 1'b1;
    ADC_AX  :   opc_inst[I_ADC] = 1'b1;
    ADC_AY  :   opc_inst[I_ADC] = 1'b1;
    ADC_IX  :   opc_inst[I_ADC] = 1'b1;
    ADC_IY  :   opc_inst[I_ADC] = 1'b1;
    AND_IMM :   opc_inst[I_AND] = 1'b1;
    AND_ZP  :   opc_inst[I_AND] = 1'b1;
    AND_ZX  :   opc_inst[I_AND] = 1'b1;
    AND_ABS :   opc_inst[I_AND] = 1'b1;
    AND_AX  :   opc_inst[I_AND] = 1'b1;
    AND_AY  :   opc_inst[I_AND] = 1'b1;
    AND_IX  :   opc_inst[I_AND] = 1'b1;
    AND_IY  :   opc_inst[I_AND] = 1'b1;
    ASL_ACC :   opc_inst[I_ASL] = 1'b1;
    ASL_ZP  :   opc_inst[I_ASL] = 1'b1;
    ASL_ZX  :   opc_inst[I_ASL] = 1'b1;
    ASL_ABS :   opc_inst[I_ASL] = 1'b1;
    ASL_AX  :   opc_inst[I_ASL] = 1'b1;
    BCC     :   opc_inst[I_BCC] = 1'b1;
    BCS     :   opc_inst[I_BCS] = 1'b1;
    BEQ     :   opc_inst[I_BEQ] = 1'b1;
    BIT_ZP  :   opc_inst[I_BIT] = 1'b1;
    BIT_ABS :   opc_inst[I_BIT] = 1'b1;
    BMI     :   opc_inst[I_BMI] = 1'b1;
    BNE     :   opc_inst[I_BNE] = 1'b1;
    BPL     :   opc_inst[I_BPL] = 1'b1;
    BRK     :   opc_inst[I_BRK] = 1'b1;
    BVC     :   opc_inst[I_BVC] = 1'b1;
    BVS     :   opc_inst[I_BVS] = 1'b1;
    CLC     :   opc_inst[I_CLC] = 1'b1;
    CLD     :   opc_inst[I_CLD] = 1'b1;
    CLI     :   opc_inst[I_CLI] = 1'b1;
    CLV     :   opc_inst[I_CLV] = 1'b1;
    CMP_IMM :   opc_inst[I_CMP] = 1'b1;
    CMP_ZP  :   opc_inst[I_CMP] = 1'b1;
    CMP_ZX  :   opc_inst[I_CMP] = 1'b1;
    CMP_ABS :   opc_inst[I_CMP] = 1'b1;
    CMP_AX  :   opc_inst[I_CMP] = 1'b1;
    CMP_AY  :   opc_inst[I_CMP] = 1'b1;
    CMP_IX  :   opc_inst[I_CMP] = 1'b1;
    CMP_IY  :   opc_inst[I_CMP] = 1'b1;
    CPX_IMM :   opc_inst[I_CPX] = 1'b1;
    CPX_ZP  :   opc_inst[I_CPX] = 1'b1;
    CPX_ABS :   opc_inst[I_CPX] = 1'b1;
    CPY_IMM :   opc_inst[I_CPY] = 1'b1;
    CPY_ZP  :   opc_inst[I_CPY] = 1'b1;
    CPY_ABS :   opc_inst[I_CPY] = 1'b1;
    DEC_ZP  :   opc_inst[I_DEC] = 1'b1;
    DEC_ZX  :   opc_inst[I_DEC] = 1'b1;
    DEC_ABS :   opc_inst[I_DEC] = 1'b1;
    DEC_AX  :   opc_inst[I_DEC] = 1'b1;
    DEX     :   opc_inst[I_DEX] = 1'b1;
    DEY     :   opc_inst[I_DEY] = 1'b1;
    EOR_IMM :   opc_inst[I_EOR] = 1'b1;
    EOR_ZP  :   opc_inst[I_EOR] = 1'b1;
    EOR_ZX  :   opc_inst[I_EOR] = 1'b1;
    EOR_ABS :   opc_inst[I_EOR] = 1'b1;
    EOR_AX  :   opc_inst[I_EOR] = 1'b1;
    EOR_AY  :   opc_inst[I_EOR] = 1'b1;
    EOR_IX  :   opc_inst[I_EOR] = 1'b1;
    EOR_IY  :   opc_inst[I_EOR] = 1'b1;
    INC_ZP  :   opc_inst[I_INC] = 1'b1;
    INC_ZX  :   opc_inst[I_INC] = 1'b1;
    INC_ABS :   opc_inst[I_INC] = 1'b1;
    INC_AX  :   opc_inst[I_INC] = 1'b1;
    INX     :   opc_inst[I_INX] = 1'b1;
    INY     :   opc_inst[I_INY] = 1'b1;
    JMP_ABS :   opc_inst[I_JMP] = 1'b1;
    JMP_IND :   opc_inst[I_JMP] = 1'b1;
    JSR_ABS :   opc_inst[I_JSR] = 1'b1;
    LDA_IMM :   opc_inst[I_LDA] = 1'b1;
    LDA_ZP  :   opc_inst[I_LDA] = 1'b1;
    LDA_ZX  :   opc_inst[I_LDA] = 1'b1;
    LDA_ABS :   opc_inst[I_LDA] = 1'b1;
    LDA_AX  :   opc_inst[I_LDA] = 1'b1;
    LDA_AY  :   opc_inst[I_LDA] = 1'b1;
    LDA_IX  :   opc_inst[I_LDA] = 1'b1;
    LDA_IY  :   opc_inst[I_LDA] = 1'b1;
    LDX_IMM :   opc_inst[I_LDX] = 1'b1;
    LDX_ZP  :   opc_inst[I_LDX] = 1'b1;
    LDX_ZY  :   opc_inst[I_LDX] = 1'b1;
    LDX_ABS :   opc_inst[I_LDX] = 1'b1;
    LDX_AY  :   opc_inst[I_LDX] = 1'b1;
    LDY_IMM :   opc_inst[I_LDY] = 1'b1;
    LDY_ZP  :   opc_inst[I_LDY] = 1'b1;
    LDY_ZX  :   opc_inst[I_LDY] = 1'b1;
    LDY_ABS :   opc_inst[I_LDY] = 1'b1;
    LDY_AX  :   opc_inst[I_LDY] = 1'b1;
    LSR_ACC :   opc_inst[I_LSR] = 1'b1;
    LSR_ZP  :   opc_inst[I_LSR] = 1'b1;
    LSR_ZX  :   opc_inst[I_LSR] = 1'b1;
    LSR_ABS :   opc_inst[I_LSR] = 1'b1;
    LSR_AX  :   opc_inst[I_LSR] = 1'b1;
    NOP     :   opc_inst[I_NOP] = 1'b1;
    ORA_IMM :   opc_inst[I_ORA] = 1'b1;
    ORA_ZP  :   opc_inst[I_ORA] = 1'b1;
    ORA_ZX  :   opc_inst[I_ORA] = 1'b1;
    ORA_ABS :   opc_inst[I_ORA] = 1'b1;
    ORA_AX  :   opc_inst[I_ORA] = 1'b1;
    ORA_AY  :   opc_inst[I_ORA] = 1'b1;
    ORA_IX  :   opc_inst[I_ORA] = 1'b1;
    ORA_IY  :   opc_inst[I_ORA] = 1'b1;
    PHA     :   opc_inst[I_PHA] = 1'b1;
    PHP     :   opc_inst[I_PHP] = 1'b1;
    PLA     :   opc_inst[I_PLA] = 1'b1;
    PLP     :   opc_inst[I_PLP] = 1'b1;
    ROL_ACC :   opc_inst[I_ROL] = 1'b1;
    ROL_ZP  :   opc_inst[I_ROL] = 1'b1;
    ROL_ZX  :   opc_inst[I_ROL] = 1'b1;
    ROL_ABS :   opc_inst[I_ROL] = 1'b1;
    ROL_AX  :   opc_inst[I_ROL] = 1'b1;
    ROR_ACC :   opc_inst[I_ROR] = 1'b1;
    ROR_ZP  :   opc_inst[I_ROR] = 1'b1;
    ROR_ZX  :   opc_inst[I_ROR] = 1'b1;
    ROR_ABS :   opc_inst[I_ROR] = 1'b1;
    ROR_AX  :   opc_inst[I_ROR] = 1'b1;
    RTI     :   opc_inst[I_RTI] = 1'b1;
    RTS     :   opc_inst[I_RTS] = 1'b1;
    SBC_IMM :   opc_inst[I_SBC] = 1'b1;
    SBC_ZP  :   opc_inst[I_SBC] = 1'b1;
    SBC_ZX  :   opc_inst[I_SBC] = 1'b1;
    SBC_ABS :   opc_inst[I_SBC] = 1'b1;
    SBC_AX  :   opc_inst[I_SBC] = 1'b1;
    SBC_AY  :   opc_inst[I_SBC] = 1'b1;
    SBC_IX  :   opc_inst[I_SBC] = 1'b1;
    SBC_IY  :   opc_inst[I_SBC] = 1'b1;
    SEC     :   opc_inst[I_SEC] = 1'b1;
    SED     :   opc_inst[I_SED] = 1'b1;
    SEI     :   opc_inst[I_SEI] = 1'b1;
    STA_ZP  :   opc_inst[I_STA] = 1'b1;
    STA_ZX  :   opc_inst[I_STA] = 1'b1;
    STA_ABS :   opc_inst[I_STA] = 1'b1;
    STA_AX  :   opc_inst[I_STA] = 1'b1;
    STA_AY  :   opc_inst[I_STA] = 1'b1;
    STA_IX  :   opc_inst[I_STA] = 1'b1;
    STA_IY  :   opc_inst[I_STA] = 1'b1;
    STX_ZP  :   opc_inst[I_STX] = 1'b1;
    STX_ZY  :   opc_inst[I_STX] = 1'b1;
    STX_ABS :   opc_inst[I_STX] = 1'b1;
    STY_ZP  :   opc_inst[I_STY] = 1'b1;
    STY_ZX  :   opc_inst[I_STY] = 1'b1;
    STY_ABS :   opc_inst[I_STY] = 1'b1;
    TAX     :   opc_inst[I_TAX] = 1'b1;
    TAY     :   opc_inst[I_TAY] = 1'b1;
    TSX     :   opc_inst[I_TSX] = 1'b1;
    TXA     :   opc_inst[I_TXA] = 1'b1;
    TXS     :   opc_inst[I_TXS] = 1'b1;
    TYA     :   opc_inst[I_TYA] = 1'b1;
    endcase
end
assign  opc_src_a_ar    = src_dst[12];  
assign  opc_src_a_xr    = src_dst[11];  
assign  opc_src_a_yr    = src_dst[10];  
assign  opc_src_a_sp    = src_dst[ 9];  
assign  opc_src_a_ps    = src_dst[ 8];  
assign  opc_src_a_din   = src_dst[ 7];  
assign  opc_src_b_din   = src_dst[ 6];  
assign  opc_dst_ar      = src_dst[ 5];  
assign  opc_dst_xr      = src_dst[ 4];  
assign  opc_dst_yr      = src_dst[ 3];  
assign  opc_dst_sp      = src_dst[ 2];  
assign  opc_dst_ps      = src_dst[ 1];  
assign  opc_dst_dout    = src_dst[ 0];  
always @* begin
    case (opcode)
    ADC_IMM : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    ADC_ZP  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    ADC_ZX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    ADC_ABS : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    ADC_AX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    ADC_AY  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    ADC_IX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    ADC_IY  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    AND_IMM : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    AND_ZP  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    AND_ZX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    AND_ABS : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    AND_AX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    AND_AY  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    AND_IX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    AND_IY  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    ASL_ACC : {src_dst, opc_flag} = {13'b 100000_0_100000, 8'b 1000_0011};
    ASL_ZP  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    ASL_ZX  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    ASL_ABS : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    ASL_AX  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    BCC     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    BCS     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    BEQ     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    BMI     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    BNE     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    BPL     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    BVC     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    BVS     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    BIT_ZP  : {src_dst, opc_flag} = {13'b 100000_1_000000, 8'b 1100_0010};
    BIT_ABS : {src_dst, opc_flag} = {13'b 100000_1_000000, 8'b 1100_0010};
    BRK     : {src_dst, opc_flag} = {13'b 000010_0_000001, 8'b 0001_0100};
    CLC     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0001};
    CLD     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_1000};
    CLI     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0100};
    CLV     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0100_0000};
    CMP_IMM : {src_dst, opc_flag} = {13'b 100000_1_000000, 8'b 1000_0011};
    CMP_ZP  : {src_dst, opc_flag} = {13'b 100000_1_000000, 8'b 1000_0011};
    CMP_ZX  : {src_dst, opc_flag} = {13'b 100000_1_000000, 8'b 1000_0011};
    CMP_ABS : {src_dst, opc_flag} = {13'b 100000_1_000000, 8'b 1000_0011};
    CMP_AX  : {src_dst, opc_flag} = {13'b 100000_1_000000, 8'b 1000_0011};
    CMP_AY  : {src_dst, opc_flag} = {13'b 100000_1_000000, 8'b 1000_0011};
    CMP_IX  : {src_dst, opc_flag} = {13'b 100000_1_000000, 8'b 1000_0011};
    CMP_IY  : {src_dst, opc_flag} = {13'b 100000_1_000000, 8'b 1000_0011};
    CPX_IMM : {src_dst, opc_flag} = {13'b 010000_1_000000, 8'b 1000_0011};
    CPX_ZP  : {src_dst, opc_flag} = {13'b 010000_1_000000, 8'b 1000_0011};
    CPX_ABS : {src_dst, opc_flag} = {13'b 010000_1_000000, 8'b 1000_0011};
    CPY_IMM : {src_dst, opc_flag} = {13'b 001000_1_000000, 8'b 1000_0011};
    CPY_ZP  : {src_dst, opc_flag} = {13'b 001000_1_000000, 8'b 1000_0011};
    CPY_ABS : {src_dst, opc_flag} = {13'b 001000_1_000000, 8'b 1000_0011};
    DEC_ZP  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0010};
    DEC_ZX  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0010};
    DEC_ABS : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0010};
    DEC_AX  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0010};
    DEX     : {src_dst, opc_flag} = {13'b 010000_0_010000, 8'b 1000_0010};
    DEY     : {src_dst, opc_flag} = {13'b 001000_0_001000, 8'b 1000_0010};
    EOR_IMM : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    EOR_ZP  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    EOR_ZX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    EOR_ABS : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    EOR_AX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    EOR_AY  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    EOR_IX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    EOR_IY  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    INC_ZP  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0010};
    INC_ZX  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0010};
    INC_ABS : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0010};
    INC_AX  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0010};
    INX     : {src_dst, opc_flag} = {13'b 010000_0_010000, 8'b 1000_0010};
    INY     : {src_dst, opc_flag} = {13'b 001000_0_001000, 8'b 1000_0010};
    JMP_ABS : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    JMP_IND : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    JSR_ABS : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    LDA_IMM : {src_dst, opc_flag} = {13'b 000000_1_100000, 8'b 1000_0010};
    LDA_ZP  : {src_dst, opc_flag} = {13'b 000000_1_100000, 8'b 1000_0010};
    LDA_ZX  : {src_dst, opc_flag} = {13'b 000000_1_100000, 8'b 1000_0010};
    LDA_ABS : {src_dst, opc_flag} = {13'b 000000_1_100000, 8'b 1000_0010};
    LDA_AX  : {src_dst, opc_flag} = {13'b 000000_1_100000, 8'b 1000_0010};
    LDA_AY  : {src_dst, opc_flag} = {13'b 000000_1_100000, 8'b 1000_0010};
    LDA_IX  : {src_dst, opc_flag} = {13'b 000000_1_100000, 8'b 1000_0010};
    LDA_IY  : {src_dst, opc_flag} = {13'b 000000_1_100000, 8'b 1000_0010};
    LDX_IMM : {src_dst, opc_flag} = {13'b 000000_1_010000, 8'b 1000_0010};
    LDX_ZP  : {src_dst, opc_flag} = {13'b 000000_1_010000, 8'b 1000_0010};
    LDX_ZY  : {src_dst, opc_flag} = {13'b 000000_1_010000, 8'b 1000_0010};
    LDX_ABS : {src_dst, opc_flag} = {13'b 000000_1_010000, 8'b 1000_0010};
    LDX_AY  : {src_dst, opc_flag} = {13'b 000000_1_010000, 8'b 1000_0010};
    LDY_IMM : {src_dst, opc_flag} = {13'b 000000_1_001000, 8'b 1000_0010};
    LDY_ZP  : {src_dst, opc_flag} = {13'b 000000_1_001000, 8'b 1000_0010};
    LDY_ZX  : {src_dst, opc_flag} = {13'b 000000_1_001000, 8'b 1000_0010};
    LDY_ABS : {src_dst, opc_flag} = {13'b 000000_1_001000, 8'b 1000_0010};
    LDY_AX  : {src_dst, opc_flag} = {13'b 000000_1_001000, 8'b 1000_0010};
    LSR_ACC : {src_dst, opc_flag} = {13'b 100000_0_100000, 8'b 1000_0011};
    LSR_ZP  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    LSR_ZX  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    LSR_ABS : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    LSR_AX  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    NOP     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    ORA_IMM : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    ORA_ZP  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    ORA_ZX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    ORA_ABS : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    ORA_AX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    ORA_AY  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    ORA_IX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    ORA_IY  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1000_0010};
    PHA     : {src_dst, opc_flag} = {13'b 100000_0_000001, 8'b 0000_0000};
    PHP     : {src_dst, opc_flag} = {13'b 000010_0_000001, 8'b 0000_0000};
    PLA     : {src_dst, opc_flag} = {13'b 000000_1_100000, 8'b 1000_0010};
    PLP     : {src_dst, opc_flag} = {13'b 000000_1_000010, 8'b 1111_1111};
    ROL_ACC : {src_dst, opc_flag} = {13'b 100000_0_100000, 8'b 1000_0011};
    ROL_ZP  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    ROL_ZX  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    ROL_ABS : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    ROL_AX  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    ROR_ACC : {src_dst, opc_flag} = {13'b 100000_0_100000, 8'b 1000_0011};
    ROR_ZP  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    ROR_ZX  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    ROR_ABS : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    ROR_AX  : {src_dst, opc_flag} = {13'b 000001_0_000001, 8'b 1000_0011};
    RTI     : {src_dst, opc_flag} = {13'b 000000_1_000010, 8'b 1111_1111};
    RTS     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    SBC_IMM : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    SBC_ZP  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    SBC_ZX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    SBC_ABS : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    SBC_AX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    SBC_AY  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    SBC_IX  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    SBC_IY  : {src_dst, opc_flag} = {13'b 100000_1_100000, 8'b 1100_0011};
    SEC     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0001};
    SED     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_1000};
    SEI     : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0100};
    STA_ZP  : {src_dst, opc_flag} = {13'b 100000_0_000001, 8'b 0000_0000};
    STA_ZX  : {src_dst, opc_flag} = {13'b 100000_0_000001, 8'b 0000_0000};
    STA_ABS : {src_dst, opc_flag} = {13'b 100000_0_000001, 8'b 0000_0000};
    STA_AX  : {src_dst, opc_flag} = {13'b 100000_0_000001, 8'b 0000_0000};
    STA_AY  : {src_dst, opc_flag} = {13'b 100000_0_000001, 8'b 0000_0000};
    STA_IX  : {src_dst, opc_flag} = {13'b 100000_0_000001, 8'b 0000_0000};
    STA_IY  : {src_dst, opc_flag} = {13'b 100000_0_000001, 8'b 0000_0000};
    STX_ZP  : {src_dst, opc_flag} = {13'b 010000_0_000001, 8'b 0000_0000};
    STX_ZY  : {src_dst, opc_flag} = {13'b 010000_0_000001, 8'b 0000_0000};
    STX_ABS : {src_dst, opc_flag} = {13'b 010000_0_000001, 8'b 0000_0000};
    STY_ZP  : {src_dst, opc_flag} = {13'b 001000_0_000001, 8'b 0000_0000};
    STY_ZX  : {src_dst, opc_flag} = {13'b 001000_0_000001, 8'b 0000_0000};
    STY_ABS : {src_dst, opc_flag} = {13'b 001000_0_000001, 8'b 0000_0000};
    TAX     : {src_dst, opc_flag} = {13'b 100000_0_010000, 8'b 1000_0010};
    TAY     : {src_dst, opc_flag} = {13'b 100000_0_001000, 8'b 1000_0010};
    TSX     : {src_dst, opc_flag} = {13'b 000100_0_010000, 8'b 1000_0010};
    TXA     : {src_dst, opc_flag} = {13'b 010000_0_100000, 8'b 1000_0010};
    TXS     : {src_dst, opc_flag} = {13'b 010000_0_000100, 8'b 0000_0000};
    TYA     : {src_dst, opc_flag} = {13'b 001000_0_100000, 8'b 1000_0010};
    default : {src_dst, opc_flag} = {13'b 000000_0_000000, 8'b 0000_0000};
    endcase
end
assign  mc_fetch_en     = mc_exec[15];  
assign  mc_din_le       = mc_exec[14];  
assign  mc_pc_chg       = mc_exec[13];  
assign  mc_addr_pc      = mc_exec[12];  
assign  mc_addr_zp      = mc_exec[11];  
assign  mc_addr_abs     = mc_exec[10];  
assign  mc_addr_sp      = mc_exec[ 9];  
assign  mc_oe_next      = mc_exec[ 8];  
assign  mc_alu_inst_op  = mc_exec[ 7];  
assign  mc_alu_add_xr   = mc_exec[ 6];  
assign  mc_alu_add_yr   = mc_exec[ 5];  
assign  mc_alu_add_z    = mc_exec[ 4];  
assign  mc_alu_inc_din  = mc_exec[ 3];  
assign  mc_alu_inc_reg  = mc_exec[ 2];  
assign  mc_alu_inc_sp   = mc_exec[ 1];  
assign  mc_alu_dec_sp   = mc_exec[ 0];  
always @* begin
    mc_exec = {16{1'b0}};
    case (opcode)
    ASL_ACC,
    LSR_ACC,
    ROL_ACC,
    ROR_ACC:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 000_0000_0_0000_0000;  
        3'd1: mc_exec = 16'b 101_1000_0_1000_0000;  
        endcase
    AND_IMM,
    ORA_IMM,
    EOR_IMM,
    ADC_IMM,
    SBC_IMM,
    CMP_IMM,
    CPX_IMM,
    CPY_IMM,
    LDA_IMM,
    LDX_IMM,
    LDY_IMM:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd1: mc_exec = 16'b 101_1000_0_1000_0000;  
        endcase
    AND_ZP,
    ORA_ZP,
    EOR_ZP,
    ADC_ZP,
    SBC_ZP,
    CMP_ZP,
    CPX_ZP,
    CPY_ZP,
    LDA_ZP,
    LDX_ZP,
    LDY_ZP,
    BIT_ZP:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0100_0_0000_0000;  
        3'd1: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd2: mc_exec = 16'b 101_1000_0_1000_0000;  
        endcase
    STA_ZP,
    STX_ZP,
    STY_ZP:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0100_1_1000_0000;  
        3'd1: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd2: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    ASL_ZP,
    LSR_ZP,
    ROL_ZP,
    ROR_ZP,
    INC_ZP,
    DEC_ZP:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0100_0_0000_0000;  
        3'd1: mc_exec = 16'b 010_0000_0_0000_0000;  
        3'd2: mc_exec = 16'b 000_0000_1_1000_0000;  
        3'd3: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd4: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    AND_ZX,
    ORA_ZX,
    EOR_ZX,
    ADC_ZX,
    SBC_ZX,
    CMP_ZX,
    LDA_ZX,
    LDY_ZX:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0000_0_0000_0000;  
        3'd1: mc_exec = 16'b 000_0100_0_0100_0000;  
        3'd2: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd3: mc_exec = 16'b 101_1000_0_1000_0000;  
        endcase
    STA_ZX,
    STY_ZX:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0000_0_1000_0000;  
        3'd1: mc_exec = 16'b 000_0100_1_0100_0000;  
        3'd2: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd3: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    ASL_ZX,
    LSR_ZX,
    ROL_ZX,
    ROR_ZX,
    INC_ZX,
    DEC_ZX:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0000_0_0000_0000;  
        3'd1: mc_exec = 16'b 000_0100_0_0100_0000;  
        3'd2: mc_exec = 16'b 010_0000_0_0000_0000;  
        3'd3: mc_exec = 16'b 000_0000_1_1000_0000;  
        3'd4: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd5: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    LDX_ZY:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0000_0_0000_0000;  
        3'd1: mc_exec = 16'b 000_0100_0_0010_0000;  
        3'd2: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd3: mc_exec = 16'b 101_1000_0_1000_0000;  
        endcase
    STX_ZY:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0000_0_1000_0000;  
        3'd1: mc_exec = 16'b 000_0100_1_0010_0000;  
        3'd2: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd3: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    AND_ABS,
    ORA_ABS,
    EOR_ABS,
    ADC_ABS,
    SBC_ABS,
    CMP_ABS,
    CPX_ABS,
    CPY_ABS,
    LDA_ABS,
    LDX_ABS,
    LDY_ABS,
    BIT_ABS:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd1: mc_exec = 16'b 010_0010_0_0001_0000;  
        3'd2: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd3: mc_exec = 16'b 101_1000_0_1000_0000;  
        endcase
    STA_ABS,
    STX_ABS,
    STY_ABS:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 011_1000_0_1000_0000;  
        3'd1: mc_exec = 16'b 010_0010_1_0001_0000;  
        3'd2: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd3: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    ASL_ABS,
    LSR_ABS,
    ROL_ABS,
    ROR_ABS,
    INC_ABS,
    DEC_ABS:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd1: mc_exec = 16'b 010_0010_0_0001_0000;  
        3'd2: mc_exec = 16'b 010_0000_0_0000_0000;  
        3'd3: mc_exec = 16'b 000_0000_1_1000_0000;  
        3'd4: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd5: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    JMP_ABS:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd1: mc_exec = 16'b 011_0010_0_0001_0000;  
        3'd2: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    JSR_ABS:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0000_0_0000_0000;  
        3'd1: mc_exec = 16'b 000_0001_1_0000_0001;  
        3'd2: mc_exec = 16'b 000_0001_1_0000_0001;  
        3'd3: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd4: mc_exec = 16'b 011_0010_0_0001_0000;  
        3'd5: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    AND_AX,
    ORA_AX,
    EOR_AX,
    ADC_AX,
    SBC_AX,
    CMP_AX,
    LDA_AX,
    LDY_AX:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd1: mc_exec = 16'b 010_0010_0_0100_0000;  
        3'd2: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd3: mc_exec = 16'b 101_1000_0_1000_0000;  
        endcase
    STA_AX:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 011_1000_0_1000_0000;  
        3'd1: mc_exec = 16'b 010_0010_1_0100_0000;  
        3'd2: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd3: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    ASL_AX,
    LSR_AX,
    ROL_AX,
    ROR_AX,
    INC_AX,
    DEC_AX:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd1: mc_exec = 16'b 010_0010_0_0100_0000;  
        3'd2: mc_exec = 16'b 010_0000_0_0000_0000;  
        3'd3: mc_exec = 16'b 000_0000_1_1000_0000;  
        3'd4: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd5: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    AND_AY,
    ORA_AY,
    EOR_AY,
    ADC_AY,
    SBC_AY,
    CMP_AY,
    LDA_AY,
    LDX_AY:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd1: mc_exec = 16'b 010_0010_0_0010_0000;  
        3'd2: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd3: mc_exec = 16'b 101_1000_0_1000_0000;  
        endcase
    STA_AY:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 011_1000_0_1000_0000;  
        3'd1: mc_exec = 16'b 010_0010_1_0010_0000;  
        3'd2: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd3: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    AND_IX,
    ORA_IX,
    EOR_IX,
    ADC_IX,
    SBC_IX,
    CMP_IX,
    LDA_IX:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0000_0_0000_0000;  
        3'd1: mc_exec = 16'b 000_0100_0_0100_0000;  
        3'd2: mc_exec = 16'b 010_0100_0_0000_0100;  
        3'd3: mc_exec = 16'b 010_0010_0_0001_0000;  
        3'd4: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd5: mc_exec = 16'b 101_1000_0_1000_0000;  
        endcase
    STA_IX:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0000_0_1000_0000;  
        3'd1: mc_exec = 16'b 000_0100_0_0100_0000;  
        3'd2: mc_exec = 16'b 010_0100_0_0000_0100;  
        3'd3: mc_exec = 16'b 010_0010_1_0001_0000;  
        3'd4: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd5: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    AND_IY,
    ORA_IY,
    EOR_IY,
    ADC_IY,
    SBC_IY,
    CMP_IY,
    LDA_IY:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0100_0_0000_0000;  
        3'd1: mc_exec = 16'b 010_0100_0_0000_1000;  
        3'd2: mc_exec = 16'b 010_0010_0_0010_0000;  
        3'd3: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd4: mc_exec = 16'b 101_1000_0_1000_0000;  
        endcase
    STA_IY:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 010_0100_0_1000_0000;  
        3'd1: mc_exec = 16'b 010_0100_0_0000_1000;  
        3'd2: mc_exec = 16'b 010_0010_1_0010_0000;  
        3'd3: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd4: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    JMP_IND:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd1: mc_exec = 16'b 010_0010_0_0001_0000;  
        3'd2: mc_exec = 16'b 010_0010_0_0000_0100;  
        3'd3: mc_exec = 16'b 011_0010_0_0001_0000;  
        3'd4: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    TAX,
    TXA,
    TAY,
    TYA,
    TSX,
    TXS,
    INX,
    INY,
    DEX,
    DEY,
    CLC,
    CLD,
    CLI,
    CLV,
    SEC,
    SED,
    SEI,
    NOP:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 000_0000_0_0000_0000;  
        3'd1: mc_exec = 16'b 101_1000_0_1000_0000;  
        endcase
    PHA,
    PHP:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 000_0001_1_1000_0000;  
        3'd1: mc_exec = 16'b 000_1000_0_0000_0001;  
        3'd2: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    PLA,
    PLP:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 000_0000_0_0000_0010;  
        3'd1: mc_exec = 16'b 000_0001_0_0000_0000;  
        3'd2: mc_exec = 16'b 010_1000_0_0000_0000;  
        3'd3: mc_exec = 16'b 101_1000_0_1001_0000;  
        endcase
    RTI:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 000_0000_0_0000_0010;  
        3'd1: mc_exec = 16'b 000_0001_0_0000_0010;  
        3'd2: mc_exec = 16'b 010_0001_0_0000_0010;  
        3'd3: mc_exec = 16'b 010_0001_0_1001_0000;  
        3'd4: mc_exec = 16'b 011_0010_0_0001_0000;  
        3'd5: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    RTS:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 000_0000_0_0000_0010;  
        3'd1: mc_exec = 16'b 000_0001_0_0000_0010;  
        3'd2: mc_exec = 16'b 010_0001_0_0000_0000;  
        3'd3: mc_exec = 16'b 011_0010_0_0001_0000;  
        3'd4: mc_exec = 16'b 001_1000_0_0000_0000;  
        3'd5: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    BRK:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 000_0001_1_0000_0001;  
        3'd1: mc_exec = 16'b 000_0001_1_0000_0001;  
        3'd2: mc_exec = 16'b 000_0001_1_1000_0000;  
        3'd3: mc_exec = 16'b 000_0000_0_0000_0001;  
        3'd4: mc_exec = 16'b 010_0000_0_0000_0000;  
        3'd5: mc_exec = 16'b 011_0010_0_0001_0000;  
        3'd6: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    BEQ,
    BNE,
    BCS,
    BCC,
    BVS,
    BVC,
    BMI,
    BPL:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 011_1000_0_0000_0000;  
        3'd1: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    default:
        case (cyc_cnt)
        3'd0: mc_exec = 16'b 000_0000_0_0000_0000;  
        3'd1: mc_exec = 16'b 101_1000_0_0000_0000;  
        endcase
    endcase
end
assign  mc_addr_vl      = (opcode == BRK    ) & (cyc_cnt == 3'd3);
assign  mc_addr_vh      = (opcode == BRK    ) & (cyc_cnt == 3'd4);
assign  mc_dout_pch     = (opcode == BRK    ) & (cyc_cnt == 3'd0)
                        | (opcode == JSR_ABS) & (cyc_cnt == 3'd1);
assign  mc_dout_pcl     = (opcode == BRK    ) & (cyc_cnt == 3'd1)
                        | (opcode == JSR_ABS) & (cyc_cnt == 3'd2);
assign  mc_brk_if_set   = (opcode == BRK    ) & (cyc_cnt == 3'd2);
assign  mc_br_chk       = (opcode == BEQ) & (cyc_cnt == 3'd1)
                        | (opcode == BNE) & (cyc_cnt == 3'd1)
                        | (opcode == BCS) & (cyc_cnt == 3'd1)
                        | (opcode == BCC) & (cyc_cnt == 3'd1)
                        | (opcode == BVS) & (cyc_cnt == 3'd1)
                        | (opcode == BVC) & (cyc_cnt == 3'd1)
                        | (opcode == BMI) & (cyc_cnt == 3'd1)
                        | (opcode == BPL) & (cyc_cnt == 3'd1);
endmodule
