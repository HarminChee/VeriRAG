module my6502 (
    input               clk,        
    input               reset,      
    input               nmi,        
    input               irq,        
    input       [7:0]   din,        
    output  reg [15:0]  addr,       
    output  reg [7:0]   dout,       
    output  reg         dout_oe     
);
reg         nmi_asy;
reg         nmi_syn;
reg         nmi_syn_d;
reg         nmi_rise_reg;
reg         irq_asy;
reg         irq_syn;
parameter   EXEC_RES    = 3'd0;
parameter   EXEC_NMI    = 3'd1;
parameter   EXEC_IRQ    = 3'd2;
parameter   EXEC_OPC    = 3'd3;
reg [1:0]   state;
reg [1:0]   state_new;
wire        st_res;
wire        st_nmi;
wire        st_irq;
wire        st_opc;
wire        st_new_nmi;
wire        st_new_irq;
reg [2:0]   cyc_cnt;
reg [7:0]   opcode_buf;
reg [7:0]   din_buf;
reg [7:0]   a_reg;      
reg [7:0]   x_reg;      
reg [7:0]   y_reg;      
reg [7:0]   sp_reg;     
reg [15:0]  pc_reg;     
wire[7:0]   pch_reg;
wire[15:0]  pc_inc;
wire[7:0]   ps_reg;     
reg         ps_reg_nf;
reg         ps_reg_vf;
reg         ps_reg_df;
reg         ps_reg_if;
reg         ps_reg_zf;
reg         ps_reg_cf;
wire[15:0]  addr_new;
wire        addr_le;
wire[7:0]   dout_new;
wire        dout_le;
wire[7:0]   alu_ain;
wire[7:0]   alu_bin;
wire[7:0]   alu_add_bin;
wire        alu_cin;
wire[7:0]   alu_add_out;
wire        alu_add_cout;
wire        alu_add_ovf;
wire[7:0]   alu_and_out;
wire[7:0]   alu_or_out;
wire[7:0]   alu_eor_out;
wire[7:0]   alu_shl_out;
wire        alu_shl_cout;
wire[7:0]   alu_shr_out;
wire        alu_shr_cout;
wire[7:0]   alu_out;
wire        alu_out_eqz;
reg [7:0]   alu_reg;
wire        alu_out_nf;
wire        alu_out_vf;
wire        alu_out_df;
wire        alu_out_if;
wire        alu_out_zf;
wire        alu_out_cf;
wire        mc_ar_le;
wire        mc_xr_le;
wire        mc_yr_le;
wire        mc_sp_le;
wire        mc_ps_nf_le;
wire        mc_ps_vf_le;
wire        mc_ps_df_le;
wire        mc_ps_if_le;
wire        mc_ps_zf_le;
wire        mc_ps_cf_le;
wire        mc_dout_alu;
wire        mc_dout_pch_reg;
wire        mc_dout_pcl_reg;
wire        mc_dout_pch_inc;
wire        mc_dout_pcl_inc;
wire        mc_addr_pc_reg;
wire        mc_addr_pc_inc;
wire        mc_addr_zp_din;
wire        mc_addr_zp_alu;
wire        mc_addr_abs_din;
wire        mc_addr_abs_alu;
wire        mc_addr_abs_pch;
wire        mc_addr_abs_ind;
wire        mc_addr_nmi_vl;
wire        mc_addr_nmi_vh;
wire        mc_addr_res_vl;
wire        mc_addr_res_vh;
wire        mc_addr_irq_vl;
wire        mc_addr_irq_vh;
wire        pg_crs_chk;
wire        pg_crs_det;
reg         pg_crs_reg;
wire        br_req;
reg         br_req_d;
wire        br_det;
wire        br_crs_det;
reg         br_crs_reg;
wire        br_pch_inc;
wire        br_pch_dec;
wire        mi_fetch_en;
wire        mi_cyc_cnt_en;
wire        mi_pc_chg;
wire        mi_addr_pc;
wire        mi_oe_next;
wire        mi_alu_add_xr;
wire        mi_alu_add_yr;
wire        mc_alu_ain_ar;
wire        mc_alu_ain_xr;
wire        mc_alu_ain_yr;
wire        mc_alu_ain_sp;
wire        mc_alu_ain_ps;
wire        mc_alu_ain_din;
wire        mc_alu_bin_din;
wire        mc_alu_cin_use;
wire        mc_alu_inc_cmp;
wire        mc_alu_inc_grp;
wire        mc_alu_dec_grp;
wire        mc_alu_cmp_grp;
wire        mc_alu_sub_dec;
wire        mc_alu_add_sub;
wire        mc_alu_and_bit;
wire        mc_alu_or;
wire        mc_alu_eor;
wire        mc_alu_asl_rol;
wire        mc_alu_lsr_ror;
wire        inst_cin_use;
wire        inst_inc_grp;
wire        inst_dec_grp;
wire        inst_cmp_grp;
wire        inst_mov_grp;
wire        inst_and_bit;
wire        inst_asl_rol;
wire        inst_lsr_ror;
wire[55:0]  opc_inst;
wire[7:0]   opc_flag;
wire        opc_src_a_ar;
wire        opc_src_a_xr;
wire        opc_src_a_yr;
wire        opc_src_a_sp;
wire        opc_src_a_ps;
wire        opc_src_a_din;
wire        opc_src_b_din;
wire        opc_dst_ar;
wire        opc_dst_xr;
wire        opc_dst_yr;
wire        opc_dst_sp;
wire        opc_dst_ps;
wire        opc_dst_dout;
wire        mc_fetch_en;
wire        mc_din_le;
wire        mc_pc_chg;
wire        mc_addr_pc;
wire        mc_addr_zp;
wire        mc_addr_abs;
wire        mc_addr_sp;
wire        mc_addr_vl;
wire        mc_addr_vh;
wire        mc_dout_pch;
wire        mc_dout_pcl;
wire        mc_oe_next;
wire        mc_alu_inst_op;
wire        mc_alu_add_xr;
wire        mc_alu_add_yr;
wire        mc_alu_add_z;
wire        mc_alu_inc_din;
wire        mc_alu_inc_reg;
wire        mc_alu_inc_sp;
wire        mc_alu_dec_sp;
wire        mc_brk_if_set;
wire        mc_br_chk;
wire        inst_adc;
wire        inst_and;
wire        inst_asl;
wire        inst_bcc;
wire        inst_bcs;
wire        inst_beq;
wire        inst_bit;
wire        inst_bmi;
wire        inst_bne;
wire        inst_bpl;
wire        inst_brk;
wire        inst_bvc;
wire        inst_bvs;
wire        inst_clc;
wire        inst_cld;
wire        inst_cli;
wire        inst_clv;
wire        inst_cmp;
wire        inst_cpx;
wire        inst_cpy;
wire        inst_dec;
wire        inst_dex;
wire        inst_dey;
wire        inst_eor;
wire        inst_inc;
wire        inst_inx;
wire        inst_iny;
wire        inst_jmp;
wire        inst_jsr;
wire        inst_lda;
wire        inst_ldx;
wire        inst_ldy;
wire        inst_lsr;
wire        inst_nop;
wire        inst_ora;
wire        inst_pha;
wire        inst_php;
wire        inst_pla;
wire        inst_plp;
wire        inst_rol;
wire        inst_ror;
wire        inst_rti;
wire        inst_rts;
wire        inst_sbc;
wire        inst_sec;
wire        inst_sed;
wire        inst_sei;
wire        inst_sta;
wire        inst_stx;
wire        inst_sty;
wire        inst_tax;
wire        inst_tay;
wire        inst_tsx;
wire        inst_txa;
wire        inst_txs;
wire        inst_tya;
wire        opc_flag_nf;
wire        opc_flag_vf;
wire        opc_flag_df;
wire        opc_flag_if;
wire        opc_flag_zf;
wire        opc_flag_cf;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        nmi_asy   <= 1'b0;
        nmi_syn   <= 1'b0;
        nmi_syn_d <= 1'b0;
    end else begin
        nmi_asy   <= nmi;
        nmi_syn   <= nmi_asy;
        nmi_syn_d <= nmi_syn;
    end
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        nmi_rise_reg <= 1'b0;
    end else begin
        if (st_nmi) begin
            nmi_rise_reg <= 1'b0;
        end else if (nmi_syn & ~nmi_syn_d) begin
            nmi_rise_reg <= 1'b1;
        end
    end
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        irq_asy <= 1'b0;
        irq_syn <= 1'b0;
    end else begin
        irq_asy <= irq;
        irq_syn <= irq_asy;
    end
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= EXEC_RES;
    end else begin
        state <= state_new;
    end
