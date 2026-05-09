`timescale 1ns / 1ps
module AXI_DDR3_MIG (
    input              CLK,
    input              CLK_333MHZ,
    input              CLK_200MHZ,
    input              RST,
    input              test_i,
    output             axi_awvalid,
    input              axi_awready,
    output      [31:0] axi_awaddr,
    output      [2:0]  axi_awprot,
    output             axi_wvalid,
    input              axi_wready,
    output      [31:0] axi_wdata,
    output      [3:0]  axi_wstrb,
    input              axi_bvalid,
    output             axi_bready,
    output             axi_arvalid,
    input              axi_arready,
    output      [31:0] axi_araddr,
    output      [2:0]  axi_arprot,
    input              axi_rvalid,
    output             axi_rready,
    input       [31:0] axi_rdata,
    output      [12:0] ddr3_addr,
    output      [2:0]  ddr3_ba,
    output             ddr3_ras_n,
    output             ddr3_cas_n,
    output             ddr3_we_n,
    output      [0:0]  ddr3_ck_p,
    output      [0:0]  ddr3_ck_n,
    output      [0:0]  ddr3_cke,
    output      [0:0]  ddr3_cs_n,
    output      [1:0]  ddr3_dm,
    output      [0:0]  ddr3_odt,
    inout       [15:0] ddr3_dq,
    inout       [1:0]  ddr3_dqs_p,
    inout       [1:0]  ddr3_dqs_n
);

    wire rst_i;
    assign rst_i = ~RST;
    localparam [2:0] CMD_WRITE = 3'b000;
    localparam [2:0] CMD_READ = 3'b001;
    wire mem_ui_clk;
    wire mem_ui_rst;
    wire rst_def;
    wire rstn;
    wire dft_mem_ui_clk;
    wire dft_mem_ui_rst;
    assign dft_mem_ui_clk = test_i ? CLK : mem_ui_clk;
    assign dft_mem_ui_rst = test_i ? rst_i : mem_ui_rst;
    reg [26:0] mem_addr;
    reg [2:0]  mem_cmd;
    reg        mem_en;
    wire       mem_rdy;
    wire       mem_wdf_rdy;
    reg [63:0] mem_wdf_data;
    reg        mem_wdf_end;
    reg [7:0]  mem_wdf_mask;
    reg        mem_wdf_wren;
    wire [63:0] mem_rd_data;
    wire        mem_rd_data_end;
    wire        mem_rd_data_valid;
    wire        mem_init_calib_complete;
    reg         rd_vld;
    reg         rd_end;
    reg [63:0]  rd_data_1;
    reg [63:0]  rd_data_2;
    reg         block_o;
    reg [31:0]  waddr, raddr;
    reg [31:0]  wdata;
    reg [3:0]   wstrb;
    reg [1:0]   wassert;
    reg         rassert;
    assign axi_awvalid = ~block_o;
    assign axi_arvalid = ~block_o;
    assign axi_wvalid = ~block_o;
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
    wire [31:0] axi_rdata_sync;
    wire block_o_sync;
    bus_sync_sf #(.impl(1), .sword(32+1)) sync_rdata (.CLK1(dft_mem_ui_clk), .CLK2(CLK), .RST(rst_i),
        .data_in({axi_rdata_o, block_o}),
        .data_out({axi_rdata_sync, block_o_sync}));
    assign axi_rdata = axi_rdata_sync;
    assign block_o = block_o_sync;
    wire axi_bvalid_o;
    wire axi_rvalid_o;
    bus_sync_sf #(.impl(1), .sword(2)) sync_flags1 (.CLK1(dft_mem_ui_clk), .CLK2(CLK), .RST(rst_i),
        .data_in({axi_bvalid_o, axi_rvalid_o}),
        .data_out({axi_bvalid_def, axi_rvalid_def}));
    wire [31:0] waddr_o, raddr_o;
    wire [31:0] wdata_o;
    wire [3:0] wstrb_o;
    wire [1:0] wassert_o;
    wire rassert_o;
    wire axi_rready_o;
    wire axi_bready_o;
    localparam NUM_RET_WASSERT = 20;
    wire [1:0] wassert_def;
    reg [NUM_RET_WASSERT-1:0] wassert_def_reg;
    always @(posedge dft_mem_ui_clk) wassert_def_reg <= {wassert_def_reg[NUM_RET_WASSERT-2:0], wassert_def};
    assign wassert_o = wassert_def_reg[NUM_RET_WASSERT-1];
    localparam NUM_RET_RASSERT = 20;
    wire rassert_def;
    reg [NUM_RET_RASSERT-1:0] rassert_def_reg;
    always @(posedge dft_mem_ui_clk) rassert_def_reg <= {rassert_def_reg[NUM_RET_RASSERT-2:0], rassert_def};
    assign rassert_o = rassert_def_reg[NUM_RET_RASSERT-1];
    bus_sync_sf #(.impl(0), .sword(32+32+32+4+2+1)) sync_wdata (.CLK1(CLK), .CLK2(dft_mem_ui_clk), .RST(rst_i),
        .data_in({waddr, raddr, wdata, wstrb, wassert, rassert}),
        .data_out({waddr_o, raddr_o, wdata_o, wstrb_o, wassert_def, rassert_def}));
    bus_sync_sf #(.impl(0), .sword(2)) sync_flags2 (.CLK1(CLK), .CLK2(dft_mem_ui_clk), .RST(rst_i),
        .data_in({axi_bready, axi_rready}),
        .data_out({axi_bready_o, axi_rready_o}));
    always @ (posedge CLK)
    begin
        if (rst_def == 1'b0) begin
            waddr <= 0;
            raddr <= 0;
            wdata <= 0;
            wstrb <= 0;
            wassert <= 2'b00;
            rassert <= 1'b0;
        end else begin
            if (axi_bvalid | block_o) begin
                waddr <= waddr;
                wstrb <= wstrb;
                wassert[0] <= wassert[0];
            end else if (axi_awvalid && axi_awready) begin
                waddr <= axi_awaddr;
                wstrb <= axi_wstrb;
                wassert[0] <= 1'b1;
            end else begin
                waddr <= waddr;
                wstrb <= wstrb;
                wassert[0] <= wassert[0];
            end
            if (axi_bvalid | block_o) begin
                wdata <= wdata;
                wassert[1] <= wassert[1];
            end else if (axi_wvalid && axi_wready) begin
                wdata <= axi_wdata;
                wassert[1] <= 1'b1;
            end else begin
                wdata <= wdata;
                wassert[1] <= wassert[1];
            end
            if (axi_rvalid | block_o) begin
                raddr <= raddr;
                rassert <= 1'b0;
            end else if (axi_arvalid && axi_arready) begin
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
    reg axi_bvalid_o_reg;
    reg axi_rvalid_o_reg;
    assign axi_bvalid_o = axi_bvalid_o_reg;
    assign axi_rvalid_o = axi_rvalid_o_reg;
    always @ (posedge dft_mem_ui_clk or posedge dft_mem_ui_rst) begin
        if (dft_mem_ui_rst == 1'b1) begin
            axi_bvalid_o_reg <= 1'b0;
            axi_rvalid_o_reg <= 1'b0;
            axi_rdata_o <= 0;
            is_writting <= 1'b0;
            state <= st0_nothing;
            mem_wdf_wren <= 1'b0;
            mem_wdf_end <= 1'b0;
            mem_en <= 1'b0;
            mem_cmd <= 0;
        end else begin
            case (state)
                st0_nothing: begin
                    if (mem_init_calib_complete == 1'b1) begin
                        if (mem_rdy == 1'b1) begin
                            if (mem_wdf_rdy == 1'b1) begin
                                if (wassert_o[0] == 1'b1 && wassert_o[1] == 1'b1) begin
                                    state <= st2_CheckRdy;
                                    mem_cmd <= CMD_WRITE;
                                    mem_wdf_wren <= 1'b1;
                                    mem_wdf_end <= 1'b1;
                                    mem_en <= 1'b1;
                                    mem_addr <= {waddr_o[29:3], 3'b000};
                                    mem_wdf_data <= {wdata_o, wdata_o};
                                    mem_wdf_mask <= {~{wstrb_o & {4{waddr_o[2]}}}, ~{wstrb_o & {4{~waddr_o[2]}}}};
                                    is_writting <= 1'b1;
                                end else if (rassert_o == 1'b1) begin
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
                    if (mem_rdy == 1'b0)
                        state <= st3_WaitRdy;
                    else begin
                        mem_wdf_wren <= 1'b0;
                        mem_wdf_end <= 1'b0;
                        mem_en <= 1'b0;
                        state <= st4_detour;
                    end
                end
                st3_WaitRdy: begin
                    if (mem_rdy == 1'b1) begin
                        mem_wdf_wren <= 1'b0;
                        mem_wdf_end <= 1'b0;
                        mem_en <= 1'b0;
                        state <= st4_detour;
                    end else begin
                        state <= st3_WaitRdy;
                    end
                end
                st4_detour: begin
                    if (is_writting) begin
                        state <= st5_wready;
                    end else begin
                        if (rd_vld & rd_end) begin
                            state <= st6_rready;
                            axi_rvalid_o_reg <= 1'b1;
                            if (raddr_o[2])
                                axi_rdata_o <= rd_data_2[63:32];
                            else
                                axi_rdata_o <= rd_data_2[31:0];
                        end else
                            state <= st4_detour;
                    end
                end
                st5_wready: begin
                    if (axi_bready_o == 1'b1) begin
                        state <= st7_waitclean;
                        axi_bvalid_o_reg <= 1'b0;
                    end else begin
                        state <= st5_wready;
                        axi_bvalid_o_reg <= 1'b1;
                    end
                end
                st6_rready: begin
                    if (axi_rready_o == 1'b1) begin
                        state <= st7_waitclean;
                        axi_rvalid_o_reg <= 1'b0;
                    end else
                        state <= st6_rready;
                end
                st7_waitclean: begin
                    if (is_writting == 1'b1 && wassert_o == 2'b00) begin
                        state <= st0_nothing;
                    end else if (is_writting == 1'b0 && rassert_o == 1'b0) begin
                        state <= st0_nothing;
                    end else begin
                        state <= st7_waitclean;
                    end
                end
                default:
                    state <= st0_nothing;
            endcase
        end
    end
    always @ (posedge dft_mem_ui_clk)
    begin
        rd_vld <= mem_rd_data_valid;
        rd_end <= mem_rd_data_end;
        rd_data_1 <= mem_rd_data;
        rd_data_2 <= rd_data_1;
    end
    ddr3 Inst_DDR3 (
        .ddr3_dq            (ddr3_dq),
        .ddr3_dqs_p         (ddr3_dqs_p),
        .ddr3_dqs_n         (ddr3_dqs_n),
        .ddr3_addr          (ddr3_addr),
        .ddr3_ba            (ddr3_ba),
        .ddr3_ras_n         (ddr3_ras_n),
        .ddr3_cas_n         (ddr3_cas_n),
        .ddr3_we_n          (ddr3_we_n),
        .ddr3_ck_p          (ddr3_ck_p),
        .ddr3_ck_n          (ddr3_ck_n),
        .ddr3_cke           (ddr3_cke),
        .ddr3_cs_n          (ddr3_cs_n),
        .ddr3_dm            (ddr3_dm),
        .ddr3_odt           (ddr3_odt),
        .sys_clk_i          (CLK_333MHZ),
        .clk_ref_i          (CLK_200MHZ),
        .sys_rst            (rstn),
        .app_addr           (mem_addr),
        .app_cmd            (mem_cmd),
        .app_en             (mem_en),
        .app_wdf_data       (mem_wdf_data),
        .app_wdf_end        (mem_wdf_end),
        .app_wdf_mask       (mem_wdf_mask),
        .app_wdf_wren       (mem_wdf_wren),
        .app_rd_data        (mem_rd_data),
        .app_rd_data_end    (mem_rd_data_end),
        .app_rd_data_valid  (mem_rd_data_valid),
        .app_rdy            (mem_rdy),
        .app_wdf_rdy        (mem_wdf_rdy),
        .app_sr_req         (1'b0),
        .app_ref_req        (1'b0),
        .app_zq_req         (1'b0),
        .ui_clk             (mem_ui_clk),
        .ui_clk_sync_rst    (mem_ui_rst),
        .device_temp_i      (12'b000000000000),
        .init_calib_complete(mem_init_calib_complete)
    );
    assign rstn = ~rst_i;
    assign rst_def = ~(rst_i | mem_ui_rst);
    assign axi_awaddr = waddr;
    assign axi_awprot = 3'b000;
    assign axi_wdata = wdata;
    assign axi_wstrb = wstrb;
    assign axi_araddr = raddr;
    assign axi_arprot = 3'b000;
endmodule