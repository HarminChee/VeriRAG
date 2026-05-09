module micro_bench #(parameter TXHDR_WIDTH=61, RXHDR_WIDTH=18, DATA_WIDTH =512)
(
    clk,                              
    reset_n,                          
    rb2cf_C0RxHdr,                    
    rb2cf_C0RxData,                   
    rb2cf_C0RxWrValid,                
    rb2cf_C0RxRdValid,                
    rb2cf_C0RxCfgValid,               
    rb2cf_C0RxUMsgValid,              
    rb2cf_C0RxIntrValid,                
    rb2cf_C1RxHdr,                    
    rb2cf_C1RxWrValid,                
    rb2cf_C1RxIntrValid,                
    cf2ci_C0TxHdr,                    
    cf2ci_C0TxRdValid,                
    cf2ci_C1TxHdr,                    
    cf2ci_C1TxData,                   
    cf2ci_C1TxWrValid,                
    cf2ci_C1TxIntrValid,              
    ci2cf_C0TxAlmFull,                
    ci2cf_C1TxAlmFull,                
    ci2cf_InitDn                      
);
    input                        clk;                  
    input                        reset_n;              
    input [RXHDR_WIDTH-1:0]      rb2cf_C0RxHdr;        
    input [DATA_WIDTH -1:0]      rb2cf_C0RxData;       
    input                        rb2cf_C0RxWrValid;    
    input                        rb2cf_C0RxRdValid;    
    input                        rb2cf_C0RxCfgValid;   
    input                        rb2cf_C0RxUMsgValid;  
    input                        rb2cf_C0RxIntrValid;    
    input [RXHDR_WIDTH-1:0]      rb2cf_C1RxHdr;        
    input                        rb2cf_C1RxWrValid;    
    input                        rb2cf_C1RxIntrValid;    
    output [TXHDR_WIDTH-1:0]     cf2ci_C0TxHdr;        
    output                       cf2ci_C0TxRdValid;    
    output [TXHDR_WIDTH-1:0]     cf2ci_C1TxHdr;        
    output [DATA_WIDTH -1:0]     cf2ci_C1TxData;       
    output                       cf2ci_C1TxWrValid;    
    output                       cf2ci_C1TxIntrValid;  
    input                        ci2cf_C0TxAlmFull;    
    input                        ci2cf_C1TxAlmFull;    
    input                        ci2cf_InitDn;         
    assign cf2ci_C1TxIntrValid = 'b0;
    localparam       MICRO_BENCH         = 128'h2015_1013_900d_beef_a000_b000_c000_d000;
    localparam       VERSION             = 16'h0001;
    localparam       WrThru              = 4'h1;
    localparam       WrLine              = 4'h2;
    localparam       RdLine              = 4'h4;
    localparam       WrFence             = 4'h5;
    localparam      RSP_CSR              = 4'h0;
    localparam      RSP_WRITE            = 4'h1;
    localparam      RSP_READ             = 4'h4;
    localparam      DEF_SRC_ADDR         = 32'h0400_0000;           
    localparam      DEF_DST_ADDR         = 32'h0800_0000;           
    localparam      DEF_DSM_BASE         = 32'h04ff_ffff;           
    localparam      CSR_AFU_DSM_BASEL    = 16'h1a00;                 
    localparam      CSR_AFU_DSM_BASEH    = 16'h1a04;                 
    localparam      CSR_SRC_ADDR         = 16'h1a20;                 
    localparam      CSR_DST_ADDR         = 16'h1a24;                 
    localparam      CSR_CTL              = 16'h1a2c;                 
    localparam      CSR_DATA_SIZE        = 16'h1a30;                 
    localparam      CSR_LOOP_NUM         = 16'h1a34;                 
    localparam      DSM_AFU_ID           = 32'h0;                   
    localparam      DSM_STATUS           = 32'h40;                  
    reg     [DATA_WIDTH-1:0]        cf2ci_C1TxData;
    reg     [TXHDR_WIDTH-1:0]       cf2ci_C1TxHdr;
    reg                             cf2ci_C1TxWrValid;
    reg     [TXHDR_WIDTH-1:0]       cf2ci_C0TxHdr;
    reg                             cf2ci_C0TxRdValid;
    reg                             dsm_base_valid;
    reg                             dsm_base_valid_q;
    reg                             afuid_updtd;
    reg                             task_completed;
    reg                             task_completed_d;
    reg     [63:0]                  cr_dsm_base;            
    reg     [31:0]                  cr_src_address;         
    reg     [31:0]                  cr_dst_address;         
    reg     [31:0]                  cr_ctl  = 0;            
    reg     [31:0]                  cr_data_size;           
    reg     [31:0]                  cr_loop_num;            
    wire                            test_go = cr_ctl[1];    
    reg     [31:0]                  RdAddrOffset;
    reg     [13:0]                  RdReqId;
    wire    [3:0]                   rdreq_type = RdLine;
    reg     [DATA_WIDTH-1:0]        RdData;
    reg     [31:0]                  WrAddrOffset;
    reg     [13:0]                  WrReqId;
    wire    [3:0]                   wrreq_type = WrLine;
    reg     [DATA_WIDTH-1:0]        WrData;
    wire    [31:0]                  ds_afuid_address = dsm_offset2addr(DSM_AFU_ID,cr_dsm_base);     
    wire    [31:0]                  ds_stat_address = dsm_offset2addr(DSM_STATUS,cr_dsm_base);      
    wire                            re2xy_go = test_go & afuid_updtd & ci2cf_InitDn;                
    reg                             WrHdr_valid;                                                    
    reg                             RdHdr_valid;                                                    
    always @(posedge clk)                                              
    begin                                                                   
        if(!reset_n)
        begin
            cr_dsm_base     <= DEF_DSM_BASE;
            cr_src_address  <= DEF_SRC_ADDR;
            cr_dst_address  <= DEF_DST_ADDR;
            cr_ctl          <= 'b0;
            cr_data_size    <= 'h4000;
            cr_loop_num     <= 'b1;
            dsm_base_valid  <= 'b0;
        end
        else
        begin  
            if(rb2cf_C0RxCfgValid)
                case({rb2cf_C0RxHdr[13:0],2'b00})         
                    CSR_CTL          :   cr_ctl             <= rb2cf_C0RxData[31:0];
                endcase
            if(~test_go) 
            begin
                if(rb2cf_C0RxCfgValid)
                case({rb2cf_C0RxHdr[13:0],2'b00})         
                    CSR_SRC_ADDR:        cr_src_address     <= rb2cf_C0RxData[31:0];
                    CSR_DST_ADDR:        cr_dst_address     <= rb2cf_C0RxData[31:0];
                    CSR_AFU_DSM_BASEH:   cr_dsm_base[63:32] <= rb2cf_C0RxData[31:0];
                    CSR_AFU_DSM_BASEL:begin
                                         cr_dsm_base[31:0]  <= rb2cf_C0RxData[31:0];
                                         dsm_base_valid     <= 'b1;
                                      end
                    CSR_DATA_SIZE:       cr_data_size       <= rb2cf_C0RxData[31:0];
                    CSR_LOOP_NUM:        cr_loop_num        <= rb2cf_C0RxData[31:0];
                endcase
            end
        end
    end
    reg [31:0] cache_line_counter; 
    reg [31:0] cache_line_counter_d;
    reg [31:0] integer_counter;
    reg [31:0] integer_counter_d;
    reg [DATA_WIDTH-1:0] final_result;
    reg [DATA_WIDTH-1:0] final_result_d;
    reg [2:0]  cur_state;
    reg [2:0]  next_state;
    localparam RESET = 'd0;
    localparam IDLE  = 'd1;
    localparam WAIT  = 'd2;
    localparam CALC  = 'd3;
    localparam WRITE = 'd4;
    localparam DONE  = 'd5;
    always @ (posedge clk) 
    begin
        if (!reset_n)
        begin
            cache_line_counter <= 'b0;
            integer_counter    <= 'b0;
            final_result       <= {(DATA_WIDTH/32){32'h900dbeef}};
            cur_state          <= RESET;
        end
        else
        begin
            cache_line_counter <= cache_line_counter_d;
            integer_counter    <= integer_counter_d;
            final_result       <= final_result_d;
            cur_state          <= next_state;
        end
    end
    always @ (*)
    begin
        next_state           = cur_state;
        case(cur_state)                             
            RESET:   
            begin
              if(re2xy_go) 
                next_state = IDLE; 
            end
            IDLE:
            begin
              if(!ci2cf_C0TxAlmFull) 
                next_state = WAIT;
            end
            WAIT:
            begin
              if(rb2cf_C0RxRdValid) 
                next_state = CALC;
            end
            CALC:
            begin
              if(integer_counter == 'd16 && cache_line_counter == cr_data_size)
                next_state = WRITE;
              if(integer_counter == 'd16 && cache_line_counter != cr_data_size)
                next_state = IDLE;
            end
            WRITE:
            begin
              if(!ci2cf_C1TxAlmFull) 
                next_state = DONE;
            end
        endcase
    end
    always @ (*) 
    begin
        cache_line_counter_d = cache_line_counter;
        integer_counter_d    = integer_counter;
        final_result_d       = final_result;
        RdHdr_valid          = 'b0;
        RdAddrOffset         = 'b0;
        RdReqId              = 'b0;
        WrHdr_valid          = 'b0;
        WrAddrOffset         = 'b0;
        WrReqId              = 'b0;
        WrData               = 'b0;
        task_completed_d     = 'b0;
        case(cur_state)                             
            IDLE:
            begin
              RdHdr_valid    = 'b1;
              RdAddrOffset   = cache_line_counter;
              RdReqId        = 'b0; 
            end
            WAIT:
            begin
              if(rb2cf_C0RxRdValid) 
              begin
                cache_line_counter_d = cache_line_counter + 'b1;  
                integer_counter_d    = 'd16;                       
              end
            end
            CALC:
            begin
              if(integer_counter != 'd16)
              begin
                integer_counter_d = integer_counter + 'b1;
              end
              else
              begin
                final_result_d = final_result ^ RdData;
              end
            end
            WRITE:
            begin
              WrHdr_valid    = 'b1;
              WrAddrOffset   = 'b0;
              WrReqId        = 'b0;
              WrData         = final_result;
              if(!ci2cf_C1TxAlmFull) 
                task_completed_d = 'b1;
            end
        endcase
    end
    wire [31:0]             RdAddr  = cr_src_address ^ RdAddrOffset;
    wire [TXHDR_WIDTH-1:0]  RdHdr   = {
                                        5'h00,                          
                                        rdreq_type,                     
                                        6'h00,                          
                                        RdAddr,                         
                                        RdReqId                         
                                      };
    wire [31:0]             WrAddr  = cr_dst_address ^ WrAddrOffset;
    wire [TXHDR_WIDTH-1:0]  WrHdr   = {
                                        5'h00,                          
                                        wrreq_type,                     
                                        6'h00,                          
                                        WrAddr,                         
                                        WrReqId                         
                                      };
    always @(posedge clk)
    begin
        if(!reset_n)
        begin
            afuid_updtd             <= 'b0;
            cf2ci_C1TxHdr           <= 'b0;
            cf2ci_C1TxWrValid       <= 'b0;
            cf2ci_C1TxData          <= 'b0;
            cf2ci_C0TxHdr           <= 'b0;
            cf2ci_C0TxRdValid       <= 'b0;
            dsm_base_valid_q        <= 'b0;
            task_completed          <= 'b0;
        end
        else
        begin 
            cf2ci_C1TxHdr           <= 'b0;
            cf2ci_C1TxWrValid       <= 'b0;
            cf2ci_C1TxData          <= 'b0;
            cf2ci_C0TxHdr           <= 'b0;
            cf2ci_C0TxRdValid       <= 'b0;
            dsm_base_valid_q        <= dsm_base_valid;
            task_completed          <= task_completed_d;
            if(ci2cf_C1TxAlmFull==0)
            begin
                if( ci2cf_InitDn && dsm_base_valid_q && !afuid_updtd )
                begin
                    afuid_updtd             <= 1;
                    cf2ci_C1TxHdr           <= {
                                                    5'h0,                      
                                                    WrLine,                    
                                                    6'h00,                     
                                                    ds_afuid_address,          
                                                    14'h3ffe                   
                                               };                
                    cf2ci_C1TxWrValid       <= 1;
                    cf2ci_C1TxData          <= {    368'h0,                    
                                                    VERSION ,                  
                                                    MICRO_BENCH                 
                                               };
                end
                else if (re2xy_go)  
                begin
                    if(task_completed == 'b1) 
                    begin
                        cf2ci_C1TxWrValid   <= 1'b1;
                        cf2ci_C1TxHdr       <= {
                                                    5'h0,
                                                    WrLine,
                                                    6'h00,
                                                    ds_stat_address,
                                                    14'h3fff
                                               };
                        cf2ci_C1TxData      <= 'b1; 
                    end
                    else if( WrHdr_valid )                                          
                    begin                                                               
                        cf2ci_C1TxHdr     <= WrHdr;
                        cf2ci_C1TxWrValid <= 1'b1;
                        cf2ci_C1TxData    <= WrData;
                    end
                end 
            end 
            if(  re2xy_go 
              && RdHdr_valid && !ci2cf_C0TxAlmFull )                                
            begin                                                                   
                cf2ci_C0TxHdr      <= RdHdr;
                cf2ci_C0TxRdValid  <= 'b1;
            end
            if(cf2ci_C1TxWrValid)
                $display("*Req Type: %x \t Addr: %x \n Data: %x", cf2ci_C1TxHdr[55:52], cf2ci_C1TxHdr[45:14], cf2ci_C1TxData);
            if(cf2ci_C0TxRdValid)
                $display("*Req Type: %x \t Addr: %x", cf2ci_C0TxHdr[55:52], cf2ci_C0TxHdr[45:14]);
        end
    end
    always @ (posedge clk) 
    begin
        if (!reset_n)
        begin
          RdData <= 'b0;
        end
        else
        begin
          if (rb2cf_C0RxRdValid)
            RdData <= rb2cf_C0RxData;
        end
    end
    function automatic [31:0] dsm_offset2addr;
        input    [9:0]  offset_b;
        input    [63:0] base_b;
        begin
            dsm_offset2addr = base_b[37:6] + offset_b[9:6];
        end
    endfunction
endmodule
