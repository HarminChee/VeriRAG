module dram_control
                   #( parameter         n_words = 40
                    , parameter         w_width = 27
                    , parameter         wbits = $clog2(n_words)
                    )
                    ( input             clk
                    , input             pcie_perstn
                    , input             pcie_ready
                    , input             user_resetn
                    , output            ctrl_reset_n
                    , input     [6:0]   command
                    , output    [13:0]  g_mem_addr
                    , output            g_mem_wren
                    , output            g_mem_rden
                    , output    [w_width-1:0]   g_mem_datai
                    , input     [w_width-1:0]   g_mem_datao
                    , input     [25-wbits:0]    addr_direct
                    , output    [12:0]  ddr3_a          
                    , output    [2:0]   ddr3_ba         
                    , output            ddr3_ck_p       
                    , output            ddr3_ck_n       
                    , output            ddr3_cke        
                    , output            ddr3_csn        
                    , output    [3:0]   ddr3_dm         
                    , output            ddr3_rasn       
                    , output            ddr3_casn       
                    , output            ddr3_wen        
                    , output            ddr3_rstn       
                    , inout     [31:0]  ddr3_dq         
                    , inout     [3:0]   ddr3_dqs_p      
                    , inout     [3:0]   ddr3_dqs_n      
                    , output            ddr3_odt        
                    , input             ddr3_oct_rzq    
                    , input             clkin_100_p
                    , output            idle
                    );
    localparam fifodepth = 1 << wbits;
    wire mem_ready, mrdata_valid, pll_locked, cal_success, mpfe_reset_n, global_reset_n, init_done, mrden, mwren;
    assign mem_ready = '1;
    assign mrdata_valid = '1;
    reg [31:0] mrdata_reg;
    wire [31:0] mrdata, mwdata;
    assign mrdata = mrdata_reg;
    reg [w_width-1:0] gdata_reg, gdata_next;
    assign mwdata[31:w_width] = '0;
    assign ctrl_reset_n = pcie_perstn;
    assign g_mem_datai = gdata_reg;
    reg [1:0] state_reg, state_next;
    parameter ST_IDLE   = 2'b00;
    parameter ST_ADDR   = 2'b01;
    parameter ST_READ   = 2'b10;
    parameter ST_WRITE  = 2'b11;
    wire inST_IDLE  = state_reg == ST_IDLE;
    wire inST_ADDR  = state_reg == ST_ADDR;     
    wire inST_READ  = state_reg == ST_READ;     
    wire inST_WRITE = state_reg == ST_WRITE;    
    reg [wbits-1:0] count_reg, count_next;
    wire last_count = count_reg == (n_words - 1);
    wire count_is_3 = count_reg == {{(wbits-2){1'b0}},2'b11};
    parameter SEG_ADDR      = 2'b11;
    parameter SEG_PRELOAD   = 2'b00;
    parameter SEG_STORE     = 2'b10;
    reg [1:0] saddr_reg, saddr_next;
    reg [5:0] command_reg, command_next;
    assign g_mem_addr = {command_reg[4:0],{(7-wbits){1'b0}},saddr_reg,count_reg};
    reg grden_reg, grden_next, gwren_reg, gwren_next;
    assign g_mem_wren = gwren_reg;
    assign g_mem_rden = grden_reg;
    wire empty;
    assign mwren = inST_READ;
    wire rdreq = (inST_READ & mem_ready) | (inST_ADDR & count_is_3);
    reg wrreq_reg, wrreq_next;
    reg mrden_reg, mrden_next;
    reg begin_reg, begin_next;
    reg [25-wbits:0] maddr_reg, maddr_next;
    wire [25:0] maddr = {maddr_reg,{(wbits){1'b0}}};
    assign idle = inST_IDLE;
    wire do_direct_write = &command[6:2];
    always_comb begin
        command_next = command_reg;
        state_next = state_reg;
        count_next = count_reg;
        saddr_next = saddr_reg;
        grden_next = grden_reg;
        gwren_next = '0;
        gdata_next = gdata_reg;
        mrden_next = mrden_reg;
        begin_next = '0;
        maddr_next = maddr_reg;
        wrreq_next = wrreq_reg;
        case (state_reg)
            ST_IDLE: begin
                if (do_direct_write) begin
                    command_next = {6'b111100};
                    maddr_next = addr_direct;
                    state_next = ST_WRITE;
                    count_next = '0;
                    mrden_next = '1;
                    begin_next = '1;
                end else if (command[6]) begin
                    state_next = ST_ADDR;
                    command_next = command[5:0];
                    grden_next = '1;
                    count_next = {{(wbits-1){1'b0}},~command[5]};
                    saddr_next = SEG_ADDR;
                end else if (command[5]) begin
                    command_next = {1'b0,command[4:0]};
                    count_next = '0;
                    saddr_next = SEG_PRELOAD;
                    state_next = ST_WRITE;
                end
            end
            ST_ADDR: begin
                if (saddr_reg == SEG_ADDR) begin
                    count_next = '0;
                    if (~command_reg[5]) begin
                        saddr_next = SEG_STORE;
                    end else begin
                        saddr_next = SEG_PRELOAD;
                        grden_next = '0;
                    end
                end else if (~wrreq_reg) begin
                    maddr_next = g_mem_datao[25-wbits:0];
                    if (~command_reg[5]) begin
                        wrreq_next = '1;
                        count_next = count_reg + 1'b1;
                    end else begin
                        state_next = ST_WRITE;
                        count_next = '0;
                        mrden_next = '1;
                        begin_next = '1;
                    end
                end else begin
                    count_next = count_reg + 1'b1;
                    if (count_is_3) begin
                        state_next = ST_READ;
                        begin_next = '1;
                    end
                end
            end
            ST_READ: begin
                if (grden_reg) begin
                    if (last_count) begin
                        grden_next = '0;
                        count_next = '0;
                    end else begin
                        count_next = count_reg + 1'b1;
                    end
                end else begin
                    wrreq_next = '0;
                    if (mem_ready & empty) begin
                        state_next = ST_IDLE;
                    end
                end
            end
            ST_WRITE: begin
                if (command_reg[5]) begin
                    if (mrden_reg) begin
                        if (mem_ready) begin
                            mrden_next = 1'b0;
                        end
                    end else begin
                        if (mrdata_valid) begin
                            gdata_next = mrdata[w_width-1:0];
                            gwren_next = '1;
                        end
                        if (gwren_reg) begin
                            if (last_count) begin
                                state_next = ST_IDLE;
                                count_next = '0;
                            end else begin
                                count_next = count_reg + 1'b1;
                            end
                        end
                    end
                end else begin
                    if (gwren_reg) begin
                        if (last_count) begin
                            state_next = ST_IDLE;
                            count_next = '0;
                        end else begin
                            gdata_next = '0;
                            gwren_next = '1;
                            count_next = count_reg + 1'b1;
                        end
                    end else begin
                        gdata_next = {{(w_width-1){1'b0}},1'b1};
                        gwren_next = '1;
                        count_next = '0;
                    end
                end
            end
        endcase
    end
    always_ff @(posedge clk or negedge ctrl_reset_n) begin
        if (~ctrl_reset_n) begin
            command_reg     <= '0;
            state_reg       <= '0;
            count_reg       <= '0;
            saddr_reg       <= '0;
            grden_reg       <= '0;
            gwren_reg       <= '0;
            gdata_reg       <= '0;
            mrden_reg       <= '0;
            begin_reg       <= '0;
            maddr_reg       <= '0;
            wrreq_reg       <= '0;
            mrdata_reg      <= '0;
        end else begin
            command_reg     <= command_next;
            state_reg       <= state_next;
            count_reg       <= count_next;
            saddr_reg       <= saddr_next;
            grden_reg       <= grden_next;
            gwren_reg       <= gwren_next;
            gdata_reg       <= gdata_next;
            mrden_reg       <= mrden_next;
            begin_reg       <= begin_next;
            maddr_reg       <= maddr_next;
            wrreq_reg       <= wrreq_next;
            mrdata_reg      <= mrdata_reg + 1'b1;
        end
    end
    scfifo         #( .add_ram_output_register      ("ON")
                    , .intended_device_family       ("Arria V")
                    , .lpm_hint                     ("RAM_BLOCK_TYPE=MLAB")
                    , .lpm_numwords                 (fifodepth)
                    , .lpm_showahead                ("OFF")
                    , .lpm_type                     ("scfifo")
                    , .lpm_width                    (w_width)
                    , .lpm_widthu                   (wbits)
                    , .overflow_checking            ("ON")
                    , .underflow_checking           ("ON")
                    , .use_eab                      ("ON")
                    ) gfifo
                    ( .clock                        (clk)
                    , .aclr                         (~ctrl_reset_n)
                    , .sclr                         (inST_IDLE)
                    , .q                            (mwdata[w_width-1:0])
                    , .rdreq                        (rdreq)
                    , .empty                        (empty)
                    , .data                         (g_mem_datao)
                    , .wrreq                        (wrreq_reg)
                    , .full                         ()
                    , .usedw                        ()
                    , .almost_full                  ()
                    , .almost_empty                 ()
                    );
endmodule
