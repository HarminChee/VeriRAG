`define debug_compressor
`define debug_compressor
module stuffer		(clk,			
						  en,			
                    reset_data_counters, 
						  flush,		
						  stb,		
						  dl,			
						  d,			
                    color_first, 
                    sec,    
                    usec,    
						  rdy,		
						  q,			
						  qv,		
						  done,
                    imgptr, 
						  flushing
`ifdef debug_stuffer
                    ,etrax_dma_r, 
                    test_cntr,
                    test_cntr1
`endif
                    );
    input		 	clk;
    input		 	en;
    input         reset_data_counters; 
    input		 	flush;
    input		 	stb;
    input [ 3:0] 	dl;
    input [15:0] 	d;
    input         color_first; 
    input [31:0]  sec;  
    input [19:0]  usec;
    output		rdy;
    output [15:0] q;
    output			qv;
	 output			done;
    output [23:0] imgptr;
	 output			flushing;
`ifdef debug_stuffer
    output [3:0]  etrax_dma_r; 
    output [3:0]  test_cntr; 
    output [7:0]  test_cntr1; 
    reg    [3:0]  etrax_dma_r; 
    reg    [3:0]  test_cntr; 
    reg    [7:0]  test_cntr1; 
    reg           en_d;
`endif
	 wire				rdy;	
	 reg	[23:1]	stage1;	
	 wire	 [2:0]	shift1;	
	 reg	 [4:0]	stage1_bits;	
	 reg	 [4:0]	stage1_length;		
	 reg	 flushing;
	 wire	 flush_end;
	 reg stage1_full;
	 wire	[7:0]	byteMask;
	 wire [31:1]	longMask;	
	 wire	[31:1] dflt_stage2;
	 wire	[ 2:0]	sel;
	 wire	[ 1:0]	st2m;
	 wire	[31:1]	st2_d;
	 reg	[31:1]	stage2;
	 reg	[ 4:0]	stage2_bits;
	 wire	send8h, send8l, send8;
	 reg	[15:0]	q;
	 reg				qv;
    reg           flush_end_delayed;   
	 wire				pre_flush_end_delayed;	
	 wire				done;
	 reg	[23:0]	size_count; 
    reg           inc_size_count2316;
	 reg	[ 2:0]	size_out;
	 reg           size_out_over; 
	 reg				busy_eob;	
	 reg				trailer, was_trailer;		
	 reg [ 3:0]    etrax_dma;	
      reg           will_flush;   
	 wire          flush_now;
	 wire          start_sizeout; 
    reg	send8h_r, send8l_r;
    wire	      pre_stage2_bits_3;	
    wire	[4:3] willbe_stage1_bits;
    wire	[3:0]	sum_lengths;
	 reg	[1:0] st2m_r;
    reg  [2:0] stb_time;
    reg [31:0] sec_r;
    reg [19:0] usec_r;
    reg        time_out;
    reg        time_size_out;
    wire       start_time_out;
	 reg [23:0]	imgptr; 
	 reg [19:0] imgsz32; 
	 reg        inc_imgsz32;
	 always @ (negedge clk)  flushing <= en && !flush_end && ((flush && rdy) || flushing);
	 wire	[4:0]	pre_stage1_bits;
	 assign pre_stage1_bits[4:0]={2'b00,stage1_bits[2:0]} +  {(dl[3:0]==4'b0),dl[3:0]};
 	 always @ (negedge clk)	begin 
	 	if (!en || flush_end) stage1_bits[4:0] <= 5'b0;
		else if (stb && rdy) stage1_bits <= {(2'b10-pre_stage1_bits[4:3]),pre_stage1_bits[2:0]};
	 end
	 assign shift1[2:0]= stage1_bits[2:0] + dl[2:0];
	 always @ (negedge clk) if (stb && rdy)	begin
     case (shift1[2:0])
		0: stage1[23:1]	<= {     d[15:0],7'b0};
		1: stage1[23:1]	<= {1'b0,d[15:0],6'b0};
		2: stage1[23:1]	<= {2'b0,d[15:0],5'b0};
		3: stage1[23:1]	<= {3'b0,d[15:0],4'b0};
		4: stage1[23:1]	<= {4'b0,d[15:0],3'b0};
		5: stage1[23:1]	<= {5'b0,d[15:0],2'b0};
		6: stage1[23:1]	<= {6'b0,d[15:0],1'b0};
		7: stage1[23:1]	<= {7'b0,d[15:0]     };
     endcase
	 stage1_length[4:0]	<= {(dl[3:0]==4'b0),dl[3:0]};
	 end
	always @ (negedge clk) begin
		if (!en) stage2_bits	<= 5'b0;
		else if (send8) stage2_bits[4:0] <= stage2_bits[4:0] - 8;
		else if (flushing && !stage1_full && !stage2_bits[4] && (stage2_bits[3:0]!=4'b0)) stage2_bits[4:0]<=5'h10;	
		else		stage2_bits[4:0]	<= (rdy && stage1_full)? {1'b0,stage2_bits[3:0]}+stage1_length[4:0]:{1'b0,stage2_bits[3:0]};
	end
assign		sum_lengths=stage2_bits[3:0]+stage1_length[3:0];
assign pre_stage2_bits_3= en &&
                          (send8? (~stage2_bits[3]): (
								  !(flushing && !stage1_full && !stage2_bits[4] && (stage2_bits[3:0]!=4'b0)) && 
								  ((rdy && stage1_full)?sum_lengths[3]:	stage2_bits[3] )
								  ));
assign willbe_stage1_bits[4:3]={2{en && !flush_end}} & ((stb && rdy)?(2'b10-pre_stage1_bits[4:3]):stage1_bits[4:3]);
wire       pre_busy_eob=en && !flush_end_delayed && (busy_eob || (flush && rdy));
wire [4:3] pre_stage2_bits_4_interm1=stage2_bits[4:3]-2'h1;
wire [4:0] pre_stage2_bits_4_interm2={1'b0,stage2_bits[3:0]}+stage1_length[4:0];
wire       pre_stage2_bits_4=en && (send8?
                                     (pre_stage2_bits_4_interm1[4]):
                                     ((flushing && !stage1_full && !stage2_bits[4] && (stage2_bits[3:0]!=4'b0))?
                                       (1'b1):
                                       (((rdy && stage1_full))?
                                         (pre_stage2_bits_4_interm2[4]):
                                         (1'b0)
                                       )
                                     )
                              );
wire       pre_send8h_r= (( send8h_r  &&  stage2_bits[4])?
                           (&stage2[23:16]):
                           ((!send8l_r  || !stage2_bits[4])?
                             (&((longMask[31:24] & st2_d[31:24]) | (~longMask[31:24] & dflt_stage2[31:24]))):
                             (send8h_r)
                           )
                         );
wire       pre_send8l_r= ((( send8h_r || send8l_r) &&  stage2_bits[4] )?
                           (&stage2[15:8]):
                           (&((longMask[23:16] & st2_d[23:16]) | (~longMask[23:16] & dflt_stage2[23:16])))
                         );
 reg rdy_rega,rdy_regb, rdy_regc, rdy_regd;
   always @ (negedge clk) begin
	  rdy_rega <= !pre_stage2_bits_4;
	  rdy_regb <= !pre_send8h_r;
	  rdy_regc <= !pre_send8l_r;
	  rdy_regd <= !pre_busy_eob;
	  busy_eob <= pre_busy_eob;
	  send8h_r<=pre_send8h_r;
	  send8l_r<=pre_send8l_r;
   end
   assign rdy = (rdy_rega || (rdy_regb && rdy_regc)) && rdy_regd;
	assign send8h= send8h_r && stage2_bits[4];
	assign send8l= send8l_r && stage2_bits[4];
	assign send8=stage2_bits[4] && (send8h_r || send8l_r);
	always	@ (negedge clk) begin
	  if (!en) stage1_full <= 1'b0;
	  else if (flushing) stage1_full <= 1'b0; 
	  else if (rdy) stage1_full <=stb; 
	end
assign	sel[2:0]=stage2_bits[2:0];
assign	byteMask[7:0]=	{!sel[2] && !sel[1] && !sel[0],
								 !sel[2] && !sel[1],
								 !sel[2] && (!sel[1] || !sel[0]),
								 !sel[2],
								 !sel[2] || (!sel[1] && !sel[0]),
								 !sel[2] || !sel[1],
								 !sel[2] || !sel[1] || !sel[0],
								 1'b1
								 };
assign	longMask[31:1]={{8{(flushing || stage1_full) && !stage2_bits[3]}} & byteMask[7:0],
								 {8{flushing || stage1_full}} & ({8{!stage2_bits[3]}} | byteMask[7:0]),
								 {8{stage1_full}},
								 {7{stage1_full}}};
always @ (negedge clk) st2m_r[1:0]<=willbe_stage1_bits[4:3]-{1'b0,pre_stage2_bits_3};
assign	st2m[1:0]=st2m_r[1:0];
assign	st2_d[31:1]=	{{8{!flushing || stage1_full}} & (st2m[1]?{stage1[7:1],1'b0}:(st2m[0]? stage1[15:8]:     stage1[23:16])),
								 {8{!flushing || stage1_full}} & (st2m[1]? stage1[23:16]:    (st2m[0]?{stage1[7:1],1'b0}:stage1[15: 8])),
								 st2m[1]? stage1[15: 8]:    {stage1[7:1],1'b0},
								 {stage1[7:1]}};
assign	dflt_stage2=stage2_bits[4]?{stage2[15:1],16'b0}:{stage2[31:1]};
always @ (negedge clk) begin
	if		  (send8h) stage2[31:24] <= stage2[23:16];
	else if (send8l) stage2[31:24] <= 8'h00;
	else				  stage2[31:24] <= (longMask[31:24] & st2_d[31:24]) | (~longMask[31:24] & dflt_stage2[31:24]);
	if		  (send8)  stage2[23:16] <= stage2[15:8];
	else				  stage2[23:16] <= (longMask[23:16] & st2_d[23:16]) | (~longMask[23:16] & dflt_stage2[23:16]);
	if		  (send8)  stage2[15: 8] <= {stage2[7:1],1'b0};
	else				  stage2[15: 8] <= (longMask[15: 8] & st2_d[15: 8]) | (~longMask[15: 8] & dflt_stage2[15: 8]);
	if		  (send8)  stage2[7:  1] <= 7'b0;
	else				  stage2[7:  1] <= (longMask[7: 1] & st2_d[7: 1]) | (~longMask[7: 1] & dflt_stage2[7: 1]);
end
assign   flush_end= !stage2_bits[4] && flushing && !stage1_full && (stage2_bits[3:0]==4'b0);
assign flush_now= en && (!send8) && (flushing && !stage1_full && !stage2_bits[4]) && !will_flush;
always @ (negedge clk) begin
  stb_time[2:0] <= {stb_time[1] & ~stb_time[0], stb_time[0],color_first};
  if        (stb_time[2]) sec_r[31:0] <= sec[31:0];
  else if (start_sizeout) sec_r[31:0] <= {8'hff, size_count[23:0]};
  else if (time_size_out) sec_r[31:0] <= {usec_r[15:0],sec_r[31:16]};
  if   (stb_time[2]) usec_r[19:0] <= usec[19:0];
  else if (time_out) usec_r[19:0] <= {16'h0,usec_r[19:16]};
  if (reset_data_counters ) etrax_dma[3:0] <= 0; 
  else if (qv) etrax_dma[3:0] <= etrax_dma[3:0] + 1;
`ifdef debug_stuffer
  reg [3:0] tst_done_dly;
  en_d<= en;
  if (en) etrax_dma_r[3:0] <= etrax_dma[3:0];
  if    (done) test_cntr1[7:0] <= 0;
  else if (qv) test_cntr1[7:0] <= test_cntr1[7:0] +1 ; 
  tst_done_dly[3:0] <= {tst_done_dly[2:0],done};
  if (tst_done_dly[1]) test_cntr[3:0] <= 0;
  else if (qv)         test_cntr[3:0] <= test_cntr[3:0] +1 ;
`endif
  size_out_over <= en && (size_out_over?(!done):size_out[0]);
  size_out[2:0]<={size_out[1:0],start_sizeout};
  time_out <= en && (start_time_out || (time_out && !(etrax_dma[3:2]== 2'h3)));
  time_size_out <= en && (start_time_out || (time_size_out && !(etrax_dma[3:1]== 3'h7)));
  trailer <= en && (trailer?(!flush_end_delayed):(flush_end));
  was_trailer<=trailer; 
  will_flush <= en && (will_flush?(!qv):(flush_now && (stage2_bits[3:0]!=4'b0)));
  if (flush_now) size_count[0] <= stage2_bits[3] ^ (|stage2_bits[2:0]); 
  if (!en || size_out[2]) size_count[15:1] <= 0;
  else if (!trailer && !was_trailer && qv && (!will_flush || !size_count[0]))  size_count[15:1] <= size_count[15:1]+1;
  inc_size_count2316 <= (!trailer && !was_trailer && qv && (!will_flush || !size_count[0])) && (&size_count[15:1]);
  if      (!en || size_out[2]) size_count[23:16] <= 0;
  else if (inc_size_count2316) size_count[23:16] <= size_count[23:16]+1;
  qv <= en && (stage2_bits[4] || trailer);
  if      (time_size_out)  q[15:0] <= {sec_r[7:0],sec_r[15:8]};
  else                     q[15:0] <= {(stage2_bits[4]?stage2[31:24]:8'b0),
                                       ((stage2_bits[4] && !send8h)? stage2[23:16]:8'b0)};
  inc_imgsz32 <= (etrax_dma[3:0]== 4'h0) && qv;
  if (reset_data_counters || done) imgsz32[19:0] <= 0;
  else if (inc_imgsz32) imgsz32[19:0]<=imgsz32[19:0]+1;
  if (reset_data_counters) imgptr[23:0] <= 0;
  else if (done) imgptr[23:0] <= imgptr[23:0]+ imgsz32[19:0];
  flush_end_delayed <= en & pre_flush_end_delayed; 
end
assign start_time_out= qv && trailer && (etrax_dma[3:0]== 4'h8) && !size_out_over;
assign start_sizeout= time_out && (etrax_dma[3:0]== 4'hc);
SRL16_1 i_pre_flush_end_delayed (.D(size_out[1]),.Q(pre_flush_end_delayed), .A0(1'b0), .A1(1'b1), .A2(1'b1), .A3(1'b1), .CLK(clk)); 
assign 	done	= flush_end_delayed;
endmodule
