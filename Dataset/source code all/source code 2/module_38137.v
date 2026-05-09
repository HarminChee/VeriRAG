`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module polyphase_filter #
(
	parameter integer NUMBER_TAPS 				= 32,
	parameter integer DATA_IN_WIDTH 			= 16,
	parameter integer DATA_OUT_WIDTH 			= 16,
	parameter integer COEFFICIENT_WIDTH 		= 16,
	parameter integer RATE_CHANGE 				= 8,
	parameter integer DECIMATE_INTERPOLATE 		= 1 
)
(
	input wire  						data_in_aclk,
	input wire  						data_in_aresetn,
	output wire							data_in_tready,
	input wire 	[DATA_IN_WIDTH-1:0] 	data_in_tdata,
	input wire  						data_in_tlast,
	input wire  						data_in_tvalid,
	input wire  						data_out_aclk,
	input wire  						data_out_aresetn,
	input wire 							data_out_tready,
	output wire [DATA_OUT_WIDTH-1:0] 	data_out_tdata,
	output wire							data_out_tlast,
	output wire							data_out_tvalid,
	input wire  						coefficients_in_aclk,
	input wire  						coefficients_in_aresetn,
	output wire 						coefficients_in_tready,
	input wire 	[COEFFICIENT_WIDTH-1:0]	coefficients_in_tdata,
	input wire  						coefficients_in_tlast,
	input wire  						coefficients_in_tvalid
);
	localparam AXI_WIDTH 					= 32;
	localparam INPUT_DELAY 					= 1;
	localparam SUB_LENGTH 					= NUMBER_TAPS/RATE_CHANGE;
	localparam CARRY_LENGTH 				= SUB_LENGTH + RATE_CHANGE + INPUT_DELAY;
	localparam INTERP_WIDTH 				= $clog2(RATE_CHANGE);
	localparam RATE_COUNT_WIDTH 			= $clog2(RATE_CHANGE);
	localparam SUB_COUNT_WIDTH 				= $clog2(SUB_LENGTH);
	localparam DATA_CARRY_LENGTH 			= RATE_CHANGE+2;
	localparam DATA_REV_CARRY_LENGTH 		= RATE_CHANGE+2;
	localparam CALC_CARRY_LENGTH 			= RATE_CHANGE;		
	localparam DATA_REV_DELAY_CARRY_LENGTH 	= RATE_CHANGE+2;
	localparam OUTPUT_SHIFT					= $clog2(NUMBER_TAPS)*0;
	wire 							clock;
	wire 							reset;
	reg [$clog2(RATE_CHANGE)-1:0]	phase_counter;
	reg [DATA_IN_WIDTH-1:0]			data_in_tdata_array [RATE_CHANGE-1:0];
	wire [RATE_CHANGE-1:0]			data_in_tready_array;
	reg [RATE_CHANGE-1:0]			data_in_tvalid_array;
	reg [RATE_CHANGE-1:0]			data_in_tlast_array;
	reg								data_in_tlast_latched;
	wire [DATA_OUT_WIDTH-1:0]		data_out_tdata_array [RATE_CHANGE-1:0];
	wire [RATE_CHANGE-1:0]			data_out_tready_array;
	wire [RATE_CHANGE-1:0]			data_out_tvalid_array;
	wire [RATE_CHANGE-1:0]			data_out_tlast_array;
	wire [RATE_CHANGE-1:0]			coefficients_in_tready_array;
	reg [RATE_CHANGE-1:0]			coefficients_in_tvalid_array;
	wire [RATE_CHANGE-1:0]			coefficients_in_tlast_array;
	wire [RATE_CHANGE-1:0]			samples_remaining_array;
	assign clock = DECIMATE_INTERPOLATE ? data_out_aclk : data_in_aclk;
	assign reset = !data_in_aresetn | (data_out_tlast & data_out_tvalid & data_out_tready);
	assign coefficients_in_tready = &coefficients_in_tready_array;
	always @(posedge clock) begin
		if (reset | coefficients_in_tlast | data_out_tlast) begin
			coefficients_in_tvalid_array <= 1;
		end
		else begin
			if (coefficients_in_tvalid & coefficients_in_tready) begin
				coefficients_in_tvalid_array <= {coefficients_in_tvalid_array[RATE_CHANGE-2:0], coefficients_in_tvalid_array[RATE_CHANGE-1]};
			end
			else begin
				coefficients_in_tvalid_array <= coefficients_in_tvalid_array;
			end
		end
	end
	genvar i;
	generate
		if (DECIMATE_INTERPOLATE == 0) begin
		end
		else begin
			for (i = 0; i < RATE_CHANGE; i = i + 1) begin
				always @(posedge clock) begin
					if(reset) begin
						data_in_tdata_array[i] <= 0;
					end
					else begin
						if (data_in_tvalid & data_in_tready) begin
							data_in_tdata_array[i] = data_in_tdata;
						end
						else begin
							data_in_tdata_array[i] = data_in_tdata_array[i];
						end
					end
				end
				always @(posedge clock) begin
					if(reset) begin
						data_in_tlast_array[i] <= 0;
					end
					else begin
						if (data_in_tvalid & data_in_tready & data_in_tlast) begin
							data_in_tlast_array[i] = data_in_tlast;
						end
						else begin
							data_in_tlast_array[i] = data_in_tlast_array[i];
						end
					end
				end
			end
			assign data_in_tready = (|data_in_tready_array) & (phase_counter == (RATE_CHANGE-1));
			assign data_out_tready_array = {RATE_CHANGE{data_out_tready}} & 2**phase_counter;
			always @(posedge clock) begin
				if(reset) begin
					data_in_tvalid_array <= 0;
				end
				else begin
					if (data_in_tvalid & data_in_tvalid) begin
						data_in_tvalid_array <= {RATE_CHANGE{data_in_tvalid}};
					end
					else begin
						data_in_tvalid_array <= data_in_tvalid_array;
					end
				end
			end
			always @(posedge clock) begin
				if(reset) begin
					phase_counter <= RATE_CHANGE-1;
				end
				else begin
					if ((data_in_tvalid & data_out_tready & (|data_in_tready_array)) | (data_out_tready & data_in_tlast_latched)) begin
						phase_counter <= (phase_counter + 1) % RATE_CHANGE;
					end
					else begin
						phase_counter <= phase_counter;
					end
				end
			end
			assign data_out_tdata = data_out_tdata_array[(phase_counter-1)%RATE_CHANGE];
			always @(posedge clock) begin
				if(reset) begin
					data_in_tlast_latched <= 0;
				end
				else begin
					data_in_tlast_latched <= !data_out_tlast & (data_in_tlast_latched | data_in_tlast);
				end
			end
			assign data_out_tlast = data_out_tlast_array[RATE_CHANGE-1];
			assign data_out_tvalid = data_out_tvalid_array[(phase_counter-1) % RATE_CHANGE] ;
		end
	endgenerate
	genvar dsp_array;
	generate
	for (dsp_array=0; dsp_array < RATE_CHANGE; dsp_array=dsp_array+1)
		begin : fir_filter
			fir_filter #(
				.NUMBER_TAPS(SUB_LENGTH),
				.DATA_IN_WIDTH(DATA_IN_WIDTH),
				.COEFFICIENT_WIDTH(COEFFICIENT_WIDTH),
				.DATA_OUT_WIDTH(DATA_OUT_WIDTH)
			) fir_filter_inst (
				.data_in_aclk(data_in_aclk),
				.data_in_aresetn(data_in_aresetn & !reset),
				.data_in_tready(data_in_tready_array[dsp_array]),
				.data_in_tdata(data_in_tdata_array[dsp_array]),
				.data_in_tlast(data_in_tlast_array[dsp_array]),
				.data_in_tvalid(data_in_tvalid_array[dsp_array]),
				.data_out_aclk(data_out_aclk),
				.data_out_aresetn(data_out_aresetn),
				.data_out_tready(data_out_tready_array[dsp_array]),
				.data_out_tdata(data_out_tdata_array[dsp_array]),
				.data_out_tlast(data_out_tlast_array[dsp_array]),
				.data_out_tvalid(data_out_tvalid_array[dsp_array]),
				.coefficients_in_aclk(coefficients_in_aclk),
				.coefficients_in_aresetn(coefficients_in_aresetn),
				.coefficients_in_tready(coefficients_in_tready_array[dsp_array]),
				.coefficients_in_tdata(coefficients_in_tdata),
				.coefficients_in_tlast(coefficients_in_tlast_array[dsp_array]),
				.coefficients_in_tvalid(coefficients_in_tvalid_array[dsp_array] & coefficients_in_tvalid),
				.samples_remaining(samples_remaining_array[dsp_array])
			);
		end
	endgenerate
endmodule
