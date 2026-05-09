module flash_writer(
input  p_ready,
input  WE_CLK,
input  iFLASH_RY_N,
input  iOSC_28   ,
input  iERASE    ,
input  iPROGRAM ,
input  iVERIFY  ,
input  iOK  ,
input  iFAIL,
input  iRESET_N   ,
output oREAD_PRO_END,
output oVERIFY_TIME,
output [21:0] 		oFLASH_ADDR,
output reg 	[3:0] 	oFLASH_CMD,
output 		        oFLASH_TR
);

always @(posedge iOSC_28)begin
case ({iFAIL,iOK,iRESET_N,iVERIFY,iPROGRAM,iERASE})
	6'b000100: oFLASH_CMD = 4'h0;	
	6'b000001: oFLASH_CMD = 4'h4;	
	6'b000010: oFLASH_CMD = 4'h1;	
	6'b001000: oFLASH_CMD = 4'h7;	
	6'b010000: oFLASH_CMD = 4'h8;	
	6'b100000: oFLASH_CMD = 4'h9;	
endcase
end

wire [21:0]end_address;
assign end_address = 22'h3fffff;

reg  [21:0]addr_prog;
reg  end_prog;
reg  PROGRAM_TR_r;
reg  [7:0]ST_P;

always @(posedge iRESET_N or posedge WE_CLK) begin
if (iRESET_N) begin
	addr_prog    <= end_address;
	end_prog  	 <= 1;
	ST_P 		 <= 9; 
	PROGRAM_TR_r <= 0;
end	
else if (iPROGRAM) begin
	addr_prog 	<= 0;
	end_prog  	<= 0;
    ST_P 		<= 0;	
	PROGRAM_TR_r<= 0;
end	
else begin
	case ( ST_P )
	0:begin 
		ST_P <= ST_P + 1;
		PROGRAM_TR_r <=1 ;
	end
	1:begin 
		ST_P <= 4;
		PROGRAM_TR_r <=0;
	end
	2:begin 
		ST_P <= ST_P + 1;
	end
	3:begin 
		ST_P <= ST_P + 1;
	end
	4:begin 
		ST_P <= ST_P + 1;
	end
	5:begin 
		if ( iFLASH_RY_N ) ST_P <= 7;
	end
	6:begin 
		ST_P <= ST_P + 1;
	end
	7:begin 
		if (addr_prog == end_address ) 
			ST_P <= 9;
		else 
		    begin
			addr_prog <= addr_prog + 1;
			ST_P <= 0;
			end
	  end
	8:begin 
		addr_prog <= addr_prog + 1;
		ST_P <= 0;
	end
	9:begin  
		end_prog  <= 1;
	end
	endcase
  end
end

reg  [21:0]addr_read;
reg  end_read;

always @(posedge iRESET_N or posedge WE_CLK) begin
if ( iRESET_N ) begin 
	addr_read <= end_address;
	end_read  <= 1;
end	
else if (iVERIFY) begin
	addr_read <= 0;
	end_read  <= 0;
end	
else if (addr_read<end_address) 
	addr_read=addr_read+1;
else if (addr_read == end_address)  end_read  <= 1;
end

assign oFLASH_ADDR = (
(oFLASH_CMD==4'h1)? addr_prog: (
(oFLASH_CMD==4'h0)? addr_read: 0
));

wire   erase_tr  =  (iERASE)?1:0;						
wire   porgram_tr=  PROGRAM_TR_r ;   
wire   verify_tr = (addr_read  < end_address)? ~WE_CLK : 0;
assign oFLASH_TR  =  erase_tr | porgram_tr | verify_tr; 
assign oREAD_PRO_END = end_read & end_prog;
assign oVERIFY_TIME = ~end_read ;

endmodule