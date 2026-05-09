module LCD_Driver (
    input        LCLK,
    input        RST_n,
    output reg   HS,
    output reg   VS,
    output       DE,
    output reg [9:0] Column,
    output reg [9:0] Row,
    output reg   SPENA,
    output reg   SPDA_OUT,
    input        SPDA_IN,
    output reg   WrEn,
    output reg   SPCK,
    input  [7:0] Brightness,
    input  [7:0] Contrast
);

    // Internal Registers
    reg [9:0] Column_Counter;
    reg [9:0] Row_Counter;
    reg [9:0] Column_Reg;
    reg [9:0] Row_Reg; // Use internal register for Row calculation

    // Horizontal Timing Constants
    localparam H_SYNC_PULSE   = 10'd56; // HS low duration
    localparam H_BACK_PORCH   = 10'd14; // HS high after pulse, before DE
    localparam H_ACTIVE_WIDTH = 10'd320; // DE high duration (adjust based on 334?)
    localparam H_FRONT_PORCH  = 10'd18; // HS high after DE, before pulse
    localparam H_TOTAL_WIDTH  = H_SYNC_PULSE + H_BACK_PORCH + H_ACTIVE_WIDTH + H_FRONT_PORCH; // 56+14+320+18 = 408

    // Vertical Timing Constants
    localparam V_SYNC_PULSE   = 10'd13; // VS low duration
    localparam V_BACK_PORCH   = 10'd10; // VS high after pulse, before DE
    localparam V_ACTIVE_HEIGHT= 10'd240; // DE high duration
    localparam V_FRONT_PORCH  = 10'd0;  // VS high after DE, before pulse (adjust as needed)
    localparam V_TOTAL_HEIGHT = V_SYNC_PULSE + V_BACK_PORCH + V_ACTIVE_HEIGHT + V_FRONT_PORCH; // 13+10+240+0 = 263

    // Data Enable Signal
    reg H_Active;
    reg V_Active;
    assign DE = H_Active & V_Active;

    // Column Counter and Horizontal Sync (HS) Generation
    always @(posedge LCLK or negedge RST_n) begin
        if (!RST_n) begin
            Column_Counter <= 10'd0;
            Column_Reg     <= 10'd0;
            HS             <= 1'b1; // Assuming HS starts high
            H_Active       <= 1'b0;
        end else begin
            if (Column_Counter == H_TOTAL_WIDTH - 1) begin
                Column_Counter <= 10'd0;
                Column_Reg     <= 10'd0;
            end else begin
                Column_Counter <= Column_Counter + 1'b1;
                if (Column_Counter >= (H_SYNC_PULSE + H_BACK_PORCH) && Column_Counter < (H_SYNC_PULSE + H_BACK_PORCH + H_ACTIVE_WIDTH)) begin
                    Column_Reg <= Column_Reg + 1'b1;
                end
            end

            // HS Generation
            if (Column_Counter < H_SYNC_PULSE) begin
                HS <= 1'b0;
            end else begin
                HS <= 1'b1;
            end

            // H_Active Generation (Data Enable horizontal component)
            if (Column_Counter >= (H_SYNC_PULSE + H_BACK_PORCH) && Column_Counter < (H_SYNC_PULSE + H_BACK_PORCH + H_ACTIVE_WIDTH)) begin
                 H_Active <= 1'b1;
            end else begin
                 H_Active <= 1'b0;
            end
        end
    end

    // Row Counter and Vertical Sync (VS) Generation
    wire H_End = (Column_Counter == H_TOTAL_WIDTH - 1); // Signal indicating end of a horizontal line

    always @(posedge LCLK or negedge RST_n) begin
        if (!RST_n) begin
            Row_Counter <= 10'd0;
            Row_Reg     <= 10'd0;
            VS          <= 1'b1; // Assuming VS starts high
            V_Active    <= 1'b0;
        end else begin
            if (H_End) begin // Increment Row counter only at the end of a line
                if (Row_Counter == V_TOTAL_HEIGHT - 1) begin
                    Row_Counter <= 10'd0;
                    Row_Reg     <= 10'd0;
                end else begin
                    Row_Counter <= Row_Counter + 1'b1;
                     if (Row_Counter >= (V_SYNC_PULSE + V_BACK_PORCH) && Row_Counter < (V_SYNC_PULSE + V_BACK_PORCH + V_ACTIVE_HEIGHT)) begin
                        Row_Reg <= Row_Reg + 1'b1;
                     end
                end

                // VS Generation
                if (Row_Counter < V_SYNC_PULSE) begin
                    VS <= 1'b0;
                end else begin
                    VS <= 1'b1;
                end

                // V_Active Generation (Data Enable vertical component)
                 if (Row_Counter >= (V_SYNC_PULSE + V_BACK_PORCH) && Row_Counter < (V_SYNC_PULSE + V_BACK_PORCH + V_ACTIVE_HEIGHT)) begin
                     V_Active <= 1'b1;
                 end else begin
                     V_Active <= 1'b0;
                 end
            end
        end
    end

    // Assign Column and Row outputs based on internal registers
    always @(posedge LCLK or negedge RST_n) begin
       if (!RST_n) begin
           Column <= 10'd0;
           Row    <= 10'd0;
       end else begin
           if (DE) begin // Output valid Row/Column only when DE is active
               Column <= Column_Reg;
               Row    <= Row_Reg;
           end else begin
               Column <= 10'd0; // Or hold last value? Outputting 0 outside DE is common.
               Row    <= 10'd0;
           end
       end
   end


    // SPI Communication Logic
    reg [7:0] SPCK_Counter;
    wire SPCK_tmp;
    reg SPCK_tmp_dly; // Delayed version for edge detection

    // Generate a slower clock derived from LCLK for SPI bit timing
    always @(posedge LCLK or negedge RST_n) begin
        if (!RST_n) begin
            SPCK_Counter <= 8'd0;
        end else begin
            SPCK_Counter <= SPCK_Counter + 1'b1;
        end
    end
    assign SPCK_tmp = SPCK_Counter[4]; // Example: Divide LCLK by 32

    // Detect rising edge of SPCK_tmp
    always @(posedge LCLK or negedge RST_n) begin
        if (!RST_n) begin
            SPCK_tmp_dly <= 1'b0;
        end else begin
            SPCK_tmp_dly <= SPCK_tmp;
        end
    end
    wire SPCK_tmp_posedge = SPCK_tmp & ~SPCK_tmp_dly;

    // SPI State Machine Data
    reg [7:0] SP_Counter;
    parameter WAKEUP = 16'h0203; // Combined wakeup command/data? Check datasheet.
    wire [15:0] Snd_Data1;
    wire [15:0] Snd_Data2;

    // Construct SPI command/data packets (Check LCD datasheet for exact format)
    // Assuming 8-bit register address + 8-bit data
    assign Snd_Data1 = {8'h26, Brightness}; // Example: Reg 0x26 for Brightness
    assign Snd_Data2 = {8'h22, Contrast};   // Example: Reg 0x22 for Contrast

    reg [15:0] SP_DATA; // Changed width to 16 bits
    reg [15:0] Snd_Old1;
    reg [15:0] Snd_Old2;

    // SPI Clock Generation (SPCK)
    always @(posedge LCLK or negedge RST_n) begin
        if (!RST_n) begin
            SPCK <= 1'b1; // SPI Clock usually idle high (CPOL=1) or low (CPOL=0). Assume high.
        end else begin
            // Generate clock pulses when SPENA is low (active SPI transfer)
            // Assumes CPHA=1 (data sampled on trailing edge, changed on leading edge)
            // Or CPHA=0 (data sampled on leading edge, changed on trailing edge)
            // Let's assume CPHA=0: Clock toggles when SPENA is low.
             if (!SPENA) begin
                 SPCK <= SPCK_tmp; // Or ~SPCK_tmp depending on CPOL
             end else begin
                 SPCK <= 1'b1; // Idle high
             end
        end
    end

    // SPI State Machine / Data Shifting
    // Clocked by LCLK, actions triggered by SPCK_tmp edges (posedge used here)
    always @(posedge LCLK or negedge RST_n) begin
        if (!RST_n) begin
            SP_Counter <= 8'd0;
            SP_DATA    <= WAKEUP; // Load initial command
            SPENA      <= 1'b1;   // Start inactive (Chip Select high)
            Snd_Old1   <= 16'hFFFF; // Initialize to invalid values to force first send
            Snd_Old2   <= 16'hFFFF;
            WrEn       <= 1'b0;   // Write Enable initially low
            SPDA_OUT   <= 1'b0;
        end else begin
            if (SPCK_tmp_posedge) begin // Action on the rising edge of the SPI bit clock
                if (!SPENA) begin // If SPI transfer is active
                    SPDA_OUT   <= SP_DATA[15]; // Output MSB
                    SP_DATA    <= {SP_DATA[14:0], 1'b0}; // Shift data left
                    SP_Counter <= SP_Counter + 1'b1;

                    if (SP_Counter == 8'd15) begin // Last bit shifted out
                        SPENA <= 1'b1; // Deactivate CS
                        // WrEn logic might depend on specific command/response
                        // Assuming WrEn controls writing based on *received* data or just indicates send completion.
                        // The original code checked SP_DATA[15] at count 6 - unclear purpose.
                        // Let's simplify: WrEn signals when a command *could* be written/finished.
                        WrEn <= 1'b0; // Lower WrEn after transmission? Or based on response?

                        // Check if Brightness needs update
                        if (Snd_Data1 != Snd_Old1) begin
                            Snd_Old1   <= Snd_Data1;
                            SP_DATA    <= Snd_Data1;
                            SP_Counter <= 8'd0;
                            SPENA      <= 1'b0; // Start next transfer immediately
                        end
                        // Check if Contrast needs update (only if Brightness didn't)
                        else if (Snd_Data2 != Snd_Old2) begin
                            Snd_Old2   <= Snd_Data2;
                            SP_DATA    <= Snd_Data2;
                            SP_Counter <= 8'd0;
                            SPENA      <= 1'b0; // Start next transfer immediately
                        end
                        // No updates needed
                        else begin
                           // Remain idle (SPENA=1)
                           WrEn <= 1'b0; // Ensure WrEn is low if idle
                        end

                    end else {
                       WrEn <= 1'b0; // Keep WrEn low during transmission
                    }
                end // end if (!SPENA)
                else begin // SPI is idle (SPENA == 1'b1)
                   // Check if updates are pending when idle
                   if (Snd_Data1 != Snd_Old1) begin
                       Snd_Old1   <= Snd_Data1;
                       SP_DATA    <= Snd_Data1;
                       SP_Counter <= 8'd0;
                       SPENA      <= 1'b0; // Activate CS, start transfer on next edge
                       WrEn       <= 1'b0; // Ensure WrEn low at start
                   end else if (Snd_Data2 != Snd_Old2) begin
                       Snd_Old2   <= Snd_Data2;
                       SP_DATA    <= Snd_Data2;
                       SP_Counter <= 8'd0;
                       SPENA      <= 1'b0; // Activate CS, start transfer on next edge
                        WrEn       <= 1'b0; // Ensure WrEn low at start
                   end else begin
                       WrEn <= 1'b0; // Keep WrEn low if idle
                   end
                end // end else (!SPENA)
            end // end if (SPCK_tmp_posedge)
        end // end else (!RST_n)
    end // end always

endmodule