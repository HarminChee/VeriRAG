module mtx_io #(
    parameter IOW = 64,          
    parameter TARGET = "GENERIC"
)(
    input          nreset, 
    input          io_clk, 
    input          ddr_mode, 
    input  [1:0]   iowidth, 
    output [IOW-1:0] tx_packet, 
    output reg     tx_access, 
    input          tx_wait, 
    input  [7:0]   io_valid, 
    input  [IOW-1:0] io_packet, 
    output         io_wait 
);

    reg [63:0] shiftreg;
    reg [7:0]  io_valid_reg;
    wire [IOW/2-1:0] tx_packet_ddr;
    wire tx_wait_sync;
    wire transfer_active;
    wire [7:0] io_valid_next;
    wire [IOW/2-1:0] ddr_data_even;
    wire [IOW/2-1:0] ddr_data_odd;
    wire dmode8, dmode16, dmode32, dmode64;
    wire io_nreset;
    wire reload;

    assign dmode8  = (iowidth == 2'b00);
    assign dmode16 = ((iowidth == 2'b01) & ~ddr_mode) | ((iowidth == 2'b00) & ddr_mode);
    assign dmode32 = ((iowidth == 2'b10) & ~ddr_mode) | ((iowidth == 2'b01) & ddr_mode);
    assign dmode64 = ((iowidth == 2'b11) & ~ddr_mode) | ((iowidth == 2'b10) & ddr_mode);

    assign io_valid_next = dmode8  ? {1'b0, io_valid_reg[7:1]} :
                           dmode16 ? {2'b0, io_valid_reg[7:2]} :
                           dmode32 ? {4'b0, io_valid_reg[7:4]} : 8'b0;

    assign reload = ~transfer_active | dmode64 | (io_valid_next == 8'b0);

    always @(posedge io_clk or negedge io_nreset) begin
        if (!io_nreset)
            io_valid_reg <= 8'b0;
        else if (reload)
            io_valid_reg <= io_valid;
        else
            io_valid_reg <= io_valid_next;
    end

    assign transfer_active = |io_valid_reg;

    always @(posedge io_clk or negedge io_nreset) begin
        if (!io_nreset)
            tx_access <= 1'b0;
        else
            tx_access <= transfer_active;
    end

    assign io_wait = tx_wait_sync | ~reload;

    always @(posedge io_clk) begin
        if (reload)
            shiftreg <= io_packet;
        else if (dmode8)
            shiftreg <= {8'b0, shiftreg[IOW-1:8]};
        else if (dmode16)
            shiftreg <= {16'b0, shiftreg[IOW-1:16]};
        else if (dmode32)
            shiftreg <= {32'b0, shiftreg[IOW-1:32]};
    end

    assign ddr_data_even = shiftreg[IOW/2-1:0];

    assign ddr_data_odd = (iowidth == 2'b00) ? shiftreg[7:4] :
                          (iowidth == 2'b01) ? shiftreg[15:8] :
                          (iowidth == 2'b10) ? shiftreg[31:16] : shiftreg[63:32];

    oh_oddr #(.DW(IOW/2)) data_oddr (
        .out  (tx_packet_ddr),
        .clk  (io_clk),
        .din1 (ddr_data_even),
        .din2 (ddr_data_odd)
    );

    assign tx_packet = ddr_mode ? {{(IOW/2){1'b0}}, tx_packet_ddr} : shiftreg;

    oh_rsync sync_reset (
        .nrst_out(io_nreset),
        .clk(io_clk),
        .nrst_in(nreset)
    );

    oh_dsync sync_wait (
        .nreset(io_nreset),
        .clk(io_clk),
        .din(tx_wait),
        .dout(tx_wait_sync)
    );

endmodule