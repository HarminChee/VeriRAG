`define OR1200_DCFGR_NDP		3'h0	
`define OR1200_DCFGR_WPCI		1'b0	
`define OR1200_DCFGR_RES1		28'h0000000
`define OR1200_M2R_BYTE0 4'b0000
`define OR1200_M2R_BYTE1 4'b0001
`define OR1200_M2R_BYTE2 4'b0010
`define OR1200_M2R_BYTE3 4'b0011
`define OR1200_M2R_EXTB0 4'b0100
`define OR1200_M2R_EXTB1 4'b0101
`define OR1200_M2R_EXTB2 4'b0110
`define OR1200_M2R_EXTB3 4'b0111
`define OR1200_M2R_ZERO  4'b0000
`define OR1200_ICCFGR_NCW		3'h0	
`define OR1200_ICCFGR_NCS 9	
`define OR1200_ICCFGR_CBS 9	
`define OR1200_ICCFGR_CWS		1'b0	
`define OR1200_ICCFGR_CCRI		1'b1	
`define OR1200_ICCFGR_CBIRI		1'b1	
`define OR1200_ICCFGR_CBPRI		1'b0	
`define OR1200_ICCFGR_CBLRI		1'b0	
`define OR1200_ICCFGR_CBFRI		1'b1	
`define OR1200_ICCFGR_CBWBRI		1'b0	
`define OR1200_ICCFGR_RES1		17'h00000
`define OR1200_ICCFGR_CBS_BITS		7
`define OR1200_ICCFGR_CWS_BITS		8
`define OR1200_ICCFGR_CCRI_BITS		9
`define OR1200_ICCFGR_CBIRI_BITS	10
`define OR1200_ICCFGR_CBPRI_BITS	11
`define OR1200_ICCFGR_CBLRI_BITS	12
`define OR1200_ICCFGR_CBFRI_BITS	13
`define OR1200_ICCFGR_CBWBRI_BITS	14
`define OR1200_DCCFGR_NCW		3'h0	
`define OR1200_DCCFGR_NCS 9	
`define OR1200_DCCFGR_CBS 9	
`define OR1200_DCCFGR_CWS		1'b0	
`define OR1200_DCCFGR_CCRI		1'b1	
`define OR1200_DCCFGR_CBIRI		1'b1	
`define OR1200_DCCFGR_CBPRI		1'b0	
`define OR1200_DCCFGR_CBLRI		1'b0	
`define OR1200_DCCFGR_CBFRI		1'b1	
`define OR1200_DCCFGR_CBWBRI		1'b0	
`define OR1200_DCCFGR_RES1		17'h00000
`define OR1200_DCCFGR_CBS_BITS		7
`define OR1200_DCCFGR_CWS_BITS		8
`define OR1200_DCCFGR_CCRI_BITS		9
`define OR1200_DCCFGR_CBIRI_BITS	10
`define OR1200_DCCFGR_CBPRI_BITS	11
`define OR1200_DCCFGR_CBLRI_BITS	12
`define OR1200_DCCFGR_CBFRI_BITS	13
`define OR1200_DCCFGR_CBWBRI_BITS	14
`define OR1200_IMMUCFGR_NTW		2'h0	
`define OR1200_IMMUCFGR_NTS 3'b101	
`define OR1200_IMMUCFGR_NAE		3'h0	
`define OR1200_IMMUCFGR_CRI		1'b0	
`define OR1200_IMMUCFGR_PRI		1'b0	
`define OR1200_IMMUCFGR_TEIRI		1'b1	
`define OR1200_IMMUCFGR_HTR		1'b0	
`define OR1200_IMMUCFGR_RES1		20'h00000
`define OR1200_CPUCFGR_HGF_BITS	4
`define OR1200_CPUCFGR_OB32S_BITS	5
`define OR1200_CPUCFGR_OB64S_BITS	6
`define OR1200_CPUCFGR_OF32S_BITS	7
`define OR1200_CPUCFGR_OF64S_BITS	8
`define OR1200_CPUCFGR_OV64S_BITS	9
`define OR1200_CPUCFGR_NSGF		4'h0
`define OR1200_CPUCFGR_HGF		1'b0
`define OR1200_CPUCFGR_OB32S		1'b1
`define OR1200_CPUCFGR_OB64S		1'b0
`define OR1200_CPUCFGR_OF32S		1'b0
`define OR1200_CPUCFGR_OF64S		1'b0
`define OR1200_CPUCFGR_OV64S		1'b0
`define OR1200_CPUCFGR_RES1		22'h000000
`define OR1200_DMMUCFGR_CRI_BITS	8
`define OR1200_DMMUCFGR_PRI_BITS	9
`define OR1200_DMMUCFGR_TEIRI_BITS	10
`define OR1200_DMMUCFGR_HTR_BITS	11
`define OR1200_DMMUCFGR_NTW		2'h0	
`define OR1200_DMMUCFGR_NTS 3'b110	
`define OR1200_DMMUCFGR_NAE		3'h0	
`define OR1200_DMMUCFGR_CRI		1'b0	
`define OR1200_DMMUCFGR_PRI		1'b0	
`define OR1200_DMMUCFGR_TEIRI		1'b1	
`define OR1200_DMMUCFGR_HTR		1'b0	
`define OR1200_DMMUCFGR_RES1		20'h00000
`define OR1200_IMMUCFGR_CRI_BITS	8
`define OR1200_IMMUCFGR_PRI_BITS	9
`define OR1200_IMMUCFGR_TEIRI_BITS	10
`define OR1200_IMMUCFGR_HTR_BITS	11
`define OR1200_SPRGRP_SYS_VR		4'h0
`define OR1200_SPRGRP_SYS_UPR		4'h1
`define OR1200_SPRGRP_SYS_CPUCFGR	4'h2
`define OR1200_SPRGRP_SYS_DMMUCFGR	4'h3
`define OR1200_SPRGRP_SYS_IMMUCFGR	4'h4
`define OR1200_SPRGRP_SYS_DCCFGR	4'h5
`define OR1200_SPRGRP_SYS_ICCFGR	4'h6
`define OR1200_SPRGRP_SYS_DCFGR	4'h7
`define OR1200_VR_REV			6'h01
`define OR1200_VR_RES1			10'h000
`define OR1200_VR_CFG			8'h00
`define OR1200_VR_VER			8'h12
`define OR1200_UPR_UP_BITS		0
`define OR1200_UPR_DCP_BITS		1
`define OR1200_UPR_ICP_BITS		2
`define OR1200_UPR_DMP_BITS		3
`define OR1200_UPR_IMP_BITS		4
`define OR1200_UPR_MP_BITS		5
`define OR1200_UPR_DUP_BITS		6
`define OR1200_UPR_PCUP_BITS		7
`define OR1200_UPR_PMP_BITS		8
`define OR1200_UPR_PICP_BITS		9
`define OR1200_UPR_TTP_BITS		10
`define OR1200_UPR_RES1			13'h0000
`define OR1200_UPR_CUP			8'h00
`define OR1200_DU_DSR_WIDTH 14
`define OR1200_EXCEPT_UNUSED		3'hf
`define OR1200_EXCEPT_TRAP		3'he
`define OR1200_EXCEPT_BREAK		3'hd
`define OR1200_EXCEPT_SYSCALL		3'hc
`define OR1200_EXCEPT_RANGE		3'hb
`define OR1200_EXCEPT_ITLBMISS		3'ha
`define OR1200_EXCEPT_DTLBMISS		3'h9
`define OR1200_EXCEPT_INT		3'h8
`define OR1200_EXCEPT_ILLEGAL		3'h7
`define OR1200_EXCEPT_ALIGN		3'h6
`define OR1200_EXCEPT_TICK		3'h5
`define OR1200_EXCEPT_IPF		3'h4
`define OR1200_EXCEPT_DPF		3'h3
`define OR1200_EXCEPT_BUSERR		3'h2
`define OR1200_EXCEPT_RESET		3'h1
`define OR1200_EXCEPT_NONE		3'h0
`define OR1200_OPERAND_WIDTH		32
`define OR1200_REGFILE_ADDR_WIDTH	5
`define OR1200_ALUOP_WIDTH	4
`define OR1200_ALUOP_NOP	4'b000
`define OR1200_ALUOP_ADD	4'b0000
`define OR1200_ALUOP_ADDC	4'b0001
`define OR1200_ALUOP_SUB	4'b0010
`define OR1200_ALUOP_AND	4'b0011
`define OR1200_ALUOP_OR		4'b0100
`define OR1200_ALUOP_XOR	4'b0101
`define OR1200_ALUOP_MUL	4'b0110
`define OR1200_ALUOP_CUST5	4'b0111
`define OR1200_ALUOP_SHROT	4'b1000
`define OR1200_ALUOP_DIV	4'b1001
`define OR1200_ALUOP_DIVU	4'b1010
`define OR1200_ALUOP_IMM	4'b1011
`define OR1200_ALUOP_MOVHI	4'b1100
`define OR1200_ALUOP_COMP	4'b1101
`define OR1200_ALUOP_MTSR	4'b1110
`define OR1200_ALUOP_MFSR	4'b1111
`define OR1200_ALUOP_CMOV 4'b1110
`define OR1200_ALUOP_FF1  4'b1111
`define OR1200_MACOP_WIDTH	2
`define OR1200_MACOP_NOP	2'b00
`define OR1200_MACOP_MAC	2'b01
`define OR1200_MACOP_MSB	2'b10
`define OR1200_SHROTOP_WIDTH	2
`define OR1200_SHROTOP_NOP	2'b00
`define OR1200_SHROTOP_SLL	2'b00
`define OR1200_SHROTOP_SRL	2'b01
`define OR1200_SHROTOP_SRA	2'b10
`define OR1200_SHROTOP_ROR	2'b11
`define OR1200_MULTICYCLE_WIDTH	2
`define OR1200_ONE_CYCLE		2'b00
`define OR1200_TWO_CYCLES		2'b01
`define OR1200_SEL_WIDTH		2
`define OR1200_SEL_RF			2'b00
`define OR1200_SEL_IMM			2'b01
`define OR1200_SEL_EX_FORW		2'b10
`define OR1200_SEL_WB_FORW		2'b11
`define OR1200_BRANCHOP_WIDTH		3
`define OR1200_BRANCHOP_NOP		3'b000
`define OR1200_BRANCHOP_J		3'b001
`define OR1200_BRANCHOP_JR		3'b010
`define OR1200_BRANCHOP_BAL		3'b011
`define OR1200_BRANCHOP_BF		3'b100
`define OR1200_BRANCHOP_BNF		3'b101
`define OR1200_BRANCHOP_RFE		3'b110
`define OR1200_LSUOP_WIDTH		4
`define OR1200_LSUOP_NOP		4'b0000
`define OR1200_LSUOP_LBZ		4'b0010
`define OR1200_LSUOP_LBS		4'b0011
`define OR1200_LSUOP_LHZ		4'b0100
`define OR1200_LSUOP_LHS		4'b0101
`define OR1200_LSUOP_LWZ		4'b0110
`define OR1200_LSUOP_LWS		4'b0111
`define OR1200_LSUOP_LD		4'b0001
`define OR1200_LSUOP_SD		4'b1000
`define OR1200_LSUOP_SB		4'b1010
`define OR1200_LSUOP_SH		4'b1100
`define OR1200_LSUOP_SW		4'b1110
`define OR1200_FETCHOP_WIDTH		1
`define OR1200_FETCHOP_NOP		1'b0
`define OR1200_FETCHOP_LW		1'b1
`define OR1200_RFWBOP_WIDTH		3
`define OR1200_RFWBOP_NOP		3'b000
`define OR1200_RFWBOP_ALU		3'b001
`define OR1200_RFWBOP_LSU		3'b011
`define OR1200_RFWBOP_SPRS		3'b101
`define OR1200_RFWBOP_LR		3'b111
`define OR1200_COP_SFEQ       3'b000
`define OR1200_COP_SFNE       3'b001
`define OR1200_COP_SFGT       3'b010
`define OR1200_COP_SFGE       3'b011
`define OR1200_COP_SFLT       3'b100
`define OR1200_COP_SFLE       3'b101
`define OR1200_COP_X          3'b111
`define OR1200_SIGNED_COMPARE 3'b011
`define OR1200_COMPOP_WIDTH	4
`define OR1200_ITAG_IDLE	4'h0	
`define	OR1200_ITAG_NI		4'h1	
`define OR1200_ITAG_BE		4'hb	
`define OR1200_ITAG_PE		4'hc	
`define OR1200_ITAG_TE		4'hd	
`define OR1200_DTAG_IDLE	4'h0	
`define	OR1200_DTAG_ND		4'h1	
`define OR1200_DTAG_AE		4'ha	
`define OR1200_DTAG_BE		4'hb	
`define OR1200_DTAG_PE		4'hc	
`define OR1200_DTAG_TE		4'hd	
`define OR1200_DU_DSR_RSTE	0
`define OR1200_DU_DSR_BUSEE	1
`define OR1200_DU_DSR_DPFE	2
`define OR1200_DU_DSR_IPFE	3
`define OR1200_DU_DSR_TTE	4
`define OR1200_DU_DSR_AE	5
`define OR1200_DU_DSR_IIE	6
`define OR1200_DU_DSR_IE	7
`define OR1200_DU_DSR_DME	8
`define OR1200_DU_DSR_IME	9
`define OR1200_DU_DSR_RE	10
`define OR1200_DU_DSR_SCE	11
`define OR1200_DU_DSR_BE	12
`define OR1200_DU_DSR_TE	13
`define OR1200_OR32_J                 6'b000000
`define OR1200_OR32_JAL               6'b000001
`define OR1200_OR32_BNF               6'b000011
`define OR1200_OR32_BF                6'b000100
`define OR1200_OR32_NOP               6'b000101
`define OR1200_OR32_MOVHI             6'b000110
`define OR1200_OR32_XSYNC             6'b001000
`define OR1200_OR32_RFE               6'b001001
`define OR1200_OR32_JR                6'b010001
`define OR1200_OR32_JALR              6'b010010
`define OR1200_OR32_MACI              6'b010011
`define OR1200_OR32_LWZ               6'b100001
`define OR1200_OR32_LBZ               6'b100011
`define OR1200_OR32_LBS               6'b100100
`define OR1200_OR32_LHZ               6'b100101
`define OR1200_OR32_LHS               6'b100110
`define OR1200_OR32_ADDI              6'b100111
`define OR1200_OR32_ADDIC             6'b101000
`define OR1200_OR32_ANDI              6'b101001
`define OR1200_OR32_ORI               6'b101010
`define OR1200_OR32_XORI              6'b101011
`define OR1200_OR32_MULI              6'b101100
`define OR1200_OR32_MFSPR             6'b101101
`define OR1200_OR32_SH_ROTI 	      6'b101110
`define OR1200_OR32_SFXXI             6'b101111
`define OR1200_OR32_MTSPR             6'b110000
`define OR1200_OR32_MACMSB            6'b110001
`define OR1200_OR32_SW                6'b110101
`define OR1200_OR32_SB                6'b110110
`define OR1200_OR32_SH                6'b110111
`define OR1200_OR32_ALU               6'b111000
`define OR1200_OR32_SFXX              6'b111001
`define OR1200_OR32_CUST5             6'b111100
`define OR1200_EXCEPT_EPH0_P 20'h00000
`define OR1200_EXCEPT_EPH1_P 20'hF0000
`define OR1200_EXCEPT_V		   8'h00
`define OR1200_EXCEPT_WIDTH 4
`define OR1200_SPR_GROUP_SYS	5'b00000
`define OR1200_SPR_GROUP_DMMU	5'b00001
`define OR1200_SPR_GROUP_IMMU	5'b00010
`define OR1200_SPR_GROUP_DC	5'b00011
`define OR1200_SPR_GROUP_IC	5'b00100
`define OR1200_SPR_GROUP_MAC	5'b00101
`define OR1200_SPR_GROUP_DU	5'b00110
`define OR1200_SPR_GROUP_PM	5'b01000
`define OR1200_SPR_GROUP_PIC	5'b01001
`define OR1200_SPR_GROUP_TT	5'b01010
`define OR1200_SPR_CFGR		7'b0000000
`define OR1200_SPR_RF		6'b100000	
`define OR1200_SPR_NPC		11'b00000010000
`define OR1200_SPR_SR		11'b00000010001
`define OR1200_SPR_PPC		11'b00000010010
`define OR1200_SPR_EPCR		11'b00000100000
`define OR1200_SPR_EEAR		11'b00000110000
`define OR1200_SPR_ESR		11'b00001000000
`define OR1200_SR_WIDTH 16
`define OR1200_SR_SM   0
`define OR1200_SR_TEE  1
`define OR1200_SR_IEE  2
`define OR1200_SR_DCE  3
`define OR1200_SR_ICE  4
`define OR1200_SR_DME  5
`define OR1200_SR_IME  6
`define OR1200_SR_LEE  7
`define OR1200_SR_CE   8
`define OR1200_SR_F    9
`define OR1200_SR_CY   10	
`define OR1200_SR_OV   11	
`define OR1200_SR_OVE  12	
`define OR1200_SR_DSX  13	
`define OR1200_SR_EPH  14
`define OR1200_SR_FO   15
`define OR1200_SR_EPH_DEF	1'b0
`define OR1200_PM_PMR_DME 4
`define OR1200_PM_PMR_SME 5
`define OR1200_PM_PMR_DCGE 6
`define OR1200_PM_OFS_PMR 11'b0
`define OR1200_SPRGRP_PM 5'b01000
`define OR1200_PIC_INTS 20
`define OR1200_PIC_OFS_PICMR 2'b00
`define OR1200_PIC_OFS_PICSR 2'b10
`define OR1200_TT_OFS_TTMR 1'b0
`define OR1200_TT_OFS_TTCR 1'b1
`define OR1200_TTOFS_BITS 0
`define OR1200_TT_TTMR_IP 28
`define OR1200_TT_TTMR_IE 29
`define OR1200_MAC_ADDR		0	
`define OR1200_MAC_SHIFTBY	0	
`define OR1200_DTLB_TM_ADDR	7
`define	OR1200_DTLBMR_V_BITS	0
`define	OR1200_DTLBTR_CC_BITS	0
`define	OR1200_DTLBTR_CI_BITS	1
`define	OR1200_DTLBTR_WBC_BITS	2
`define	OR1200_DTLBTR_WOM_BITS	3
`define	OR1200_DTLBTR_A_BITS	4
`define	OR1200_DTLBTR_D_BITS	5
`define	OR1200_DTLBTR_URE_BITS	6
`define	OR1200_DTLBTR_UWE_BITS	7
`define	OR1200_DTLBTR_SRE_BITS	8
`define	OR1200_DTLBTR_SWE_BITS	9
`define	OR1200_DMMU_PS		13					
`define	OR1200_DTLB_INDXW	6							
`define OR1200_ITLB_TM_ADDR	7
`define	OR1200_ITLBMR_V_BITS	0
`define	OR1200_ITLBTR_CC_BITS	0
`define	OR1200_ITLBTR_CI_BITS	1
`define	OR1200_ITLBTR_WBC_BITS	2
`define	OR1200_ITLBTR_WOM_BITS	3
`define	OR1200_ITLBTR_A_BITS	4
`define	OR1200_ITLBTR_D_BITS	5
`define	OR1200_ITLBTR_SXE_BITS	6
`define	OR1200_ITLBTR_UXE_BITS	7
`define	OR1200_IMMU_PS 13					
`define	OR1200_ITLB_INDXW	6			
`define OR1200_IMMU_CI			1'b0
`define OR1200_ICLS		4
`define OR1200_DCLS		4
`define OR1200_DCSIZE			12			
`define	OR1200_DCTAG_W			21
`define OR1200_SB_LOG		2	
`define OR1200_SB_ENTRIES	4	
`define OR1200_QMEM_IADDR	32'h00800000
`define OR1200_QMEM_IMASK	32'hfff00000	
`define OR1200_QMEM_DADDR  32'h00800000
`define OR1200_QMEM_DMASK  32'hfff00000 
`define OR1200_SPRGRP_SYS_VR		4'h0
`define OR1200_SPRGRP_SYS_UPR		4'h1
`define OR1200_SPRGRP_SYS_CPUCFGR	4'h2
`define OR1200_SPRGRP_SYS_DMMUCFGR	4'h3
`define OR1200_SPRGRP_SYS_IMMUCFGR	4'h4
`define OR1200_SPRGRP_SYS_DCCFGR	4'h5
`define OR1200_SPRGRP_SYS_ICCFGR	4'h6
`define OR1200_SPRGRP_SYS_DCFGR	4'h7
`define OR1200_VR_REV			6'h01
`define OR1200_VR_RES1			10'h000
`define OR1200_VR_CFG			8'h00
`define OR1200_VR_VER			8'h12
`define OR1200_UPR_UP			1'b1
`define OR1200_UPR_DCP			1'b1
`define OR1200_UPR_ICP			1'b1
`define OR1200_UPR_DMP			1'b1
`define OR1200_UPR_IMP			1'b1
`define OR1200_UPR_MP			1'b1	
`define OR1200_UPR_DUP			1'b1
`define OR1200_UPR_PCUP			1'b0	
`define OR1200_UPR_PMP			1'b1
`define OR1200_UPR_PICP			1'b1
`define OR1200_UPR_TTP			1'b1
`define OR1200_UPR_RES1			13'h0000
`define OR1200_UPR_CUP			8'h00
`define OR1200_CPUCFGR_HGF_BITS	4
`define OR1200_CPUCFGR_OB32S_BITS	5
`define OR1200_CPUCFGR_OB64S_BITS	6
`define OR1200_CPUCFGR_OF32S_BITS	7
`define OR1200_CPUCFGR_OF64S_BITS	8
`define OR1200_CPUCFGR_OV64S_BITS	9
`define OR1200_CPUCFGR_NSGF		4'h0
`define OR1200_CPUCFGR_HGF		1'b0
`define OR1200_CPUCFGR_OB32S		1'b1
`define OR1200_CPUCFGR_OB64S		1'b0
`define OR1200_CPUCFGR_OF32S		1'b0
`define OR1200_CPUCFGR_OF64S		1'b0
`define OR1200_CPUCFGR_OV64S		1'b0
`define OR1200_CPUCFGR_RES1		22'h000000
`define OR1200_DMMUCFGR_CRI_BITS	8
`define OR1200_DMMUCFGR_PRI_BITS	9
`define OR1200_DMMUCFGR_TEIRI_BITS	10
`define OR1200_DMMUCFGR_HTR_BITS	11
`define OR1200_DMMUCFGR_NTW		2'h0	
`define OR1200_DMMUCFGR_NAE		3'h0	
`define OR1200_DMMUCFGR_CRI		1'b0	
`define OR1200_DMMUCFGR_PRI		1'b0	
`define OR1200_DMMUCFGR_TEIRI		1'b1	
`define OR1200_DMMUCFGR_HTR		1'b0	
`define OR1200_DMMUCFGR_RES1		20'h00000
`define OR1200_IMMUCFGR_CRI_BITS	8
`define OR1200_IMMUCFGR_PRI_BITS	9
`define OR1200_IMMUCFGR_TEIRI_BITS	10
`define OR1200_IMMUCFGR_HTR_BITS	11
`define OR1200_IMMUCFGR_NTW		2'h0	
`define OR1200_IMMUCFGR_NAE		3'h0	
`define OR1200_IMMUCFGR_CRI		1'b0	
`define OR1200_IMMUCFGR_PRI		1'b0	
`define OR1200_IMMUCFGR_TEIRI		1'b1	
`define OR1200_IMMUCFGR_HTR		1'b0	
`define OR1200_IMMUCFGR_RES1		20'h00000
`define OR1200_DCCFGR_CBS_BITS		7
`define OR1200_DCCFGR_CWS_BITS		8
`define OR1200_DCCFGR_CCRI_BITS		9
`define OR1200_DCCFGR_CBIRI_BITS	10
`define OR1200_DCCFGR_CBPRI_BITS	11
`define OR1200_DCCFGR_CBLRI_BITS	12
`define OR1200_DCCFGR_CBFRI_BITS	13
`define OR1200_DCCFGR_CBWBRI_BITS	14
`define OR1200_DCCFGR_NCW		3'h0	
`define OR1200_DCCFGR_CWS		1'b0	
`define OR1200_DCCFGR_CCRI		1'b1	
`define OR1200_DCCFGR_CBIRI		1'b1	
`define OR1200_DCCFGR_CBPRI		1'b0	
`define OR1200_DCCFGR_CBLRI		1'b0	
`define OR1200_DCCFGR_CBFRI		1'b1	
`define OR1200_DCCFGR_CBWBRI		1'b0	
`define OR1200_DCCFGR_RES1		17'h00000
`define OR1200_ICCFGR_CBS_BITS		7
`define OR1200_ICCFGR_CWS_BITS		8
`define OR1200_ICCFGR_CCRI_BITS		9
`define OR1200_ICCFGR_CBIRI_BITS	10
`define OR1200_ICCFGR_CBPRI_BITS	11
`define OR1200_ICCFGR_CBLRI_BITS	12
`define OR1200_ICCFGR_CBFRI_BITS	13
`define OR1200_ICCFGR_CBWBRI_BITS	14
`define OR1200_ICCFGR_NCW		3'h0	
`define OR1200_ICCFGR_CWS		1'b0	
`define OR1200_ICCFGR_CCRI		1'b1	
`define OR1200_ICCFGR_CBIRI		1'b1	
`define OR1200_ICCFGR_CBPRI		1'b0	
`define OR1200_ICCFGR_CBLRI		1'b0	
`define OR1200_ICCFGR_CBFRI		1'b1	
`define OR1200_ICCFGR_CBWBRI		1'b0	
`define OR1200_ICCFGR_RES1		17'h00000
`define OR1200_DCFGR_WPCI_BITS		3
`define OR1200_DCFGR_NDP		3'h0	
`define OR1200_DCFGR_WPCI		1'b0	
`define OR1200_DCFGR_RES1		28'h0000000
`define OR1200_ITAG_IDLE	4'h0	
`define	OR1200_ITAG_NI		4'h1	
`define OR1200_ITAG_BE		4'hb	
`define OR1200_ITAG_PE		4'hc	
`define OR1200_ITAG_TE		4'hd	
`define OR1200_BRANCHOP_WIDTH		3
`define OR1200_BRANCHOP_NOP		3'b000
`define OR1200_BRANCHOP_J		3'b001
`define OR1200_BRANCHOP_JR		3'b010
`define OR1200_BRANCHOP_BAL		3'b011
`define OR1200_BRANCHOP_BF		3'b100
`define OR1200_BRANCHOP_BNF		3'b101
`define OR1200_BRANCHOP_RFE		3'b110
`define OR1200_EXCEPT_WIDTH 4
`define OR1200_EXCEPT_EPH0_P 20'h00000
`define OR1200_EXCEPT_EPH1_P 20'hF0000
`define OR1200_EXCEPT_V		   8'h00
module or1200_genpc(
	clk, rst,
	icpu_adr_o, icpu_cycstb_o, icpu_sel_o, icpu_tag_o,
	icpu_rty_i, icpu_adr_i,
	branch_op, except_type,except_start, except_prefix, 
	branch_addrofs, lr_restor, flag, taken, 
	binsn_addr, epcr, spr_dat_i, spr_pc_we, genpc_refetch,
	genpc_freeze, genpc_stop_prefetch, no_more_dslot
);
input				clk;
input				rst;
output	[31:0]			icpu_adr_o;
output				icpu_cycstb_o;
output	[3:0]			icpu_sel_o;
output	[3:0]			icpu_tag_o;
input				icpu_rty_i;
input	[31:0]			icpu_adr_i;
input	[`OR1200_BRANCHOP_WIDTH-1:0]	branch_op;
input	[`OR1200_EXCEPT_WIDTH-1:0]	except_type;
input				except_start;
input					except_prefix;
input	[31:2]			branch_addrofs;
input	[31:0]			lr_restor;
input				flag;
output				taken;
input	[31:2]			binsn_addr;
input	[31:0]			epcr;
input	[31:0]			spr_dat_i;
input				spr_pc_we;
input				genpc_refetch;
input				genpc_freeze;
input				genpc_stop_prefetch;
input				no_more_dslot;
reg	[31:2]			pcreg;
reg	[31:0]			pc;
reg				taken;	
reg				genpc_refetch_r;
assign icpu_adr_o = !no_more_dslot & !except_start & !spr_pc_we & (icpu_rty_i | genpc_refetch) ? icpu_adr_i : pc;
assign icpu_cycstb_o = !genpc_freeze; 
assign icpu_sel_o = 4'b1111;
assign icpu_tag_o = `OR1200_ITAG_NI;
always @(posedge clk )
	if (rst)
		genpc_refetch_r <= 1'b0;
	else if (genpc_refetch)
		genpc_refetch_r <=  1'b1;
	else
		genpc_refetch_r <=  1'b0;
always @(pcreg or branch_addrofs or binsn_addr or flag or branch_op or except_type
	or except_start or lr_restor or epcr or spr_pc_we or spr_dat_i or except_prefix) begin
	case ({spr_pc_we, except_start, branch_op})	
		{2'b00, `OR1200_BRANCHOP_NOP}: begin
			pc = {pcreg + 30'b000000000000000000000000000001, 2'b0};
			taken = 1'b0;
		end
		{2'b00, `OR1200_BRANCHOP_J}: begin
			pc = {branch_addrofs, 2'b0};
			taken = 1'b1;
		end
		{2'b00, `OR1200_BRANCHOP_JR}: begin
			pc = lr_restor;
			taken = 1'b1;
		end
		{2'b00, `OR1200_BRANCHOP_BAL}: begin
	pc = {binsn_addr + branch_addrofs, 2'b0};
			taken = 1'b1;
		end
		{2'b00, `OR1200_BRANCHOP_BF}:
			if (flag) begin
				pc = {binsn_addr + branch_addrofs, 2'b0};
				taken = 1'b1;
			end
			else begin
				pc = {pcreg + 30'b000000000000000000000000000001, 2'b0};
				taken = 1'b0;
			end
		{2'b00, `OR1200_BRANCHOP_BNF}:
			if (flag) begin
				pc = {pcreg + 30'b000000000000000000000000000001, 2'b0};
				taken = 1'b0;
			end
			else begin				pc = {binsn_addr + branch_addrofs, 2'b0};
				taken = 1'b1;
			end
		{2'b00, `OR1200_BRANCHOP_RFE}: begin
			pc = epcr;
			taken = 1'b1;
		end
		{2'b01, 3'b000}: begin
			pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
			taken = 1'b1;
		end
		{2'b01, 3'b001}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		{2'b01, 3'b010}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		{2'b01, 3'b011}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		{2'b01, 3'b100}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		{2'b01, 3'b101}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		{2'b01, 3'b110}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		{2'b01, 3'b111}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		default: begin
			pc = spr_dat_i;
			taken = 1'b0;
		end
	endcase
end
always @(posedge clk )
	if (rst)
		pcreg <=  ({(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P),8'b11111111, `OR1200_EXCEPT_V} - 1) >> 2;
	else if (spr_pc_we)
		pcreg <=  spr_dat_i[31:2];
	else if (no_more_dslot | except_start | !genpc_freeze & !icpu_rty_i & !genpc_refetch)
		pcreg <=  pc[31:2];
		wire unused;
		assign unused = |except_prefix & | binsn_addr | genpc_stop_prefetch ;
endmodule
`define OR1200_ITAG_IDLE	4'h0	
`define	OR1200_ITAG_NI		4'h1	
`define OR1200_ITAG_BE		4'hb	
`define OR1200_ITAG_PE		4'hc	
`define OR1200_ITAG_TE		4'hd	
`define OR1200_OR32_J                 6'b000000
`define OR1200_OR32_JAL               6'b000001
`define OR1200_OR32_BNF               6'b000011
`define OR1200_OR32_BF                6'b000100
`define OR1200_OR32_NOP               6'b000101
`define OR1200_OR32_MOVHI             6'b000110
`define OR1200_OR32_XSYNC             6'b001000
`define OR1200_OR32_RFE               6'b001001
`define OR1200_OR32_JR                6'b010001
`define OR1200_OR32_JALR              6'b010010
`define OR1200_OR32_MACI              6'b010011
`define OR1200_OR32_LWZ               6'b100001
`define OR1200_OR32_LBZ               6'b100011
`define OR1200_OR32_LBS               6'b100100
`define OR1200_OR32_LHZ               6'b100101
`define OR1200_OR32_LHS               6'b100110
`define OR1200_OR32_ADDI              6'b100111
`define OR1200_OR32_ADDIC             6'b101000
`define OR1200_OR32_ANDI              6'b101001
`define OR1200_OR32_ORI               6'b101010
`define OR1200_OR32_XORI              6'b101011
`define OR1200_OR32_MULI              6'b101100
`define OR1200_OR32_MFSPR             6'b101101
`define OR1200_OR32_SH_ROTI 	      6'b101110
`define OR1200_OR32_SFXXI             6'b101111
`define OR1200_OR32_MTSPR             6'b110000
`define OR1200_OR32_MACMSB            6'b110001
`define OR1200_OR32_SW                6'b110101
`define OR1200_OR32_SB                6'b110110
`define OR1200_OR32_SH                6'b110111
`define OR1200_OR32_ALU               6'b111000
`define OR1200_OR32_SFXX              6'b111001
module or1200_if(
	clk, rst,
	icpu_dat_i, icpu_ack_i, icpu_err_i, icpu_adr_i, icpu_tag_i,
	if_freeze, if_insn, if_pc, flushpipe,
	if_stall, no_more_dslot, genpc_refetch, rfe,
	except_itlbmiss, except_immufault, except_ibuserr
);
input				clk;
input				rst;
input	[31:0]			icpu_dat_i;
input				icpu_ack_i;
input				icpu_err_i;
input	[31:0]			icpu_adr_i;
input	[3:0]			icpu_tag_i;
input				if_freeze;
output	[31:0]			if_insn;
output	[31:0]			if_pc;
input				flushpipe;
output				if_stall;
input				no_more_dslot;
output				genpc_refetch;
input				rfe;
output				except_itlbmiss;
output				except_immufault;
output				except_ibuserr;
reg	[31:0]			insn_saved;
reg	[31:0]			addr_saved;
reg				saved;
assign if_insn = icpu_err_i | no_more_dslot | rfe ? {`OR1200_OR32_NOP, 26'h0410000} : saved ? insn_saved : icpu_ack_i ? icpu_dat_i : {`OR1200_OR32_NOP, 26'h0610000};
assign if_pc = saved ? addr_saved : icpu_adr_i;
assign if_stall = !icpu_err_i & !icpu_ack_i & !saved;
assign genpc_refetch = saved & icpu_ack_i;
assign except_itlbmiss = icpu_err_i & (icpu_tag_i == `OR1200_ITAG_TE) & !no_more_dslot;
assign except_immufault = icpu_err_i & (icpu_tag_i == `OR1200_ITAG_PE) & !no_more_dslot;
assign except_ibuserr = icpu_err_i & (icpu_tag_i == `OR1200_ITAG_BE) & !no_more_dslot;
always @(posedge clk )
	if (rst)
		saved <=  1'b0;
	else if (flushpipe)
		saved <=  1'b0;
	else if (icpu_ack_i & if_freeze & !saved)
		saved <=  1'b1;
	else if (!if_freeze)
		saved <=  1'b0;
always @(posedge clk )
	if (rst)
		insn_saved <=  {`OR1200_OR32_NOP, 26'h0410000};
	else if (flushpipe)
		insn_saved <=  {`OR1200_OR32_NOP, 26'h0410000};
	else if (icpu_ack_i & if_freeze & !saved)
		insn_saved <=  icpu_dat_i;
	else if (!if_freeze)
		insn_saved <=  {`OR1200_OR32_NOP, 26'h0410000};
always @(posedge clk )
	if (rst)
		addr_saved <=  32'h00000000;
	else if (flushpipe)
		addr_saved <=  32'h00000000;
	else if (icpu_ack_i & if_freeze & !saved)
		addr_saved <=  icpu_adr_i;
	else if (!if_freeze)
		addr_saved <=  icpu_adr_i;
endmodule
module or1200_ctrl(
	clk, rst,
	id_freeze, ex_freeze, wb_freeze, flushpipe, if_insn, ex_insn, branch_op, branch_taken,
	rf_addra, rf_addrb, rf_rda, rf_rdb, alu_op, mac_op, shrot_op, comp_op, rf_addrw, rfwb_op,
	wb_insn, simm, branch_addrofs, lsu_addrofs, sel_a, sel_b, lsu_op,
	cust5_op, cust5_limm,
	multicycle, spr_addrimm, wbforw_valid, sig_syscall, sig_trap,
	force_dslot_fetch, no_more_dslot, ex_void, id_macrc_op, ex_macrc_op, rfe,du_hwbkpt, except_illegal
);
input					clk;
input					rst;
input					id_freeze;
input					ex_freeze;
input					wb_freeze;
input					flushpipe;
input	[31:0]				if_insn;
output	[31:0]				ex_insn;
output	[`OR1200_BRANCHOP_WIDTH-1:0]		branch_op;
input						branch_taken;
output	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	rf_addrw;
output	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	rf_addra;
output	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	rf_addrb;
output					rf_rda;
output					rf_rdb;
output	[`OR1200_ALUOP_WIDTH-1:0]		alu_op;
output	[`OR1200_MACOP_WIDTH-1:0]		mac_op;
output	[`OR1200_SHROTOP_WIDTH-1:0]		shrot_op;
output	[`OR1200_RFWBOP_WIDTH-1:0]		rfwb_op;
output	[31:0]				wb_insn;
output	[31:0]				simm;
output	[31:2]				branch_addrofs;
output	[31:0]				lsu_addrofs;
output	[`OR1200_SEL_WIDTH-1:0]		sel_a;
output	[`OR1200_SEL_WIDTH-1:0]		sel_b;
output	[`OR1200_LSUOP_WIDTH-1:0]		lsu_op;
output	[`OR1200_COMPOP_WIDTH-1:0]		comp_op;
output	[`OR1200_MULTICYCLE_WIDTH-1:0]		multicycle;
output	[4:0]				cust5_op;
output	[5:0]				cust5_limm;
output	[15:0]				spr_addrimm;
input					wbforw_valid;
input					du_hwbkpt;
output					sig_syscall;
output					sig_trap;
output					force_dslot_fetch;
output					no_more_dslot;
output					ex_void;
output					id_macrc_op;
output					ex_macrc_op;
output					rfe;
output					except_illegal;
reg	[`OR1200_BRANCHOP_WIDTH-1:0]		pre_branch_op;
reg	[`OR1200_BRANCHOP_WIDTH-1:0]		branch_op;
reg	[`OR1200_ALUOP_WIDTH-1:0]		alu_op;
reg	[`OR1200_MACOP_WIDTH-1:0]		mac_op;
reg					ex_macrc_op;
reg	[`OR1200_SHROTOP_WIDTH-1:0]		shrot_op;
reg	[31:0]				id_insn;
reg	[31:0]				ex_insn;
reg	[31:0]				wb_insn;
reg	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	rf_addrw;
reg	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	wb_rfaddrw;
reg	[`OR1200_RFWBOP_WIDTH-1:0]		rfwb_op;
reg	[31:0]				lsu_addrofs;
reg	[`OR1200_SEL_WIDTH-1:0]		sel_a;
reg	[`OR1200_SEL_WIDTH-1:0]		sel_b;
reg					sel_imm;
reg	[`OR1200_LSUOP_WIDTH-1:0]		lsu_op;
reg	[`OR1200_COMPOP_WIDTH-1:0]		comp_op;
reg	[`OR1200_MULTICYCLE_WIDTH-1:0]		multicycle;
reg					imm_signextend;
reg	[15:0]				spr_addrimm;
reg					sig_syscall;
reg					sig_trap;
reg					except_illegal;
wire					id_void;
assign rf_addra = if_insn[20:16];
assign rf_addrb = if_insn[15:11];
assign rf_rda = if_insn[31];
assign rf_rdb = if_insn[30];
assign force_dslot_fetch = 1'b0;
assign no_more_dslot = |branch_op & !id_void & branch_taken | (branch_op == `OR1200_BRANCHOP_RFE);
assign id_void = (id_insn[31:26] == `OR1200_OR32_NOP) & id_insn[16];
assign ex_void = (ex_insn[31:26] == `OR1200_OR32_NOP) & ex_insn[16];
assign simm = (imm_signextend == 1'b1) ? {{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]}, id_insn[15:0]} : {{16'b0}, id_insn[15:0]};
assign branch_addrofs = {{ex_insn[25]},{ex_insn[25]},{ex_insn[25]},{ex_insn[25]},{ex_insn[25]}, ex_insn[25:0]};
assign id_macrc_op = (id_insn[31:26] == `OR1200_OR32_MOVHI) & id_insn[16];
assign cust5_op = ex_insn[4:0];
assign cust5_limm = ex_insn[10:5];
assign rfe = (pre_branch_op == `OR1200_BRANCHOP_RFE) | (branch_op == `OR1200_BRANCHOP_RFE);
always @(rf_addrw or id_insn or rfwb_op or wbforw_valid or wb_rfaddrw)
	if ((id_insn[20:16] == rf_addrw) && rfwb_op[0])
		sel_a = `OR1200_SEL_EX_FORW;
	else if ((id_insn[20:16] == wb_rfaddrw) && wbforw_valid)
		sel_a = `OR1200_SEL_WB_FORW;
	else
		sel_a = `OR1200_SEL_RF;
always @(rf_addrw or sel_imm or id_insn or rfwb_op or wbforw_valid or wb_rfaddrw)
	if (sel_imm)
		sel_b = `OR1200_SEL_IMM;
	else if ((id_insn[15:11] == rf_addrw) && rfwb_op[0])
		sel_b = `OR1200_SEL_EX_FORW;
	else if ((id_insn[15:11] == wb_rfaddrw) && wbforw_valid)
		sel_b = `OR1200_SEL_WB_FORW;
	else
		sel_b = `OR1200_SEL_RF;
always @(posedge clk ) begin
	if (rst)
		ex_macrc_op <=  1'b0;
	else if (!ex_freeze & id_freeze | flushpipe)
		ex_macrc_op <=  1'b0;
	else if (!ex_freeze)
		ex_macrc_op <=  id_macrc_op;
end
always @(posedge clk ) begin
	if (rst)
		spr_addrimm <=  16'h0000;
	else if (!ex_freeze & id_freeze | flushpipe)
		spr_addrimm <=  16'h0000;
	else if (!ex_freeze) begin
		case (id_insn[31:26])	
			`OR1200_OR32_MFSPR: 
				spr_addrimm <=  id_insn[15:0];
			default:
				spr_addrimm <=  {id_insn[25:21], id_insn[10:0]};
		endcase
	end
end
always @(id_insn) begin
  case (id_insn[31:26])		
    `OR1200_OR32_LWZ:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_LBZ:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_LBS:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_LHZ:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_LHS:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_SW:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_SB:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_SH:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_ALU:
      multicycle = id_insn[9:8];
    default: begin
      multicycle = `OR1200_ONE_CYCLE;
    end
  endcase
end
always @(id_insn) begin
  case (id_insn[31:26])		
	`OR1200_OR32_ADDI:
		imm_signextend = 1'b1;
	`OR1200_OR32_ADDIC:
		imm_signextend = 1'b1;
	`OR1200_OR32_XORI:
		imm_signextend = 1'b1;
	`OR1200_OR32_MULI:
		imm_signextend = 1'b1;
	`OR1200_OR32_MACI:
		imm_signextend = 1'b1;
	`OR1200_OR32_SFXXI:
		imm_signextend = 1'b1;
	default: begin
		imm_signextend = 1'b0;
	end
endcase
end
always @(lsu_op or ex_insn) begin
	lsu_addrofs[10:0] = ex_insn[10:0];
	case(lsu_op)	
		`OR1200_LSUOP_SB : 
			lsu_addrofs[31:11] = {{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}}, ex_insn[25:21]};
			`OR1200_LSUOP_SH : 
			lsu_addrofs[31:11] = {{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}}, ex_insn[25:21]};
		`OR1200_LSUOP_SW : 
			lsu_addrofs[31:11] = {{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}}, ex_insn[25:21]};
		default : 
			lsu_addrofs[31:11] = {{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}}, ex_insn[15:11]};
	endcase
end
always @(posedge clk) begin
	if (rst)
		rf_addrw <=  5'b00000;
	else if (!ex_freeze & id_freeze)
		rf_addrw <=  5'b00000;
	else if (!ex_freeze)
		case (pre_branch_op)	
`OR1200_BRANCHOP_BAL:
				rf_addrw <=  5'b01001;	
				`OR1200_BRANCHOP_JR:
				rf_addrw <=  5'b01001;
			default:
				rf_addrw <=  id_insn[25:21];
		endcase
end
always @(posedge clk ) begin
	if (rst)
		wb_rfaddrw <=  5'b00000;
	else if (!wb_freeze)
		wb_rfaddrw <=  rf_addrw;
end
always @(posedge clk ) begin
	if (rst)
		id_insn <=  {`OR1200_OR32_NOP, 26'h0410000};
        else if (flushpipe)
                id_insn <=  {`OR1200_OR32_NOP, 26'h0410000};        
	else if (!id_freeze) begin
		id_insn <=  if_insn;
	end
end
always @(posedge clk ) begin
	if (rst)
		ex_insn <=  {`OR1200_OR32_NOP, 26'h0410000};
	else if (!ex_freeze & id_freeze | flushpipe)
		ex_insn <=  {`OR1200_OR32_NOP, 26'h0410000};	
	else if (!ex_freeze) begin
		ex_insn <=  id_insn;
	end
end
always @(posedge clk ) begin
	if (rst)
		wb_insn <=  {`OR1200_OR32_NOP, 26'h0410000};
	else if (flushpipe)
		wb_insn <=  {`OR1200_OR32_NOP, 26'h0410000};	
	else if (!wb_freeze) begin
		wb_insn <=  ex_insn;
	end
end
always @(posedge clk ) begin
	if (rst)
		sel_imm <=  1'b0;
	else if (!id_freeze) begin
	  case (if_insn[31:26])		
	    `OR1200_OR32_JALR:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_JR:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_RFE:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_MFSPR:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_MTSPR:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_XSYNC:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_MACMSB:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_SW:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_SB:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_SH:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_ALU:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_SFXX:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_CUST5:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_NOP:
	      sel_imm <=  1'b0;
	    default: begin
	      sel_imm <=  1'b1;
	    end
	  endcase
	end
end
always @(posedge clk ) begin
	if (rst)
		except_illegal <=  1'b0;
	else if (!ex_freeze & id_freeze | flushpipe)
		except_illegal <=  1'b0;
	else if (!ex_freeze) begin
	      except_illegal <=  1'b1;
	end
end
always @(posedge clk ) begin
	if (rst)
		alu_op <=  `OR1200_ALUOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		alu_op <=  `OR1200_ALUOP_NOP;
	else if (!ex_freeze) begin
	  case (id_insn[31:26])		
	    `OR1200_OR32_J:
	      alu_op <=  `OR1200_ALUOP_IMM;
	    `OR1200_OR32_JAL:
	      alu_op <=  `OR1200_ALUOP_IMM;
	    `OR1200_OR32_BNF:
	      alu_op <=  `OR1200_ALUOP_NOP;
	    `OR1200_OR32_BF:
	      alu_op <=  `OR1200_ALUOP_NOP;
	    `OR1200_OR32_MOVHI:
	      alu_op <=  `OR1200_ALUOP_MOVHI;
	    `OR1200_OR32_MFSPR:
	      alu_op <=  `OR1200_ALUOP_MFSR;
	    `OR1200_OR32_MTSPR:
	      alu_op <=  `OR1200_ALUOP_MTSR;
	    `OR1200_OR32_ADDI:
	      alu_op <=  `OR1200_ALUOP_ADD;
	    `OR1200_OR32_ADDIC:
	      alu_op <=  `OR1200_ALUOP_ADDC;
	    `OR1200_OR32_ANDI:
	      alu_op <=  `OR1200_ALUOP_AND;
	    `OR1200_OR32_ORI:
	      alu_op <=  `OR1200_ALUOP_OR;
	    `OR1200_OR32_XORI:
	      alu_op <=  `OR1200_ALUOP_XOR;
	    `OR1200_OR32_MULI:
	      alu_op <=  `OR1200_ALUOP_MUL;
	    `OR1200_OR32_SH_ROTI:
	      alu_op <=  `OR1200_ALUOP_SHROT;
	    `OR1200_OR32_SFXXI:
	      alu_op <=  `OR1200_ALUOP_COMP;
	    `OR1200_OR32_ALU:
	      alu_op <=  id_insn[3:0];
	    `OR1200_OR32_SFXX:
	      alu_op <=  `OR1200_ALUOP_COMP;
	    `OR1200_OR32_CUST5:
	      alu_op <=  `OR1200_ALUOP_CUST5;	    
	    default: begin
	      alu_op <=  `OR1200_ALUOP_NOP;
	    end
	  endcase
	end
end
always @(posedge clk ) begin
	if (rst)
		mac_op <=  `OR1200_MACOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		mac_op <=  `OR1200_MACOP_NOP;
	else if (!ex_freeze)
	  case (id_insn[31:26])		
	    `OR1200_OR32_MACI:
	      mac_op <=  `OR1200_MACOP_MAC;
	    `OR1200_OR32_MACMSB:
	      mac_op <=  id_insn[1:0];
	    default: begin
	      mac_op <=  `OR1200_MACOP_NOP;
	    end	      
	  endcase
	else
		mac_op <=  `OR1200_MACOP_NOP;
end
always @(posedge clk ) begin
	if (rst)
		shrot_op <=  `OR1200_SHROTOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		shrot_op <=  `OR1200_SHROTOP_NOP;
	else if (!ex_freeze) begin
		shrot_op <=  id_insn[7:6];
	end
end
always @(posedge clk ) begin
	if (rst)
		rfwb_op <=  `OR1200_RFWBOP_NOP;
	else  if (!ex_freeze & id_freeze | flushpipe)
		rfwb_op <=  `OR1200_RFWBOP_NOP;
	else  if (!ex_freeze) begin
		case (id_insn[31:26])		
		  `OR1200_OR32_JAL:
		    rfwb_op <=  `OR1200_RFWBOP_LR;
		  `OR1200_OR32_JALR:
		    rfwb_op <=  `OR1200_RFWBOP_LR;
		  `OR1200_OR32_MOVHI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_MFSPR:
		    rfwb_op <=  `OR1200_RFWBOP_SPRS;
		  `OR1200_OR32_LWZ:
		    rfwb_op <=  `OR1200_RFWBOP_LSU;
		  `OR1200_OR32_LBZ:
		    rfwb_op <=  `OR1200_RFWBOP_LSU;
		  `OR1200_OR32_LBS:
		    rfwb_op <=  `OR1200_RFWBOP_LSU;
		  `OR1200_OR32_LHZ:
		    rfwb_op <=  `OR1200_RFWBOP_LSU;
		  `OR1200_OR32_LHS:
		    rfwb_op <=  `OR1200_RFWBOP_LSU;
		  `OR1200_OR32_ADDI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_ADDIC:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_ANDI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_ORI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_XORI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_MULI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_SH_ROTI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_ALU:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_CUST5:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  default: begin
		    rfwb_op <=  `OR1200_RFWBOP_NOP;
		  end
		endcase
	end
end
always @(posedge clk ) begin
	if (rst)
		pre_branch_op <=  `OR1200_BRANCHOP_NOP;
	else if (flushpipe)
		pre_branch_op <=  `OR1200_BRANCHOP_NOP;
	else if (!id_freeze) begin
		case (if_insn[31:26])		
		  `OR1200_OR32_J:
		    pre_branch_op <=  `OR1200_BRANCHOP_BAL;
		  `OR1200_OR32_JAL:
		    pre_branch_op <=  `OR1200_BRANCHOP_BAL;
		  `OR1200_OR32_JALR:
		    pre_branch_op <=  `OR1200_BRANCHOP_JR;
		  `OR1200_OR32_JR:
		    pre_branch_op <=  `OR1200_BRANCHOP_JR;
		  `OR1200_OR32_BNF:
		    pre_branch_op <=  `OR1200_BRANCHOP_BNF;
		  `OR1200_OR32_BF:
		    pre_branch_op <=  `OR1200_BRANCHOP_BF;
		  `OR1200_OR32_RFE:
		    pre_branch_op <=  `OR1200_BRANCHOP_RFE;
		  default: begin
		    pre_branch_op <=  `OR1200_BRANCHOP_NOP;
		  end
		endcase
	end
end
always @(posedge clk )
	if (rst)
		branch_op <=  `OR1200_BRANCHOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		branch_op <=  `OR1200_BRANCHOP_NOP;		
	else if (!ex_freeze)
		branch_op <=  pre_branch_op;
always @(posedge clk ) begin
	if (rst)
		lsu_op <=  `OR1200_LSUOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		lsu_op <=  `OR1200_LSUOP_NOP;
	else if (!ex_freeze)  begin
	  case (id_insn[31:26])		
	    `OR1200_OR32_LWZ:
	      lsu_op <=  `OR1200_LSUOP_LWZ;
	    `OR1200_OR32_LBZ:
	      lsu_op <=  `OR1200_LSUOP_LBZ;
	    `OR1200_OR32_LBS:
	      lsu_op <=  `OR1200_LSUOP_LBS;
	    `OR1200_OR32_LHZ:
	      lsu_op <=  `OR1200_LSUOP_LHZ;
	    `OR1200_OR32_LHS:
	      lsu_op <=  `OR1200_LSUOP_LHS;
	    `OR1200_OR32_SW:
	      lsu_op <=  `OR1200_LSUOP_SW;
	    `OR1200_OR32_SB:
	      lsu_op <=  `OR1200_LSUOP_SB;
	    `OR1200_OR32_SH:
	      lsu_op <=  `OR1200_LSUOP_SH;
	    default: begin
	      lsu_op <=  `OR1200_LSUOP_NOP;
	    end
	  endcase
	end
end
always @(posedge clk ) begin
	if (rst) begin
		comp_op <=  4'b0000;
	end else if (!ex_freeze & id_freeze | flushpipe)
		comp_op <=  4'b0000;
	else if (!ex_freeze)
		comp_op <=  id_insn[24:21];
end
always @(posedge clk ) begin
	if (rst)
		sig_syscall <=  1'b0;
	else if (!ex_freeze & id_freeze | flushpipe)
		sig_syscall <=  1'b0;
	else if (!ex_freeze) begin
		sig_syscall <=  (id_insn[31:23] == {`OR1200_OR32_XSYNC, 3'b000});
	end
end
always @(posedge clk ) begin
	if (rst)
		sig_trap <=  1'b0;
	else if (!ex_freeze & id_freeze | flushpipe)
		sig_trap <=  1'b0;
	else if (!ex_freeze) begin
		sig_trap <=  (id_insn[31:23] == {`OR1200_OR32_XSYNC, 3'b010})
			| du_hwbkpt;
	end
end
endmodule
module or1200_rf(
	clk, rst,
	supv, wb_freeze, addrw, dataw,id_freeze, we, flushpipe,
 addra, rda, dataa,  addrb,rdb, datab, 
	spr_cs, spr_write, spr_addr, spr_dat_i, spr_dat_o
);
input				clk;
input				rst;
input				supv;
input				wb_freeze;
input	[`OR1200_REGFILE_ADDR_WIDTH-1:0]		addrw;
input	[`OR1200_OPERAND_WIDTH-1:0]		dataw;
input				we;
input				flushpipe;
input				id_freeze;
input	[`OR1200_REGFILE_ADDR_WIDTH-1:0]		addra;
input	[`OR1200_REGFILE_ADDR_WIDTH-1:0]		addrb;
output	[`OR1200_OPERAND_WIDTH-1:0]		dataa;
output	[`OR1200_OPERAND_WIDTH-1:0]		datab;
input				rda;
input				rdb;
input				spr_cs;
input				spr_write;
input	[31:0]			spr_addr;
input	[31:0]			spr_dat_i;
output	[31:0]			spr_dat_o;
wire	[`OR1200_OPERAND_WIDTH-1:0]		from_rfa;
wire	[`OR1200_OPERAND_WIDTH-1:0]		from_rfb;
reg	[`OR1200_OPERAND_WIDTH:0]			dataa_saved;
reg	[`OR1200_OPERAND_WIDTH:0]			datab_saved;
wire	[`OR1200_REGFILE_ADDR_WIDTH-1:0]		rf_addra;
wire	[`OR1200_REGFILE_ADDR_WIDTH-1:0]		rf_addrw;
wire	[`OR1200_OPERAND_WIDTH-1:0]		rf_dataw;
wire				rf_we;
wire				spr_valid;
wire				rf_ena;
wire				rf_enb;
reg				rf_we_allow;
assign spr_valid = spr_cs & (spr_addr[10:5] == `OR1200_SPR_RF);
assign spr_dat_o = from_rfa;
assign dataa = (dataa_saved[32]) ? dataa_saved[31:0] : from_rfa;
assign datab = (datab_saved[32]) ? datab_saved[31:0] : from_rfb;
assign rf_addra = (spr_valid & !spr_write) ? spr_addr[4:0] : addra;
assign rf_addrw = (spr_valid & spr_write) ? spr_addr[4:0] : addrw;
assign rf_dataw = (spr_valid & spr_write) ? spr_dat_i : dataw;
always @(posedge clk)
	if (rst)
		rf_we_allow <=  1'b1;
	else if (~wb_freeze)
		rf_we_allow <= ~flushpipe;
assign rf_we = ((spr_valid & spr_write) | (we & ~wb_freeze)) & rf_we_allow & (supv | (|rf_addrw));
assign rf_ena = rda & ~id_freeze | spr_valid;	
assign rf_enb = rdb & ~id_freeze | spr_valid;
always @(posedge clk )
	if (rst) begin
		dataa_saved <=33'b000000000000000000000000000000000;
	end
	else if (id_freeze & !dataa_saved[32]) begin
		dataa_saved <= {1'b1, from_rfa};
	end
	else if (!id_freeze)
		dataa_saved <=33'b000000000000000000000000000000000;
always @(posedge clk)
	if (rst) begin
		datab_saved <=  33'b000000000000000000000000000000000;
	end
	else if (id_freeze & !datab_saved[32]) begin
		datab_saved <=  {1'b1, from_rfb};
	end
	else if (!id_freeze)
		datab_saved <=  33'b000000000000000000000000000000000;
wire const_one;
wire const_zero;
assign const_one = 1'b1;
assign const_zero = 1'b0;
wire [31:0] const_zero_data;
assign const_zero_data = 32'b00000000000000000000000000000000;
wire [31:0] dont_care_out;
wire [31:0] dont_care_out2;
dual_port_ram rf_a(	
  .clk (clk),
  .we1(const_zero),
  .we2(rf_we),
  .data1(const_zero_data),
  .data2(rf_dataw),
  .out1(from_rfa),
  .out2 (dont_care_out),
  .addr1(rf_addra),
  .addr2(rf_addrw));
dual_port_ram rf_b(	
  .clk (clk),
  .we1(const_zero),
  .we2(rf_we),
  .data1(const_zero_data),
  .data2(rf_dataw),
  .out1(from_rfb),
  .out2 (dont_care_out2),
  .addr1(addrb),
  .addr2(rf_addrw));
wire unused;
assign unused = |spr_addr;
endmodule
module or1200_operandmuxes(
	clk, rst,
	id_freeze, ex_freeze, rf_dataa, rf_datab, ex_forw, wb_forw,
	simm, sel_a, sel_b, operand_a, operand_b, muxed_b
);
input				clk;
input				rst;
input				id_freeze;
input				ex_freeze;
input	[`OR1200_OPERAND_WIDTH-1:0]		rf_dataa;
input	[`OR1200_OPERAND_WIDTH-1:0]		rf_datab;
input	[`OR1200_OPERAND_WIDTH-1:0]		ex_forw;
input	[`OR1200_OPERAND_WIDTH-1:0]		wb_forw;
input	[`OR1200_OPERAND_WIDTH-1:0]		simm;
input	[`OR1200_SEL_WIDTH-1:0]	sel_a;
input	[`OR1200_SEL_WIDTH-1:0]	sel_b;
output	[`OR1200_OPERAND_WIDTH-1:0]		operand_a;
output	[`OR1200_OPERAND_WIDTH-1:0]		operand_b;
output	[`OR1200_OPERAND_WIDTH-1:0]		muxed_b;
reg	[`OR1200_OPERAND_WIDTH-1:0]		operand_a;
reg	[`OR1200_OPERAND_WIDTH-1:0]		operand_b;
reg	[`OR1200_OPERAND_WIDTH-1:0]		muxed_a;
reg	[`OR1200_OPERAND_WIDTH-1:0]		muxed_b;
reg				saved_a;
reg				saved_b;
always @(posedge clk ) begin
	if (rst) begin
		operand_a <=  32'b0000000000000000000000000000;
		saved_a <=  1'b0;
	end else if (!ex_freeze && id_freeze && !saved_a) begin
		operand_a <=  muxed_a;
		saved_a <=  1'b1;
	end else if (!ex_freeze && !saved_a) begin
		operand_a <=  muxed_a;
	end else if (!ex_freeze && !id_freeze)
		saved_a <=  1'b0;
end
always @(posedge clk ) begin
	if (rst) begin
		operand_b <=  32'b0000000000000000000000000000;
		saved_b <=  1'b0;
	end else if (!ex_freeze && id_freeze && !saved_b) begin
		operand_b <=  muxed_b;
		saved_b <=  1'b1;
	end else if (!ex_freeze && !saved_b) begin
		operand_b <=  muxed_b;
	end else if (!ex_freeze && !id_freeze)
		saved_b <=  1'b0;
end
always @(ex_forw or wb_forw or rf_dataa or sel_a) begin
	case (sel_a)	
		`OR1200_SEL_EX_FORW:
			muxed_a = ex_forw;
		`OR1200_SEL_WB_FORW:
			muxed_a = wb_forw;
		default:
			muxed_a = rf_dataa;
	endcase
end
always @(simm or ex_forw or wb_forw or rf_datab or sel_b) begin
	case (sel_b)	
		`OR1200_SEL_IMM:
			muxed_b = simm;
		`OR1200_SEL_EX_FORW:
			muxed_b = ex_forw;
		`OR1200_SEL_WB_FORW:
			muxed_b = wb_forw;
		default:
			muxed_b = rf_datab;
	endcase
end
endmodule
module or1200_alu(
	a, b, mult_mac_result, macrc_op,
	alu_op, shrot_op, comp_op,
	cust5_op, cust5_limm,
	result, flagforw, flag_we,
	cyforw, cy_we, flag,k_carry
);
input	[32-1:0]		a;
input	[32-1:0]		b;
input	[32-1:0]		mult_mac_result;
input				macrc_op;
input	[`OR1200_ALUOP_WIDTH-1:0]	alu_op;
input	[2-1:0]	shrot_op;
input	[4-1:0]	comp_op;
input	[4:0]			cust5_op;
input	[5:0]			cust5_limm;
output	[32-1:0]		result;
output				flagforw;
output				flag_we;
output				cyforw;
output				cy_we;
input				k_carry;
input         flag;
reg	[32-1:0]		result;
reg	[32-1:0]		shifted_rotated;
reg	[32-1:0]		result_cust5;
reg				flagforw;
reg				flagcomp;
reg				flag_we;
reg				cy_we;
wire	[32-1:0]		comp_a;
wire	[32-1:0]		comp_b;
wire				a_eq_b;
wire				a_lt_b;
wire	[32-1:0]		result_sum;
wire	[32-1:0]		result_csum;
wire				cy_csum;
wire	[32-1:0]		result_and;
wire				cy_sum;
reg				cyforw;
assign comp_a [31:3]= a[31] ^ comp_op[3];
assign comp_a [2:0] = a[30:0];
assign comp_b [31:3]  = b[31] ^ comp_op[3] ;
assign comp_b [2:0] =  b[32-2:0];
assign a_eq_b = (comp_a == comp_b);
assign a_lt_b = (comp_a < comp_b);
assign cy_sum= a + b;
assign result_sum = a+b;
assign cy_csum =a + b + {32'b00000000000000000000000000000000, k_carry};
assign result_csum = a + b + {32'b00000000000000000000000000000000, k_carry};
assign result_and = a & b;
always @(alu_op or a or b or result_sum or result_and or macrc_op or shifted_rotated or mult_mac_result) 
begin
	case (alu_op)		
    4'b1111: begin
        result = a[0] ? 1 : a[1] ? 2 : a[2] ? 3 : a[3] ? 4 : a[4] ? 5 : a[5] ? 6 : a[6] ? 7 : a[7] ? 8 : a[8] ? 9 : a[9] ? 10 : a[10] ? 11 : a[11] ? 12 : a[12] ? 13 : a[13] ? 14 : a[14] ? 15 : a[15] ? 16 : a[16] ? 17 : a[17] ? 18 : a[18] ? 19 : a[19] ? 20 : a[20] ? 21 : a[21] ? 22 : a[22] ? 23 : a[23] ? 24 : a[24] ? 25 : a[25] ? 26 : a[26] ? 27 : a[27] ? 28 : a[28] ? 29 : a[29] ? 30 : a[30] ? 31 : a[31] ? 32 : 0;
    end
		`OR1200_ALUOP_CUST5 : begin 
				result = result_cust5;
		end
		`OR1200_ALUOP_SHROT : begin 
				result = shifted_rotated;
		end
		`OR1200_ALUOP_ADD : begin
				result = result_sum;
		end
		`OR1200_ALUOP_ADDC : begin
				result = result_csum;
		end
		`OR1200_ALUOP_SUB : begin
				result = a - b;
		end
		`OR1200_ALUOP_XOR : begin
				result = a ^ b;
		end
		`OR1200_ALUOP_OR  : begin
				result = a | b;
		end
		`OR1200_ALUOP_IMM : begin
				result = b;
		end
		`OR1200_ALUOP_MOVHI : begin
				if (macrc_op) begin
					result = mult_mac_result;
				end
				else begin
					result = b << 16;
				end
		end
		`OR1200_ALUOP_MUL : begin
				result = mult_mac_result;
		end
    4'b1110: begin
        result = flag ? a : b;
    end
    default: 
    begin
      result=result_and;
    end 
	endcase
end
always @(cust5_op or cust5_limm or a or b) begin
	case (cust5_op)		
		5'h1 : begin 
			case (cust5_limm[1:0])
				2'h0: result_cust5 = {a[31:8], b[7:0]};
				2'h1: result_cust5 = {a[31:16], b[7:0], a[7:0]};
				2'h2: result_cust5 = {a[31:24], b[7:0], a[15:0]};
				2'h3: result_cust5 = {b[7:0], a[23:0]};
			endcase
		end
		5'h2 :
			result_cust5 = a | (1 << 4);
		5'h3 :
			result_cust5 = a & (32'b11111111111111111111111111111111^ (cust5_limm));
		default: begin
			result_cust5 = a;
		end
	endcase
end
always @(alu_op or result_sum or result_and or flagcomp) begin
	case (alu_op)		
		`OR1200_ALUOP_ADD : begin
			flagforw = (result_sum == 32'b00000000000000000000000000000000);
			flag_we = 1'b1;
		end
		`OR1200_ALUOP_ADDC : begin
			flagforw = (result_csum == 32'b00000000000000000000000000000000);
			flag_we = 1'b1;
		end
		`OR1200_ALUOP_AND: begin
			flagforw = (result_and == 32'b00000000000000000000000000000000);
			flag_we = 1'b1;
		end
		`OR1200_ALUOP_COMP: begin
			flagforw = flagcomp;
			flag_we = 1'b1;
		end
		default: begin
			flagforw = 1'b0;
			flag_we = 1'b0;
		end
	endcase
end
always @(alu_op or cy_sum
	) begin
	case (alu_op)		
		`OR1200_ALUOP_ADD : begin
			cyforw = cy_sum;
			cy_we = 1'b1;
		end
		`OR1200_ALUOP_ADDC: begin
			cyforw = cy_csum;
			cy_we = 1'b1;
		end
		default: begin
			cyforw = 1'b0;
			cy_we = 1'b0;
		end
	endcase
end
always @(shrot_op or a or b) begin
	case (shrot_op)		
	2'b00 :
				shifted_rotated = (a << 2);
		`OR1200_SHROTOP_SRL :
				shifted_rotated = (a >> 2);
		`OR1200_SHROTOP_ROR :
				shifted_rotated = (a << 1'b1);
		default:
				shifted_rotated = (a << 1);
	endcase
end
always @(comp_op or a_eq_b or a_lt_b) begin
	case(comp_op[2:0])	
		`OR1200_COP_SFEQ:
			flagcomp = a_eq_b;
		`OR1200_COP_SFNE:
			flagcomp = ~a_eq_b;
		`OR1200_COP_SFGT:
			flagcomp = ~(a_eq_b | a_lt_b);
		`OR1200_COP_SFGE:
			flagcomp = ~a_lt_b;
		`OR1200_COP_SFLT:
			flagcomp = a_lt_b;
		`OR1200_COP_SFLE:
			flagcomp = a_eq_b | a_lt_b;
		default:
			flagcomp = 1'b0;
	endcase
end
endmodule
module or1200_mult_mac(
	clk, rst,
	ex_freeze, id_macrc_op, macrc_op, a, b, mac_op, alu_op, result, mac_stall_r,
	spr_cs, spr_write, spr_addr, spr_dat_i, spr_dat_o
);
input				clk;
input				rst;
input				ex_freeze;
input				id_macrc_op;
input				macrc_op;
input	[`OR1200_OPERAND_WIDTH-1:0]		a;
input	[`OR1200_OPERAND_WIDTH-1:0]		b;
input	[`OR1200_MACOP_WIDTH-1:0]	mac_op;
input	[`OR1200_ALUOP_WIDTH-1:0]	alu_op;
output	[`OR1200_OPERAND_WIDTH-1:0]		result;
output				mac_stall_r;
input				spr_cs;
input				spr_write;
input	[31:0]			spr_addr;
input	[31:0]			spr_dat_i;
output	[31:0]			spr_dat_o;
reg	[`OR1200_OPERAND_WIDTH-1:0]		result;
reg	[2*`OR1200_OPERAND_WIDTH-1:0]		mul_prod_r;
wire	[2*`OR1200_OPERAND_WIDTH-1:0]		mul_prod;
wire	[`OR1200_MACOP_WIDTH-1:0]	mac_op;
reg	[`OR1200_MACOP_WIDTH-1:0]	mac_op_r1;
reg	[`OR1200_MACOP_WIDTH-1:0]	mac_op_r2;
reg	[`OR1200_MACOP_WIDTH-1:0]	mac_op_r3;
reg				mac_stall_r;
reg	[2*`OR1200_OPERAND_WIDTH-1:0]		mac_r;
wire	[`OR1200_OPERAND_WIDTH-1:0]		x;
wire	[`OR1200_OPERAND_WIDTH-1:0]		y;
wire				spr_maclo_we;
wire				spr_machi_we;
wire				alu_op_div_divu;
wire				alu_op_div;
reg				div_free;
wire	[`OR1200_OPERAND_WIDTH-1:0]		div_tmp;
reg	[5:0]			div_cntr;
assign spr_maclo_we = spr_cs & spr_write & spr_addr[`OR1200_MAC_ADDR];
assign spr_machi_we = spr_cs & spr_write & !spr_addr[`OR1200_MAC_ADDR];
assign spr_dat_o = spr_addr[`OR1200_MAC_ADDR] ? mac_r[31:0] : mac_r[63:32];
assign x = (alu_op_div & a[31]) ? ~a + 1'b1 : alu_op_div_divu | (alu_op == `OR1200_ALUOP_MUL) | (|mac_op) ? a : 32'h00000000;
assign y = (alu_op_div & b[31]) ? ~b + 1'b1 : alu_op_div_divu | (alu_op == `OR1200_ALUOP_MUL) | (|mac_op) ? b : 32'h00000000;
assign alu_op_div = (alu_op == `OR1200_ALUOP_DIV);
assign alu_op_div_divu = alu_op_div | (alu_op == `OR1200_ALUOP_DIVU);
assign div_tmp = mul_prod_r[63:32] - y;
always @(alu_op or mul_prod_r or mac_r or a or b)
	case(alu_op)	
		`OR1200_ALUOP_DIV:
			result = a[31] ^ b[31] ? ~mul_prod_r[31:0] + 1'b1 : mul_prod_r[31:0];
		`OR1200_ALUOP_DIVU:
		begin
			result = mul_prod_r[31:0];
		end
		`OR1200_ALUOP_MUL: begin
			result = mul_prod_r[31:0];
		end
		default:
		result = mac_r[31:0];
	endcase
assign mul_prod = x * y;
always @(posedge clk)
	if (rst) begin
		mul_prod_r <=  64'h0000000000000000;
		div_free <=  1'b1;
		div_cntr <=  6'b000000;
	end
	else if (|div_cntr) begin
		if (div_tmp[31])
			mul_prod_r <=  {mul_prod_r[62:0], 1'b0};
		else
			mul_prod_r <=  {div_tmp[30:0], mul_prod_r[31:0], 1'b1};
		div_cntr <=  div_cntr - 1'b1;
	end
	else if (alu_op_div_divu && div_free) begin
		mul_prod_r <=  {31'b0000000000000000000000000000000, x[31:0], 1'b0};
		div_cntr <=  6'b100000;
		div_free <=  1'b0;
	end
	else if (div_free | !ex_freeze) begin
		mul_prod_r <=  mul_prod[63:0];
		div_free <=  1'b1;
	end
always @(posedge clk)
	if (rst)
		mac_op_r1 <=  2'b00;
	else
		mac_op_r1 <=  mac_op;
always @(posedge clk)
	if (rst)
		mac_op_r2 <=  2'b00;
	else
		mac_op_r2 <=  mac_op_r1;
always @(posedge clk )
	if (rst)
		mac_op_r3 <=  2'b00;
	else
		mac_op_r3 <=  mac_op_r2;
always @(posedge clk)
	if (rst)
		mac_r <=  64'h0000000000000000;
	else if (spr_maclo_we)
		mac_r[31:0] <=  spr_dat_i;
	else if (spr_machi_we)
		mac_r[63:32] <=  spr_dat_i;
	else if (mac_op_r3 == `OR1200_MACOP_MAC)
		mac_r <=  mac_r + mul_prod_r;
	else if (mac_op_r3 == `OR1200_MACOP_MSB)
		mac_r <=  mac_r - mul_prod_r;
	else if (macrc_op & !ex_freeze)
		mac_r <=  64'h0000000000000000;
wire unused;
assign unused = |spr_addr;
always @( posedge clk)
	if (rst)
		mac_stall_r <=  1'b0;
	else
		mac_stall_r <=  (|mac_op | (|mac_op_r1) | (|mac_op_r2)) & id_macrc_op
				| (|div_cntr)
				;
endmodule
module or1200_sprs(
		clk, rst,
			addrbase, addrofs, dat_i, alu_op, 
		flagforw, flag_we, flag, cyforw, cy_we, carry,	to_wbmux,
		du_addr, du_dat_du, du_read,
		du_write, du_dat_cpu,
		spr_addr,spr_dat_pic, spr_dat_tt, spr_dat_pm,
		spr_dat_cfgr, spr_dat_rf, spr_dat_npc, spr_dat_ppc, spr_dat_mac,
		spr_dat_dmmu, spr_dat_immu, spr_dat_du, spr_dat_o, spr_cs, spr_we,
		 epcr_we, eear_we,esr_we, pc_we,epcr, eear, esr, except_started,
		sr_we, to_sr, sr,branch_op
);
input				clk; 		
input 				rst;		
input 				flagforw;	
input 				flag_we;	
output 				flag;		
input 				cyforw;		
input 				cy_we;		
output 				carry;		
input	[`OR1200_OPERAND_WIDTH-1:0] 		addrbase;	
input	[15:0] 			addrofs;	
input	[`OR1200_OPERAND_WIDTH-1:0]		dat_i;		
input	[`OR1200_ALUOP_WIDTH-1:0]	alu_op;		
input	[`OR1200_BRANCHOP_WIDTH-1:0]	branch_op;	
input	[`OR1200_OPERAND_WIDTH-1:0] 		epcr;		
input	[`OR1200_OPERAND_WIDTH-1:0] 		eear;		
input	[`OR1200_SR_WIDTH-1:0] 	esr;		
input 				except_started; 
output	[`OR1200_OPERAND_WIDTH-1:0]		to_wbmux;	
output				epcr_we;	
output				eear_we;	
output				esr_we;		
output				pc_we;		
output 				sr_we;		
output	[`OR1200_SR_WIDTH-1:0]	to_sr;		
output	[`OR1200_SR_WIDTH-1:0]	sr;		
input	[31:0]			spr_dat_cfgr;	
input	[31:0]			spr_dat_rf;	
input	[31:0]			spr_dat_npc;	
input	[31:0]			spr_dat_ppc;	
input	[31:0]			spr_dat_mac;	
input	[31:0]			spr_dat_pic;	
input	[31:0]			spr_dat_tt;	
input	[31:0]			spr_dat_pm;	
input	[31:0]			spr_dat_dmmu;	
input	[31:0]			spr_dat_immu;	
input	[31:0]			spr_dat_du;	
output	[31:0]			spr_addr;	
output	[31:0]			spr_dat_o;	
output	[31:0]			spr_cs;		
output				spr_we;		
input	[`OR1200_OPERAND_WIDTH-1:0]		du_addr;	
input	[`OR1200_OPERAND_WIDTH-1:0]		du_dat_du;	
input				du_read;	
input				du_write;	
output	[`OR1200_OPERAND_WIDTH-1:0]		du_dat_cpu;	
reg	[`OR1200_SR_WIDTH-1:0]		sr;		
reg				write_spr;	
reg				read_spr;	
reg	[`OR1200_OPERAND_WIDTH-1:0]		to_wbmux;	
wire				cfgr_sel;	
wire				rf_sel;		
wire				npc_sel;	
wire				ppc_sel;	
wire 				sr_sel;		
wire 				epcr_sel;	
wire 				eear_sel;	
wire 				esr_sel;	
wire	[31:0]			sys_data;	
wire				du_access;	
wire	[`OR1200_ALUOP_WIDTH-1:0]	sprs_op;	
reg	[31:0]			unqualified_cs;	
assign du_access = du_read | du_write;
assign sprs_op = du_write ? `OR1200_ALUOP_MTSR : du_read ? `OR1200_ALUOP_MFSR : alu_op;
assign spr_addr = du_access ? du_addr : addrbase | {16'h0000, addrofs};
assign spr_dat_o = du_write ? du_dat_du : dat_i;
assign du_dat_cpu = du_write ? du_dat_du : du_read ? to_wbmux : dat_i;
assign spr_we = du_write | write_spr;
assign spr_cs = unqualified_cs & {{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr}};
always @(spr_addr)
	case (spr_addr[15:11])	
		5'b00000: unqualified_cs = 32'b00000000000000000000000000000001;
		5'b00001: unqualified_cs = 32'b00000000000000000000000000000010;
		5'b00010: unqualified_cs = 32'b00000000000000000000000000000100;
		5'b00011: unqualified_cs = 32'b00000000000000000000000000001000;
		5'b00100: unqualified_cs = 32'b00000000000000000000000000010000;
		5'b00101: unqualified_cs = 32'b00000000000000000000000000100000;
		5'b00110: unqualified_cs = 32'b00000000000000000000000001000000;
		5'b00111: unqualified_cs = 32'b00000000000000000000000010000000;
		5'b01000: unqualified_cs = 32'b00000000000000000000000100000000;
		5'b01001: unqualified_cs = 32'b00000000000000000000001000000000;
		5'b01010: unqualified_cs = 32'b00000000000000000000010000000000;
		5'b01011: unqualified_cs = 32'b00000000000000000000100000000000;
		5'b01100: unqualified_cs = 32'b00000000000000000001000000000000;
		5'b01101: unqualified_cs = 32'b00000000000000000010000000000000;
		5'b01110: unqualified_cs = 32'b00000000000000000100000000000000;
		5'b01111: unqualified_cs = 32'b00000000000000001000000000000000;
		5'b10000: unqualified_cs = 32'b00000000000000010000000000000000;
		5'b10001: unqualified_cs = 32'b00000000000000100000000000000000;
		5'b10010: unqualified_cs = 32'b00000000000001000000000000000000;
		5'b10011: unqualified_cs = 32'b00000000000010000000000000000000;
		5'b10100: unqualified_cs = 32'b00000000000100000000000000000000;
		5'b10101: unqualified_cs = 32'b00000000001000000000000000000000;
		5'b10110: unqualified_cs = 32'b00000000010000000000000000000000;
		5'b10111: unqualified_cs = 32'b00000000100000000000000000000000;
		5'b11000: unqualified_cs = 32'b00000001000000000000000000000000;
		5'b11001: unqualified_cs = 32'b00000010000000000000000000000000;
		5'b11010: unqualified_cs = 32'b00000100000000000000000000000000;
		5'b11011: unqualified_cs = 32'b00001000000000000000000000000000;
		5'b11100: unqualified_cs = 32'b00010000000000000000000000000000;
		5'b11101: unqualified_cs = 32'b00100000000000000000000000000000;
		5'b11110: unqualified_cs = 32'b01000000000000000000000000000000;
		5'b11111: unqualified_cs = 32'b10000000000000000000000000000000;
	endcase
assign to_sr[`OR1200_SR_FO:`OR1200_SR_OV] =
		(branch_op == `OR1200_BRANCHOP_RFE) ? esr[`OR1200_SR_FO:`OR1200_SR_OV] :
		(write_spr && sr_sel) ? {1'b1, spr_dat_o[`OR1200_SR_FO-1:`OR1200_SR_OV]}:
		sr[`OR1200_SR_FO:`OR1200_SR_OV];
assign to_sr[`OR1200_SR_CY] =
		(branch_op == `OR1200_BRANCHOP_RFE) ? esr[`OR1200_SR_CY] :
		cy_we ? cyforw :
		(write_spr && sr_sel) ? spr_dat_o[`OR1200_SR_CY] :
		sr[`OR1200_SR_CY];
assign to_sr[`OR1200_SR_F] =
		(branch_op == `OR1200_BRANCHOP_RFE) ? esr[`OR1200_SR_F] :
		flag_we ? flagforw :
		(write_spr && sr_sel) ? spr_dat_o[`OR1200_SR_F] :
		sr[`OR1200_SR_F];
assign to_sr[`OR1200_SR_CE:`OR1200_SR_SM] =
		(branch_op == `OR1200_BRANCHOP_RFE) ? esr[`OR1200_SR_CE:`OR1200_SR_SM] :
		(write_spr && sr_sel) ? spr_dat_o[`OR1200_SR_CE:`OR1200_SR_SM]:
		sr[`OR1200_SR_CE:`OR1200_SR_SM];
assign cfgr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:4] == `OR1200_SPR_CFGR));
assign rf_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:5] == `OR1200_SPR_RF));
assign npc_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_NPC));
assign ppc_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_PPC));
assign sr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_SR));
assign epcr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_EPCR));
assign eear_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_EEAR));
assign esr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_ESR));
assign sr_we = (write_spr && sr_sel) | (branch_op == `OR1200_BRANCHOP_RFE) | flag_we | cy_we;
assign pc_we = (write_spr && (npc_sel | ppc_sel));
assign epcr_we = (write_spr && epcr_sel);
assign eear_we = (write_spr && eear_sel);
assign esr_we = (write_spr && esr_sel);
assign sys_data = (spr_dat_cfgr & {{read_spr & cfgr_sel}}) |
		  (spr_dat_rf & {{read_spr & rf_sel}}) |
		  (spr_dat_npc & {{read_spr & npc_sel}}) |
		  (spr_dat_ppc & {{read_spr & ppc_sel}}) |
		  ({{{16'b0000000000000000}},sr} & {{read_spr & sr_sel}}) |
		  (epcr & {{read_spr & epcr_sel}}) |
		  (eear & {{read_spr & eear_sel}}) |
		  ({{{16'b0000000000000000}},esr} & {{read_spr & esr_sel}});
assign flag = sr[`OR1200_SR_F];
assign carry = sr[`OR1200_SR_CY];
always @(posedge clk)
	if (rst)
		sr <=  {1'b1, `OR1200_SR_EPH_DEF, {{13'b0000000000000}}, 1'b1};
	else if (except_started) begin
		sr[`OR1200_SR_SM]  <=  1'b1;
		sr[`OR1200_SR_TEE] <=  1'b0;
		sr[`OR1200_SR_IEE] <=  1'b0;
		sr[`OR1200_SR_DME] <=  1'b0;
		sr[`OR1200_SR_IME] <=  1'b0;
	end
	else if (sr_we)
		sr <=  to_sr[`OR1200_SR_WIDTH-1:0];
always @(sprs_op or spr_addr or sys_data or spr_dat_mac or spr_dat_pic or spr_dat_pm or
	spr_dat_dmmu or spr_dat_immu or spr_dat_du or spr_dat_tt) begin
	case (sprs_op)	
		`OR1200_ALUOP_MTSR : begin
			write_spr = 1'b1;
			read_spr = 1'b0;
			to_wbmux = 32'b00000000000000000000000000000000;
		end
		`OR1200_ALUOP_MFSR : begin
			case (spr_addr[15:11]) 
				`OR1200_SPR_GROUP_TT:
					to_wbmux = spr_dat_tt;
				`OR1200_SPR_GROUP_PIC:
					to_wbmux = spr_dat_pic;
				`OR1200_SPR_GROUP_PM:
					to_wbmux = spr_dat_pm;
				`OR1200_SPR_GROUP_DMMU:
					to_wbmux = spr_dat_dmmu;
				`OR1200_SPR_GROUP_IMMU:
					to_wbmux = spr_dat_immu;
				`OR1200_SPR_GROUP_MAC:
					to_wbmux = spr_dat_mac;
				`OR1200_SPR_GROUP_DU:
					to_wbmux = spr_dat_du;
				`OR1200_SPR_GROUP_SYS:
					to_wbmux = sys_data;
				default:
					to_wbmux = 32'b00000000000000000000000000000000;
			endcase
			write_spr = 1'b0;
			read_spr = 1'b1;
		end
		default : begin
			write_spr = 1'b0;
			read_spr = 1'b0;
			to_wbmux = 32'b00000000000000000000000000000000;
		end
	endcase
end
endmodule
`define OR1200_NO_FREEZE	3'b000
`define OR1200_FREEZE_BYDC	3'b001
`define OR1200_FREEZE_BYMULTICYCLE	3'b010
`define OR1200_WAIT_LSU_TO_FINISH	3'b011
`define OR1200_WAIT_IC			3'b100
module or1200_freeze(
	clk, rst,
	multicycle, flushpipe, extend_flush, lsu_stall, if_stall,
	lsu_unstall,  
	force_dslot_fetch, abort_ex, du_stall,  mac_stall,
	genpc_freeze, if_freeze, id_freeze, ex_freeze, wb_freeze,
	icpu_ack_i, icpu_err_i
);
input				clk;
input				rst;
input	[`OR1200_MULTICYCLE_WIDTH-1:0]	multicycle;
input				flushpipe;
input				extend_flush;
input				lsu_stall;
input				if_stall;
input				lsu_unstall;
input				force_dslot_fetch;
input				abort_ex;
input				du_stall;
input				mac_stall;
output				genpc_freeze;
output				if_freeze;
output				id_freeze;
output				ex_freeze;
output				wb_freeze;
input				icpu_ack_i;
input				icpu_err_i;
wire				multicycle_freeze;
reg	[`OR1200_MULTICYCLE_WIDTH-1:0]	multicycle_cnt;
reg				flushpipe_r;
assign genpc_freeze = du_stall | flushpipe_r;
assign if_freeze = id_freeze | extend_flush;
assign id_freeze = (lsu_stall | (~lsu_unstall & if_stall) | multicycle_freeze | force_dslot_fetch) | du_stall | mac_stall;
assign ex_freeze = wb_freeze;
assign wb_freeze = (lsu_stall | (~lsu_unstall & if_stall) | multicycle_freeze) | du_stall | mac_stall | abort_ex;
always @(posedge clk )
	if (rst)
		flushpipe_r <=  1'b0;
	else if (icpu_ack_i | icpu_err_i)
		flushpipe_r <=  flushpipe;
	else if (!flushpipe)
		flushpipe_r <=  1'b0;
assign multicycle_freeze = |multicycle_cnt;
always @(posedge clk )
	if (rst)
		multicycle_cnt <=  2'b00;
	else if (|multicycle_cnt)
		multicycle_cnt <=  multicycle_cnt - 2'b01;
	else if (|multicycle & !ex_freeze)
		multicycle_cnt <=  multicycle;
endmodule
`define OR1200_EXCEPTFSM_WIDTH 3
`define OR1200_EXCEPTFSM_IDLE	3'b000
`define OR1200_EXCEPTFSM_FLU1 	3'b001
`define OR1200_EXCEPTFSM_FLU2 	3'b010
`define OR1200_EXCEPTFSM_FLU3 	3'b011
`define OR1200_EXCEPTFSM_FLU5 	3'b101
`define OR1200_EXCEPTFSM_FLU4 	3'b100
module or1200_except(
	clk, rst, 
	sig_ibuserr, sig_dbuserr, sig_illegal, sig_align, sig_range, sig_dtlbmiss, sig_dmmufault,
	sig_int, sig_syscall, sig_trap, sig_itlbmiss, sig_immufault, sig_tick,
	branch_taken,icpu_ack_i, icpu_err_i, dcpu_ack_i, dcpu_err_i,
	genpc_freeze, id_freeze, ex_freeze, wb_freeze, if_stall,
	if_pc, id_pc, lr_sav, flushpipe, extend_flush, except_type, except_start,
	except_started, except_stop, ex_void,
	spr_dat_ppc, spr_dat_npc, datain, du_dsr, epcr_we, eear_we, esr_we, pc_we, epcr, eear,
	esr, lsu_addr, sr_we, to_sr, sr, abort_ex
);
input				clk;
input				rst;
input				sig_ibuserr;
input				sig_dbuserr;
input				sig_illegal;
input				sig_align;
input				sig_range;
input				sig_dtlbmiss;
input				sig_dmmufault;
input				sig_int;
input				sig_syscall;
input				sig_trap;
input				sig_itlbmiss;
input				sig_immufault;
input				sig_tick;
input				branch_taken;
input				genpc_freeze;
input				id_freeze;
input				ex_freeze;
input				wb_freeze;
input				if_stall;
input	[31:0]			if_pc;
output	[31:0]			id_pc;
output	[31:2]			lr_sav;
input	[31:0]			datain;
input   [`OR1200_DU_DSR_WIDTH-1:0]     du_dsr;
input				epcr_we;
input				eear_we;
input				esr_we;
input				pc_we;
output	[31:0]			epcr;
output	[31:0]			eear;
output	[`OR1200_SR_WIDTH-1:0]	esr;
input	[`OR1200_SR_WIDTH-1:0]	to_sr;
input				sr_we;
input	[`OR1200_SR_WIDTH-1:0]	sr;
input	[31:0]			lsu_addr;
output				flushpipe;
output				extend_flush;
output	[`OR1200_EXCEPT_WIDTH-1:0]	except_type;
output				except_start;
output				except_started;
output	[12:0]			except_stop;
input				ex_void;
output	[31:0]			spr_dat_ppc;
output	[31:0]			spr_dat_npc;
output				abort_ex;
input				icpu_ack_i;
input				icpu_err_i;
input				dcpu_ack_i;
input				dcpu_err_i;
reg	[`OR1200_EXCEPT_WIDTH-1:0]	except_type;
reg	[31:0]			id_pc;
reg	[31:0]			ex_pc;
reg	[31:0]			wb_pc;
reg	[31:0]			epcr;
reg	[31:0]			eear;
reg	[`OR1200_SR_WIDTH-1:0]		esr;
reg	[2:0]			id_exceptflags;
reg	[2:0]			ex_exceptflags;
reg	[`OR1200_EXCEPTFSM_WIDTH-1:0]	state;
reg				extend_flush;
reg				extend_flush_last;
reg				ex_dslot;
reg				delayed1_ex_dslot;
reg				delayed2_ex_dslot;
wire				except_started;
wire	[12:0]			except_trig;
wire				except_flushpipe;
reg	[2:0]			delayed_iee;
reg	[2:0]			delayed_tee;
wire				int_pending;
wire				tick_pending;
assign except_started = extend_flush & except_start;
assign lr_sav = ex_pc[31:2];
assign spr_dat_ppc = wb_pc;
assign spr_dat_npc = ex_void ? id_pc : ex_pc;
assign except_start = (except_type != 4'b0000) & extend_flush;
assign int_pending = sig_int & sr[`OR1200_SR_IEE] & delayed_iee[2] & ~ex_freeze & ~branch_taken & ~ex_dslot & ~sr_we;
assign tick_pending = sig_tick & sr[`OR1200_SR_TEE] & ~ex_freeze & ~branch_taken & ~ex_dslot & ~sr_we;
assign abort_ex = sig_dbuserr | sig_dmmufault | sig_dtlbmiss | sig_align | sig_illegal;		
assign except_trig = {
			tick_pending		& ~du_dsr[`OR1200_DU_DSR_TTE],
			int_pending 		& ~du_dsr[`OR1200_DU_DSR_IE],
			ex_exceptflags[1]	& ~du_dsr[`OR1200_DU_DSR_IME],
			ex_exceptflags[0]	& ~du_dsr[`OR1200_DU_DSR_IPFE],
			ex_exceptflags[2]	& ~du_dsr[`OR1200_DU_DSR_BUSEE],
			sig_illegal		& ~du_dsr[`OR1200_DU_DSR_IIE],
			sig_align		& ~du_dsr[`OR1200_DU_DSR_AE],
			sig_dtlbmiss		& ~du_dsr[`OR1200_DU_DSR_DME],
			sig_dmmufault		& ~du_dsr[`OR1200_DU_DSR_DPFE],
			sig_dbuserr		& ~du_dsr[`OR1200_DU_DSR_BUSEE],
			sig_range		& ~du_dsr[`OR1200_DU_DSR_RE],
			sig_trap		& ~du_dsr[`OR1200_DU_DSR_TE] & ~ex_freeze,
			sig_syscall		& ~du_dsr[`OR1200_DU_DSR_SCE] & ~ex_freeze
		};
assign except_stop = {
			tick_pending		& du_dsr[`OR1200_DU_DSR_TTE],
			int_pending 		& du_dsr[`OR1200_DU_DSR_IE],
			ex_exceptflags[1]	& du_dsr[`OR1200_DU_DSR_IME],
			ex_exceptflags[0]	& du_dsr[`OR1200_DU_DSR_IPFE],
			ex_exceptflags[2]	& du_dsr[`OR1200_DU_DSR_BUSEE],
			sig_illegal		& du_dsr[`OR1200_DU_DSR_IIE],
			sig_align		& du_dsr[`OR1200_DU_DSR_AE],
			sig_dtlbmiss		& du_dsr[`OR1200_DU_DSR_DME],
			sig_dmmufault		& du_dsr[`OR1200_DU_DSR_DPFE],
			sig_dbuserr		& du_dsr[`OR1200_DU_DSR_BUSEE],
			sig_range		& du_dsr[`OR1200_DU_DSR_RE],
			sig_trap		& du_dsr[`OR1200_DU_DSR_TE] & ~ex_freeze,
			sig_syscall		& du_dsr[`OR1200_DU_DSR_SCE] & ~ex_freeze
		};
always @(posedge clk ) begin
	if (rst) begin
		id_pc <=  32'b00000000000000000000000000000000;
		id_exceptflags <=  3'b000;
	end
	else if (flushpipe) begin
		id_pc <=  32'h00000000;
		id_exceptflags <=  3'b000;
	end
	else if (!id_freeze) begin
		id_pc <=  if_pc;
		id_exceptflags <=  { sig_ibuserr, sig_itlbmiss, sig_immufault };
	end
end
always @(posedge clk)
	if (rst)
		delayed_iee <=  3'b000;
	else if (!sr[`OR1200_SR_IEE])
		delayed_iee <=  3'b000;
	else
		delayed_iee <=  {delayed_iee[1:0], 1'b1};
always @( posedge clk)
	if (rst)
		delayed_tee <=  3'b000;
	else if (!sr[`OR1200_SR_TEE])
		delayed_tee <=  3'b000;
	else
		delayed_tee <=  {delayed_tee[1:0], 1'b1};
always @(posedge clk ) begin
	if (rst) begin
		ex_dslot <=  1'b0;
		ex_pc <=  32'd0;
		ex_exceptflags <=  3'b000;
		delayed1_ex_dslot <=  1'b0;
		delayed2_ex_dslot <=  1'b0;
	end
	else if (flushpipe) begin
		ex_dslot <=  1'b0;
		ex_pc <=  32'h00000000;
		ex_exceptflags <=  3'b000;
		delayed1_ex_dslot <=  1'b0;
		delayed2_ex_dslot <=  1'b0;
	end
	else if (!ex_freeze & id_freeze) begin
		ex_dslot <=  1'b0;
		ex_pc <=  id_pc;
		ex_exceptflags <=  3'b000;
		delayed1_ex_dslot <=  ex_dslot;
		delayed2_ex_dslot <=  delayed1_ex_dslot;
	end
	else if (!ex_freeze) begin
		ex_dslot <=  branch_taken;
		ex_pc <=  id_pc;
		ex_exceptflags <=  id_exceptflags;
		delayed1_ex_dslot <=  ex_dslot;
		delayed2_ex_dslot <=  delayed1_ex_dslot;
	end
end
always @(posedge clk ) begin
	if (rst) begin
		wb_pc <=  32'b00000000000000000000000000000000;
	end
	else if (!wb_freeze) begin
		wb_pc <=  ex_pc;
	end
end
assign flushpipe = except_flushpipe | pc_we | extend_flush;
assign except_flushpipe = |except_trig & ~|state;
always @(posedge clk ) begin
	if (rst) begin
		state <=  `OR1200_EXCEPTFSM_IDLE;
		except_type <=  4'b0000;
		extend_flush <=  1'b0;
		epcr <=  32'b00000000000000000000000000000000;
		eear <=  32'b00000000000000000000000000000000;
		esr <=  {{1'b1, 1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0}, {1'b1}};
		extend_flush_last <=  1'b0;
	end
	else begin
		case (state)
			`OR1200_EXCEPTFSM_IDLE:
				if (except_flushpipe) begin
					state <=  `OR1200_EXCEPTFSM_FLU1;
					extend_flush <=  1'b1;
					esr <=  sr_we ? to_sr : sr;
					if (except_trig[12] == 1)
					begin
						except_type <=  `OR1200_EXCEPT_TICK;
					   epcr <=  ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
					end
					else if (except_trig[12] == 0 && except_trig[11] == 0)
					begin
						except_type <=  `OR1200_EXCEPT_INT;
						epcr <=  ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
					end
					else if (except_trig[12] == 0 && except_trig[11] == 0 && except_trig[10] == 1)
					begin
						except_type <=  `OR1200_EXCEPT_ITLBMISS;
						eear <=  ex_dslot ? ex_pc : ex_pc;
						epcr <=  ex_dslot ? wb_pc : ex_pc;
					end
					else
					begin  
						except_type <=  4'b0000;
					end					
				end
				else if (pc_we) begin
					state <=  `OR1200_EXCEPTFSM_FLU1;
					extend_flush <=  1'b1;
				end
				else begin
					if (epcr_we)
						epcr <=  datain;
					if (eear_we)
						eear <=  datain;
					if (esr_we)
						esr <=  {1'b1, datain[`OR1200_SR_WIDTH-2:0]};
				end
			`OR1200_EXCEPTFSM_FLU1:
				if (icpu_ack_i | icpu_err_i | genpc_freeze)
					state <=  `OR1200_EXCEPTFSM_FLU2;
			`OR1200_EXCEPTFSM_FLU2:
					state <=  `OR1200_EXCEPTFSM_FLU3;
			`OR1200_EXCEPTFSM_FLU3:
					begin
						state <=  `OR1200_EXCEPTFSM_FLU4;
					end
			`OR1200_EXCEPTFSM_FLU4: begin
					state <=  `OR1200_EXCEPTFSM_FLU5;
					extend_flush <=  1'b0;
					extend_flush_last <=  1'b0; 
				end
			default: begin
				if (!if_stall && !id_freeze) begin
					state <=  `OR1200_EXCEPTFSM_IDLE;
					except_type <=  4'b0000;
					extend_flush_last <=  1'b0;
				end
			end
		endcase
	end
end
wire unused;
assign unused = sig_range | sig_syscall | sig_trap | dcpu_ack_i| dcpu_err_i | du_dsr | lsu_addr;
endmodule
module or1200_cfgr(
	spr_addr, spr_dat_o
);
input	[31:0]	spr_addr;	
output	[31:0]	spr_dat_o;	
reg	[31:0]	spr_dat_o;	
always @(spr_addr)
	if (~|spr_addr[31:4])
		case(spr_addr[3:0])		
			`OR1200_SPRGRP_SYS_VR: begin
				spr_dat_o[5:0] = `OR1200_VR_REV;
				spr_dat_o[16:6] = `OR1200_VR_RES1;
				spr_dat_o[23:17] = `OR1200_VR_CFG;
				spr_dat_o[31:24] = `OR1200_VR_VER;
			end
			`OR1200_SPRGRP_SYS_UPR: begin
				spr_dat_o[`OR1200_UPR_UP_BITS] = `OR1200_UPR_UP;
				spr_dat_o[`OR1200_UPR_DCP_BITS] = `OR1200_UPR_DCP;
				spr_dat_o[`OR1200_UPR_ICP_BITS] = `OR1200_UPR_ICP;
				spr_dat_o[`OR1200_UPR_DMP_BITS] = `OR1200_UPR_DMP;
				spr_dat_o[`OR1200_UPR_IMP_BITS] = `OR1200_UPR_IMP;
				spr_dat_o[`OR1200_UPR_MP_BITS] = `OR1200_UPR_MP;
				spr_dat_o[`OR1200_UPR_DUP_BITS] = `OR1200_UPR_DUP;
				spr_dat_o[`OR1200_UPR_PCUP_BITS] = `OR1200_UPR_PCUP;
				spr_dat_o[`OR1200_UPR_PMP_BITS] = `OR1200_UPR_PMP;
				spr_dat_o[`OR1200_UPR_PICP_BITS] = `OR1200_UPR_PICP;
				spr_dat_o[`OR1200_UPR_TTP_BITS] = `OR1200_UPR_TTP;
				spr_dat_o[23:11] = `OR1200_UPR_RES1;
				spr_dat_o[31:24] = `OR1200_UPR_CUP;
			end
			`OR1200_SPRGRP_SYS_CPUCFGR: begin
				spr_dat_o[3:0] = `OR1200_CPUCFGR_NSGF;
				spr_dat_o[`OR1200_CPUCFGR_HGF_BITS] = `OR1200_CPUCFGR_HGF;
				spr_dat_o[`OR1200_CPUCFGR_OB32S_BITS] = `OR1200_CPUCFGR_OB32S;
				spr_dat_o[`OR1200_CPUCFGR_OB64S_BITS] = `OR1200_CPUCFGR_OB64S;
				spr_dat_o[`OR1200_CPUCFGR_OF32S_BITS] = `OR1200_CPUCFGR_OF32S;
				spr_dat_o[`OR1200_CPUCFGR_OF64S_BITS] = `OR1200_CPUCFGR_OF64S;
				spr_dat_o[`OR1200_CPUCFGR_OV64S_BITS] = `OR1200_CPUCFGR_OV64S;
				spr_dat_o[31:10] = `OR1200_CPUCFGR_RES1;
			end
			`OR1200_SPRGRP_SYS_DMMUCFGR: begin
				spr_dat_o[1:0] = `OR1200_DMMUCFGR_NTW;
				spr_dat_o[4:2] = `OR1200_DMMUCFGR_NTS;
				spr_dat_o[7:5] = `OR1200_DMMUCFGR_NAE;
				spr_dat_o[`OR1200_DMMUCFGR_CRI_BITS] = `OR1200_DMMUCFGR_CRI;
				spr_dat_o[`OR1200_DMMUCFGR_PRI_BITS] = `OR1200_DMMUCFGR_PRI;
				spr_dat_o[`OR1200_DMMUCFGR_TEIRI_BITS] = `OR1200_DMMUCFGR_TEIRI;
				spr_dat_o[`OR1200_DMMUCFGR_HTR_BITS] = `OR1200_DMMUCFGR_HTR;
				spr_dat_o[31:12] = `OR1200_DMMUCFGR_RES1;
			end
			`OR1200_SPRGRP_SYS_IMMUCFGR: begin
				spr_dat_o[1:0] = `OR1200_IMMUCFGR_NTW;
				spr_dat_o[4:2] = `OR1200_IMMUCFGR_NTS;
				spr_dat_o[7:5] = `OR1200_IMMUCFGR_NAE;
				spr_dat_o[`OR1200_IMMUCFGR_CRI_BITS] = `OR1200_IMMUCFGR_CRI;
				spr_dat_o[`OR1200_IMMUCFGR_PRI_BITS] = `OR1200_IMMUCFGR_PRI;
				spr_dat_o[`OR1200_IMMUCFGR_TEIRI_BITS] = `OR1200_IMMUCFGR_TEIRI;
				spr_dat_o[`OR1200_IMMUCFGR_HTR_BITS] = `OR1200_IMMUCFGR_HTR;
				spr_dat_o[31:12] = `OR1200_IMMUCFGR_RES1;
			end
			`OR1200_SPRGRP_SYS_DCCFGR: begin
				spr_dat_o[2:0] = `OR1200_DCCFGR_NCW;
				spr_dat_o[6:3] = `OR1200_DCCFGR_NCS;
				spr_dat_o[`OR1200_DCCFGR_CBS_BITS] = `OR1200_DCCFGR_CBS;
				spr_dat_o[`OR1200_DCCFGR_CWS_BITS] = `OR1200_DCCFGR_CWS;
				spr_dat_o[`OR1200_DCCFGR_CCRI_BITS] = `OR1200_DCCFGR_CCRI;
				spr_dat_o[`OR1200_DCCFGR_CBIRI_BITS] = `OR1200_DCCFGR_CBIRI;
				spr_dat_o[`OR1200_DCCFGR_CBPRI_BITS] = `OR1200_DCCFGR_CBPRI;
				spr_dat_o[`OR1200_DCCFGR_CBLRI_BITS] = `OR1200_DCCFGR_CBLRI;
				spr_dat_o[`OR1200_DCCFGR_CBFRI_BITS] = `OR1200_DCCFGR_CBFRI;
				spr_dat_o[`OR1200_DCCFGR_CBWBRI_BITS] = `OR1200_DCCFGR_CBWBRI;
				spr_dat_o[31:15] = `OR1200_DCCFGR_RES1;
			end
			`OR1200_SPRGRP_SYS_ICCFGR: begin
				spr_dat_o[2:0] = `OR1200_ICCFGR_NCW;
				spr_dat_o[6:3] = `OR1200_ICCFGR_NCS;
				spr_dat_o[`OR1200_ICCFGR_CBS_BITS] = `OR1200_ICCFGR_CBS;
				spr_dat_o[`OR1200_ICCFGR_CWS_BITS] = `OR1200_ICCFGR_CWS;
				spr_dat_o[`OR1200_ICCFGR_CCRI_BITS] = `OR1200_ICCFGR_CCRI;
				spr_dat_o[`OR1200_ICCFGR_CBIRI_BITS] = `OR1200_ICCFGR_CBIRI;
				spr_dat_o[`OR1200_ICCFGR_CBPRI_BITS] = `OR1200_ICCFGR_CBPRI;
				spr_dat_o[`OR1200_ICCFGR_CBLRI_BITS] = `OR1200_ICCFGR_CBLRI;
				spr_dat_o[`OR1200_ICCFGR_CBFRI_BITS] = `OR1200_ICCFGR_CBFRI;
				spr_dat_o[`OR1200_ICCFGR_CBWBRI_BITS] = `OR1200_ICCFGR_CBWBRI;
				spr_dat_o[31:15] = `OR1200_ICCFGR_RES1;
			end
			`OR1200_SPRGRP_SYS_DCFGR: begin
				spr_dat_o[2:0] = `OR1200_DCFGR_NDP;
				spr_dat_o[3] = `OR1200_DCFGR_WPCI;
				spr_dat_o[31:4] = `OR1200_DCFGR_RES1;
			end
			default: spr_dat_o = 32'h00000000;
		endcase
