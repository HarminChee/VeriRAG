module Command_reader
    #(parameter CMD_ADDRESS=0, FIFO_DEPTH=32, FIFO_DEPTH_LOG2=5)
(
    input wire clock,
    input wire reset_n,
    input wire restart,
    output wire ready,
    output reg [28:0] read_address,
    output wire [7:0] read_burstcount,
    input wire read_waitrequest,
    input wire [63:0] read_readdata,
    input wire read_readdatavalid,
    output reg read_read,
    output wire fifo_empty,
    output wire [63:0] fifo_q,
    input wire fifo_rdreq
);
    assign read_burstcount = 8'h01;
    localparam STATE_INIT = 3'h0;
    localparam STATE_RESTART = 3'h1;
    localparam STATE_FLUSHING_READS = 3'h2;
    localparam STATE_CLEAR_FIFO_WAIT = 3'h3;
    localparam STATE_COPY_COMMANDS = 3'h4;
    reg [2:0] state;
    reg [28:0] pc;
    reg [FIFO_DEPTH-1:0] pending_reads;
    assign ready = state == STATE_COPY_COMMANDS && !restart;
    reg fifo_sclr;
    wire [FIFO_DEPTH_LOG2-1:0] fifo_size;
    scfifo #(.add_ram_output_register("OFF"),
             .intended_device_family("CYCLONEV"),
             .lpm_numwords(FIFO_DEPTH),
             .lpm_showahead("OFF"),
             .lpm_type("scfifo"),
             .lpm_width(64),
             .lpm_widthu(FIFO_DEPTH_LOG2),
             .overflow_checking("ON"),
             .underflow_checking("ON"),
             .use_eab("ON")) fifo(
            .aclr(!reset_n),
            .sclr(fifo_sclr),
            .clock(clock),
            .data(read_readdata),
            .empty(fifo_empty),
            .usedw(fifo_size),
            .q(fifo_q),
            .rdreq(fifo_rdreq),
            .wrreq(read_readdatavalid));
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            state <= STATE_INIT;
            pc <= CMD_ADDRESS/8;
            pending_reads <= {FIFO_DEPTH{1'b0}};
            read_read <= 1'b0;
            fifo_sclr <= 1'b0;
        end else begin
            if (read_readdatavalid) begin
                pending_reads <= pending_reads - 1'b1;
            end 
            if (restart) begin
                state <= STATE_RESTART;
                read_read <= 1'b0;
            end else case (state)
                STATE_INIT: begin
                end
                STATE_RESTART: begin
                    pc <= CMD_ADDRESS/8;
                    state <= STATE_FLUSHING_READS;
                end
                STATE_FLUSHING_READS: begin
                    if (pending_reads == 0) begin
                        fifo_sclr <= 1'b1;
                        state <= STATE_CLEAR_FIFO_WAIT;
                    end
                end
                STATE_CLEAR_FIFO_WAIT: begin
                    fifo_sclr <= 1'b0;
                    state <= STATE_COPY_COMMANDS;
                end
                STATE_COPY_COMMANDS: begin
                    if (read_read && read_waitrequest) begin
                    end else if (fifo_size + pending_reads < FIFO_DEPTH - 3) begin
                        read_address <= pc;
                        read_read <= 1'b1;
                        pc <= pc + 1'b1;
                        if (read_readdatavalid) begin
                            pending_reads <= pending_reads;
                        end else begin
                            pending_reads <= pending_reads + 1'b1;
                        end
                    end else begin
                        read_read <= 1'b0;
                    end
                end
                default: begin
                    state <= STATE_INIT;
                end
            endcase
        end
    end
endmodule
