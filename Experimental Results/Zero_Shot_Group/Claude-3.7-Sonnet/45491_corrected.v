`timescale 1ns / 1ps
module AXI_DDR2_MIG(
      input         CLK,                
      input         CLK_333MHZ,
      input         CLK_200MHZ,
      input         RST,              
      input           axi_awvalid,
      output          axi_awready,
      input  [31:0]   axi_awaddr,
      input  [2:0]    axi_awprot,
      input           axi_wvalid,
      output          axi_wready,
      input  [31:0]   axi_wdata,
      input  [3:0]    axi_wstrb,
      output          axi_bvalid,
      input           axi_bready,
      input           axi_arvalid,
      output          axi_arready,
      input  [31:0]   axi_araddr,
      input  [2:0]    axi_arprot,
      output          axi_rvalid,
      input           axi_rready,
      output [31:0]   axi_rdata,
      output [12:0]   ddr2_addr,
      output [2:0]    ddr2_ba,
      output          ddr2_ras_n,
      output          ddr2_cas_n,
      output          ddr2_we_n,
      output [0:0]    ddr2_ck_p,
      output [0:0]    ddr2_ck_n,
      output [0:0]    ddr2_cke,
      output [0:0]    ddr2_cs_n,
      output [1:0]    ddr2_dm,
      output [0:0]    ddr2_odt,
      inout  [15:0]   ddr2_dq,
      inout  [1:0]    ddr2_dqs_p,
      inout  [1:0]    ddr2_dqs_n
    );
    wire rst_i;
    assign rst_i = ~RST;
    localparam [2:0] CMD_WRITE = 3'b000;
    localparam [2:0] CMD_READ  = 3'b001;
    wire mem_ui_clk;
    wire mem_ui_rst;
    wire rst_def;
    wire rstn;
    reg [26:0]  mem_addr; 
    reg [2:0]  mem_cmd; 
    reg mem_en; 
    wire mem_rdy;
    wire mem_wdf_rdy; 
    reg [63:0] mem_wdf_data;
    reg mem_wdf_end; 
    reg [7:0] mem_wdf_mask;
    reg mem_wdf_wren;
    wire [63:0] mem_rd_data;
    wire mem_rd_data_end; 
    wire mem_rd_data_valid; 
    wire mem_init_calib_complete; 
    reg rd_vld; 
    reg rd_end;
    reg [63:0] rd_data_1, rd_data_2;
    wire block;
    reg block_o;
    reg [31:0] waddr, raddr;
    reg [31:0] wdata;
    reg [3:0] wstrb;
    reg [1:0] wassert;
    reg rassert;
    assign axi_awready = ~block;
    assign axi_arready = ~block;
    assign axi_wready = ~block;
    always @(posedge CLK)
    begin : SINGLE_SHOT
        if(rst_def == 1'b0) begin
            waddr <= 0;
            raddr <= 0;
            wdata <= 0;
            wstrb <= 0;
            wassert <= 2'b00;
            rassert <= 1'b0;
        end else begin
            if(axi_bvalid | block) begin	
                waddr <= waddr;
                wstrb <= wstrb;
                wassert[0] <= 1'b0;
            end else if(axi_awvalid) begin
                waddr <= axi_awaddr;
                wstrb <= axi_wstrb;
                wassert[0] <= 1'b1;
            end else begin
                waddr <= waddr;
                wstrb <= wstrb;
                wassert[0] <= wassert[0];
            end
            if(axi_bvalid | block) begin	
                wdata <= wdata;
                wassert[1] <= 1'b0;
            end else if(axi_wvalid) begin
                wdata <= axi_wdata;
                wassert[1] <= 1'b1;
            end else begin
                wdata <= wdata;
                wassert[1] <= wassert[1];
            end
            if(axi_rvalid | block) begin	
                raddr <= raddr;
                rassert <= 1'b0;
            end else if(axi_arvalid) begin
                raddr <= axi_araddr;
                rassert <= 1'b1;
            end else begin
                raddr <= raddr;
                rassert <= rassert;
            end
        end
    end
    parameter st0_nothing = 0, st2_CheckRdy = 2, st3_WaitRdy = 3, st4_detour = 4, st5_wready = 5, st6_rready = 6, st7_waitclean = 7;
    reg [3:0] state;
    reg is_writting;
    reg axi_bvalid_o;
    reg axi_rvalid_o;
    reg [31:0] axi_rdata_o;
    localparam NUM_RET_RVALID = 15;
    wire axi_rvalid_def;
    reg [NUM_RET_RVALID-1:0] axi_rvalid_def_reg;
    always @(posedge CLK) axi_rvalid_def_reg <= {axi_rvalid_def_reg[NUM_RET_RVALID-2:0], axi_rvalid_def};
    assign axi_rvalid = axi_rvalid_def_reg[NUM_RET_RVALID-1];
    localparam NUM_RET_BVALID = 15;
    wire axi_bvalid_def;
    reg [NUM_RET_BVALID-1:0] axi_bvalid_def_reg;
    always @(posedge CLK) axi_bvalid_def_reg <= {axi_bvalid_def_reg[NUM_RET_BVALID-2:0], axi_bvalid_def};
    assign axi_bvalid = axi_bvalid_def_reg[NUM_RET_BVALID-1];
    bus_sync_sf #(.impl(1), .sword(32+1)) sync_rdata(.CLK1(mem_ui_clk), .CLK2(CLK), .RST(RST), 
    .data_in({axi_rdata_o, block_o}), 
    .data_out({axi_rdata, block}));
    bus_sync_sf #(.impl(1), .sword(2)) sync_flags(.CLK1(mem_ui_clk), .CLK2(CLK), .RST(RST), 
    .data_in({axi_bvalid_o, axi_rvalid_o}), 
    .data_out({axi_bvalid_def, axi_rvalid_def}));
    wire [31:0] waddr_o, raddr_o;
    wire [31:0] wdata_o;
    wire [3:0] wstrb_o;
    wire wassert_o;
    wire rassert_o;
    wire axi_rready_o;
    wire axi_bready_o;
    wire axi_bvalid_ret;
    wire axi_rvalid_ret;
    localparam NUM_RET_WASSERT = 20;
    wire [1:0] wassert_def;
    reg [NUM_RET_WASSERT-1:0] wassert_def_reg;
    always @(posedge mem_ui_clk) wassert_def_reg <= {wassert_def_reg[NUM_RET_WASSERT-2:0], &wassert_def};
    assign wassert_o = wassert_def_reg[NUM_RET_WASSERT-1];
    localparam NUM_RET_RASSERT = 20;
    wire rassert_def;
    reg [NUM_RET_RASSERT-1:0] rassert_def_reg;
    always @(posedge mem_ui_clk) rassert_def_reg <= {rassert_def_reg[NUM_RET_RASSERT-2:0], rassert_def};
    assign rassert_o = rassert_def_reg[NUM_RET_RASSERT-1];
    bus_sync_sf #(.impl(0), .sword(32+32+32+4+2+1)) sync_odata(.CLK1(CLK), .CLK2(mem_ui_clk), .RST(RST), 
    .data_in({waddr, raddr, wdata, wstrb, wassert, rassert}), 
    .data_out({waddr_o, raddr_o, wdata_o, wstrb_o, wassert_def, rassert_def}));
    bus_sync_sf #(.impl(0), .sword(2)) sync_flagso(.CLK1(CLK), .CLK2(mem_ui_clk), .RST(RST), 
    .data_in({axi_bready, axi_rready}), 
    .data_out({axi_bready_o, axi_rready_o}));
    always @ (posedge mem_ui_clk or negedge rst_def) begin
        if (rst_def == 1'b0) begin
            axi_bvalid_o <= 1'b0;
            axi_rvalid_o <= 1'b0;
            axi_rdata_o <= 0;
            is_writting <= 1'b0;
            state <= st0_nothing;
            mem_wdf_wren <= 1'b0;
            mem_wdf_end <= 1'b0;
            mem_en <= 1'b0;
            mem_cmd <= 0;
            block_o <= 1'b0;
        end else
            case (state)
                st0_nothing: begin
                    if(mem_init_calib_complete == 1'b1) begin 
                        if(mem_rdy == 1'b1) begin 
                            if(mem_wdf_rdy == 1'b1) begin 
                                if(wassert_o == 1'b1) begin
                                    state <= st2_CheckRdy;
                                    mem_cmd <= CMD_WRITE;
                                    mem_wdf_wren <= 1'b1;
                                    mem_wdf_end <= 1'b1;
                                    mem_en <= 1'b1;
                                    mem_addr <= {waddr_o[29:3], 3'b000};
                                    mem_wdf_data <= {wdata_o, wdata_o};
                                    mem_wdf_mask <= {~{wstrb_o & {4{waddr_o[2]}}}, ~{wstrb_o & {4{~waddr_o[2]}}}};
                                    is_writting <= 1'b1;
                                end else if(rassert_o == 1'b1) begin
                                    state <= st2_CheckRdy;
                                    mem_cmd <= CMD_READ;
                                    mem_en <= 1'b1;
                                    mem_addr <= {raddr_o[29:3], 3'b000};
                                    is_writting <= 1'b0;
                                end else begin
                                    state <= st0_nothing;
                                end
                            end
                        end
                    end
                end
                st2_CheckRdy: begin
                    if(mem_rdy == 1'b0)
                        state <= st3_WaitRdy;
                    else begin
                        mem_wdf_wren <= 1'b0;
                        mem_wdf_end <= 1'b0;
                        mem_en <= 1'b0;
                        state <= st4_detour;
                    end
                end
                st3_WaitRdy: begin
                    if(mem_rdy == 1'b1)
                        state <= st3_WaitRdy;
                    else begin
                        mem_wdf_wren <= 1'b0;
                        mem_wdf_end <= 1'b0;
                        mem_en <= 1'b0;
                        state <= st4_detour;
                    end
                end
                st4_detour:
                    if(is_writting) begin
                        state <= st5_wready;
                        axi_bvalid_o <= 1'b1;
                    end else begin
                        if(rd_vld & rd_end) begin
                            state <= st6_rready;
                            axi_rvalid_o <= 1'b1;
                            if(raddr[2])
                                axi_rdata_o <= rd_data_2[63:32];
                            else
                                axi_rdata_o <= rd_data_2[31:0];
                        end else begin
                            state <= st4_detour;
                        end
                    end
                st5_wready:
                    if (axi_bready_o == 1'b1) begin
                        state <= st7_waitclean;
                        block_o <= 1'b1;
                    end else
                        state <= st5_wready;
                st6_rready:
                    if (axi_rready_o == 1'b1) begin
                        state <= st7_waitclean;
                        block_o <= 1'b1;
                    end else
                        state <= st6_rready;
                st7_waitclean:
                    if (is_writting == 1'b1 && wassert_o == 1'b0) begin
                        state <= st0_nothing;
                        axi_bvalid_o <= 1'b0;
                        block_o <= 1'b0;
                    end else if (is_writting == 1'b0 && rassert_o == 1'b0) begin
                        state <= st0_nothing;
                        axi_rvalid_o <= 1'b0;
                        block_o <= 1'b0;
                    end
                default:
                    state <= st0_nothing;
            endcase
    end
    always @ (posedge mem_ui_clk)
    begin
        rd_vld <= mem_rd_data_valid;
        rd_end <= mem_rd_data_end;
        rd_data_1 <= mem_rd_data;
        rd_data_2 <= rd_data_1;
    end
    ddr2 Inst_DDR2 (
      .ddr2_dq              (ddr2_dq),
      .ddr2_dqs_p           (ddr2_dqs_p),
      .ddr2_dqs_n           (ddr2_dqs_n),
      .ddr2_addr            (ddr2_addr),
      .ddr2_ba              (ddr2_ba),
      .ddr2_ras_n           (ddr2_ras_n),
      .ddr2_cas_n           (ddr2_cas_n),
      .ddr2_we_n            (ddr2_we_n),
      .ddr2_ck_p            (ddr2_ck_p),
      .ddr2_ck_n            (ddr2_ck_n),
      .ddr2_cke             (ddr2_cke),
      .ddr2_cs_n            (ddr2_cs_n),
      .ddr2_dm              (ddr2_dm),
      .ddr2_odt             (ddr2_odt),
      .sys_clk_i            (CLK_333MHZ),
      .clk_ref_i            (CLK_200MHZ),
      .sys_rst              (rstn),
      .app_addr             (mem_addr),
      .app_cmd              (mem_cmd),
      .app_en               (mem_en),
      .app_wdf_data         (mem_wdf_data),
      .app_wdf_end          (mem_wdf_end),
      .app_wdf_mask         (mem_wdf_mask),
      .app_wdf_wren         (mem_wdf_wren),
      .app_rd_data          (mem_rd_data),
      .app_rd_data_end      (mem_rd_data_end),
      .app_rd_data_valid    (mem_rd_data_valid),
      .app_rdy              (mem_rdy),
      .app_wdf_rdy          (mem_wdf_rdy),
      .app_sr_req           (1'b0),
      .app_ref_req          (1'b0),
      .app_zq_req           (1'b0),
      .ui_clk               (mem_ui_clk),
      .ui_clk_sync_rst      (mem_ui_rst),
      .device_temp_i        (12'b000000000000),
      .init_calib_complete  (mem_init_calib_complete)); 
    assign rstn = ~rst_i;
    assign rst_def = ~(rst_i | mem_ui_rst);
endmodule