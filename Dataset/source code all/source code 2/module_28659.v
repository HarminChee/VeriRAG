`timescale 1ns/1ps
`timescale 1ns/1ps
module  simul_axi_hp_rd #(
    parameter [1:0] HP_PORT=0
)(
    input         rst,
    input         aclk,
    output        aresetn, 
    input  [31:0] araddr,
    input         arvalid,
    output        arready,
    input  [ 5:0] arid,
    input  [ 1:0] arlock,
    input  [ 3:0] arcache,
    input  [ 2:0] arprot,
    input  [ 3:0] arlen,
    input  [ 1:0] arsize,
    input  [ 1:0] arburst,
    input  [ 3:0] arqos,
    output [63:0] rdata,
    output        rvalid,
    input         rready,
    output [ 5:0] rid,
    output        rlast,
    output [ 1:0] rresp,
    output [ 7:0] rcount,
    output [ 2:0] racount,
    input         rdissuecap1en,
    output [31:0] sim_rd_address,
    output [ 5:0] sim_rid,
    input         sim_rd_valid,
    output        sim_rd_ready,
    input  [63:0] sim_rd_data,
    output [ 2:0] sim_rd_cap,
    output [ 3:0] sim_rd_qos,
    input  [ 1:0] sim_rd_resp,
    input  [31:0] reg_addr,
    input         reg_wr,
    input         reg_rd,
    input  [31:0] reg_din,
    output [31:0] reg_dout
);
    localparam AFI_BASECTRL= 32'hf8008000+ (HP_PORT << 12);
    localparam AFI_RDCHAN_CTRL= AFI_BASECTRL + 'h00;
    localparam AFI_RDCHAN_ISSUINGCAP= AFI_BASECTRL + 'h4;
    localparam AFI_RDQOS= AFI_BASECTRL + 'h8;
    localparam AFI_RDDATAFIFO_LEVEL= AFI_BASECTRL + 'hc;
    localparam AFI_RDDEBUG= AFI_BASECTRL + 'h10; 
    localparam VALID_ARLOCK =  2'b0; 
    localparam VALID_ARCACHE = 4'b0011; 
    localparam VALID_ARPROT =  3'b000;
    localparam VALID_ARLOCK_MASK =  2'b11; 
    localparam VALID_ARCACHE_MASK = 4'b0011; 
    localparam VALID_ARPROT_MASK =  3'b010;
    assign aresetn= ~rst; 
    reg         rdQosHeadOfCmdQEn =   0;
    reg         rdFabricOutCmdEn =    0;
    reg         rdFabricQosEn =       0;
    reg         rd32BitEn =           0; 
    reg   [2:0] rdIssueCap1 =         0;
    reg   [2:0] rdIssueCap0 =         7;
    reg   [3:0] rdStaticQos =         0;
    wire  [3:0] rd_qos_in;
    wire  [3:0] rd_qos_out;
    wire  [5:0] arid_out; 
    wire  [1:0] arburst_out;
    wire  [1:0] arsize_out; 
    wire  [3:0] arlen_out;
    wire [31:0] araddr_out;
    wire        ar_nempty;
    wire        r_nempty;
    reg   [7:0] fifo_with_requested=0; 
    wire        fifo_data_rd;
    wire  [7:0] next_with_requested;
    wire        start_read_burst_w;
    reg         was_data_fifo_read; 
    reg         was_data_fifo_write;
    reg         was_addr_fifo_write; 
    wire        read_in_progress_w; 
    reg         read_in_progress;
    reg   [3:0] read_left;
    reg   [1:0] rburst;
    reg   [3:0] rlen;
    wire [11:3] next_rd_address; 
    reg  [31:0] read_address;
    wire        last_confirmed_read;
    wire        last_read;
    assign sim_rd_qos = (rdQosHeadOfCmdQEn && (rd_qos_in > rd_qos_out))? rd_qos_in : rd_qos_out;
    assign sim_rd_cap = (rdFabricOutCmdEn && rdissuecap1en) ? rdIssueCap1 : rdIssueCap0;
    assign rd_qos_in =  rdFabricQosEn?(arqos & {4{arvalid}}) : rdStaticQos;
    assign aresetn= ~rst; 
    assign reg_dout=(reg_rd && (reg_addr==AFI_RDDATAFIFO_LEVEL))?
                          {24'b0,rcount}:
                    (   (reg_rd && (reg_addr==AFI_RDCHAN_CTRL))?
                          {28'b0,rdQosHeadOfCmdQEn,rdFabricOutCmdEn,rdFabricQosEn,rd32BitEn}:
                     (  (reg_rd && (reg_addr==AFI_RDCHAN_ISSUINGCAP))?
                          {25'b0,rdIssueCap1,1'b0,rdIssueCap0}:
                      ( (reg_rd && (reg_addr==AFI_RDQOS))?
                          {28'b0,rdStaticQos}:32'bz)));
    always @ (posedge aclk or posedge rst) begin
        if (rst) begin
            rdQosHeadOfCmdQEn  <= 0;
            rdFabricOutCmdEn   <= 0;
            rdFabricQosEn      <= 1;
            rd32BitEn        <= 0;
        end else if (reg_wr && (reg_addr==AFI_RDCHAN_CTRL)) begin
            rdQosHeadOfCmdQEn  <= reg_din[3];
            rdFabricOutCmdEn   <= reg_din[2];
            rdFabricQosEn      <= reg_din[1];
            rd32BitEn        <= reg_din[0];
        end
        if (rst) begin
            rdIssueCap1  <= 0;
            rdIssueCap0  <= 7;
        end else if (reg_wr && (reg_addr==AFI_RDCHAN_ISSUINGCAP)) begin
            rdIssueCap1  <= reg_din[6:4];
            rdIssueCap0  <= reg_din[2:0];
        end
        if (rst) begin
            rdStaticQos  <= 0;
        end else if (reg_wr && (reg_addr==AFI_RDQOS)) begin
            rdStaticQos  <= reg_din[3:0];
        end
    end
    assign fifo_data_rd = rvalid && rready;
    assign next_with_requested= fifo_with_requested + {4'b0,arlen_out[3:0]} + {7'h0,~fifo_data_rd};
    assign start_read_burst_w= ar_nempty && (next_with_requested <= 8'h80) &&
                               (! read_in_progress || last_confirmed_read);
    assign read_in_progress_w= ar_nempty && (next_with_requested <= 8'h80) ||
                               (read_in_progress && !last_confirmed_read); 
    assign rvalid= r_nempty && ((|rcount[7:1]) ||  !was_data_fifo_read);
    assign arready= !racount[2] && (!racount[1] || !racount[0] || !was_addr_fifo_write);
    assign last_read = (read_left==0);
    assign last_confirmed_read = (read_left==0) && sim_rd_valid && sim_rd_ready;
    assign      next_rd_address[11:3] =
      rburst[1]?
        (rburst[0]? {9'bx}:((read_address[11:3] + 1) & {5'h1f, ~rlen[3:0]})):
        (rburst[0]? (read_address[11:3]+1):(read_address[11:3]));
    assign sim_rd_address = read_address; 
    assign sim_rid =        arid_out;
    assign sim_rd_ready =   read_in_progress &&
           !rcount[7] && (!(&rcount[6:0]) || !was_data_fifo_write);
    always @ (posedge  aclk) begin
        if (start_read_burst_w) begin
            if (arsize_out != 2'h3) begin
                $display ("%m: at time %t ERROR: arsize_out=%h, currently only 'h3 (8 bytes) is valid",$time,arsize_out);
                $stop;
            end
        end
        if (arvalid && arready) begin
            if (((arlock ^ VALID_ARLOCK) & VALID_ARLOCK_MASK) != 0) begin
                $display ("%m: at time %t ERROR: arlock = %h, valid %h with mask %h",$time, arlock, VALID_ARLOCK, VALID_ARLOCK_MASK);
                $stop;
            end
            if (((arcache ^ VALID_ARCACHE) & VALID_ARCACHE_MASK) != 0) begin
                $display ("%m: at time %t ERROR: arcache = %h, valid %h with mask %h",$time, arcache, VALID_ARCACHE, VALID_ARCACHE_MASK);
                $stop;
            end
            if (((arprot ^ VALID_ARPROT) & VALID_ARPROT_MASK) != 0) begin
                $display ("%m: at time %t ERROR: arprot = %h, valid %h with mask %h",$time, arprot, VALID_ARPROT, VALID_ARPROT_MASK);
                $stop;
            end
        end
    end
    always @ (posedge aclk or posedge rst) begin
        if (rst)                     fifo_with_requested <= 0;
        else if (start_read_burst_w) fifo_with_requested <= next_with_requested;
        else                         fifo_with_requested <= fifo_with_requested - {7'h0,fifo_data_rd};
        if (rst)  was_data_fifo_read <= 0;
        else      was_data_fifo_read <= rvalid && rready;
        if (rst)  was_addr_fifo_write <= 0;
        else      was_addr_fifo_write <= arvalid && arready;
        if (rst)  was_data_fifo_write <= 0;
        else      was_data_fifo_write <= sim_rd_valid && sim_rd_ready;
        if   (rst)                   rburst[1:0] <= 0;
        else if (start_read_burst_w) rburst[1:0] <= arburst_out[1:0];
        if   (rst)                   rlen[3:0] <= 0;
        else if (start_read_burst_w) rlen[3:0] <=   arlen_out[3:0];
        if   (rst) read_in_progress <= 0;
        else       read_in_progress <= read_in_progress_w;
        if   (rst) read_left <= 0;
        else if (start_read_burst_w)           read_left <= arlen_out[3:0]; 
        else if (sim_rd_valid && sim_rd_ready) read_left <= read_left-1; 
        if   (rst)                             read_address <= 32'bx;
        else if (start_read_burst_w)           read_address <= araddr_out; 
        else if (sim_rd_valid && sim_rd_ready) read_address <= {read_address[31:12],next_rd_address[11:3],read_address[2:0]};
    end
fifo_same_clock_fill   #( .DATA_WIDTH(50),.DATA_DEPTH(2)) 
    raddr_i (
        .rst          (rst),
        .clk          (aclk),
        .sync_rst     (1'b0),
        .we           (arvalid && arready),
        .re           (start_read_burst_w),
        .data_in      ({arid[5:0],     arburst[1:0],    arsize[1:0],    arlen[3:0],    araddr[31:0],     rd_qos_in[3:0]}),
        .data_out     ({arid_out[5:0], arburst_out[1:0],arsize_out[1:0],arlen_out[3:0],araddr_out[31:0], rd_qos_out[3:0]}),
        .nempty       (ar_nempty),
        .half_full    (), 
        .under        (), 
        .over         (), 
        .wcount       (), 
        .rcount       (), 
        .wnum_in_fifo (racount),           
        .rnum_in_fifo ()                   
    );
fifo_same_clock_fill   #( .DATA_WIDTH(73),.DATA_DEPTH(7)) 
    rdata_i (
        .rst          (rst),
        .clk          (aclk),
        .sync_rst     (1'b0),
        .we           (sim_rd_valid && sim_rd_ready),
        .re           (rvalid && rready),
        .data_in      ({last_read, arid_out[5:0],  sim_rd_resp[1:0],  sim_rd_data[63:0]}),
        .data_out     ({rlast,     rid[5:0],       rresp[1:0],        rdata[63:0]}),
        .nempty       (r_nempty), 
        .half_full    (), 
        .under        (), 
        .over         (), 
        .wcount       (), 
        .rcount       (), 
        .wnum_in_fifo (), 
        .rnum_in_fifo (rcount) 
    );
endmodule
