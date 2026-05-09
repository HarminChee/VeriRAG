module ports(
	din,  
	dout, 
	busin, 
	a, 
	iorq_n,mreq_n,rd_n,wr_n, 
	data_port_input, 
	data_port_output, 
	command_port_input, 
	data_bit_input, 
	command_bit_input, 
	data_bit_output, 
	command_bit_output,
	data_bit_wr, 
	command_bit_wr,
	mode_8chans, 
	mode_pan4ch, 
	mode_ramro, 
	mode_norom,
	mode_pg0, 
	mode_pg1,
	clksel0, 
	clksel1,
	snd_wrtoggle, 
	snd_datnvol,  
	snd_addr,     
	snd_data,     
	md_din, 
	md_start,
	md_dreq,
	md_halfspeed,
	mc_ncs, 
	mc_xrst,
	mc_dout,
	mc_din,
	mc_start,
	mc_speed,
	mc_rdy,
	sd_ncs, 
	sd_dout,
	sd_din,
	sd_start,
	sd_det,
	sd_wp,
	led, 
	led_toggle,
	dma_din_modules, 
	dma_select_zx,
	dma_dout_zx,
	dma_wrstb,
	dma_regsel,
	rst_n,
	cpu_clock 
);
	localparam MPAG      = 6'h00;
	localparam MPAGEX    = 6'h10;
	localparam ZXCMD     = 6'h01;
	localparam ZXDATRD   = 6'h02;
	localparam ZXDATWR   = 6'h03;
	localparam ZXSTAT    = 6'h04;
	localparam CLRCBIT   = 6'h05;
	localparam VOL1      = 6'h06;
	localparam VOL2      = 6'h07;
	localparam VOL3      = 6'h08;
	localparam VOL4      = 6'h09;
	localparam VOL5      = 6'h16;
	localparam VOL6      = 6'h17;
	localparam VOL7      = 6'h18;
	localparam VOL8      = 6'h19;
	localparam DAMNPORT1 = 6'h0a;
	localparam DAMNPORT2 = 6'h0b;
	localparam LEDCTR    = 6'h01;
	localparam GSCFG0    = 6'h0f;
	localparam SCTRL     = 6'h11;
	localparam SSTAT     = 6'h12;
	localparam SD_SEND   = 6'h13;
	localparam SD_READ   = 6'h13;
	localparam SD_RSTR   = 6'h14;
	localparam MD_SEND   = 6'h14; 
	localparam MC_SEND   = 6'h15;
	localparam MC_READ   = 6'h15;
	localparam DMA_MOD   = 6'h1b; 
	localparam DMA_HAD   = 6'h1c; 
	localparam DMA_MAD   = 6'h1d; 
	localparam DMA_LAD   = 6'h1e; 
	localparam DMA_CST   = 6'h1f; 
	localparam DMA_PORTS = 6'h1c; 
	input      [7:0] din;
	output reg [7:0] dout;
	output reg busin; 
	input [15:0] a;
	input iorq_n,mreq_n,rd_n,wr_n;
	input      [7:0] data_port_input;
	input      [7:0] command_port_input;
	output reg [7:0] data_port_output;
	input data_bit_input;
	input command_bit_input;
	output reg data_bit_output;
	output reg command_bit_output;
	output reg data_bit_wr;
	output reg command_bit_wr;
	output reg mode_8chans;
	output reg mode_pan4ch;
	output reg mode_ramro;
	output reg mode_norom;
	output reg [6:0] mode_pg0;
	output reg [6:0] mode_pg1;
	output reg clksel0;
	output reg clksel1;
	output reg snd_wrtoggle;
	output reg snd_datnvol;
	output reg [2:0] snd_addr;
	output reg [7:0] snd_data;
	input rst_n;
	input cpu_clock;
	output [7:0] md_din; 
	output md_start; 
	input md_dreq; 
	output reg md_halfspeed;
	output reg mc_ncs; 
	output reg mc_xrst; 
	output mc_start; 
	output reg [1:0] mc_speed;
	input mc_rdy;
	output [7:0] mc_din; 
	input [7:0] mc_dout; 
	output reg sd_ncs;
	output sd_start;
	output [7:0] sd_din;
	input [7:0] sd_dout;
	input sd_det;
	input sd_wp;
	output reg [7:0] dma_din_modules;
	input [7:0] dma_dout_zx;
	output reg dma_select_zx;
	output reg dma_wrstb;
	output reg [1:0] dma_regsel;
	output reg led;
	input led_toggle;
	reg mode_expag; 
	reg port09_bit5;
	wire port_enabled; 
	wire mem_enabled; 
	reg volports_enabled; 
	reg iowrn_reg; 
	reg iordn_reg; 
	reg merdn_reg; 
	reg port_wr; 
	reg port_rd;  
	reg memreg_rd; 
	wire port00_wr;   
	wire p_ledctr_wr;
	wire port02_rd;
	wire port03_wr;
	wire port05_wrrd;
	wire port09_wr;
	wire port0a_wrrd;
	wire port0b_wrrd;
	wire port0f_wr;
	wire port10_wr;
	wire p_sctrl_wr;
	wire p_sdsnd_wr;
	wire p_sdrst_rd;
	wire p_mdsnd_wr;
	wire p_mcsnd_wr;
	wire p_dmamod_wr;
	wire p_dmaports_wr;
	reg [2:0] volnum; 
	reg [2:0] dma_module_select; 
	localparam DMA_NONE_SELECTED = 3'd0;
	localparam DMA_MODULE_ZX     = 3'd1;
	reg [7:0] dma_dout_modules; 
	assign port_enabled = ~(a[7] | a[6]); 
	assign mem_enabled = (~a[15]) & a[14] & a[13]; 
	always @*
	begin
		if( a[5:0]==VOL1 ||
		    a[5:0]==VOL2 ||
		    a[5:0]==VOL3 ||
		    a[5:0]==VOL4 ||
		    a[5:0]==VOL5 ||
		    a[5:0]==VOL6 ||
		    a[5:0]==VOL7 ||
		    a[5:0]==VOL8 )
			volports_enabled <= 1'b1;
		else
			volports_enabled <= 1'b0;
	end
	always @*
	begin
		if( port_enabled && (!iorq_n) && (!rd_n) )
			busin <= 1'b0; 
		else
			busin <= 1'b1; 
	end
	always @(posedge cpu_clock)
	begin
		iowrn_reg <= iorq_n | wr_n;
		iordn_reg <= iorq_n | rd_n;
		if( port_enabled && (!iorq_n) && (!wr_n) && iowrn_reg )
			port_wr <= 1'b1;
		else
			port_wr <= 1'b0;
		if( port_enabled && (!iorq_n) && (!rd_n) && iordn_reg )
			port_rd <= 1'b1;
		else
			port_rd <= 1'b0;
	end
	always @(negedge cpu_clock)
	begin
		merdn_reg <= mreq_n | rd_n;
		if( mem_enabled && (!mreq_n) && (!rd_n) && merdn_reg )
			memreg_rd <= 1'b1;
		else
			memreg_rd <= 1'b0;
	end
	assign port00_wr   = ( a[5:0]==MPAG      && port_wr            );
	assign port02_rd   = ( a[5:0]==ZXDATRD   && port_rd            );
	assign port03_wr   = ( a[5:0]==ZXDATWR   && port_wr            );
	assign port05_wrrd = ( a[5:0]==CLRCBIT   && (port_wr||port_rd) );
	assign port09_wr   = ( a[5:0]==VOL4      && port_wr            );
	assign port0a_wrrd = ( a[5:0]==DAMNPORT1 && (port_wr||port_rd) );
	assign port0b_wrrd = ( a[5:0]==DAMNPORT2 && (port_wr||port_rd) );
	assign port0f_wr   = ( a[5:0]==GSCFG0    && port_wr            );
	assign port10_wr   = ( a[5:0]==MPAGEX    && port_wr            );
	assign p_sctrl_wr = ( a[5:0]==SCTRL  && port_wr );
	assign p_sdsnd_wr = ( a[5:0]==SD_SEND && port_wr );
	assign p_sdrst_rd = ( a[5:0]==SD_RSTR && port_rd );
	assign p_mdsnd_wr = ( a[5:0]==MD_SEND && port_wr );
	assign p_mcsnd_wr = ( a[5:0]==MC_SEND && port_wr );
	assign p_ledctr_wr = ( a[5:0]==LEDCTR && port_wr );
	assign p_dmamod_wr   = ( a[5:0]==DMA_MOD && port_wr );
	assign p_dmaports_wr = ( {a[5:2],2'b00}==DMA_PORTS && port_wr );
	always @*
	begin
		case( a[5:0] )
		ZXCMD: 
			dout <= command_port_input;
		ZXDATRD: 
			dout <= data_port_input;
		ZXSTAT: 
			dout <= { data_bit_input, 6'bXXXXXX, command_bit_input };
		GSCFG0: 
			dout <= { 1'b0, mode_pan4ch, clksel1, clksel0, mode_expag, mode_8chans, mode_ramro, mode_norom };
		SSTAT:
			dout <= { 4'd0, mc_rdy, sd_wp, sd_det, md_dreq };
		SCTRL:
			dout <= { 2'd0, mc_speed[1], md_halfspeed, mc_speed[0], mc_xrst, mc_ncs, sd_ncs };
		SD_READ:
			dout <= sd_dout;
		SD_RSTR:
			dout <= sd_dout;
		MC_READ:
			dout <= mc_dout;
		DMA_MOD:
			dout <= { 5'd0, dma_module_select };
		DMA_HAD:
			dout <= dma_dout_modules;
		DMA_MAD:
			dout <= dma_dout_modules;
		DMA_LAD:
			dout <= dma_dout_modules;
		DMA_CST:
			dout <= dma_dout_modules;
		default:
			dout <= 8'bXXXXXXXX;
		endcase
	end
	always @(posedge cpu_clock)
	begin
		if( port00_wr==1'b1 ) 
		begin
			if( mode_expag==1'b0 ) 
				mode_pg0[6:0] <= { din[5:0], 1'b0 };
			else 
				mode_pg0[6:0] <= { din[5:0], din[7] };
		end
		if( mode_expag==1'b0 && port00_wr==1'b1 ) 
			mode_pg1[6:0] <= { din[5:0], 1'b1 };
		else if( mode_expag==1'b1 && port10_wr==1'b1 )
			mode_pg1[6:0] <= { din[5:0], din[7] };
	end
	always @(posedge cpu_clock)
	begin
		if( port03_wr==1'b1 )
			data_port_output <= din;
	end
	always @(posedge cpu_clock)
	begin
		if( port09_wr==1'b1 )
			port09_bit5 <= din[5];
	end
	always @(posedge cpu_clock,negedge rst_n)
	begin
		if( rst_n==1'b0 ) 
			{ mode_pan4ch, clksel1, clksel0, mode_expag, mode_8chans, mode_ramro, mode_norom } <= 7'b0110000;
		else 
		begin
			if( port0f_wr == 1'b1 )
			begin
				{ mode_pan4ch, clksel1, clksel0, mode_expag, mode_8chans, mode_ramro, mode_norom } <= din[6:0];
			end
		end
	end
    always @*
    begin
		case( {port02_rd,port03_wr,port0a_wrrd} )
		3'b100:
		begin
			data_bit_output <= 1'b0;
			data_bit_wr <= 1'b1;
		end
		3'b010:
		begin
			data_bit_output <= 1'b1; 
			data_bit_wr <= 1'b1;
		end
		3'b001:
		begin
			data_bit_output <= ~mode_pg0[0];
			data_bit_wr <= 1'b1;
		end
		default:
		begin
			data_bit_output <= 1'bX;
			data_bit_wr <= 1'b0;
		end
    	endcase
    end
	always @*
	begin
		casex( {port05_wrrd,port0b_wrrd} )
		2'b10:
		begin
			command_bit_output <= 1'b0;
			command_bit_wr <= 1'b1;
		end
		2'b01:
		begin
			command_bit_output <= port09_bit5;
			command_bit_wr <= 1'b1;
		end
		default:
		begin
			command_bit_output <= 1'bX;
			command_bit_wr <= 1'b0;
		end
		endcase
	end
	always @*
	begin
		case( a[5:0] ) 
		VOL1:
			volnum <= 3'd0;
		VOL2:
			volnum <= 3'd1;
		VOL3:
			volnum <= 3'd2;
		VOL4:
			volnum <= 3'd3;
		VOL5:
			volnum <= 3'd4;
		VOL6:
			volnum <= 3'd5;
		VOL7:
			volnum <= 3'd6;
		VOL8:
			volnum <= 3'd7;
		default:
			volnum <= 3'bXXX;
		endcase
	end
	always @(posedge cpu_clock)
	begin
		if( memreg_rd ) 
		begin
			snd_wrtoggle <= ~snd_wrtoggle;
			snd_datnvol  <= 1'b1; 
			if( !mode_8chans ) 
				snd_addr <= { 1'b0, a[9:8] };
			else 
				snd_addr <= a[10:8];
			snd_data <= din;
		end
		else if( volports_enabled && port_wr )
		begin
			snd_wrtoggle <= ~snd_wrtoggle;
			snd_datnvol  <= 1'b0; 
			snd_addr <= volnum;
			snd_data <= din;
		end
	end
	assign sd_din = (a[5:0]==SD_RSTR) ? 8'hFF : din;
	assign mc_din = din;
	assign md_din = din;
	assign sd_start = p_sdsnd_wr | p_sdrst_rd;
	assign mc_start = p_mcsnd_wr;
	assign md_start = p_mdsnd_wr;
      always @(posedge cpu_clock, negedge rst_n)
      begin
		if( !rst_n ) 
		begin
			md_halfspeed <= 1'b0;
			mc_speed     <= 2'b01;
			mc_xrst      <= 1'b0;
			mc_ncs       <= 1'b1;
			sd_ncs       <= 1'b1;
		end
		else 
		begin
			if( p_sctrl_wr )
			begin
				if( din[0] )
					sd_ncs       <= din[7];
				if( din[1] )
					mc_ncs       <= din[7];
				if( din[2] )
					mc_xrst      <= din[7];
				if( din[3] )
					mc_speed[0]  <= din[7];
				if( din[4] )
					md_halfspeed <= din[7];
				if( din[5] )
					mc_speed[1]  <= din[7];
			end
		end
      end
	always @(posedge cpu_clock, negedge rst_n)
	begin
		if( !rst_n )
			led <= 1'b0;
		else
		begin
			if( p_ledctr_wr )
				led <= din[0];
			else if( led_toggle )
				led <= ~led;
		end
	end
	always @(posedge cpu_clock, negedge rst_n) 
	begin
		if( !rst_n )
			dma_module_select <= DMA_NONE_SELECTED;
		else if( p_dmamod_wr )
			dma_module_select <= din[2:0];
	end
	always @* dma_din_modules = din; 
	always @* 
	begin
		dma_select_zx = 1'b0;
		case( dma_module_select )
		DMA_MODULE_ZX:
			dma_select_zx = 1'b1;
		endcase
	end
	always @* dma_wrstb = p_dmaports_wr; 
	always @* dma_regsel = a[1:0];
	always @* 
	begin
		case( dma_regsel )
		DMA_MODULE_ZX:
			dma_dout_modules <= dma_dout_zx;
		default:
			dma_dout_modules <= 8'bxxxxxxxx;
		endcase
	end
endmodule