end
always @* begin
    state_new = state;
    if (mi_fetch_en) begin
        if (nmi_rise_reg)               state_new = EXEC_NMI;
        else if (irq_syn & ~ps_reg_if)  state_new = EXEC_IRQ;
        else                            state_new = EXEC_OPC;
    end
end
assign  st_res      = (state == EXEC_RES);
assign  st_nmi      = (state == EXEC_NMI);
assign  st_irq      = (state == EXEC_IRQ);
assign  st_opc      = (state == EXEC_OPC);
assign  st_new_nmi  = (state_new == EXEC_NMI);
assign  st_new_irq  = (state_new == EXEC_IRQ);
always @(posedge clk or posedge reset) begin
    if (reset) begin
        cyc_cnt <= 3'd0;
    end else begin
        if (mi_fetch_en) begin
            cyc_cnt <= 3'd0;
        end else if (mi_cyc_cnt_en) begin
            cyc_cnt <= cyc_cnt + 1'b1;
        end
    end
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        opcode_buf <= 8'h00;
    end else begin
        if (mi_fetch_en) begin
            if (st_new_nmi | st_new_irq) begin
                opcode_buf <= 8'h00;    
            end else begin
                opcode_buf <= din;
            end
        end
    end
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        din_buf <= 8'h00;
    end else begin
        if (mi_fetch_en) begin
            din_buf <= 8'h00;
        end else if (mc_din_le) begin
            din_buf <= din;
        end
    end
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        a_reg  <= 8'h00;
        x_reg  <= 8'h00;
        y_reg  <= 8'h00;
        sp_reg <= 8'hff;
    end else begin
        a_reg  <= mc_ar_le ? alu_out : a_reg;
        x_reg  <= mc_xr_le ? alu_out : x_reg;
        y_reg  <= mc_yr_le ? alu_out : y_reg;
        sp_reg <= mc_sp_le ? alu_out : sp_reg;
    end
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_reg <= 16'h0000;
    end else begin
        if (mi_pc_chg) begin
            pc_reg <= addr_new;
        end
    end
