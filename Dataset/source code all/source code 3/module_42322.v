`timescale 1 ns / 10 ps
  module dlp_top
    #(parameter BYTES = 4
      )
    (
     input                 hb_clk,         
     input                 hb_rstn,        
     input [8:2]           hb_adr,         
     input                 hb_wstrb,       
     input [3:0]           hb_ben,         
     input                 hb_csn,         
     input [31:0]          hb_din,         
     input [3:0]           dlp_offset,     
     input                 de_busy,        
     input                 mclock,         
     input                 mc_rdy,         
     input                 mc_push,        
     input                 mc_done,        
     input [(BYTES*8)-1:0] pd_in,          
     input                 v_sync_tog,     
     input                 cache_busy,     
     input [3:0]           sorg_upper,     
     output [8:2]          de_adr,         
     output                de_wstrb,       
     output                de_csn,         
     output [3:0]          de_ben,         
     output [31:0]         de_data,        
     output [53:0]         dl_rdback,      
     output [27:0]         mc_adr,         
     output                dl_sen,         
     output                dl_memreq,      
     output [4:0]          dlp_wcnt,       
     output                hb_de_busy,     
     output                hold_start      
     );
  wire          dlp_actv_2;     
  wire [27:0]   hb_end;         
  wire          dl_idle;        
  wire          dl_stop;        
  wire          dlf;            
  wire          wvs;            
  wire          v_sunk;         
  wire          actv_stp;       
  wire          cmd_rdy_ld;     
  wire          hb_wc;          
  wire          wcf;            
  wire [27:0]   dl_adr;         
  wire          char_select;    
  wire [31:0]   table_org0,     
                table_org1;     
  wire          char_count;     
  wire [31:0]   curr_sorg;      
  wire [3:0]    curr_pg_cnt;    
  wire [7:0]    curr_height;    
  wire [7:0]    curr_width;     
  wire [8:2]    aad,bad,cad;    
  wire [127:0]  dl_temp;        
  wire [15:0]   dest_x;         
  wire [15:0]   dest_y;         
  wire          reset_wait;     
  wire          next_dle;
  wire          cmd_ack;
  wire          text_store;
  wire          dlp_data_avail;
  wire          dlp_flush;
  wire [127:0]  dlp_data;
  wire          dlp_wreg_pop;
  reg           dlp_rstn_hb;        
  reg           dlp_rstn_mc;        
  reg           mc_sync0, mc_sync1; 
  reg           mc_done_0, mc_done_tog, mc_done_tog_sync_0, mc_done_tog_sync_1, mc_done_tog_sync;
  reg           dlp_pop;
  localparam    DLCNT_DLADR     = 6'b0_1111_1;  
  pp_sync SYNC0 (hb_clk, hb_rstn, v_sync_tog, v_sunk);
  always @(posedge mclock or negedge hb_rstn)
    if (!hb_rstn) begin
      mc_sync0    <= 1'b0;
      mc_sync1    <= 1'b0;
      dlp_rstn_mc <= 1'b0;
      mc_done_0   <= 1'b0;
      mc_done_tog <= 1'b0;
    end else begin
      mc_sync0 <= dlp_rstn_hb;
      mc_sync1 <= mc_sync0;
      dlp_rstn_mc <= mc_sync0 & ~mc_sync1;
      mc_done_0 <= mc_done;
      if (mc_done & ~mc_done_0) mc_done_tog <= ~mc_done_tog;
    end
  always @(posedge hb_clk or negedge hb_rstn)
    if (!hb_rstn) begin
      dlp_rstn_hb <= 1'b0;
      dlp_pop     <= 1'b0;
    end else begin
      dlp_pop <= dlp_wreg_pop;
      dlp_rstn_hb <= !hb_ben[3] & hb_din[31] & 
                     (hb_adr == {DLCNT_DLADR, 1'b1}) &&
                     hb_wstrb && !hb_csn;
      mc_done_tog_sync_0 <= mc_done_tog;
      mc_done_tog_sync_1 <= mc_done_tog_sync_0;
      mc_done_tog_sync   <= mc_done_tog_sync_1 ^ mc_done_tog_sync_0;
    end
  dlp_reg REG
    (
     .hb_clk             (hb_clk),
     .hb_rstn            (hb_rstn),
     .dlp_rstn_hb        (dlp_rstn_hb),
     .hb_adr             (hb_adr),
     .hb_wstrb           (hb_wstrb),
     .hb_ben             (hb_ben),
     .hb_csn             (hb_csn),
     .hb_din             (hb_din),
     .de_adr             (de_adr),
     .de_wstrb           (de_wstrb),
     .de_ben             (de_ben),
     .de_csn             (de_csn),
     .de_din             (de_data),
     .actv_stp           (actv_stp),
     .next_dle           (next_dle),
     .cmd_ack            (cmd_ack),
     .reset_wait         (reset_wait),
     .dlp_offset         (4'h0), 
     .hb_addr            (dl_adr),
     .hb_end             (hb_end),
     .hb_fmt             (dlf),
     .hb_wc              (hb_wc),
     .hb_sen             (dl_sen),
     .hb_stp             (dl_stop),
     .dlp_actv_2         (dlp_actv_2),
     .dl_idle            (dl_idle),
     .hold_start         (hold_start),
     .cmd_rdy_ld         (cmd_rdy_ld),
     .wcf                (wcf),
     .dlp_wcnt           (dlp_wcnt)
     );
  dlp_store #
    (
     .BYTES              (BYTES)
     ) STORE
    (
     .hb_clk             (hb_clk),
     .hb_rstn            (hb_rstn),
     .dlp_rstn_mc        (dlp_rstn_mc),
     .dlp_wreg_pop       (dlp_wreg_pop),
     .dlp_data           (dlp_data), 
     .dlf                (dlf),
     .text               (text_store),
     .char_select        (char_select),
     .list_format        (list_format),
     .wcount             (wcount),
     .wvs                (wvs), 
     .table_org0         (table_org0), 
     .table_org1         (table_org1),
     .char_count         (char_count),
     .sorg_upper         (sorg_upper),
     .curr_sorg          (curr_sorg),
     .curr_pg_cnt        (curr_pg_cnt), 
     .curr_height        (curr_height),
     .curr_width         (curr_width), 
     .aad                (aad),
     .bad                (bad),
     .cad                (cad),
     .dl_temp            (dl_temp),
     .dest_x             (dest_x),
     .dest_y             (dest_y)
     );
  dlp_sm SM
    (
     .hb_clk             (hb_clk),
     .hb_rstn            (hb_rstn),
     .dlp_rstn_hb        (dlp_rstn_hb),
     .mc_done            (mc_done_tog_sync),
     .hb_adr             (hb_adr),
     .hb_wstrb           (hb_wstrb),
     .hb_ben             (hb_ben),
     .hb_csn             (hb_csn),
     .hb_din             (hb_din),
     .de_busy            (de_busy),
     .dl_stop            (dl_stop), 
     .table_org0         (table_org0),
     .table_org1         (table_org1),
     .aad                (aad),
     .bad                (bad),
     .cad                (cad),
     .dl_temp            (dl_temp),
     .curr_sorg          (curr_sorg),
     .curr_height        (curr_height),
     .curr_width         (curr_width),
     .curr_pg_cnt        (curr_pg_cnt),
     .dest_x             (dest_x),
     .dest_y             (dest_y),
     .cmd_rdy_ld         (cmd_rdy_ld),
     .wcf                (wcf),
     .cache_busy         (cache_busy),
     .mc_rdy             (mc_rdy),
     .dl_idle            (dl_idle),
     .list_format        (list_format),
     .v_sunk             (v_sunk),
     .wvs                (wvs),
     .dlf                (dlf),
     .wcount             (wcount),
     .dl_adr             (dl_adr),
     .dlp_actv_2         (dlp_actv_2),
     .char_count         (char_count),
     .dlp_data_avail     (dlp_data_avail),
     .dl_memreq          (dl_memreq),
     .text_store         (text_store),
     .char_select        (char_select),
     .actv_stp           (actv_stp),
     .mc_adr             (mc_adr),
     .hb_de_busy         (hb_de_busy),
     .de_adr             (de_adr),
     .de_ben             (de_ben),
     .de_wstrb           (de_wstrb),
     .de_data            (de_data),
     .de_csn             (de_csn),
     .cmd_ack            (cmd_ack),
     .next_dle           (next_dle),
     .reset_wait         (reset_wait),
     .dlp_wreg_pop       (dlp_wreg_pop),
     .dlp_flush          (dlp_flush)
     );
  dlp_cache #
    (
     .BYTES              (BYTES)
     ) u_dlp_cache
    (
     .hb_clk             (hb_clk),
     .hb_rstn            (hb_rstn),
     .dlp_flush          (dlp_flush),
     .dlp_pop            (dlp_pop),
     .mclock             (mclock),
     .mc_push            (mc_push),
     .pd_in              (pd_in),
     .dlp_data_avail     (dlp_data_avail),
     .dlp_data     	 (dlp_data)
     );
assign dl_rdback[20:0]  =       dl_adr[20:0];   
assign dl_rdback[53:51] =       3'b0;           
assign dl_rdback[22:21] =       {hb_wc,hold_start};
assign dl_rdback[43:23] =       hb_end[20:0];   
assign dl_rdback[50:48] =       3'b0;           
assign dl_rdback[44]    =       1'b0;
assign dl_rdback[45]    =       dlf;
assign dl_rdback[46]    =       dl_sen;
assign dl_rdback[47]    =       dl_stop;
endmodule
`timescale 1 ns / 10 ps
  module dlp_top
    #(parameter BYTES = 4
      )
    (
     input                 hb_clk,         
     input                 hb_rstn,        
     input [8:2]           hb_adr,         
     input                 hb_wstrb,       
     input [3:0]           hb_ben,         
     input                 hb_csn,         
     input [31:0]          hb_din,         
     input [3:0]           dlp_offset,     
     input                 de_busy,        
     input                 mclock,         
     input                 mc_rdy,         
     input                 mc_push,        
     input                 mc_done,        
     input [(BYTES*8)-1:0] pd_in,          
     input                 v_sync_tog,     
     input                 cache_busy,     
     input [3:0]           sorg_upper,     
     output [8:2]          de_adr,         
     output                de_wstrb,       
     output                de_csn,         
     output [3:0]          de_ben,         
     output [31:0]         de_data,        
     output [53:0]         dl_rdback,      
     output [27:0]         mc_adr,         
     output                dl_sen,         
     output                dl_memreq,      
     output [4:0]          dlp_wcnt,       
     output                hb_de_busy,     
     output                hold_start      
     );
  wire          dlp_actv_2;     
  wire [27:0]   hb_end;         
  wire          dl_idle;        
  wire          dl_stop;        
  wire          dlf;            
  wire          wvs;            
  wire          v_sunk;         
  wire          actv_stp;       
  wire          cmd_rdy_ld;     
  wire          hb_wc;          
  wire          wcf;            
  wire [27:0]   dl_adr;         
  wire          char_select;    
  wire [31:0]   table_org0,     
                table_org1;     
  wire          char_count;     
  wire [31:0]   curr_sorg;      
  wire [3:0]    curr_pg_cnt;    
  wire [7:0]    curr_height;    
  wire [7:0]    curr_width;     
  wire [8:2]    aad,bad,cad;    
  wire [127:0]  dl_temp;        
  wire [15:0]   dest_x;         
  wire [15:0]   dest_y;         
  wire          reset_wait;     
  wire          next_dle;
  wire          cmd_ack;
  wire          text_store;
  wire          dlp_data_avail;
  wire          dlp_flush;
  wire [127:0]  dlp_data;
  wire          dlp_wreg_pop;
  reg           dlp_rstn_hb;        
  reg           dlp_rstn_mc;        
  reg           mc_sync0, mc_sync1; 
  reg           mc_done_0, mc_done_tog, mc_done_tog_sync_0, mc_done_tog_sync_1, mc_done_tog_sync;
  reg           dlp_pop;
  localparam    DLCNT_DLADR     = 6'b0_1111_1;  
  pp_sync SYNC0 (hb_clk, hb_rstn, v_sync_tog, v_sunk);
  always @(posedge mclock or negedge hb_rstn)
    if (!hb_rstn) begin
      mc_sync0    <= 1'b0;
      mc_sync1    <= 1'b0;
      dlp_rstn_mc <= 1'b0;
      mc_done_0   <= 1'b0;
      mc_done_tog <= 1'b0;
    end else begin
      mc_sync0 <= dlp_rstn_hb;
      mc_sync1 <= mc_sync0;
      dlp_rstn_mc <= mc_sync0 & ~mc_sync1;
      mc_done_0 <= mc_done;
      if (mc_done & ~mc_done_0) mc_done_tog <= ~mc_done_tog;
    end
  always @(posedge hb_clk or negedge hb_rstn)
    if (!hb_rstn) begin
      dlp_rstn_hb <= 1'b0;
      dlp_pop     <= 1'b0;
    end else begin
      dlp_pop <= dlp_wreg_pop;
      dlp_rstn_hb <= !hb_ben[3] & hb_din[31] & 
                     (hb_adr == {DLCNT_DLADR, 1'b1}) &&
                     hb_wstrb && !hb_csn;
      mc_done_tog_sync_0 <= mc_done_tog;
      mc_done_tog_sync_1 <= mc_done_tog_sync_0;
      mc_done_tog_sync   <= mc_done_tog_sync_1 ^ mc_done_tog_sync_0;
    end
  dlp_reg REG
    (
     .hb_clk             (hb_clk),
     .hb_rstn            (hb_rstn),
     .dlp_rstn_hb        (dlp_rstn_hb),
     .hb_adr             (hb_adr),
     .hb_wstrb           (hb_wstrb),
     .hb_ben             (hb_ben),
     .hb_csn             (hb_csn),
     .hb_din             (hb_din),
     .de_adr             (de_adr),
     .de_wstrb           (de_wstrb),
     .de_ben             (de_ben),
     .de_csn             (de_csn),
     .de_din             (de_data),
     .actv_stp           (actv_stp),
     .next_dle           (next_dle),
     .cmd_ack            (cmd_ack),
     .reset_wait         (reset_wait),
     .dlp_offset         (4'h0), 
     .hb_addr            (dl_adr),
     .hb_end             (hb_end),
     .hb_fmt             (dlf),
     .hb_wc              (hb_wc),
     .hb_sen             (dl_sen),
     .hb_stp             (dl_stop),
     .dlp_actv_2         (dlp_actv_2),
     .dl_idle            (dl_idle),
     .hold_start         (hold_start),
     .cmd_rdy_ld         (cmd_rdy_ld),
     .wcf                (wcf),
     .dlp_wcnt           (dlp_wcnt)
     );
  dlp_store #
    (
     .BYTES              (BYTES)
     ) STORE
    (
     .hb_clk             (hb_clk),
     .hb_rstn            (hb_rstn),
     .dlp_rstn_mc        (dlp_rstn_mc),
     .dlp_wreg_pop       (dlp_wreg_pop),
     .dlp_data           (dlp_data), 
     .dlf                (dlf),
     .text               (text_store),
     .char_select        (char_select),
     .list_format        (list_format),
     .wcount             (wcount),
     .wvs                (wvs), 
     .table_org0         (table_org0), 
     .table_org1         (table_org1),
     .char_count         (char_count),
     .sorg_upper         (sorg_upper),
     .curr_sorg          (curr_sorg),
     .curr_pg_cnt        (curr_pg_cnt), 
     .curr_height        (curr_height),
     .curr_width         (curr_width), 
     .aad                (aad),
     .bad                (bad),
     .cad                (cad),
     .dl_temp            (dl_temp),
     .dest_x             (dest_x),
     .dest_y             (dest_y)
     );
  dlp_sm SM
    (
     .hb_clk             (hb_clk),
     .hb_rstn            (hb_rstn),
     .dlp_rstn_hb        (dlp_rstn_hb),
     .mc_done            (mc_done_tog_sync),
     .hb_adr             (hb_adr),
     .hb_wstrb           (hb_wstrb),
     .hb_ben             (hb_ben),
     .hb_csn             (hb_csn),
     .hb_din             (hb_din),
     .de_busy            (de_busy),
     .dl_stop            (dl_stop), 
     .table_org0         (table_org0),
     .table_org1         (table_org1),
     .aad                (aad),
     .bad                (bad),
     .cad                (cad),
     .dl_temp            (dl_temp),
     .curr_sorg          (curr_sorg),
     .curr_height        (curr_height),
     .curr_width         (curr_width),
     .curr_pg_cnt        (curr_pg_cnt),
     .dest_x             (dest_x),
     .dest_y             (dest_y),
     .cmd_rdy_ld         (cmd_rdy_ld),
     .wcf                (wcf),
     .cache_busy         (cache_busy),
     .mc_rdy             (mc_rdy),
     .dl_idle            (dl_idle),
     .list_format        (list_format),
     .v_sunk             (v_sunk),
     .wvs                (wvs),
     .dlf                (dlf),
     .wcount             (wcount),
     .dl_adr             (dl_adr),
     .dlp_actv_2         (dlp_actv_2),
     .char_count         (char_count),
     .dlp_data_avail     (dlp_data_avail),
     .dl_memreq          (dl_memreq),
     .text_store         (text_store),
     .char_select        (char_select),
     .actv_stp           (actv_stp),
     .mc_adr             (mc_adr),
     .hb_de_busy         (hb_de_busy),
     .de_adr             (de_adr),
     .de_ben             (de_ben),
     .de_wstrb           (de_wstrb),
     .de_data            (de_data),
     .de_csn             (de_csn),
     .cmd_ack            (cmd_ack),
     .next_dle           (next_dle),
     .reset_wait         (reset_wait),
     .dlp_wreg_pop       (dlp_wreg_pop),
     .dlp_flush          (dlp_flush)
     );
  dlp_cache #
    (
     .BYTES              (BYTES)
     ) u_dlp_cache
    (
     .hb_clk             (hb_clk),
     .hb_rstn            (hb_rstn),
     .dlp_flush          (dlp_flush),
     .dlp_pop            (dlp_pop),
     .mclock             (mclock),
     .mc_push            (mc_push),
     .pd_in              (pd_in),
     .dlp_data_avail     (dlp_data_avail),
     .dlp_data     	 (dlp_data)
     );
assign dl_rdback[20:0]  =       dl_adr[20:0];   
assign dl_rdback[53:51] =       3'b0;           
assign dl_rdback[22:21] =       {hb_wc,hold_start};
assign dl_rdback[43:23] =       hb_end[20:0];   
assign dl_rdback[50:48] =       3'b0;           
assign dl_rdback[44]    =       1'b0;
assign dl_rdback[45]    =       dlf;
assign dl_rdback[46]    =       dl_sen;
assign dl_rdback[47]    =       dl_stop;
endmodule
