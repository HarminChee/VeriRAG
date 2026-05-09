 module onewiremaster (
   BIT_CTL, clk, clk_1us_en, clr_activate_intr, DQ_IN, EN_FOW, EOWL,
   EOWSH, epd, erbf, ersf, etbe, etmt, FOW, ias, LLM, MR, OD,
   owr, pd, PPM, rbf_reset, sr_a, STP_SPLY, STPEN, tbe, xmit_buffer,
   clear_interrupts, DQ_CONTROL, FSM_CLK, INTR,
   OneWireIO_eq_Load, OW_LOW, OW_SHORT, pdr, rbf, rcvr_buffer, reset_owr,
   rsrf, STPZ, temt);
   input       BIT_CTL;         
   input 	   clk;				
   input       clk_1us_en;         
   input       clr_activate_intr;
   input       DQ_IN;           
   input       EN_FOW;          
   input       EOWL;            
   input       EOWSH;           
   input       epd;             
   input       erbf;            
   input       ersf;            
   input       etbe;            
   input       etmt;            
   input       FOW;             
   input       ias;             
   input       LLM;             
   input       MR;              
   input       OD;              
   input       owr;             
   input       pd;              
   input       PPM;             
   input       rbf_reset;       
   input       sr_a;            
   input       STP_SPLY;        
   input       STPEN;           
   input       tbe;             
   input [7:0] xmit_buffer;     
   output       clear_interrupts;
   output       DQ_CONTROL;     
   output       FSM_CLK;        
   output       INTR;           
   output       OneWireIO_eq_Load;
   output       OW_LOW;         
   output       OW_SHORT;       
   output       pdr;            
   output       rbf;            
   output [7:0] rcvr_buffer;    
   output       reset_owr;      
   output       rsrf;           
   output       STPZ;           
   output       temt;           
   parameter [2:0] Idle       = 3'b000,  
                   CheckOWR   = 3'b001,  
                   Reset_Low  = 3'b010,  
                   PD_Wait    = 3'b011,  
                   PD_Sample  = 3'b100,  
                   Reset_High = 3'b101,  
                   PD_Force   = 3'b110,  
                   PD_Release = 3'b111;  
  parameter [4:0] IdleS=      5'b00000, 
                  Load=       5'b00001, 
                  CheckOW=    5'b00010, 
                  DQLOW=      5'b00011, 
                  WriteZero=  5'b00100, 
                  WriteOne=   5'b00101, 
                  ReadBit=    5'b00110, 
                  FirstPassSR=5'b00111, 
                  WriteBitSR= 5'b01000, 
                  WriteBit=   5'b01001, 
                  WaitTS=     5'b01010, 
                  IndexInc=   5'b01011, 
                  UpdateBuff= 5'b01100, 
                  ODWriteZero=5'b01101, 
                  ODWriteOne= 5'b01110, 
                  ClrLowDone= 5'b01111; 
   parameter [6:0]                      
      bit_ts_writeone_high    = 7'b0000110, 
      bit_ts_writeone_high_ll = 7'b0001000, 
      bit_ts_sample           = 7'b0001111, 
      bit_ts_sample_ll        = 7'b0011000, 
      bit_ts_writezero_high   = 7'b0111100, 
      bit_ts_end              = 7'b1000110, 
      bit_ts_end_ll           = 7'b1010000, 
      bit_ts_writeone_high_od  = 7'b0000001, 
      bit_ts_sample_od         = 7'b0000010, 
      bit_ts_writezero_high_od = 7'b0001000, 
      bit_ts_end_od            = 7'b0001001; 
   parameter [10:0]                     
      reset_ts_release = 11'b01001011000,    
      reset_ts_no_stpz = 11'b01001100010,    
      reset_ts_ppm     = 11'b01001101100,    
      reset_ts_sample  = 11'b01010011110,    
      reset_ts_llsample= 11'b01010101101,    
      reset_ts_ppm_end = 11'b01010110010,    
      reset_ts_stpz    = 11'b01110110110,    
      reset_ts_recover = 11'b01111000000,    
      reset_ts_end     = 11'b10000111000,    
      reset_ts_release_od = 11'b00001000110, 
      reset_ts_no_stpz_od = 11'b00001001011, 
      reset_ts_sample_od  = 11'b00001001111, 
      reset_ts_stpz_od    = 11'b00001101001, 
      reset_ts_recover_od = 11'b00001110011, 
      reset_ts_end_od     = 11'b00010000000; 
   wire            owr;         
   wire            sr_a;        
   wire            pd;          
   reg             pdr;         
   wire            tbe;         
   reg             temt;        
   wire            temt_ext;    
   reg             rbf;         
   reg             rsrf;        
   reg             OW_SHORT;    
   reg             OW_LOW;      
   reg             INTR;
   reg             set_rbf;     
   wire            epd;         
   wire            ias;         
   wire            etbe;        
   wire            etmt;        
   wire            erbf;        
   wire            ersf;        
   wire            EOWSH;       
   wire            EOWL;        
   wire            clr_activate_intr;
   reg             reset_owr;
   reg             activate_intr;
   reg             dly_clr_activate_intr;
   reg             clear_interrupts;
   reg             SET_RSHRT;      
   reg             SET_IOSHRT;     
   wire [7:0]      xmit_buffer;    
   reg [7:0]       xmit_shiftreg;  
   reg [7:0]       rcvr_buffer;    
   reg [7:0]       rcvr_shiftreg;  
   reg             last_rcvr_bit;  
   reg             byte_done;
   reg             byte_done_flag, bdext1;  
   reg             First;          
   reg             BitRead1;
   reg             BitRead2;
   reg             BitWrite;
   reg [2:0]       OneWireReset;
   reg [4:0]       OneWireIO;
   reg [10:0]      count;
   reg [3:0]       index;
   reg [6:0]       TimeSlotCnt;
   reg             PD_READ;
   reg             LOW_DONE;
   reg             DQ_CONTROL_F;
   wire            DQ_CONTROL;
   wire            STPZ;
   reg             DQ_IN_HIGH;
   reg             OD_DQH;
	reg             rbf_set;
	reg             rsrf_reset;
   reg             ROW;
   wire FSM_CLK = clk;
   assign DQ_CONTROL = MR ? 1'b1 : DQ_CONTROL_F;  
   always @(posedge clk)                      
	begin
		if(clk_1us_en)
		begin
		  DQ_CONTROL_F <=
					   (EN_FOW == 1) && (FOW == 1)?0:
					   OneWireReset == Reset_Low?0:
					   OneWireReset == PD_Wait?1:
					   OneWireReset == PD_Force?0:
					   OneWireIO == DQLOW?0:
					   OneWireIO == WriteZero?0:
					   OneWireIO == ODWriteZero?0:
					   OneWireIO == WriteBit?0:
					   1;
		end
	end
   wire OneWireIO_eq_Load = OneWireIO == Load;
   wire   SPLY = (STP_SPLY && (OneWireReset == Idle) && (OneWireIO == IdleS));
   assign STPZ = !(STPEN && DQ_CONTROL && DQ_IN_HIGH
                   && (PD_READ || LOW_DONE || SPLY));
   always @(posedge MR or posedge FSM_CLK)
	begin
     if (MR)
       begin
         DQ_IN_HIGH <= 0;
         OD_DQH <=0;
       end
		else if(clk_1us_en)
		begin
		 if (OD)
		   if(DQ_IN && !DQ_IN_HIGH && !OD_DQH)
			 begin
			   DQ_IN_HIGH <= 1;
			   OD_DQH <=1;
			 end
		   else if(OD_DQH && DQ_IN)
			 DQ_IN_HIGH <= 0;
		   else
			 begin
			   OD_DQH <=0;
			   DQ_IN_HIGH <= 0;
			 end
		 else
		   begin
			 if(DQ_IN && !DQ_IN_HIGH)
			   DQ_IN_HIGH <= 1;
			 else if (DQ_IN && DQ_IN_HIGH)
			   DQ_IN_HIGH <= DQ_IN_HIGH;
			 else
			   DQ_IN_HIGH <= 0;
		   end
	  end
    end
	always @(posedge MR or posedge rbf_reset or posedge rbf_set)
     if (MR)
      rbf <= 0;
     else if (rbf_reset)  
      rbf <= 0;
     else
      rbf <= 1;
   always @(posedge MR or posedge FSM_CLK)
     if (MR)
       rsrf <= 1'b0;
	else if(clk_1us_en)
	begin
		 if (last_rcvr_bit || BIT_CTL)
		   begin
			 if (OneWireIO == IndexInc)
			   rsrf <= 1'b1;
			 else if (rsrf_reset)
			   rsrf <= 1'b0;
		   end
		 else if (rsrf_reset || (OneWireIO == DQLOW))
		   rsrf <= 1'b0;
	end
   always @(posedge FSM_CLK or posedge MR)
     if (MR)
       begin
         rcvr_buffer <= 0;
         rbf_set <= 0;
       end
     else if(clk_1us_en)
       if (rsrf && !rbf)
         begin
           rcvr_buffer <= rcvr_shiftreg;
           rbf_set <= 1'b1;
           rsrf_reset <= 1'b1;
         end
       else
         begin
           rbf_set <= 1'b0;
           if (!rsrf)
             rsrf_reset <= 1'b0;
         end
   always @(posedge MR or posedge FSM_CLK)
     begin
       if(MR)
         OW_SHORT <= 1'b0;
	   else if(clk_1us_en)
	   begin
		   if (SET_RSHRT || SET_IOSHRT)
			 OW_SHORT <= 1'b1;
		   else if (clr_activate_intr)
			 OW_SHORT <= 1'b0;
		   else
			 OW_SHORT <= OW_SHORT;
		 end
	  end
   always @(posedge MR or posedge FSM_CLK)
     begin
       if (MR)
         OW_LOW <= 0;
	   else if(clk_1us_en)
	   begin
		   if (!DQ_IN && (OneWireReset == Idle) && (OneWireIO == IdleS))
			 OW_LOW <= 1;
		   else if (clr_activate_intr)
			 OW_LOW <= 0;
		   else
			 OW_LOW <= OW_LOW;
	   end
     end
   always @(posedge MR or posedge FSM_CLK)
      if (MR)
         begin
            clear_interrupts <= 1'b0;
         end 
      else if(clk_1us_en)
         begin
            clear_interrupts<=clr_activate_intr;
         end
   wire acint_reset = MR || clr_activate_intr;
   always @(posedge acint_reset or posedge FSM_CLK)
     if(acint_reset)
        activate_intr <= 1'b0;
      else if(clk_1us_en)
        case(1)
          pd && epd:
             activate_intr <= 1'b1;
          tbe && etbe && !temt:
             activate_intr <= 1'b1;
          temt_ext && etmt:
             activate_intr <= 1'b1;
          rbf && erbf:
             activate_intr <= 1'b1;
          rsrf && ersf:
             activate_intr <= 1'b1;
          OW_LOW && EOWL:
             activate_intr <= 1'b1;
          OW_SHORT && EOWSH:
             activate_intr <= 1'b1;
        endcase 
   always @(activate_intr or ias)
      case({activate_intr,ias})
        2'b11:
           INTR <= 1'b1;
        2'b01:
           INTR <= 1'b0;
        2'b10:
           INTR <= 1'b1; 
        default:
           INTR <= 1'b0; 
      endcase 
   always @(posedge FSM_CLK or posedge MR)
      if(MR) begin
         pdr <= 1'b1;        
         OneWireReset <= Idle;
         count <= 0;
         PD_READ <= 0;       
         reset_owr <= 0;
         SET_RSHRT <= 0;     
			ROW <= 0;
      end
      else if(clk_1us_en)
      begin
       if(!owr)
       begin
         count <= 0;
			ROW <= 0;
         reset_owr <= 0;
         OneWireReset <= Idle;
       end
           else
              case(OneWireReset)
                Idle: begin
                   if (ROW)
			              reset_owr <= 1;
			          else
						   begin
							  count <= 0;
                       SET_RSHRT <=0;
                       reset_owr <= 0;
                       OneWireReset <= CheckOWR;
                     end
					  end
                CheckOWR: begin
                   OneWireReset <= Reset_Low;
                   if(!DQ_IN)
                     SET_RSHRT <= 1;
                   end
                Reset_Low: begin
                   count <= count + 1;
                   PD_READ <= 0;                
                   if(OD)                       
                     begin
                       if(count == reset_ts_release_od)
                         begin
                           OneWireReset <= PD_Wait;
                           PD_READ <= 1;
                         end
                     end
                   else if(count == reset_ts_release)
                     begin
                       OneWireReset <= PD_Wait;
                       PD_READ <= 1;
                     end
                end
                PD_Wait: begin
                   SET_RSHRT <= 0;
                   count <= count + 1;
                   if(!DQ_IN & DQ_CONTROL_F) begin
                      OneWireReset <= PD_Sample;
                   end
                   else if(OD)
                     begin
                       if(count==reset_ts_no_stpz_od)
                         PD_READ <= 0;       
                       else if(count == reset_ts_sample_od)
                         begin
                           OneWireReset <= PD_Sample;
                         end
                     end
                   else if(count == reset_ts_no_stpz)
                     PD_READ <= 0; 
                   else if((count == reset_ts_ppm) && PPM)
                     OneWireReset <= PD_Force;
                   else if(count == reset_ts_llsample && !LLM)
                     begin
                       OneWireReset <= PD_Sample;
                     end
                   else if(count == reset_ts_sample && LLM)
                     begin
                       OneWireReset <= PD_Sample;
                     end
                end
                PD_Sample: begin
                   PD_READ <= 0;
                   count <= count + 1;
                           pdr <= DQ_IN;
                           OneWireReset <= Reset_High;
                end
                Reset_High: begin
                   count <= count + 1;
                   if (OD)                      
                     begin
                       if (count == reset_ts_stpz_od)
                         begin
                           if (DQ_IN)
                              PD_READ <= 1;
                         end
                       else if (count == reset_ts_recover_od)
                         begin
                           PD_READ <= 0;
                         end
                       else if (count == reset_ts_end_od)
                         begin
                           PD_READ <= 0;
                           OneWireReset <= Idle;
                           ROW <= 1;
                         end
                     end
                   else
                     begin
                       if(count == reset_ts_stpz)
                         begin
                           if (DQ_IN)
                             PD_READ <= 1;
                         end
                       else if (count == reset_ts_recover)
                         begin
                           PD_READ <= 0;
                         end
                       else if (count == reset_ts_end)
                         begin
                           PD_READ <= 0;
                           OneWireReset <= Idle;
                           ROW <= 1;
                         end
                     end
                end
                PD_Force:  begin
                  count <= count + 1;
                  if (count == reset_ts_ppm_end)
                    begin
                      OneWireReset <= PD_Release;
                    end
                end
                PD_Release: begin
                  count <= count + 1;
                  pdr <= 0;              
                  if(count == reset_ts_stpz)
                    begin
                      if (DQ_IN)
                        PD_READ <= 1;
                    end
                  else if (count == reset_ts_recover)
                    begin
                      PD_READ <= 0;
                    end
                  else if (count == reset_ts_end)
                    begin
                      PD_READ <= 0;
                      OneWireReset <= Idle;
                      ROW <= 1;
                    end
                end
              endcase
	end
   always @(posedge MR or posedge FSM_CLK)
      if(MR)
         bdext1 <= 1'b0;
      else if(clk_1us_en)
         bdext1 <= byte_done;
   always @(posedge MR or posedge FSM_CLK)
      if(MR)
         byte_done_flag <= 1'b0;
      else if(clk_1us_en)
         byte_done_flag <= bdext1;
   assign temt_ext = temt && byte_done_flag;
   always @(posedge FSM_CLK or posedge MR)
      if(MR) begin
         index <= 0;
         TimeSlotCnt <= 0;
         temt <= 1'b1;
         last_rcvr_bit <= 1'b0;
         rcvr_shiftreg <= 0;
         OneWireIO <= IdleS;
         BitRead1<=0;
         BitRead2<=0;
         BitWrite<=0;
         First <= 1'b0;
         byte_done <= 1'b0;
         xmit_shiftreg<=0;
         LOW_DONE <= 0;
         SET_IOSHRT <= 0;
      end
      else if(clk_1us_en)
         case(OneWireIO)
           IdleS:
              begin
                 byte_done <= 1'b0;
                 index <= 0;
                 last_rcvr_bit <= 1'b0;
                 First <= 1'b0;
                 TimeSlotCnt <= 0;
                 LOW_DONE <= 0;
                 SET_IOSHRT <= 0;
                 temt <= 1'b1;
                 if(!tbe)
                   begin
                     if(STPEN)
                       OneWireIO <= ClrLowDone;
                     else
                       OneWireIO <= Load;
                   end
                 else
                    OneWireIO <= IdleS;
              end
           ClrLowDone:
              begin
                 LOW_DONE <= 0;
                 if (!LOW_DONE)
                   OneWireIO <= Load;
              end
           Load:
              begin
                 xmit_shiftreg <= xmit_buffer;
                 rcvr_shiftreg <= 0;
                 temt <= 1'b0;
                 LOW_DONE <= 0;
                 OneWireIO <= CheckOW;
              end
           CheckOW:
             begin
               OneWireIO <= DQLOW;
               if (!DQ_IN)
                 SET_IOSHRT <= 1;
             end
           DQLOW:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              LOW_DONE <= 0;
              if (OD)
               begin
                   if(!sr_a)
                     begin
                       case(index)
                         0:
                            if(!xmit_shiftreg[0])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         1:
                            if(!xmit_shiftreg[1])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         2:
                            if(!xmit_shiftreg[2])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         3:
                            if(!xmit_shiftreg[3])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         4:
                            if(!xmit_shiftreg[4])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         5:
                            if(!xmit_shiftreg[5])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         6:
                            if(!xmit_shiftreg[6])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         7:
                            if(!xmit_shiftreg[7])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                       endcase 
                     end
                   else         
                     OneWireIO <= ReadBit;
                  end
              else if(((TimeSlotCnt==bit_ts_writeone_high) && !LLM) || 
                      ((TimeSlotCnt==bit_ts_writeone_high_ll) && LLM))
              begin
                 if(!sr_a)                  
                   begin
                      case(index)
                        0:
                           if(!xmit_shiftreg[0])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        1:
                           if(!xmit_shiftreg[1])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        2:
                           if(!xmit_shiftreg[2])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        3:
                           if(!xmit_shiftreg[3])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        4:
                           if(!xmit_shiftreg[4])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        5:
                           if(!xmit_shiftreg[5])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        6:
                           if(!xmit_shiftreg[6])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        7:
                           if(!xmit_shiftreg[7])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                      endcase 
                  end
                  else         
                     OneWireIO <= ReadBit;
                  end
               end
           WriteZero:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              if(((TimeSlotCnt==bit_ts_sample) && !sr_a && !LLM) ||
                 ((TimeSlotCnt==bit_ts_sample_ll) && !sr_a &&  LLM))
                 case(index)
                   0:
                      rcvr_shiftreg[0] <= DQ_IN;
                   1:
                      rcvr_shiftreg[1] <= DQ_IN;
                   2:
                      rcvr_shiftreg[2] <= DQ_IN;
                   3:
                      rcvr_shiftreg[3] <= DQ_IN;
                   4:
                      rcvr_shiftreg[4] <= DQ_IN;
                   5:
                      rcvr_shiftreg[5] <= DQ_IN;
                   6:
                      rcvr_shiftreg[6] <= DQ_IN;
                   7:
                      rcvr_shiftreg[7] <= DQ_IN;
                 endcase
              if(TimeSlotCnt == bit_ts_writezero_high)            
                 OneWireIO <= WaitTS;
              if(DQ_IN)
                 LOW_DONE <= 1;
             end
           WriteOne:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              if(((TimeSlotCnt==bit_ts_sample) && !sr_a && !LLM) ||
                 ((TimeSlotCnt==bit_ts_sample_ll) && !sr_a &&  LLM))
                 case(index)
                   0:
                      rcvr_shiftreg[0] <= DQ_IN;
                   1:
                      rcvr_shiftreg[1] <= DQ_IN;
                   2:
                      rcvr_shiftreg[2] <= DQ_IN;
                   3:
                      rcvr_shiftreg[3] <= DQ_IN;
                   4:
                      rcvr_shiftreg[4] <= DQ_IN;
                   5:
                      rcvr_shiftreg[5] <= DQ_IN;
                   6:
                      rcvr_shiftreg[6] <= DQ_IN;
                   7:
                      rcvr_shiftreg[7] <= DQ_IN;
                 endcase
              if(TimeSlotCnt == bit_ts_writezero_high)             
                 OneWireIO <= WaitTS;
              if(DQ_IN)
                 LOW_DONE <= 1;
             end
           ODWriteZero:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              if((TimeSlotCnt == bit_ts_sample_od) && !sr_a)
                 case(index)
                   0:
                      rcvr_shiftreg[0] <= DQ_IN;
                   1:
                      rcvr_shiftreg[1] <= DQ_IN;
                   2:
                      rcvr_shiftreg[2] <= DQ_IN;
                   3:
                      rcvr_shiftreg[3] <= DQ_IN;
                   4:
                      rcvr_shiftreg[4] <= DQ_IN;
                   5:
                      rcvr_shiftreg[5] <= DQ_IN;
                   6:
                      rcvr_shiftreg[6] <= DQ_IN;
                   7:
                      rcvr_shiftreg[7] <= DQ_IN;
                 endcase
              if(TimeSlotCnt == bit_ts_writezero_high_od)
                 OneWireIO <= WaitTS;
              if(DQ_IN)
                 LOW_DONE <= 1;
             end
           ODWriteOne:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              if((TimeSlotCnt == bit_ts_sample_od) && !sr_a)
                 case(index)
                   0:
                      rcvr_shiftreg[0] <= DQ_IN;
                   1:
                      rcvr_shiftreg[1] <= DQ_IN;
                   2:
                      rcvr_shiftreg[2] <= DQ_IN;
                   3:
                      rcvr_shiftreg[3] <= DQ_IN;
                   4:
                      rcvr_shiftreg[4] <= DQ_IN;
                   5:
                      rcvr_shiftreg[5] <= DQ_IN;
                   6:
                      rcvr_shiftreg[6] <= DQ_IN;
                   7:
                      rcvr_shiftreg[7] <= DQ_IN;
                 endcase
              if(TimeSlotCnt == bit_ts_writezero_high_od)
                OneWireIO <= WaitTS;
              if(DQ_IN)
                 LOW_DONE <= 1;
             end
           ReadBit:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              if(DQ_IN)
                LOW_DONE <= 1;
              if(OD)
                begin
                  if(TimeSlotCnt == bit_ts_sample_od)
                    if(!First)
                      BitRead1 <= DQ_IN;
                    else
                      BitRead2 <= DQ_IN;
                  if(TimeSlotCnt == bit_ts_writezero_high_od)     
                    OneWireIO <= FirstPassSR;
                end
              else
                begin
                  if(((TimeSlotCnt == bit_ts_sample)&&!LLM) || ((TimeSlotCnt == bit_ts_sample_ll)&&LLM))
                    if(!First)
                      BitRead1 <= DQ_IN;
                    else
                      BitRead2 <= DQ_IN;
                  if(TimeSlotCnt == bit_ts_writezero_high)
                    OneWireIO <= FirstPassSR;
                end
             end
           FirstPassSR:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              LOW_DONE <= 0;
              if(OD)
                begin
                  if(TimeSlotCnt == bit_ts_end_od)
                    begin
                      TimeSlotCnt <= 0;
                      if(!First)
                        begin
                          First <= 1'b1;
                          OneWireIO <= DQLOW;
                        end
                      else
                        begin
                          OneWireIO <= WriteBitSR;
                        end
                    end
                end
              else
                begin
                  if(((TimeSlotCnt==bit_ts_end) && !LLM) || ((TimeSlotCnt==bit_ts_end_ll) && LLM))
                    begin
                      TimeSlotCnt <= 0;
                      if(!First)
                        begin
                          First <= 1'b1;
                          OneWireIO <= DQLOW;
                        end
                      else
                        begin
                          OneWireIO <= WriteBitSR;
                        end 
                    end
                end
             end
           WriteBitSR:
             begin
               case({BitRead1,BitRead2})
                 2'b00: begin
                    case(index)
                      0: begin
                         BitWrite <= xmit_shiftreg[1];
                         rcvr_shiftreg[0] <= 1'b1;
                      end
                      1: begin
                         BitWrite <= xmit_shiftreg[2];
                         rcvr_shiftreg[1] <= 1'b1;
                      end
                      2: begin
                         BitWrite <= xmit_shiftreg[3];
                         rcvr_shiftreg[2] <= 1'b1;
                      end
                      3: begin
                         BitWrite <= xmit_shiftreg[4];
                         rcvr_shiftreg[3] <= 1'b1;
                      end
                      4: begin
                         BitWrite <= xmit_shiftreg[5];
                         rcvr_shiftreg[4] <= 1'b1;
                      end
                      5: begin
                         BitWrite <= xmit_shiftreg[6];
                         rcvr_shiftreg[5] <= 1'b1;
                      end
                      6: begin
                         BitWrite <= xmit_shiftreg[7];
                         rcvr_shiftreg[6] <= 1'b1;
                      end
                      7: begin
                         BitWrite <= xmit_shiftreg[0];
                         rcvr_shiftreg[7] <= 1'b1;
                      end
                    endcase
                 end
                 2'b01: begin
                    BitWrite <= 1'b0;
                    case(index)
                      0:
                         rcvr_shiftreg[0] <= 1'b0;
                      1:
                         rcvr_shiftreg[1] <= 1'b0;
                      2:
                         rcvr_shiftreg[2] <= 1'b0;
                      3:
                         rcvr_shiftreg[3] <= 1'b0;
                      4:
                         rcvr_shiftreg[4] <= 1'b0;
                      5:
                         rcvr_shiftreg[5] <= 1'b0;
                      6:
                         rcvr_shiftreg[6] <= 1'b0;
                      7:
                         rcvr_shiftreg[7] <= 1'b0;
                    endcase
                 end
                 2'b10: begin
                    BitWrite <= 1'b1;
                    case(index)
                      0:
                         rcvr_shiftreg[0] <= 1'b0;
                      1:
                         rcvr_shiftreg[1] <= 1'b0;
                      2:
                         rcvr_shiftreg[2] <= 1'b0;
                      3:
                         rcvr_shiftreg[3] <= 1'b0;
                      4:
                         rcvr_shiftreg[4] <= 1'b0;
                      5:
                         rcvr_shiftreg[5] <= 1'b0;
                      6:
                         rcvr_shiftreg[6] <= 1'b0;
                      7:
                         rcvr_shiftreg[7] <= 1'b0;
                    endcase
                 end
                 2'b11: begin
                    BitWrite <= 1'b1;
                    case(index)
                      0: begin
                         rcvr_shiftreg[0] <= 1'b1;
                         rcvr_shiftreg[1] <= 1'b1;
                      end
                      1: begin
                         rcvr_shiftreg[1] <= 1'b1;
                         rcvr_shiftreg[2] <= 1'b1;
                      end
                      2: begin
                         rcvr_shiftreg[2] <= 1'b1;
                         rcvr_shiftreg[3] <= 1'b1;
                      end
                      3: begin
                         rcvr_shiftreg[3] <= 1'b1;
                         rcvr_shiftreg[4] <= 1'b1;
                      end
                      4: begin
                         rcvr_shiftreg[4] <= 1'b1;
                         rcvr_shiftreg[5] <= 1'b1;
                      end
                      5: begin
                         rcvr_shiftreg[5] <= 1'b1;
                         rcvr_shiftreg[6] <= 1'b1;
                      end
                      6: begin
                         rcvr_shiftreg[6] <= 1'b1;
                         rcvr_shiftreg[7] <= 1'b1;
                      end
                      7: begin
                         rcvr_shiftreg[7] <= 1'b1;
                         rcvr_shiftreg[0] <= 1'b1;
                      end
                    endcase
                 end
               endcase 
               OneWireIO <= WriteBit;
              end
           WriteBit:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              case(index)
                0:
                   rcvr_shiftreg[1] <= BitWrite;
                1:
                   rcvr_shiftreg[2] <= BitWrite;
                2:
                   rcvr_shiftreg[3] <= BitWrite;
                3:
                   rcvr_shiftreg[4] <= BitWrite;
                4:
                   rcvr_shiftreg[5] <= BitWrite;
                5:
                   rcvr_shiftreg[6] <= BitWrite;
                6:
                   rcvr_shiftreg[7] <= BitWrite;
                7:
                   rcvr_shiftreg[0] <= BitWrite;
              endcase
              if(!BitWrite)
                begin
                  if(OD)
                    OneWireIO <= ODWriteZero;
                  else
                    OneWireIO <= WriteZero;
                end
              else
                begin
                  if(OD && (TimeSlotCnt == bit_ts_writeone_high_od))
                    OneWireIO <= ODWriteOne;
                  else if (!LLM && (TimeSlotCnt == bit_ts_writeone_high))  
                    OneWireIO <= WriteOne;
                  else if (LLM && (TimeSlotCnt == bit_ts_writeone_high_ll))
                    OneWireIO <= WriteOne;
                end
             end
           WaitTS:
             begin
              SET_IOSHRT <= 0;
              TimeSlotCnt <= TimeSlotCnt + 1;
              if(OD)
                begin
                  if(TimeSlotCnt == bit_ts_end_od)  
                    OneWireIO <= IndexInc;
                end
              else
                if(((TimeSlotCnt == bit_ts_end) && !LLM) || ((TimeSlotCnt==bit_ts_end_ll) && LLM))
                  OneWireIO <= IndexInc;
              if(DQ_IN)
                 LOW_DONE <= 1;
             end
           IndexInc:
             begin
              if(!sr_a)
                 index <= index + 1;
              else
                 begin
                    index <= index + 2;
                    First <= 1'b0;
                 end
              if(BIT_CTL || (index == 8-1 && !sr_a) || (index == 8-2 && sr_a)  )
                 begin                             
                    byte_done <= 1'b1;
                    OneWireIO <= UpdateBuff;
                 end
              else
                 begin
                    if((index == 7-1) && !sr_a)
                       last_rcvr_bit <= 1'b1;
                    else
                       if((index == 6-2) && sr_a)
                          last_rcvr_bit <= 1'b1;
                    OneWireIO <= DQLOW;
                    TimeSlotCnt <= 0;
                 end
                 LOW_DONE <= 0;
             end
           UpdateBuff:
             begin
                OneWireIO <= IdleS;
                if(DQ_IN && STP_SPLY)
                  LOW_DONE <= 1;
             end
         endcase
