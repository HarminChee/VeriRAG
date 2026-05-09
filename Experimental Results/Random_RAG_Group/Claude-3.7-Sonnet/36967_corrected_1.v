module sht1x_sensor(
		input					rsi_MRST_reset,
		input					csi_MCLK_clk,
		input					test_mode,
		input		[31:0]	avs_ctrl_writedata,
		output	[31:0]	avs_ctrl_readdata,
		input		[3:0]		avs_ctrl_byteenable,
		input		[2:0]		avs_ctrl_address,
		input					avs_ctrl_write,
		input					avs_ctrl_read,
		output				avs_ctrl_waitrequest,
	   output sck, 
		output dir,
		inout  sda
		);
		reg      [31:0] read_data;
		reg      [31:0] write_data;
		reg      [15:0] temperature;
		reg      [15:0] moisture;
		wire     data_ready;
		reg      [14:0] state;
		reg      [14:0] next_state;
		assign	avs_ctrl_readdata = read_data;
		always@(posedge csi_MCLK_clk or posedge rsi_MRST_reset)
		begin
			if(rsi_MRST_reset) begin
				read_data <= 0;
			end
			else if(avs_ctrl_write) 
			begin
				case(avs_ctrl_address)
					0: write_data <= avs_ctrl_writedata;
					default:;
				endcase	
			end
			else begin
				case(avs_ctrl_address)
					0: read_data <= 32;
					1: read_data <= 32'hEA680003;
					2: read_data <= {16'd0,temperature};
					3: read_data <= {16'd0,moisture};
					4: read_data <= {31'd0,data_ready};
					default: read_data <= 0;
				endcase
			end
		end
		wire sck_t;
		wire sck_mux;
		reg [31:0] temp;
		always @(posedge csi_MCLK_clk or posedge rsi_MRST_reset)
		begin
			if(rsi_MRST_reset)
				temp <= 0;
			else
				temp <= temp + 32'd64585974/4/4/2;
		end
		assign sck_t = temp[31];
		assign sck_mux = test_mode ? csi_MCLK_clk : sck_t;
		reg [15:0] measure_date;
		reg [7:0]  crc;
		parameter 
	   Address = 3'b000,
		Measure_Temperature=5'b00011,
		Measure_Relative_Humidity=5'b00101,
		Read_Status_Register=5'b00111,
		Write_Status_Register=5'b00110;
		parameter dir_out = 1'b1;
		parameter dir_in  = 1'b0;
		reg  dir_r;
		reg  sda_r;
		reg  sck_r;
		wire sda_in;
		assign sda_in = sda;
		assign sda = dir_r ? sda_r : 1'bz;
		assign sck = sck_r;
		assign dir = dir_r;
		parameter Reset_0 = 15'd0;
		always @ (posedge csi_MCLK_clk or posedge rsi_MRST_reset)
		begin
			if(rsi_MRST_reset) begin
				state <= Reset_0;
			end else	begin
				state <= next_state;
			end
		end
endmodule