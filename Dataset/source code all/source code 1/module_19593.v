module GS_cpld(
	output reg         config_n,  
	input  wire        status_n,  
	input  wire        conf_done, 
	output wire        cs,        
	input  wire        init_done, 
	input  wire        clk24in, 
	input  wire        clk20in, 
	input  wire        clksel0, 
	input  wire        clksel1, 
	output wire        clkout,  
	input  wire        clkin, 
	input  wire        coldres_n, 
	output reg         warmres_n,
	input  wire        iorq_n, 
	input  wire        mreq_n,
	input  wire        rd_n,
	input  wire        wr_n,
	inout  wire [ 7:0] d, 
	input  wire        a6,  
	input  wire        a7,
	input  wire        a10,
	input  wire        a11,
	input  wire        a12,
	input  wire        a13,
	input  wire        a14,
	input  wire        a15,
	output wire        mema14,
	output wire        mema15,
	output wire        mema19,
	inout  wire        romcs_n,
	inout  wire        memoe_n,
	inout  wire        memwe_n,
	input  wire        in_ramcs0_n,
	input  wire        in_ramcs1_n,
	input  wire        in_ramcs2_n,
	input  wire        in_ramcs3_n,
	output wire        out_ramcs0_n,
	output wire        out_ramcs1_n,
	output wire        ra6,  
	output wire        ra7,
	output wire        ra10,
	output wire        ra11,
	output wire        ra12,
	output wire        ra13,
	inout  wire [ 7:0] rd 
);
	reg int_mema14,int_mema15;
	reg int_romcs_n,int_ramcs_n;
	wire int_memoe_n,int_memwe_n;
	wire int_cs;
	wire ext_romcs_n,
	     ext_memoe_n,
	     ext_memwe_n;
	reg [1:0] memcfg; 
	reg disbl; 
	reg was_cold_reset_n; 
	reg  [1:0] dbout;
	wire [1:0] dbin;
	wire memcfg_write_n;
	wire rescfg_write_n;
	wire coldrstf_read_n;
	wire fpgastat_read_n;
	assign dbin[1] = d[7];
	assign dbin[0] = d[0];
	reg [3:0] rstcount; 
	reg [2:0] disbl_sync;
	clocker clk( .clk1(clk24in),
	             .clk2(clk20in),
	             .clksel(clksel1),
	             .divsel(clksel0),
	             .clkout(clkout)
	           );
	always @(negedge config_n,posedge init_done)
	begin
		if( !config_n ) 
			disbl <= 0;
		else 
			disbl <= 1;
	end
	assign mema14  = disbl ? 1'bZ : int_mema14;
	assign mema15  = disbl ? 1'bZ : int_mema15;
	assign romcs_n = disbl ? 1'bZ : int_romcs_n;
	assign memoe_n = disbl ? 1'bZ : int_memoe_n;
	assign memwe_n = disbl ? 1'bZ : int_memwe_n;
	assign cs      = disbl ? 1'bZ : int_cs;
	assign ext_romcs_n = romcs_n;
	assign ext_memoe_n = memoe_n;
	assign ext_memwe_n = memwe_n;
	always @*
	begin
		casex( {a15,a14,memcfg[1]} )
		3'b00x:
			{int_mema15,int_mema14,int_romcs_n,int_ramcs_n} <= 4'b0001;
		3'b01x:
			{int_mema15,int_mema14,int_romcs_n,int_ramcs_n} <= 4'b0010;
		3'b1x0:
			{int_mema15,int_mema14,int_romcs_n,int_ramcs_n} <= {memcfg[0],a14,2'b01};
		3'b1x1:
			{int_mema15,int_mema14,int_romcs_n,int_ramcs_n} <= {memcfg[0],a14,2'b10};
		endcase
	end
	assign int_memoe_n = mreq_n | rd_n;
	assign int_memwe_n = mreq_n | wr_n;
	assign memcfg_write_n = iorq_n | wr_n | a7 | ~a6; 
	always @(negedge coldres_n, posedge memcfg_write_n)
	begin
		if( !coldres_n ) 
			memcfg <= 2'b00;
		else 
			memcfg <= dbin;
	end
	assign rescfg_write_n = iorq_n | wr_n | ~a7 | a6; 
	always @(posedge rescfg_write_n, negedge coldres_n)
	begin
		if( !coldres_n ) 
		begin
			was_cold_reset_n <= 0; 
			config_n <= 0; 
		end
		else 
		begin
			config_n <= dbin[0];
			was_cold_reset_n <= dbin[1] | was_cold_reset_n;
		end
	end
	assign int_cs = a7 & a6; 
	assign coldrstf_read_n = iorq_n | rd_n | a7 | ~a6; 
	assign fpgastat_read_n = iorq_n | rd_n | ~a7 | a6; 
	always @*
	begin
		case( {coldrstf_read_n,fpgastat_read_n} )
			2'b01:
				dbout = { was_cold_reset_n, 1'bX };
			2'b10:
				dbout = { status_n, conf_done };
			default:
				dbout = 2'bXX;
		endcase
	end
	always @(posedge clkin)
	begin
		disbl_sync[2:0]={disbl_sync[1:0],disbl};
	end
	always @(negedge coldres_n,posedge clkin)
	begin
		if( coldres_n==0 ) 
		begin
			rstcount <= (-1);
			warmres_n <= 0;
		end
		else 
		begin
			if( disbl_sync[2]==0 && disbl_sync[1]==1 ) 
			begin
				warmres_n <= 0;
				rstcount <= (-1);
			end
			else 
			begin
				rstcount <= rstcount - 1;
				if( |rstcount == 0 )
					warmres_n <= 1'bZ;
			end
		end
	end
	assign d = ( (!coldrstf_read_n)||(!fpgastat_read_n) )   ?
	           { dbout[1], 6'bXXXXXX, dbout[0] }            :
	           ( (ext_romcs_n&&(!ext_memoe_n)) ? rd : 8'bZZZZZZZZ ) ;
	assign rd = (ext_romcs_n&&(!ext_memwe_n)) ? d : 8'bZZZZZZZZ;
	assign ra6  = a6;
	assign ra7  = a7;
	assign ra10 = a10;
	assign ra11 = a11;
	assign ra12 = a12;
	assign ra13 = a13;
	assign out_ramcs0_n = disbl ? ( in_ramcs0_n & in_ramcs1_n ) : int_ramcs_n;
	assign out_ramcs1_n = disbl ? ( in_ramcs2_n & in_ramcs3_n ) : 1'b1;
	assign mema19 = disbl ? ( in_ramcs0_n & in_ramcs2_n ) : 1'b0;
endmodule
