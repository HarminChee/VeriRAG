Here is the modified Verilog code addressing the CLKNPI issue:


module nexys_video_demo (
    input clk,
    output tx,
    input rx,
    input [7:0] sw,
    output [7:0] led
);
    wire clk100;
    wire resetn;
    wire        iomem_valid;
    wire         iomem_ready;
    wire [3:0]  iomem_wstrb;
    wire [31:0] iomem_addr;
    wire [31:0] iomem_wdata;
    wire  [31:0] iomem_rdata;
    wire [31:0] gpio;

    BUFG bufg100 (.I(clk), .O(clk100));

    reset_generator reset_gen (
        .clk(clk100),
        .resetn(resetn)
    );

    gpio_controller gpio_ctrl (
        .clk(clk100),
        .resetn(resetn),
        .sw(sw),
        .led(led),
        .iomem_valid(iomem_valid),
        .iomem_ready(iomem_ready),
        .iomem_wstrb(iomem_wstrb),
        .iomem_addr(iomem_addr),
        .iomem_wdata(iomem_wdata),
        .iomem_rdata(iomem_rdata),
        .gpio(gpio)
    );

    picosoc_noflash soc (
        .clk          (clk100),
        .resetn       (resetn),
        .ser_tx       (tx),
        .ser_rx       (rx),
        .irq_5        (1'b0),
        .irq_6        (1'b0),
        .irq_7        (1'b0),
        .iomem_valid  (iomem_valid),
        .iomem_ready  (iomem_ready),
        .iomem_wstrb  (iomem_wstrb),
        .iomem_addr   (iomem_addr),
        .iomem_wdata  (iomem_wdata),
        .iomem_rdata  (iomem_rdata)
    );
endmodule

module reset_generator (
    input clk,
    output reg resetn
);
    reg [5:0] reset_cnt = 0;

    always @(posedge clk) begin
        reset_cnt <= reset_cnt + !resetn;
        resetn <= &reset_cnt;
    end
endmodule

module gpio_controller (
    input clk,
    input resetn,
    input [7:0] sw,
    output [7:0] led,
    input        iomem_valid,
    output reg   iomem_ready,
    input [3:0]  iomem_wstrb,
    input [31:0] iomem_addr,
    input [31:0] iomem_wdata,
    output reg [31:0] iomem_rdata,
    output reg [31:0] gpio
);
    assign led = gpio[7:0];

    always @(posedge clk) begin
        if (!resetn) begin
            gpio <= 0;
            iomem_ready <= 0;
            iomem_rdata <= 0;
        end else begin
            iomem_ready <= 0;
            if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 03) begin
                iomem_ready <= 1;
                iomem_rdata <= {gpio[31:24], sw, gpio[15:0]};
                if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
                if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
                if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
                if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
            end
        end
    end
endmodule