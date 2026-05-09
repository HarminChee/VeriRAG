`timescale 1ps / 1ps
`timescale 1ps / 1ps
module ppu_ri
(
  input  wire        clk_in,            
  input  wire        rst_in,            
  input  wire [ 2:0] sel_in,            
  input  wire        ncs_in,            
  input  wire        r_nw_in,           
  input  wire [ 7:0] cpu_d_in,          
  input  wire [13:0] vram_a_in,         
  input  wire [ 7:0] vram_d_in,         
  input  wire [ 7:0] pram_d_in,         
  input  wire        vblank_in,         
  input  wire [ 7:0] spr_ram_d_in,      
  input  wire        spr_overflow_in,   
  input  wire        spr_pri_col_in,    
  output wire [ 7:0] cpu_d_out,         
  output reg  [ 7:0] vram_d_out,        
  output reg         vram_wr_out,       
  output reg         pram_wr_out,       
  output wire [ 2:0] fv_out,            
  output wire [ 4:0] vt_out,            
  output wire        v_out,             
  output wire [ 2:0] fh_out,            
  output wire [ 4:0] ht_out,            
  output wire        h_out,             
  output wire        s_out,             
  output reg         inc_addr_out,      
  output wire        inc_addr_amt_out,  
  output wire        nvbl_en_out,       
  output wire        vblank_out,        
  output wire        bg_en_out,         
  output wire        spr_en_out,        
  output wire        bg_ls_clip_out,    
  output wire        spr_ls_clip_out,   
  output wire        spr_h_out,         
  output wire        spr_pt_sel_out,    
  output wire        upd_cntrs_out,     
  output wire [ 7:0] spr_ram_a_out,     
  output reg  [ 7:0] spr_ram_d_out,     
  output reg         spr_ram_wr_out     
);
reg [2:0] q_fv,  d_fv;   
reg [4:0] q_vt,  d_vt;   
reg       q_v,   d_v;    
reg [2:0] q_fh,  d_fh;   
reg [4:0] q_ht,  d_ht;   
reg       q_h,   d_h;    
reg       q_s,   d_s;    
reg [7:0] q_cpu_d_out,     d_cpu_d_out;      
reg       q_upd_cntrs_out, d_upd_cntrs_out;  
reg q_nvbl_en,     d_nvbl_en;     
reg q_spr_h,       d_spr_h;       
reg q_spr_pt_sel,  d_spr_pt_sel;  
reg q_addr_incr,   d_addr_incr;   
reg q_spr_en,      d_spr_en;      
reg q_bg_en,       d_bg_en;       
reg q_spr_ls_clip, d_spr_ls_clip; 
reg q_bg_ls_clip,  d_bg_ls_clip;  
reg q_vblank,      d_vblank;      
reg       q_byte_sel,  d_byte_sel;   
reg [7:0] q_rd_buf,    d_rd_buf;     
reg       q_rd_rdy,    d_rd_rdy;     
reg [7:0] q_spr_ram_a, d_spr_ram_a;  
reg       q_ncs_in;                  
reg       q_vblank_in;               
always @(posedge clk_in)
  begin
    if (rst_in)
      begin
        q_fv            <= 2'h0;
        q_vt            <= 5'h00;
        q_v             <= 1'h0;
        q_fh            <= 3'h0;
        q_ht            <= 5'h00;
        q_h             <= 1'h0;
        q_s             <= 1'h0;
        q_cpu_d_out     <= 8'h00;
        q_upd_cntrs_out <= 1'h0;
        q_nvbl_en       <= 1'h0;
        q_spr_h         <= 1'h0;
        q_spr_pt_sel    <= 1'h0;
        q_addr_incr     <= 1'h0;
        q_spr_en        <= 1'h0;
        q_bg_en         <= 1'h0;
        q_spr_ls_clip   <= 1'h0;
        q_bg_ls_clip    <= 1'h0;
        q_vblank        <= 1'h0;
        q_byte_sel      <= 1'h0;
        q_rd_buf        <= 8'h00;
        q_rd_rdy        <= 1'h0;
        q_spr_ram_a     <= 8'h00;
        q_ncs_in        <= 1'h1;
        q_vblank_in     <= 1'h0;
      end
    else
      begin
        q_fv            <= d_fv;
        q_vt            <= d_vt;
        q_v             <= d_v;
        q_fh            <= d_fh;
        q_ht            <= d_ht;
        q_h             <= d_h;
        q_s             <= d_s;
        q_cpu_d_out     <= d_cpu_d_out;
        q_upd_cntrs_out <= d_upd_cntrs_out;
        q_nvbl_en       <= d_nvbl_en;
        q_spr_h         <= d_spr_h;
        q_spr_pt_sel    <= d_spr_pt_sel;
        q_addr_incr     <= d_addr_incr;
        q_spr_en        <= d_spr_en;
        q_bg_en         <= d_bg_en;
        q_spr_ls_clip   <= d_spr_ls_clip;
        q_bg_ls_clip    <= d_bg_ls_clip;
        q_vblank        <= d_vblank;
        q_byte_sel      <= d_byte_sel;
        q_rd_buf        <= d_rd_buf;
        q_rd_rdy        <= d_rd_rdy;
        q_spr_ram_a     <= d_spr_ram_a;
        q_ncs_in        <= ncs_in;
        q_vblank_in     <= vblank_in;
      end
  end
