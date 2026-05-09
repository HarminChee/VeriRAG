module altor32_dcache
( 
    input           clk_i ,
    input           rst_i ,
    input           flush_i ,
    input [31:0]    address_i ,
    output [31:0]   data_o ,
    input [31:0]    data_i ,
    input           we_i ,
    input           stb_i ,
    input [3:0]     sel_i ,
    output          stall_o ,
    output          ack_o ,
    output [31:0]   mem_addr_o ,
    input [31:0]    mem_data_i ,
    output [31:0]   mem_data_o ,
    output [2:0]    mem_cti_o ,
    output          mem_cyc_o ,
    output          mem_stb_o ,
    output          mem_we_o ,
    output [3:0]    mem_sel_o ,
    input           mem_stall_i,
    input           mem_ack_i 
);
parameter CACHE_LINE_SIZE_WIDTH     = 5; 
parameter CACHE_LINE_SIZE_BYTES     = 2 ** CACHE_LINE_SIZE_WIDTH; 
parameter CACHE_LINE_ADDR_WIDTH     = 8; 
parameter CACHE_LINE_WORDS_IDX_MAX  = CACHE_LINE_SIZE_WIDTH - 2; 
parameter CACHE_TAG_ENTRIES         = 2 ** CACHE_LINE_ADDR_WIDTH ; 
parameter CACHE_DSIZE               = CACHE_LINE_ADDR_WIDTH * CACHE_LINE_SIZE_BYTES; 
parameter CACHE_DWIDTH              = CACHE_LINE_ADDR_WIDTH + CACHE_LINE_SIZE_WIDTH - 2; 
parameter CACHE_TAG_WIDTH           = 16; 
parameter CACHE_TAG_LINE_ADDR_WIDTH = CACHE_TAG_WIDTH - 2; 
parameter CACHE_TAG_ADDR_LOW        = CACHE_LINE_SIZE_WIDTH + CACHE_LINE_ADDR_WIDTH;
parameter CACHE_TAG_ADDR_HIGH       = CACHE_TAG_LINE_ADDR_WIDTH + CACHE_LINE_SIZE_WIDTH + CACHE_LINE_ADDR_WIDTH - 1;
parameter CACHE_TAG_DIRTY_BIT       = 14;
parameter CACHE_TAG_VALID_BIT       = 15;
parameter ADDR_NO_CACHE_BIT         = 25;
parameter ADDR_CACHE_BYPASS_BIT     = 31;
parameter FLUSH_INITIAL             = 0;
wire [CACHE_LINE_ADDR_WIDTH-1:0] tag_entry;
wire [CACHE_TAG_WIDTH-1:0]       tag_data_out;
reg  [CACHE_TAG_WIDTH-1:0]       tag_data_in;
reg                              tag_wr;
wire [CACHE_DWIDTH-1:0]          cache_address;
wire [31:0]                      cache_data_r;
reg [31:0]                       cache_data_w;
reg [3:0]                        cache_wr;
wire [31:2]                      cache_update_addr;
wire [31:0]                      cache_update_data_w;
wire [31:0]                      cache_update_data_r;
wire                             cache_update_wr;
reg                              ack;
reg                              fill;
reg                              evict;
wire                             done;
wire [31:0]                      data_r;
reg                              rd_single;
reg [3:0]                        wr_single;
reg                              req_rd;
reg [3:0]                        req_wr;
reg                              req_ack;
reg [31:0]                       req_address;
reg [31:0]                       req_data;
reg                              req_flush;
reg                              req_init;
reg                              flush_single;
wire [31:0]                      line_address;
parameter STATE_IDLE        = 0;
parameter STATE_SINGLE      = 1;
parameter STATE_CHECK       = 2;
parameter STATE_FETCH       = 3;
parameter STATE_WAIT        = 4;
parameter STATE_WAIT2       = 5;
parameter STATE_WRITE       = 6;
parameter STATE_SINGLE_READY= 7;
parameter STATE_EVICTING    = 8;
parameter STATE_UPDATE      = 9;
parameter STATE_FLUSH1      = 10;
parameter STATE_FLUSH2      = 11;
parameter STATE_FLUSH3      = 12;
parameter STATE_FLUSH4      = 13;
reg [3:0] state;
wire [31:0]                      muxed_address = (state == STATE_IDLE) ? address_i : req_address;
assign tag_entry               = muxed_address[CACHE_LINE_ADDR_WIDTH + CACHE_LINE_SIZE_WIDTH - 1:CACHE_LINE_SIZE_WIDTH];
assign cache_address           = {tag_entry, muxed_address[CACHE_LINE_SIZE_WIDTH-1:2]};
assign data_o                  = (state == STATE_SINGLE_READY) ? data_r : cache_data_r;
assign stall_o                 = (state != STATE_IDLE) | req_flush | flush_i;
wire valid                     = tag_data_out[CACHE_TAG_VALID_BIT];
wire dirty                     = tag_data_out[CACHE_TAG_DIRTY_BIT];
wire cacheable                 = ~muxed_address[ADDR_NO_CACHE_BIT] & ~muxed_address[ADDR_CACHE_BYPASS_BIT];
wire addr_hit                  = (req_address[CACHE_TAG_ADDR_HIGH:CACHE_TAG_ADDR_LOW] == tag_data_out[13:0]);
wire hit                       = cacheable & valid & addr_hit & (state == STATE_CHECK);
assign ack_o                   = ack | hit;
assign line_address[31:CACHE_TAG_ADDR_HIGH+1] = {(31-CACHE_TAG_ADDR_HIGH){1'b0}};
assign line_address[CACHE_LINE_ADDR_WIDTH + CACHE_LINE_SIZE_WIDTH - 1:CACHE_LINE_SIZE_WIDTH] = tag_entry;
assign line_address[CACHE_TAG_ADDR_HIGH:CACHE_TAG_ADDR_LOW] = tag_data_out[13:0];
assign line_address[CACHE_LINE_SIZE_WIDTH-1:0] = {CACHE_LINE_SIZE_WIDTH{1'b0}};
wire cache_wr_enable           = (state == STATE_WRITE) ? valid & addr_hit : 1'b1;
reg [3:0] next_state_r;
always @ *
begin
    next_state_r = state;
    case (state)
    STATE_IDLE :
    begin
        if (flush_i | req_flush)
            next_state_r    = STATE_FLUSH2;
        else if (stb_i & ~we_i & ~cacheable)
            next_state_r    = STATE_SINGLE;
        else if (stb_i & ~we_i)
            next_state_r    = STATE_CHECK;
        else if (stb_i & we_i & ~cacheable)
            next_state_r    = STATE_SINGLE;
        else if (stb_i & we_i)
            next_state_r    = STATE_WRITE;
    end         
    STATE_WRITE :
    begin            
        if (valid & addr_hit & dirty)
            next_state_r    = STATE_IDLE;
        else if (valid & addr_hit & ~dirty)
            next_state_r    = STATE_WAIT2;            
        else if (valid & dirty)
            next_state_r    = STATE_EVICTING;
        else
            next_state_r    = STATE_UPDATE;
    end
    STATE_EVICTING:
    begin
        if (done)
        begin
            if (req_rd)
                next_state_r   = STATE_FETCH;
            else
                next_state_r   = STATE_UPDATE;
        end
    end
    STATE_UPDATE:
    begin
        if (done)
            next_state_r    = STATE_WAIT2;
    end            
    STATE_CHECK :
    begin         
        if (valid & addr_hit) 
            next_state_r    = STATE_IDLE;
        else if (valid & dirty)
            next_state_r    = STATE_EVICTING;
        else
            next_state_r    = STATE_FETCH;
    end
    STATE_SINGLE:
    begin
        if (done)
        begin
            if (~req_rd)
                next_state_r    = STATE_SINGLE_READY;
            else if (valid & dirty & addr_hit)
                next_state_r    = STATE_FLUSH4;                           
            else if (valid & addr_hit)
                next_state_r    = STATE_SINGLE_READY;
            else
                next_state_r    = STATE_SINGLE_READY;
        end
    end            
    STATE_FETCH :
    begin
        if (done)
           next_state_r = STATE_WAIT;
    end
    STATE_WAIT :
    begin
        next_state_r    = STATE_WAIT2;
    end    
    STATE_WAIT2 :
    begin
        next_state_r    = STATE_IDLE;
    end            
    STATE_SINGLE_READY :
    begin
        next_state_r    = STATE_IDLE;
    end
    STATE_FLUSH1 :
    begin
        if (req_address[CACHE_LINE_ADDR_WIDTH + CACHE_LINE_SIZE_WIDTH - 1:CACHE_LINE_SIZE_WIDTH] == {CACHE_LINE_ADDR_WIDTH{1'b1}})
            next_state_r    = STATE_WAIT;
        else
            next_state_r    = STATE_FLUSH2;
    end
    STATE_FLUSH2 :
    begin
        next_state_r    = STATE_FLUSH3;
    end
    STATE_FLUSH3 :
    begin
        if (dirty && ~req_init)
            next_state_r    = STATE_FLUSH4;                
        else
        begin
            if (flush_single)
                next_state_r    = STATE_WAIT;
            else
                next_state_r    = STATE_FLUSH1;
        end
    end
    STATE_FLUSH4 :
    begin
        if (done)
        begin
            if (flush_single)
                next_state_r    = STATE_SINGLE_READY;
            else                    
                next_state_r    = STATE_FLUSH1;
        end
    end      
    default:
        ;
   endcase
end
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
        state   <= STATE_IDLE;
   else
        state   <= next_state_r;
end
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        tag_data_in     <= 16'b0;
        tag_wr          <= 1'b0;
   end
   else
   begin
        tag_wr          <= 1'b0;
        case (state)
        STATE_WRITE :
        begin            
            if (valid & addr_hit) 
            begin
                if (~dirty)
                begin
                    tag_data_in  <= tag_data_out;
                    tag_data_in[CACHE_TAG_DIRTY_BIT] <= 1'b1;
                    tag_wr       <= 1'b1;
                end
            end            
            else if (~valid | ~dirty)
            begin
                tag_data_in <= {1'b1, 1'b1, req_address[CACHE_TAG_ADDR_HIGH:CACHE_TAG_ADDR_LOW]};
                tag_wr      <= 1'b1;
            end
        end
        STATE_EVICTING:
        begin
            if (done)
            begin
                tag_data_in <= {1'b1, 1'b0, req_address[CACHE_TAG_ADDR_HIGH:CACHE_TAG_ADDR_LOW]};
                tag_wr      <= 1'b1;
            end
        end
        STATE_UPDATE:
        begin
            if (done)
            begin
                tag_data_in  <= tag_data_out;
                tag_data_in[CACHE_TAG_DIRTY_BIT] <= 1'b1;
                tag_wr       <= 1'b1;  
            end
        end            
        STATE_CHECK :
        begin         
            if (valid & addr_hit)
            begin
            end                 
            else if (~valid | ~dirty)
            begin
                tag_data_in <= {1'b1, 1'b0, req_address[CACHE_TAG_ADDR_HIGH:CACHE_TAG_ADDR_LOW]};
                tag_wr      <= 1'b1;
            end
        end
        STATE_SINGLE:
        begin
            if (done)
            begin
                if (~req_rd)
                begin
                    if (valid & addr_hit)
                    begin
                        tag_data_in  <= tag_data_out;
                        tag_data_in[CACHE_TAG_VALID_BIT] <= 1'b0;
                        tag_wr       <= 1'b1;
                    end         
                end                
                else if (valid & ~dirty & addr_hit)
                begin
                    tag_data_in  <= tag_data_out;
                    tag_data_in[CACHE_TAG_VALID_BIT] <= 1'b0;
                    tag_wr       <= 1'b1;                  
                end
            end
        end            
        STATE_FLUSH3 :
        begin
            if (~dirty | req_init)
            begin
                tag_data_in  <= 16'b0;
                tag_data_in[CACHE_TAG_VALID_BIT] <= 1'b0;
                tag_wr       <= 1'b1;
            end
        end
        STATE_FLUSH4 :
        begin
            if (done)
            begin
                tag_data_in  <= 16'b0;
                tag_data_in[CACHE_TAG_VALID_BIT] <= 1'b0;
                tag_data_in[CACHE_TAG_DIRTY_BIT] <= 1'b0;
                tag_wr       <= 1'b1;
            end
        end          
        default:
            ;
       endcase
   end
end
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        req_address     <= 32'h00000000;
        req_data        <= 32'h00000000;
        req_ack         <= 1'b0;
        req_wr          <= 4'h0;
        req_rd          <= 1'b0;
        req_flush       <= 1'b1;
        req_init        <= FLUSH_INITIAL;
   end
   else
   begin
        if (flush_i)
            req_flush       <= 1'b1;
        case (state)
        STATE_IDLE :
        begin
            if (flush_i | req_flush)
            begin
                req_address <= 32'h00000000;
                req_flush   <= 1'b0;
                req_ack     <= 1'b0;
            end            
            else if (stb_i & ~we_i & ~cacheable)
            begin
                req_address <= address_i;
                req_address[ADDR_CACHE_BYPASS_BIT] <= 1'b0;
                req_rd      <= 1'b1;
                req_wr      <= 4'b0;
                req_ack     <= 1'b1;
            end
            else if (stb_i & ~we_i)
            begin
                req_address <= address_i;
                req_rd      <= 1'b1;
                req_wr      <= 4'b0;
                req_ack     <= 1'b1;
            end                
            else if (stb_i & we_i & ~cacheable)
            begin
                req_address <= address_i;
                req_address[ADDR_CACHE_BYPASS_BIT] <= 1'b0;
                req_data    <= data_i;
                req_wr      <= sel_i;
                req_rd      <= 1'b0;                    
                req_ack     <= 1'b1;     
            end
            else if (stb_i & we_i)
            begin
                req_address <= address_i;
                req_data    <= data_i;
                req_wr      <= sel_i;
                req_rd      <= 1'b0;
                req_ack     <= 1'b0;
            end              
        end
        STATE_FLUSH1 :
        begin
            if (req_address[CACHE_LINE_ADDR_WIDTH + CACHE_LINE_SIZE_WIDTH - 1:CACHE_LINE_SIZE_WIDTH] == {CACHE_LINE_ADDR_WIDTH{1'b1}})
            begin
                req_ack <= 1'b0;
                req_init <= 1'b0;
            end
            else
            begin
                req_address[CACHE_LINE_ADDR_WIDTH + CACHE_LINE_SIZE_WIDTH - 1:CACHE_LINE_SIZE_WIDTH] <=
                req_address[CACHE_LINE_ADDR_WIDTH + CACHE_LINE_SIZE_WIDTH - 1:CACHE_LINE_SIZE_WIDTH] + 1;
            end
        end      
        default:
            ;
       endcase
   end
end
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        cache_data_w    <= 32'h00000000;
        cache_wr        <= 4'b0;
   end
   else
   begin
        cache_wr        <= 4'b0;
        case (state)
        STATE_IDLE:
        begin
            if (stb_i & we_i & cacheable & ~(flush_i | req_flush))
            begin
                cache_data_w <= data_i;
                cache_wr     <= sel_i;
            end    
        end
        STATE_UPDATE:
        begin
            if (done)
            begin
                cache_data_w <= req_data;
                cache_wr     <= req_wr;
            end
        end            
        default:
            ;
       endcase
   end
end
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        wr_single       <= 4'h0;
        rd_single       <= 1'b0;
        flush_single    <= 1'b0;
        fill            <= 1'b0;
        evict           <= 1'b0;
   end
   else
   begin
        fill            <= 1'b0;
        evict           <= 1'b0;
        wr_single       <= 4'b0;
        rd_single       <= 1'b0;
        case (state)
            STATE_IDLE :
            begin
                if (flush_i | req_flush)
                begin
                    flush_single<= 1'b0;
                end            
                else if (stb_i & ~we_i & ~cacheable)
                begin
                    rd_single     <= 1'b1;
                end             
                else if (stb_i & we_i & ~cacheable)
                begin
                    wr_single     <= sel_i;
                end         
            end         
            STATE_WRITE :
            begin            
                if (valid & addr_hit)
                begin
                end
                else if (valid & dirty)
                begin
                    evict       <= 1'b1;
                end                
                else
                begin
                    fill        <= 1'b1;
                end
            end
            STATE_EVICTING:
            begin
                if (done)
                begin
                    fill        <= 1'b1;
                end
            end        
            STATE_CHECK :
            begin         
                if (valid & addr_hit)
                begin
                end
                else if (valid & dirty)
                begin
                    evict       <= 1'b1;
                end                     
                else
                begin
                    fill        <= 1'b1;
                end
            end
            STATE_SINGLE:
            begin
                if (done)
                begin
                    if (~req_rd)
                    begin
                    end                
                    else if (valid & dirty & addr_hit)
                    begin
                        evict       <= 1'b1;
                        flush_single<= 1'b1;
                    end
                end
            end           
            STATE_FLUSH3 :
            begin
                if (dirty)
                begin
                    evict       <= 1'b1;
                end
            end      
            default:
                ;
           endcase
   end
end
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
        ack     <= 1'b0;
   else
   begin
        ack     <= 1'b0;
        case (state)
        STATE_IDLE :
        begin
            if (~(flush_i | req_flush) & stb_i & we_i & cacheable)
                ack <= 1'b1;
        end         
        STATE_SINGLE:
        begin
            if (done)
            begin
                if (~req_rd)
                    ack         <= req_ack;                    
                else if (valid & dirty & addr_hit)
                begin
                end
                else if (valid & addr_hit)
                    ack         <= req_ack;                        
                else
                    ack         <= req_ack;                    
            end
        end
        STATE_WAIT2 :
        begin
            ack     <= req_ack;
        end            
        STATE_FLUSH4 :
        begin
            if (done & flush_single)
                ack     <= req_ack;
        end          
        default:
            ;
       endcase
   end
end
altor32_dcache_mem_if
#(
    .CACHE_LINE_SIZE_WIDTH(CACHE_LINE_SIZE_WIDTH),
    .CACHE_LINE_WORDS_IDX_MAX(CACHE_LINE_WORDS_IDX_MAX)
)
u_mem_if
( 
    .clk_i(clk_i),
    .rst_i(rst_i),
    .address_i(muxed_address),
    .data_i(req_data),
    .data_o(data_r),
    .fill_i(fill),
    .evict_i(evict),
    .evict_addr_i(line_address),
    .rd_single_i(rd_single),
    .wr_single_i(wr_single),
    .done_o(done),
    .cache_addr_o(cache_update_addr),
    .cache_data_o(cache_update_data_w),
    .cache_data_i(cache_update_data_r),
    .cache_wr_o(cache_update_wr),    
    .mem_addr_o(mem_addr_o),
    .mem_data_i(mem_data_i),
    .mem_data_o(mem_data_o),
    .mem_cti_o(mem_cti_o),
    .mem_cyc_o(mem_cyc_o),
    .mem_stb_o(mem_stb_o),
    .mem_we_o(mem_we_o),
    .mem_sel_o(mem_sel_o),
    .mem_stall_i(mem_stall_i),
    .mem_ack_i(mem_ack_i)
);
altor32_ram_sp  
#(
    .WIDTH(CACHE_TAG_WIDTH),
    .SIZE(CACHE_LINE_ADDR_WIDTH)
) 
u1_tag_mem
(
    .clk_i(clk_i), 
    .dat_o(tag_data_out), 
    .dat_i(tag_data_in), 
    .adr_i(tag_entry), 
    .wr_i(tag_wr)
);
altor32_ram_dp  
#(
    .WIDTH(8),
    .SIZE(CACHE_DWIDTH)
) 
u2_data_mem0
(
    .aclk_i(clk_i), 
    .aadr_i(cache_address), 
    .adat_o(cache_data_r[7:0]), 
    .adat_i(cache_data_w[7:0]),     
    .awr_i(cache_wr[0] & cache_wr_enable),
    .bclk_i(clk_i), 
    .badr_i(cache_update_addr[CACHE_DWIDTH+2-1:2]), 
    .bdat_o(cache_update_data_r[7:0]), 
    .bdat_i(cache_update_data_w[7:0]),     
    .bwr_i(cache_update_wr)
);
altor32_ram_dp  
#(
    .WIDTH(8),
    .SIZE(CACHE_DWIDTH)
) 
u2_data_mem1
(
    .aclk_i(clk_i), 
    .aadr_i(cache_address), 
    .adat_o(cache_data_r[15:8]), 
    .adat_i(cache_data_w[15:8]),     
    .awr_i(cache_wr[1] & cache_wr_enable),
    .bclk_i(clk_i), 
    .badr_i(cache_update_addr[CACHE_DWIDTH+2-1:2]), 
    .bdat_o(cache_update_data_r[15:8]), 
    .bdat_i(cache_update_data_w[15:8]),     
    .bwr_i(cache_update_wr)   
);
altor32_ram_dp  
#(
    .WIDTH(8),
    .SIZE(CACHE_DWIDTH)
) 
u2_data_mem2
(
    .aclk_i(clk_i), 
    .aadr_i(cache_address), 
    .adat_o(cache_data_r[23:16]), 
    .adat_i(cache_data_w[23:16]),     
    .awr_i(cache_wr[2] & cache_wr_enable),
    .bclk_i(clk_i), 
    .badr_i(cache_update_addr[CACHE_DWIDTH+2-1:2]), 
    .bdat_o(cache_update_data_r[23:16]), 
    .bdat_i(cache_update_data_w[23:16]),     
    .bwr_i(cache_update_wr)       
);
altor32_ram_dp  
#(
    .WIDTH(8),
    .SIZE(CACHE_DWIDTH)
) 
u2_data_mem3
(
    .aclk_i(clk_i), 
    .aadr_i(cache_address), 
    .adat_o(cache_data_r[31:24]), 
    .adat_i(cache_data_w[31:24]),     
    .awr_i(cache_wr[3] & cache_wr_enable),
    .bclk_i(clk_i), 
    .badr_i(cache_update_addr[CACHE_DWIDTH+2-1:2]), 
    .bdat_o(cache_update_data_r[31:24]), 
    .bdat_i(cache_update_data_w[31:24]),     
    .bwr_i(cache_update_wr)       
);
endmodule
