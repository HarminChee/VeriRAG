`timescale 1ns/1ps
// (1)_corrected_ffc.v
module I2C_MASTER(clk,rst_n,sda,scl,RD_EN,WR_EN,receive_status,tx_start,tx_data,tx_complete,bps_start_t,capture_rst
);
input clk; // Primary clock input
input rst_n; // Primary reset input
input RD_EN;
input WR_EN;
input tx_complete;
input bps_start_t;
input capture_rst;
reg WR,RD;
output scl; // SCL line driven by I2C_wr module
output receive_status;
output tx_start; // Driven by check_pin module
output [7:0] tx_data; // Driven by check_pin module
// wire [7:0] tx_data; // Declared as output, cannot be wire here. Remove this line.
inout sda; // SDA line driven/read by I2C_wr module

// Remove internal clock generation register
// reg scl_clk;

// Add enable signal for logic previously clocked by scl_clk
reg scl_enable;

reg receive_status;
reg[7:0] clk_div;
reg[7:0] send_count;
wire[7:0] data; // Data bus between master logic and I2C_wr
reg[7:0] data_reg; // Register to hold data for writing
reg end_ready;
wire ack; // Acknowledge signal from I2C_wr
wire tx_end; // From check_pin
reg[7:0] send_memory[31:0];
reg[7:0] receive_memory[31:0];

// Instantiate check_pin module (remains unchanged)
check_pin  check_pin_instance(
										.clk(clk),
										.rst_n(rst_n),
										.tx_start(tx_start),
										.capture_ready((send_count == 10'd32) && RD_EN && end_ready), // Corrected width 10'd32
										.tx_data(tx_data),
										.tx_complete(tx_complete),
										.tx_end(tx_end),
										.bps_start_t(bps_start_t),
										.receive_status(receive_status),
										.capture_rst(capture_rst)
										);

// Logic for end_ready (remains unchanged)
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
	end_ready <= 1'b0;
	else
	end_ready <= tx_end ? 1'b0 : 1'b1;
end

// Generate scl_enable instead of scl_clk
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		// scl_clk <= 1'b0; // Remove scl_clk assignment
		scl_enable <= 1'b0; // Reset enable signal
		clk_div <= 'h0;
		// Initialize send_memory (can be simplified if synthesis tool supports it)
		// Or use a loop or initial block for simulation / FPGA initialization
		send_memory[0] <= 8'd0; send_memory[1] <= 8'd1; send_memory[2] <= 8'd2; send_memory[3] <= 8'd3;
		send_memory[4] <= 8'd4; send_memory[5] <= 8'd5; send_memory[6] <= 8'd6; send_memory[7] <= 8'd7;
		send_memory[8] <= 8'd8; send_memory[9] <= 8'd9; send_memory[10] <= 8'd10; send_memory[11] <= 8'd11;
		send_memory[12] <= 8'd12; send_memory[13] <= 8'd13; send_memory[14] <= 8'd14; send_memory[15] <= 8'd15;
		send_memory[16] <= 8'd16; send_memory[17] <= 8'd17; send_memory[18] <= 8'd18; send_memory[19] <= 8'd19;
		send_memory[20] <= 8'd20; send_memory[21] <= 8'd21; send_memory[22] <= 8'd22; send_memory[23] <= 8'd23;
		send_memory[24] <= 8'd24; send_memory[25] <= 8'd25; send_memory[26] <= 8'd26; send_memory[27] <= 8'd27;
		send_memory[28] <= 8'd28; send_memory[29] <= 8'd29; send_memory[30] <= 8'd30; send_memory[31] <= 8'd31;
	end
	else begin
	   // Generate a single cycle enable pulse when counter reaches the threshold
	   if(clk_div == 'd200) begin // Use exact count for enable pulse
			// scl_clk <= ~scl_clk; // Remove internal clock toggle
			clk_div <= 'h0;
			scl_enable <= 1'b1; // Assert enable for one cycle
		end
	   else begin
			clk_div <= clk_div + 1'b1;
			scl_enable <= 1'b0; // Deassert enable otherwise
		end
	end
end

// Modify the block previously clocked by 'ack' to use the primary 'clk'
// and use 'ack' as a condition/enable.
always @(posedge clk or negedge rst_n)begin
	integer i; // Declare loop variable for reset
	if(!rst_n)begin
		send_count <= 'h0;
		// Initialize receive memory during reset
		for (i=0; i<32; i=i+1) begin
			receive_memory[i] <= 8'h0;
		end
	end
	else begin
		// Use 'ack' as an enable condition for counter increment and memory write
		if(ack && (send_count < 10'd32)) begin // Corrected width 10'd32
			send_count <= send_count + 1'b1;
			// Write to receive memory only if RD_EN is active during the acknowledged cycle
			if (RD_EN) begin
				// Write data to the memory location corresponding to the current count
				// This happens in the same cycle the count increments, so data corresponds to 'send_count' index
				receive_memory[send_count] <= data;
			end
			// Removed the problematic ': 8'h0' part from the original conditional assignment
		end
		// If ack is low or send_count >= 32, send_count retains its value (implicit)
		// and no write to receive_memory occurs in this block based on 'ack'.
	end
end

// Logic for receive_status (remains unchanged)
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
	receive_status <= 1'b0;
	else
	// Check the last location of receive memory - Use correct index 31
	receive_status <= (receive_memory[31] == 8'd31) ? 1'b1 : 1'b0; // Assuming this check is intended logic
end

// Logic for WR, RD, data_reg (remains unchanged)
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		WR         <= 1'b0;
		RD         <= 1'b0;
		data_reg   <= 'h0;
	end
	else begin
	   if(send_count == 10'd32) begin // Use consistent width 10'd32
			WR         <= 1'b0;
			RD         <= 1'b0;
			// data_reg retains value, maybe reset here? data_reg <= 'h0; depends on intent
		end
		else begin
		  // Prioritize RD_EN? Or WR_EN? Assume mutually exclusive or WR has priority if both asserted.
		  // Original code implies if RD_EN is high, RD becomes high. If WR_EN is high (and RD_EN is not), WR becomes high.
		  // Let's refine this slightly for clarity, assuming they might not be exclusive
		  RD <= 1'b0; // Default values
		  WR <= 1'b0;
		  if(RD_EN) begin
				RD <= 1'b1;
				// WR <= 1'b0; // Ensure WR is low if RD is active
		  end
		  else if(WR_EN) begin // Only consider WR if RD is not active
				WR <= 1'b1;
				data_reg <= send_memory[send_count];
				// RD <= 1'b0; // Ensure RD is low if WR is active
		  end
		end
	end
end

// Assign data based on WR_EN (remains unchanged)
// Consider if data should be driven only when WR is active?
// assign data = WR ? data_reg : 8'hz; // Alternative: Drive based on internal WR signal
assign data = WR_EN ? data_reg :  8'hz; // Keep original assignment based on WR_EN input

// Instantiate I2C_wr module
// Pass the primary clock 'clk' and the generated 'scl_enable' signal
// The I2C_wr module itself must be modified internally to use 'clk' and 'scl_enable'
I2C_wr I2C_wr_instance(
					.sda(sda),
					.scl(scl),         // Output SCL signal
					.ack(ack),         // Output ACK signal
					.rst_n(rst_n),
					.clk(clk),         // Use primary clock 'clk'
					.clk_enable(scl_enable), // Pass the enable signal
					.WR(WR),           // Pass internal WR control signal
					.RD(RD),           // Pass internal RD control signal
					.data(data)        // Pass data bus
);

endmodule