endmodule
module or1200_wbmux(
	clk, rst,
	wb_freeze, rfwb_op,
	muxin_a, muxin_b, muxin_c, muxin_d,
	muxout, muxreg, muxreg_valid
);
input				clk;
input				rst;
input				wb_freeze;
input	[`OR1200_RFWBOP_WIDTH-1:0]	rfwb_op;
input	[32-1:0]		muxin_a;
input	[32-1:0]		muxin_b;
input	[32-1:0]		muxin_c;
input	[32-1:0]		muxin_d;
output	[32-1:0]		muxout;
output	[32-1:0]		muxreg;
output				muxreg_valid;
reg	[32-1:0]		muxout;
reg	[32-1:0]		muxreg;
reg				muxreg_valid;
always @(posedge clk) begin
	if (rst) begin
		muxreg <=  32'b00000000000000000000000000000000;
		muxreg_valid <=  1'b0;
	end
	else if (!wb_freeze) begin
		muxreg <=  muxout;
		muxreg_valid <=  rfwb_op[0];
	end
end
always @(muxin_a or muxin_b or muxin_c or muxin_d or rfwb_op) begin
	case(rfwb_op[`OR1200_RFWBOP_WIDTH-1:1]) 
		2'b00: muxout = muxin_a;
		2'b01: begin
			muxout = muxin_b;
		end
		2'b10: begin
			muxout = muxin_c;
		end
		2'b11: begin
			muxout = muxin_d + 32'b00000000000000000000000000001000;
		end
	endcase
