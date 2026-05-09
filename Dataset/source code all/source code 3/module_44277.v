module	histogram  (pclk,             
                     pclk2x,           
						 	sclk,					
							wen,              
					      rnext,            
							wa,               
							hist_do,			    
							wd,					
							frame_run,        
							line_run_a,         
							di_a,               
							di_vld_a,            
							bayer_phase      
						 );
  input			 pclk;
  input			 pclk2x;
  input			 sclk;
  input			 wen;
  input			 rnext;
  input  [ 2:0] wa;
  output [31:0] hist_do;
  input  [15:0] wd;
  input			 frame_run;
  input			 line_run_a;
  input  [15:0] di_a;
  input			 di_vld_a;
  input  [ 1:0] bayer_phase;
  wire [17:0]   hist_do0;
  reg			  line_run;
  reg  [15:0] di;
  reg			  pre_di_vld, di_vld;
   always @(posedge pclk) begin
    line_run <= line_run_a;
    di[15:0] <= di_a[15:0];
   end
   always @ (posedge pclk2x) begin
    pre_di_vld   <= di_vld_a;
    di_vld   <= pre_di_vld; 
   end
   reg  [15:0]  di2x;
   reg  [ 3:0]  dvld2x; 
   reg  [ 1:0]  bayer;
   reg  [ 1:0]  bayer_phase_latched;
   reg  [ 9:0]  hist_waddr;       
   reg  [ 9:0]  hist_waddr_hold1; 
   reg  [ 9:0]  hist_waddr_hold2; 
   reg          same_waddr;       
	reg          pre_same_addr;
   reg  [ 2:0]  frame_run_s;
   reg  [ 2:0]  line_run_s;
   reg          line_start,line_end;
   reg          frame_start;
   reg  [ 5:0]  hist_seq; 
   reg  [ 9:0]  hist_init_cntr;
   reg          end_hist_init;
   reg  [17:0]  hist_pre;  
   reg  [17:0]  hist_post; 
   wire         hist_bank; 
   reg          odd_line;
   reg  [13:1]  pix_cntr;
   reg  [13:1] line_cntr;
   reg          line_started, 
                line_ended;   
   reg          frame_started;
   reg          frame_ended;  
   reg          init_hist;    
   reg          init_hist_d;
   reg          window_on;    
   reg   [13:1] pos_left; 
   reg   [13:1] pos_top;
   reg   [13:1] size_width;
   reg   [13:1] size_height;
   reg   [1:0]  we_pos;
   reg   [1:0]  we_size;
   reg          we_addr;
   reg          we_addr_d;
   wire          rd_hist;
   reg   [ 9:0] hist_raddr; 
   reg          hist_wea;
   reg          hist_ena;
   reg          bayer_en;   
   reg          last_line;
   wire [17:0]  hist_doa; 
   wire [17:0]  hist_dia= hist_post[17:0]; 
	reg  [15:0]  wdd; 
   reg  [13:1]  minus_pos_left;   
   reg          pos_left_is_zero; 
	reg          line_start_posl_zero;  
	reg          line_start_posl_nzero; 
   assign rd_hist = rnext || we_addr_d;
   assign        hist_do[31:0]={14'h0,hist_do0[17:0]};
 FDE  i_hist_bank (.C(pclk2x), .CE(init_hist & ~init_hist_d),  .D(~hist_bank), .Q(hist_bank)); 
 always @ (posedge pclk2x) begin
   frame_run_s[2:0] <= {frame_run_s[1:0],frame_run};
   line_run_s[2:0]  <= {line_run_s[1:0], line_run};
   line_start       <= line_run_s[1]  && !line_run_s[2];
   line_start_posl_zero  <= line_run_s[1]  && !line_run_s[2] && pos_left_is_zero;  
   line_start_posl_nzero <= line_run_s[1]  && !line_run_s[2] && !pos_left_is_zero;  
   line_end         <= line_run_s[2]  && !line_run_s[1];
   frame_start      <= frame_run_s[1] && !frame_run_s[2];
	bayer_en         <= frame_start || (bayer_en && !line_start);
	if (bayer_en) bayer_phase_latched[1:0] <=bayer_phase[1:0];
   if      (!frame_run_s[2]) hist_init_cntr[9:0] <= 10'b0;
   else if (init_hist)       hist_init_cntr[9:0] <= hist_init_cntr[9:0] + 1;
   end_hist_init <= (hist_init_cntr[9:1]==9'h1ff);
   init_hist <= frame_run_s[1] && (init_hist?(~end_hist_init):~frame_run_s[2]);
	init_hist_d <= init_hist;
   if (!init_hist) hist_init_cntr[9:0] <= 10'h0;
   else            hist_init_cntr[9:0] <=  hist_init_cntr[9:0] + 1;
   dvld2x[3:0] <= {dvld2x[2:0], ~(|dvld2x[2:0]) & di_vld };
   hist_seq[5:0] <= {hist_seq[4:0], window_on && (dvld2x[1] | dvld2x[3])};
   hist_ena <= hist_seq[0] || hist_seq[5] || init_hist; 
   hist_wea <= hist_seq[5] || init_hist; 
   if      (dvld2x[0]) di2x[15:8] <= di[15:8];
   if      (dvld2x[0]) di2x[ 7:0] <= di[ 7:0];
   else if (dvld2x[2]) di2x[ 7:0] <= di2x[15:8];
   if      (dvld2x[0])   bayer[0] <= 1'b0;
   else if (dvld2x[2])   bayer[0] <= ~bayer[0];
   if      (frame_start) bayer[1] <=  1'b0;
   else if (line_start)  bayer[1] <= ~bayer[1];
   if (hist_seq[1]) hist_waddr_hold1[9:0] <= hist_waddr[9:0];
   if (hist_seq[3]) hist_waddr_hold2[9:0] <= hist_waddr_hold1[9:0];
   if      (init_hist)   hist_waddr[9:0] <= hist_init_cntr[9:0]; 
   else if (hist_seq[0]) hist_waddr[9:0] <= {bayer[1:0]^bayer_phase_latched[1:0],di2x[7:0]};
   else if (hist_seq[5]) hist_waddr[9:0] <= {hist_waddr_hold2[9:0]};
   pre_same_addr <= (di2x[7:0] == hist_waddr_hold2[7:0]);
   same_waddr <= hist_seq[1] && 
                 hist_seq[5] && 
                 pre_same_addr;
   if (hist_seq[2]) hist_pre[17:0] <= same_waddr? hist_post[17:0] : hist_doa[17:0]; 
   if      (init_hist)                                  hist_post[17:0] <= 18'h0; 
   else if (hist_seq[4] && (hist_pre[17:0]!=18'h3ffff)) hist_post[17:0] <= hist_pre[17:0] + 1;	
   if      (frame_start) odd_line <= 1'b1;
   else if (line_end)    odd_line <= ~odd_line;
   minus_pos_left[13:1] <= -pos_left[13:1];   
   pos_left_is_zero     <= (pos_left[13:1]==13'h0); 
   if      (line_start) pix_cntr[13:1] <= minus_pos_left[13:1]; 
   else if (dvld2x[0])  pix_cntr[13:1] <= pix_cntr[13:1]+1; 
   if      (line_start_posl_nzero || !frame_run_s[2])                           line_started <= 1'h0;
   else if (line_start_posl_zero  || (dvld2x[2] &&((~pix_cntr[13:1])== 13'h0))) line_started <= 1'h1; 
   if      (line_start || !frame_run_s[2])                                    line_ended <= 1'h0;
   else if (dvld2x[2] && line_started && (pix_cntr[13:1] == size_width[13:1])) line_ended <= 1'h1;  
   if      (frame_start)            line_cntr[13:1] <= ~pos_top[13:1];
   else if (line_end && !odd_line)  line_cntr[13:1] <= line_cntr[13:1]+1;
   if      (!frame_run_s[2])                     frame_started <= 1'h0;
   else if ((~line_cntr[13:1])== 13'h0)          frame_started <= 1'h1;
   last_line <= (line_cntr[13:1] == size_height[13:1]);
   if      (!frame_run_s[2])                                                                    frame_ended <= 1'h0;
   else if ((line_start && frame_started && last_line) || (frame_run_s[2] && ! frame_run_s[1])) frame_ended <= 1'h1;
   window_on <= (line_start_posl_zero || (line_started && !line_ended)) && frame_started && !frame_ended;
 end
 always @ (negedge sclk) begin
   wdd[15:0] <= wd[15:0];
   we_pos[1:0]  <= {wen && (wa[2:0]==3'h1), wen && (wa[2:0]==3'h0)};
   we_size[1:0] <= {wen && (wa[2:0]==3'h3), wen && (wa[2:0]==3'h2)};
   we_addr      <=  wen && (wa[2:0]==3'h4);
   we_addr_d    <=  we_addr;
   if (we_pos[0])  pos_left[13:1]    <= wdd[13: 1];
   if (we_pos[1])  pos_top[13:1]     <= wdd[13: 1];
   if (we_size[0]) size_width[13:1]  <= wdd[13: 1];
   if (we_size[1]) size_height[13:1] <= wdd[13: 1];
   if      (we_addr)   hist_raddr[9:0] <= wdd[9:0];
   else if (rd_hist)   hist_raddr[9:0] <= hist_raddr[9:0] + 1;
 end
   RAMB16_S9_S9 i_hist_low (
      .DOA(hist_doa[7:0]),                     
      .DOPA(hist_doa[8]),                      
      .ADDRA({hist_bank,hist_waddr[9:0]}),     
      .CLKA( pclk2x),                            
      .DIA(hist_dia[7:0]),                     
      .DIPA(hist_dia[8]),                      
      .ENA(hist_ena),                          
      .SSRA(1'b0),                             
      .WEA(hist_wea),                          
      .DOB(hist_do0[7:0]),                      
      .DOPB(hist_do0[8]),                       
      .ADDRB({~hist_bank,hist_raddr[9:0]}),    
      .CLKB(!sclk),                            
      .DIB(8'h0),                              
      .DIPB(1'h0),                             
      .ENB(rd_hist),                           
      .SSRB(1'b0),                             
      .WEB(1'b0)                               
   );
   RAMB16_S9_S9 i_hist_high (
      .DOA(hist_doa[16:9]),                     
      .DOPA(hist_doa[17]),                     
      .ADDRA({hist_bank,hist_waddr[9:0]}),     
      .CLKA( pclk2x),                            
      .DIA(hist_dia[16:9]),                    
      .DIPA(hist_dia[17]),                     
      .ENA(hist_ena),                          
      .SSRA(1'b0),                             
      .WEA(hist_wea),                          
      .DOB(hist_do0[16:9]),                     
      .DOPB(hist_do0[17]),                      
      .ADDRB({~hist_bank,hist_raddr[9:0]}),    
      .CLKB(!sclk),                            
      .DIB(8'h0),                              
      .DIPB(1'h0),                             
      .ENB(rd_hist),                           
      .SSRB(1'b0),                             
      .WEB(1'b0)                               
   );
endmodule
