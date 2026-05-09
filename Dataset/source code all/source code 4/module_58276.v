module altor32_dcache_mem_if
( 
    input               clk_i , 
    input               rst_i , 
    input [31:0]        address_i ,
    input [31:0]        data_i ,
    output reg [31:0]   data_o ,
    input               fill_i ,
    input               evict_i ,
    input  [31:0]       evict_addr_i ,
    input               rd_single_i ,
    input [3:0]         wr_single_i ,
    output reg          done_o ,
    output reg [31:2]   cache_addr_o ,
    output reg [31:0]   cache_data_o ,
    input      [31:0]   cache_data_i ,
    output reg          cache_wr_o ,
    output reg [31:0]   mem_addr_o ,
    input [31:0]        mem_data_i ,
    output reg [31:0]   mem_data_o ,
    output reg [2:0]    mem_cti_o ,
    output reg          mem_cyc_o ,
    output reg          mem_stb_o ,
    output reg          mem_we_o ,
    output reg [3:0]    mem_sel_o ,
    input               mem_stall_i,
    input               mem_ack_i 
);
parameter CACHE_LINE_SIZE_WIDTH     = 5;                         
parameter CACHE_LINE_WORDS_IDX_MAX  = CACHE_LINE_SIZE_WIDTH - 2; 
reg [31:CACHE_LINE_SIZE_WIDTH]  line_address;
reg [CACHE_LINE_WORDS_IDX_MAX-1:0] response_idx;
reg [CACHE_LINE_WORDS_IDX_MAX-1:0]  request_idx;
wire [CACHE_LINE_WORDS_IDX_MAX-1:0] next_request_idx = request_idx + 1'b1;
reg [CACHE_LINE_WORDS_IDX_MAX-1:0]  cache_idx;
wire [CACHE_LINE_WORDS_IDX_MAX-1:0] next_cache_idx = cache_idx + 1'b1;
parameter STATE_IDLE        = 0;
parameter STATE_FETCH       = 1;
parameter STATE_WRITE_SETUP = 2;
parameter STATE_WRITE       = 3;
parameter STATE_WRITE_WAIT  = 4;
parameter STATE_MEM_SINGLE  = 5;
parameter STATE_FETCH_WAIT  = 6;
reg [3:0] state;
reg [3:0] next_state_r;
always @ *
begin
    next_state_r = state;
    case (state)
    STATE_IDLE :
    begin
        if (evict_i)
            next_state_r    = STATE_WRITE_SETUP;
        else if (fill_i)
            next_state_r    = STATE_FETCH;
        else if (rd_single_i | (|wr_single_i))
            next_state_r    = STATE_MEM_SINGLE;
    end
    STATE_FETCH :
    begin
        if (~mem_stall_i && request_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
            next_state_r    = STATE_FETCH_WAIT;
    end
    STATE_FETCH_WAIT:
    begin
        if (mem_ack_i && response_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
            next_state_r = STATE_IDLE;
    end  
    STATE_WRITE_SETUP :
        next_state_r    = STATE_WRITE;
    STATE_WRITE :
    begin
        if (~mem_stall_i && request_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
            next_state_r = STATE_WRITE_WAIT;
        else if (~mem_stall_i | ~mem_stb_o)
            next_state_r = STATE_WRITE_SETUP;
    end
    STATE_WRITE_WAIT:
    begin
        if (mem_ack_i && response_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
            next_state_r = STATE_IDLE;
    end            
    STATE_MEM_SINGLE:
    begin
        if (mem_ack_i)
            next_state_r  = STATE_IDLE;
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
        line_address    <= {32-CACHE_LINE_SIZE_WIDTH{1'b0}};
        done_o          <= 1'b0;
        data_o          <= 32'h00000000;
   end
   else
   begin
        done_o          <= 1'b0;
        case (state)
            STATE_IDLE :
            begin
                if (evict_i)
                    line_address <= evict_addr_i[31:CACHE_LINE_SIZE_WIDTH];
                else if (fill_i)
                    line_address <= address_i[31:CACHE_LINE_SIZE_WIDTH];
            end
            STATE_WRITE_WAIT,
            STATE_FETCH_WAIT:
            begin
                if (mem_ack_i)
                begin
                    if (response_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
                        done_o      <= 1'b1;
                end
            end            
            STATE_MEM_SINGLE:
            begin
                if (mem_ack_i)
                begin
                    data_o      <= mem_data_i;
                    done_o      <= 1'b1;
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
        cache_addr_o    <= 30'h00000000;
        cache_data_o    <= 32'h00000000;
        cache_wr_o      <= 1'b0;
        cache_idx       <= {CACHE_LINE_WORDS_IDX_MAX{1'b0}};
   end
   else
   begin
        cache_wr_o      <= 1'b0;
        case (state)
            STATE_IDLE :
            begin
                cache_idx       <= {CACHE_LINE_WORDS_IDX_MAX{1'b0}};
                if (evict_i)
                begin
                    cache_addr_o  <= {evict_addr_i[31:CACHE_LINE_SIZE_WIDTH], {CACHE_LINE_WORDS_IDX_MAX{1'b0}}};
                end
            end
            STATE_FETCH, 
            STATE_FETCH_WAIT:
            begin
                if (mem_ack_i)
                begin
                    cache_addr_o    <= {line_address, cache_idx};
                    cache_data_o    <= mem_data_i;
                    cache_wr_o      <= 1'b1;
                    cache_idx       <= next_cache_idx;
                end
            end
            STATE_WRITE_SETUP:
            begin
            end
            STATE_WRITE,
            STATE_WRITE_WAIT:
            begin
                if (~mem_stall_i | ~mem_stb_o)
                begin
                    cache_addr_o <= {line_address, next_cache_idx};
                    cache_idx    <= next_cache_idx;
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
        mem_addr_o      <= 32'h00000000;
        mem_data_o      <= 32'h00000000;
        mem_sel_o       <= 4'h0;
        mem_cti_o       <= 3'b0;
        mem_stb_o       <= 1'b0;
        mem_we_o        <= 1'b0;
        request_idx     <= {CACHE_LINE_WORDS_IDX_MAX{1'b0}};
   end
   else
   begin
        if (~mem_stall_i)
        begin
            mem_stb_o   <= 1'b0;
            if (mem_cti_o == 3'b111)
            begin
                mem_data_o      <= 32'h00000000;
                mem_sel_o       <= 4'h0;
                mem_cti_o       <= 3'b0;
                mem_stb_o       <= 1'b0;
                mem_we_o        <= 1'b0;            
            end
        end
        case (state)
            STATE_IDLE :
            begin                
                request_idx     <= {CACHE_LINE_WORDS_IDX_MAX{1'b0}};
                if (evict_i)
                begin
                end
                else if (fill_i)
                begin
                    mem_addr_o   <= {address_i[31:CACHE_LINE_SIZE_WIDTH], {CACHE_LINE_SIZE_WIDTH{1'b0}}};
                    mem_data_o   <= 32'h00000000;
                    mem_sel_o    <= 4'b1111;
                    mem_cti_o    <= 3'b010;
                    mem_stb_o    <= 1'b1;
                    mem_we_o     <= 1'b0;
                    request_idx  <= next_request_idx;
                end                
                else if (rd_single_i)
                begin
                    mem_addr_o   <= address_i;
                    mem_data_o   <= 32'h00000000;
                    mem_sel_o    <= 4'b1111;
                    mem_cti_o    <= 3'b111;
                    mem_stb_o    <= 1'b1;
                    mem_we_o     <= 1'b0; 
                end
                else if (|wr_single_i)
                begin
                    mem_addr_o   <= address_i;
                    mem_data_o   <= data_i;
                    mem_sel_o    <= wr_single_i;
                    mem_cti_o    <= 3'b111;
                    mem_stb_o    <= 1'b1;
                    mem_we_o     <= 1'b1; 
                end
            end
            STATE_FETCH :
            begin
                if (~mem_stall_i)
                begin
                    mem_addr_o <= {line_address, request_idx, 2'b00};
                    mem_stb_o  <= 1'b1;
                    if (request_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
                        mem_cti_o <= 3'b111;
                    request_idx <= next_request_idx;
                end
            end
            STATE_WRITE :
            begin
                if (~mem_stall_i | ~mem_stb_o)
                begin
                    mem_addr_o   <= {line_address, request_idx, 2'b00};
                    mem_data_o   <= cache_data_i;
                    mem_sel_o    <= 4'b1111;
                    mem_stb_o    <= 1'b1;
                    mem_we_o     <= 1'b1;
                    if (request_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
                        mem_cti_o <= 3'b111;
                    else
                        mem_cti_o <= 3'b010;
                    request_idx <= next_request_idx;
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
        response_idx    <= {CACHE_LINE_WORDS_IDX_MAX{1'b0}};
   else
   begin
        case (state)
            STATE_IDLE :
            begin
                response_idx    <= {CACHE_LINE_WORDS_IDX_MAX{1'b0}};         
            end
            STATE_FETCH,
            STATE_FETCH_WAIT :
            begin
                if (mem_ack_i)
                    response_idx <= response_idx + 1'b1;
            end
            STATE_WRITE,
            STATE_WRITE_SETUP,
            STATE_WRITE_WAIT:
            begin
                if (mem_ack_i)
                    response_idx <= response_idx + 1'b1;
            end
            default:
                ;
           endcase
   end
end
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
        mem_cyc_o       <= 1'b0;
   else
   begin
        case (state)
            STATE_IDLE :
            begin
                if (evict_i)
                begin
                end
                else if (fill_i)
                    mem_cyc_o    <= 1'b1;
                else if (rd_single_i)
                    mem_cyc_o    <= 1'b1;
                else if (|wr_single_i)
                    mem_cyc_o    <= 1'b1;
            end
            STATE_FETCH :
            begin
                if (mem_ack_i && response_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
                    mem_cyc_o   <= 1'b0;
            end
            STATE_WRITE :
            begin
                mem_cyc_o    <= 1'b1;
            end            
            STATE_WRITE_WAIT,
            STATE_FETCH_WAIT:
            begin
                if (mem_ack_i && response_idx == {CACHE_LINE_WORDS_IDX_MAX{1'b1}})
                    mem_cyc_o   <= 1'b0;
            end            
            STATE_MEM_SINGLE:
            begin
                if (mem_ack_i)
                    mem_cyc_o   <= 1'b0;
            end        
            default:
                ;
           endcase
   end
end
endmodule
