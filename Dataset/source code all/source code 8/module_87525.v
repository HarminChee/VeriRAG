`timescale 1 ns/ 100 ps
`timescale 1 ns/ 100 ps
module h_sync(
        clk,                    
        rst,                    
        HSYNC,                  
        H_DE,                   
        vsync_rst,              
        h_bp_cnt_tc,    
        h_bp_cnt_tc2,   
        h_pix_cnt_tc,   
        h_pix_cnt_tc2   
);
        input                   clk;
        input                   rst;
        output                  vsync_rst;
        output                  HSYNC;
        output                  H_DE;
        output                  h_bp_cnt_tc;
        output                  h_bp_cnt_tc2;
        output                  h_pix_cnt_tc;
        output                  h_pix_cnt_tc2; 
        reg                             vsync_rst;
        reg                             HSYNC;
        reg                             H_DE;
        reg [0:6]               h_p_cnt;        
        reg [0:5]               h_bp_cnt;       
        reg [0:10]              h_pix_cnt;      
        reg [0:3]               h_fp_cnt;       
        reg                             h_p_cnt_ce;
        reg                             h_bp_cnt_ce;
        reg                             h_pix_cnt_ce;
        reg                             h_fp_cnt_ce;
        reg                             h_p_cnt_clr;
        reg                             h_bp_cnt_clr;
        reg                             h_pix_cnt_clr;
        reg                             h_fp_cnt_clr;
        reg                             h_p_cnt_tc;
        reg                             h_bp_cnt_tc;
        reg                             h_bp_cnt_tc2;
        reg                             h_pix_cnt_tc;
        reg                             h_pix_cnt_tc2;
        reg                             h_fp_cnt_tc;
        parameter [0:4] SET_COUNTERS = 5'b00001;
        parameter [0:4] PULSE            = 5'b00010;
        parameter [0:4] BACK_PORCH       = 5'b00100;
        parameter [0:4] PIXEL            = 5'b01000;
        parameter [0:4] FRONT_PORCH      = 5'b10000;
        reg [0:4]               HSYNC_cs ;
        reg [0:4]               HSYNC_ns;
        always @(posedge clk) begin
                if (rst) begin
                        HSYNC_cs = SET_COUNTERS;
                        vsync_rst = 1;
                end
                else begin
                        HSYNC_cs = HSYNC_ns;
                        vsync_rst = 0;
                end
        end
        always @(HSYNC_cs or h_p_cnt_tc or h_bp_cnt_tc or h_pix_cnt_tc or h_fp_cnt_tc) 
        begin 
                case (HSYNC_cs)
                SET_COUNTERS: begin
                        h_p_cnt_ce = 0;
                        h_p_cnt_clr = 1;
                        h_bp_cnt_ce = 0;
                        h_bp_cnt_clr = 1;
                        h_pix_cnt_ce = 0;
                        h_pix_cnt_clr = 1;
                        h_fp_cnt_ce = 0;
                        h_fp_cnt_clr = 1;
                        HSYNC = 1;
                        H_DE = 0;
                        HSYNC_ns = PULSE;
                end
                PULSE: begin
                        h_p_cnt_ce = 1;
                h_p_cnt_clr = 0;
                        h_bp_cnt_ce = 0;
                        h_bp_cnt_clr = 1;
                        h_pix_cnt_ce = 0;
                h_pix_cnt_clr = 1;
                        h_fp_cnt_ce = 0;
                        h_fp_cnt_clr = 1;
                HSYNC = 0;
                        H_DE = 0;
                if (h_p_cnt_tc == 0) HSYNC_ns = PULSE;                     
                        else HSYNC_ns = BACK_PORCH;
                end
                BACK_PORCH: begin
                        h_p_cnt_ce = 0;
                        h_p_cnt_clr = 1;
                        h_bp_cnt_ce = 1;
                        h_bp_cnt_clr = 0;
                        h_pix_cnt_ce = 0;
                h_pix_cnt_clr = 1;
                        h_fp_cnt_ce = 0;
                        h_fp_cnt_clr = 1;
                        HSYNC = 1;
                        H_DE = 0;
                        if (h_bp_cnt_tc == 0) HSYNC_ns = BACK_PORCH;                                                       
                        else HSYNC_ns = PIXEL;
                end
                PIXEL: begin
                        h_p_cnt_ce = 0;
                        h_p_cnt_clr = 1;
                        h_bp_cnt_ce = 0;
                        h_bp_cnt_clr = 1;
                        h_pix_cnt_ce = 1;
                h_pix_cnt_clr = 0;
                        h_fp_cnt_ce = 0;
                        h_fp_cnt_clr = 1;
                        HSYNC = 1;
                        H_DE = 1;
                        if (h_pix_cnt_tc == 0) HSYNC_ns = PIXEL;                                                           
                        else HSYNC_ns = FRONT_PORCH;
        end
                FRONT_PORCH: begin
                        h_p_cnt_ce = 0;
                        h_p_cnt_clr = 1;
                        h_bp_cnt_ce = 0;
                        h_bp_cnt_clr = 1;
                        h_pix_cnt_ce = 0;
                h_pix_cnt_clr = 1;
                        h_fp_cnt_ce = 1;
                        h_fp_cnt_clr = 0;
                        HSYNC = 1;      
                        H_DE = 0;
                        if (h_fp_cnt_tc == 0) HSYNC_ns = FRONT_PORCH;                                                      
                        else HSYNC_ns = PULSE;
                end
                default: begin
                        h_p_cnt_ce = 0;
                        h_p_cnt_clr = 1;
                        h_bp_cnt_ce = 0;
                        h_bp_cnt_clr = 1;
                        h_pix_cnt_ce = 0;
                h_pix_cnt_clr = 1;
                        h_fp_cnt_ce = 1;
                        h_fp_cnt_clr = 0;
                        HSYNC = 1;      
                        H_DE = 0;
                        HSYNC_ns = SET_COUNTERS;
                end
                endcase
        end
        always @(posedge clk)
        begin
                if (h_p_cnt_clr) begin
                        h_p_cnt = 7'b0;
                        h_p_cnt_tc = 0;
                end
                else begin
                        if (h_p_cnt_ce) begin
                                if (h_p_cnt == 94) begin
                                        h_p_cnt = h_p_cnt + 1;
                                        h_p_cnt_tc = 1;
                                end
                                else begin
                                        h_p_cnt = h_p_cnt + 1;
                                        h_p_cnt_tc = 0;
                                end
                        end
                end
        end
        always @(posedge clk )
        begin
                if (h_bp_cnt_clr) begin
                        h_bp_cnt = 6'b0;
                        h_bp_cnt_tc = 0;
                        h_bp_cnt_tc2 = 0;
                end
                else begin
                        if (h_bp_cnt_ce) begin
                                if (h_bp_cnt == 45) begin
                                        h_bp_cnt = h_bp_cnt + 1;
                                        h_bp_cnt_tc2 = 1;
                                        h_bp_cnt_tc = 0;
                                end
                                else if (h_bp_cnt == 46) begin
                                        h_bp_cnt = h_bp_cnt + 1;
                                        h_bp_cnt_tc = 1;
                                        h_bp_cnt_tc2 = 0;
                                end
                                else begin
                                        h_bp_cnt = h_bp_cnt + 1;
                                        h_bp_cnt_tc = 0;
                                        h_bp_cnt_tc2 = 0;
                                end
                        end
                end
        end
        always @(posedge clk)
        begin
                if (h_pix_cnt_clr) begin
                        h_pix_cnt = 11'b0;
                        h_pix_cnt_tc = 0;
                        h_pix_cnt_tc2 = 0;
                end
                else begin
                        if (h_pix_cnt_ce) begin
                                if (h_pix_cnt == 637) begin
                                        h_pix_cnt = h_pix_cnt + 1;
                                        h_pix_cnt_tc2 = 1;
                                end
                                else if (h_pix_cnt == 638) begin
                                        h_pix_cnt = h_pix_cnt + 1;
                                        h_pix_cnt_tc = 1;
                                end
                                else begin
                                        h_pix_cnt = h_pix_cnt + 1;
                                        h_pix_cnt_tc = 0;
                                        h_pix_cnt_tc2 = 0;
                                end
                        end     
                end
        end
        always @(posedge clk)
        begin
                if (h_fp_cnt_clr) begin
                        h_fp_cnt = 5'b0;
                        h_fp_cnt_tc = 0;
                end
                else begin
                        if (h_fp_cnt_ce) begin
                                if (h_fp_cnt == 14) begin
                                        h_fp_cnt = h_fp_cnt + 1;
                                        h_fp_cnt_tc = 1;
                                end
                                else begin
                                        h_fp_cnt = h_fp_cnt + 1;
                                        h_fp_cnt_tc = 0;
                                end
                        end
                end
        end
endmodule
