`timescale 1ns / 100ps
module QMFIR_uart_top_corrected_clk(
   uart_tx,
   uart_rx, 
   clk, 
   arst_n
   );
   output         uart_tx;
   input          uart_rx;
   input          clk;
   input          arst_n;
   wire           arst_n;
   wire [15:0]    MEMDAT;
   wire           uart_rst_n;
   reg            init_rst_n;
   reg            delay;
   wire           reg_we;             
   wire [13:0]    uart_addr;         
   wire [31:0]    uart_dout;         
   wire           uart_mem_re;       
   wire           uart_mem_we;       
   wire [23:0]    uart_mem_i;
   reg [23:0]     uart_reg_i;    
   wire [15:0]    ESCR;
   wire [15:0]    WPTR;
   wire [15:0]    ICNT;
   wire [15:0]    FREQ;
   wire [15:0]    OCNT;
   wire [15:0]    FCNT;
   wire [31:0]    firin;
   wire [15:0]    MEMDATR1;
   wire [15:0]    MEMDATI1;
   wire [15:0]    MEMDATR2;
   wire [15:0]    MEMDATI2;
   wire [15:0]    MEMDATR3;
   wire [15:0]    MEMDATI3;
   wire [15:0]    RealOut1;
   wire [15:0]    RealOut2;
   wire [15:0]    RealOut3;
   wire [15:0]    ImagOut1;
   wire [15:0]    ImagOut2;
   wire [15:0]    ImagOut3;
   wire [9:0]     mem_addr1;
   wire [9:0]     mem_addr2;
   wire [9:0]     mem_addr3;  
   wire [11:0]    bramin_addr;
   reg            START;
   wire           DataValid;
   assign arst = ~arst_n;
   assign arst1 = ESCR[0];
   assign uart_rst_n = arst_n & init_rst_n;
   QMFIR_uart_if uart_(
           .uart_dout      (uart_dout[31:0]),
           .uart_addr      (uart_addr[13:0]),
           .uart_mem_we    (uart_mem_we),
           .uart_mem_re    (uart_mem_re),
           .reg_we         (reg_we),
           .uart_tx        (uart_tx),
           .uart_mem_i     (uart_mem_i[23:0]),
           .uart_reg_i     (uart_reg_i[23:0]),
           .clk            (clk),
           .arst_n         (uart_rst_n),
           .uart_rx        (uart_rx));   
   iReg ireg_ (
               .ESCR(ESCR),
               .WPTR(WPTR),
               .ICNT(ICNT),
               .FREQ(FREQ),
               .OCNT(OCNT),
               .FCNT(FCNT),
               .clk(clk),
               .arst(arst),
               .idata(uart_dout[15:0]),
               .iaddr(uart_addr),
               .iwe(reg_we),
               .FIR_WE(DataValid),
               .WFIFO_WE(uart_mem_we)
                );
   BRAM_larg bramin_(
                     .doutb(firin), 
                     .clka(clk),
                     .clkb(clk),
                     .addra(bramin_addr[11:0]), 
                     .addrb(FCNT[11:0]), 
                     .dina(uart_dout),  
                     .wea(uart_mem_we));
   QM_FIR QM_FIR(
                 .RealOut1               (RealOut1),
                 .RealOut2               (RealOut2), 
                 .RealOut3               (RealOut3), 
                 .ImagOut1               (ImagOut1), 
                 .ImagOut2               (ImagOut2), 
                 .ImagOut3               (ImagOut3),
                 .DataValid              (DataValid),
                 .CLK                    (clk), 
                 .ARST                   (arst1), 
                 .InputValid             (START), 
                 .dsp_in0                (firin[31:24]), 
                 .dsp_in1                (firin[23:16]), 
                 .dsp_in2                (firin[15:8]), 
                 .dsp_in3                (firin[7:0]), 
                 .newFreq                (FREQ[14]),
                 .freq                   (FREQ[6:0]));
   BRAM BRAM1_ (
        .doutb({MEMDATI1[15:0],MEMDATR1[15:0]}),
        .clka(clk),
        .clkb(clk),
        .addra(WPTR[6:0]),
        .addrb(mem_addr1[6:0]),
        .dina({ImagOut1[15:0],RealOut1[15:0]}),
        .wea(DataValid));
   BRAM BRAM2_ (
        .doutb({MEMDATI2[15:0],MEMDATR2[15:0]}),
        .clka(clk),
        .clkb(clk),
        .addra(WPTR[6:0]),
        .addrb(mem_addr2[6:0]),
        .dina({ImagOut2[15:0],RealOut2[15:0]}),
        .wea(DataValid));
   BRAM BRAM3_ (
        .doutb({MEMDATI3[15:0],MEMDATR3[15:0]}),
        .clka(clk),
        .clkb(clk),
        .addra(WPTR[6:0]),
        .addrb(mem_addr3[6:0]),
        .dina({ImagOut3[15:0],RealOut3[15:0]}),
        .wea(DataValid));
   always @ (posedge clk or posedge arst)
     if (arst !=  1'b0)
       START = 1'b0;
     else begin
             if (ESCR[3]) begin
                init_rst_n <= 0;    
                START = ESCR[3];    
             end
             else begin
                init_rst_n <= 1;
                START = 1'b0;
             end
        end
    assign bramin_addr[11:0] = {(12){uart_mem_we}} & uart_addr[11:0];
   always @ (ESCR or FCNT or FREQ or ICNT or OCNT or WPTR or uart_addr)
     case (uart_addr[2:0])
       3'h1: uart_reg_i = {uart_addr[7:0], ESCR[15:0]};
       3'h2: uart_reg_i = {uart_addr[7:0], WPTR[15:0]};
       3'h3: uart_reg_i = {uart_addr[7:0], ICNT[15:0]};
       3'h4: uart_reg_i = {uart_addr[7:0], FREQ[15:0]};
       3'h5: uart_reg_i = {uart_addr[7:0], OCNT[15:0]};
       3'h6: uart_reg_i = {uart_addr[7:0], FCNT[15:0]};
     endcase 
   assign mem_addr1[6:0] = ((uart_addr[13:11] == 3'h1) | (uart_addr[13:11] == 3'h2)) ? uart_addr[6:0] : 7'b111_1111;
   assign mem_addr2[6:0] = ((uart_addr[13:11] == 3'h3) | (uart_addr[13:11] == 3'h4)) ? uart_addr[6:0] : 7'b111_1111;
   assign mem_addr3[6:0] = ((uart_addr[13:11] == 3'h5) | (uart_addr[13:11] == 3'h6)) ? uart_addr[6:0] : 7'b111_1111;
   assign MEMDAT[15:0] = (MEMDATR1[15:0] & {16{uart_addr[13:11] == 3'h1}}) | 
             (MEMDATI1[15:0] & {16{uart_addr[13:11] == 3'h2}}) | 
             (MEMDATR2[15:0] & {16{uart_addr[13:11] == 3'h3}}) | 
             (MEMDATI2[15:0] & {16{uart_addr[13:11] == 3'h4}}) | 
             (MEMDATR3[15:0] & {16{uart_addr[13:11] == 3'h5}}) | 
             (MEMDATI3[15:0] & {16{uart_addr[13:11] == 3'h6}});
   assign uart_mem_i[23:0] = {1'b0,uart_addr[13:11],uart_addr[3:0], MEMDAT[15:0]};
endmodule