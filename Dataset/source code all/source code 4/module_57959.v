module vdu (
    input             wb_clk_i,   
    input             wb_rst_i,
    input      [15:0] wb_dat_i,
    output reg [15:0] wb_dat_o,
    input      [19:1] wb_adr_i,
    input             wb_we_i,
    input             wb_tga_i,
    input      [ 1:0] wb_sel_i,
    input             wb_stb_i,
    input             wb_cyc_i,
    output            wb_ack_o,
    output reg [ 1:0] vga_red_o,
    output reg [ 1:0] vga_green_o,
    output reg [ 1:0] vga_blue_o,
    output reg        horiz_sync,
    output reg        vert_sync
  );
  parameter HOR_DISP_END = 10'd639; 
  parameter HOR_SYNC_BEG = 10'd655; 
  parameter HOR_SYNC_END = 10'd751; 
  parameter HOR_SCAN_END = 10'd799; 
  parameter HOR_DISP_CHR = 80;      
  parameter HOR_VIDEO_ON = 10'd7;   
  parameter HOR_VIDEO_OFF = 10'd647; 
  parameter VER_DISP_END = 9'd400;  
  parameter VER_SYNC_BEG = 9'd411;  
  parameter VER_SYNC_END = 9'd413;  
  parameter VER_SCAN_END = 9'd448;  
  parameter VER_DISP_CHR = 5'd25;   
  reg        cursor_on_v;
  reg        cursor_on_h;
  reg        video_on_v;
  reg        video_on_h;
  reg [9:0]  h_count;
  reg [8:0]  v_count;       
  reg [22:0] blink_count;
  wire [11:0] char_addr;
  wire [7:0]  char_data_out;
  reg [3:0] reg_adr;
  reg [6:0] reg_hcursor; 
  reg [4:0] reg_vcursor; 
  reg [3:0] reg_cur_start;
  reg [3:0] reg_cur_end;
  wire      wr_adr;
  wire      wr_reg;
  wire      write;
  wire      wr_hcursor;
  wire      wr_vcursor;
  wire      wr_cur_start;
  wire      wr_cur_end;
  reg [7:0] vga_shift;
  reg [2:0] vga_fg_colour;
  reg [2:0] vga_bg_colour;
  reg       cursor_on;
  wire      cursor_on1;
  reg       video_on;
  wire      video_on1;
  reg   [6:0] col_addr;  
  reg   [4:0] row_addr;  
  reg   [6:0] col1_addr; 
  reg   [4:0] row1_addr; 
  reg   [6:0] hor_addr;  
  reg   [6:0] ver_addr;  
  reg         vga0_we;
  reg         vga0_rw, vga1_rw, vga2_rw, vga3_rw, vga4_rw, vga5_rw;
  reg         vga1_we;
  reg         vga2_we;
  reg         buff_we;
  reg   [7:0] buff_data_in;
  reg         attr_we;
  reg   [7:0] attr_data_in;
  reg  [10:0] buff_addr;
  reg  [10:0] attr0_addr;
  reg         attr0_we;
  reg  [10:0] buff0_addr;
  reg         buff0_we;
  reg  [10:0] attr_addr;
  reg         intense;
  wire  [7:0] vga_data_out;
  wire  [7:0] attr_data_out;
  wire [10:0] vga_addr;  
  wire [15:0] out_data;
  wire        fg_or_bg;
  wire        stb;
  wire        brown_bg;
  wire        brown_fg;
  wire [15:0] status_reg1;
  wire        vh_retrace;
  wire        v_retrace;
  vdu_char_rom char_rom (
    .clk  (wb_clk_i),
    .addr (char_addr),
    .q    (char_data_out)
  );
  vdu_ram_2k_char ram_2k_char (
    .clk   (wb_clk_i),
    .rst   (wb_rst_i),
    .we    (buff_we),
    .addr  (buff_addr),
    .wdata (buff_data_in),
    .rdata (vga_data_out)
  );
  vdu_ram_2k_attr ram_2k_attr (
    .clk   (wb_clk_i),
    .rst   (wb_rst_i),
    .we    (attr_we),
    .addr  (attr_addr),
    .wdata (attr_data_in),
    .rdata (attr_data_out)
  );
  assign video_on1  = video_on_h && video_on_v;
  assign cursor_on1 = cursor_on_h && cursor_on_v;
  assign char_addr  = { vga_data_out, v_count[3:0] };
  assign vga_addr   = { 4'b0, hor_addr} + { ver_addr, 4'b0 };
  assign out_data   = {attr_data_out, vga_data_out};
  assign stb        = wb_stb_i && wb_cyc_i;
  assign fg_or_bg    = vga_shift[7] ^ cursor_on;
  assign brown_fg    = (vga_fg_colour==3'd6) && !intense;
  assign brown_bg    = (vga_bg_colour==3'd6);
  assign write        = wb_tga_i & wb_stb_i & wb_cyc_i & wb_we_i;
  assign wr_adr       = write & wb_sel_i[0];
  assign wr_reg       = write & wb_sel_i[1];
  assign wr_hcursor   = wr_reg & (reg_adr==4'hf);
  assign wr_vcursor   = wr_reg & (reg_adr==4'he);
  assign wr_cur_start = wr_reg & (reg_adr==4'ha);
  assign wr_cur_end   = wr_reg & (reg_adr==4'hb);
  assign v_retrace   = !video_on_v;
  assign vh_retrace  = v_retrace | !video_on_h;
  assign status_reg1 = { 11'b0, v_retrace, 3'b0, vh_retrace };
  assign wb_ack_o    = stb & (wb_tga_i ? 1'b1 : vga5_rw);
  always @(posedge wb_clk_i)
    if(wb_rst_i) begin
        attr0_addr    <= 11'b0;
        attr0_we      <= 1'b0;
        attr_data_in  <= 8'h0;
        buff0_addr    <= 11'b0;
        buff0_we      <= 1'b0;
        buff_data_in  <= 8'h0;
      end
    else begin
        if(stb && !wb_tga_i) begin
            attr0_addr   <= wb_adr_i[11:1];
            buff0_addr   <= wb_adr_i[11:1];
            attr0_we     <= wb_we_i & wb_sel_i[1];
            buff0_we     <= wb_we_i & wb_sel_i[0];
            attr_data_in <= wb_dat_i[15:8];
            buff_data_in <= wb_dat_i[7:0];
          end
      end
  always @(posedge wb_clk_i)
    wb_dat_o <= wb_rst_i ? 16'h0 : (wb_tga_i ? status_reg1
                                 : (vga4_rw ? out_data : wb_dat_o));
  always @(posedge wb_clk_i)
    reg_adr <= wb_rst_i ? 4'h0
      : (wr_adr ? wb_dat_i[3:0] : reg_adr);
  always @(posedge wb_clk_i)
    reg_hcursor <= wb_rst_i ? 7'h0
      : (wr_hcursor ? wb_dat_i[14:8] : reg_hcursor);
  always @(posedge wb_clk_i)
    reg_vcursor <= wb_rst_i ? 5'h0
      : (wr_vcursor ? wb_dat_i[12:8] : reg_vcursor);
  always @(posedge wb_clk_i)
    reg_cur_start <= wb_rst_i ? 4'he
      : (wr_cur_start ? wb_dat_i[11:8] : reg_cur_start);
  always @(posedge wb_clk_i)
    reg_cur_end <= wb_rst_i ? 4'hf
      : (wr_cur_end ? wb_dat_i[11:8] : reg_cur_end);
  always @(posedge wb_clk_i)
    if(wb_rst_i) begin
        h_count     <= 10'b0;
        horiz_sync  <= 1'b1;
        v_count     <= 9'b0;
        vert_sync   <= 1'b1;
        video_on_h  <= 1'b1;
        video_on_v  <= 1'b1;
        cursor_on_h <= 1'b0;
        cursor_on_v <= 1'b0;
        blink_count <= 22'b0;
      end
    else begin
        h_count    <= (h_count==HOR_SCAN_END) ? 10'b0 : h_count + 10'b1;
        horiz_sync <= (h_count==HOR_SYNC_BEG) ? 1'b0  : ((h_count==HOR_SYNC_END) ? 1'b1 : horiz_sync);
        v_count    <= (v_count==VER_SCAN_END && h_count==HOR_SCAN_END) ? 9'b0 : ((h_count==HOR_SYNC_END) ? v_count + 9'b1 : v_count);
        vert_sync  <= (v_count==VER_SYNC_BEG) ? 1'b0 : ((v_count==VER_SYNC_END) ? 1'b1 : vert_sync);
        video_on_h <= (h_count==HOR_VIDEO_ON) ? 1'b1 : ((h_count==HOR_VIDEO_OFF) ? 1'b0 : video_on_h);
        video_on_v <= (v_count==9'h0) ? 1'b1 : ((v_count==VER_DISP_END) ? 1'b0 : video_on_v);
        cursor_on_h <= (h_count[9:3] == reg_hcursor[6:0]);
        cursor_on_v <= (v_count[8:4] == reg_vcursor[4:0]) && (v_count[3:0] >= reg_cur_start) && (v_count[3:0] <= reg_cur_end);
        blink_count <= blink_count + 22'd1;
      end
  always @(posedge wb_clk_i)
    if(wb_rst_i) begin
        vga0_we   <= 1'b0;
        vga0_rw   <= 1'b1;
        row_addr  <= 5'b0;
        col_addr  <= 7'b0;
        vga1_we   <= 1'b0;
        vga1_rw   <= 1'b1;
        row1_addr <= 5'b0;
        col1_addr <= 7'b0;
        vga2_we   <= 1'b0;
        vga2_rw   <= 1'b0;
        vga3_rw   <= 1'b0;
        vga4_rw   <= 1'b0;
        vga5_rw   <= 1'b0;
        ver_addr  <= 7'b0;
        hor_addr  <= 7'b0;
        buff_addr <= 10'b0;
        attr_addr <= 10'b0;
        buff_we   <= 1'b0;
        attr_we   <= 1'b0;
      end
    else begin  
        case (h_count[2:0])  
          3'b000:            
            begin
              vga0_we <= wb_we_i;
              vga0_rw <= stb;
            end
          default:  
            begin
              vga0_we <= 1'b0;
              vga0_rw <= 1'b0;
              col_addr <= h_count[9:3];
              row_addr <= v_count[8:4];
            end
        endcase
        vga1_we <= vga0_we;
        vga1_rw <= vga0_rw;
        row1_addr <= (row_addr < VER_DISP_CHR) ? row_addr : row_addr - VER_DISP_CHR;
        col1_addr <= col_addr;
        vga2_we <= vga1_we;
        vga2_rw <= vga1_rw;
        ver_addr <= { 2'b00, row1_addr } + { row1_addr, 2'b00 }; 
        hor_addr <= col1_addr;
        buff_addr <= vga2_rw ? buff0_addr : vga_addr;
        attr_addr <= vga2_rw ? attr0_addr : vga_addr;
        buff_we   <= vga2_rw ? (buff0_we & vga2_we) : 1'b0;
        attr_we   <= vga2_rw ? (attr0_we & vga2_we) : 1'b0;
        vga3_rw   <= vga2_rw;
        vga4_rw   <= vga3_rw;
        vga5_rw   <= vga4_rw;
      end
  always @(posedge wb_clk_i)
    if(wb_rst_i) begin
        video_on      <= 1'b0;
        cursor_on     <= 1'b0;
        vga_bg_colour <= 3'b000;
        vga_fg_colour <= 3'b111;
        vga_shift     <= 8'b00000000;
        vga_red_o     <= 1'b0;
        vga_green_o   <= 1'b0;
        vga_blue_o    <= 1'b0;
      end
    else begin
        if(h_count[2:0] == 3'b000) begin
            video_on      <= video_on1;
            cursor_on     <= (cursor_on1 | attr_data_out[7]) & blink_count[22];
            vga_fg_colour <= attr_data_out[2:0];
            vga_bg_colour <= attr_data_out[6:4];
            intense       <= attr_data_out[3];
            vga_shift     <= char_data_out;
          end
        else vga_shift <= { vga_shift[6:0], 1'b0 };
        vga_blue_o <= video_on ? (fg_or_bg ? { vga_fg_colour[0], intense } : { vga_bg_colour[0], 1'b0 }) : 2'b0;
        vga_green_o  <= video_on ? (fg_or_bg ? (brown_fg ? 2'b01 : { vga_fg_colour[1], intense })
                     : (brown_bg ? 2'b01 : { vga_bg_colour[1], 1'b0 })) : 2'b0;
        vga_red_o    <= video_on ? (fg_or_bg ? { vga_fg_colour[2], intense } : { vga_bg_colour[2], 1'b0 }) : 2'b0;
      end
endmodule
