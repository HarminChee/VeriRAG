module axi4_lite_ipif_wrapper #(
    parameter               C_BASE_ADDRESS    = 32'h00,
    parameter               C_ADDR_RANGE_SIZE = 32'h7FF
) (
    input                   s_axi_aclk,
    input                   s_axi_aresetn,
    input    [31:0]         s_axi_awaddr,
    input                   s_axi_awvalid,
    output                  s_axi_awready,
    input    [31:0]         s_axi_wdata,
    input                   s_axi_wvalid,
    output                  s_axi_wready,
    output   [1:0]          s_axi_bresp,
    output                  s_axi_bvalid,
    input                   s_axi_bready,
    input    [31:0]         s_axi_araddr,
    input                   s_axi_arvalid,
    output                  s_axi_arready,
    output   [31:0]         s_axi_rdata,
    output   [1:0]          s_axi_rresp,
    output                  s_axi_rvalid,
    input                   s_axi_rready,
    output                  bus2ip_clk,
    output                  bus2ip_reset,
    output   [31:0]         bus2ip_addr,
    output                  bus2ip_cs,
    output                  bus2ip_rdce,
    output                  bus2ip_wrce,
    output   [31:0]         bus2ip_data,
    input    [31:0]         ip2bus_data,
    input                   ip2bus_wrack,
    input                   ip2bus_rdack,
    input                   ip2bus_error
);
    parameter C_BASE_ADDRESS_TEMAC  = C_BASE_ADDRESS;
    parameter C_HIGH_ADDRESS_TEMAC  = C_BASE_ADDRESS + C_ADDR_RANGE_SIZE;
    
    wire                 bus2ip_cs_int;
    wire                 bus2ip_rdce_int;
    wire                 bus2ip_wrce_int;
    wire                 bus2ip_resetn;
    wire                 ip2bus_rdack_comb;
    wire                 ip2bus_wrack_comb;
    
    reg                  local_wrack;
    reg                  local_rdack;
    reg                  cs_edge_reg;
    
    assign bus2ip_reset  =  !bus2ip_resetn;
    assign bus2ip_cs     = bus2ip_cs_int;
    assign bus2ip_rdce   = bus2ip_rdce_int;
    assign bus2ip_wrce   = bus2ip_wrce_int;
    
    axi_lite_ipif #(
        .C_S_AXI_MIN_SIZE             (C_ADDR_RANGE_SIZE),
        .C_DPHASE_TIMEOUT             (16),
        .C_NUM_ADDRESS_RANGES         (1),
        .C_TOTAL_NUM_CE               (1),
        .C_ARD_ADDR_RANGE_ARRAY       ({C_BASE_ADDRESS_TEMAC, C_HIGH_ADDRESS_TEMAC}),
        .C_ARD_NUM_CE_ARRAY           (8'd1),
        .C_FAMILY                     ("virtex6")
    ) axi_lite_top (
        .S_AXI_ACLK            (s_axi_aclk),
        .S_AXI_ARESETN         (s_axi_aresetn),
        .S_AXI_AWADDR          (s_axi_awaddr),
        .S_AXI_AWVALID         (s_axi_awvalid),
        .S_AXI_AWREADY         (s_axi_awready),
        .S_AXI_WDATA           (s_axi_wdata),
        .S_AXI_WSTRB           (4'hF),
        .S_AXI_WVALID          (s_axi_wvalid),
        .S_AXI_WREADY          (s_axi_wready),
        .S_AXI_BRESP           (s_axi_bresp),
        .S_AXI_BVALID          (s_axi_bvalid),
        .S_AXI_BREADY          (s_axi_bready),
        .S_AXI_ARADDR          (s_axi_araddr),
        .S_AXI_ARVALID         (s_axi_arvalid),
        .S_AXI_ARREADY         (s_axi_arready),
        .S_AXI_RDATA           (s_axi_rdata),
        .S_AXI_RRESP           (s_axi_rresp),
        .S_AXI_RVALID          (s_axi_rvalid),
        .S_AXI_RREADY          (s_axi_rready),
        .Bus2IP_Clk            (bus2ip_clk),
        .Bus2IP_Resetn         (bus2ip_resetn),
        .Bus2IP_Addr           (bus2ip_addr),
        .Bus2IP_RNW            (),
        .Bus2IP_BE             (),
        .Bus2IP_CS             (bus2ip_cs_int),
        .Bus2IP_RdCE           (bus2ip_rdce_int),
        .Bus2IP_WrCE           (bus2ip_wrce_int),
        .Bus2IP_Data           (bus2ip_data),
        .IP2Bus_Data           (ip2bus_data),
        .IP2Bus_WrAck          (ip2bus_wrack_comb),
        .IP2Bus_RdAck          (ip2bus_rdack_comb),
        .IP2Bus_Error          (ip2bus_error)
    );
    
    always @(posedge bus2ip_clk or negedge bus2ip_resetn)
    begin
        if (!bus2ip_resetn) begin
            local_wrack <= 1'b0;
            local_rdack <= 1'b0;
            cs_edge_reg <= 1'b0;
        end
        else begin
            cs_edge_reg <= bus2ip_cs_int;
            if (bus2ip_cs_int & !cs_edge_reg) begin
                if (bus2ip_rdce_int)
                    local_rdack <= 1'b1;
                else
                    local_rdack <= 1'b0;
                if (bus2ip_wrce_int)
                    local_wrack <= 1'b1;
                else
                    local_wrack <= 1'b0;
            end
            else begin
                local_wrack <= 1'b0;
                local_rdack <= 1'b0;
            end
        end
    end
    
    assign ip2bus_rdack_comb = local_rdack | ip2bus_rdack;
    assign ip2bus_wrack_comb = local_wrack | ip2bus_wrack;

endmodule