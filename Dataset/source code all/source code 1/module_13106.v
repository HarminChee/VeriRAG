module wb_slave_spi_master #(
    parameter                              BUFFER_SIZE      = 16,    
    parameter                              ADDR_WIDTH       = 16,    
    parameter                              DATA_WIDTH       = 32,    
    parameter                              BASE_ADDRESS     = 'h0F00,    
    parameter                              BUFFER_INDEX_WIDTH = $clog2(BUFFER_SIZE),    
    parameter                              CONTROL_SIZE     = 1,    
    parameter                              STATUS_SIZE      = 1    
) (
    input                               data_in,
    output                              clk_out,
    output reg                          data_out,
    output reg                          slave_select_out,
    input          [ADDR_WIDTH-1:0]     adr_i,    
    input                               cyc_i,    
    input          [DATA_WIDTH-1:0]     dat_i,    
    input                               stb_i,    
    input                               we_i,    
    output reg                          ack_o,    
    output reg     [DATA_WIDTH-1:0]     dat_o,    
    output reg                          err_o,    
    input                               clk_i,    
    input                               rst_i    
);
    localparam BYTE_SIZE = 8; 
    localparam BYTE_INDEX_SIZE = $clog2(BYTE_SIZE); 
    localparam BUFFER_INDEX_SIZE = $clog2(BUFFER_SIZE); 
    reg [BYTE_SIZE-1:0] buffer_recv [STATUS_SIZE+BUFFER_SIZE-1:0];
    reg [BYTE_SIZE-1:0] buffer_send [CONTROL_SIZE+BUFFER_SIZE-1:0];
    reg [0:0] wb_state;
    parameter [0:0]
        S_WB_WAIT      = 1'd0, 
        S_WB_DEASSERT  = 1'd1; 
    integer addr_ok;
    wire start_transfer = buffer_send[BUFFER_SIZE][0];
    reg transfer_complete;
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i == 1'b1) begin
            ack_o <= 0; 
            dat_o <= 0; 
            err_o <= 0; 
            wb_state <= S_WB_WAIT; 
            buffer_send[BUFFER_SIZE] = 0;
        end
        else begin
            buffer_recv[BUFFER_SIZE][BYTE_SIZE-1:0] = {7'b0000000,transfer_complete};
            if (wb_state == S_WB_WAIT) begin
                if (we_i == 1) begin
                    if (adr_i < BASE_ADDRESS + BUFFER_SIZE*2 + CONTROL_SIZE + STATUS_SIZE && adr_i >= BASE_ADDRESS + BUFFER_SIZE + STATUS_SIZE) begin
                        addr_ok = 1;
                    end
                    else begin
                        addr_ok = 0;
                    end
                end
                else begin
                    if (adr_i < BASE_ADDRESS + BUFFER_SIZE + STATUS_SIZE && adr_i >= BASE_ADDRESS) begin
                        addr_ok = 1;
                    end
                    else begin
                        addr_ok = 0;
                    end
                end
                if ( cyc_i == 1 && stb_i == 1 ) begin
                    if (addr_ok) begin
                        ack_o <= 1;
                        if ( we_i == 1 ) begin
                            buffer_send[adr_i - BASE_ADDRESS - BUFFER_SIZE - STATUS_SIZE] <= dat_i[BYTE_SIZE-1:0];
                        end
                        else begin
                            dat_o[DATA_WIDTH-1:0] <= {{DATA_WIDTH-BYTE_SIZE{1'b0}},buffer_recv[adr_i - BASE_ADDRESS]};
                        end
                    end
                    else begin
                        err_o <= 1;
                    end
                    wb_state <= S_WB_DEASSERT;
                end
            end
            else if (wb_state == S_WB_DEASSERT) begin
                ack_o <= 0;
                err_o <= 0;
                wb_state <= S_WB_WAIT;
                buffer_send[BUFFER_SIZE][0] <= 0;
            end
            else
                $display("ERROR: Unkown wb_state: %d", wb_state);
        end
    end
    reg [BUFFER_INDEX_SIZE-1:0] buffer_index;
    reg [BYTE_INDEX_SIZE-1:0] send_iterator;
    reg [BYTE_INDEX_SIZE-1:0] recv_iterator;
    reg [BYTE_SIZE-2:0] data_recv;
    reg [BYTE_SIZE-1:0] data_send;
    reg [1:0] spi_state;
    parameter [1:0]
        S_SPI_WAIT      = 2'd0,
        S_SPI_INIT_NEXT      = 2'd1,
        S_SPI_TRANSFER  = 2'd2,
        S_SPI_DEASSERT  = 2'd3;
    assign clk_out = clk_i;
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i == 1'b1) begin
            spi_state <= S_SPI_WAIT; 
            data_recv <= 0;
            data_send <= 8'h55;
            data_out <= 1'bz;
            send_iterator <= 0;
            recv_iterator <= 0;
            buffer_index <= 0;
            data_recv <= 0;
            data_send <= 0;
            slave_select_out <= 1;
            transfer_complete <= 1;
        end
        else begin
        case(spi_state)
            S_SPI_WAIT: begin
                if (start_transfer && transfer_complete) begin
                    spi_state <= S_SPI_INIT_NEXT;
                    transfer_complete <= 0;
                end
            end
            S_SPI_INIT_NEXT: begin
                data_send <= buffer_send[buffer_index];
                slave_select_out <= 0;
                spi_state <= S_SPI_TRANSFER;
            end
            S_SPI_TRANSFER: begin
                data_out <= data_send[send_iterator];
                 if (send_iterator > 0 && recv_iterator < BYTE_SIZE-1) begin
                    data_recv[recv_iterator] <= data_in;
                    recv_iterator = recv_iterator +1;
                 end
                 if (recv_iterator >= BYTE_SIZE-1) begin
                    spi_state <= S_SPI_DEASSERT;
                 end
                 else
                    send_iterator <= send_iterator + 1;
            end
            S_SPI_DEASSERT: begin
                slave_select_out <= 1;
                data_out <= 1'bz;
                buffer_recv[buffer_index] <= {data_in,data_recv[6:0]};
                send_iterator <= 0;
                recv_iterator <= 0;
                data_recv <= 0;
                data_send <= 0;
                if (buffer_index < BUFFER_SIZE-1) begin
                    buffer_index = buffer_index + 1;
                    spi_state <= S_SPI_INIT_NEXT;
                end
                else begin
                    spi_state <= S_SPI_WAIT;
                    transfer_complete <= 1;
                    buffer_index <= 0;
                 end
            end
            default: begin
                $display("ERROR: Unkown spi_state: %d", spi_state);
            end
        endcase
        end
    end
endmodule