always @*
  begin
    d_fv          = q_fv;
    d_vt          = q_vt;
    d_v           = q_v;
    d_fh          = q_fh;
    d_ht          = q_ht;
    d_h           = q_h;
    d_s           = q_s;
    d_cpu_d_out   = q_cpu_d_out;
    d_nvbl_en     = q_nvbl_en;
    d_spr_h       = q_spr_h;
    d_spr_pt_sel  = q_spr_pt_sel;
    d_addr_incr   = q_addr_incr;
    d_spr_en      = q_spr_en;
    d_bg_en       = q_bg_en;
    d_spr_ls_clip = q_spr_ls_clip;
    d_bg_ls_clip  = q_bg_ls_clip;
    d_byte_sel    = q_byte_sel;
    d_spr_ram_a   = q_spr_ram_a;
    d_rd_buf = (q_rd_rdy) ? vram_d_in : q_rd_buf;
    d_rd_rdy = 1'b0;
    d_upd_cntrs_out = 1'b0;
    d_vblank = (~q_vblank_in & vblank_in) ? 1'b1 :
               (~vblank_in)               ? 1'b0 : q_vblank;
    vram_wr_out = 1'b0;
    vram_d_out  = 8'h00;
    pram_wr_out = 1'b0;
    inc_addr_out = 1'b0;
    spr_ram_d_out  = 8'h00;
    spr_ram_wr_out = 1'b0;
    if (q_ncs_in & ~ncs_in)
      begin
        if (r_nw_in)
          begin
            case (sel_in)
              3'h2:  
                begin
                  d_cpu_d_out = { q_vblank, spr_pri_col_in, spr_overflow_in, 5'b00000 };
                  d_byte_sel  = 1'b0;
                  d_vblank    = 1'b0;
                end
              3'h4:  
                begin
                  d_cpu_d_out = spr_ram_d_in;
                end
              3'h7:  
                begin
                  d_cpu_d_out  = (vram_a_in[13:8] == 6'h3F) ? pram_d_in : q_rd_buf;
                  d_rd_rdy     = 1'b1;
                  inc_addr_out = 1'b1;
                end
            endcase
          end
        else
          begin
            case (sel_in)
              3'h0:  
                begin
                  d_nvbl_en    = cpu_d_in[7];
                  d_spr_h      = cpu_d_in[5];
                  d_s          = cpu_d_in[4];
                  d_spr_pt_sel = cpu_d_in[3];
                  d_addr_incr  = cpu_d_in[2];
                  d_v          = cpu_d_in[1];
                  d_h          = cpu_d_in[0];
                end
              3'h1:  
                begin
                  d_spr_en      = cpu_d_in[4];
                  d_bg_en       = cpu_d_in[3];
                  d_spr_ls_clip = ~cpu_d_in[2];
                  d_bg_ls_clip  = ~cpu_d_in[1];
                end
              3'h3:  
                begin
                  d_spr_ram_a = cpu_d_in;
                end
              3'h4:  
                begin
                  spr_ram_d_out  = cpu_d_in;
                  spr_ram_wr_out = 1'b1;
                  d_spr_ram_a    = q_spr_ram_a + 8'h01;
                end
              3'h5:  
                begin
                  d_byte_sel = ~q_byte_sel;
                  if (~q_byte_sel)
                    begin
                      d_fh = cpu_d_in[2:0];
                      d_ht = cpu_d_in[7:3];
                    end
                  else
                    begin
                      d_fv = cpu_d_in[2:0];
                      d_vt = cpu_d_in[7:3];
                    end
                end
              3'h6:  
                begin
                  d_byte_sel = ~q_byte_sel;
                  if (~q_byte_sel)
                    begin
                      d_fv      = { 1'b0, cpu_d_in[5:4] };
                      d_v       = cpu_d_in[3];
                      d_h       = cpu_d_in[2];
                      d_vt[4:3] = cpu_d_in[1:0];
                    end
                  else
                    begin
                      d_vt[2:0]       = cpu_d_in[7:5];
                      d_ht            = cpu_d_in[4:0];
                      d_upd_cntrs_out = 1'b1;
                    end
                end
              3'h7:  
                begin
                  if (vram_a_in[13:8] == 6'h3F)
                    pram_wr_out = 1'b1;
                  else
                    vram_wr_out = 1'b1;
                  vram_d_out   = cpu_d_in;
                  inc_addr_out = 1'b1;
                end
            endcase
          end
      end
  end
assign cpu_d_out        = (~ncs_in & r_nw_in) ? q_cpu_d_out : 8'h00;
assign fv_out           = q_fv;
assign vt_out           = q_vt;
assign v_out            = q_v;
assign fh_out           = q_fh;
assign ht_out           = q_ht;
assign h_out            = q_h;
assign s_out            = q_s;
assign inc_addr_amt_out = q_addr_incr;
assign nvbl_en_out      = q_nvbl_en;
assign vblank_out       = q_vblank;
assign bg_en_out        = q_bg_en;
assign spr_en_out       = q_spr_en;
assign bg_ls_clip_out   = q_bg_ls_clip;
assign spr_ls_clip_out  = q_spr_ls_clip;
assign spr_h_out        = q_spr_h;
assign spr_pt_sel_out   = q_spr_pt_sel;
assign upd_cntrs_out    = q_upd_cntrs_out;
assign spr_ram_a_out    = q_spr_ram_a;
endmodule
