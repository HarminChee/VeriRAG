`timescale 1ns / 1ps
`timescale 1ns / 1ps
module EEPROM_Top(  clk, rst_n, write_en, flag_write_done,flag_error,flag_read_done,
                    SCL_en, SCL_o, SCL_i, SDA_en, SDA_o, SDA_i,
                    data_in, data_out);
input clk, rst_n, write_en;
output reg flag_write_done,flag_read_done,flag_error;
output reg SCL_en,SCL_o,SDA_en,SDA_o;
input SCL_i,SDA_i;
input [47:0] data_in;
output reg [47:0] data_out;
parameter EN_WRITE = 1'b0, EN_READ = 1'b1;
localparam I2CAddr     = 7'b1010_000; 
localparam DEVICE_READ = 8'b1010_0001,
           DEVICE_WRITE = 8'b1010_0000;
reg [15:0] counter;
reg clk_400kHz;
reg fifo_rst;
wire flag_fifo_empty,flag_fifo_full;
reg fifo_wr_en,fifo_rd_en;
reg [7:0] fifo_data_reg;
wire [7:0] fifo_data_out_reg;
fifo_EEPROM ins_fifo_eeprom(
.rst(fifo_rst),
.wr_clk(clk),
.rd_clk(clk_400kHz),
.din(fifo_data_reg),
.wr_en(fifo_wr_en),
.rd_en(fifo_rd_en),
.dout(fifo_data_out_reg),
.full(flag_fifo_full),
.empty(flag_fifo_empty)
);
always @ ( posedge clk or negedge rst_n )
if (!rst_n) begin
    counter <= 16'd0;
    clk_400kHz <= 0;
