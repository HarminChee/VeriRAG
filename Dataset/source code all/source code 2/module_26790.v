`timescale 1 ns / 10 ps
`timescale 1 ns / 10 ps
module mc_arb
  #(
    parameter BYTES    = 16
    )
  (
   input                mclock,
   input                reset_n,
   input [27:0]         dlp_arb_addr,
   input [4:0]          dlp_arb_wcnt,
   input                dlp_arb_req,
   input                line_actv_4,
   input [31:0]         de_arb_addr,
   input [3:0]          de_arb_page,
   input [1:0]          de_arb_cmd,
   input                de_arb_req,
   input [31:0]         z_arb_addr,
   input                empty_de,
   input [66:0]         blend_ctrl_data,
   input                mff_empty,
   input [6:0]          mff_usedw,
   input [4:0]          z_to_arb_in,
   input [22:0]         hst_arb_addr,  
   input [1:0]          hst_arb_page,  
   input	        hst_arb_read,  
   input 	        hst_arb_req,   
   input                crt_arb_req,
   input [4:0]          crt_arb_page,
   input [20:0]         crt_arb_addr,
   input                vga_mode,
   input 		vga_arb_req,
   input [17:0]         vga_arb_addr,
   input                vga_arb_read,
   input [31:0]         tc_address,
   input [5:0]          tc_page,
   input                tc_req,
   output reg           tc_ack,
   input [31:0]         pal_address,
   input                pal_req,
   input                pal_half,
   output reg           pal_ack,
   input		local_ready,
   input		local_rdata_valid,
   input                init_done,
   output reg	[24:0]	local_address,
   output reg		local_write_req,
   output reg		local_read_req,
   output reg		local_burstbegin,
   output reg	[5:0]	local_size,
   output               dlp_gnt,
   output reg           de_gnt,
   output               hst_gnt,
   output               crt_gnt,
   output               vga_gnt,
   output               unload_de,
   output               unload_z,
   output               unload_mff,
   output               unload_hst,
   output reg           push_de,
   output reg           push_crt,
   output reg           push_dlp,
   output reg           push_tex,
   output reg           push_pal,
   output reg           push_hst,
   output reg           push_mff,
   output reg           push_z,
   output               vga_pop,
   output reg           vga_push,
   output reg           mc_dat_pop,
   output [3:0]         dev_sel,
   output reg [66:0]    mff_ctrl_data,
   output reg           mc_busy,
   output reg [3:0]             arb_state,
   output reg [1:0]             current_cmd,
   output reg [4:0]     z_data,
   output reg [2:0] 	   next_dev,
   output [8:0]            requests,
  output [8:0] 		read_dev
   );
  localparam
    READ        = 2'b01,
    WRITE       = 2'b00,
    RMW         = 2'b10,
    CRT         = 4'h0,
    DE          = 4'h1,
    DLP         = 4'h2,
    HOST        = 4'h3,
    TEX         = 4'h4,
    PAL         = 4'h5,
    MFF         = 4'h6,
    VGA         = 4'h7,
    ZDEV        = 4'h8,
    TC_IDLE     = 1'b0,
    TC_WAIT     = 1'b1,
    DE_IDLE     = 1'b0,
    DE_WAIT     = 1'b1,
    INIT        = 4'h0,
    IDLE        = 4'h1,
    WRITE0      = 4'h2,  
    WRITE1      = 4'h3,
    WRITE2      = 4'h4,
    READ_IDLE   = 1'b0,
    READ_COUNT  = 1'b1;
  reg [3:0] 		current_dev;   
  reg [1:0]             de_capt_cmd;   
  reg [5:0]             de_capt_page;  
  reg [31:0]            de_capt_addr;  
  reg [31:0]            de_capt_zaddr; 
  reg [31:0]            current_addr;  
  reg [5:0]             current_page;  
  reg [5:0]             page_count;    
  reg [7:0]             grants;        
  reg                   de_cs, de_ns;  
  reg                   tc_cs, tc_ns;  
  reg                   pal_cs, pal_ns;
  reg                   int_data_avail;
  reg                   int_data_avail_d;
  reg                   tc_int_data_avail;
  reg                   tc_int_data_avail_d;
  reg                   pal_int_data_avail;
  reg                   pal_int_data_avail_d;
  reg [4:0]             unload_pipe;   
  reg                   unload_first, set_first;
  reg [4:0] 		pipe_first;
  reg                   unload_done;   
  reg                   unload_empty;  
  reg                   unload_last_int; 
  reg 			push_read;
  reg [5:0] 		push_count;
  reg [6:0] 		push_countp1;
  reg [8:0] 		push_dev;
  reg                   de_gnt_d;
  reg 			unload_de_int;
  reg 			unload_z_int;
  reg 			unload_hst_int;
  reg 			unload_mff_int;
  reg                   unload_vga_int;
  reg 			hold_de_int;
  reg 			hold_z_int;
  reg 			hold_hst_int;
  reg 			hold_mff_int;
  reg                   hold_vga_int;
  reg 			pop_read;      
  reg 			read_cs;       
  reg 			read_ns;       
  reg [5:0] 		local_count;   
  reg 			load_count;    
  reg                   z_pass;        
  reg                   z_avail;
  reg [4:0]             z_to_arb;
  reg 			pal_half_store;
  wire                  de_gnt_int;    
  wire [5:0] 		read_count;
  wire                  read_empty;
  wire			almost_full;
  wire  [3:0]       	read_usedw;
  wire 			tc_gnt_in;
  wire			tc_gnt_int; 
  wire			pal_gnt_int; 
  assign requests = {
		    1'b0,
	  	    vga_arb_req, 
		    1'b0,
		    pal_int_data_avail_d, 
		    tc_int_data_avail_d, 
		    hst_arb_req, 
		    dlp_arb_req, 
		    int_data_avail_d, 
		    crt_arb_req
		    } & 
		    {8{~unload_done}} & ~grants & {vga_mode, {7{~vga_mode}}};
  assign vga_gnt    = grants[7];
  assign pal_gnt_int= grants[5]; 
  assign tc_gnt_int = grants[4]; 
  assign hst_gnt    = grants[3]; 
  assign dlp_gnt    = grants[2]; 
  assign de_gnt_int = grants[1]; 
  assign crt_gnt    = grants[0];
  always @* begin
    if (vga_mode) unload_empty = ~|unload_pipe & ~unload_vga_int;
    else 	  unload_empty = ~|unload_pipe & ~unload_de_int & ~unload_hst_int & ~hold_de_int & ~hold_hst_int & ~hold_z_int;
    if (current_dev == MFF || current_dev == ZDEV) begin
      mc_dat_pop      = unload_pipe[3] & local_ready;
      local_write_req = unload_pipe[4];
      unload_done     = unload_pipe[4];
    end else begin
      mc_dat_pop      = unload_pipe[0] & local_ready;
      local_write_req = unload_pipe[1];
      unload_done     = unload_pipe[1];
    end
  end 
  always @* begin
    tc_ack            = 1'b0;
    tc_int_data_avail = 1'b0;
    tc_ns             = tc_cs;
    case (tc_cs)
      TC_IDLE: begin
        if (tc_req) begin
          tc_ack = 1'b1;
          tc_ns  = TC_WAIT;
        end else 
          tc_ns  = TC_IDLE;
      end 
      TC_WAIT: begin
        tc_int_data_avail = 1'b1;
        if (tc_gnt_int) begin
	  tc_ns = TC_IDLE;
	  tc_int_data_avail = 1'b0;
        end else
          tc_ns = TC_WAIT;
      end
    endcase 
  end 
  always @* begin
    pal_ack            = 1'b0;
    pal_int_data_avail = 1'b0;
    pal_ns             = pal_cs;
    case (pal_cs)
      TC_IDLE: begin
        if (pal_req) begin
          pal_ack = 1'b1;
          pal_ns  = TC_WAIT;
        end else 
          pal_ns  = TC_IDLE;
      end 
      TC_WAIT: begin
        pal_int_data_avail = 1'b1;
        if (pal_gnt_int) begin
	  pal_ns = TC_IDLE;
	  pal_int_data_avail = 1'b0;
        end else
          pal_ns = TC_WAIT;
      end
    endcase 
  end 
  always @* begin
    de_gnt         = 1'b0;
    int_data_avail = 1'b0;
    de_ns          = de_cs;
    case (de_cs)
      DE_IDLE: begin
        if (de_arb_req) begin
          de_gnt = 1'b1;
          de_ns  = DE_WAIT;
        end else 
          de_ns  = DE_IDLE;
      end 
      DE_WAIT: begin
        int_data_avail = 1'b1;
        if (de_gnt_int) begin
	  de_ns = DE_IDLE;
	  int_data_avail = 1'b0;
        end else
          de_ns = DE_WAIT;
      end
    endcase 
  end 
  always @(posedge mclock, negedge reset_n) begin
    	if (!reset_n) 	  z_to_arb <= 5'h0;
    	else if(de_gnt_d) z_to_arb <= z_to_arb_in;
    end
  always @* begin
    current_addr = 32'h0;
    current_page = 6'h0;
    case (current_dev)
      DE, ZDEV: begin
	if (z_pass && z_to_arb[3]) begin
          if(z_to_arb[2:1] == 2'b00) current_cmd    = WRITE; 
	  else			     current_cmd    = RMW;
          if (BYTES == 32) begin 
            current_addr = {de_capt_zaddr, 1'b0};
            current_page = {2'b0, de_capt_page[4:1]};
          end else if (BYTES == 16) begin 
            current_addr = de_capt_zaddr;
            current_page = de_capt_page;
          end else if (BYTES == 8) begin
            current_addr = de_capt_zaddr>>1;
            current_page = (line_actv_4) ? 6'b0 : {1'b0, de_capt_page,1'b1};
          end else begin
            current_addr = de_capt_zaddr>>2;
            current_page = (line_actv_4) ? 6'b0 : {de_capt_page,2'b11};
          end
	end else begin
          current_cmd    = de_capt_cmd;
          if (BYTES == 32) begin 
            current_addr = {de_capt_addr, 1'b0};
            current_page = {3'b0, de_capt_page[4:1]};
          end else if (BYTES == 16) begin 
            current_addr = de_capt_addr;
            current_page = de_capt_page;
          end else if (BYTES == 8) begin
            current_addr = de_capt_addr>>1;
            current_page = (line_actv_4) ? 6'b0 : {1'b0, de_capt_page,1'b1};
          end else begin
            current_addr = de_capt_addr>>2;
            current_page = (line_actv_4) ? 6'b0 : {de_capt_page,2'b11};
          end
	end
      end
      DLP: begin
        current_cmd  = 2'b1;
        current_addr = dlp_arb_addr;
        if (BYTES == 32) begin
          current_page = 7'h0;
        end else if (BYTES == 16) begin
          current_page = dlp_arb_wcnt;
        end else if (BYTES == 8) begin
          current_page = 7'h1;
        end else begin
          current_page = 7'h3;
        end
      end 
      HOST: begin
        current_cmd    = hst_arb_read;
	current_addr   = hst_arb_addr;
	current_page   = hst_arb_page;
      end
      CRT: begin
        current_cmd    = READ;
	current_addr   = crt_arb_addr;
	current_page   = crt_arb_page;
      end
      VGA: begin
        current_cmd    = vga_arb_read ? READ : WRITE;
	current_addr   = vga_arb_addr >> 1;
	current_page   = 0;
      end
      TEX: begin
        current_cmd    = READ;
	current_addr   = tc_address;
	current_page   = tc_page;
      end
      PAL: begin
        current_cmd    = READ;
	current_addr   = pal_half_store ? ((pal_address) + 32) : 
			 (pal_address);
	current_page   = 6'h1F;
      end
      default: begin
        current_cmd    = 2'b1;
        current_addr = {dlp_arb_addr, 4'b0};
        if (BYTES == 32) begin
          current_page = 7'h0;
        end else if (BYTES == 16) begin
          current_page = 6'h0;
        end else if (BYTES == 8) begin
          current_page = 7'h1;
        end else begin
          current_page = 7'h3;
        end
      end
    endcase 
    next_dev = CRT[2:0];
    casex ({vga_mode, current_dev})
      {1'b1, 4'bxxxx}:     next_dev = VGA[2:0];
      {1'b0, CRT}: begin
	case (1'b1)
	  requests[CRT]:  next_dev = CRT[2:0]; 
	  requests[DLP]:  next_dev = DLP[2:0]; 
	  requests[HOST]: next_dev = HOST[2:0]; 
	  requests[PAL]:  next_dev = PAL[2:0]; 
	  requests[TEX]:  next_dev = TEX[2:0]; 
	  requests[DE]:   next_dev = DE[2:0]; 
	  default:  	  next_dev = CRT[2:0]; 
	endcase
      end
      {1'b0, DLP}: begin
	case (1'b1)
	  requests[CRT]:  next_dev = CRT[2:0]; 
	  requests[HOST]: next_dev = HOST[2:0]; 
	  requests[PAL]:  next_dev = PAL[2:0]; 
	  requests[TEX]:  next_dev = TEX[2:0]; 
	  requests[DE]:   next_dev = DE[2:0]; 
	  requests[DLP]:  next_dev = DLP[2:0]; 
	  default:  	  next_dev = CRT[2:0]; 
	endcase
      end
      {1'b0, HOST}: begin
	case (1'b1)
	  requests[CRT]:  next_dev = CRT[2:0]; 
	  requests[DLP]:  next_dev = DLP[2:0]; 
	  requests[PAL]:  next_dev = PAL[2:0]; 
	  requests[TEX]:  next_dev = TEX[2:0]; 
	  requests[DE]:   next_dev = DE[2:0]; 
	  requests[HOST]: next_dev = HOST[2:0]; 
	  default:  	  next_dev = CRT[2:0]; 
	endcase
      end
      {1'b0, PAL}: begin
	case (1'b1)
	  requests[CRT]:  next_dev = CRT[2:0]; 
	  requests[DLP]:  next_dev = DLP[2:0]; 
	  requests[HOST]: next_dev = HOST[2:0]; 
	  requests[TEX]:  next_dev = TEX[2:0]; 
	  requests[DE]:   next_dev = DE[2:0]; 
	  requests[PAL]:  next_dev = PAL[2:0]; 
	  default:  	  next_dev = CRT[2:0]; 
	endcase
      end
      {1'b0, TEX}: begin
	case (1'b1)
	  requests[CRT]:  next_dev = CRT[2:0]; 
	  requests[DLP]:  next_dev = DLP[2:0]; 
	  requests[HOST]: next_dev = HOST[2:0]; 
	  requests[PAL]:  next_dev = PAL[2:0]; 
	  requests[DE]:   next_dev = DE[2:0]; 
	  requests[TEX]:  next_dev = TEX[2:0]; 
	  default:  	  next_dev = CRT[2:0]; 
	endcase
      end
      {1'b0, DE}, {1'b0, ZDEV}: begin
	case (1'b1)
	  requests[CRT]:  next_dev = CRT[2:0]; 
	  requests[DLP]:  next_dev = DLP[2:0]; 
	  requests[HOST]: next_dev = HOST[2:0]; 
	  requests[PAL]:  next_dev = PAL[2:0]; 
	  requests[TEX]:  next_dev = TEX[2:0]; 
	  requests[DE]:   next_dev = DE[2:0]; 
	  default:  	  next_dev = CRT[2:0]; 
	endcase
      end
      default: begin
	case (1'b1)
	  requests[CRT]:  next_dev = CRT[2:0]; 
	  requests[DLP]:  next_dev = DLP[2:0]; 
	  requests[HOST]: next_dev = HOST[2:0]; 
	  requests[PAL]:  next_dev = PAL[2:0]; 
	  requests[TEX]:  next_dev = TEX[2:0]; 
	  requests[DE]:   next_dev = DE[2:0]; 
	  default:  	  next_dev = CRT[2:0]; 
	endcase
      end
    endcase 
  end 
  assign dev_sel    = current_dev;
  assign unload_de  = (unload_de_int  | hold_de_int)  & local_ready;
  assign unload_z   = (unload_z_int   | hold_z_int)   & local_ready;
  assign unload_mff = (unload_mff_int | hold_mff_int) & local_ready;
  assign unload_hst = (unload_hst_int | hold_hst_int) & local_ready;
  assign vga_pop    = (unload_vga_int | hold_vga_int) & local_ready;
  always @* begin
    load_count = 1'b0;
    pop_read   = 1'b0;
    case (read_cs)
      READ_IDLE: begin
	if (~read_empty) begin
	  pop_read    = 1'b1;
	  read_ns     = READ_COUNT;
	  load_count  = 1'b1;
	end else
	  read_ns     = READ_IDLE;
      end
      READ_COUNT: begin
          if (local_rdata_valid && (local_count == read_count))
	      begin
	          if (~read_empty) begin
	              pop_read    = 1'b1;
	              read_ns     = READ_COUNT;
	              load_count  = 1'b1;
	          end 
	          else read_ns  = READ_IDLE;
      	      end
	  else read_ns  = READ_COUNT;
      end
    endcase 
  end 
  always @(posedge mclock, negedge reset_n)
    if (!reset_n) begin
      pal_half_store <= 1'b0;
    end else begin
      if (pal_ack) pal_half_store <= pal_half;
    end
  always @(posedge mclock, negedge reset_n) begin
    if (!reset_n) begin
	hold_de_int      <= 1'b0;
      hold_z_int      <= 1'b0;
	hold_mff_int     <= 1'b0;
	hold_hst_int     <= 1'b0;
	hold_vga_int     <= 1'b0;
    end 
    else if (local_ready) begin
	hold_de_int      <= 1'b0;
      hold_z_int      <= 1'b0;
	hold_mff_int     <= 1'b0;
	hold_hst_int     <= 1'b0;
	hold_vga_int     <= 1'b0;
    end 
    else begin
	hold_de_int      <= unload_de_int  | hold_de_int;
	hold_z_int       <= unload_z_int   | hold_z_int;
	hold_mff_int     <= unload_mff_int | hold_mff_int;
	hold_hst_int     <= unload_hst_int | hold_hst_int;
	hold_vga_int     <= unload_vga_int | hold_vga_int;
    end 
  end
  always @(posedge mclock, negedge reset_n) begin
    if (!reset_n) begin
      unload_pipe      <= 5'b0;
      pipe_first       <= 1'b0;
    end
    else if (local_ready) begin
	if (current_dev == MFF || current_dev == ZDEV) begin
          unload_pipe <= {unload_pipe[3:0], (unload_de | unload_z)};
	  pipe_first  <= {pipe_first[3:0],  unload_first};
	end 
	else begin
          unload_pipe <= {3'b0, unload_pipe[0], (unload_de | unload_hst | vga_pop)};
          pipe_first  <= {3'b0, pipe_first[0],  unload_first};
	end
    end
  end
  always @(posedge mclock, negedge reset_n) begin
    if      (~reset_n) z_avail <= 1'b0;
    else if (push_z)   z_avail <= 1'b1;
    else if (unload_z) z_avail <= 1'b0;
  end
  always @(posedge mclock, negedge reset_n) begin
    if (!reset_n) begin
      arb_state        <= INIT;
      current_dev      <= CRT;
      grants           <= 8'b0;
      mff_ctrl_data    <= 67'b0;
      de_cs            <= DE_IDLE;
      tc_cs            <= TC_IDLE;
      pal_cs           <= TC_IDLE;
      read_cs          <= READ_IDLE;
      int_data_avail_d <= 1'b0;
      tc_int_data_avail_d <= 1'b0;
      pal_int_data_avail_d <= 1'b0;
      unload_de_int    <= 1'b0;
      unload_z_int     <= 1'b0;
      unload_mff_int   <= 1'b0;
      unload_hst_int   <= 1'b0;
      unload_vga_int   <= 1'b0;
      local_size       <= 6'b0;
      local_address    <= 'b0;
      local_read_req   <= 1'b0;
      local_burstbegin <= 1'b0;
      page_count       <= 6'b0;
      push_read        <= 1'b0;
      push_count       <= 6'b0;
      push_countp1     <= 6'b0;
      push_dev         <= 9'b0;
      de_gnt_d         <= 1'b0;
      unload_first     <= 1'b0;
      push_de          <= 1'b0;
      push_crt         <= 1'b0;
      push_dlp         <= 1'b0;
      push_tex         <= 1'b0;
      push_pal         <= 1'b0;
      push_hst         <= 1'b0;
      push_mff         <= 1'b0;
      mc_busy          <= 1'b0;
      local_count      <= 6'h0;
      z_pass           <= 1'b1;
      set_first        <= 1'b0;
    end else begin 
      unload_first     <= 1'b0;
      grants           <= 8'b0;
      local_read_req   <= 1'b0;
      push_read        <= 1'b0;
      unload_hst_int   <= 1'b0;
      unload_de_int    <= 1'b0;
      unload_z_int     <= 1'b0;
      unload_mff_int   <= 1'b0;
      unload_vga_int   <= 1'b0;
      push_de          <= read_dev[DE]   & local_rdata_valid;
      push_crt         <= read_dev[CRT]  & local_rdata_valid;
      push_dlp         <= read_dev[DLP]  & local_rdata_valid;
      push_tex         <= read_dev[TEX]  & local_rdata_valid;
      push_pal         <= read_dev[PAL]  & local_rdata_valid;
      push_hst         <= read_dev[HOST] & local_rdata_valid;
      push_mff         <= read_dev[MFF]  & local_rdata_valid;
      vga_push         <= read_dev[VGA]  & local_rdata_valid;
      push_z           <= read_dev[ZDEV] & local_rdata_valid;
      read_cs          <= read_ns;
      de_cs            <= de_ns;
      tc_cs            <= tc_ns;
      pal_cs           <= pal_ns;
      de_gnt_d         <= de_gnt;
      int_data_avail_d <= int_data_avail;
      tc_int_data_avail_d <= tc_int_data_avail;
      pal_int_data_avail_d <= pal_int_data_avail;
      if (load_count) 		  local_count <= 6'h0;
      else if (local_rdata_valid) local_count <= local_count + 6'h1;
      if (de_gnt_d) begin
        de_capt_cmd   <= de_arb_cmd;
        de_capt_page  <= de_arb_page;
        de_capt_addr  <= de_arb_addr;
        de_capt_zaddr <= z_arb_addr;
      end
      if ((arb_state == IDLE) && ((current_cmd == READ) || current_cmd == RMW) && !almost_full && local_ready && (requests[current_dev]))
      	 		           			  local_burstbegin <= 1'b1;
      else if (current_dev == MFF || current_dev == ZDEV) local_burstbegin <= pipe_first[3];
      else 		           			  local_burstbegin <= pipe_first[0];
      case (arb_state)
	INIT: if (init_done) arb_state <= IDLE;
	      else arb_state <= INIT;
	IDLE: begin 
	    mc_busy <= de_arb_req || ~empty_de;
            if(requests[current_dev]) begin
                mff_ctrl_data <= blend_ctrl_data;
	        if (current_dev == DE) z_data <= z_to_arb;
	        else z_data <= 5'b0;
	        local_address <= current_addr[24:0];
	      	local_size    <= current_page + 1'b1;
	      	page_count    <= current_page + 1'b1;
	        set_first <= 1'b1;
	      	case (current_cmd)
		    WRITE: begin 
		  	     arb_state     <= WRITE0;
			     if (z_to_arb[3] & z_pass & (current_dev == DE)) current_dev   <= ZDEV;
		             else grants[current_dev] <= 1'b1;
		    end
		    READ: begin 
		        if(!almost_full && local_ready) begin
 		    	    local_read_req      <= 1'b1;
		    	    grants[current_dev] <= 1'b1;
		    	    push_read  		<= 1'b1;
		    	    push_dev   		<= 1'b1 << current_dev;
		    	    push_count 		<= current_page;
		    	    push_countp1 	<= current_page + 7'h1;
		    	    arb_state  		<= IDLE;
		        end
		    end
		    RMW: begin 
		        if(!almost_full && local_ready) begin
 		    	    local_read_req   	<= 1'b1;
		    	    grants[current_dev] <= ~z_to_arb[3] || ~z_pass;
		    	    push_read     	<= 1'b1;
			    if (z_to_arb[3] & z_pass) begin
		    	    	push_dev      <= 'h100;
		  		current_dev   <= ZDEV;
			    end 
			    else begin
		    	    	push_dev      <= 'h40;
		  	    	current_dev   <= MFF;
			    end
		    	    push_count    <= current_page;
		    	    push_countp1  <= current_page + 7'h1;
		    	    arb_state     <= WRITE0;
		  	end
		    end
		    default: arb_state     <= IDLE;
	      	endcase 
            end 
	    else begin
		    current_dev <= next_dev;
		    arb_state   <= IDLE;
	    end
	end 
	WRITE0: begin 
	  if (
	      (!empty_de  && (current_dev == DE)) ||
	      (!empty_de && (z_avail || (z_data[2:1] == 2'b00)) && (current_dev == ZDEV)) ||
	      ((mff_usedw == push_countp1) && (current_dev == MFF) && !mff_empty) || 
	      (current_dev == HOST) || 
	      (current_dev == VGA)
      	     ) begin
	    if (local_ready) begin
	      unload_first <= set_first;
	      set_first    <= 1'b0;
	      unload_de_int  <= ((current_dev == DE) || (current_dev == MFF)) & |page_count & (~z_pass | ~z_data[3]); 
	      unload_z_int  <= ((current_dev == ZDEV)) & |page_count & z_pass;
	      unload_mff_int <= (current_dev == MFF) & |page_count;
	      unload_hst_int <= (current_dev == HOST) & |page_count;
	      unload_vga_int <= (current_dev == VGA) & |page_count;
	      page_count <= page_count - |page_count;
	      if (current_dev == MFF || current_dev == ZDEV) arb_state <= WRITE1;
	      else if (~|page_count) arb_state <= WRITE2;
	    end else arb_state <= WRITE0;
	  end 
	  else arb_state <= WRITE0;
	end 
	WRITE1: begin 
	  unload_de_int  <= ((current_dev == DE) || (current_dev == MFF)) & |page_count & (~z_pass | ~z_data[3]); 
	  unload_z_int   <= (current_dev == ZDEV) & |page_count & z_pass;
	  unload_mff_int <= (current_dev == MFF) & |page_count;
	  unload_hst_int <= (current_dev == HOST) & |page_count;
	  unload_vga_int <= (current_dev == VGA) & |page_count;
	  if (local_ready) begin
	    page_count <= page_count - |page_count;
	    if (unload_pipe[3]) arb_state <= WRITE2;
	    else arb_state <= WRITE1;
	  end 
	  else arb_state <= WRITE1;
	end
	WRITE2: begin 
	  unload_de_int  <= ((current_dev == DE) || (current_dev == MFF)) & |page_count & (~z_pass | ~z_data[3]); 
	  unload_z_int   <= (current_dev == ZDEV) & |page_count & z_pass;
	  unload_mff_int <= (current_dev == MFF) & |page_count;
	  unload_hst_int <= (current_dev == HOST) & |page_count;
	  unload_vga_int <= (current_dev == VGA) & |page_count;
	  if (local_ready) begin
	    page_count <= page_count - |page_count;
	    if (unload_empty) begin
	      if ((z_data[3]  ) & (current_dev != HOST)) z_pass <= ~z_pass;
	        arb_state <= IDLE;
		current_dev <= next_dev; 
	    end
	    else arb_state <= WRITE2;
	  end
	  else arb_state <= WRITE2;
	end
      endcase 
    end 
  end
  sfifo_15x16 u_read
    (
     .data         ({push_dev, push_count}),
     .wrreq        (push_read),
     .rdreq        (pop_read),
     .clock        (mclock),
     .aclr         (~reset_n),
     .q            ({read_dev, read_count}),
     .full         (),
     .empty        (read_empty),
     .usedw        (read_usedw),
     .almost_full  (almost_full)
     );
    `ifdef RTL_SIM
    always @(posedge mclock) begin
	    if(!local_write_req && !local_read_req && local_burstbegin) begin
		    $display("BURST BEGIN ERROR");
		    #10000 $stop;
	    end
    end
    `endif
endmodule
