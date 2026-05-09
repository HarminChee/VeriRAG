module dispatch(
    input clk,
    input rst_n,
    input exe2disp_data_wr,
    input [133:0] exe2disp_data,
    input exe2disp_valid_wr,
    input exe2disp_valid,
    output reg disp2exe_alf,
    input exe2disp_direction_req,
    input exe2disp_direction,
    output reg disp2up_data_wr,
    output  [133:0] disp2up_data,
    output reg disp2up_valid_wr,
    output disp2up_valid,
    input up2disp_alf,
    output reg disp2down_data_wr,
    output  [133:0] disp2down_data,
    output reg disp2down_valid_wr,
    output disp2down_valid,
    input down2disp_alf
);
reg [133:0] data_buff;
reg [1:0] disp_state;
assign disp2up_data = data_buff;
assign disp2down_data = data_buff;
assign disp2up_valid = disp2up_valid_wr;
assign disp2down_valid = disp2down_valid_wr;
always @ * begin
    if(exe2disp_direction_req == 1'b1) begin
        if(exe2disp_direction == 1'b0) begin
            disp2exe_alf = up2disp_alf;
        end
        else begin
            disp2exe_alf = down2disp_alf;
        end
    end
    else begin
        disp2exe_alf = 1'b1;
    end
end
localparam  IDLE_S = 2'd0,
            TRANS_UP_S = 2'd1,
            TRANS_DOWN_S = 2'd2;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        disp2up_data_wr <= 1'b0;
        disp2up_valid_wr <= 1'b0;
        disp2down_data_wr <= 1'b0;
        disp2down_valid_wr <= 1'b0;
        disp_state <= IDLE_S;
    end
    else begin
        case(disp_state)
            IDLE_S: begin
                if(exe2disp_data_wr == 1'b1) begin
                    data_buff <= exe2disp_data;
                    if(exe2disp_direction == 1'b0) begin
                        disp2up_data_wr <= exe2disp_data_wr;
                        disp2up_valid_wr <= exe2disp_valid_wr;
                        disp2down_data_wr <= 1'b0;
                        disp2down_valid_wr <= 1'b0;
                        disp_state <= TRANS_UP_S;
                    end
                    else begin
                        disp2up_data_wr <= 1'b0;
                        disp2up_valid_wr <= 1'b0;
                        disp2down_data_wr <= exe2disp_data_wr;
                        disp2down_valid_wr <= exe2disp_valid_wr;
                        disp_state <= TRANS_DOWN_S;
                    end
                end
                else begin
                    disp2up_data_wr <= 1'b0;
                    disp2up_valid_wr <= 1'b0;
                    disp2down_data_wr <= 1'b0;
                    disp2down_valid_wr <= 1'b0;
                    disp_state <= IDLE_S;
                end
            end
            TRANS_UP_S: begin
                data_buff <= exe2disp_data;
                disp2up_data_wr <= exe2disp_data_wr;
                disp2up_valid_wr <= exe2disp_valid_wr;
                if(exe2disp_valid_wr == 1'b1) begin
                    disp_state <= IDLE_S;
                end
                else begin
                    disp_state <= TRANS_UP_S;
                end
            end
            TRANS_DOWN_S: begin
                data_buff <= exe2disp_data;
                disp2down_data_wr <= exe2disp_data_wr;
                disp2down_valid_wr <= exe2disp_valid_wr;
                if(exe2disp_valid_wr == 1'b1) begin
                    disp_state <= IDLE_S;
                end
                else begin
                    disp_state <= TRANS_DOWN_S;
                end
            end
            default: begin
                disp2up_data_wr <= 1'b0;
                disp2up_valid_wr <= 1'b0;
                disp2down_data_wr <= 1'b0;
                disp2down_valid_wr <= 1'b0;
                disp_state <= IDLE_S;
            end
        endcase
    end
end
endmodule