end
else begin
  if( counter == 16'd124 ) begin
    counter <= 16'd0;
    clk_400kHz <= ~clk_400kHz;
  end
  else begin
    counter <= counter + 16'd1;
    clk_400kHz <= clk_400kHz;
  end  
end
localparam  STATE_HIGH    = 2'd0,
            STATE_NEGEDGE = 2'd1,
            STATE_LOW     = 2'd2,
            STATE_POSEDGE = 2'd3;
reg [1:0] SCL_state;
always @ (posedge clk_400kHz or negedge rst_n)
if (rst_n) begin
    SCL_en <= 1'b1;
    SCL_o <= 1'b1;
    SCL_state <= STATE_HIGH;
end
else begin
    case (SCL_state)
        STATE_HIGH: begin
            SCL_o <= 1'b1;
            SCL_state <= STATE_NEGEDGE;
        end
        STATE_NEGEDGE: begin
            SCL_o <= 1'b0;
            SCL_state <= STATE_LOW;
        end
        STATE_LOW: begin
            SCL_o <= 1'b0;
            SCL_state <= STATE_POSEDGE;
        end
        STATE_POSEDGE: begin
            SCL_o <= 1'b1;
            SCL_state <= STATE_HIGH;
        end
    endcase
end
reg [3:0] fifo_write_state;
reg [3:0] fifo_write_counter;
localparam SfifoIdle=4'd0, SfifoWait4Idle=4'd1, SfifoWriteAddr=4'd2, SfifoWriteData=4'd3, SfifoStop=4'd4;
always @ (posedge clk or negedge rst_n)
if (~rst_n) begin
    fifo_rst <= 1'b1;
    fifo_wr_en <= 1'b0;
    fifo_data_reg <= 8'd0;
    fifo_write_state <= SfifoIdle;
    fifo_write_counter <= 0;
end
else begin
    fifo_rst <= 1'b0;
    case ( fifo_write_state )
        SfifoIdle: begin
            if ( write_en ) begin
                fifo_wr_en <= 1'b0;
                fifo_write_state <= SfifoWriteAddr;
            end
            else fifo_write_state <= SfifoIdle;
        end
        SfifoWriteAddr: begin
            fifo_wr_en <= 1'b1;
            fifo_data_reg <= fifo_write_counter;
            fifo_write_state <= SfifoWriteData;
        end
        SfifoWriteData: begin
            fifo_wr_en <= 1'b1;
            case (fifo_write_counter)
               4'd0:    fifo_data_reg <= data_in[7:0];  
               4'd1:    fifo_data_reg <= data_in[15:8]; 
               4'd2:    fifo_data_reg <= data_in[23:16];
               4'd3:    fifo_data_reg <= data_in[31:24];
               4'd4:    fifo_data_reg <= data_in[39:32];
               4'd5:    fifo_data_reg <= data_in[47:40];
            endcase
            if ( fifo_write_counter < 5 && fifo_write_counter >=0 ) begin
                fifo_write_counter <= fifo_write_counter + 1;
                fifo_write_state   <= SfifoWriteAddr;
            end
            else if ( fifo_write_counter == 5 ) begin
                fifo_write_counter <= 4'd0;
                fifo_write_state   <= SfifoStop;
            end
        end
        SfifoStop: begin
            fifo_wr_en <= 1'b1;
            fifo_write_state <= SfifoWait4Idle;
        end
        SfifoWait4Idle: begin
            if (!write_en)  fifo_write_state <= SfifoIdle;
            else            fifo_write_state <= SfifoWait4Idle;
        end
    endcase
end
reg [7:0] i2c_state;
localparam Sstop=8'd0, Sidle=8'd1, Sstart=8'd2, Swrite_init=8'd3, Swrite_ack=8'd4, Swrite_byte=8'd5, Sread_init=8'd6, SdummyWrite_ack=8'd7, SdummyWrite_byte=8'd8, Sread_ack=8'd9, Sread_byte=8'd10, Sread_reStart=8'd11, Sread_writeDevice=8'd12;
reg [3:0] i2c_byte_state;
localparam i2c_byte_writeDevice=4'd0, i2c_byte_readAddr=4'd1, i2c_byte_readData=4'd2, i2c_byte_writeData=4'd3,i2c_byte_writeAddr=4'd4;
wire flag_start_write;
reg flag_start,flag_WR;
reg [3:0] shift_counter;
reg [3:0] byte_counter;
reg [7:0] data_reg;
reg i2c_ack;
assign flag_start_write = ( fifo_write_state == SfifoStop )?1'b1:1'b0;
always @ (posedge clk_400kHz or negedge rst_n)
if (rst_n) begin
    SDA_en <= 1'b0;
    SDA_o <= 1'b1;
    shift_counter <= 4'd7;
    byte_counter <= 4'd0;
    i2c_ack <= 1'b0;
    flag_error <= 1'b0;
    flag_write_done <= 1'b0;
    flag_read_done <= 1'b0;
end
else begin
    case (i2c_state)
        Sidle: begin
            SDA_o <= 1'b1;
            if( flag_start && SCL_state == STATE_POSEDGE ) begin
                SDA_en <= EN_WRITE;
                i2c_state <= Sstart;
            end
            else begin
                SDA_en <= EN_READ;
                i2c_state <= Sidle;
            end
        end
        Sstart: begin
            if(SCL_state == STATE_HIGH) begin
                SDA_o <= 1'b0;
                shift_counter <= 4'd7;
                data_reg <= DEVICE_WRITE;
                if (flag_WR == EN_WRITE) begin
                    i2c_byte_state <= i2c_byte_writeDevice;
                    i2c_state <= Swrite_byte;             
                end
                else begin
                    i2c_byte_state <= i2c_byte_writeDevice;
                    i2c_state <= SdummyWrite_byte;
                end
            end
            else begin
                i2c_state <= Sstart;
            end
        end
        Swrite_ack: begin
            SDA_en <= EN_READ;
            shift_counter <= 4'd7;
            if ( SCL_state == STATE_HIGH ) begin
                case (i2c_byte_state)
                    i2c_byte_writeDevice: begin
                        i2c_state <= Swrite_ack;
                        i2c_byte_state <= i2c_byte_writeAddr;
                        data_reg <= 8'h00;
                    end
                    i2c_byte_writeAddr: begin
                        i2c_state <= Swrite_ack;
                        fifo_rd_en <= 1;
                        i2c_byte_state <= i2c_byte_writeData;
                    end
                    i2c_byte_writeData: begin
                        if (flag_fifo_empty) begin
                            i2c_state <= Sstop;
                            flag_write_done <= 1'b1;
                        end
                        else begin
                            i2c_state <= Swrite_ack;
                            fifo_rd_en <= 1;
                            i2c_byte_state <= i2c_byte_writeData;
                        end
                    end
                endcase
            end
            else if ( SCL_state == STATE_NEGEDGE && i2c_byte_state == i2c_byte_writeData ) begin
                fifo_rd_en <= 0;
                i2c_state <= Swrite_ack;
            end
            else if ( SCL_state == STATE_LOW ) begin
                i2c_ack <= SDA_i;
                data_reg <= fifo_data_out_reg;
                i2c_state <= Swrite_byte;
            end
            else i2c_state <= Swrite_ack;
        end
        Swrite_byte: begin
            SDA_en <= EN_WRITE;
            if ( SCL_state == STATE_LOW && shift_counter <= 4'd7 && shift_counter >= 4'd0 ) begin
                SDA_o <= data_reg[shift_counter];
                shift_counter <= shift_counter - 1'd1;
                if (shift_counter == 0) i2c_state <= Swrite_ack;
                else                    i2c_state <= Swrite_byte;
            end
            else begin
                i2c_state <= Swrite_byte;
            end
        end
        SdummyWrite_ack: begin
            shift_counter <= 4'd7;
            if ( SCL_state == STATE_HIGH ) begin
                SDA_en <= EN_READ;
                case (i2c_byte_state)
                    i2c_byte_writeDevice: begin
                        i2c_state <= SdummyWrite_ack;
                        i2c_byte_state <= i2c_byte_writeAddr;
                        data_reg <= 8'h00;
                    end
                    i2c_byte_writeAddr: begin
                        i2c_state <= SdummyWrite_ack;
                        i2c_byte_state <= i2c_byte_writeData;
                    end
                endcase
            end
            else if ( SCL_state == STATE_LOW ) begin
                i2c_ack <= SDA_i;
                data_reg <= 8'h00;
                SDA_o <= 1'b1;
                SDA_en <= EN_WRITE;
                i2c_state <= Sread_reStart;
            end
            else i2c_state <= SdummyWrite_ack;
        end
        SdummyWrite_byte: begin
            SDA_en <= EN_WRITE;
            if ( SCL_state == STATE_LOW && shift_counter <= 4'd7 && shift_counter >= 4'd0 ) begin
                SDA_o <= data_reg[shift_counter];
                shift_counter <= shift_counter - 4'd1;
                if (shift_counter == 0) i2c_state <= SdummyWrite_ack;
                else                    i2c_state <= SdummyWrite_byte;
            end
            else begin
                i2c_state <= SdummyWrite_byte;
            end
        end
        Sread_reStart: begin
            SDA_en <= EN_WRITE;
            if ( SCL_state == STATE_HIGH ) begin
                SDA_o <= 1'b0;
                i2c_state <= Sread_writeDevice;
                data_reg <= DEVICE_READ;
                shift_counter <= 4'd7;
            end
            else begin
                i2c_state <= Sread_reStart;
            end
        end
        Sread_writeDevice: begin
            if ( SCL_state == STATE_LOW && shift_counter <= 4'd7 && shift_counter >= 4'd0 ) begin
                SDA_en <= EN_WRITE;
                SDA_o <= data_reg[shift_counter];
                shift_counter <= shift_counter - 4'd1;
                i2c_state <= Sread_writeDevice;
            end
            else if ( SCL_state == STATE_POSEDGE && shift_counter == 4'd0 ) begin
                SDA_en <= EN_READ;
                i2c_state <= Sread_writeDevice;
            end
            else if ( SCL_state == STATE_HIGH && shift_counter == 4'd0 ) begin 
                SDA_en <= EN_READ;
                shift_counter <= 4'd7;
                i2c_ack <= SDA_i;
                i2c_state <= Sread_byte;
            end
            else i2c_state <= Sread_writeDevice;
        end
        Sread_ack: begin
            SDA_en <= EN_WRITE;
            if ( SCL_state == STATE_LOW ) begin
                SDA_o <= 1'b0;
                if ( byte_counter[0] == 1'b1 ) begin
                    if ( data_reg[2:0] == byte_counter[3:1] ) begin
                        i2c_state <= Sread_ack;
                        flag_error <= 1'b0;
                    end
                    else begin
                        i2c_state <= Sstop;
                        flag_error <= 1'b1;
                    end
                end
                else if ( byte_counter[0] == 1'b0 ) begin
                    data_out <= {data_reg,data_out[47:8]};
                    i2c_state <= Sread_ack;
                end
            end
            else if ( SCL_state == STATE_HIGH ) begin
                if ( byte_counter == 4'd12 ) begin
                    flag_read_done <= 1'b1;
                    i2c_state <= Sstop;
                end
                else begin
                    i2c_state <= Sread_byte;
                end
            end
            else i2c_state <= Sread_ack;
        end
        Sread_byte: begin
            SDA_en <= EN_READ;
            if ( SCL_state == STATE_HIGH && shift_counter <= 4'd7 && shift_counter >= 4'd0 ) begin
                data_reg <= {data_reg[6:0],SDA_i};
                if (shift_counter == 0) begin
                    byte_counter <= byte_counter + 1;
                    i2c_state <= Sread_ack;
                end
                else i2c_state <= Sread_byte;
                shift_counter <= shift_counter - 4'd1;
            end
            else begin
                i2c_state <= Sread_byte;
            end
        end
        Sstop: begin
            SDA_en <= EN_WRITE;
            flag_error <= 1'b0;
            flag_read_done <= 1'b0;
            flag_write_done <= 1'b0;
            if ( SCL_state == STATE_HIGH ) begin
                SDA_o <= 1'b1;
                i2c_state <= Sidle;
            end
            else    i2c_state <= Sstop;
        end
    endcase
end
endmodule