endmodule
 module onewiremaster (
   BIT_CTL, clk, clk_1us_en, clr_activate_intr, DQ_IN, EN_FOW, EOWL,
   EOWSH, epd, erbf, ersf, etbe, etmt, FOW, ias, LLM, MR, OD,
   owr, pd, PPM, rbf_reset, sr_a, STP_SPLY, STPEN, tbe, xmit_buffer,
   clear_interrupts, DQ_CONTROL, FSM_CLK, INTR,
   OneWireIO_eq_Load, OW_LOW, OW_SHORT, pdr, rbf, rcvr_buffer, reset_owr,
   rsrf, STPZ, temt);
   input       BIT_CTL;         
   input 	   clk;				
   input       clk_1us_en;         
   input       clr_activate_intr;
   input       DQ_IN;           
   input       EN_FOW;          
   input       EOWL;            
   input       EOWSH;           
   input       epd;             
   input       erbf;            
   input       ersf;            
   input       etbe;            
   input       etmt;            
   input       FOW;             
   input       ias;             
   input       LLM;             
   input       MR;              
   input       OD;              
   input       owr;             
   input       pd;              
   input       PPM;             
   input       rbf_reset;       
   input       sr_a;            
   input       STP_SPLY;        
   input       STPEN;           
   input       tbe;             
   input [7:0] xmit_buffer;     
   output       clear_interrupts;
   output       DQ_CONTROL;     
   output       FSM_CLK;        
   output       INTR;           
   output       OneWireIO_eq_Load;
   output       OW_LOW;         
   output       OW_SHORT;       
   output       pdr;            
   output       rbf;            
   output [7:0] rcvr_buffer;    
   output       reset_owr;      
   output       rsrf;           
   output       STPZ;           
   output       temt;           
   parameter [2:0] Idle       = 3'b000,  
                   CheckOWR   = 3'b001,  
                   Reset_Low  = 3'b010,  
                   PD_Wait    = 3'b011,  
                   PD_Sample  = 3'b100,  
                   Reset_High = 3'b101,  
                   PD_Force   = 3'b110,  
                   PD_Release = 3'b111;  
  parameter [4:0] IdleS=      5'b00000, 
                  Load=       5'b00001, 
                  CheckOW=    5'b00010, 
                  DQLOW=      5'b00011, 
                  WriteZero=  5'b00100, 
                  WriteOne=   5'b00101, 
                  ReadBit=    5'b00110, 
                  FirstPassSR=5'b00111, 
                  WriteBitSR= 5'b01000, 
                  WriteBit=   5'b01001, 
                  WaitTS=     5'b01010, 
                  IndexInc=   5'b01011, 
                  UpdateBuff= 5'b01100, 
                  ODWriteZero=5'b01101, 
                  ODWriteOne= 5'b01110, 
                  ClrLowDone= 5'b01111; 
   parameter [6:0]                      
      bit_ts_writeone_high    = 7'b0000110, 
      bit_ts_writeone_high_ll = 7'b0001000, 
      bit_ts_sample           = 7'b0001111, 
      bit_ts_sample_ll        = 7'b0011000, 
      bit_ts_writezero_high   = 7'b0111100, 
      bit_ts_end              = 7'b1000110, 
      bit_ts_end_ll           = 7'b1010000, 
      bit_ts_writeone_high_od  = 7'b0000001, 
      bit_ts_sample_od         = 7'b0000010, 
      bit_ts_writezero_high_od = 7'b0001000, 
      bit_ts_end_od            = 7'b0001001; 
   parameter [10:0]                     
      reset_ts_release = 11'b01001011000,    
      reset_ts_no_stpz = 11'b01001100010,    
      reset_ts_ppm     = 11'b01001101100,    
      reset_ts_sample  = 11'b01010011110,    
      reset_ts_llsample= 11'b01010101101,    
      reset_ts_ppm_end = 11'b01010110010,    
      reset_ts_stpz    = 11'b01110110110,    
      reset_ts_recover = 11'b01111000000,    
      reset_ts_end     = 11'b10000111000,    
      reset_ts_release_od = 11'b00001000110, 
      reset_ts_no_stpz_od = 11'b00001001011, 
      reset_ts_sample_od  = 11'b00001001111, 
      reset_ts_stpz_od    = 11'b00001101001, 
      reset_ts_recover_od = 11'b00001110011, 
      reset_ts_end_od     = 11'b00010000000; 
   wire            owr;         
   wire            sr_a;        
   wire            pd;          
   reg             pdr;         
   wire            tbe;         
   reg             temt;        
   wire            temt_ext;    
   reg             rbf;         
   reg             rsrf;        
   reg             OW_SHORT;    
   reg             OW_LOW;      
   reg             INTR;
   reg             set_rbf;     
   wire            epd;         
   wire            ias;         
   wire            etbe;        
   wire            etmt;        
   wire            erbf;        
   wire            ersf;        
   wire            EOWSH;       
   wire            EOWL;        
   wire            clr_activate_intr;
   reg             reset_owr;
   reg             activate_intr;
   reg             dly_clr_activate_intr;
   reg             clear_interrupts;
   reg             SET_RSHRT;      
   reg             SET_IOSHRT;     
   wire [7:0]      xmit_buffer;    
   reg [7:0]       xmit_shiftreg;  
   reg [7:0]       rcvr_buffer;    
   reg [7:0]       rcvr_shiftreg;  
   reg             last_rcvr_bit;  
   reg             byte_done;
   reg             byte_done_flag, bdext1;  
   reg             First;          
   reg             BitRead1;
   reg             BitRead2;
   reg             BitWrite;
   reg [2:0]       OneWireReset;
   reg [4:0]       OneWireIO;
   reg [10:0]      count;
   reg [3:0]       index;
   reg [6:0]       TimeSlotCnt;
   reg             PD_READ;
   reg             LOW_DONE;
   reg             DQ_CONTROL_F;
   wire            DQ_CONTROL;
   wire            STPZ;
   reg             DQ_IN_HIGH;
   reg             OD_DQH;
	reg             rbf_set;
	reg             rsrf_reset;
   reg             ROW;
   wire FSM_CLK = clk;
   assign DQ_CONTROL = MR ? 1'b1 : DQ_CONTROL_F;  
   always @(posedge clk)                      
	begin
		if(clk_1us_en)
		begin
		  DQ_CONTROL_F <=
					   (EN_FOW == 1) && (FOW == 1)?0:
					   OneWireReset == Reset_Low?0:
					   OneWireReset == PD_Wait?1:
					   OneWireReset == PD_Force?0:
					   OneWireIO == DQLOW?0:
					   OneWireIO == WriteZero?0:
					   OneWireIO == ODWriteZero?0:
					   OneWireIO == WriteBit?0:
					   1;
		end
	end
   wire OneWireIO_eq_Load = OneWireIO == Load;
   wire   SPLY = (STP_SPLY && (OneWireReset == Idle) && (OneWireIO == IdleS));
   assign STPZ = !(STPEN && DQ_CONTROL && DQ_IN_HIGH
                   && (PD_READ || LOW_DONE || SPLY));
   always @(posedge MR or posedge FSM_CLK)
	begin
     if (MR)
       begin
         DQ_IN_HIGH <= 0;
         OD_DQH <=0;
       end
		else if(clk_1us_en)
		begin
		 if (OD)
		   if(DQ_IN && !DQ_IN_HIGH && !OD_DQH)
			 begin
			   DQ_IN_HIGH <= 1;
			   OD_DQH <=1;
			 end
		   else if(OD_DQH && DQ_IN)
			 DQ_IN_HIGH <= 0;
		   else
			 begin
			   OD_DQH <=0;
			   DQ_IN_HIGH <= 0;
			 end
		 else
		   begin
			 if(DQ_IN && !DQ_IN_HIGH)
			   DQ_IN_HIGH <= 1;
			 else if (DQ_IN && DQ_IN_HIGH)
			   DQ_IN_HIGH <= DQ_IN_HIGH;
			 else
			   DQ_IN_HIGH <= 0;
		   end
	  end
    end
	always @(posedge MR or posedge rbf_reset or posedge rbf_set)
     if (MR)
      rbf <= 0;
     else if (rbf_reset)  
      rbf <= 0;
     else
      rbf <= 1;
   always @(posedge MR or posedge FSM_CLK)
     if (MR)
       rsrf <= 1'b0;
	else if(clk_1us_en)
	begin
		 if (last_rcvr_bit || BIT_CTL)
		   begin
			 if (OneWireIO == IndexInc)
			   rsrf <= 1'b1;
			 else if (rsrf_reset)
			   rsrf <= 1'b0;
		   end
		 else if (rsrf_reset || (OneWireIO == DQLOW))
		   rsrf <= 1'b0;
	end
   always @(posedge FSM_CLK or posedge MR)
     if (MR)
       begin
         rcvr_buffer <= 0;
         rbf_set <= 0;
       end
     else if(clk_1us_en)
       if (rsrf && !rbf)
         begin
           rcvr_buffer <= rcvr_shiftreg;
           rbf_set <= 1'b1;
           rsrf_reset <= 1'b1;
         end
       else
         begin
           rbf_set <= 1'b0;
           if (!rsrf)
             rsrf_reset <= 1'b0;
         end
   always @(posedge MR or posedge FSM_CLK)
     begin
       if(MR)
         OW_SHORT <= 1'b0;
	   else if(clk_1us_en)
	   begin
		   if (SET_RSHRT || SET_IOSHRT)
			 OW_SHORT <= 1'b1;
		   else if (clr_activate_intr)
			 OW_SHORT <= 1'b0;
		   else
			 OW_SHORT <= OW_SHORT;
		 end
	  end
   always @(posedge MR or posedge FSM_CLK)
     begin
       if (MR)
         OW_LOW <= 0;
	   else if(clk_1us_en)
	   begin
		   if (!DQ_IN && (OneWireReset == Idle) && (OneWireIO == IdleS))
			 OW_LOW <= 1;
		   else if (clr_activate_intr)
			 OW_LOW <= 0;
		   else
			 OW_LOW <= OW_LOW;
	   end
     end
   always @(posedge MR or posedge FSM_CLK)
      if (MR)
         begin
            clear_interrupts <= 1'b0;
         end 
      else if(clk_1us_en)
         begin
            clear_interrupts<=clr_activate_intr;
         end
   wire acint_reset = MR || clr_activate_intr;
   always @(posedge acint_reset or posedge FSM_CLK)
     if(acint_reset)
        activate_intr <= 1'b0;
      else if(clk_1us_en)
        case(1)
          pd && epd:
             activate_intr <= 1'b1;
          tbe && etbe && !temt:
             activate_intr <= 1'b1;
          temt_ext && etmt:
             activate_intr <= 1'b1;
          rbf && erbf:
             activate_intr <= 1'b1;
          rsrf && ersf:
             activate_intr <= 1'b1;
          OW_LOW && EOWL:
             activate_intr <= 1'b1;
          OW_SHORT && EOWSH:
             activate_intr <= 1'b1;
        endcase 
   always @(activate_intr or ias)
      case({activate_intr,ias})
        2'b11:
           INTR <= 1'b1;
        2'b01:
           INTR <= 1'b0;
        2'b10:
           INTR <= 1'b1; 
        default:
           INTR <= 1'b0; 
      endcase 
   always @(posedge FSM_CLK or posedge MR)
      if(MR) begin
         pdr <= 1'b1;        
         OneWireReset <= Idle;
         count <= 0;
         PD_READ <= 0;       
         reset_owr <= 0;
         SET_RSHRT <= 0;     
			ROW <= 0;
      end
      else if(clk_1us_en)
      begin
       if(!owr)
       begin
         count <= 0;
			ROW <= 0;
         reset_owr <= 0;
         OneWireReset <= Idle;
       end
           else
              case(OneWireReset)
                Idle: begin
                   if (ROW)
			              reset_owr <= 1;
			          else
						   begin
							  count <= 0;
                       SET_RSHRT <=0;
                       reset_owr <= 0;
                       OneWireReset <= CheckOWR;
                     end
					  end
                CheckOWR: begin
                   OneWireReset <= Reset_Low;
                   if(!DQ_IN)
                     SET_RSHRT <= 1;
                   end
                Reset_Low: begin
                   count <= count + 1;
                   PD_READ <= 0;                
                   if(OD)                       
                     begin
                       if(count == reset_ts_release_od)
                         begin
                           OneWireReset <= PD_Wait;
                           PD_READ <= 1;
                         end
                     end
                   else if(count == reset_ts_release)
                     begin
                       OneWireReset <= PD_Wait;
                       PD_READ <= 1;
                     end
                end
                PD_Wait: begin
                   SET_RSHRT <= 0;
                   count <= count + 1;
                   if(!DQ_IN & DQ_CONTROL_F) begin
                      OneWireReset <= PD_Sample;
                   end
                   else if(OD)
                     begin
                       if(count==reset_ts_no_stpz_od)
                         PD_READ <= 0;       
                       else if(count == reset_ts_sample_od)
                         begin
                           OneWireReset <= PD_Sample;
                         end
                     end
                   else if(count == reset_ts_no_stpz)
                     PD_READ <= 0; 
                   else if((count == reset_ts_ppm) && PPM)
                     OneWireReset <= PD_Force;
                   else if(count == reset_ts_llsample && !LLM)
                     begin
                       OneWireReset <= PD_Sample;
                     end
                   else if(count == reset_ts_sample && LLM)
                     begin
                       OneWireReset <= PD_Sample;
                     end
                end
                PD_Sample: begin
                   PD_READ <= 0;
                   count <= count + 1;
                           pdr <= DQ_IN;
                           OneWireReset <= Reset_High;
                end
                Reset_High: begin
                   count <= count + 1;
                   if (OD)                      
                     begin
                       if (count == reset_ts_stpz_od)
                         begin
                           if (DQ_IN)
                              PD_READ <= 1;
                         end
                       else if (count == reset_ts_recover_od)
                         begin
                           PD_READ <= 0;
                         end
                       else if (count == reset_ts_end_od)
                         begin
                           PD_READ <= 0;
                           OneWireReset <= Idle;
                           ROW <= 1;
                         end
                     end
                   else
                     begin
                       if(count == reset_ts_stpz)
                         begin
                           if (DQ_IN)
                             PD_READ <= 1;
                         end
                       else if (count == reset_ts_recover)
                         begin
                           PD_READ <= 0;
                         end
                       else if (count == reset_ts_end)
                         begin
                           PD_READ <= 0;
                           OneWireReset <= Idle;
                           ROW <= 1;
                         end
                     end
                end
                PD_Force:  begin
                  count <= count + 1;
                  if (count == reset_ts_ppm_end)
                    begin
                      OneWireReset <= PD_Release;
                    end
                end
                PD_Release: begin
                  count <= count + 1;
                  pdr <= 0;              
                  if(count == reset_ts_stpz)
                    begin
                      if (DQ_IN)
                        PD_READ <= 1;
                    end
                  else if (count == reset_ts_recover)
                    begin
                      PD_READ <= 0;
                    end
                  else if (count == reset_ts_end)
                    begin
                      PD_READ <= 0;
                      OneWireReset <= Idle;
                      ROW <= 1;
                    end
                end
              endcase
	end
   always @(posedge MR or posedge FSM_CLK)
      if(MR)
         bdext1 <= 1'b0;
      else if(clk_1us_en)
         bdext1 <= byte_done;
   always @(posedge MR or posedge FSM_CLK)
      if(MR)
         byte_done_flag <= 1'b0;
      else if(clk_1us_en)
         byte_done_flag <= bdext1;
   assign temt_ext = temt && byte_done_flag;
   always @(posedge FSM_CLK or posedge MR)
      if(MR) begin
         index <= 0;
         TimeSlotCnt <= 0;
         temt <= 1'b1;
         last_rcvr_bit <= 1'b0;
         rcvr_shiftreg <= 0;
         OneWireIO <= IdleS;
         BitRead1<=0;
         BitRead2<=0;
         BitWrite<=0;
         First <= 1'b0;
         byte_done <= 1'b0;
         xmit_shiftreg<=0;
         LOW_DONE <= 0;
         SET_IOSHRT <= 0;
      end
      else if(clk_1us_en)
         case(OneWireIO)
           IdleS:
              begin
                 byte_done <= 1'b0;
                 index <= 0;
                 last_rcvr_bit <= 1'b0;
                 First <= 1'b0;
                 TimeSlotCnt <= 0;
                 LOW_DONE <= 0;
                 SET_IOSHRT <= 0;
                 temt <= 1'b1;
                 if(!tbe)
                   begin
                     if(STPEN)
                       OneWireIO <= ClrLowDone;
                     else
                       OneWireIO <= Load;
                   end
                 else
                    OneWireIO <= IdleS;
              end
           ClrLowDone:
              begin
                 LOW_DONE <= 0;
                 if (!LOW_DONE)
                   OneWireIO <= Load;
              end
           Load:
              begin
                 xmit_shiftreg <= xmit_buffer;
                 rcvr_shiftreg <= 0;
                 temt <= 1'b0;
                 LOW_DONE <= 0;
                 OneWireIO <= CheckOW;
              end
           CheckOW:
             begin
               OneWireIO <= DQLOW;
               if (!DQ_IN)
                 SET_IOSHRT <= 1;
             end
           DQLOW:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              LOW_DONE <= 0;
              if (OD)
               begin
                   if(!sr_a)
                     begin
                       case(index)
                         0:
                            if(!xmit_shiftreg[0])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         1:
                            if(!xmit_shiftreg[1])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         2:
                            if(!xmit_shiftreg[2])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         3:
                            if(!xmit_shiftreg[3])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         4:
                            if(!xmit_shiftreg[4])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         5:
                            if(!xmit_shiftreg[5])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         6:
                            if(!xmit_shiftreg[6])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                         7:
                            if(!xmit_shiftreg[7])
                               OneWireIO <= ODWriteZero;
                            else
                               OneWireIO <= ODWriteOne;
                       endcase 
                     end
                   else         
                     OneWireIO <= ReadBit;
                  end
              else if(((TimeSlotCnt==bit_ts_writeone_high) && !LLM) || 
                      ((TimeSlotCnt==bit_ts_writeone_high_ll) && LLM))
              begin
                 if(!sr_a)                  
                   begin
                      case(index)
                        0:
                           if(!xmit_shiftreg[0])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        1:
                           if(!xmit_shiftreg[1])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        2:
                           if(!xmit_shiftreg[2])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        3:
                           if(!xmit_shiftreg[3])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        4:
                           if(!xmit_shiftreg[4])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        5:
                           if(!xmit_shiftreg[5])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        6:
                           if(!xmit_shiftreg[6])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                        7:
                           if(!xmit_shiftreg[7])
                              OneWireIO <= WriteZero;
                           else
                              OneWireIO <= WriteOne;
                      endcase 
                  end
                  else         
                     OneWireIO <= ReadBit;
                  end
               end
           WriteZero:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              if(((TimeSlotCnt==bit_ts_sample) && !sr_a && !LLM) ||
                 ((TimeSlotCnt==bit_ts_sample_ll) && !sr_a &&  LLM))
                 case(index)
                   0:
                      rcvr_shiftreg[0] <= DQ_IN;
                   1:
                      rcvr_shiftreg[1] <= DQ_IN;
                   2:
                      rcvr_shiftreg[2] <= DQ_IN;
                   3:
                      rcvr_shiftreg[3] <= DQ_IN;
                   4:
                      rcvr_shiftreg[4] <= DQ_IN;
                   5:
                      rcvr_shiftreg[5] <= DQ_IN;
                   6:
                      rcvr_shiftreg[6] <= DQ_IN;
                   7:
                      rcvr_shiftreg[7] <= DQ_IN;
                 endcase
              if(TimeSlotCnt == bit_ts_writezero_high)            
                 OneWireIO <= WaitTS;
              if(DQ_IN)
                 LOW_DONE <= 1;
             end
           WriteOne:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              if(((TimeSlotCnt==bit_ts_sample) && !sr_a && !LLM) ||
                 ((TimeSlotCnt==bit_ts_sample_ll) && !sr_a &&  LLM))
                 case(index)
                   0:
                      rcvr_shiftreg[0] <= DQ_IN;
                   1:
                      rcvr_shiftreg[1] <= DQ_IN;
                   2:
                      rcvr_shiftreg[2] <= DQ_IN;
                   3:
                      rcvr_shiftreg[3] <= DQ_IN;
                   4:
                      rcvr_shiftreg[4] <= DQ_IN;
                   5:
                      rcvr_shiftreg[5] <= DQ_IN;
                   6:
                      rcvr_shiftreg[6] <= DQ_IN;
                   7:
                      rcvr_shiftreg[7] <= DQ_IN;
                 endcase
              if(TimeSlotCnt == bit_ts_writezero_high)             
                 OneWireIO <= WaitTS;
              if(DQ_IN)
                 LOW_DONE <= 1;
             end
           ODWriteZero:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              if((TimeSlotCnt == bit_ts_sample_od) && !sr_a)
                 case(index)
                   0:
                      rcvr_shiftreg[0] <= DQ_IN;
                   1:
                      rcvr_shiftreg[1] <= DQ_IN;
                   2:
                      rcvr_shiftreg[2] <= DQ_IN;
                   3:
                      rcvr_shiftreg[3] <= DQ_IN;
                   4:
                      rcvr_shiftreg[4] <= DQ_IN;
                   5:
                      rcvr_shiftreg[5] <= DQ_IN;
                   6:
                      rcvr_shiftreg[6] <= DQ_IN;
                   7:
                      rcvr_shiftreg[7] <= DQ_IN;
                 endcase
              if(TimeSlotCnt == bit_ts_writezero_high_od)
                 OneWireIO <= WaitTS;
              if(DQ_IN)
                 LOW_DONE <= 1;
             end
           ODWriteOne:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              if((TimeSlotCnt == bit_ts_sample_od) && !sr_a)
                 case(index)
                   0:
                      rcvr_shiftreg[0] <= DQ_IN;
                   1:
                      rcvr_shiftreg[1] <= DQ_IN;
                   2:
                      rcvr_shiftreg[2] <= DQ_IN;
                   3:
                      rcvr_shiftreg[3] <= DQ_IN;
                   4:
                      rcvr_shiftreg[4] <= DQ_IN;
                   5:
                      rcvr_shiftreg[5] <= DQ_IN;
                   6:
                      rcvr_shiftreg[6] <= DQ_IN;
                   7:
                      rcvr_shiftreg[7] <= DQ_IN;
                 endcase
              if(TimeSlotCnt == bit_ts_writezero_high_od)
                OneWireIO <= WaitTS;
              if(DQ_IN)
                 LOW_DONE <= 1;
             end
           ReadBit:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              if(DQ_IN)
                LOW_DONE <= 1;
              if(OD)
                begin
                  if(TimeSlotCnt == bit_ts_sample_od)
                    if(!First)
                      BitRead1 <= DQ_IN;
                    else
                      BitRead2 <= DQ_IN;
                  if(TimeSlotCnt == bit_ts_writezero_high_od)     
                    OneWireIO <= FirstPassSR;
                end
              else
                begin
                  if(((TimeSlotCnt == bit_ts_sample)&&!LLM) || ((TimeSlotCnt == bit_ts_sample_ll)&&LLM))
                    if(!First)
                      BitRead1 <= DQ_IN;
                    else
                      BitRead2 <= DQ_IN;
                  if(TimeSlotCnt == bit_ts_writezero_high)
                    OneWireIO <= FirstPassSR;
                end
             end
           FirstPassSR:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              LOW_DONE <= 0;
              if(OD)
                begin
                  if(TimeSlotCnt == bit_ts_end_od)
                    begin
                      TimeSlotCnt <= 0;
                      if(!First)
                        begin
                          First <= 1'b1;
                          OneWireIO <= DQLOW;
                        end
                      else
                        begin
                          OneWireIO <= WriteBitSR;
                        end
                    end
                end
              else
                begin
                  if(((TimeSlotCnt==bit_ts_end) && !LLM) || ((TimeSlotCnt==bit_ts_end_ll) && LLM))
                    begin
                      TimeSlotCnt <= 0;
                      if(!First)
                        begin
                          First <= 1'b1;
                          OneWireIO <= DQLOW;
                        end
                      else
                        begin
                          OneWireIO <= WriteBitSR;
                        end 
                    end
                end
             end
           WriteBitSR:
             begin
               case({BitRead1,BitRead2})
                 2'b00: begin
                    case(index)
                      0: begin
                         BitWrite <= xmit_shiftreg[1];
                         rcvr_shiftreg[0] <= 1'b1;
                      end
                      1: begin
                         BitWrite <= xmit_shiftreg[2];
                         rcvr_shiftreg[1] <= 1'b1;
                      end
                      2: begin
                         BitWrite <= xmit_shiftreg[3];
                         rcvr_shiftreg[2] <= 1'b1;
                      end
                      3: begin
                         BitWrite <= xmit_shiftreg[4];
                         rcvr_shiftreg[3] <= 1'b1;
                      end
                      4: begin
                         BitWrite <= xmit_shiftreg[5];
                         rcvr_shiftreg[4] <= 1'b1;
                      end
                      5: begin
                         BitWrite <= xmit_shiftreg[6];
                         rcvr_shiftreg[5] <= 1'b1;
                      end
                      6: begin
                         BitWrite <= xmit_shiftreg[7];
                         rcvr_shiftreg[6] <= 1'b1;
                      end
                      7: begin
                         BitWrite <= xmit_shiftreg[0];
                         rcvr_shiftreg[7] <= 1'b1;
                      end
                    endcase
                 end
                 2'b01: begin
                    BitWrite <= 1'b0;
                    case(index)
                      0:
                         rcvr_shiftreg[0] <= 1'b0;
                      1:
                         rcvr_shiftreg[1] <= 1'b0;
                      2:
                         rcvr_shiftreg[2] <= 1'b0;
                      3:
                         rcvr_shiftreg[3] <= 1'b0;
                      4:
                         rcvr_shiftreg[4] <= 1'b0;
                      5:
                         rcvr_shiftreg[5] <= 1'b0;
                      6:
                         rcvr_shiftreg[6] <= 1'b0;
                      7:
                         rcvr_shiftreg[7] <= 1'b0;
                    endcase
                 end
                 2'b10: begin
                    BitWrite <= 1'b1;
                    case(index)
                      0:
                         rcvr_shiftreg[0] <= 1'b0;
                      1:
                         rcvr_shiftreg[1] <= 1'b0;
                      2:
                         rcvr_shiftreg[2] <= 1'b0;
                      3:
                         rcvr_shiftreg[3] <= 1'b0;
                      4:
                         rcvr_shiftreg[4] <= 1'b0;
                      5:
                         rcvr_shiftreg[5] <= 1'b0;
                      6:
                         rcvr_shiftreg[6] <= 1'b0;
                      7:
                         rcvr_shiftreg[7] <= 1'b0;
                    endcase
                 end
                 2'b11: begin
                    BitWrite <= 1'b1;
                    case(index)
                      0: begin
                         rcvr_shiftreg[0] <= 1'b1;
                         rcvr_shiftreg[1] <= 1'b1;
                      end
                      1: begin
                         rcvr_shiftreg[1] <= 1'b1;
                         rcvr_shiftreg[2] <= 1'b1;
                      end
                      2: begin
                         rcvr_shiftreg[2] <= 1'b1;
                         rcvr_shiftreg[3] <= 1'b1;
                      end
                      3: begin
                         rcvr_shiftreg[3] <= 1'b1;
                         rcvr_shiftreg[4] <= 1'b1;
                      end
                      4: begin
                         rcvr_shiftreg[4] <= 1'b1;
                         rcvr_shiftreg[5] <= 1'b1;
                      end
                      5: begin
                         rcvr_shiftreg[5] <= 1'b1;
                         rcvr_shiftreg[6] <= 1'b1;
                      end
                      6: begin
                         rcvr_shiftreg[6] <= 1'b1;
                         rcvr_shiftreg[7] <= 1'b1;
                      end
                      7: begin
                         rcvr_shiftreg[7] <= 1'b1;
                         rcvr_shiftreg[0] <= 1'b1;
                      end
                    endcase
                 end
               endcase 
               OneWireIO <= WriteBit;
              end
           WriteBit:
             begin
              TimeSlotCnt <= TimeSlotCnt + 1;
              case(index)
                0:
                   rcvr_shiftreg[1] <= BitWrite;
                1:
                   rcvr_shiftreg[2] <= BitWrite;
                2:
                   rcvr_shiftreg[3] <= BitWrite;
                3:
                   rcvr_shiftreg[4] <= BitWrite;
                4:
                   rcvr_shiftreg[5] <= BitWrite;
                5:
                   rcvr_shiftreg[6] <= BitWrite;
                6:
                   rcvr_shiftreg[7] <= BitWrite;
                7:
                   rcvr_shiftreg[0] <= BitWrite;
              endcase
              if(!BitWrite)
                begin
                  if(OD)
                    OneWireIO <= ODWriteZero;
                  else
                    OneWireIO <= WriteZero;
                end
              else
                begin
                  if(OD && (TimeSlotCnt == bit_ts_writeone_high_od))
                    OneWireIO <= ODWriteOne;
                  else if (!LLM && (TimeSlotCnt == bit_ts_writeone_high))  
                    OneWireIO <= WriteOne;
                  else if (LLM && (TimeSlotCnt == bit_ts_writeone_high_ll))
                    OneWireIO <= WriteOne;
                end
             end
           WaitTS:
             begin
              SET_IOSHRT <= 0;
              TimeSlotCnt <= TimeSlotCnt + 1;
              if(OD)
                begin
                  if(TimeSlotCnt == bit_ts_end_od)  
                    OneWireIO <= IndexInc;
                end
              else
                if(((TimeSlotCnt == bit_ts_end) && !LLM) || ((TimeSlotCnt==bit_ts_end_ll) && LLM))
                  OneWireIO <= IndexInc;
              if(DQ_IN)
                 LOW_DONE <= 1;
             end
           IndexInc:
             begin
              if(!sr_a)
                 index <= index + 1;
              else
                 begin
                    index <= index + 2;
                    First <= 1'b0;
                 end
              if(BIT_CTL || (index == 8-1 && !sr_a) || (index == 8-2 && sr_a)  )
                 begin                             
                    byte_done <= 1'b1;
                    OneWireIO <= UpdateBuff;
                 end
              else
                 begin
                    if((index == 7-1) && !sr_a)
                       last_rcvr_bit <= 1'b1;
                    else
                       if((index == 6-2) && sr_a)
                          last_rcvr_bit <= 1'b1;
                    OneWireIO <= DQLOW;
                    TimeSlotCnt <= 0;
                 end
                 LOW_DONE <= 0;
             end
           UpdateBuff:
             begin
                OneWireIO <= IdleS;
                if(DQ_IN && STP_SPLY)
                  LOW_DONE <= 1;
             end
         endcase
endmodule
