module spi_controller(
    input   clk,
    input   RST_N,
    output  o_IRQ,
    input   wire [31:0] i_data_to_registers,
    input   wire        i_wr_controll_reg,  
    input   wire        i_wr_data_reg,      
    input   wire        i_read_status_reg,
    output  wire [31:0] o_controll_reg,
    output  wire [31:0] o_status_reg,
    output  wire [31:0] o_data_reg,
    input   i_miso,
    output  o_mosi,
    output  o_sclk
    );
reg [31:0] q_controll_reg;
wire [31:0] w_status_reg;
reg [7:0] q_data_reg;
reg [7:0]   q_spi_bit_cntr;
reg [2:0]   q_spi_byte_cntr; 
reg         q_irq_flag;
reg        q_collision_flag;
reg [7:0]  q_spi_mosi_shr;
reg [7:0]  q_spi_miso_shr;
wire w_setup_spi_data;
wire w_sample_spi_data;
wire w_active_spi_transaction;
wire w_sclk_reset;
wire w_reset;
wire w_dword;
wire w_cpol;
wire w_cpha;
wire w_spr1;
wire w_spr0;
assign o_controll_reg   = q_controll_reg;
assign o_status_reg     = w_status_reg;
assign o_data_reg       = q_spi_miso_shr;
assign w_reset          = ~RST_N;
assign w_irq_en         = q_controll_reg[7];
assign w_spie           = q_controll_reg[6];
assign w_dword          = q_controll_reg[5];
assign w_cpol           = q_controll_reg[3];
assign w_cpha           = q_controll_reg[2];
assign w_spr1           = q_controll_reg[1];
assign w_spr0           = q_controll_reg[0];
assign w_sclk_reset     = w_reset | ~w_active_spi_transaction;
spi_clock_generator spi_clock_generator_inst(
    .i_clk(clk),
    .i_reset(w_sclk_reset),
    .i_spr0(w_spr0),
    .i_spr1(w_spr1),
    .i_cpol(w_cpol),
    .i_cpha(w_cpha),
    .i_mstr(1'b1),
    .o_sclk(o_sclk),
    .o_sclk_rising_edge(),
    .o_sclk_falling_edge(),
    .o_sample_spi_data(w_sample_spi_data),
    .o_setup_spi_data(w_setup_spi_data)
    );
assign w_status_reg = {q_irq_flag, q_collision_flag, 6'b0};
always @(posedge clk) begin
    if(w_reset)
        q_controll_reg <= '0;
    if(i_wr_controll_reg) begin
        q_controll_reg <= i_data_to_registers;
    end
end
always @(posedge clk) begin
    if (w_reset)
        q_data_reg <= '0;
    else if(i_wr_data_reg) begin
        q_data_reg <= i_data_to_registers;
    end
    if(w_active_spi_transaction) begin
        if(w_setup_spi_data) begin
            if(w_dword) begin
                q_data_reg <= {1'b0, q_data_reg[7:1]};
            end else begin
                q_data_reg <= {q_data_reg[6:0], 1'b0};
            end
        end
    end
end
always @(posedge clk) begin
    if(w_reset) begin
        q_spi_bit_cntr <= 8;
    end else begin
        if (i_wr_data_reg) begin
            q_spi_bit_cntr <= 0;
        end else begin
            if(w_setup_spi_data) begin
                if(w_active_spi_transaction)
                    q_spi_bit_cntr <= q_spi_bit_cntr + 1;
            end
        end
    end
end
assign w_active_spi_transaction = q_spi_bit_cntr <8;
always @(posedge clk) begin
    if (w_reset) 
        q_irq_flag <= 1'b0;
    else if(q_spi_bit_cntr == 7 && w_sample_spi_data) begin
        q_irq_flag <= 1'b1;
    end else begin
        if(i_read_status_reg)
            q_irq_flag <= 1'b0;
    end
end
assign o_IRQ = q_irq_flag;
always @(posedge clk) begin
    if(w_reset) begin
        q_collision_flag <= 1'b0;
    end else begin
        if(w_active_spi_transaction) begin
            if(i_wr_controll_reg | i_wr_data_reg)
                q_collision_flag <= 1'b1;
        end else begin
            if(i_read_status_reg)
                q_collision_flag <= 1'b0;
        end
    end
end
always @(posedge clk) begin
    if(w_sample_spi_data) begin
        if(w_dword) begin
            q_spi_miso_shr <= {i_miso, q_spi_miso_shr[7:1]};
        end else begin
            q_spi_miso_shr <= {q_spi_miso_shr[6:0], i_miso};
        end
    end   
end
assign o_mosi = w_dword ? (q_data_reg[0]) : q_data_reg[7];
endmodule