end
endmodule
module or1200_lsu(
	addrbase, addrofs, lsu_op, lsu_datain, lsu_dataout, lsu_stall, lsu_unstall,
        du_stall, except_align, except_dtlbmiss, except_dmmufault, except_dbuserr,
	dcpu_adr_o, dcpu_cycstb_o, dcpu_we_o, dcpu_sel_o, dcpu_tag_o, dcpu_dat_o,
	dcpu_dat_i, dcpu_ack_i, dcpu_rty_i, dcpu_err_i, dcpu_tag_i
);
input	[31:0]			addrbase;
input	[31:0]			addrofs;
input	[`OR1200_LSUOP_WIDTH-1:0]	lsu_op;
input	[`OR1200_OPERAND_WIDTH-1:0]		lsu_datain;
output	[`OR1200_OPERAND_WIDTH-1:0]		lsu_dataout;
output				lsu_stall;
output				lsu_unstall;
input                           du_stall;
output				except_align;
output				except_dtlbmiss;
output				except_dmmufault;
output				except_dbuserr;
output	[31:0]			dcpu_adr_o;
output				dcpu_cycstb_o;
output				dcpu_we_o;
output	[3:0]			dcpu_sel_o;
output	[3:0]			dcpu_tag_o;
output	[31:0]			dcpu_dat_o;
input	[31:0]			dcpu_dat_i;
input				dcpu_ack_i;
input				dcpu_rty_i;
input				dcpu_err_i;
input	[3:0]			dcpu_tag_i;
reg	[3:0]			dcpu_sel_o;
assign lsu_stall = dcpu_rty_i & dcpu_cycstb_o;
assign lsu_unstall = dcpu_ack_i;
assign except_align = ((lsu_op == `OR1200_LSUOP_SH) | (lsu_op == `OR1200_LSUOP_LHZ) | (lsu_op == `OR1200_LSUOP_LHS)) & dcpu_adr_o[0]
		|  ((lsu_op == `OR1200_LSUOP_SW) | (lsu_op == `OR1200_LSUOP_LWZ) | (lsu_op == `OR1200_LSUOP_LWS)) & |dcpu_adr_o[1:0];
assign except_dtlbmiss = dcpu_err_i & (dcpu_tag_i == `OR1200_DTAG_TE);
assign except_dmmufault = dcpu_err_i & (dcpu_tag_i == `OR1200_DTAG_PE);
assign except_dbuserr = dcpu_err_i & (dcpu_tag_i == `OR1200_DTAG_BE);
assign dcpu_adr_o = addrbase + addrofs;
assign dcpu_cycstb_o = du_stall | lsu_unstall | except_align ? 1'b0 : |lsu_op;
assign dcpu_we_o = lsu_op[3];
assign dcpu_tag_o = dcpu_cycstb_o ? `OR1200_DTAG_ND : `OR1200_DTAG_IDLE;
always @(lsu_op or dcpu_adr_o)
	case({lsu_op, dcpu_adr_o[1:0]})
		{`OR1200_LSUOP_SB, 2'b00} : dcpu_sel_o = 4'b1000;
		{`OR1200_LSUOP_SB, 2'b01} : dcpu_sel_o = 4'b0100;
		{`OR1200_LSUOP_SB, 2'b10} : dcpu_sel_o = 4'b0010;
		{`OR1200_LSUOP_SB, 2'b11} : dcpu_sel_o = 4'b0001;
		{`OR1200_LSUOP_SH, 2'b00} : dcpu_sel_o = 4'b1100;
		{`OR1200_LSUOP_SH, 2'b10} : dcpu_sel_o = 4'b0011;
		{`OR1200_LSUOP_SW, 2'b00} : dcpu_sel_o = 4'b1111;
		{`OR1200_LSUOP_LBZ, 2'b00} : dcpu_sel_o = 4'b1000;
		{`OR1200_LSUOP_LBS, 2'b00} : dcpu_sel_o = 4'b1000;
		{`OR1200_LSUOP_LBZ, 2'b01}: dcpu_sel_o = 4'b0100;
		{`OR1200_LSUOP_LBS, 2'b01} : dcpu_sel_o = 4'b0100;
		{`OR1200_LSUOP_LBZ, 2'b10}: dcpu_sel_o = 4'b0010;
		{`OR1200_LSUOP_LBS, 2'b10} : dcpu_sel_o = 4'b0010;
		{`OR1200_LSUOP_LBZ, 2'b11}: dcpu_sel_o = 4'b0001;
		{`OR1200_LSUOP_LBS, 2'b11} : dcpu_sel_o = 4'b0001;
		{`OR1200_LSUOP_LHZ, 2'b00}: dcpu_sel_o = 4'b1100;
		{`OR1200_LSUOP_LHS, 2'b00} : dcpu_sel_o = 4'b1100;
		{`OR1200_LSUOP_LHZ, 2'b10}: dcpu_sel_o = 4'b0011;
		{`OR1200_LSUOP_LHS, 2'b10} : dcpu_sel_o = 4'b0011;
		{`OR1200_LSUOP_LWZ, 2'b00}: dcpu_sel_o = 4'b1111;
		{4'b1111, 2'b00} : dcpu_sel_o = 4'b1111;
		default : dcpu_sel_o = 4'b0000;
	endcase
or1200_mem2reg or1200_mem2reg(
	.addr(dcpu_adr_o[1:0]),
	.lsu_op(lsu_op),
	.memdata(dcpu_dat_i),
	.regdata(lsu_dataout)
);
or1200_reg2mem or1200_reg2mem(
        .addr(dcpu_adr_o[1:0]),
        .lsu_op(lsu_op),
        .regdata(lsu_datain),
        .memdata(dcpu_dat_o)
);
endmodule
module or1200_reg2mem(addr, lsu_op, regdata, memdata);
input	[1:0]			addr;
input	[`OR1200_LSUOP_WIDTH-1:0]	lsu_op;
input	[32-1:0]		regdata;
output	[32-1:0]		memdata;
reg	[7:0]			memdata_hh;
reg	[7:0]			memdata_hl;
reg	[7:0]			memdata_lh;
reg	[7:0]			memdata_ll;
assign memdata = {memdata_hh, memdata_hl, memdata_lh, memdata_ll};
always @(lsu_op or addr or regdata) begin
	case({lsu_op, addr[1:0]})	
		{`OR1200_LSUOP_SB, 2'b00} : memdata_hh = regdata[7:0];
		{`OR1200_LSUOP_SH, 2'b00} : memdata_hh = regdata[15:8];
		default : memdata_hh = regdata[31:24];
	endcase
end
always @(lsu_op or addr or regdata) begin
	case({lsu_op, addr[1:0]})	
		{`OR1200_LSUOP_SW, 2'b00} : memdata_hl = regdata[23:16];
		default : memdata_hl = regdata[7:0];
	endcase
end
always @(lsu_op or addr or regdata) begin
	case({lsu_op, addr[1:0]})	
		{`OR1200_LSUOP_SB, 2'b10} : memdata_lh = regdata[7:0];
		default : memdata_lh = regdata[15:8];
	endcase
end
always @(regdata)
	memdata_ll = regdata[7:0];
endmodule
module or1200_mem2reg(addr, lsu_op, memdata, regdata);
input	[1:0]			addr;
input	[`OR1200_LSUOP_WIDTH-1:0]	lsu_op;
input	[32-1:0]		memdata;
output	[32-1:0]		regdata;
wire	[32-1:0]		regdata;
reg	[7:0]			regdata_hh;
reg	[7:0]			regdata_hl;
reg	[7:0]			regdata_lh;
reg	[7:0]			regdata_ll;
reg	[32-1:0]		aligned;
reg	[3:0]			sel_byte0, sel_byte1,
				sel_byte2, sel_byte3;
assign regdata = {regdata_hh, regdata_hl, regdata_lh, regdata_ll};
always @(addr or lsu_op) begin
	case({lsu_op[2:0], addr})	
		{3'b011, 2'b00}:			
			sel_byte0 = `OR1200_M2R_BYTE3;	
		{3'b011, 2'b01}:	
sel_byte0 = `OR1200_M2R_BYTE2;		
		{3'b101, 2'b00}:			
			sel_byte0 = `OR1200_M2R_BYTE2;	
		{3'b011, 2'b10}:			
			sel_byte0 = `OR1200_M2R_BYTE1;	
		default:				
			sel_byte0 = `OR1200_M2R_BYTE0;	
	endcase
end
always @(addr or lsu_op) begin
	case({lsu_op[2:0], addr})	
		{3'b010, 2'b00}:			
			sel_byte1 = `OR1200_M2R_ZERO;	
		{3'b011, 2'b00}:			
			sel_byte1 = `OR1200_M2R_EXTB3;	
		{3'b011, 2'b01}:			
			sel_byte1 = `OR1200_M2R_EXTB2;	
		{3'b011, 2'b10}:			
			sel_byte1 = `OR1200_M2R_EXTB1;	
		{3'b011, 2'b11}:			
			sel_byte1 = `OR1200_M2R_EXTB0;	
		{3'b100, 2'b00}:			
			sel_byte1 = `OR1200_M2R_BYTE3;	
		default:				
			sel_byte1 = `OR1200_M2R_BYTE1;	
	endcase
end
always @(addr or lsu_op) begin
	case({lsu_op[2:0], addr})	
		{3'b010, 2'b00}:	
sel_byte2 = `OR1200_M2R_ZERO;			
		{3'b100, 2'b00}:			
			sel_byte2 = `OR1200_M2R_ZERO;	
		{3'b011, 2'b00}:	
			sel_byte2 = `OR1200_M2R_EXTB3;	
		{3'b101, 2'b00}:			
			sel_byte2 = `OR1200_M2R_EXTB3;	
		{3'b011, 2'b01}:			
			sel_byte2 = `OR1200_M2R_EXTB2;	
		{3'b011, 2'b10}:	
	sel_byte2 = `OR1200_M2R_EXTB1;	
		{3'b101, 2'b10}:			
			sel_byte2 = `OR1200_M2R_EXTB1;	
		{3'b011, 2'b11}:			
			sel_byte2 = `OR1200_M2R_EXTB0;	
		default:				
			sel_byte2 = `OR1200_M2R_BYTE2;	
	endcase
end
always @(addr or lsu_op) begin
	case({lsu_op[2:0], addr}) 
		{3'b010, 2'b00}:
			sel_byte3 = `OR1200_M2R_ZERO;	
		{3'b100, 2'b00}:			
			sel_byte3 = `OR1200_M2R_ZERO;	
		{3'b011, 2'b00}:
sel_byte3 = `OR1200_M2R_EXTB3;	
		{3'b101, 2'b00}:			
			sel_byte3 = `OR1200_M2R_EXTB3;	
		{3'b011, 2'b01}:			
			sel_byte3 = `OR1200_M2R_EXTB2;	
		{3'b011, 2'b10}:
			sel_byte3 = `OR1200_M2R_EXTB1;	
		{3'b101, 2'b10}:			
			sel_byte3 = `OR1200_M2R_EXTB1;	
		{3'b011, 2'b11}:			
			sel_byte3 = `OR1200_M2R_EXTB0;	
		default:				
			sel_byte3 = `OR1200_M2R_BYTE3;	
	endcase
end
always @(sel_byte0 or memdata)
 begin
		case(sel_byte0)
		`OR1200_M2R_BYTE0: begin
				regdata_ll = memdata[7:0];
			end
		`OR1200_M2R_BYTE1: begin
				regdata_ll = memdata[15:8];
			end
		`OR1200_M2R_BYTE2: begin
				regdata_ll = memdata[23:16];
			end
		default: begin
				regdata_ll = memdata[31:24];
			end
	endcase
end
always @(sel_byte1 or memdata) begin
	case(sel_byte1) 
		`OR1200_M2R_ZERO: begin
				regdata_lh = 8'h00;
			end
		`OR1200_M2R_BYTE1: begin
				regdata_lh = memdata[15:8];
			end
		`OR1200_M2R_BYTE3: begin
				regdata_lh = memdata[31:24];
			end
		`OR1200_M2R_EXTB0: begin
				regdata_lh = {{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]}};
			end
		`OR1200_M2R_EXTB1: begin
				regdata_lh = {{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]}};
			end
		`OR1200_M2R_EXTB2: begin
				regdata_lh = {{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]}};
			end
		default: begin
				regdata_lh = {{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]}};
			end
	endcase
end
always @(sel_byte2 or memdata) begin
	case(sel_byte2) 
		`OR1200_M2R_ZERO: begin
				regdata_hl = 8'h00;
			end
		`OR1200_M2R_BYTE2: begin
				regdata_hl = memdata[23:16];
			end
		`OR1200_M2R_EXTB0: begin
				regdata_hl = {{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]}};
			end
		`OR1200_M2R_EXTB1: begin
				regdata_hl =  {{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]}};
			end
		`OR1200_M2R_EXTB2: begin
				regdata_hl = {{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]}};
			end
		default: begin
				regdata_hl = {{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]}};
			end
	endcase
end
always @(sel_byte3 or memdata) begin
	case(sel_byte3) 
		`OR1200_M2R_ZERO: begin
				regdata_hh = 8'h00;
			end
		`OR1200_M2R_BYTE3: begin
				regdata_hh = memdata[31:24];
			end
		`OR1200_M2R_EXTB0: begin
				regdata_hh = {{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]}};
			end
		`OR1200_M2R_EXTB1: begin
				regdata_hh = {{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]}};
			end
		`OR1200_M2R_EXTB2: begin
				regdata_hh = {{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]}};
			end
		`OR1200_M2R_EXTB3: begin
				regdata_hh =  {{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]}};
			end
	endcase
end
always @(addr or memdata) begin
	case(addr) 
		2'b00:
			aligned = memdata;
		2'b01:
			aligned = {memdata[23:0], 8'b00000000};
		2'b10:
			aligned = {memdata[15:0], 16'b0000000000000000};
		2'b11:
			aligned = {memdata[7:0], 24'b000000000000000000000000};
	endcase
end
wire[8:0] unused_signal;
assign unused_signal = lsu_op;
endmodule
`define OR1200_DCFGR_NDP		3'h0	
`define OR1200_DCFGR_WPCI		1'b0	
`define OR1200_DCFGR_RES1		28'h0000000
`define OR1200_M2R_BYTE0 4'b0000
`define OR1200_M2R_BYTE1 4'b0001
`define OR1200_M2R_BYTE2 4'b0010
`define OR1200_M2R_BYTE3 4'b0011
`define OR1200_M2R_EXTB0 4'b0100
`define OR1200_M2R_EXTB1 4'b0101
`define OR1200_M2R_EXTB2 4'b0110
`define OR1200_M2R_EXTB3 4'b0111
`define OR1200_M2R_ZERO  4'b0000
`define OR1200_ICCFGR_NCW		3'h0	
`define OR1200_ICCFGR_NCS 9	
`define OR1200_ICCFGR_CBS 9	
`define OR1200_ICCFGR_CWS		1'b0	
`define OR1200_ICCFGR_CCRI		1'b1	
`define OR1200_ICCFGR_CBIRI		1'b1	
`define OR1200_ICCFGR_CBPRI		1'b0	
`define OR1200_ICCFGR_CBLRI		1'b0	
`define OR1200_ICCFGR_CBFRI		1'b1	
`define OR1200_ICCFGR_CBWBRI		1'b0	
`define OR1200_ICCFGR_RES1		17'h00000
`define OR1200_ICCFGR_CBS_BITS		7
`define OR1200_ICCFGR_CWS_BITS		8
`define OR1200_ICCFGR_CCRI_BITS		9
`define OR1200_ICCFGR_CBIRI_BITS	10
`define OR1200_ICCFGR_CBPRI_BITS	11
`define OR1200_ICCFGR_CBLRI_BITS	12
`define OR1200_ICCFGR_CBFRI_BITS	13
`define OR1200_ICCFGR_CBWBRI_BITS	14
`define OR1200_DCCFGR_NCW		3'h0	
`define OR1200_DCCFGR_NCS 9	
`define OR1200_DCCFGR_CBS 9	
`define OR1200_DCCFGR_CWS		1'b0	
`define OR1200_DCCFGR_CCRI		1'b1	
`define OR1200_DCCFGR_CBIRI		1'b1	
`define OR1200_DCCFGR_CBPRI		1'b0	
`define OR1200_DCCFGR_CBLRI		1'b0	
`define OR1200_DCCFGR_CBFRI		1'b1	
`define OR1200_DCCFGR_CBWBRI		1'b0	
`define OR1200_DCCFGR_RES1		17'h00000
`define OR1200_DCCFGR_CBS_BITS		7
`define OR1200_DCCFGR_CWS_BITS		8
`define OR1200_DCCFGR_CCRI_BITS		9
`define OR1200_DCCFGR_CBIRI_BITS	10
`define OR1200_DCCFGR_CBPRI_BITS	11
`define OR1200_DCCFGR_CBLRI_BITS	12
`define OR1200_DCCFGR_CBFRI_BITS	13
`define OR1200_DCCFGR_CBWBRI_BITS	14
`define OR1200_IMMUCFGR_NTW		2'h0	
`define OR1200_IMMUCFGR_NTS 3'b101	
`define OR1200_IMMUCFGR_NAE		3'h0	
`define OR1200_IMMUCFGR_CRI		1'b0	
`define OR1200_IMMUCFGR_PRI		1'b0	
`define OR1200_IMMUCFGR_TEIRI		1'b1	
`define OR1200_IMMUCFGR_HTR		1'b0	
`define OR1200_IMMUCFGR_RES1		20'h00000
`define OR1200_CPUCFGR_HGF_BITS	4
`define OR1200_CPUCFGR_OB32S_BITS	5
`define OR1200_CPUCFGR_OB64S_BITS	6
`define OR1200_CPUCFGR_OF32S_BITS	7
`define OR1200_CPUCFGR_OF64S_BITS	8
`define OR1200_CPUCFGR_OV64S_BITS	9
`define OR1200_CPUCFGR_NSGF		4'h0
`define OR1200_CPUCFGR_HGF		1'b0
`define OR1200_CPUCFGR_OB32S		1'b1
`define OR1200_CPUCFGR_OB64S		1'b0
`define OR1200_CPUCFGR_OF32S		1'b0
`define OR1200_CPUCFGR_OF64S		1'b0
`define OR1200_CPUCFGR_OV64S		1'b0
`define OR1200_CPUCFGR_RES1		22'h000000
`define OR1200_DMMUCFGR_CRI_BITS	8
`define OR1200_DMMUCFGR_PRI_BITS	9
`define OR1200_DMMUCFGR_TEIRI_BITS	10
`define OR1200_DMMUCFGR_HTR_BITS	11
`define OR1200_DMMUCFGR_NTW		2'h0	
`define OR1200_DMMUCFGR_NTS 3'b110	
`define OR1200_DMMUCFGR_NAE		3'h0	
`define OR1200_DMMUCFGR_CRI		1'b0	
`define OR1200_DMMUCFGR_PRI		1'b0	
`define OR1200_DMMUCFGR_TEIRI		1'b1	
`define OR1200_DMMUCFGR_HTR		1'b0	
`define OR1200_DMMUCFGR_RES1		20'h00000
`define OR1200_IMMUCFGR_CRI_BITS	8
`define OR1200_IMMUCFGR_PRI_BITS	9
`define OR1200_IMMUCFGR_TEIRI_BITS	10
`define OR1200_IMMUCFGR_HTR_BITS	11
`define OR1200_SPRGRP_SYS_VR		4'h0
`define OR1200_SPRGRP_SYS_UPR		4'h1
`define OR1200_SPRGRP_SYS_CPUCFGR	4'h2
`define OR1200_SPRGRP_SYS_DMMUCFGR	4'h3
`define OR1200_SPRGRP_SYS_IMMUCFGR	4'h4
`define OR1200_SPRGRP_SYS_DCCFGR	4'h5
`define OR1200_SPRGRP_SYS_ICCFGR	4'h6
`define OR1200_SPRGRP_SYS_DCFGR	4'h7
`define OR1200_VR_REV			6'h01
`define OR1200_VR_RES1			10'h000
`define OR1200_VR_CFG			8'h00
`define OR1200_VR_VER			8'h12
`define OR1200_UPR_UP_BITS		0
`define OR1200_UPR_DCP_BITS		1
`define OR1200_UPR_ICP_BITS		2
`define OR1200_UPR_DMP_BITS		3
`define OR1200_UPR_IMP_BITS		4
`define OR1200_UPR_MP_BITS		5
`define OR1200_UPR_DUP_BITS		6
`define OR1200_UPR_PCUP_BITS		7
`define OR1200_UPR_PMP_BITS		8
`define OR1200_UPR_PICP_BITS		9
`define OR1200_UPR_TTP_BITS		10
`define OR1200_UPR_RES1			13'h0000
`define OR1200_UPR_CUP			8'h00
`define OR1200_DU_DSR_WIDTH 14
`define OR1200_EXCEPT_UNUSED		3'hf
`define OR1200_EXCEPT_TRAP		3'he
`define OR1200_EXCEPT_BREAK		3'hd
`define OR1200_EXCEPT_SYSCALL		3'hc
`define OR1200_EXCEPT_RANGE		3'hb
`define OR1200_EXCEPT_ITLBMISS		3'ha
`define OR1200_EXCEPT_DTLBMISS		3'h9
`define OR1200_EXCEPT_INT		3'h8
`define OR1200_EXCEPT_ILLEGAL		3'h7
`define OR1200_EXCEPT_ALIGN		3'h6
`define OR1200_EXCEPT_TICK		3'h5
`define OR1200_EXCEPT_IPF		3'h4
`define OR1200_EXCEPT_DPF		3'h3
`define OR1200_EXCEPT_BUSERR		3'h2
`define OR1200_EXCEPT_RESET		3'h1
`define OR1200_EXCEPT_NONE		3'h0
`define OR1200_OPERAND_WIDTH		32
`define OR1200_REGFILE_ADDR_WIDTH	5
`define OR1200_ALUOP_WIDTH	4
`define OR1200_ALUOP_NOP	4'b000
`define OR1200_ALUOP_ADD	4'b0000
`define OR1200_ALUOP_ADDC	4'b0001
`define OR1200_ALUOP_SUB	4'b0010
`define OR1200_ALUOP_AND	4'b0011
`define OR1200_ALUOP_OR		4'b0100
`define OR1200_ALUOP_XOR	4'b0101
`define OR1200_ALUOP_MUL	4'b0110
`define OR1200_ALUOP_CUST5	4'b0111
`define OR1200_ALUOP_SHROT	4'b1000
`define OR1200_ALUOP_DIV	4'b1001
`define OR1200_ALUOP_DIVU	4'b1010
`define OR1200_ALUOP_IMM	4'b1011
`define OR1200_ALUOP_MOVHI	4'b1100
`define OR1200_ALUOP_COMP	4'b1101
`define OR1200_ALUOP_MTSR	4'b1110
`define OR1200_ALUOP_MFSR	4'b1111
`define OR1200_ALUOP_CMOV 4'b1110
`define OR1200_ALUOP_FF1  4'b1111
`define OR1200_MACOP_WIDTH	2
`define OR1200_MACOP_NOP	2'b00
`define OR1200_MACOP_MAC	2'b01
`define OR1200_MACOP_MSB	2'b10
`define OR1200_SHROTOP_WIDTH	2
`define OR1200_SHROTOP_NOP	2'b00
`define OR1200_SHROTOP_SLL	2'b00
`define OR1200_SHROTOP_SRL	2'b01
`define OR1200_SHROTOP_SRA	2'b10
`define OR1200_SHROTOP_ROR	2'b11
`define OR1200_MULTICYCLE_WIDTH	2
`define OR1200_ONE_CYCLE		2'b00
`define OR1200_TWO_CYCLES		2'b01
`define OR1200_SEL_WIDTH		2
`define OR1200_SEL_RF			2'b00
`define OR1200_SEL_IMM			2'b01
`define OR1200_SEL_EX_FORW		2'b10
`define OR1200_SEL_WB_FORW		2'b11
`define OR1200_BRANCHOP_WIDTH		3
`define OR1200_BRANCHOP_NOP		3'b000
`define OR1200_BRANCHOP_J		3'b001
`define OR1200_BRANCHOP_JR		3'b010
`define OR1200_BRANCHOP_BAL		3'b011
`define OR1200_BRANCHOP_BF		3'b100
`define OR1200_BRANCHOP_BNF		3'b101
`define OR1200_BRANCHOP_RFE		3'b110
`define OR1200_LSUOP_WIDTH		4
`define OR1200_LSUOP_NOP		4'b0000
`define OR1200_LSUOP_LBZ		4'b0010
`define OR1200_LSUOP_LBS		4'b0011
`define OR1200_LSUOP_LHZ		4'b0100
`define OR1200_LSUOP_LHS		4'b0101
`define OR1200_LSUOP_LWZ		4'b0110
`define OR1200_LSUOP_LWS		4'b0111
`define OR1200_LSUOP_LD		4'b0001
`define OR1200_LSUOP_SD		4'b1000
`define OR1200_LSUOP_SB		4'b1010
`define OR1200_LSUOP_SH		4'b1100
`define OR1200_LSUOP_SW		4'b1110
`define OR1200_FETCHOP_WIDTH		1
`define OR1200_FETCHOP_NOP		1'b0
`define OR1200_FETCHOP_LW		1'b1
`define OR1200_RFWBOP_WIDTH		3
`define OR1200_RFWBOP_NOP		3'b000
`define OR1200_RFWBOP_ALU		3'b001
`define OR1200_RFWBOP_LSU		3'b011
`define OR1200_RFWBOP_SPRS		3'b101
`define OR1200_RFWBOP_LR		3'b111
`define OR1200_COP_SFEQ       3'b000
`define OR1200_COP_SFNE       3'b001
`define OR1200_COP_SFGT       3'b010
`define OR1200_COP_SFGE       3'b011
`define OR1200_COP_SFLT       3'b100
`define OR1200_COP_SFLE       3'b101
`define OR1200_COP_X          3'b111
`define OR1200_SIGNED_COMPARE 3'b011
`define OR1200_COMPOP_WIDTH	4
`define OR1200_ITAG_IDLE	4'h0	
`define	OR1200_ITAG_NI		4'h1	
`define OR1200_ITAG_BE		4'hb	
`define OR1200_ITAG_PE		4'hc	
`define OR1200_ITAG_TE		4'hd	
`define OR1200_DTAG_IDLE	4'h0	
`define	OR1200_DTAG_ND		4'h1	
`define OR1200_DTAG_AE		4'ha	
`define OR1200_DTAG_BE		4'hb	
`define OR1200_DTAG_PE		4'hc	
`define OR1200_DTAG_TE		4'hd	
`define OR1200_DU_DSR_RSTE	0
`define OR1200_DU_DSR_BUSEE	1
`define OR1200_DU_DSR_DPFE	2
`define OR1200_DU_DSR_IPFE	3
`define OR1200_DU_DSR_TTE	4
`define OR1200_DU_DSR_AE	5
`define OR1200_DU_DSR_IIE	6
`define OR1200_DU_DSR_IE	7
`define OR1200_DU_DSR_DME	8
`define OR1200_DU_DSR_IME	9
`define OR1200_DU_DSR_RE	10
`define OR1200_DU_DSR_SCE	11
`define OR1200_DU_DSR_BE	12
`define OR1200_DU_DSR_TE	13
`define OR1200_OR32_J                 6'b000000
`define OR1200_OR32_JAL               6'b000001
`define OR1200_OR32_BNF               6'b000011
`define OR1200_OR32_BF                6'b000100
`define OR1200_OR32_NOP               6'b000101
`define OR1200_OR32_MOVHI             6'b000110
`define OR1200_OR32_XSYNC             6'b001000
`define OR1200_OR32_RFE               6'b001001
`define OR1200_OR32_JR                6'b010001
`define OR1200_OR32_JALR              6'b010010
`define OR1200_OR32_MACI              6'b010011
`define OR1200_OR32_LWZ               6'b100001
`define OR1200_OR32_LBZ               6'b100011
`define OR1200_OR32_LBS               6'b100100
`define OR1200_OR32_LHZ               6'b100101
`define OR1200_OR32_LHS               6'b100110
`define OR1200_OR32_ADDI              6'b100111
`define OR1200_OR32_ADDIC             6'b101000
`define OR1200_OR32_ANDI              6'b101001
`define OR1200_OR32_ORI               6'b101010
`define OR1200_OR32_XORI              6'b101011
`define OR1200_OR32_MULI              6'b101100
`define OR1200_OR32_MFSPR             6'b101101
`define OR1200_OR32_SH_ROTI 	      6'b101110
`define OR1200_OR32_SFXXI             6'b101111
`define OR1200_OR32_MTSPR             6'b110000
`define OR1200_OR32_MACMSB            6'b110001
`define OR1200_OR32_SW                6'b110101
`define OR1200_OR32_SB                6'b110110
`define OR1200_OR32_SH                6'b110111
`define OR1200_OR32_ALU               6'b111000
`define OR1200_OR32_SFXX              6'b111001
`define OR1200_OR32_CUST5             6'b111100
`define OR1200_EXCEPT_EPH0_P 20'h00000
`define OR1200_EXCEPT_EPH1_P 20'hF0000
`define OR1200_EXCEPT_V		   8'h00
`define OR1200_EXCEPT_WIDTH 4
`define OR1200_SPR_GROUP_SYS	5'b00000
`define OR1200_SPR_GROUP_DMMU	5'b00001
`define OR1200_SPR_GROUP_IMMU	5'b00010
`define OR1200_SPR_GROUP_DC	5'b00011
`define OR1200_SPR_GROUP_IC	5'b00100
`define OR1200_SPR_GROUP_MAC	5'b00101
`define OR1200_SPR_GROUP_DU	5'b00110
`define OR1200_SPR_GROUP_PM	5'b01000
`define OR1200_SPR_GROUP_PIC	5'b01001
`define OR1200_SPR_GROUP_TT	5'b01010
`define OR1200_SPR_CFGR		7'b0000000
`define OR1200_SPR_RF		6'b100000	
`define OR1200_SPR_NPC		11'b00000010000
`define OR1200_SPR_SR		11'b00000010001
`define OR1200_SPR_PPC		11'b00000010010
`define OR1200_SPR_EPCR		11'b00000100000
`define OR1200_SPR_EEAR		11'b00000110000
`define OR1200_SPR_ESR		11'b00001000000
`define OR1200_SR_WIDTH 16
`define OR1200_SR_SM   0
`define OR1200_SR_TEE  1
`define OR1200_SR_IEE  2
`define OR1200_SR_DCE  3
`define OR1200_SR_ICE  4
`define OR1200_SR_DME  5
`define OR1200_SR_IME  6
`define OR1200_SR_LEE  7
`define OR1200_SR_CE   8
`define OR1200_SR_F    9
`define OR1200_SR_CY   10	
`define OR1200_SR_OV   11	
`define OR1200_SR_OVE  12	
`define OR1200_SR_DSX  13	
`define OR1200_SR_EPH  14
`define OR1200_SR_FO   15
`define OR1200_SR_EPH_DEF	1'b0
`define OR1200_PM_PMR_DME 4
`define OR1200_PM_PMR_SME 5
`define OR1200_PM_PMR_DCGE 6
`define OR1200_PM_OFS_PMR 11'b0
`define OR1200_SPRGRP_PM 5'b01000
`define OR1200_PIC_INTS 20
`define OR1200_PIC_OFS_PICMR 2'b00
`define OR1200_PIC_OFS_PICSR 2'b10
`define OR1200_TT_OFS_TTMR 1'b0
`define OR1200_TT_OFS_TTCR 1'b1
`define OR1200_TTOFS_BITS 0
`define OR1200_TT_TTMR_IP 28
`define OR1200_TT_TTMR_IE 29
`define OR1200_MAC_ADDR		0	
`define OR1200_MAC_SHIFTBY	0	
`define OR1200_DTLB_TM_ADDR	7
`define	OR1200_DTLBMR_V_BITS	0
`define	OR1200_DTLBTR_CC_BITS	0
`define	OR1200_DTLBTR_CI_BITS	1
`define	OR1200_DTLBTR_WBC_BITS	2
`define	OR1200_DTLBTR_WOM_BITS	3
`define	OR1200_DTLBTR_A_BITS	4
`define	OR1200_DTLBTR_D_BITS	5
`define	OR1200_DTLBTR_URE_BITS	6
`define	OR1200_DTLBTR_UWE_BITS	7
`define	OR1200_DTLBTR_SRE_BITS	8
`define	OR1200_DTLBTR_SWE_BITS	9
`define	OR1200_DMMU_PS		13					
`define	OR1200_DTLB_INDXW	6							
`define OR1200_ITLB_TM_ADDR	7
`define	OR1200_ITLBMR_V_BITS	0
`define	OR1200_ITLBTR_CC_BITS	0
`define	OR1200_ITLBTR_CI_BITS	1
`define	OR1200_ITLBTR_WBC_BITS	2
`define	OR1200_ITLBTR_WOM_BITS	3
`define	OR1200_ITLBTR_A_BITS	4
`define	OR1200_ITLBTR_D_BITS	5
`define	OR1200_ITLBTR_SXE_BITS	6
`define	OR1200_ITLBTR_UXE_BITS	7
`define	OR1200_IMMU_PS 13					
`define	OR1200_ITLB_INDXW	6			
`define OR1200_IMMU_CI			1'b0
`define OR1200_ICLS		4
`define OR1200_DCLS		4
`define OR1200_DCSIZE			12			
`define	OR1200_DCTAG_W			21
`define OR1200_SB_LOG		2	
`define OR1200_SB_ENTRIES	4	
`define OR1200_QMEM_IADDR	32'h00800000
`define OR1200_QMEM_IMASK	32'hfff00000	
`define OR1200_QMEM_DADDR  32'h00800000
`define OR1200_QMEM_DMASK  32'hfff00000 
`define OR1200_SPRGRP_SYS_VR		4'h0
`define OR1200_SPRGRP_SYS_UPR		4'h1
`define OR1200_SPRGRP_SYS_CPUCFGR	4'h2
`define OR1200_SPRGRP_SYS_DMMUCFGR	4'h3
`define OR1200_SPRGRP_SYS_IMMUCFGR	4'h4
`define OR1200_SPRGRP_SYS_DCCFGR	4'h5
`define OR1200_SPRGRP_SYS_ICCFGR	4'h6
`define OR1200_SPRGRP_SYS_DCFGR	4'h7
`define OR1200_VR_REV			6'h01
`define OR1200_VR_RES1			10'h000
`define OR1200_VR_CFG			8'h00
`define OR1200_VR_VER			8'h12
`define OR1200_UPR_UP			1'b1
`define OR1200_UPR_DCP			1'b1
`define OR1200_UPR_ICP			1'b1
`define OR1200_UPR_DMP			1'b1
`define OR1200_UPR_IMP			1'b1
`define OR1200_UPR_MP			1'b1	
`define OR1200_UPR_DUP			1'b1
`define OR1200_UPR_PCUP			1'b0	
`define OR1200_UPR_PMP			1'b1
`define OR1200_UPR_PICP			1'b1
`define OR1200_UPR_TTP			1'b1
`define OR1200_UPR_RES1			13'h0000
`define OR1200_UPR_CUP			8'h00
`define OR1200_CPUCFGR_HGF_BITS	4
`define OR1200_CPUCFGR_OB32S_BITS	5
`define OR1200_CPUCFGR_OB64S_BITS	6
`define OR1200_CPUCFGR_OF32S_BITS	7
`define OR1200_CPUCFGR_OF64S_BITS	8
`define OR1200_CPUCFGR_OV64S_BITS	9
`define OR1200_CPUCFGR_NSGF		4'h0
`define OR1200_CPUCFGR_HGF		1'b0
`define OR1200_CPUCFGR_OB32S		1'b1
`define OR1200_CPUCFGR_OB64S		1'b0
`define OR1200_CPUCFGR_OF32S		1'b0
`define OR1200_CPUCFGR_OF64S		1'b0
`define OR1200_CPUCFGR_OV64S		1'b0
`define OR1200_CPUCFGR_RES1		22'h000000
`define OR1200_DMMUCFGR_CRI_BITS	8
`define OR1200_DMMUCFGR_PRI_BITS	9
`define OR1200_DMMUCFGR_TEIRI_BITS	10
`define OR1200_DMMUCFGR_HTR_BITS	11
`define OR1200_DMMUCFGR_NTW		2'h0	
`define OR1200_DMMUCFGR_NAE		3'h0	
`define OR1200_DMMUCFGR_CRI		1'b0	
`define OR1200_DMMUCFGR_PRI		1'b0	
`define OR1200_DMMUCFGR_TEIRI		1'b1	
`define OR1200_DMMUCFGR_HTR		1'b0	
`define OR1200_DMMUCFGR_RES1		20'h00000
`define OR1200_IMMUCFGR_CRI_BITS	8
`define OR1200_IMMUCFGR_PRI_BITS	9
`define OR1200_IMMUCFGR_TEIRI_BITS	10
`define OR1200_IMMUCFGR_HTR_BITS	11
`define OR1200_IMMUCFGR_NTW		2'h0	
`define OR1200_IMMUCFGR_NAE		3'h0	
`define OR1200_IMMUCFGR_CRI		1'b0	
`define OR1200_IMMUCFGR_PRI		1'b0	
`define OR1200_IMMUCFGR_TEIRI		1'b1	
`define OR1200_IMMUCFGR_HTR		1'b0	
`define OR1200_IMMUCFGR_RES1		20'h00000
`define OR1200_DCCFGR_CBS_BITS		7
`define OR1200_DCCFGR_CWS_BITS		8
`define OR1200_DCCFGR_CCRI_BITS		9
`define OR1200_DCCFGR_CBIRI_BITS	10
`define OR1200_DCCFGR_CBPRI_BITS	11
`define OR1200_DCCFGR_CBLRI_BITS	12
`define OR1200_DCCFGR_CBFRI_BITS	13
`define OR1200_DCCFGR_CBWBRI_BITS	14
`define OR1200_DCCFGR_NCW		3'h0	
`define OR1200_DCCFGR_CWS		1'b0	
`define OR1200_DCCFGR_CCRI		1'b1	
`define OR1200_DCCFGR_CBIRI		1'b1	
`define OR1200_DCCFGR_CBPRI		1'b0	
`define OR1200_DCCFGR_CBLRI		1'b0	
`define OR1200_DCCFGR_CBFRI		1'b1	
`define OR1200_DCCFGR_CBWBRI		1'b0	
`define OR1200_DCCFGR_RES1		17'h00000
`define OR1200_ICCFGR_CBS_BITS		7
`define OR1200_ICCFGR_CWS_BITS		8
`define OR1200_ICCFGR_CCRI_BITS		9
`define OR1200_ICCFGR_CBIRI_BITS	10
`define OR1200_ICCFGR_CBPRI_BITS	11
`define OR1200_ICCFGR_CBLRI_BITS	12
`define OR1200_ICCFGR_CBFRI_BITS	13
`define OR1200_ICCFGR_CBWBRI_BITS	14
`define OR1200_ICCFGR_NCW		3'h0	
`define OR1200_ICCFGR_CWS		1'b0	
`define OR1200_ICCFGR_CCRI		1'b1	
`define OR1200_ICCFGR_CBIRI		1'b1	
`define OR1200_ICCFGR_CBPRI		1'b0	
`define OR1200_ICCFGR_CBLRI		1'b0	
`define OR1200_ICCFGR_CBFRI		1'b1	
`define OR1200_ICCFGR_CBWBRI		1'b0	
`define OR1200_ICCFGR_RES1		17'h00000
`define OR1200_DCFGR_WPCI_BITS		3
`define OR1200_DCFGR_NDP		3'h0	
`define OR1200_DCFGR_WPCI		1'b0	
`define OR1200_DCFGR_RES1		28'h0000000
module or1200_flat( 
	clk, rst,
	ic_en,
	icpu_adr_o, icpu_cycstb_o, icpu_sel_o, icpu_tag_o,
	icpu_dat_i, icpu_ack_i, icpu_rty_i, icpu_err_i, icpu_adr_i, icpu_tag_i,
	immu_en,
	ex_insn, ex_freeze, id_pc, branch_op,
	spr_dat_npc, rf_dataw,
	du_stall, du_addr, du_dat_du, du_read, du_write, du_dsr, du_hwbkpt,
	du_except, du_dat_cpu,
	dc_en,
	dcpu_adr_o, dcpu_cycstb_o, dcpu_we_o, dcpu_sel_o, dcpu_tag_o, dcpu_dat_o,
	dcpu_dat_i, dcpu_ack_i, dcpu_rty_i, dcpu_err_i, dcpu_tag_i,
	dmmu_en,
	sig_int, sig_tick,
	supv, spr_addr, spr_dat_cpu, spr_dat_pic, spr_dat_tt, spr_dat_pm,
	spr_dat_dmmu, spr_dat_immu, spr_dat_du, spr_cs, spr_we
);
input 				clk;
input 				rst;
output				ic_en;
output	[31:0]			icpu_adr_o;
output				icpu_cycstb_o;
output	[3:0]			icpu_sel_o;
output	[3:0]			icpu_tag_o;
input	[31:0]			icpu_dat_i;
input				icpu_ack_i;
input				icpu_rty_i;
input				icpu_err_i;
input	[31:0]			icpu_adr_i;
input	[3:0]			icpu_tag_i;
output				immu_en;
output	[31:0]			ex_insn;
output				ex_freeze;
output	[31:0]			id_pc;
output	[`OR1200_BRANCHOP_WIDTH-1:0]	branch_op;
input				du_stall;
input	[`OR1200_OPERAND_WIDTH-1:0]		du_addr;
input	[`OR1200_OPERAND_WIDTH-1:0]		du_dat_du;
input				du_read;
input				du_write;
input	[`OR1200_DU_DSR_WIDTH-1:0]	du_dsr;
input				du_hwbkpt;
output	[12:0]			du_except;
output	[`OR1200_OPERAND_WIDTH-1:0]		du_dat_cpu;
output	[`OR1200_OPERAND_WIDTH-1:0]		rf_dataw;
output	[31:0]			dcpu_adr_o;
output				dcpu_cycstb_o;
output				dcpu_we_o;
output	[3:0]			dcpu_sel_o;
output	[3:0]			dcpu_tag_o;
output	[31:0]			dcpu_dat_o;
input	[31:0]			dcpu_dat_i;
input				dcpu_ack_i;
input				dcpu_rty_i;
input				dcpu_err_i;
input	[3:0]			dcpu_tag_i;
output				dc_en;
output				dmmu_en;
output				supv;
input	[`OR1200_OPERAND_WIDTH-1:0]		spr_dat_pic;
input	[`OR1200_OPERAND_WIDTH-1:0]		spr_dat_tt;
input	[`OR1200_OPERAND_WIDTH-1:0]		spr_dat_pm;
input	[`OR1200_OPERAND_WIDTH-1:0]		spr_dat_dmmu;
input	[`OR1200_OPERAND_WIDTH-1:0]		spr_dat_immu;
input	[`OR1200_OPERAND_WIDTH-1:0]		spr_dat_du;
output	[`OR1200_OPERAND_WIDTH-1:0]		spr_addr;
output	[`OR1200_OPERAND_WIDTH-1:0]		spr_dat_cpu;
output	[`OR1200_OPERAND_WIDTH-1:0]		spr_dat_npc;
output	[31:0]			spr_cs;
output				spr_we;
input				sig_int;
input				sig_tick;
wire	[31:0]			if_insn;
wire	[31:0]			if_pc;
wire	[31:2]			lr_sav;
wire	[`OR1200_REGFILE_ADDR_WIDTH-1:0]		rf_addrw;
wire	[`OR1200_REGFILE_ADDR_WIDTH-1:0] 		rf_addra;
wire	[`OR1200_REGFILE_ADDR_WIDTH-1:0] 		rf_addrb;
wire				rf_rda;
wire				rf_rdb;
wire	[`OR1200_OPERAND_WIDTH-1:0]		simm;
wire	[`OR1200_OPERAND_WIDTH-1:2]		branch_addrofs;
wire	[`OR1200_ALUOP_WIDTH-1:0]	alu_op;
wire	[`OR1200_SHROTOP_WIDTH-1:0]	shrot_op;
wire	[`OR1200_COMPOP_WIDTH-1:0]	comp_op;
wire	[`OR1200_BRANCHOP_WIDTH-1:0]	branch_op;
wire	[`OR1200_LSUOP_WIDTH-1:0]	lsu_op;
wire				genpc_freeze;
wire				if_freeze;
wire				id_freeze;
wire				ex_freeze;
wire				wb_freeze;
wire	[`OR1200_SEL_WIDTH-1:0]	sel_a;
wire	[`OR1200_SEL_WIDTH-1:0]	sel_b;
wire	[`OR1200_RFWBOP_WIDTH-1:0]	rfwb_op;
wire	[`OR1200_OPERAND_WIDTH-1:0]		rf_dataw;
wire	[`OR1200_OPERAND_WIDTH-1:0]		rf_dataa;
wire	[`OR1200_OPERAND_WIDTH-1:0]		rf_datab;
wire	[`OR1200_OPERAND_WIDTH-1:0]		muxed_b;
wire	[`OR1200_OPERAND_WIDTH-1:0]		wb_forw;
wire				wbforw_valid;
wire	[`OR1200_OPERAND_WIDTH-1:0]		operand_a;
wire	[`OR1200_OPERAND_WIDTH-1:0]		operand_b;
wire	[`OR1200_OPERAND_WIDTH-1:0]		alu_dataout;
wire	[`OR1200_OPERAND_WIDTH-1:0]		lsu_dataout;
wire	[`OR1200_OPERAND_WIDTH-1:0]		sprs_dataout;
wire	[31:0]			lsu_addrofs;
wire	[`OR1200_MULTICYCLE_WIDTH-1:0]	multicycle;
wire	[`OR1200_EXCEPT_WIDTH-1:0]	except_type;
wire	[4:0]			cust5_op;
wire	[5:0]			cust5_limm;
wire				flushpipe;
wire				extend_flush;
wire				branch_taken;
wire				flag;
wire				flagforw;
wire				flag_we;
wire				k_carry;
wire				cyforw;
wire				cy_we;
wire				lsu_stall;
wire				epcr_we;
wire				eear_we;
wire				esr_we;
wire				pc_we;
wire	[31:0]			epcr;
wire	[31:0]			eear;
wire	[`OR1200_SR_WIDTH-1:0]	esr;
wire				sr_we;
wire	[`OR1200_SR_WIDTH-1:0]	to_sr;
wire	[`OR1200_SR_WIDTH-1:0]	sr;
wire				except_start;
wire				except_started;
wire	[31:0]			wb_insn;
wire	[15:0]			spr_addrimm;
wire				sig_syscall;
wire				sig_trap;
wire	[31:0]			spr_dat_cfgr;
wire	[31:0]			spr_dat_rf;
wire    [31:0]                  spr_dat_npc;
wire	[31:0]			spr_dat_ppc;
wire	[31:0]			spr_dat_mac;
wire				force_dslot_fetch;
wire				no_more_dslot;
wire				ex_void;
wire				if_stall;
wire				id_macrc_op;
wire				ex_macrc_op;
wire	[`OR1200_MACOP_WIDTH-1:0] mac_op;
wire	[31:0]			mult_mac_result;
wire				mac_stall;
wire	[12:0]			except_stop;
wire				genpc_refetch;
wire				rfe;
wire				lsu_unstall;
wire				except_align;
wire				except_dtlbmiss;
wire				except_dmmufault;
wire				except_illegal;
wire				except_itlbmiss;
wire				except_immufault;
wire				except_ibuserr;
wire				except_dbuserr;
wire				abort_ex;
assign du_except = except_stop;
assign dc_en = sr[`OR1200_SR_DCE];
assign ic_en = sr[`OR1200_SR_ICE];
assign dmmu_en = sr[`OR1200_SR_DME];
assign immu_en = sr[`OR1200_SR_IME];
assign supv = sr[`OR1200_SR_SM];
or1200_genpc or1200_genpc(
	.clk(clk),
	.rst(rst),
	.icpu_adr_o(icpu_adr_o),
	.icpu_cycstb_o(icpu_cycstb_o),
	.icpu_sel_o(icpu_sel_o),
	.icpu_tag_o(icpu_tag_o),
	.icpu_rty_i(icpu_rty_i),
	.icpu_adr_i(icpu_adr_i),
	.branch_op(branch_op),
	.except_type(except_type),
	.except_start(except_start),
	.except_prefix(sr[`OR1200_SR_EPH]),
	.branch_addrofs(branch_addrofs),
	.lr_restor(operand_b),
	.flag(flag),
	.taken(branch_taken),
	.binsn_addr(lr_sav),
	.epcr(epcr),
	.spr_dat_i(spr_dat_cpu),
	.spr_pc_we(pc_we),
	.genpc_refetch(genpc_refetch),
	.genpc_freeze(genpc_freeze),
  .genpc_stop_prefetch(1'b0),
	.no_more_dslot(no_more_dslot)
);
or1200_if or1200_if(
	.clk(clk),
	.rst(rst),
	.icpu_dat_i(icpu_dat_i),
	.icpu_ack_i(icpu_ack_i),
	.icpu_err_i(icpu_err_i),
	.icpu_adr_i(icpu_adr_i),
	.icpu_tag_i(icpu_tag_i),
	.if_freeze(if_freeze),
	.if_insn(if_insn),
	.if_pc(if_pc),
	.flushpipe(flushpipe),
	.if_stall(if_stall),
	.no_more_dslot(no_more_dslot),
	.genpc_refetch(genpc_refetch),
	.rfe(rfe),
	.except_itlbmiss(except_itlbmiss),
	.except_immufault(except_immufault),
	.except_ibuserr(except_ibuserr)
);
or1200_ctrl or1200_ctrl(
	.clk(clk),
	.rst(rst),
	.id_freeze(id_freeze),
	.ex_freeze(ex_freeze),
	.wb_freeze(wb_freeze),
	.flushpipe(flushpipe),
	.if_insn(if_insn),
	.ex_insn(ex_insn),
	.branch_op(branch_op),
	.branch_taken(branch_taken),
	.rf_addra(rf_addra),
	.rf_addrb(rf_addrb),
	.rf_rda(rf_rda),
	.rf_rdb(rf_rdb),
	.alu_op(alu_op),
	.mac_op(mac_op),
	.shrot_op(shrot_op),
	.comp_op(comp_op),
	.rf_addrw(rf_addrw),
	.rfwb_op(rfwb_op),
	.wb_insn(wb_insn),
	.simm(simm),
	.branch_addrofs(branch_addrofs),
	.lsu_addrofs(lsu_addrofs),
	.sel_a(sel_a),
	.sel_b(sel_b),
	.lsu_op(lsu_op),
	.cust5_op(cust5_op),
	.cust5_limm(cust5_limm),
	.multicycle(multicycle),
	.spr_addrimm(spr_addrimm),
	.wbforw_valid(wbforw_valid),
	.sig_syscall(sig_syscall),
	.sig_trap(sig_trap),
	.force_dslot_fetch(force_dslot_fetch),
	.no_more_dslot(no_more_dslot),
	.ex_void(ex_void),
	.id_macrc_op(id_macrc_op),
	.ex_macrc_op(ex_macrc_op),
	.rfe(rfe),
	.du_hwbkpt(du_hwbkpt),
	.except_illegal(except_illegal)
);
or1200_rf or1200_rf(
	.clk(clk),
	.rst(rst),
	.supv(sr[`OR1200_SR_SM]),
	.wb_freeze(wb_freeze),
	.addrw(rf_addrw),
	.dataw(rf_dataw),
	.id_freeze(id_freeze),
	.we(rfwb_op[0]),
	.flushpipe(flushpipe),
	.addra(rf_addra),
	.rda(rf_rda),
	.dataa(rf_dataa),
	.addrb(rf_addrb),
	.rdb(rf_rdb),
	.datab(rf_datab),
	.spr_cs(spr_cs[`OR1200_SPR_GROUP_SYS]),
	.spr_write(spr_we),
	.spr_addr(spr_addr),
	.spr_dat_i(spr_dat_cpu),
	.spr_dat_o(spr_dat_rf)
);
or1200_operandmuxes or1200_operandmuxes(
	.clk(clk),
	.rst(rst),
	.id_freeze(id_freeze),
	.ex_freeze(ex_freeze),
	.rf_dataa(rf_dataa),
	.rf_datab(rf_datab),
	.ex_forw(rf_dataw),
	.wb_forw(wb_forw),
	.simm(simm),
	.sel_a(sel_a),
	.sel_b(sel_b),
	.operand_a(operand_a),
	.operand_b(operand_b),
	.muxed_b(muxed_b)
);
or1200_alu or1200_alu(
	.a(operand_a),
	.b(operand_b),
	.mult_mac_result(mult_mac_result),
	.macrc_op(ex_macrc_op),
	.alu_op(alu_op),
	.shrot_op(shrot_op),
	.comp_op(comp_op),
	.cust5_op(cust5_op),
	.cust5_limm(cust5_limm),
	.result(alu_dataout),
	.flagforw(flagforw),
	.flag_we(flag_we),
	.cyforw(cyforw),
	.cy_we(cy_we),
  .flag(flag),
	.k_carry(k_carry)
);
or1200_mult_mac or1200_mult_mac(
	.clk(clk),
	.rst(rst),
	.ex_freeze(ex_freeze),
	.id_macrc_op(id_macrc_op),
	.macrc_op(ex_macrc_op),
	.a(operand_a),
	.b(operand_b),
	.mac_op(mac_op),
	.alu_op(alu_op),
	.result(mult_mac_result),
	.mac_stall_r(mac_stall),
	.spr_cs(spr_cs[`OR1200_SPR_GROUP_MAC]),
	.spr_write(spr_we),
	.spr_addr(spr_addr),
	.spr_dat_i(spr_dat_cpu),
	.spr_dat_o(spr_dat_mac)
);
or1200_sprs or1200_sprs(
	.clk(clk),
	.rst(rst),
	.addrbase(operand_a),
	.addrofs(spr_addrimm),
	.dat_i(operand_b),
	.alu_op(alu_op),
	.flagforw(flagforw),
	.flag_we(flag_we),
	.flag(flag),
	.cyforw(cyforw),
	.cy_we(cy_we),
	.carry(k_carry),
	.to_wbmux(sprs_dataout),
	.du_addr(du_addr),
	.du_dat_du(du_dat_du),
	.du_read(du_read),
	.du_write(du_write),
	.du_dat_cpu(du_dat_cpu),
	.spr_addr(spr_addr),
	.spr_dat_pic(spr_dat_pic),
	.spr_dat_tt(spr_dat_tt),
	.spr_dat_pm(spr_dat_pm),
	.spr_dat_cfgr(spr_dat_cfgr),
	.spr_dat_rf(spr_dat_rf),
	.spr_dat_npc(spr_dat_npc),
        .spr_dat_ppc(spr_dat_ppc),
	.spr_dat_mac(spr_dat_mac),
	.spr_dat_dmmu(spr_dat_dmmu),
	.spr_dat_immu(spr_dat_immu),
	.spr_dat_du(spr_dat_du),
	.spr_dat_o(spr_dat_cpu),
	.spr_cs(spr_cs),
	.spr_we(spr_we),
	.epcr_we(epcr_we),
	.eear_we(eear_we),
	.esr_we(esr_we),
	.pc_we(pc_we),
	.epcr(epcr),
	.eear(eear),
	.esr(esr),
	.except_started(except_started),
	.sr_we(sr_we),
	.to_sr(to_sr),
	.sr(sr),
	.branch_op(branch_op)
);
or1200_lsu or1200_lsu(
	.addrbase(operand_a),
	.addrofs(lsu_addrofs),
	.lsu_op(lsu_op),
	.lsu_datain(operand_b),
	.lsu_dataout(lsu_dataout),
	.lsu_stall(lsu_stall),
	.lsu_unstall(lsu_unstall),
        .du_stall(du_stall),
	.except_align(except_align),
	.except_dtlbmiss(except_dtlbmiss),
	.except_dmmufault(except_dmmufault),
	.except_dbuserr(except_dbuserr),
	.dcpu_adr_o(dcpu_adr_o),
	.dcpu_cycstb_o(dcpu_cycstb_o),
	.dcpu_we_o(dcpu_we_o),
	.dcpu_sel_o(dcpu_sel_o),
	.dcpu_tag_o(dcpu_tag_o),
	.dcpu_dat_o(dcpu_dat_o),
	.dcpu_dat_i(dcpu_dat_i),
	.dcpu_ack_i(dcpu_ack_i),
	.dcpu_rty_i(dcpu_rty_i),
	.dcpu_err_i(dcpu_err_i),
	.dcpu_tag_i(dcpu_tag_i)
);
or1200_wbmux or1200_wbmux(
	.clk(clk),
	.rst(rst),
	.wb_freeze(wb_freeze),
	.rfwb_op(rfwb_op),
	.muxin_a(alu_dataout),
	.muxin_b(lsu_dataout),
	.muxin_c(sprs_dataout),
	.muxin_d({lr_sav, 2'b0}),
	.muxout(rf_dataw),
	.muxreg(wb_forw),
	.muxreg_valid(wbforw_valid)
);
or1200_freeze or1200_freeze(
	.clk(clk),
	.rst(rst),
	.multicycle(multicycle),
	.flushpipe(flushpipe),
	.extend_flush(extend_flush),
	.lsu_stall(lsu_stall),
	.if_stall(if_stall),
	.lsu_unstall(lsu_unstall),
	.force_dslot_fetch(force_dslot_fetch),
	.abort_ex(abort_ex),
	.du_stall(du_stall),
	.mac_stall(mac_stall),
	.genpc_freeze(genpc_freeze),
	.if_freeze(if_freeze),
	.id_freeze(id_freeze),
	.ex_freeze(ex_freeze),
	.wb_freeze(wb_freeze),
	.icpu_ack_i(icpu_ack_i),
	.icpu_err_i(icpu_err_i)
);
or1200_except or1200_except(
	.clk(clk),
	.rst(rst),
	.sig_ibuserr(except_ibuserr),
	.sig_dbuserr(except_dbuserr),
	.sig_illegal(except_illegal),
	.sig_align(except_align),
	.sig_range(1'b0),
	.sig_dtlbmiss(except_dtlbmiss),
	.sig_dmmufault(except_dmmufault),
	.sig_int(sig_int),
	.sig_syscall(sig_syscall),
	.sig_trap(sig_trap),
	.sig_itlbmiss(except_itlbmiss),
	.sig_immufault(except_immufault),
	.sig_tick(sig_tick),
	.branch_taken(branch_taken),
	.icpu_ack_i(icpu_ack_i),
	.icpu_err_i(icpu_err_i),
	.dcpu_ack_i(dcpu_ack_i),
	.dcpu_err_i(dcpu_err_i),
	.genpc_freeze(genpc_freeze),
        .id_freeze(id_freeze),
        .ex_freeze(ex_freeze),
        .wb_freeze(wb_freeze),
	.if_stall(if_stall),
	.if_pc(if_pc),
	.id_pc(id_pc),
	.lr_sav(lr_sav),
	.flushpipe(flushpipe),
	.extend_flush(extend_flush),
	.except_type(except_type),
	.except_start(except_start),
	.except_started(except_started),
	.except_stop(except_stop),
	.ex_void(ex_void),
	.spr_dat_ppc(spr_dat_ppc),
	.spr_dat_npc(spr_dat_npc),
	.datain(operand_b),
	.du_dsr(du_dsr),
	.epcr_we(epcr_we),
	.eear_we(eear_we),
	.esr_we(esr_we),
	.pc_we(pc_we),
        .epcr(epcr),
	.eear(eear),
	.esr(esr),
	.lsu_addr(dcpu_adr_o),
	.sr_we(sr_we),
	.to_sr(to_sr),
	.sr(sr),
	.abort_ex(abort_ex)
);
or1200_cfgr or1200_cfgr(
	.spr_addr(spr_addr),
	.spr_dat_o(spr_dat_cfgr)
);
endmodule
`define OR1200_ITAG_IDLE	4'h0	
`define	OR1200_ITAG_NI		4'h1	
`define OR1200_ITAG_BE		4'hb	
`define OR1200_ITAG_PE		4'hc	
`define OR1200_ITAG_TE		4'hd	
`define OR1200_BRANCHOP_WIDTH		3
`define OR1200_BRANCHOP_NOP		3'b000
`define OR1200_BRANCHOP_J		3'b001
`define OR1200_BRANCHOP_JR		3'b010
`define OR1200_BRANCHOP_BAL		3'b011
`define OR1200_BRANCHOP_BF		3'b100
`define OR1200_BRANCHOP_BNF		3'b101
`define OR1200_BRANCHOP_RFE		3'b110
`define OR1200_EXCEPT_WIDTH 4
`define OR1200_EXCEPT_EPH0_P 20'h00000
`define OR1200_EXCEPT_EPH1_P 20'hF0000
`define OR1200_EXCEPT_V		   8'h00
module or1200_genpc(
	clk, rst,
	icpu_adr_o, icpu_cycstb_o, icpu_sel_o, icpu_tag_o,
	icpu_rty_i, icpu_adr_i,
	branch_op, except_type,except_start, except_prefix, 
	branch_addrofs, lr_restor, flag, taken, 
	binsn_addr, epcr, spr_dat_i, spr_pc_we, genpc_refetch,
	genpc_freeze, genpc_stop_prefetch, no_more_dslot
);
input				clk;
input				rst;
output	[31:0]			icpu_adr_o;
output				icpu_cycstb_o;
output	[3:0]			icpu_sel_o;
output	[3:0]			icpu_tag_o;
input				icpu_rty_i;
input	[31:0]			icpu_adr_i;
input	[`OR1200_BRANCHOP_WIDTH-1:0]	branch_op;
input	[`OR1200_EXCEPT_WIDTH-1:0]	except_type;
input				except_start;
input					except_prefix;
input	[31:2]			branch_addrofs;
input	[31:0]			lr_restor;
input				flag;
output				taken;
input	[31:2]			binsn_addr;
input	[31:0]			epcr;
input	[31:0]			spr_dat_i;
input				spr_pc_we;
input				genpc_refetch;
input				genpc_freeze;
input				genpc_stop_prefetch;
input				no_more_dslot;
reg	[31:2]			pcreg;
reg	[31:0]			pc;
reg				taken;	
reg				genpc_refetch_r;
assign icpu_adr_o = !no_more_dslot & !except_start & !spr_pc_we & (icpu_rty_i | genpc_refetch) ? icpu_adr_i : pc;
assign icpu_cycstb_o = !genpc_freeze; 
assign icpu_sel_o = 4'b1111;
assign icpu_tag_o = `OR1200_ITAG_NI;
always @(posedge clk )
	if (rst)
		genpc_refetch_r <= 1'b0;
	else if (genpc_refetch)
		genpc_refetch_r <=  1'b1;
	else
		genpc_refetch_r <=  1'b0;
always @(pcreg or branch_addrofs or binsn_addr or flag or branch_op or except_type
	or except_start or lr_restor or epcr or spr_pc_we or spr_dat_i or except_prefix) begin
	case ({spr_pc_we, except_start, branch_op})	
		{2'b00, `OR1200_BRANCHOP_NOP}: begin
			pc = {pcreg + 30'b000000000000000000000000000001, 2'b0};
			taken = 1'b0;
		end
		{2'b00, `OR1200_BRANCHOP_J}: begin
			pc = {branch_addrofs, 2'b0};
			taken = 1'b1;
		end
		{2'b00, `OR1200_BRANCHOP_JR}: begin
			pc = lr_restor;
			taken = 1'b1;
		end
		{2'b00, `OR1200_BRANCHOP_BAL}: begin
	pc = {binsn_addr + branch_addrofs, 2'b0};
			taken = 1'b1;
		end
		{2'b00, `OR1200_BRANCHOP_BF}:
			if (flag) begin
				pc = {binsn_addr + branch_addrofs, 2'b0};
				taken = 1'b1;
			end
			else begin
				pc = {pcreg + 30'b000000000000000000000000000001, 2'b0};
				taken = 1'b0;
			end
		{2'b00, `OR1200_BRANCHOP_BNF}:
			if (flag) begin
				pc = {pcreg + 30'b000000000000000000000000000001, 2'b0};
				taken = 1'b0;
			end
			else begin				pc = {binsn_addr + branch_addrofs, 2'b0};
				taken = 1'b1;
			end
		{2'b00, `OR1200_BRANCHOP_RFE}: begin
			pc = epcr;
			taken = 1'b1;
		end
		{2'b01, 3'b000}: begin
			pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
			taken = 1'b1;
		end
		{2'b01, 3'b001}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		{2'b01, 3'b010}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		{2'b01, 3'b011}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		{2'b01, 3'b100}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		{2'b01, 3'b101}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		{2'b01, 3'b110}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		{2'b01, 3'b111}: begin
                        pc = {(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P), except_type, `OR1200_EXCEPT_V};
                        taken = 1'b1;
                end
		default: begin
			pc = spr_dat_i;
			taken = 1'b0;
		end
	endcase
end
always @(posedge clk )
	if (rst)
		pcreg <=  ({(except_prefix ? `OR1200_EXCEPT_EPH1_P : `OR1200_EXCEPT_EPH0_P),8'b11111111, `OR1200_EXCEPT_V} - 1) >> 2;
	else if (spr_pc_we)
		pcreg <=  spr_dat_i[31:2];
	else if (no_more_dslot | except_start | !genpc_freeze & !icpu_rty_i & !genpc_refetch)
		pcreg <=  pc[31:2];
		wire unused;
		assign unused = |except_prefix & | binsn_addr | genpc_stop_prefetch ;
endmodule
`define OR1200_ITAG_IDLE	4'h0	
`define	OR1200_ITAG_NI		4'h1	
`define OR1200_ITAG_BE		4'hb	
`define OR1200_ITAG_PE		4'hc	
`define OR1200_ITAG_TE		4'hd	
`define OR1200_OR32_J                 6'b000000
`define OR1200_OR32_JAL               6'b000001
`define OR1200_OR32_BNF               6'b000011
`define OR1200_OR32_BF                6'b000100
`define OR1200_OR32_NOP               6'b000101
`define OR1200_OR32_MOVHI             6'b000110
`define OR1200_OR32_XSYNC             6'b001000
`define OR1200_OR32_RFE               6'b001001
`define OR1200_OR32_JR                6'b010001
`define OR1200_OR32_JALR              6'b010010
`define OR1200_OR32_MACI              6'b010011
`define OR1200_OR32_LWZ               6'b100001
`define OR1200_OR32_LBZ               6'b100011
`define OR1200_OR32_LBS               6'b100100
`define OR1200_OR32_LHZ               6'b100101
`define OR1200_OR32_LHS               6'b100110
`define OR1200_OR32_ADDI              6'b100111
`define OR1200_OR32_ADDIC             6'b101000
`define OR1200_OR32_ANDI              6'b101001
`define OR1200_OR32_ORI               6'b101010
`define OR1200_OR32_XORI              6'b101011
`define OR1200_OR32_MULI              6'b101100
`define OR1200_OR32_MFSPR             6'b101101
`define OR1200_OR32_SH_ROTI 	      6'b101110
`define OR1200_OR32_SFXXI             6'b101111
`define OR1200_OR32_MTSPR             6'b110000
`define OR1200_OR32_MACMSB            6'b110001
`define OR1200_OR32_SW                6'b110101
`define OR1200_OR32_SB                6'b110110
`define OR1200_OR32_SH                6'b110111
`define OR1200_OR32_ALU               6'b111000
`define OR1200_OR32_SFXX              6'b111001
module or1200_if(
	clk, rst,
	icpu_dat_i, icpu_ack_i, icpu_err_i, icpu_adr_i, icpu_tag_i,
	if_freeze, if_insn, if_pc, flushpipe,
	if_stall, no_more_dslot, genpc_refetch, rfe,
	except_itlbmiss, except_immufault, except_ibuserr
);
input				clk;
input				rst;
input	[31:0]			icpu_dat_i;
input				icpu_ack_i;
input				icpu_err_i;
input	[31:0]			icpu_adr_i;
input	[3:0]			icpu_tag_i;
input				if_freeze;
output	[31:0]			if_insn;
output	[31:0]			if_pc;
input				flushpipe;
output				if_stall;
input				no_more_dslot;
output				genpc_refetch;
input				rfe;
output				except_itlbmiss;
output				except_immufault;
output				except_ibuserr;
reg	[31:0]			insn_saved;
reg	[31:0]			addr_saved;
reg				saved;
assign if_insn = icpu_err_i | no_more_dslot | rfe ? {`OR1200_OR32_NOP, 26'h0410000} : saved ? insn_saved : icpu_ack_i ? icpu_dat_i : {`OR1200_OR32_NOP, 26'h0610000};
assign if_pc = saved ? addr_saved : icpu_adr_i;
assign if_stall = !icpu_err_i & !icpu_ack_i & !saved;
assign genpc_refetch = saved & icpu_ack_i;
assign except_itlbmiss = icpu_err_i & (icpu_tag_i == `OR1200_ITAG_TE) & !no_more_dslot;
assign except_immufault = icpu_err_i & (icpu_tag_i == `OR1200_ITAG_PE) & !no_more_dslot;
assign except_ibuserr = icpu_err_i & (icpu_tag_i == `OR1200_ITAG_BE) & !no_more_dslot;
always @(posedge clk )
	if (rst)
		saved <=  1'b0;
	else if (flushpipe)
		saved <=  1'b0;
	else if (icpu_ack_i & if_freeze & !saved)
		saved <=  1'b1;
	else if (!if_freeze)
		saved <=  1'b0;
always @(posedge clk )
	if (rst)
		insn_saved <=  {`OR1200_OR32_NOP, 26'h0410000};
	else if (flushpipe)
		insn_saved <=  {`OR1200_OR32_NOP, 26'h0410000};
	else if (icpu_ack_i & if_freeze & !saved)
		insn_saved <=  icpu_dat_i;
	else if (!if_freeze)
		insn_saved <=  {`OR1200_OR32_NOP, 26'h0410000};
always @(posedge clk )
	if (rst)
		addr_saved <=  32'h00000000;
	else if (flushpipe)
		addr_saved <=  32'h00000000;
	else if (icpu_ack_i & if_freeze & !saved)
		addr_saved <=  icpu_adr_i;
	else if (!if_freeze)
		addr_saved <=  icpu_adr_i;
endmodule
module or1200_ctrl(
	clk, rst,
	id_freeze, ex_freeze, wb_freeze, flushpipe, if_insn, ex_insn, branch_op, branch_taken,
	rf_addra, rf_addrb, rf_rda, rf_rdb, alu_op, mac_op, shrot_op, comp_op, rf_addrw, rfwb_op,
	wb_insn, simm, branch_addrofs, lsu_addrofs, sel_a, sel_b, lsu_op,
	cust5_op, cust5_limm,
	multicycle, spr_addrimm, wbforw_valid, sig_syscall, sig_trap,
	force_dslot_fetch, no_more_dslot, ex_void, id_macrc_op, ex_macrc_op, rfe,du_hwbkpt, except_illegal
);
input					clk;
input					rst;
input					id_freeze;
input					ex_freeze;
input					wb_freeze;
input					flushpipe;
input	[31:0]				if_insn;
output	[31:0]				ex_insn;
output	[`OR1200_BRANCHOP_WIDTH-1:0]		branch_op;
input						branch_taken;
output	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	rf_addrw;
output	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	rf_addra;
output	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	rf_addrb;
output					rf_rda;
output					rf_rdb;
output	[`OR1200_ALUOP_WIDTH-1:0]		alu_op;
output	[`OR1200_MACOP_WIDTH-1:0]		mac_op;
output	[`OR1200_SHROTOP_WIDTH-1:0]		shrot_op;
output	[`OR1200_RFWBOP_WIDTH-1:0]		rfwb_op;
output	[31:0]				wb_insn;
output	[31:0]				simm;
output	[31:2]				branch_addrofs;
output	[31:0]				lsu_addrofs;
output	[`OR1200_SEL_WIDTH-1:0]		sel_a;
output	[`OR1200_SEL_WIDTH-1:0]		sel_b;
output	[`OR1200_LSUOP_WIDTH-1:0]		lsu_op;
output	[`OR1200_COMPOP_WIDTH-1:0]		comp_op;
output	[`OR1200_MULTICYCLE_WIDTH-1:0]		multicycle;
output	[4:0]				cust5_op;
output	[5:0]				cust5_limm;
output	[15:0]				spr_addrimm;
input					wbforw_valid;
input					du_hwbkpt;
output					sig_syscall;
output					sig_trap;
output					force_dslot_fetch;
output					no_more_dslot;
output					ex_void;
output					id_macrc_op;
output					ex_macrc_op;
output					rfe;
output					except_illegal;
reg	[`OR1200_BRANCHOP_WIDTH-1:0]		pre_branch_op;
reg	[`OR1200_BRANCHOP_WIDTH-1:0]		branch_op;
reg	[`OR1200_ALUOP_WIDTH-1:0]		alu_op;
reg	[`OR1200_MACOP_WIDTH-1:0]		mac_op;
reg					ex_macrc_op;
reg	[`OR1200_SHROTOP_WIDTH-1:0]		shrot_op;
reg	[31:0]				id_insn;
reg	[31:0]				ex_insn;
reg	[31:0]				wb_insn;
reg	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	rf_addrw;
reg	[`OR1200_REGFILE_ADDR_WIDTH-1:0]	wb_rfaddrw;
reg	[`OR1200_RFWBOP_WIDTH-1:0]		rfwb_op;
reg	[31:0]				lsu_addrofs;
reg	[`OR1200_SEL_WIDTH-1:0]		sel_a;
reg	[`OR1200_SEL_WIDTH-1:0]		sel_b;
reg					sel_imm;
reg	[`OR1200_LSUOP_WIDTH-1:0]		lsu_op;
reg	[`OR1200_COMPOP_WIDTH-1:0]		comp_op;
reg	[`OR1200_MULTICYCLE_WIDTH-1:0]		multicycle;
reg					imm_signextend;
reg	[15:0]				spr_addrimm;
reg					sig_syscall;
reg					sig_trap;
reg					except_illegal;
wire					id_void;
assign rf_addra = if_insn[20:16];
assign rf_addrb = if_insn[15:11];
assign rf_rda = if_insn[31];
assign rf_rdb = if_insn[30];
assign force_dslot_fetch = 1'b0;
assign no_more_dslot = |branch_op & !id_void & branch_taken | (branch_op == `OR1200_BRANCHOP_RFE);
assign id_void = (id_insn[31:26] == `OR1200_OR32_NOP) & id_insn[16];
assign ex_void = (ex_insn[31:26] == `OR1200_OR32_NOP) & ex_insn[16];
assign simm = (imm_signextend == 1'b1) ? {{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]},{id_insn[15]}, id_insn[15:0]} : {{16'b0}, id_insn[15:0]};
assign branch_addrofs = {{ex_insn[25]},{ex_insn[25]},{ex_insn[25]},{ex_insn[25]},{ex_insn[25]}, ex_insn[25:0]};
assign id_macrc_op = (id_insn[31:26] == `OR1200_OR32_MOVHI) & id_insn[16];
assign cust5_op = ex_insn[4:0];
assign cust5_limm = ex_insn[10:5];
assign rfe = (pre_branch_op == `OR1200_BRANCHOP_RFE) | (branch_op == `OR1200_BRANCHOP_RFE);
always @(rf_addrw or id_insn or rfwb_op or wbforw_valid or wb_rfaddrw)
	if ((id_insn[20:16] == rf_addrw) && rfwb_op[0])
		sel_a = `OR1200_SEL_EX_FORW;
	else if ((id_insn[20:16] == wb_rfaddrw) && wbforw_valid)
		sel_a = `OR1200_SEL_WB_FORW;
	else
		sel_a = `OR1200_SEL_RF;
always @(rf_addrw or sel_imm or id_insn or rfwb_op or wbforw_valid or wb_rfaddrw)
	if (sel_imm)
		sel_b = `OR1200_SEL_IMM;
	else if ((id_insn[15:11] == rf_addrw) && rfwb_op[0])
		sel_b = `OR1200_SEL_EX_FORW;
	else if ((id_insn[15:11] == wb_rfaddrw) && wbforw_valid)
		sel_b = `OR1200_SEL_WB_FORW;
	else
		sel_b = `OR1200_SEL_RF;
always @(posedge clk ) begin
	if (rst)
		ex_macrc_op <=  1'b0;
	else if (!ex_freeze & id_freeze | flushpipe)
		ex_macrc_op <=  1'b0;
	else if (!ex_freeze)
		ex_macrc_op <=  id_macrc_op;
end
always @(posedge clk ) begin
	if (rst)
		spr_addrimm <=  16'h0000;
	else if (!ex_freeze & id_freeze | flushpipe)
		spr_addrimm <=  16'h0000;
	else if (!ex_freeze) begin
		case (id_insn[31:26])	
			`OR1200_OR32_MFSPR: 
				spr_addrimm <=  id_insn[15:0];
			default:
				spr_addrimm <=  {id_insn[25:21], id_insn[10:0]};
		endcase
	end
end
always @(id_insn) begin
  case (id_insn[31:26])		
    `OR1200_OR32_LWZ:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_LBZ:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_LBS:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_LHZ:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_LHS:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_SW:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_SB:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_SH:
      multicycle = `OR1200_TWO_CYCLES;
    `OR1200_OR32_ALU:
      multicycle = id_insn[9:8];
    default: begin
      multicycle = `OR1200_ONE_CYCLE;
    end
  endcase
end
always @(id_insn) begin
  case (id_insn[31:26])		
	`OR1200_OR32_ADDI:
		imm_signextend = 1'b1;
	`OR1200_OR32_ADDIC:
		imm_signextend = 1'b1;
	`OR1200_OR32_XORI:
		imm_signextend = 1'b1;
	`OR1200_OR32_MULI:
		imm_signextend = 1'b1;
	`OR1200_OR32_MACI:
		imm_signextend = 1'b1;
	`OR1200_OR32_SFXXI:
		imm_signextend = 1'b1;
	default: begin
		imm_signextend = 1'b0;
	end
endcase
end
always @(lsu_op or ex_insn) begin
	lsu_addrofs[10:0] = ex_insn[10:0];
	case(lsu_op)	
		`OR1200_LSUOP_SB : 
			lsu_addrofs[31:11] = {{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}}, ex_insn[25:21]};
			`OR1200_LSUOP_SH : 
			lsu_addrofs[31:11] = {{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}}, ex_insn[25:21]};
		`OR1200_LSUOP_SW : 
			lsu_addrofs[31:11] = {{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}},{{ex_insn[25]}}, ex_insn[25:21]};
		default : 
			lsu_addrofs[31:11] = {{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}},{{ex_insn[15]}}, ex_insn[15:11]};
	endcase
end
always @(posedge clk) begin
	if (rst)
		rf_addrw <=  5'b00000;
	else if (!ex_freeze & id_freeze)
		rf_addrw <=  5'b00000;
	else if (!ex_freeze)
		case (pre_branch_op)	
`OR1200_BRANCHOP_BAL:
				rf_addrw <=  5'b01001;	
				`OR1200_BRANCHOP_JR:
				rf_addrw <=  5'b01001;
			default:
				rf_addrw <=  id_insn[25:21];
		endcase
end
always @(posedge clk ) begin
	if (rst)
		wb_rfaddrw <=  5'b00000;
	else if (!wb_freeze)
		wb_rfaddrw <=  rf_addrw;
end
always @(posedge clk ) begin
	if (rst)
		id_insn <=  {`OR1200_OR32_NOP, 26'h0410000};
        else if (flushpipe)
                id_insn <=  {`OR1200_OR32_NOP, 26'h0410000};        
	else if (!id_freeze) begin
		id_insn <=  if_insn;
	end
end
always @(posedge clk ) begin
	if (rst)
		ex_insn <=  {`OR1200_OR32_NOP, 26'h0410000};
	else if (!ex_freeze & id_freeze | flushpipe)
		ex_insn <=  {`OR1200_OR32_NOP, 26'h0410000};	
	else if (!ex_freeze) begin
		ex_insn <=  id_insn;
	end
end
always @(posedge clk ) begin
	if (rst)
		wb_insn <=  {`OR1200_OR32_NOP, 26'h0410000};
	else if (flushpipe)
		wb_insn <=  {`OR1200_OR32_NOP, 26'h0410000};	
	else if (!wb_freeze) begin
		wb_insn <=  ex_insn;
	end
end
always @(posedge clk ) begin
	if (rst)
		sel_imm <=  1'b0;
	else if (!id_freeze) begin
	  case (if_insn[31:26])		
	    `OR1200_OR32_JALR:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_JR:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_RFE:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_MFSPR:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_MTSPR:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_XSYNC:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_MACMSB:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_SW:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_SB:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_SH:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_ALU:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_SFXX:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_CUST5:
	      sel_imm <=  1'b0;
	    `OR1200_OR32_NOP:
	      sel_imm <=  1'b0;
	    default: begin
	      sel_imm <=  1'b1;
	    end
	  endcase
	end
end
always @(posedge clk ) begin
	if (rst)
		except_illegal <=  1'b0;
	else if (!ex_freeze & id_freeze | flushpipe)
		except_illegal <=  1'b0;
	else if (!ex_freeze) begin
	      except_illegal <=  1'b1;
	end
end
always @(posedge clk ) begin
	if (rst)
		alu_op <=  `OR1200_ALUOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		alu_op <=  `OR1200_ALUOP_NOP;
	else if (!ex_freeze) begin
	  case (id_insn[31:26])		
	    `OR1200_OR32_J:
	      alu_op <=  `OR1200_ALUOP_IMM;
	    `OR1200_OR32_JAL:
	      alu_op <=  `OR1200_ALUOP_IMM;
	    `OR1200_OR32_BNF:
	      alu_op <=  `OR1200_ALUOP_NOP;
	    `OR1200_OR32_BF:
	      alu_op <=  `OR1200_ALUOP_NOP;
	    `OR1200_OR32_MOVHI:
	      alu_op <=  `OR1200_ALUOP_MOVHI;
	    `OR1200_OR32_MFSPR:
	      alu_op <=  `OR1200_ALUOP_MFSR;
	    `OR1200_OR32_MTSPR:
	      alu_op <=  `OR1200_ALUOP_MTSR;
	    `OR1200_OR32_ADDI:
	      alu_op <=  `OR1200_ALUOP_ADD;
	    `OR1200_OR32_ADDIC:
	      alu_op <=  `OR1200_ALUOP_ADDC;
	    `OR1200_OR32_ANDI:
	      alu_op <=  `OR1200_ALUOP_AND;
	    `OR1200_OR32_ORI:
	      alu_op <=  `OR1200_ALUOP_OR;
	    `OR1200_OR32_XORI:
	      alu_op <=  `OR1200_ALUOP_XOR;
	    `OR1200_OR32_MULI:
	      alu_op <=  `OR1200_ALUOP_MUL;
	    `OR1200_OR32_SH_ROTI:
	      alu_op <=  `OR1200_ALUOP_SHROT;
	    `OR1200_OR32_SFXXI:
	      alu_op <=  `OR1200_ALUOP_COMP;
	    `OR1200_OR32_ALU:
	      alu_op <=  id_insn[3:0];
	    `OR1200_OR32_SFXX:
	      alu_op <=  `OR1200_ALUOP_COMP;
	    `OR1200_OR32_CUST5:
	      alu_op <=  `OR1200_ALUOP_CUST5;	    
	    default: begin
	      alu_op <=  `OR1200_ALUOP_NOP;
	    end
	  endcase
	end
end
always @(posedge clk ) begin
	if (rst)
		mac_op <=  `OR1200_MACOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		mac_op <=  `OR1200_MACOP_NOP;
	else if (!ex_freeze)
	  case (id_insn[31:26])		
	    `OR1200_OR32_MACI:
	      mac_op <=  `OR1200_MACOP_MAC;
	    `OR1200_OR32_MACMSB:
	      mac_op <=  id_insn[1:0];
	    default: begin
	      mac_op <=  `OR1200_MACOP_NOP;
	    end	      
	  endcase
	else
		mac_op <=  `OR1200_MACOP_NOP;
end
always @(posedge clk ) begin
	if (rst)
		shrot_op <=  `OR1200_SHROTOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		shrot_op <=  `OR1200_SHROTOP_NOP;
	else if (!ex_freeze) begin
		shrot_op <=  id_insn[7:6];
	end
end
always @(posedge clk ) begin
	if (rst)
		rfwb_op <=  `OR1200_RFWBOP_NOP;
	else  if (!ex_freeze & id_freeze | flushpipe)
		rfwb_op <=  `OR1200_RFWBOP_NOP;
	else  if (!ex_freeze) begin
		case (id_insn[31:26])		
		  `OR1200_OR32_JAL:
		    rfwb_op <=  `OR1200_RFWBOP_LR;
		  `OR1200_OR32_JALR:
		    rfwb_op <=  `OR1200_RFWBOP_LR;
		  `OR1200_OR32_MOVHI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_MFSPR:
		    rfwb_op <=  `OR1200_RFWBOP_SPRS;
		  `OR1200_OR32_LWZ:
		    rfwb_op <=  `OR1200_RFWBOP_LSU;
		  `OR1200_OR32_LBZ:
		    rfwb_op <=  `OR1200_RFWBOP_LSU;
		  `OR1200_OR32_LBS:
		    rfwb_op <=  `OR1200_RFWBOP_LSU;
		  `OR1200_OR32_LHZ:
		    rfwb_op <=  `OR1200_RFWBOP_LSU;
		  `OR1200_OR32_LHS:
		    rfwb_op <=  `OR1200_RFWBOP_LSU;
		  `OR1200_OR32_ADDI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_ADDIC:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_ANDI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_ORI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_XORI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_MULI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_SH_ROTI:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_ALU:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  `OR1200_OR32_CUST5:
		    rfwb_op <=  `OR1200_RFWBOP_ALU;
		  default: begin
		    rfwb_op <=  `OR1200_RFWBOP_NOP;
		  end
		endcase
	end
end
always @(posedge clk ) begin
	if (rst)
		pre_branch_op <=  `OR1200_BRANCHOP_NOP;
	else if (flushpipe)
		pre_branch_op <=  `OR1200_BRANCHOP_NOP;
	else if (!id_freeze) begin
		case (if_insn[31:26])		
		  `OR1200_OR32_J:
		    pre_branch_op <=  `OR1200_BRANCHOP_BAL;
		  `OR1200_OR32_JAL:
		    pre_branch_op <=  `OR1200_BRANCHOP_BAL;
		  `OR1200_OR32_JALR:
		    pre_branch_op <=  `OR1200_BRANCHOP_JR;
		  `OR1200_OR32_JR:
		    pre_branch_op <=  `OR1200_BRANCHOP_JR;
		  `OR1200_OR32_BNF:
		    pre_branch_op <=  `OR1200_BRANCHOP_BNF;
		  `OR1200_OR32_BF:
		    pre_branch_op <=  `OR1200_BRANCHOP_BF;
		  `OR1200_OR32_RFE:
		    pre_branch_op <=  `OR1200_BRANCHOP_RFE;
		  default: begin
		    pre_branch_op <=  `OR1200_BRANCHOP_NOP;
		  end
		endcase
	end
end
always @(posedge clk )
	if (rst)
		branch_op <=  `OR1200_BRANCHOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		branch_op <=  `OR1200_BRANCHOP_NOP;		
	else if (!ex_freeze)
		branch_op <=  pre_branch_op;
always @(posedge clk ) begin
	if (rst)
		lsu_op <=  `OR1200_LSUOP_NOP;
	else if (!ex_freeze & id_freeze | flushpipe)
		lsu_op <=  `OR1200_LSUOP_NOP;
	else if (!ex_freeze)  begin
	  case (id_insn[31:26])		
	    `OR1200_OR32_LWZ:
	      lsu_op <=  `OR1200_LSUOP_LWZ;
	    `OR1200_OR32_LBZ:
	      lsu_op <=  `OR1200_LSUOP_LBZ;
	    `OR1200_OR32_LBS:
	      lsu_op <=  `OR1200_LSUOP_LBS;
	    `OR1200_OR32_LHZ:
	      lsu_op <=  `OR1200_LSUOP_LHZ;
	    `OR1200_OR32_LHS:
	      lsu_op <=  `OR1200_LSUOP_LHS;
	    `OR1200_OR32_SW:
	      lsu_op <=  `OR1200_LSUOP_SW;
	    `OR1200_OR32_SB:
	      lsu_op <=  `OR1200_LSUOP_SB;
	    `OR1200_OR32_SH:
	      lsu_op <=  `OR1200_LSUOP_SH;
	    default: begin
	      lsu_op <=  `OR1200_LSUOP_NOP;
	    end
	  endcase
	end
end
always @(posedge clk ) begin
	if (rst) begin
		comp_op <=  4'b0000;
	end else if (!ex_freeze & id_freeze | flushpipe)
		comp_op <=  4'b0000;
	else if (!ex_freeze)
		comp_op <=  id_insn[24:21];
end
always @(posedge clk ) begin
	if (rst)
		sig_syscall <=  1'b0;
	else if (!ex_freeze & id_freeze | flushpipe)
		sig_syscall <=  1'b0;
	else if (!ex_freeze) begin
		sig_syscall <=  (id_insn[31:23] == {`OR1200_OR32_XSYNC, 3'b000});
	end
end
always @(posedge clk ) begin
	if (rst)
		sig_trap <=  1'b0;
	else if (!ex_freeze & id_freeze | flushpipe)
		sig_trap <=  1'b0;
	else if (!ex_freeze) begin
		sig_trap <=  (id_insn[31:23] == {`OR1200_OR32_XSYNC, 3'b010})
			| du_hwbkpt;
	end
end
endmodule
module or1200_rf(
	clk, rst,
	supv, wb_freeze, addrw, dataw,id_freeze, we, flushpipe,
 addra, rda, dataa,  addrb,rdb, datab, 
	spr_cs, spr_write, spr_addr, spr_dat_i, spr_dat_o
);
input				clk;
input				rst;
input				supv;
input				wb_freeze;
input	[`OR1200_REGFILE_ADDR_WIDTH-1:0]		addrw;
input	[`OR1200_OPERAND_WIDTH-1:0]		dataw;
input				we;
input				flushpipe;
input				id_freeze;
input	[`OR1200_REGFILE_ADDR_WIDTH-1:0]		addra;
input	[`OR1200_REGFILE_ADDR_WIDTH-1:0]		addrb;
output	[`OR1200_OPERAND_WIDTH-1:0]		dataa;
output	[`OR1200_OPERAND_WIDTH-1:0]		datab;
input				rda;
input				rdb;
input				spr_cs;
input				spr_write;
input	[31:0]			spr_addr;
input	[31:0]			spr_dat_i;
output	[31:0]			spr_dat_o;
wire	[`OR1200_OPERAND_WIDTH-1:0]		from_rfa;
wire	[`OR1200_OPERAND_WIDTH-1:0]		from_rfb;
reg	[`OR1200_OPERAND_WIDTH:0]			dataa_saved;
reg	[`OR1200_OPERAND_WIDTH:0]			datab_saved;
wire	[`OR1200_REGFILE_ADDR_WIDTH-1:0]		rf_addra;
wire	[`OR1200_REGFILE_ADDR_WIDTH-1:0]		rf_addrw;
wire	[`OR1200_OPERAND_WIDTH-1:0]		rf_dataw;
wire				rf_we;
wire				spr_valid;
wire				rf_ena;
wire				rf_enb;
reg				rf_we_allow;
assign spr_valid = spr_cs & (spr_addr[10:5] == `OR1200_SPR_RF);
assign spr_dat_o = from_rfa;
assign dataa = (dataa_saved[32]) ? dataa_saved[31:0] : from_rfa;
assign datab = (datab_saved[32]) ? datab_saved[31:0] : from_rfb;
assign rf_addra = (spr_valid & !spr_write) ? spr_addr[4:0] : addra;
assign rf_addrw = (spr_valid & spr_write) ? spr_addr[4:0] : addrw;
assign rf_dataw = (spr_valid & spr_write) ? spr_dat_i : dataw;
always @(posedge clk)
	if (rst)
		rf_we_allow <=  1'b1;
	else if (~wb_freeze)
		rf_we_allow <= ~flushpipe;
assign rf_we = ((spr_valid & spr_write) | (we & ~wb_freeze)) & rf_we_allow & (supv | (|rf_addrw));
assign rf_ena = rda & ~id_freeze | spr_valid;	
assign rf_enb = rdb & ~id_freeze | spr_valid;
always @(posedge clk )
	if (rst) begin
		dataa_saved <=33'b000000000000000000000000000000000;
	end
	else if (id_freeze & !dataa_saved[32]) begin
		dataa_saved <= {1'b1, from_rfa};
	end
	else if (!id_freeze)
		dataa_saved <=33'b000000000000000000000000000000000;
always @(posedge clk)
	if (rst) begin
		datab_saved <=  33'b000000000000000000000000000000000;
	end
	else if (id_freeze & !datab_saved[32]) begin
		datab_saved <=  {1'b1, from_rfb};
	end
	else if (!id_freeze)
		datab_saved <=  33'b000000000000000000000000000000000;
wire const_one;
wire const_zero;
assign const_one = 1'b1;
assign const_zero = 1'b0;
wire [31:0] const_zero_data;
assign const_zero_data = 32'b00000000000000000000000000000000;
wire [31:0] dont_care_out;
wire [31:0] dont_care_out2;
dual_port_ram rf_a(	
  .clk (clk),
  .we1(const_zero),
  .we2(rf_we),
  .data1(const_zero_data),
  .data2(rf_dataw),
  .out1(from_rfa),
  .out2 (dont_care_out),
  .addr1(rf_addra),
  .addr2(rf_addrw));
dual_port_ram rf_b(	
  .clk (clk),
  .we1(const_zero),
  .we2(rf_we),
  .data1(const_zero_data),
  .data2(rf_dataw),
  .out1(from_rfb),
  .out2 (dont_care_out2),
  .addr1(addrb),
  .addr2(rf_addrw));
wire unused;
assign unused = |spr_addr;
endmodule
module or1200_operandmuxes(
	clk, rst,
	id_freeze, ex_freeze, rf_dataa, rf_datab, ex_forw, wb_forw,
	simm, sel_a, sel_b, operand_a, operand_b, muxed_b
);
input				clk;
input				rst;
input				id_freeze;
input				ex_freeze;
input	[`OR1200_OPERAND_WIDTH-1:0]		rf_dataa;
input	[`OR1200_OPERAND_WIDTH-1:0]		rf_datab;
input	[`OR1200_OPERAND_WIDTH-1:0]		ex_forw;
input	[`OR1200_OPERAND_WIDTH-1:0]		wb_forw;
input	[`OR1200_OPERAND_WIDTH-1:0]		simm;
input	[`OR1200_SEL_WIDTH-1:0]	sel_a;
input	[`OR1200_SEL_WIDTH-1:0]	sel_b;
output	[`OR1200_OPERAND_WIDTH-1:0]		operand_a;
output	[`OR1200_OPERAND_WIDTH-1:0]		operand_b;
output	[`OR1200_OPERAND_WIDTH-1:0]		muxed_b;
reg	[`OR1200_OPERAND_WIDTH-1:0]		operand_a;
reg	[`OR1200_OPERAND_WIDTH-1:0]		operand_b;
reg	[`OR1200_OPERAND_WIDTH-1:0]		muxed_a;
reg	[`OR1200_OPERAND_WIDTH-1:0]		muxed_b;
reg				saved_a;
reg				saved_b;
always @(posedge clk ) begin
	if (rst) begin
		operand_a <=  32'b0000000000000000000000000000;
		saved_a <=  1'b0;
	end else if (!ex_freeze && id_freeze && !saved_a) begin
		operand_a <=  muxed_a;
		saved_a <=  1'b1;
	end else if (!ex_freeze && !saved_a) begin
		operand_a <=  muxed_a;
	end else if (!ex_freeze && !id_freeze)
		saved_a <=  1'b0;
end
always @(posedge clk ) begin
	if (rst) begin
		operand_b <=  32'b0000000000000000000000000000;
		saved_b <=  1'b0;
	end else if (!ex_freeze && id_freeze && !saved_b) begin
		operand_b <=  muxed_b;
		saved_b <=  1'b1;
	end else if (!ex_freeze && !saved_b) begin
		operand_b <=  muxed_b;
	end else if (!ex_freeze && !id_freeze)
		saved_b <=  1'b0;
end
always @(ex_forw or wb_forw or rf_dataa or sel_a) begin
	case (sel_a)	
		`OR1200_SEL_EX_FORW:
			muxed_a = ex_forw;
		`OR1200_SEL_WB_FORW:
			muxed_a = wb_forw;
		default:
			muxed_a = rf_dataa;
	endcase
end
always @(simm or ex_forw or wb_forw or rf_datab or sel_b) begin
	case (sel_b)	
		`OR1200_SEL_IMM:
			muxed_b = simm;
		`OR1200_SEL_EX_FORW:
			muxed_b = ex_forw;
		`OR1200_SEL_WB_FORW:
			muxed_b = wb_forw;
		default:
			muxed_b = rf_datab;
	endcase
end
endmodule
module or1200_alu(
	a, b, mult_mac_result, macrc_op,
	alu_op, shrot_op, comp_op,
	cust5_op, cust5_limm,
	result, flagforw, flag_we,
	cyforw, cy_we, flag,k_carry
);
input	[32-1:0]		a;
input	[32-1:0]		b;
input	[32-1:0]		mult_mac_result;
input				macrc_op;
input	[`OR1200_ALUOP_WIDTH-1:0]	alu_op;
input	[2-1:0]	shrot_op;
input	[4-1:0]	comp_op;
input	[4:0]			cust5_op;
input	[5:0]			cust5_limm;
output	[32-1:0]		result;
output				flagforw;
output				flag_we;
output				cyforw;
output				cy_we;
input				k_carry;
input         flag;
reg	[32-1:0]		result;
reg	[32-1:0]		shifted_rotated;
reg	[32-1:0]		result_cust5;
reg				flagforw;
reg				flagcomp;
reg				flag_we;
reg				cy_we;
wire	[32-1:0]		comp_a;
wire	[32-1:0]		comp_b;
wire				a_eq_b;
wire				a_lt_b;
wire	[32-1:0]		result_sum;
wire	[32-1:0]		result_csum;
wire				cy_csum;
wire	[32-1:0]		result_and;
wire				cy_sum;
reg				cyforw;
assign comp_a [31:3]= a[31] ^ comp_op[3];
assign comp_a [2:0] = a[30:0];
assign comp_b [31:3]  = b[31] ^ comp_op[3] ;
assign comp_b [2:0] =  b[32-2:0];
assign a_eq_b = (comp_a == comp_b);
assign a_lt_b = (comp_a < comp_b);
assign cy_sum= a + b;
assign result_sum = a+b;
assign cy_csum =a + b + {32'b00000000000000000000000000000000, k_carry};
assign result_csum = a + b + {32'b00000000000000000000000000000000, k_carry};
assign result_and = a & b;
always @(alu_op or a or b or result_sum or result_and or macrc_op or shifted_rotated or mult_mac_result) 
begin
	case (alu_op)		
    4'b1111: begin
        result = a[0] ? 1 : a[1] ? 2 : a[2] ? 3 : a[3] ? 4 : a[4] ? 5 : a[5] ? 6 : a[6] ? 7 : a[7] ? 8 : a[8] ? 9 : a[9] ? 10 : a[10] ? 11 : a[11] ? 12 : a[12] ? 13 : a[13] ? 14 : a[14] ? 15 : a[15] ? 16 : a[16] ? 17 : a[17] ? 18 : a[18] ? 19 : a[19] ? 20 : a[20] ? 21 : a[21] ? 22 : a[22] ? 23 : a[23] ? 24 : a[24] ? 25 : a[25] ? 26 : a[26] ? 27 : a[27] ? 28 : a[28] ? 29 : a[29] ? 30 : a[30] ? 31 : a[31] ? 32 : 0;
    end
		`OR1200_ALUOP_CUST5 : begin 
				result = result_cust5;
		end
		`OR1200_ALUOP_SHROT : begin 
				result = shifted_rotated;
		end
		`OR1200_ALUOP_ADD : begin
				result = result_sum;
		end
		`OR1200_ALUOP_ADDC : begin
				result = result_csum;
		end
		`OR1200_ALUOP_SUB : begin
				result = a - b;
		end
		`OR1200_ALUOP_XOR : begin
				result = a ^ b;
		end
		`OR1200_ALUOP_OR  : begin
				result = a | b;
		end
		`OR1200_ALUOP_IMM : begin
				result = b;
		end
		`OR1200_ALUOP_MOVHI : begin
				if (macrc_op) begin
					result = mult_mac_result;
				end
				else begin
					result = b << 16;
				end
		end
		`OR1200_ALUOP_MUL : begin
				result = mult_mac_result;
		end
    4'b1110: begin
        result = flag ? a : b;
    end
    default: 
    begin
      result=result_and;
    end 
	endcase
end
always @(cust5_op or cust5_limm or a or b) begin
	case (cust5_op)		
		5'h1 : begin 
			case (cust5_limm[1:0])
				2'h0: result_cust5 = {a[31:8], b[7:0]};
				2'h1: result_cust5 = {a[31:16], b[7:0], a[7:0]};
				2'h2: result_cust5 = {a[31:24], b[7:0], a[15:0]};
				2'h3: result_cust5 = {b[7:0], a[23:0]};
			endcase
		end
		5'h2 :
			result_cust5 = a | (1 << 4);
		5'h3 :
			result_cust5 = a & (32'b11111111111111111111111111111111^ (cust5_limm));
		default: begin
			result_cust5 = a;
		end
	endcase
end
always @(alu_op or result_sum or result_and or flagcomp) begin
	case (alu_op)		
		`OR1200_ALUOP_ADD : begin
			flagforw = (result_sum == 32'b00000000000000000000000000000000);
			flag_we = 1'b1;
		end
		`OR1200_ALUOP_ADDC : begin
			flagforw = (result_csum == 32'b00000000000000000000000000000000);
			flag_we = 1'b1;
		end
		`OR1200_ALUOP_AND: begin
			flagforw = (result_and == 32'b00000000000000000000000000000000);
			flag_we = 1'b1;
		end
		`OR1200_ALUOP_COMP: begin
			flagforw = flagcomp;
			flag_we = 1'b1;
		end
		default: begin
			flagforw = 1'b0;
			flag_we = 1'b0;
		end
	endcase
end
always @(alu_op or cy_sum
	) begin
	case (alu_op)		
		`OR1200_ALUOP_ADD : begin
			cyforw = cy_sum;
			cy_we = 1'b1;
		end
		`OR1200_ALUOP_ADDC: begin
			cyforw = cy_csum;
			cy_we = 1'b1;
		end
		default: begin
			cyforw = 1'b0;
			cy_we = 1'b0;
		end
	endcase
end
always @(shrot_op or a or b) begin
	case (shrot_op)		
	2'b00 :
				shifted_rotated = (a << 2);
		`OR1200_SHROTOP_SRL :
				shifted_rotated = (a >> 2);
		`OR1200_SHROTOP_ROR :
				shifted_rotated = (a << 1'b1);
		default:
				shifted_rotated = (a << 1);
	endcase
end
always @(comp_op or a_eq_b or a_lt_b) begin
	case(comp_op[2:0])	
		`OR1200_COP_SFEQ:
			flagcomp = a_eq_b;
		`OR1200_COP_SFNE:
			flagcomp = ~a_eq_b;
		`OR1200_COP_SFGT:
			flagcomp = ~(a_eq_b | a_lt_b);
		`OR1200_COP_SFGE:
			flagcomp = ~a_lt_b;
		`OR1200_COP_SFLT:
			flagcomp = a_lt_b;
		`OR1200_COP_SFLE:
			flagcomp = a_eq_b | a_lt_b;
		default:
			flagcomp = 1'b0;
	endcase
end
endmodule
module or1200_mult_mac(
	clk, rst,
	ex_freeze, id_macrc_op, macrc_op, a, b, mac_op, alu_op, result, mac_stall_r,
	spr_cs, spr_write, spr_addr, spr_dat_i, spr_dat_o
);
input				clk;
input				rst;
input				ex_freeze;
input				id_macrc_op;
input				macrc_op;
input	[`OR1200_OPERAND_WIDTH-1:0]		a;
input	[`OR1200_OPERAND_WIDTH-1:0]		b;
input	[`OR1200_MACOP_WIDTH-1:0]	mac_op;
input	[`OR1200_ALUOP_WIDTH-1:0]	alu_op;
output	[`OR1200_OPERAND_WIDTH-1:0]		result;
output				mac_stall_r;
input				spr_cs;
input				spr_write;
input	[31:0]			spr_addr;
input	[31:0]			spr_dat_i;
output	[31:0]			spr_dat_o;
reg	[`OR1200_OPERAND_WIDTH-1:0]		result;
reg	[2*`OR1200_OPERAND_WIDTH-1:0]		mul_prod_r;
wire	[2*`OR1200_OPERAND_WIDTH-1:0]		mul_prod;
wire	[`OR1200_MACOP_WIDTH-1:0]	mac_op;
reg	[`OR1200_MACOP_WIDTH-1:0]	mac_op_r1;
reg	[`OR1200_MACOP_WIDTH-1:0]	mac_op_r2;
reg	[`OR1200_MACOP_WIDTH-1:0]	mac_op_r3;
reg				mac_stall_r;
reg	[2*`OR1200_OPERAND_WIDTH-1:0]		mac_r;
wire	[`OR1200_OPERAND_WIDTH-1:0]		x;
wire	[`OR1200_OPERAND_WIDTH-1:0]		y;
wire				spr_maclo_we;
wire				spr_machi_we;
wire				alu_op_div_divu;
wire				alu_op_div;
reg				div_free;
wire	[`OR1200_OPERAND_WIDTH-1:0]		div_tmp;
reg	[5:0]			div_cntr;
assign spr_maclo_we = spr_cs & spr_write & spr_addr[`OR1200_MAC_ADDR];
assign spr_machi_we = spr_cs & spr_write & !spr_addr[`OR1200_MAC_ADDR];
assign spr_dat_o = spr_addr[`OR1200_MAC_ADDR] ? mac_r[31:0] : mac_r[63:32];
assign x = (alu_op_div & a[31]) ? ~a + 1'b1 : alu_op_div_divu | (alu_op == `OR1200_ALUOP_MUL) | (|mac_op) ? a : 32'h00000000;
assign y = (alu_op_div & b[31]) ? ~b + 1'b1 : alu_op_div_divu | (alu_op == `OR1200_ALUOP_MUL) | (|mac_op) ? b : 32'h00000000;
assign alu_op_div = (alu_op == `OR1200_ALUOP_DIV);
assign alu_op_div_divu = alu_op_div | (alu_op == `OR1200_ALUOP_DIVU);
assign div_tmp = mul_prod_r[63:32] - y;
always @(alu_op or mul_prod_r or mac_r or a or b)
	case(alu_op)	
		`OR1200_ALUOP_DIV:
			result = a[31] ^ b[31] ? ~mul_prod_r[31:0] + 1'b1 : mul_prod_r[31:0];
		`OR1200_ALUOP_DIVU:
		begin
			result = mul_prod_r[31:0];
		end
		`OR1200_ALUOP_MUL: begin
			result = mul_prod_r[31:0];
		end
		default:
		result = mac_r[31:0];
	endcase
assign mul_prod = x * y;
always @(posedge clk)
	if (rst) begin
		mul_prod_r <=  64'h0000000000000000;
		div_free <=  1'b1;
		div_cntr <=  6'b000000;
	end
	else if (|div_cntr) begin
		if (div_tmp[31])
			mul_prod_r <=  {mul_prod_r[62:0], 1'b0};
		else
			mul_prod_r <=  {div_tmp[30:0], mul_prod_r[31:0], 1'b1};
		div_cntr <=  div_cntr - 1'b1;
	end
	else if (alu_op_div_divu && div_free) begin
		mul_prod_r <=  {31'b0000000000000000000000000000000, x[31:0], 1'b0};
		div_cntr <=  6'b100000;
		div_free <=  1'b0;
	end
	else if (div_free | !ex_freeze) begin
		mul_prod_r <=  mul_prod[63:0];
		div_free <=  1'b1;
	end
always @(posedge clk)
	if (rst)
		mac_op_r1 <=  2'b00;
	else
		mac_op_r1 <=  mac_op;
always @(posedge clk)
	if (rst)
		mac_op_r2 <=  2'b00;
	else
		mac_op_r2 <=  mac_op_r1;
always @(posedge clk )
	if (rst)
		mac_op_r3 <=  2'b00;
	else
		mac_op_r3 <=  mac_op_r2;
always @(posedge clk)
	if (rst)
		mac_r <=  64'h0000000000000000;
	else if (spr_maclo_we)
		mac_r[31:0] <=  spr_dat_i;
	else if (spr_machi_we)
		mac_r[63:32] <=  spr_dat_i;
	else if (mac_op_r3 == `OR1200_MACOP_MAC)
		mac_r <=  mac_r + mul_prod_r;
	else if (mac_op_r3 == `OR1200_MACOP_MSB)
		mac_r <=  mac_r - mul_prod_r;
	else if (macrc_op & !ex_freeze)
		mac_r <=  64'h0000000000000000;
wire unused;
assign unused = |spr_addr;
always @( posedge clk)
	if (rst)
		mac_stall_r <=  1'b0;
	else
		mac_stall_r <=  (|mac_op | (|mac_op_r1) | (|mac_op_r2)) & id_macrc_op
				| (|div_cntr)
				;
endmodule
module or1200_sprs(
		clk, rst,
			addrbase, addrofs, dat_i, alu_op, 
		flagforw, flag_we, flag, cyforw, cy_we, carry,	to_wbmux,
		du_addr, du_dat_du, du_read,
		du_write, du_dat_cpu,
		spr_addr,spr_dat_pic, spr_dat_tt, spr_dat_pm,
		spr_dat_cfgr, spr_dat_rf, spr_dat_npc, spr_dat_ppc, spr_dat_mac,
		spr_dat_dmmu, spr_dat_immu, spr_dat_du, spr_dat_o, spr_cs, spr_we,
		 epcr_we, eear_we,esr_we, pc_we,epcr, eear, esr, except_started,
		sr_we, to_sr, sr,branch_op
);
input				clk; 		
input 				rst;		
input 				flagforw;	
input 				flag_we;	
output 				flag;		
input 				cyforw;		
input 				cy_we;		
output 				carry;		
input	[`OR1200_OPERAND_WIDTH-1:0] 		addrbase;	
input	[15:0] 			addrofs;	
input	[`OR1200_OPERAND_WIDTH-1:0]		dat_i;		
input	[`OR1200_ALUOP_WIDTH-1:0]	alu_op;		
input	[`OR1200_BRANCHOP_WIDTH-1:0]	branch_op;	
input	[`OR1200_OPERAND_WIDTH-1:0] 		epcr;		
input	[`OR1200_OPERAND_WIDTH-1:0] 		eear;		
input	[`OR1200_SR_WIDTH-1:0] 	esr;		
input 				except_started; 
output	[`OR1200_OPERAND_WIDTH-1:0]		to_wbmux;	
output				epcr_we;	
output				eear_we;	
output				esr_we;		
output				pc_we;		
output 				sr_we;		
output	[`OR1200_SR_WIDTH-1:0]	to_sr;		
output	[`OR1200_SR_WIDTH-1:0]	sr;		
input	[31:0]			spr_dat_cfgr;	
input	[31:0]			spr_dat_rf;	
input	[31:0]			spr_dat_npc;	
input	[31:0]			spr_dat_ppc;	
input	[31:0]			spr_dat_mac;	
input	[31:0]			spr_dat_pic;	
input	[31:0]			spr_dat_tt;	
input	[31:0]			spr_dat_pm;	
input	[31:0]			spr_dat_dmmu;	
input	[31:0]			spr_dat_immu;	
input	[31:0]			spr_dat_du;	
output	[31:0]			spr_addr;	
output	[31:0]			spr_dat_o;	
output	[31:0]			spr_cs;		
output				spr_we;		
input	[`OR1200_OPERAND_WIDTH-1:0]		du_addr;	
input	[`OR1200_OPERAND_WIDTH-1:0]		du_dat_du;	
input				du_read;	
input				du_write;	
output	[`OR1200_OPERAND_WIDTH-1:0]		du_dat_cpu;	
reg	[`OR1200_SR_WIDTH-1:0]		sr;		
reg				write_spr;	
reg				read_spr;	
reg	[`OR1200_OPERAND_WIDTH-1:0]		to_wbmux;	
wire				cfgr_sel;	
wire				rf_sel;		
wire				npc_sel;	
wire				ppc_sel;	
wire 				sr_sel;		
wire 				epcr_sel;	
wire 				eear_sel;	
wire 				esr_sel;	
wire	[31:0]			sys_data;	
wire				du_access;	
wire	[`OR1200_ALUOP_WIDTH-1:0]	sprs_op;	
reg	[31:0]			unqualified_cs;	
assign du_access = du_read | du_write;
assign sprs_op = du_write ? `OR1200_ALUOP_MTSR : du_read ? `OR1200_ALUOP_MFSR : alu_op;
assign spr_addr = du_access ? du_addr : addrbase | {16'h0000, addrofs};
assign spr_dat_o = du_write ? du_dat_du : dat_i;
assign du_dat_cpu = du_write ? du_dat_du : du_read ? to_wbmux : dat_i;
assign spr_we = du_write | write_spr;
assign spr_cs = unqualified_cs & {{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr},{read_spr | write_spr}};
always @(spr_addr)
	case (spr_addr[15:11])	
		5'b00000: unqualified_cs = 32'b00000000000000000000000000000001;
		5'b00001: unqualified_cs = 32'b00000000000000000000000000000010;
		5'b00010: unqualified_cs = 32'b00000000000000000000000000000100;
		5'b00011: unqualified_cs = 32'b00000000000000000000000000001000;
		5'b00100: unqualified_cs = 32'b00000000000000000000000000010000;
		5'b00101: unqualified_cs = 32'b00000000000000000000000000100000;
		5'b00110: unqualified_cs = 32'b00000000000000000000000001000000;
		5'b00111: unqualified_cs = 32'b00000000000000000000000010000000;
		5'b01000: unqualified_cs = 32'b00000000000000000000000100000000;
		5'b01001: unqualified_cs = 32'b00000000000000000000001000000000;
		5'b01010: unqualified_cs = 32'b00000000000000000000010000000000;
		5'b01011: unqualified_cs = 32'b00000000000000000000100000000000;
		5'b01100: unqualified_cs = 32'b00000000000000000001000000000000;
		5'b01101: unqualified_cs = 32'b00000000000000000010000000000000;
		5'b01110: unqualified_cs = 32'b00000000000000000100000000000000;
		5'b01111: unqualified_cs = 32'b00000000000000001000000000000000;
		5'b10000: unqualified_cs = 32'b00000000000000010000000000000000;
		5'b10001: unqualified_cs = 32'b00000000000000100000000000000000;
		5'b10010: unqualified_cs = 32'b00000000000001000000000000000000;
		5'b10011: unqualified_cs = 32'b00000000000010000000000000000000;
		5'b10100: unqualified_cs = 32'b00000000000100000000000000000000;
		5'b10101: unqualified_cs = 32'b00000000001000000000000000000000;
		5'b10110: unqualified_cs = 32'b00000000010000000000000000000000;
		5'b10111: unqualified_cs = 32'b00000000100000000000000000000000;
		5'b11000: unqualified_cs = 32'b00000001000000000000000000000000;
		5'b11001: unqualified_cs = 32'b00000010000000000000000000000000;
		5'b11010: unqualified_cs = 32'b00000100000000000000000000000000;
		5'b11011: unqualified_cs = 32'b00001000000000000000000000000000;
		5'b11100: unqualified_cs = 32'b00010000000000000000000000000000;
		5'b11101: unqualified_cs = 32'b00100000000000000000000000000000;
		5'b11110: unqualified_cs = 32'b01000000000000000000000000000000;
		5'b11111: unqualified_cs = 32'b10000000000000000000000000000000;
	endcase
assign to_sr[`OR1200_SR_FO:`OR1200_SR_OV] =
		(branch_op == `OR1200_BRANCHOP_RFE) ? esr[`OR1200_SR_FO:`OR1200_SR_OV] :
		(write_spr && sr_sel) ? {1'b1, spr_dat_o[`OR1200_SR_FO-1:`OR1200_SR_OV]}:
		sr[`OR1200_SR_FO:`OR1200_SR_OV];
assign to_sr[`OR1200_SR_CY] =
		(branch_op == `OR1200_BRANCHOP_RFE) ? esr[`OR1200_SR_CY] :
		cy_we ? cyforw :
		(write_spr && sr_sel) ? spr_dat_o[`OR1200_SR_CY] :
		sr[`OR1200_SR_CY];
assign to_sr[`OR1200_SR_F] =
		(branch_op == `OR1200_BRANCHOP_RFE) ? esr[`OR1200_SR_F] :
		flag_we ? flagforw :
		(write_spr && sr_sel) ? spr_dat_o[`OR1200_SR_F] :
		sr[`OR1200_SR_F];
assign to_sr[`OR1200_SR_CE:`OR1200_SR_SM] =
		(branch_op == `OR1200_BRANCHOP_RFE) ? esr[`OR1200_SR_CE:`OR1200_SR_SM] :
		(write_spr && sr_sel) ? spr_dat_o[`OR1200_SR_CE:`OR1200_SR_SM]:
		sr[`OR1200_SR_CE:`OR1200_SR_SM];
assign cfgr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:4] == `OR1200_SPR_CFGR));
assign rf_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:5] == `OR1200_SPR_RF));
assign npc_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_NPC));
assign ppc_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_PPC));
assign sr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_SR));
assign epcr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_EPCR));
assign eear_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_EEAR));
assign esr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_ESR));
assign sr_we = (write_spr && sr_sel) | (branch_op == `OR1200_BRANCHOP_RFE) | flag_we | cy_we;
assign pc_we = (write_spr && (npc_sel | ppc_sel));
assign epcr_we = (write_spr && epcr_sel);
assign eear_we = (write_spr && eear_sel);
assign esr_we = (write_spr && esr_sel);
assign sys_data = (spr_dat_cfgr & {{read_spr & cfgr_sel}}) |
		  (spr_dat_rf & {{read_spr & rf_sel}}) |
		  (spr_dat_npc & {{read_spr & npc_sel}}) |
		  (spr_dat_ppc & {{read_spr & ppc_sel}}) |
		  ({{{16'b0000000000000000}},sr} & {{read_spr & sr_sel}}) |
		  (epcr & {{read_spr & epcr_sel}}) |
		  (eear & {{read_spr & eear_sel}}) |
		  ({{{16'b0000000000000000}},esr} & {{read_spr & esr_sel}});
assign flag = sr[`OR1200_SR_F];
assign carry = sr[`OR1200_SR_CY];
always @(posedge clk)
	if (rst)
		sr <=  {1'b1, `OR1200_SR_EPH_DEF, {{13'b0000000000000}}, 1'b1};
	else if (except_started) begin
		sr[`OR1200_SR_SM]  <=  1'b1;
		sr[`OR1200_SR_TEE] <=  1'b0;
		sr[`OR1200_SR_IEE] <=  1'b0;
		sr[`OR1200_SR_DME] <=  1'b0;
		sr[`OR1200_SR_IME] <=  1'b0;
	end
	else if (sr_we)
		sr <=  to_sr[`OR1200_SR_WIDTH-1:0];
always @(sprs_op or spr_addr or sys_data or spr_dat_mac or spr_dat_pic or spr_dat_pm or
	spr_dat_dmmu or spr_dat_immu or spr_dat_du or spr_dat_tt) begin
	case (sprs_op)	
		`OR1200_ALUOP_MTSR : begin
			write_spr = 1'b1;
			read_spr = 1'b0;
			to_wbmux = 32'b00000000000000000000000000000000;
		end
		`OR1200_ALUOP_MFSR : begin
			case (spr_addr[15:11]) 
				`OR1200_SPR_GROUP_TT:
					to_wbmux = spr_dat_tt;
				`OR1200_SPR_GROUP_PIC:
					to_wbmux = spr_dat_pic;
				`OR1200_SPR_GROUP_PM:
					to_wbmux = spr_dat_pm;
				`OR1200_SPR_GROUP_DMMU:
					to_wbmux = spr_dat_dmmu;
				`OR1200_SPR_GROUP_IMMU:
					to_wbmux = spr_dat_immu;
				`OR1200_SPR_GROUP_MAC:
					to_wbmux = spr_dat_mac;
				`OR1200_SPR_GROUP_DU:
					to_wbmux = spr_dat_du;
				`OR1200_SPR_GROUP_SYS:
					to_wbmux = sys_data;
				default:
					to_wbmux = 32'b00000000000000000000000000000000;
			endcase
			write_spr = 1'b0;
			read_spr = 1'b1;
		end
		default : begin
			write_spr = 1'b0;
			read_spr = 1'b0;
			to_wbmux = 32'b00000000000000000000000000000000;
		end
	endcase
end
endmodule
`define OR1200_NO_FREEZE	3'b000
`define OR1200_FREEZE_BYDC	3'b001
`define OR1200_FREEZE_BYMULTICYCLE	3'b010
`define OR1200_WAIT_LSU_TO_FINISH	3'b011
`define OR1200_WAIT_IC			3'b100
module or1200_freeze(
	clk, rst,
	multicycle, flushpipe, extend_flush, lsu_stall, if_stall,
	lsu_unstall,  
	force_dslot_fetch, abort_ex, du_stall,  mac_stall,
	genpc_freeze, if_freeze, id_freeze, ex_freeze, wb_freeze,
	icpu_ack_i, icpu_err_i
);
input				clk;
input				rst;
input	[`OR1200_MULTICYCLE_WIDTH-1:0]	multicycle;
input				flushpipe;
input				extend_flush;
input				lsu_stall;
input				if_stall;
input				lsu_unstall;
input				force_dslot_fetch;
input				abort_ex;
input				du_stall;
input				mac_stall;
output				genpc_freeze;
output				if_freeze;
output				id_freeze;
output				ex_freeze;
output				wb_freeze;
input				icpu_ack_i;
input				icpu_err_i;
wire				multicycle_freeze;
reg	[`OR1200_MULTICYCLE_WIDTH-1:0]	multicycle_cnt;
reg				flushpipe_r;
assign genpc_freeze = du_stall | flushpipe_r;
assign if_freeze = id_freeze | extend_flush;
assign id_freeze = (lsu_stall | (~lsu_unstall & if_stall) | multicycle_freeze | force_dslot_fetch) | du_stall | mac_stall;
assign ex_freeze = wb_freeze;
assign wb_freeze = (lsu_stall | (~lsu_unstall & if_stall) | multicycle_freeze) | du_stall | mac_stall | abort_ex;
always @(posedge clk )
	if (rst)
		flushpipe_r <=  1'b0;
	else if (icpu_ack_i | icpu_err_i)
		flushpipe_r <=  flushpipe;
	else if (!flushpipe)
		flushpipe_r <=  1'b0;
assign multicycle_freeze = |multicycle_cnt;
always @(posedge clk )
	if (rst)
		multicycle_cnt <=  2'b00;
	else if (|multicycle_cnt)
		multicycle_cnt <=  multicycle_cnt - 2'b01;
	else if (|multicycle & !ex_freeze)
		multicycle_cnt <=  multicycle;
endmodule
`define OR1200_EXCEPTFSM_WIDTH 3
`define OR1200_EXCEPTFSM_IDLE	3'b000
`define OR1200_EXCEPTFSM_FLU1 	3'b001
`define OR1200_EXCEPTFSM_FLU2 	3'b010
`define OR1200_EXCEPTFSM_FLU3 	3'b011
`define OR1200_EXCEPTFSM_FLU5 	3'b101
`define OR1200_EXCEPTFSM_FLU4 	3'b100
module or1200_except(
	clk, rst, 
	sig_ibuserr, sig_dbuserr, sig_illegal, sig_align, sig_range, sig_dtlbmiss, sig_dmmufault,
	sig_int, sig_syscall, sig_trap, sig_itlbmiss, sig_immufault, sig_tick,
	branch_taken,icpu_ack_i, icpu_err_i, dcpu_ack_i, dcpu_err_i,
	genpc_freeze, id_freeze, ex_freeze, wb_freeze, if_stall,
	if_pc, id_pc, lr_sav, flushpipe, extend_flush, except_type, except_start,
	except_started, except_stop, ex_void,
	spr_dat_ppc, spr_dat_npc, datain, du_dsr, epcr_we, eear_we, esr_we, pc_we, epcr, eear,
	esr, lsu_addr, sr_we, to_sr, sr, abort_ex
);
input				clk;
input				rst;
input				sig_ibuserr;
input				sig_dbuserr;
input				sig_illegal;
input				sig_align;
input				sig_range;
input				sig_dtlbmiss;
input				sig_dmmufault;
input				sig_int;
input				sig_syscall;
input				sig_trap;
input				sig_itlbmiss;
input				sig_immufault;
input				sig_tick;
input				branch_taken;
input				genpc_freeze;
input				id_freeze;
input				ex_freeze;
input				wb_freeze;
input				if_stall;
input	[31:0]			if_pc;
output	[31:0]			id_pc;
output	[31:2]			lr_sav;
input	[31:0]			datain;
input   [`OR1200_DU_DSR_WIDTH-1:0]     du_dsr;
input				epcr_we;
input				eear_we;
input				esr_we;
input				pc_we;
output	[31:0]			epcr;
output	[31:0]			eear;
output	[`OR1200_SR_WIDTH-1:0]	esr;
input	[`OR1200_SR_WIDTH-1:0]	to_sr;
input				sr_we;
input	[`OR1200_SR_WIDTH-1:0]	sr;
input	[31:0]			lsu_addr;
output				flushpipe;
output				extend_flush;
output	[`OR1200_EXCEPT_WIDTH-1:0]	except_type;
output				except_start;
output				except_started;
output	[12:0]			except_stop;
input				ex_void;
output	[31:0]			spr_dat_ppc;
output	[31:0]			spr_dat_npc;
output				abort_ex;
input				icpu_ack_i;
input				icpu_err_i;
input				dcpu_ack_i;
input				dcpu_err_i;
reg	[`OR1200_EXCEPT_WIDTH-1:0]	except_type;
reg	[31:0]			id_pc;
reg	[31:0]			ex_pc;
reg	[31:0]			wb_pc;
reg	[31:0]			epcr;
reg	[31:0]			eear;
reg	[`OR1200_SR_WIDTH-1:0]		esr;
reg	[2:0]			id_exceptflags;
reg	[2:0]			ex_exceptflags;
reg	[`OR1200_EXCEPTFSM_WIDTH-1:0]	state;
reg				extend_flush;
reg				extend_flush_last;
reg				ex_dslot;
reg				delayed1_ex_dslot;
reg				delayed2_ex_dslot;
wire				except_started;
wire	[12:0]			except_trig;
wire				except_flushpipe;
reg	[2:0]			delayed_iee;
reg	[2:0]			delayed_tee;
wire				int_pending;
wire				tick_pending;
assign except_started = extend_flush & except_start;
assign lr_sav = ex_pc[31:2];
assign spr_dat_ppc = wb_pc;
assign spr_dat_npc = ex_void ? id_pc : ex_pc;
assign except_start = (except_type != 4'b0000) & extend_flush;
assign int_pending = sig_int & sr[`OR1200_SR_IEE] & delayed_iee[2] & ~ex_freeze & ~branch_taken & ~ex_dslot & ~sr_we;
assign tick_pending = sig_tick & sr[`OR1200_SR_TEE] & ~ex_freeze & ~branch_taken & ~ex_dslot & ~sr_we;
assign abort_ex = sig_dbuserr | sig_dmmufault | sig_dtlbmiss | sig_align | sig_illegal;		
assign except_trig = {
			tick_pending		& ~du_dsr[`OR1200_DU_DSR_TTE],
			int_pending 		& ~du_dsr[`OR1200_DU_DSR_IE],
			ex_exceptflags[1]	& ~du_dsr[`OR1200_DU_DSR_IME],
			ex_exceptflags[0]	& ~du_dsr[`OR1200_DU_DSR_IPFE],
			ex_exceptflags[2]	& ~du_dsr[`OR1200_DU_DSR_BUSEE],
			sig_illegal		& ~du_dsr[`OR1200_DU_DSR_IIE],
			sig_align		& ~du_dsr[`OR1200_DU_DSR_AE],
			sig_dtlbmiss		& ~du_dsr[`OR1200_DU_DSR_DME],
			sig_dmmufault		& ~du_dsr[`OR1200_DU_DSR_DPFE],
			sig_dbuserr		& ~du_dsr[`OR1200_DU_DSR_BUSEE],
			sig_range		& ~du_dsr[`OR1200_DU_DSR_RE],
			sig_trap		& ~du_dsr[`OR1200_DU_DSR_TE] & ~ex_freeze,
			sig_syscall		& ~du_dsr[`OR1200_DU_DSR_SCE] & ~ex_freeze
		};
assign except_stop = {
			tick_pending		& du_dsr[`OR1200_DU_DSR_TTE],
			int_pending 		& du_dsr[`OR1200_DU_DSR_IE],
			ex_exceptflags[1]	& du_dsr[`OR1200_DU_DSR_IME],
			ex_exceptflags[0]	& du_dsr[`OR1200_DU_DSR_IPFE],
			ex_exceptflags[2]	& du_dsr[`OR1200_DU_DSR_BUSEE],
			sig_illegal		& du_dsr[`OR1200_DU_DSR_IIE],
			sig_align		& du_dsr[`OR1200_DU_DSR_AE],
			sig_dtlbmiss		& du_dsr[`OR1200_DU_DSR_DME],
			sig_dmmufault		& du_dsr[`OR1200_DU_DSR_DPFE],
			sig_dbuserr		& du_dsr[`OR1200_DU_DSR_BUSEE],
			sig_range		& du_dsr[`OR1200_DU_DSR_RE],
			sig_trap		& du_dsr[`OR1200_DU_DSR_TE] & ~ex_freeze,
			sig_syscall		& du_dsr[`OR1200_DU_DSR_SCE] & ~ex_freeze
		};
always @(posedge clk ) begin
	if (rst) begin
		id_pc <=  32'b00000000000000000000000000000000;
		id_exceptflags <=  3'b000;
	end
	else if (flushpipe) begin
		id_pc <=  32'h00000000;
		id_exceptflags <=  3'b000;
	end
	else if (!id_freeze) begin
		id_pc <=  if_pc;
		id_exceptflags <=  { sig_ibuserr, sig_itlbmiss, sig_immufault };
	end
end
always @(posedge clk)
	if (rst)
		delayed_iee <=  3'b000;
	else if (!sr[`OR1200_SR_IEE])
		delayed_iee <=  3'b000;
	else
		delayed_iee <=  {delayed_iee[1:0], 1'b1};
always @( posedge clk)
	if (rst)
		delayed_tee <=  3'b000;
	else if (!sr[`OR1200_SR_TEE])
		delayed_tee <=  3'b000;
	else
		delayed_tee <=  {delayed_tee[1:0], 1'b1};
always @(posedge clk ) begin
	if (rst) begin
		ex_dslot <=  1'b0;
		ex_pc <=  32'd0;
		ex_exceptflags <=  3'b000;
		delayed1_ex_dslot <=  1'b0;
		delayed2_ex_dslot <=  1'b0;
	end
	else if (flushpipe) begin
		ex_dslot <=  1'b0;
		ex_pc <=  32'h00000000;
		ex_exceptflags <=  3'b000;
		delayed1_ex_dslot <=  1'b0;
		delayed2_ex_dslot <=  1'b0;
	end
	else if (!ex_freeze & id_freeze) begin
		ex_dslot <=  1'b0;
		ex_pc <=  id_pc;
		ex_exceptflags <=  3'b000;
		delayed1_ex_dslot <=  ex_dslot;
		delayed2_ex_dslot <=  delayed1_ex_dslot;
	end
	else if (!ex_freeze) begin
		ex_dslot <=  branch_taken;
		ex_pc <=  id_pc;
		ex_exceptflags <=  id_exceptflags;
		delayed1_ex_dslot <=  ex_dslot;
		delayed2_ex_dslot <=  delayed1_ex_dslot;
	end
end
always @(posedge clk ) begin
	if (rst) begin
		wb_pc <=  32'b00000000000000000000000000000000;
	end
	else if (!wb_freeze) begin
		wb_pc <=  ex_pc;
	end
end
assign flushpipe = except_flushpipe | pc_we | extend_flush;
assign except_flushpipe = |except_trig & ~|state;
always @(posedge clk ) begin
	if (rst) begin
		state <=  `OR1200_EXCEPTFSM_IDLE;
		except_type <=  4'b0000;
		extend_flush <=  1'b0;
		epcr <=  32'b00000000000000000000000000000000;
		eear <=  32'b00000000000000000000000000000000;
		esr <=  {{1'b1, 1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0},{1'b0}, {1'b1}};
		extend_flush_last <=  1'b0;
	end
	else begin
		case (state)
			`OR1200_EXCEPTFSM_IDLE:
				if (except_flushpipe) begin
					state <=  `OR1200_EXCEPTFSM_FLU1;
					extend_flush <=  1'b1;
					esr <=  sr_we ? to_sr : sr;
					if (except_trig[12] == 1)
					begin
						except_type <=  `OR1200_EXCEPT_TICK;
					   epcr <=  ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
					end
					else if (except_trig[12] == 0 && except_trig[11] == 0)
					begin
						except_type <=  `OR1200_EXCEPT_INT;
						epcr <=  ex_dslot ? wb_pc : delayed1_ex_dslot ? id_pc : delayed2_ex_dslot ? id_pc : id_pc;
					end
					else if (except_trig[12] == 0 && except_trig[11] == 0 && except_trig[10] == 1)
					begin
						except_type <=  `OR1200_EXCEPT_ITLBMISS;
						eear <=  ex_dslot ? ex_pc : ex_pc;
						epcr <=  ex_dslot ? wb_pc : ex_pc;
					end
					else
					begin  
						except_type <=  4'b0000;
					end					
				end
				else if (pc_we) begin
					state <=  `OR1200_EXCEPTFSM_FLU1;
					extend_flush <=  1'b1;
				end
				else begin
					if (epcr_we)
						epcr <=  datain;
					if (eear_we)
						eear <=  datain;
					if (esr_we)
						esr <=  {1'b1, datain[`OR1200_SR_WIDTH-2:0]};
				end
			`OR1200_EXCEPTFSM_FLU1:
				if (icpu_ack_i | icpu_err_i | genpc_freeze)
					state <=  `OR1200_EXCEPTFSM_FLU2;
			`OR1200_EXCEPTFSM_FLU2:
					state <=  `OR1200_EXCEPTFSM_FLU3;
			`OR1200_EXCEPTFSM_FLU3:
					begin
						state <=  `OR1200_EXCEPTFSM_FLU4;
					end
			`OR1200_EXCEPTFSM_FLU4: begin
					state <=  `OR1200_EXCEPTFSM_FLU5;
					extend_flush <=  1'b0;
					extend_flush_last <=  1'b0; 
				end
			default: begin
				if (!if_stall && !id_freeze) begin
					state <=  `OR1200_EXCEPTFSM_IDLE;
					except_type <=  4'b0000;
					extend_flush_last <=  1'b0;
				end
			end
		endcase
	end
end
wire unused;
assign unused = sig_range | sig_syscall | sig_trap | dcpu_ack_i| dcpu_err_i | du_dsr | lsu_addr;
endmodule
module or1200_cfgr(
	spr_addr, spr_dat_o
);
input	[31:0]	spr_addr;	
output	[31:0]	spr_dat_o;	
reg	[31:0]	spr_dat_o;	
always @(spr_addr)
	if (~|spr_addr[31:4])
		case(spr_addr[3:0])		
			`OR1200_SPRGRP_SYS_VR: begin
				spr_dat_o[5:0] = `OR1200_VR_REV;
				spr_dat_o[16:6] = `OR1200_VR_RES1;
				spr_dat_o[23:17] = `OR1200_VR_CFG;
				spr_dat_o[31:24] = `OR1200_VR_VER;
			end
			`OR1200_SPRGRP_SYS_UPR: begin
				spr_dat_o[`OR1200_UPR_UP_BITS] = `OR1200_UPR_UP;
				spr_dat_o[`OR1200_UPR_DCP_BITS] = `OR1200_UPR_DCP;
				spr_dat_o[`OR1200_UPR_ICP_BITS] = `OR1200_UPR_ICP;
				spr_dat_o[`OR1200_UPR_DMP_BITS] = `OR1200_UPR_DMP;
				spr_dat_o[`OR1200_UPR_IMP_BITS] = `OR1200_UPR_IMP;
				spr_dat_o[`OR1200_UPR_MP_BITS] = `OR1200_UPR_MP;
				spr_dat_o[`OR1200_UPR_DUP_BITS] = `OR1200_UPR_DUP;
				spr_dat_o[`OR1200_UPR_PCUP_BITS] = `OR1200_UPR_PCUP;
				spr_dat_o[`OR1200_UPR_PMP_BITS] = `OR1200_UPR_PMP;
				spr_dat_o[`OR1200_UPR_PICP_BITS] = `OR1200_UPR_PICP;
				spr_dat_o[`OR1200_UPR_TTP_BITS] = `OR1200_UPR_TTP;
				spr_dat_o[23:11] = `OR1200_UPR_RES1;
				spr_dat_o[31:24] = `OR1200_UPR_CUP;
			end
			`OR1200_SPRGRP_SYS_CPUCFGR: begin
				spr_dat_o[3:0] = `OR1200_CPUCFGR_NSGF;
				spr_dat_o[`OR1200_CPUCFGR_HGF_BITS] = `OR1200_CPUCFGR_HGF;
				spr_dat_o[`OR1200_CPUCFGR_OB32S_BITS] = `OR1200_CPUCFGR_OB32S;
				spr_dat_o[`OR1200_CPUCFGR_OB64S_BITS] = `OR1200_CPUCFGR_OB64S;
				spr_dat_o[`OR1200_CPUCFGR_OF32S_BITS] = `OR1200_CPUCFGR_OF32S;
				spr_dat_o[`OR1200_CPUCFGR_OF64S_BITS] = `OR1200_CPUCFGR_OF64S;
				spr_dat_o[`OR1200_CPUCFGR_OV64S_BITS] = `OR1200_CPUCFGR_OV64S;
				spr_dat_o[31:10] = `OR1200_CPUCFGR_RES1;
			end
			`OR1200_SPRGRP_SYS_DMMUCFGR: begin
				spr_dat_o[1:0] = `OR1200_DMMUCFGR_NTW;
				spr_dat_o[4:2] = `OR1200_DMMUCFGR_NTS;
				spr_dat_o[7:5] = `OR1200_DMMUCFGR_NAE;
				spr_dat_o[`OR1200_DMMUCFGR_CRI_BITS] = `OR1200_DMMUCFGR_CRI;
				spr_dat_o[`OR1200_DMMUCFGR_PRI_BITS] = `OR1200_DMMUCFGR_PRI;
				spr_dat_o[`OR1200_DMMUCFGR_TEIRI_BITS] = `OR1200_DMMUCFGR_TEIRI;
				spr_dat_o[`OR1200_DMMUCFGR_HTR_BITS] = `OR1200_DMMUCFGR_HTR;
				spr_dat_o[31:12] = `OR1200_DMMUCFGR_RES1;
			end
			`OR1200_SPRGRP_SYS_IMMUCFGR: begin
				spr_dat_o[1:0] = `OR1200_IMMUCFGR_NTW;
				spr_dat_o[4:2] = `OR1200_IMMUCFGR_NTS;
				spr_dat_o[7:5] = `OR1200_IMMUCFGR_NAE;
				spr_dat_o[`OR1200_IMMUCFGR_CRI_BITS] = `OR1200_IMMUCFGR_CRI;
				spr_dat_o[`OR1200_IMMUCFGR_PRI_BITS] = `OR1200_IMMUCFGR_PRI;
				spr_dat_o[`OR1200_IMMUCFGR_TEIRI_BITS] = `OR1200_IMMUCFGR_TEIRI;
				spr_dat_o[`OR1200_IMMUCFGR_HTR_BITS] = `OR1200_IMMUCFGR_HTR;
				spr_dat_o[31:12] = `OR1200_IMMUCFGR_RES1;
			end
			`OR1200_SPRGRP_SYS_DCCFGR: begin
				spr_dat_o[2:0] = `OR1200_DCCFGR_NCW;
				spr_dat_o[6:3] = `OR1200_DCCFGR_NCS;
				spr_dat_o[`OR1200_DCCFGR_CBS_BITS] = `OR1200_DCCFGR_CBS;
				spr_dat_o[`OR1200_DCCFGR_CWS_BITS] = `OR1200_DCCFGR_CWS;
				spr_dat_o[`OR1200_DCCFGR_CCRI_BITS] = `OR1200_DCCFGR_CCRI;
				spr_dat_o[`OR1200_DCCFGR_CBIRI_BITS] = `OR1200_DCCFGR_CBIRI;
				spr_dat_o[`OR1200_DCCFGR_CBPRI_BITS] = `OR1200_DCCFGR_CBPRI;
				spr_dat_o[`OR1200_DCCFGR_CBLRI_BITS] = `OR1200_DCCFGR_CBLRI;
				spr_dat_o[`OR1200_DCCFGR_CBFRI_BITS] = `OR1200_DCCFGR_CBFRI;
				spr_dat_o[`OR1200_DCCFGR_CBWBRI_BITS] = `OR1200_DCCFGR_CBWBRI;
				spr_dat_o[31:15] = `OR1200_DCCFGR_RES1;
			end
			`OR1200_SPRGRP_SYS_ICCFGR: begin
				spr_dat_o[2:0] = `OR1200_ICCFGR_NCW;
				spr_dat_o[6:3] = `OR1200_ICCFGR_NCS;
				spr_dat_o[`OR1200_ICCFGR_CBS_BITS] = `OR1200_ICCFGR_CBS;
				spr_dat_o[`OR1200_ICCFGR_CWS_BITS] = `OR1200_ICCFGR_CWS;
				spr_dat_o[`OR1200_ICCFGR_CCRI_BITS] = `OR1200_ICCFGR_CCRI;
				spr_dat_o[`OR1200_ICCFGR_CBIRI_BITS] = `OR1200_ICCFGR_CBIRI;
				spr_dat_o[`OR1200_ICCFGR_CBPRI_BITS] = `OR1200_ICCFGR_CBPRI;
				spr_dat_o[`OR1200_ICCFGR_CBLRI_BITS] = `OR1200_ICCFGR_CBLRI;
				spr_dat_o[`OR1200_ICCFGR_CBFRI_BITS] = `OR1200_ICCFGR_CBFRI;
				spr_dat_o[`OR1200_ICCFGR_CBWBRI_BITS] = `OR1200_ICCFGR_CBWBRI;
				spr_dat_o[31:15] = `OR1200_ICCFGR_RES1;
			end
			`OR1200_SPRGRP_SYS_DCFGR: begin
				spr_dat_o[2:0] = `OR1200_DCFGR_NDP;
				spr_dat_o[3] = `OR1200_DCFGR_WPCI;
				spr_dat_o[31:4] = `OR1200_DCFGR_RES1;
			end
			default: spr_dat_o = 32'h00000000;
		endcase
endmodule
module or1200_wbmux(
	clk, rst,
	wb_freeze, rfwb_op,
	muxin_a, muxin_b, muxin_c, muxin_d,
	muxout, muxreg, muxreg_valid
);
input				clk;
input				rst;
input				wb_freeze;
input	[`OR1200_RFWBOP_WIDTH-1:0]	rfwb_op;
input	[32-1:0]		muxin_a;
input	[32-1:0]		muxin_b;
input	[32-1:0]		muxin_c;
input	[32-1:0]		muxin_d;
output	[32-1:0]		muxout;
output	[32-1:0]		muxreg;
output				muxreg_valid;
reg	[32-1:0]		muxout;
reg	[32-1:0]		muxreg;
reg				muxreg_valid;
always @(posedge clk) begin
	if (rst) begin
		muxreg <=  32'b00000000000000000000000000000000;
		muxreg_valid <=  1'b0;
	end
	else if (!wb_freeze) begin
		muxreg <=  muxout;
		muxreg_valid <=  rfwb_op[0];
	end
end
always @(muxin_a or muxin_b or muxin_c or muxin_d or rfwb_op) begin
	case(rfwb_op[`OR1200_RFWBOP_WIDTH-1:1]) 
		2'b00: muxout = muxin_a;
		2'b01: begin
			muxout = muxin_b;
		end
		2'b10: begin
			muxout = muxin_c;
		end
		2'b11: begin
			muxout = muxin_d + 32'b00000000000000000000000000001000;
		end
	endcase
end
endmodule
module or1200_lsu(
	addrbase, addrofs, lsu_op, lsu_datain, lsu_dataout, lsu_stall, lsu_unstall,
        du_stall, except_align, except_dtlbmiss, except_dmmufault, except_dbuserr,
	dcpu_adr_o, dcpu_cycstb_o, dcpu_we_o, dcpu_sel_o, dcpu_tag_o, dcpu_dat_o,
	dcpu_dat_i, dcpu_ack_i, dcpu_rty_i, dcpu_err_i, dcpu_tag_i
);
input	[31:0]			addrbase;
input	[31:0]			addrofs;
input	[`OR1200_LSUOP_WIDTH-1:0]	lsu_op;
input	[`OR1200_OPERAND_WIDTH-1:0]		lsu_datain;
output	[`OR1200_OPERAND_WIDTH-1:0]		lsu_dataout;
output				lsu_stall;
output				lsu_unstall;
input                           du_stall;
output				except_align;
output				except_dtlbmiss;
output				except_dmmufault;
output				except_dbuserr;
output	[31:0]			dcpu_adr_o;
output				dcpu_cycstb_o;
output				dcpu_we_o;
output	[3:0]			dcpu_sel_o;
output	[3:0]			dcpu_tag_o;
output	[31:0]			dcpu_dat_o;
input	[31:0]			dcpu_dat_i;
input				dcpu_ack_i;
input				dcpu_rty_i;
input				dcpu_err_i;
input	[3:0]			dcpu_tag_i;
reg	[3:0]			dcpu_sel_o;
assign lsu_stall = dcpu_rty_i & dcpu_cycstb_o;
assign lsu_unstall = dcpu_ack_i;
assign except_align = ((lsu_op == `OR1200_LSUOP_SH) | (lsu_op == `OR1200_LSUOP_LHZ) | (lsu_op == `OR1200_LSUOP_LHS)) & dcpu_adr_o[0]
		|  ((lsu_op == `OR1200_LSUOP_SW) | (lsu_op == `OR1200_LSUOP_LWZ) | (lsu_op == `OR1200_LSUOP_LWS)) & |dcpu_adr_o[1:0];
assign except_dtlbmiss = dcpu_err_i & (dcpu_tag_i == `OR1200_DTAG_TE);
assign except_dmmufault = dcpu_err_i & (dcpu_tag_i == `OR1200_DTAG_PE);
assign except_dbuserr = dcpu_err_i & (dcpu_tag_i == `OR1200_DTAG_BE);
assign dcpu_adr_o = addrbase + addrofs;
assign dcpu_cycstb_o = du_stall | lsu_unstall | except_align ? 1'b0 : |lsu_op;
assign dcpu_we_o = lsu_op[3];
assign dcpu_tag_o = dcpu_cycstb_o ? `OR1200_DTAG_ND : `OR1200_DTAG_IDLE;
always @(lsu_op or dcpu_adr_o)
	case({lsu_op, dcpu_adr_o[1:0]})
		{`OR1200_LSUOP_SB, 2'b00} : dcpu_sel_o = 4'b1000;
		{`OR1200_LSUOP_SB, 2'b01} : dcpu_sel_o = 4'b0100;
		{`OR1200_LSUOP_SB, 2'b10} : dcpu_sel_o = 4'b0010;
		{`OR1200_LSUOP_SB, 2'b11} : dcpu_sel_o = 4'b0001;
		{`OR1200_LSUOP_SH, 2'b00} : dcpu_sel_o = 4'b1100;
		{`OR1200_LSUOP_SH, 2'b10} : dcpu_sel_o = 4'b0011;
		{`OR1200_LSUOP_SW, 2'b00} : dcpu_sel_o = 4'b1111;
		{`OR1200_LSUOP_LBZ, 2'b00} : dcpu_sel_o = 4'b1000;
		{`OR1200_LSUOP_LBS, 2'b00} : dcpu_sel_o = 4'b1000;
		{`OR1200_LSUOP_LBZ, 2'b01}: dcpu_sel_o = 4'b0100;
		{`OR1200_LSUOP_LBS, 2'b01} : dcpu_sel_o = 4'b0100;
		{`OR1200_LSUOP_LBZ, 2'b10}: dcpu_sel_o = 4'b0010;
		{`OR1200_LSUOP_LBS, 2'b10} : dcpu_sel_o = 4'b0010;
		{`OR1200_LSUOP_LBZ, 2'b11}: dcpu_sel_o = 4'b0001;
		{`OR1200_LSUOP_LBS, 2'b11} : dcpu_sel_o = 4'b0001;
		{`OR1200_LSUOP_LHZ, 2'b00}: dcpu_sel_o = 4'b1100;
		{`OR1200_LSUOP_LHS, 2'b00} : dcpu_sel_o = 4'b1100;
		{`OR1200_LSUOP_LHZ, 2'b10}: dcpu_sel_o = 4'b0011;
		{`OR1200_LSUOP_LHS, 2'b10} : dcpu_sel_o = 4'b0011;
		{`OR1200_LSUOP_LWZ, 2'b00}: dcpu_sel_o = 4'b1111;
		{4'b1111, 2'b00} : dcpu_sel_o = 4'b1111;
		default : dcpu_sel_o = 4'b0000;
	endcase
or1200_mem2reg or1200_mem2reg(
	.addr(dcpu_adr_o[1:0]),
	.lsu_op(lsu_op),
	.memdata(dcpu_dat_i),
	.regdata(lsu_dataout)
);
or1200_reg2mem or1200_reg2mem(
        .addr(dcpu_adr_o[1:0]),
        .lsu_op(lsu_op),
        .regdata(lsu_datain),
        .memdata(dcpu_dat_o)
);
endmodule
module or1200_reg2mem(addr, lsu_op, regdata, memdata);
input	[1:0]			addr;
input	[`OR1200_LSUOP_WIDTH-1:0]	lsu_op;
input	[32-1:0]		regdata;
output	[32-1:0]		memdata;
reg	[7:0]			memdata_hh;
reg	[7:0]			memdata_hl;
reg	[7:0]			memdata_lh;
reg	[7:0]			memdata_ll;
assign memdata = {memdata_hh, memdata_hl, memdata_lh, memdata_ll};
always @(lsu_op or addr or regdata) begin
	case({lsu_op, addr[1:0]})	
		{`OR1200_LSUOP_SB, 2'b00} : memdata_hh = regdata[7:0];
		{`OR1200_LSUOP_SH, 2'b00} : memdata_hh = regdata[15:8];
		default : memdata_hh = regdata[31:24];
	endcase
end
always @(lsu_op or addr or regdata) begin
	case({lsu_op, addr[1:0]})	
		{`OR1200_LSUOP_SW, 2'b00} : memdata_hl = regdata[23:16];
		default : memdata_hl = regdata[7:0];
	endcase
end
always @(lsu_op or addr or regdata) begin
	case({lsu_op, addr[1:0]})	
		{`OR1200_LSUOP_SB, 2'b10} : memdata_lh = regdata[7:0];
		default : memdata_lh = regdata[15:8];
	endcase
end
always @(regdata)
	memdata_ll = regdata[7:0];
endmodule
module or1200_mem2reg(addr, lsu_op, memdata, regdata);
input	[1:0]			addr;
input	[`OR1200_LSUOP_WIDTH-1:0]	lsu_op;
input	[32-1:0]		memdata;
output	[32-1:0]		regdata;
wire	[32-1:0]		regdata;
reg	[7:0]			regdata_hh;
reg	[7:0]			regdata_hl;
reg	[7:0]			regdata_lh;
reg	[7:0]			regdata_ll;
reg	[32-1:0]		aligned;
reg	[3:0]			sel_byte0, sel_byte1,
				sel_byte2, sel_byte3;
assign regdata = {regdata_hh, regdata_hl, regdata_lh, regdata_ll};
always @(addr or lsu_op) begin
	case({lsu_op[2:0], addr})	
		{3'b011, 2'b00}:			
			sel_byte0 = `OR1200_M2R_BYTE3;	
		{3'b011, 2'b01}:	
sel_byte0 = `OR1200_M2R_BYTE2;		
		{3'b101, 2'b00}:			
			sel_byte0 = `OR1200_M2R_BYTE2;	
		{3'b011, 2'b10}:			
			sel_byte0 = `OR1200_M2R_BYTE1;	
		default:				
			sel_byte0 = `OR1200_M2R_BYTE0;	
	endcase
end
always @(addr or lsu_op) begin
	case({lsu_op[2:0], addr})	
		{3'b010, 2'b00}:			
			sel_byte1 = `OR1200_M2R_ZERO;	
		{3'b011, 2'b00}:			
			sel_byte1 = `OR1200_M2R_EXTB3;	
		{3'b011, 2'b01}:			
			sel_byte1 = `OR1200_M2R_EXTB2;	
		{3'b011, 2'b10}:			
			sel_byte1 = `OR1200_M2R_EXTB1;	
		{3'b011, 2'b11}:			
			sel_byte1 = `OR1200_M2R_EXTB0;	
		{3'b100, 2'b00}:			
			sel_byte1 = `OR1200_M2R_BYTE3;	
		default:				
			sel_byte1 = `OR1200_M2R_BYTE1;	
	endcase
end
always @(addr or lsu_op) begin
	case({lsu_op[2:0], addr})	
		{3'b010, 2'b00}:	
sel_byte2 = `OR1200_M2R_ZERO;			
		{3'b100, 2'b00}:			
			sel_byte2 = `OR1200_M2R_ZERO;	
		{3'b011, 2'b00}:	
			sel_byte2 = `OR1200_M2R_EXTB3;	
		{3'b101, 2'b00}:			
			sel_byte2 = `OR1200_M2R_EXTB3;	
		{3'b011, 2'b01}:			
			sel_byte2 = `OR1200_M2R_EXTB2;	
		{3'b011, 2'b10}:	
	sel_byte2 = `OR1200_M2R_EXTB1;	
		{3'b101, 2'b10}:			
			sel_byte2 = `OR1200_M2R_EXTB1;	
		{3'b011, 2'b11}:			
			sel_byte2 = `OR1200_M2R_EXTB0;	
		default:				
			sel_byte2 = `OR1200_M2R_BYTE2;	
	endcase
end
always @(addr or lsu_op) begin
	case({lsu_op[2:0], addr}) 
		{3'b010, 2'b00}:
			sel_byte3 = `OR1200_M2R_ZERO;	
		{3'b100, 2'b00}:			
			sel_byte3 = `OR1200_M2R_ZERO;	
		{3'b011, 2'b00}:
sel_byte3 = `OR1200_M2R_EXTB3;	
		{3'b101, 2'b00}:			
			sel_byte3 = `OR1200_M2R_EXTB3;	
		{3'b011, 2'b01}:			
			sel_byte3 = `OR1200_M2R_EXTB2;	
		{3'b011, 2'b10}:
			sel_byte3 = `OR1200_M2R_EXTB1;	
		{3'b101, 2'b10}:			
			sel_byte3 = `OR1200_M2R_EXTB1;	
		{3'b011, 2'b11}:			
			sel_byte3 = `OR1200_M2R_EXTB0;	
		default:				
			sel_byte3 = `OR1200_M2R_BYTE3;	
	endcase
end
always @(sel_byte0 or memdata)
 begin
		case(sel_byte0)
		`OR1200_M2R_BYTE0: begin
				regdata_ll = memdata[7:0];
			end
		`OR1200_M2R_BYTE1: begin
				regdata_ll = memdata[15:8];
			end
		`OR1200_M2R_BYTE2: begin
				regdata_ll = memdata[23:16];
			end
		default: begin
				regdata_ll = memdata[31:24];
			end
	endcase
end
always @(sel_byte1 or memdata) begin
	case(sel_byte1) 
		`OR1200_M2R_ZERO: begin
				regdata_lh = 8'h00;
			end
		`OR1200_M2R_BYTE1: begin
				regdata_lh = memdata[15:8];
			end
		`OR1200_M2R_BYTE3: begin
				regdata_lh = memdata[31:24];
			end
		`OR1200_M2R_EXTB0: begin
				regdata_lh = {{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]}};
			end
		`OR1200_M2R_EXTB1: begin
				regdata_lh = {{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]}};
			end
		`OR1200_M2R_EXTB2: begin
				regdata_lh = {{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]}};
			end
		default: begin
				regdata_lh = {{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]}};
			end
	endcase
end
always @(sel_byte2 or memdata) begin
	case(sel_byte2) 
		`OR1200_M2R_ZERO: begin
				regdata_hl = 8'h00;
			end
		`OR1200_M2R_BYTE2: begin
				regdata_hl = memdata[23:16];
			end
		`OR1200_M2R_EXTB0: begin
				regdata_hl = {{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]}};
			end
		`OR1200_M2R_EXTB1: begin
				regdata_hl =  {{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]}};
			end
		`OR1200_M2R_EXTB2: begin
				regdata_hl = {{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]}};
			end
		default: begin
				regdata_hl = {{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]}};
			end
	endcase
end
always @(sel_byte3 or memdata) begin
	case(sel_byte3) 
		`OR1200_M2R_ZERO: begin
				regdata_hh = 8'h00;
			end
		`OR1200_M2R_BYTE3: begin
				regdata_hh = memdata[31:24];
			end
		`OR1200_M2R_EXTB0: begin
				regdata_hh = {{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]},{memdata[7]}};
			end
		`OR1200_M2R_EXTB1: begin
				regdata_hh = {{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]},{memdata[15]}};
			end
		`OR1200_M2R_EXTB2: begin
				regdata_hh = {{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]},{memdata[23]}};
			end
		`OR1200_M2R_EXTB3: begin
				regdata_hh =  {{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]},{memdata[31]}};
			end
	endcase
end
always @(addr or memdata) begin
	case(addr) 
		2'b00:
			aligned = memdata;
		2'b01:
			aligned = {memdata[23:0], 8'b00000000};
		2'b10:
			aligned = {memdata[15:0], 16'b0000000000000000};
		2'b11:
			aligned = {memdata[7:0], 24'b000000000000000000000000};
	endcase
end
wire[8:0] unused_signal;
assign unused_signal = lsu_op;
endmodule
