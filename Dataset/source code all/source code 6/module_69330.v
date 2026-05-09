module SPIPROG (input 	JTCK           ,
		input 	JTDI           ,
		output 	JTDO2          ,
		input 	JSHIFT         ,
		input 	JUPDATE        ,
		input 	JRSTN          ,
		input 	JCE2           ,
		input 	SPIPROG_ENABLE ,
		input 	CONTROL_DATAN  ,
		output 	SPI_C          ,
		output 	SPI_D          ,
		output 	SPI_SN         ,
		input 	SPI_Q);
   wire 		er2Cr_enable ;
   wire 		er2Dr0_enable;
   wire 		er2Dr1_enable;
   wire 		tdo_er2Cr ;
   wire 		tdo_er2Dr0;
   wire 		tdo_er2Dr1;
   wire [7:0] 		encodedDrSelBits ;
   wire [8:0] 		er2CrTdiBit      ;
   wire [8:0] 		er2Dr0TdiBit     ;
   wire 		captureDrER2;
   reg 			spi_s       ;
   reg [6:0] 		spi_q_dly;
   wire [7:0] 		ip_functionality_id;
   genvar 		i;
   assign 		er2Cr_enable = JCE2 & SPIPROG_ENABLE & CONTROL_DATAN;
   assign 		tdo_er2Cr = er2CrTdiBit[0];
   generate
      for(i=0; i<=7; i=i+1)
	begin:CR_BIT0_BIT7
	   TYPEA BIT_N (.CLK        (JTCK),
			.RESET_N    (JRSTN),
			.CLKEN      (er2Cr_enable),
			.TDI        (er2CrTdiBit[i + 1]),
			.TDO        (er2CrTdiBit[i]),
			.DATA_OUT   (encodedDrSelBits[i]),
			.DATA_IN    (encodedDrSelBits[i]),
			.CAPTURE_DR (captureDrER2),
			.UPDATE_DR  (JUPDATE));
	end
   endgenerate 
   assign er2CrTdiBit[8] = JTDI;
   assign er2Dr0_enable = (JCE2 & SPIPROG_ENABLE & ~CONTROL_DATAN & (encodedDrSelBits == 8'b00000000)) ? 1'b1 : 1'b0;
   assign tdo_er2Dr0 = er2Dr0TdiBit[0];
   assign ip_functionality_id = 8'b00000001;  
   generate
      for(i=0; i<=7; i=i+1)
	begin:DR0_BIT0_BIT7
	   TYPEB BIT_N (.CLK        (JTCK),
			.RESET_N    (JRSTN),
			.CLKEN      (er2Dr0_enable),
			.TDI        (er2Dr0TdiBit[i + 1]),
			.TDO        (er2Dr0TdiBit[i]),
			.DATA_IN    (ip_functionality_id[i]),
			.CAPTURE_DR (captureDrER2));
	end
   endgenerate 
   assign er2Dr0TdiBit[8] = JTDI;
   assign er2Dr1_enable = (JCE2 & JSHIFT & SPIPROG_ENABLE & ~CONTROL_DATAN & (encodedDrSelBits == 8'b00000001)) ?  1'b1 : 1'b0;
   assign SPI_C = ~ (JTCK & er2Dr1_enable & spi_s);
   assign SPI_D = JTDI & er2Dr1_enable;
   always @(negedge JTCK or negedge JRSTN)
     begin
	if (~JRSTN)
          spi_s <= 1'b0;
	else
          if (JUPDATE)
            spi_s <= 1'b0;
          else
            spi_s <= er2Dr1_enable;
     end
   assign SPI_SN = ~spi_s;
   always @(negedge JTCK or negedge JRSTN)
     begin
	if (~JRSTN)
          spi_q_dly <= 'b0;
	else
          if (er2Dr1_enable)
            spi_q_dly  <= {spi_q_dly[5:0],SPI_Q};
     end
   assign tdo_er2Dr1 = spi_q_dly[6];
   assign JTDO2 = CONTROL_DATAN ? tdo_er2Cr :
	  (encodedDrSelBits == 8'b00000000) ? tdo_er2Dr0 :
	  (encodedDrSelBits == 8'b00000001) ? tdo_er2Dr1 : 1'b0;
   assign captureDrER2  = ~JSHIFT & JCE2;
endmodule