end
assign  pch_reg = pc_reg[15:8];
assign  pc_inc = pc_reg + 1'b1;
assign  ps_reg[7] = ps_reg_nf;
assign  ps_reg[6] = ps_reg_vf;
assign  ps_reg[5] = 1'b1;
assign  ps_reg[4] = st_opc;     
assign  ps_reg[3] = ps_reg_df;
assign  ps_reg[2] = ps_reg_if;
assign  ps_reg[1] = ps_reg_zf;
assign  ps_reg[0] = ps_reg_cf;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        ps_reg_nf <= 1'b0;
        ps_reg_vf <= 1'b0;
        ps_reg_df <= 1'b0;
        ps_reg_if <= 1'b0;
        ps_reg_zf <= 1'b1;
        ps_reg_cf <= 1'b0;
    end else begin
        ps_reg_nf <= mc_ps_nf_le ? alu_out_nf : ps_reg_nf;
        ps_reg_vf <= mc_ps_vf_le ? alu_out_vf : ps_reg_vf;
        ps_reg_df <= mc_ps_df_le ? alu_out_df : ps_reg_df;
        ps_reg_if <= mc_ps_if_le ? alu_out_if : ps_reg_if;
        ps_reg_zf <= mc_ps_zf_le ? alu_out_zf : ps_reg_zf;
        ps_reg_cf <= mc_ps_cf_le ? alu_out_cf : ps_reg_cf;
    end
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        addr <= 16'h0000;
    end else begin
        if (addr_le) begin
            addr <= addr_new;
        end
    end
