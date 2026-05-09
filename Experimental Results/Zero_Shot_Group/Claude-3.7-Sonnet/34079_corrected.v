module SPI_MASTER_ADC #(parameter outBits = 16)(
    input               SYS_CLK,
    input               ENA,
    input    [15:0]     DATA_MOSI,
    input               MISO,
    output              MOSI,
    output  reg         CSbar,
    output              SCK,
    output  reg         FIN,
    output  [15:0]      DATA_MISO
);

    reg    [(outBits-1):0]    data_in         = 0;            
    reg    [(outBits-1):0]    data_in_final   = 0;            
    reg    [(outBits-1):0]    data_out        = 0;            
    reg    [5:0]              icounter        = 0;            
    reg    [5:0]              ocounter        = 0;            
    reg    [1:0]              CLK_16          = 0;

    always @(posedge SYS_CLK)
        CLK_16 <= CLK_16 + 1;

    wire SPI_CLK = CLK_16[1];

    assign SCK        = SPI_CLK;
    assign DATA_MISO  = data_in_final;

    always @(posedge SPI_CLK)
        CSbar <= ~ENA;

    always @(posedge SPI_CLK)
        FIN <= (ocounter >= outBits) & (icounter >= outBits);

    always @(posedge SPI_CLK) begin
        case (CSbar)
            1'b1: begin
                icounter  <= 0;
                data_in   <= 0;
            end
            1'b0: begin            
                if (icounter < outBits) begin
                    data_in   <= {data_in[(outBits-2):0], MISO};
                    icounter  <= icounter + 1;
                end
                else begin
                    data_in_final <= data_in;
                end
            end
        endcase
    end

    assign MOSI = data_out[(outBits-1)];

    always @(posedge SPI_CLK) begin
        case (CSbar)
            1'b1: begin                
                ocounter <= 0;
                data_out <= DATA_MOSI;    
            end
            1'b0: begin
                if (ocounter < outBits) begin
                    data_out <= {data_out[(outBits-2):0], 1'b0};
                    ocounter <= ocounter + 1;
                end
            end
        endcase
    end

endmodule