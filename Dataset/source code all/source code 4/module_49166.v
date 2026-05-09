module camera_capture #(
        parameter N = 12
    ) (
        input clock,
        input reset_n,
        input [11:0] in_width,
        input [11:0] in_height,
        input in_start,
        input in_line_valid,
        input in_frame_valid,
        input [N-1:0] in_data,
        output  [31:0]  oFrame_Cont,
        output out_valid,
        output [N-1:0] out_data,
        output [11:0] out_count_x,
        output [11:0] out_count_y,
        output out_captured
    );
    reg [11:0] COLUMN_WIDTH;
    reg [11:0] ROW_HEIGHT;
    always @(posedge clock)
    begin
        if (!reset_n) begin
            COLUMN_WIDTH[11:0] <= {in_width[10:0], 1'b0}; 
            ROW_HEIGHT[11:0] <= {in_height[10:0], 1'b0}; 
        end
    end
    reg captured;
    reg _captured;
    reg start;
    always @(posedge clock)
    begin
        if (reset_n) begin
            _captured <= captured;
            if (captured && !_captured) begin 
                start <= 1'b0;
            end
            else if (in_start) begin
                start <= 1'b1;
            end
        end
        else begin
            start <= 1'b0;
        end
    end
    reg _in_frame_valid;
    reg capture_valid;
    reg frame_valid;
    reg [N-1:0] data_valid;
    reg [31:0]  Frame_Cont;
    assign  oFrame_Cont =   Frame_Cont;
    always @(posedge clock)
    begin
        _in_frame_valid <= in_frame_valid;
        if (start & !captured) begin
            frame_valid <= in_frame_valid & in_line_valid;
            data_valid[N-1:0] <= in_data[N-1:0];
            if (in_frame_valid && !_in_frame_valid) begin 
                capture_valid <= 1'b1;
            end
            else if(!in_frame_valid && _in_frame_valid) begin 
                capture_valid <= 1'b0;
                Frame_Cont  <=  Frame_Cont+1;
            end
        end
        else begin
            frame_valid <= 1'b0;
            capture_valid <= 1'b0;
            data_valid[N-1:0] <= 0;
        end
    end
    reg valid;
    reg [N-1:0] data;
    reg [11:0] count_x;
    reg [11:0] count_y;
    always @(posedge clock)
    begin
        if (start & !captured) begin
            valid <= capture_valid & frame_valid;
            data[N-1:0] <= data_valid[N-1:0];
            if (valid) begin
                if (count_x < (COLUMN_WIDTH - 1)) begin
                    count_x[11:0] <= count_x[11:0] + 16'd1;
                end
                else begin
                    if (count_y < (ROW_HEIGHT - 1)) begin
                        count_x[11:0] <= 12'd0;
                        count_y[11:0] <= count_y[11:0] + 16'd1;
                    end
                end
            end
            if ((count_x == (COLUMN_WIDTH - 1)) && 
                (count_y == (ROW_HEIGHT - 1))) begin
                captured <= 1'b1;
            end
        end
        else begin
            valid <= 1'b0;
            data[N-1:0] <= 0;
            count_x[11:0] <= 12'd0;
            count_y[11:0] <= 12'd0;
            captured <= 1'b0;
        end
    end
    assign out_valid = valid;
    assign out_data[N-1:0] = data[N-1:0];
    assign out_count_x[11:0] = count_x[11:0];
    assign out_count_y[11:0] = count_y[11:0];   
    assign out_captured = (start) ? captured : 1'b1;
endmodule
