`timescale 1 ns / 10 ps
`timescale 1 ns / 10 ps
module ramdac
  (
   input		hclk,		
   input 	        pixclk,         
   input 	        crtclock,       
   input		hresetn,	
   input		wrn,		
   input		rdn,		
   input [2:0] 	        rs,		
   input [7:0] 	        cpu_din,	
   input		ext_fs,		
   input		blank,		
   input		hsyncin,	
   input		vsyncin,	
   input [23:0] 	pix_din,	
   input		idac_en,	
   input		ldi_2xzoom, 	
   input                fdp_on,         
   output [1:0] 	bpp,		
   output 	        vga_mode,       
   output 	        dac_pwr,        
   output 	        syncn2dac,      
   output reg 	        blanknr,        
   output reg	        blankng,        
   output reg	        blanknb,        
   output 	        sense,		
   output [7:0] 	cpu_dout,	
   output 	        hsyncout,	
   output 	        vsyncout,	
   output reg	        dac_cblankn,	
   output [7:0] 	p0_red, 	
   output [7:0] 	p0_green, 	
   output [7:0] 	p0_blue, 	
   output reg           pixs,           
   output reg           display_en,     
   output               dac_dpe,        
   input		pll_busy,
   output		pll_write_param,
   output [3:0]		pll_counter_type,
   output [2:0]		pll_counter_param,
   output [8:0]		pll_data_in,
   output		pll_reconfig,
   output [2:0] 	pixclksel,
   output [1:0] 	int_fs,
   output 		sync_ext,
   output 		pll_areset_in
   );
  wire 		blu_comp, grn_comp, red_comp;
  assign red_comp = 1'b0;
  assign grn_comp = 1'b0;
  assign blu_comp = 1'b0;
  assign 	sense = (idac_en) ?  ~(blu_comp | grn_comp | red_comp) : 1'b1;
  wire 		blankx6;    
  reg 		blankr, blankg, blankb;
  wire [7:0] 	pal_cpu_adr;
  wire [7:0] 	dicr, dicg, dicb;
  wire [7:0] 	palr_addr_evn;
  wire [7:0] 	palg_addr_evn;
  wire [7:0] 	palb_addr_evn;
  wire [7:0] 	palr2dac_evn, palr2cpu;
  wire [7:0] 	palg2dac_evn, palg2cpu;
  wire [7:0] 	palb2dac_evn, palb2cpu;
  wire [7:0] 	cursor_addr;
  wire [7:0] 	cursor1_data;
  wire [7:0] 	cursor2_data;
  wire [7:0] 	cursor3_data;
  wire [7:0] 	cursor4_data;
  wire 		lblu_comp;
  wire 		lgrn_comp;
  wire 		lred_comp;
  wire [10:0] 	idx_raw, idx_inc;
  wire [2:0] 	cp_addr;
  wire [2:0] 	pixformat;
  wire [3:0] 	hsyn_pos;
  wire [3:0] 	dac_op;
  wire [1:0] 	syscctl,  pix_sel, vsyn_cntl, hsyn_cntl;
  wire [7:0] 	cur1red , cur1grn , cur1blu, cur2red,
                cur2grn, cur2blu, cur3red, cur3grn, cur3blu, pal_wradr,
                pal_data1, pal_data2, pal_data3,
                pix_mask, curctl, curxlow, curxhi,
                curylow, curyhi, adcuratt,
                p0_red_pal_adr, p0_grn_pal_adr, p0_blu_pal_adr;
  wire [5:0] 	curhotx , curhoty;
  wire [7:0] 	pixreg20, pixreg24,
		pixreg21, pixreg25,
		pixreg22, pixreg26,
		pixreg23, pixreg27;
  wire 		sclk_pwr, sync_pwr, iclk_pwr, csyn_invt, vsyn_invt,
		hsyn_invt, sixbitlin,wr_mode, rd_mode,
		b8dcol, b16dcol, ziblin, fsf,
		b32dcol, adcurctl, misr_cntl, sens_disb,
		sens_sel, xor_sync, padr_rfmt, blank_cntl,
		sclk_inv, blankx, colres;
  wire [7:0] 	misr_red, misr_grn, misr_blu, cpu2cursor;
  wire [7:0] 	red2pal, grn2pal, blu2pal ;
  wire [7:0] 	paladr;
  wire 		palwr ;
  wire [7:0] 	pal2cpu;
  wire 		hsync, vsync_m1;
  wire [7:0] 	p0_red_pal, p0_grn_pal, p0_blu_pal, palred, palgrn, palblu;
  wire [7:0] 	cursor_data1, cursor_data2, cursor_data3, cursor_data4,
		cursor2cpu;
  wire  	display_cursor;
  wire 		p0_apply_cursor, p0_highlight, p0_translucent;
  wire [7:0] 	act_curylow, act_curyhi, act_curxlow, act_curxhi;
  wire [7:0] 	p0_blu_cursor;
  wire [7:0] 	p0_grn_cursor;
  wire [7:0] 	p0_red_cursor;
  wire [7:0] 	cpu_cursor_addr;
  wire 		enable_crc, blankx4d;
  reg 		bvdac1, blankvdac; 
  wire [6:0] 	mreg;
  wire [5:0] 	nreg;
  wire [2:0] 	preg;
  wire [1:0] 	creg;
  wire [3:0] 	p_counter;
  wire [2:0] 	p_param;
  wire [8:0] 	p_data_in;
  wire [8:0] 	p_data_out;
  wire [3:0] 	s_counter;
  wire [2:0] 	s_param;
  wire [8:0] 	s_data_in;
  wire [8:0] 	s_data_out;
  wire 		misr_done;
  wire 		vsync;
  wire 		init_crc;
  always @(posedge pixclk or negedge hresetn)
    if (!hresetn) begin
      bvdac1             <= 1'b0;
      pixs               <= 1'b0;
      dac_cblankn 	 <= 1'b0;
      display_en         <= 1'b0;
      blankr             <= 1'b0;
      blankb             <= 1'b0;
      blankg             <= 1'b0;
      blanknr            <= 1'b0;
      blanknb            <= 1'b0;
      blankng            <= 1'b0;
    end else if (iclk_pwr) begin
      bvdac1             <= 1'b0;
      pixs               <= 1'b0;
      dac_cblankn 	 <= 1'b0;
      display_en         <= 1'b0;
      blankr             <= 1'b0;
      blankb             <= 1'b0;
      blankg             <= 1'b0;
      blanknr            <= 1'b0;
      blanknb            <= 1'b0;
      blankng            <= 1'b0;
    end else begin
      bvdac1             <= !blankx4d; 
      pixs               <= ~vga_mode; 
      dac_cblankn 	 <= blankx6 & ~blank_cntl & fdp_on;
      display_en         <= blankx6 & ~blank_cntl & fdp_on;
      blankr             <= blank_cntl | dac_op[2] | !blankx4d;
      blankb             <= blank_cntl | dac_op[2] | !blankx4d;
      blankg             <= blank_cntl | !blankx4d;
      blanknr            <= dac_op[0] & !(blank_cntl | dac_op[2] | bvdac1);
      blanknb            <= dac_op[0] & !(blank_cntl | dac_op[2] | bvdac1);
      blankng            <= dac_op[0] & !(blank_cntl |  bvdac1);
    end
  wire 		sog = dac_op[3];
  assign 	dac_dpe = ~dac_op[0] | ~dac_cblankn;
  assign 	bpp = pixformat[2:1];
  cpu_int u_cpu_int 
    (
     .hclk		        (hclk),
     .hresetn	                (hresetn),
     .rs		        (rs),
     .wrn		        (wrn),
     .rdn		        (rdn),
     .cpu_din	                (cpu_din),
     .mreg		        (mreg),
     .nreg		        (nreg),
     .preg		        (preg),
     .creg		        (creg),
     .cursor2cpu	        (cursor2cpu),
     .lblu_comp	                (lblu_comp),
     .lgrn_comp	                (lgrn_comp),
     .lred_comp	                (lred_comp),
     .blu_comp	                (blu_comp),
     .grn_comp	                (grn_comp),
     .red_comp	                (red_comp),
     .misr_done	                (misr_done),
     .pal2cpu	                (pal2cpu),
     .paladr		        (paladr),
     .act_curxlow	        (act_curxlow),
     .act_curxhi	        (act_curxhi),
     .act_curylow	        (act_curylow),
     .act_curyhi	        (act_curyhi),
     .misr_red	                (misr_red),
     .misr_grn	                (misr_grn),
     .misr_blu	                (misr_blu),
     .ext_fs		        (ext_fs),
     .rd_mode	                (rd_mode),
     .idx_inc	                (idx_inc),
     .idx_raw	                (idx_raw),
     .cpu2cursor	        (cpu2cursor),
     .cp_addr	                (cp_addr),
     .pixformat	                (pixformat),
     .pixclksel	                (pixclksel),
     .hsyn_pos	                (hsyn_pos),
     .dac_op		        (dac_op),
     .syscctl	                (syscctl),
     .pix_sel	                (pix_sel),
     .vsyn_cntl	                (vsyn_cntl),
     .hsyn_cntl	                (hsyn_cntl),
     .int_fs		        (int_fs),
     .cur1red	                (cur1red),
     .cur1grn	                (cur1grn),
     .cur1blu	                (cur1blu),
     .cur2red	                (cur2red),
     .cur2grn	                (cur2grn),
     .cur2blu	                (cur2blu),
     .cur3red	                (cur3red),
     .cur3grn	                (cur3grn),
     .cur3blu	                (cur3blu),
     .pal_wradr	                (pal_wradr),
     .pal_data1	                (pal_data1),
     .pal_data2	                (pal_data2),
     .pal_data3	                (pal_data3),
     .pix_mask	                (pix_mask),
     .curctl		        (curctl),
     .curxlow	                (curxlow),
     .curxhi		        (curxhi),
     .curylow	                (curylow),
     .curyhi		        (curyhi),
     .sysmctl	                (),
     .cpu_dout	                (cpu_dout),
     .adcuratt	                (adcuratt),
     .curhotx	                (curhotx),
     .curhoty	                (curhoty),
     .sysnctl	                (),
     .syspctl	                (),
     .pixreg20	                (pixreg20),
     .pixreg24	                (pixreg24),
     .pixreg21	                (pixreg21),
     .pixreg25	                (pixreg25),
     .pixreg22 	                (pixreg22),
     .pixreg26	                (pixreg26),
     .pixreg23	                (pixreg23),
     .pixreg27	                (pixreg27),
     .sclk_pwr	                (sclk_pwr),
     .sync_pwr	                (sync_pwr),
     .iclk_pwr	                (iclk_pwr),
     .dac_pwr	                (dac_pwr),
     .csyn_invt	                (csyn_invt),
     .vsyn_invt	                (vsyn_invt),
     .hsyn_invt	                (hsyn_invt),
     .sixbitlin	                (sixbitlin),
     .wr_mode	                (wr_mode),
     .vga_mode	                (vga_mode),
     .b8dcol		        (b8dcol),
     .b16dcol	                (b16dcol),
     .b32dcol	                (b32dcol),
     .ziblin		        (ziblin),
     .fsf		        (fsf),
     .adcurctl	                (adcurctl),
     .prog_mode	                (),
     .spll_enab	                (),
     .misr_cntl	                (misr_cntl),
     .sens_disb	                (sens_disb),
     .sens_sel	                (sens_sel),
     .xor_sync 	                (xor_sync),
     .padr_rfmt	                (padr_rfmt),
     .blank_cntl	        (blank_cntl),
     .colres		        (colres),
     .sclk_inv	                (sclk_inv),
     .ppll_enab	                ()
     );
  syncs u_syncs 
    (
     .crtclock		        (crtclock),
     .pixclk			(pixclk),
     .hresetn                   (hresetn),
     .sclk_pwr	                (sclk_pwr),
     .sync_pwr	                (sync_pwr),
     .iclk_pwr	                (iclk_pwr),
     .vsyncin		        (vsyncin),
     .hcsyncin		        (hsyncin),
     .xor_sync		        (xor_sync),
     .vsyn_invt		        (vsyn_invt),
     .hsyn_invt		        (hsyn_invt),
     .csyn_invt		        (csyn_invt),
     .sog			(sog),
     .hsyn_cntl		        (hsyn_cntl),
     .vsyn_cntl		        (vsyn_cntl),
     .hsyn_pos		        (hsyn_pos) ,
     .vsyncout		        (vsyncout),
     .hsyncout		        (hsyncout),
     .syncn2dac		        (syncn2dac)
     );
  blnk u_blnk 
    (
     .pixclk			(pixclk),
     .reset			(hresetn),
     .blankx			(blankx) ,
     .misr_cntl		        (misr_cntl),
     .blu_comp		        (blu_comp),
     .grn_comp		        (grn_comp),
     .red_comp		        (red_comp),
     .vga_en                    (vga_mode),
     .hsync			(hsync),
     .vsync			(vsync),
     .vsync_m1		        (vsync_m1),
     .misr_done		        (misr_done),
     .enable_crc		(enable_crc),
     .init_crc		        (init_crc),
     .lblu_comp		        (lblu_comp),
     .lgrn_comp		        (lgrn_comp),
     .lred_comp		        (lred_comp),
     .blankx4d		        (blankx4d),
     .blankx6		        (blankx6)
     );
  crcx u_crcx
    (
     .pixclk			(pixclk),
     .rstn			(hresetn),
     .enable_crc		(enable_crc),
     .init_crc		        (init_crc),
     .red                        (p0_red),
     .grn                        (p0_green),
     .blu                        (p0_blue),
     .misr_red                   (misr_red),
     .misr_grn                   (misr_grn),
     .misr_blu                   (misr_blu)
     );
  cursor u_cursor 
    (
     .pixclk			(pixclk),
     .reset			(hresetn),
     .rdn			(rdn),
     .wrn			(wrn),
     .adcurctl		        (adcurctl),
     .hsync			(hsync),
     .vsync			(vsync),
     .cursor1_data		(cursor1_data),
     .cursor2_data		(cursor2_data),
     .cursor3_data		(cursor3_data),
     .cursor4_data		(cursor4_data),
     .cur1red		        (cur1red),
     .cur1grn		        (cur1grn),
     .cur1blu 		        (cur1blu ),
     .cur2red		        (cur2red),
     .cur2grn		        (cur2grn),
     .cur2blu		        (cur2blu),
     .cur3red		        (cur3red),
     .cur3grn		        (cur3grn),
     .cur3blu		        (cur3blu),
     .curctl			(curctl),
     .adcuratt		        (adcuratt),
     .curxlow		        (curxlow),
     .curxhi			(curxhi),
     .curylow		        (curylow),
     .curyhi			(curyhi),
     .curhotx		        (curhotx),
     .curhoty		        (curhoty),
     .idx_raw		        (idx_raw),
     .display_cursor		(display_cursor),
     .p0_apply_cursor		(p0_apply_cursor),
     .p0_highlight	        (p0_highlight),
     .p0_translucent		(p0_translucent),
     .act_curxlow		(act_curxlow),
     .act_curxhi		(act_curxhi),
     .act_curylow		(act_curylow),
     .act_curyhi		(act_curyhi),
     .p0_red_cursor 		(p0_red_cursor),
     .p0_grn_cursor		(p0_grn_cursor),
     .p0_blu_cursor		(p0_blu_cursor),
     .cursor_addr		(cursor_addr)
     );
  pal_ctl  u_pal_ctl 
    (
     .hclk			(hclk),
     .hresetn		        (hresetn),
     .wrn			(wrn),
     .rdn			(rdn),
     .wr_mode		        (wr_mode),
     .rd_mode		        (rd_mode),
     .colres			(colres),
     .pal_data1		        (pal_data1),
     .pal_data2		        (pal_data2),
     .pal_data3		        (pal_data3),
     .pal_wradr		        (pal_wradr),
     .palred			(palr2cpu),
     .palgrn			(palg2cpu),
     .palblu 		        (palb2cpu),
     .cp_addr		        (cp_addr),
     .paladr			(paladr),
     .palwr			(palwr),
     .red2pal		        (red2pal),
     .grn2pal		        (grn2pal),
     .blu2pal		        (blu2pal),
     .pal2cpu		        (pal2cpu)
     );
  ram_ctl u_ram_ctl 
    (
     .pixclk			(pixclk),
     .hresetn			(hresetn),
     .colres			(colres),
     .sixbitlin		        (sixbitlin),
     .p0_red_pal_adr		(p0_red_pal_adr),
     .p0_grn_pal_adr		(p0_grn_pal_adr),
     .p0_blu_pal_adr		(p0_blu_pal_adr),
     .palr2dac_evn		(palr2dac_evn),
     .palg2dac_evn		(palg2dac_evn),
     .palb2dac_evn		(palb2dac_evn),
     .p0_red_pal		(p0_red_pal),
     .p0_grn_pal		(p0_grn_pal),
     .p0_blu_pal		(p0_blu_pal),
     .palr_addr_evn		(palr_addr_evn),
     .palg_addr_evn		(palg_addr_evn),
     .palb_addr_evn		(palb_addr_evn)
     );
  ram_blks u_ram_blks 
    (
     .hclk			(hclk),
     .hresetn		        (hresetn),
     .wrn			(wrn),
     .pixclk			(pixclk),
     .palwr			(palwr), 
     .pal_cpu_adr		(paladr), 
     .red2pal		        (red2pal),
     .grn2pal		        (grn2pal),
     .blu2pal		        (blu2pal),
     .cpu_pal_one		(1'b0),
     .cpu_cursor_one		(1'b0),
     .idx_inc		        (idx_inc),
     .cpu2cursor		(cpu2cursor), 
     .disp_pal_one		(1'b0),
     .disp_cursor_one	        (1'b0),
     .palr_addr_evn		(palr_addr_evn), 
     .palg_addr_evn		(palg_addr_evn), 
     .palb_addr_evn		(palb_addr_evn), 
     .cursor_addr		(cursor_addr),
     .palr2dac_evn		(palr2dac_evn), 
     .palg2dac_evn		(palg2dac_evn), 
     .palb2dac_evn		(palb2dac_evn), 
     .palr2cpu		        (palr2cpu), 
     .palg2cpu		        (palg2cpu), 
     .palb2cpu		        (palb2cpu), 
     .cursor2cpu		(cursor2cpu),
     .cursor1_data		(cursor1_data), 
     .cursor2_data		(cursor2_data),
     .cursor3_data		(cursor3_data), 
     .cursor4_data		(cursor4_data) 
     );
  pixel_dp  pix_dpx 
    (
     .reset			(hresetn),
     .blank			(blank),
     .pixclk			(pixclk),
     .pix_din		        (pix_din),
     .pixformat		        (pixformat),
     .b8dcol			(b8dcol),
     .b16dcol		        (b16dcol),
     .ziblin			(ziblin),
     .fsf			(fsf),
     .b32dcol		        (b32dcol),
     .vga_mode		        (vga_mode),
     .display_cursor		(display_cursor),
     .p0_apply_cursor		(p0_apply_cursor),
     .p0_highlight	        (p0_highlight),
     .p0_translucent		(p0_translucent),
     .p0_red_cursor		(p0_red_cursor),
     .p0_grn_cursor		(p0_grn_cursor),
     .p0_blu_cursor		(p0_blu_cursor),
     .p0_red_pal		(p0_red_pal),
     .p0_grn_pal		(p0_grn_pal),
     .p0_blu_pal		(p0_blu_pal),
     .blankr			(blankr),
     .pix_mask		        (pix_mask),
     .blankb			(blankb),
     .blankg			(blankg),
     .p0_red_pal_adr		(p0_red_pal_adr),
     .p0_grn_pal_adr		(p0_grn_pal_adr),
     .p0_blu_pal_adr		(p0_blu_pal_adr),
     .p0_red			(p0_red),
     .p0_green			(p0_green),
     .p0_blue			(p0_blue),
     .blankx			(blankx)
     );
  pix_pll u_pix_pll 
    (
     .hclk		        (hclk),
     .hresetn		        (hresetn),
     .pixclksel		        (pixclksel),    
     .int_fs   		        (int_fs),       
     .ext_fs   		        (ext_fs),       
     .pixreg20 		        (pixreg20),     
     .pixreg21 		        (pixreg21),     
     .pixreg22 		        (pixreg22),     
     .pixreg23 		        (pixreg23),     
     .pixreg24 		        (pixreg24),     
     .pixreg25 		        (pixreg25),     
     .pixreg26 		        (pixreg26),     
     .pixreg27 		        (pixreg27),     
     .busy                	(pll_busy),
     .mreg_temp		        (mreg),
     .nreg_temp		        (nreg),
     .preg     		        (preg),
     .sync_ext                  (sync_ext),
     .write_param               (pll_write_param),
     .counter_type              (pll_counter_type),
     .counter_param             (pll_counter_param),
     .data_in             	(pll_data_in),
     .reconfig                  (pll_reconfig),
     .pll_areset_in             (pll_areset_in)
     );
endmodule
