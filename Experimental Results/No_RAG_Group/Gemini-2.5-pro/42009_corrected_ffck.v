`timescale 1ns/1ps
module I2C_MASTER_SUBAD_corrected_ffc (
    clk,
    rst_n,
    sda,
    scl,
    RD_EN,
    WR_EN,
    receive_status
);

input clk; // Primary clock input
input rst_n;
input RD_EN;
input WR_EN;
reg WR,RD;
output scl;
output receive_status;
inout sda;

// Removed scl_clk (internally generated clock)
reg scl_clk_en; // Added clock enable signal
reg receive_status;
reg[7:0] clk_div;
reg[7:0] send_count;
wire[7:0] data;
reg[7:0] data_reg;
wire ack;
reg[7:0] send_memory[33:0];
reg[7:0] receive_memory[33:0];
integer i; // For loop variable

// Clock divider logic modified to generate a clock enable signal
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        scl_clk_en <= 1'b0; // Initialize enable
        clk_div <= 'h0;
        // Initialize memories
        send_memory[0] <= 8'd1;
        send_memory[1] <= 8'd32;
        send_memory[2] <= 8'd0;
        send_memory[3] <= 8'd1;
        send_memory[4] <= 8'd2;
        send_memory[5] <= 8'd3;
        send_memory[6] <= 8'd4;
        send_memory[7] <= 8'd5;
        send_memory[8] <= 8'd6;
        send_memory[9] <= 8'd7;
        send_memory[10] <= 8'd8;
        send_memory[11] <= 8'd9;
        send_memory[12] <= 8'd10;
        send_memory[13] <= 8'd11;
        send_memory[14] <= 8'd12;
        send_memory[15] <= 8'd13;
        send_memory[16] <= 8'd14;
        send_memory[17] <= 8'd15;
        send_memory[18] <= 8'd16;
        send_memory[19] <= 8'd17;
        send_memory[20] <= 8'd18;
        send_memory[21] <= 8'd19;
        send_memory[22] <= 8'd20;
        send_memory[23] <= 8'd21;
        send_memory[24] <= 8'd22;
        send_memory[25] <= 8'd23;
        send_memory[26] <= 8'd24;
        send_memory[27] <= 8'd25;
        send_memory[28] <= 8'd26;
        send_memory[29] <= 8'd27;
        send_memory[30] <= 8'd28;
        send_memory[31] <= 8'd29;
        send_memory[32] <= 8'd30;
        send_memory[33] <= 8'd31;
        for (i=0; i<=33; i=i+1) begin
             receive_memory[i] <= 8'h0;
        end
    end
    else begin
       scl_clk_en <= 1'b0; // Default to low
       if(clk_div == 'd200)begin // Generate enable pulse when counter reaches limit
           scl_clk_en <= 1'b1;
           clk_div <= 'h0;
       end
       else begin
           clk_div <= clk_div + 1'b1;
       end
    end
end

// Modified this block to be synchronous to the primary clock 'clk'
// Updates occur based on the clock enable 'scl_clk_en' and 'ack'
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        send_count <= 'h0;
        // receive_memory initialization moved to the first always block reset section
    end
    else begin
        // Update only when clock enable is active and ack is received
        if (scl_clk_en && ack) begin
            if (send_count < 10'd34) begin
                send_count <= send_count + 1'b1;
                // Note: 'data' comes from the submodule, ensure timing is correct
                receive_memory[send_count] <= RD_EN ? data : 8'h0;
            end
            // No else needed for send_count, it holds its value if conditions aren't met
        end
        // No else needed for send_count, it holds its value if conditions aren't met
    end
end

// This block is already synchronous to the primary clock 'clk'
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
        receive_status <= 1'b0;
   else
        // Check a specific memory location for status
        receive_status <= (receive_memory[31] == 8'd31) ? 1'b1 : 1'b0; // Example condition
end

// This block is already synchronous to the primary clock 'clk'
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        WR         <= 1'b0;
        RD         <= 1'b0;
        data_reg   <= 'h0;
    end
    else begin
       // Logic based on send_count and external enables RD_EN, WR_EN
       if(send_count == 8'd34)begin // Assuming 34 indicates end of transaction
            WR         <= 1'b0;
            RD         <= 1'b0;
            // data_reg holds value
       end
       else begin
           // Prioritize RD_EN? Or WR_EN? Assuming they are mutually exclusive or WR has priority if both asserted
           if(WR_EN) begin // Check WR_EN first
               WR         <= 1'b1;
               RD         <= 1'b0; // Ensure RD is low if WR is active
               data_reg   <= send_memory[send_count];
           end
           else if(RD_EN) begin // Check RD_EN if WR_EN is low
               RD         <= 1'b1;
               WR         <= 1'b0; // Ensure WR is low if RD is active
               // data_reg holds value, not updated during read phase here
           end
           else begin // If neither enable is active
               WR <= 1'b0;
               RD <= 1'b0;
               // data_reg holds value
           end
       end
    end
end

// Assign data based on WR_EN (likely drives sda via submodule when WR is active)
assign data = WR_EN ? data_reg : 8'hz;

// Instantiate the I2C submodule
// Pass the primary clock 'clk' and the generated clock enable 'scl_clk_en'
// Assumes I2C_wr_subad module has ports 'clk' and 'clk_en'
I2C_wr_subad I2C_wr_subad_instance(
                    .sda(sda),
                    .scl(scl),
                    .ack(ack),
                    .rst_n(rst_n),
                    .clk(clk),         // Use primary clock
                    .clk_en(scl_clk_en), // Use clock enable (assuming port 'clk_en' exists in I2C_wr_subad)
                    .WR(WR),
                    .RD(RD),
                    .data(data)
);

endmodule