end
assign  addr_new    = (mc_addr_pc_reg  ?   pc_reg           : 16'h0000)
                    | (mc_addr_pc_inc  ?   pc_inc           : 16'h0000)
                    | (mc_addr_zp_din  ? {  8'h00, din    } : 16'h0000)
                    | (mc_addr_zp_alu  ? {  8'h00, alu_out} : 16'h0000)
                    | (mc_addr_abs_din ? {    din, alu_out} : 16'h0000)
                    | (mc_addr_abs_alu ? {alu_out, alu_reg} : 16'h0000)
                    | (mc_addr_abs_pch ? {pch_reg, alu_out} : 16'h0000)
                    | (mc_addr_abs_ind ? {din_buf, alu_out} : 16'h0000)
                    | (mc_addr_sp      ? {  8'h01, sp_reg } : 16'h0000)
                    | (mc_addr_nmi_vl  ?   16'hfffa         : 16'h0000)
                    | (mc_addr_nmi_vh  ?   16'hfffb         : 16'h0000)
                    | (mc_addr_res_vl  ?   16'hfffc         : 16'h0000)
                    | (mc_addr_res_vh  ?   16'hfffd         : 16'h0000)
                    | (mc_addr_irq_vl  ?   16'hfffe         : 16'h0000)
                    | (mc_addr_irq_vh  ?   16'hffff         : 16'h0000);
assign  addr_le     =  mc_addr_pc_reg
                    |  mc_addr_pc_inc
                    |  mc_addr_zp_din
                    |  mc_addr_zp_alu
                    |  mc_addr_abs_din
                    |  mc_addr_abs_alu
                    |  mc_addr_abs_pch
                    |  mc_addr_abs_ind
                    |  mc_addr_sp
                    |  mc_addr_nmi_vl
                    |  mc_addr_nmi_vh
                    |  mc_addr_res_vl
                    |  mc_addr_res_vh
                    |  mc_addr_irq_vl
                    |  mc_addr_irq_vh;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        dout <= 8'h00;
    end else begin
        if (dout_le) begin
            dout <= dout_new;
        end
    end
end
assign  dout_new    = (mc_dout_alu     ? alu_out      : 8'h00)
                    | (mc_dout_pch_reg ? pc_reg[15:8] : 8'h00)
                    | (mc_dout_pcl_reg ? pc_reg[7:0]  : 8'h00)
                    | (mc_dout_pch_inc ? pc_inc[15:8] : 8'h00)
                    | (mc_dout_pcl_inc ? pc_inc[7:0]  : 8'h00);
assign  dout_le     =  mc_dout_alu
                    |  mc_dout_pch_reg
                    |  mc_dout_pcl_reg
                    |  mc_dout_pch_inc
                    |  mc_dout_pcl_inc;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        dout_oe <= 1'b0;
    end else begin
        dout_oe <= mi_oe_next;
    end
end
assign  alu_ain     = (mc_alu_ain_ar  ?  a_reg        : 8'h00)
                    | (mc_alu_ain_xr  ?  x_reg        : 8'h00)
                    | (mc_alu_ain_yr  ?  y_reg        : 8'h00)
                    | (mc_alu_ain_sp  ?  sp_reg       : 8'h00)
                    | (mc_alu_ain_ps  ?  ps_reg       : 8'h00)
                    | (mc_alu_ain_din ?  din_buf      : 8'h00)
                    | (mc_alu_inc_reg ?  alu_reg      : 8'h00)
                    | (br_det         ?  pc_reg[7:0]  : 8'h00)
                    | (br_crs_reg     ?  pc_reg[15:8] : 8'h00);
assign  alu_bin     =  mc_alu_bin_din ?  din_buf : 8'h00;
assign  alu_add_bin =  mc_alu_sub_dec ? ~alu_bin : alu_bin;
assign  alu_cin     =  mc_alu_cin_use ? ps_reg_cf : mc_alu_inc_cmp;
assign  {alu_add_cout, alu_add_out} = alu_ain + alu_add_bin + alu_cin;
assign  alu_add_ovf = (~alu_ain[7] & ~alu_add_bin[7] &  alu_add_out[7])
                    | ( alu_ain[7] &  alu_add_bin[7] & ~alu_add_out[7]);
assign  alu_and_out = alu_ain & alu_bin;
assign  alu_or_out  = alu_ain | alu_bin;
assign  alu_eor_out = alu_ain ^ alu_bin;
assign  {alu_shl_cout, alu_shl_out} = {alu_ain, alu_cin};
assign  {alu_shr_out, alu_shr_cout} = {alu_cin, alu_ain};
assign  alu_out     = (mc_alu_add_sub ? alu_add_out : 8'h00)
                    | (mc_alu_and_bit ? alu_and_out : 8'h00)
                    | (mc_alu_or      ? alu_or_out  : 8'h00)
                    | (mc_alu_eor     ? alu_eor_out : 8'h00)
                    | (mc_alu_asl_rol ? alu_shl_out : 8'h00)
                    | (mc_alu_lsr_ror ? alu_shr_out : 8'h00);
assign  alu_out_eqz = (alu_out == 8'h00);
always @(posedge clk or posedge reset) begin
    if (reset) begin
        alu_reg <= 8'h00;
    end else begin
        alu_reg <= alu_out;
    end
end
assign  alu_out_nf  = (inst_bit
                      |inst_plp
                      |inst_rti)    ? alu_bin[7]
                    :                 alu_out[7];
assign  alu_out_vf  =  inst_clv     ? 1'b0
                    : (inst_bit
                      |inst_plp
                      |inst_rti)    ? alu_bin[6]
                    :                 alu_add_ovf;
assign  alu_out_df  =  inst_cld     ? 1'b0
                    :  inst_sed     ? 1'b1
                    :                 alu_bin[3];
assign  alu_out_if  =  inst_cli     ? 1'b0
                    : (inst_sei
                      |inst_brk)    ? 1'b1
                    :                 alu_bin[2];
assign  alu_out_zf  = (inst_plp
                      |inst_rti)    ? alu_bin[1]
                    :                 alu_out_eqz;
assign  alu_out_cf  =  inst_clc     ? 1'b0
                    :  inst_sec     ? 1'b1
                    : (inst_plp
                      |inst_rti)    ? alu_bin[0]
                    : (inst_asl
                      |inst_rol)    ? alu_shl_cout
                    : (inst_lsr
                      |inst_ror)    ? alu_shr_cout
                    :                 alu_add_cout;
assign  mc_ar_le    =  mc_alu_inst_op & opc_dst_ar;
assign  mc_xr_le    =  mc_alu_inst_op & opc_dst_xr;
assign  mc_yr_le    =  mc_alu_inst_op & opc_dst_yr;
assign  mc_sp_le    = (mc_alu_inst_op & opc_dst_sp)
                    |  mc_alu_inc_sp
                    |  mc_alu_dec_sp;
assign  mc_ps_nf_le =  mc_alu_inst_op & opc_flag_nf;
assign  mc_ps_vf_le =  mc_alu_inst_op & opc_flag_vf;
assign  mc_ps_df_le =  mc_alu_inst_op & opc_flag_df;
assign  mc_ps_if_le = (mc_alu_inst_op & opc_flag_if)
                    |  mc_brk_if_set;
assign  mc_ps_zf_le =  mc_alu_inst_op & opc_flag_zf;
assign  mc_ps_cf_le =  mc_alu_inst_op & opc_flag_cf;
assign  mc_dout_alu     =  mc_alu_inst_op & opc_dst_dout;
assign  mc_dout_pch_reg = (mc_dout_pch & st_nmi)
                        | (mc_dout_pch & st_irq);
assign  mc_dout_pcl_reg = (mc_dout_pcl & st_nmi)
                        | (mc_dout_pcl & st_irq);
assign  mc_dout_pch_inc = (mc_dout_pch & inst_brk & st_opc)
                        | (mc_dout_pch & inst_jsr);
assign  mc_dout_pcl_inc = (mc_dout_pcl & inst_brk & st_opc)
                        | (mc_dout_pcl & inst_jsr);
assign  mc_addr_pc_reg  = mi_addr_pc & ~mi_pc_chg;  
assign  mc_addr_pc_inc  = mi_addr_pc &  mi_pc_chg;  
assign  mc_addr_zp_din  =  mc_addr_zp & ~mc_addr_zp_alu;    
assign  mc_addr_zp_alu  = (mc_addr_zp &  mc_alu_add_xr)     
                        | (mc_addr_zp &  mc_alu_add_yr)     
                        | (mc_addr_zp &  mc_alu_inc_reg)    
                        | (mc_addr_zp &  mc_alu_inc_din);   
assign  mc_addr_abs_din = (pg_crs_chk & ~pg_crs_det);   
assign  mc_addr_abs_alu =  pg_crs_reg                   
                        |  br_crs_reg;                  
assign  mc_addr_abs_pch = (br_det     & ~br_crs_det);       
assign  mc_addr_abs_ind =  mc_addr_abs & mc_alu_inc_reg;    
assign  mc_addr_nmi_vl  = mc_addr_vl &  st_nmi;
assign  mc_addr_nmi_vh  = mc_addr_vh &  st_nmi;
assign  mc_addr_res_vl  = mc_addr_vl &  st_res;
assign  mc_addr_res_vh  = mc_addr_vh &  st_res;
assign  mc_addr_irq_vl  = mc_addr_vl & ~st_res & ~st_nmi;   
assign  mc_addr_irq_vh  = mc_addr_vh & ~st_res & ~st_nmi;   
assign  pg_crs_chk  = mc_addr_abs & ~mc_addr_abs_ind & ~pg_crs_reg;
assign  pg_crs_det  = (pg_crs_chk & mc_alu_add_xr & alu_add_cout)   
                    | (pg_crs_chk & mc_alu_add_yr & alu_add_cout);  
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pg_crs_reg <= 1'b0;
    end else begin
        pg_crs_reg <= pg_crs_det;   
    end
end
assign  br_req      = (mc_br_chk & inst_bpl & ~ps_reg_nf)
                    | (mc_br_chk & inst_bmi &  ps_reg_nf)
                    | (mc_br_chk & inst_bvc & ~ps_reg_vf)
                    | (mc_br_chk & inst_bvs &  ps_reg_vf)
                    | (mc_br_chk & inst_bne & ~ps_reg_zf)
                    | (mc_br_chk & inst_beq &  ps_reg_zf)
                    | (mc_br_chk & inst_bcc & ~ps_reg_cf)
                    | (mc_br_chk & inst_bcs &  ps_reg_cf);
always @(posedge clk or posedge reset) begin
    if (reset) begin
        br_req_d <= 1'b0;
    end else begin
        br_req_d <= br_req;
    end
end
assign  br_det = br_req & ~br_req_d;
assign  br_crs_det  = (br_det & ~din_buf[7] &  alu_add_cout)    
                    | (br_det &  din_buf[7] & ~alu_add_cout);   
always @(posedge clk or posedge reset) begin
    if (reset) begin
        br_crs_reg <= 1'b0;
    end else begin
        br_crs_reg <= br_crs_det;   
    end
end
assign  br_pch_inc  = br_crs_reg & ~din_buf[7];     
assign  br_pch_dec  = br_crs_reg &  din_buf[7];     
assign  mi_fetch_en     = mc_fetch_en   & ~br_det       
                                        & ~br_crs_reg;  
assign  mi_cyc_cnt_en   = 1'b1          & ~pg_crs_det   
                                        & ~br_det       
                                        & ~br_crs_reg;  
assign  mi_pc_chg   = mc_pc_chg & ~(mi_fetch_en & st_new_nmi)   
                                & ~(mi_fetch_en & st_new_irq)   
                                        & ~br_crs_det;  
assign  mi_addr_pc      = mc_addr_pc    & ~br_det       
                                        & ~br_crs_reg;  
assign  mi_oe_next      = mc_oe_next    & ~st_res       
                                        & ~pg_crs_det;  
assign  mi_alu_add_xr   = mc_alu_add_xr & ~pg_crs_reg;  
assign  mi_alu_add_yr   = mc_alu_add_yr & ~pg_crs_reg;  
assign  mc_alu_ain_ar   =  mc_alu_inst_op & opc_src_a_ar;
assign  mc_alu_ain_xr   = (mc_alu_inst_op & opc_src_a_xr)
                        |  mi_alu_add_xr;
assign  mc_alu_ain_yr   = (mc_alu_inst_op & opc_src_a_yr)
                        |  mi_alu_add_yr;
assign  mc_alu_ain_sp   = (mc_alu_inst_op & opc_src_a_sp)
                        |  mc_alu_inc_sp
                        |  mc_alu_dec_sp;
assign  mc_alu_ain_ps   = (mc_alu_inst_op & opc_src_a_ps);
assign  mc_alu_ain_din  = (mc_alu_inst_op & opc_src_a_din)
                        |  mc_alu_inc_din
                        |  pg_crs_reg;      
assign  mc_alu_bin_din  = (mc_alu_inst_op & opc_src_b_din)
                        |  mi_alu_add_xr
                        |  mi_alu_add_yr
                        |  mc_alu_add_z
                        |  br_det;          
assign  mc_alu_cin_use  = (mc_alu_inst_op & inst_cin_use);
assign  mc_alu_inc_cmp  =  mc_alu_inc_grp
                        |  mc_alu_cmp_grp;
assign  mc_alu_inc_grp  = (mc_alu_inst_op & inst_inc_grp)
                        |  mc_alu_inc_din
                        |  mc_alu_inc_reg
                        |  mc_alu_inc_sp
                        |  pg_crs_reg       
                        |  br_pch_inc;      
assign  mc_alu_dec_grp  = (mc_alu_inst_op & inst_dec_grp)
                        |  mc_alu_dec_sp
                        |  br_pch_dec;      
assign  mc_alu_cmp_grp  = (mc_alu_inst_op & inst_cmp_grp);
assign  mc_alu_sub_dec  = (mc_alu_inst_op & inst_sbc)
                        |  mc_alu_cmp_grp
                        |  mc_alu_dec_grp;
assign  mc_alu_add_sub  = (mc_alu_inst_op & inst_adc)
                        | (mc_alu_inst_op & inst_mov_grp)
                        |  mc_alu_inc_grp
                        |  mc_alu_sub_dec   
                        |  mi_alu_add_xr
                        |  mi_alu_add_yr
                        |  mc_alu_add_z
                        |  br_det;          
assign  mc_alu_and_bit  =  mc_alu_inst_op & inst_and_bit;
assign  mc_alu_or       =  mc_alu_inst_op & inst_ora;
assign  mc_alu_eor      =  mc_alu_inst_op & inst_eor;
assign  mc_alu_asl_rol  =  mc_alu_inst_op & inst_asl_rol;
assign  mc_alu_lsr_ror  =  mc_alu_inst_op & inst_lsr_ror;
assign  inst_cin_use    = inst_adc
                        | inst_sbc
                        | inst_rol
                        | inst_ror;
assign  inst_inc_grp    = inst_inc
                        | inst_inx
                        | inst_iny;
assign  inst_dec_grp    = inst_dec
                        | inst_dex
                        | inst_dey;
assign  inst_cmp_grp    = inst_cmp
                        | inst_cpx
                        | inst_cpy;
assign  inst_mov_grp    = inst_lda
                        | inst_ldx
                        | inst_ldy
                        | inst_sta
                        | inst_stx
                        | inst_sty
                        | inst_tax
                        | inst_tay
                        | inst_tsx
                        | inst_txa
                        | inst_txs
                        | inst_tya
                        | inst_pha
                        | inst_php
                        | inst_pla
                        | inst_plp
                        | inst_brk
                        | inst_rti;
assign  inst_and_bit    = inst_and
                        | inst_bit;
assign  inst_asl_rol    = inst_asl
                        | inst_rol;
assign  inst_lsr_ror    = inst_lsr
                        | inst_ror;
my6502mc    u_mc (
    .opcode         (opcode_buf     ),  
    .cyc_cnt        (cyc_cnt        ),  
    .opc_inst       (opc_inst       ),  
    .opc_flag       (opc_flag       ),  
    .opc_src_a_ar   (opc_src_a_ar   ),  
    .opc_src_a_xr   (opc_src_a_xr   ),  
    .opc_src_a_yr   (opc_src_a_yr   ),  
    .opc_src_a_sp   (opc_src_a_sp   ),  
    .opc_src_a_ps   (opc_src_a_ps   ),  
    .opc_src_a_din  (opc_src_a_din  ),  
    .opc_src_b_din  (opc_src_b_din  ),  
    .opc_dst_ar     (opc_dst_ar     ),  
    .opc_dst_xr     (opc_dst_xr     ),  
    .opc_dst_yr     (opc_dst_yr     ),  
    .opc_dst_sp     (opc_dst_sp     ),  
    .opc_dst_ps     (opc_dst_ps     ),  
    .opc_dst_dout   (opc_dst_dout   ),  
    .mc_fetch_en    (mc_fetch_en    ),  
    .mc_din_le      (mc_din_le      ),  
    .mc_pc_chg      (mc_pc_chg      ),  
    .mc_addr_pc     (mc_addr_pc     ),  
    .mc_addr_zp     (mc_addr_zp     ),  
    .mc_addr_abs    (mc_addr_abs    ),  
    .mc_addr_sp     (mc_addr_sp     ),  
    .mc_addr_vl     (mc_addr_vl     ),  
    .mc_addr_vh     (mc_addr_vh     ),  
    .mc_dout_pch    (mc_dout_pch    ),  
    .mc_dout_pcl    (mc_dout_pcl    ),  
    .mc_oe_next     (mc_oe_next     ),  
    .mc_alu_inst_op (mc_alu_inst_op ),  
    .mc_alu_add_xr  (mc_alu_add_xr  ),  
    .mc_alu_add_yr  (mc_alu_add_yr  ),  
    .mc_alu_add_z   (mc_alu_add_z   ),  
    .mc_alu_inc_din (mc_alu_inc_din ),  
    .mc_alu_inc_reg (mc_alu_inc_reg ),  
    .mc_alu_inc_sp  (mc_alu_inc_sp  ),  
    .mc_alu_dec_sp  (mc_alu_dec_sp  ),  
    .mc_brk_if_set  (mc_brk_if_set  ),  
    .mc_br_chk      (mc_br_chk      )   
);
assign  inst_adc    = opc_inst[ 0];
assign  inst_and    = opc_inst[ 1];
assign  inst_asl    = opc_inst[ 2];
assign  inst_bcc    = opc_inst[ 3];
assign  inst_bcs    = opc_inst[ 4];
assign  inst_beq    = opc_inst[ 5];
assign  inst_bit    = opc_inst[ 6];
assign  inst_bmi    = opc_inst[ 7];
assign  inst_bne    = opc_inst[ 8];
assign  inst_bpl    = opc_inst[ 9];
assign  inst_brk    = opc_inst[10];
assign  inst_bvc    = opc_inst[11];
assign  inst_bvs    = opc_inst[12];
assign  inst_clc    = opc_inst[13];
assign  inst_cld    = opc_inst[14];
assign  inst_cli    = opc_inst[15];
assign  inst_clv    = opc_inst[16];
assign  inst_cmp    = opc_inst[17];
assign  inst_cpx    = opc_inst[18];
assign  inst_cpy    = opc_inst[19];
assign  inst_dec    = opc_inst[20];
assign  inst_dex    = opc_inst[21];
assign  inst_dey    = opc_inst[22];
assign  inst_eor    = opc_inst[23];
assign  inst_inc    = opc_inst[24];
assign  inst_inx    = opc_inst[25];
assign  inst_iny    = opc_inst[26];
assign  inst_jmp    = opc_inst[27];
assign  inst_jsr    = opc_inst[28];
assign  inst_lda    = opc_inst[29];
assign  inst_ldx    = opc_inst[30];
assign  inst_ldy    = opc_inst[31];
assign  inst_lsr    = opc_inst[32];
assign  inst_nop    = opc_inst[33];
assign  inst_ora    = opc_inst[34];
assign  inst_pha    = opc_inst[35];
assign  inst_php    = opc_inst[36];
assign  inst_pla    = opc_inst[37];
assign  inst_plp    = opc_inst[38];
assign  inst_rol    = opc_inst[39];
assign  inst_ror    = opc_inst[40];
assign  inst_rti    = opc_inst[41];
assign  inst_rts    = opc_inst[42];
assign  inst_sbc    = opc_inst[43];
assign  inst_sec    = opc_inst[44];
assign  inst_sed    = opc_inst[45];
assign  inst_sei    = opc_inst[46];
assign  inst_sta    = opc_inst[47];
assign  inst_stx    = opc_inst[48];
assign  inst_sty    = opc_inst[49];
assign  inst_tax    = opc_inst[50];
assign  inst_tay    = opc_inst[51];
assign  inst_tsx    = opc_inst[52];
assign  inst_txa    = opc_inst[53];
assign  inst_txs    = opc_inst[54];
assign  inst_tya    = opc_inst[55];
assign  opc_flag_nf = opc_flag[7];
assign  opc_flag_vf = opc_flag[6];
assign  opc_flag_df = opc_flag[3];
assign  opc_flag_if = opc_flag[2];
assign  opc_flag_zf = opc_flag[1];
assign  opc_flag_cf = opc_flag[0];
endmodule
