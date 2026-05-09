module flash_writer(
    input  p_ready,
    input  WE_CLK,
    input  iFLASH_RY_N,
    input  iOSC_28,
    input  iERASE,
    input  iPROGRAM,
    input  iVERIFY,
    input  iOK,
    input  iFAIL,
    input  iRESET_N,
    output oREAD_PRO_END,
    output oVERIFY_TIME,
    output [21:0] oFLASH_ADDR,
    output reg [3:0] oFLASH_CMD,
    output oFLASH_TR
);

always @(posedge iOSC_28) begin
    case ({iFAIL,iOK,iRESET_N,iVERIFY,iPROGRAM,iERASE})
        6'b000100: oFLASH_CMD = 4'h0;    
        6'b000001: oFLASH_CMD = 4'h4;    
        6'b000010: oFLASH_CMD = 4'h1;    
        6'b001000: oFLASH_CMD = 4'h7;    
        6'b010000: oFLASH_CMD = 4'h8;    
        6'b100000: oFLASH_CMD = 4'h9;
        default: oFLASH_CMD = 4'h0;    
    endcase
end

reg [31:0] delay;
always @(posedge iOSC_28 or posedge iRESET_N) begin
    if (iRESET_N)
        delay <= 32'h0;
    else
        delay <= delay + 1;
end

wire ck_prog = delay[5];  
wire ck_read = delay[4];  
wire [21:0] end_address;
assign end_address = 22'h3fffff; 

reg [21:0] addr_prog;
reg end_prog;
reg PROGRAM_TR_r;
reg [7:0] ST_P;

always @(posedge ck_prog or posedge iRESET_N) begin
    if (iRESET_N) begin
        addr_prog <= end_address;
        end_prog <= 1'b1;
        ST_P <= 8'd9; 
        PROGRAM_TR_r <= 1'b0;
    end    
    else if (iPROGRAM) begin
        addr_prog <= 22'h0;
        end_prog <= 1'b0;
        ST_P <= 8'd0;    
        PROGRAM_TR_r <= 1'b0;
    end    
    else begin
        case (ST_P)
            8'd0: begin 
                ST_P <= ST_P + 8'd1;
                PROGRAM_TR_r <= 1'b1;
            end
            8'd1: begin 
                ST_P <= 8'd4;
                PROGRAM_TR_r <= 1'b0;
            end
            8'd2: begin 
                ST_P <= ST_P + 8'd1;
            end
            8'd3: begin 
                ST_P <= ST_P + 8'd1;
            end
            8'd4: begin 
                ST_P <= ST_P + 8'd1;
            end
            8'd5: begin 
                if (iFLASH_RY_N) 
                    ST_P <= 8'd7;
            end
            8'd6: begin 
                ST_P <= ST_P + 8'd1;
            end
            8'd7: begin 
                if (addr_prog == end_address)
                    ST_P <= 8'd9;
                else begin
                    addr_prog <= addr_prog + 22'd1;
                    ST_P <= 8'd0;
                end
            end
            8'd8: begin 
                addr_prog <= addr_prog + 22'd1;
                ST_P <= 8'd0;
            end
            8'd9: begin  
                end_prog <= 1'b1;
            end
            default: ST_P <= 8'd9;
        endcase
    end
end

reg [21:0] addr_read;
reg end_read;

always @(posedge ck_read or posedge iRESET_N) begin
    if (iRESET_N) begin 
        addr_read <= end_address;
        end_read <= 1'b1;
    end    
    else if (iVERIFY) begin
        addr_read <= 22'h0;
        end_read <= 1'b0;
    end    
    else if (addr_read < end_address) 
        addr_read <= addr_read + 22'd1;
    else if (addr_read == end_address)  
        end_read <= 1'b1;
end

assign oFLASH_ADDR = (oFLASH_CMD == 4'h1) ? addr_prog : 
                     (oFLASH_CMD == 4'h0) ? addr_read : 22'h0;

wire erase_tr = iERASE;                        
wire program_tr = PROGRAM_TR_r;   
wire verify_tr = (addr_read < end_address) ? ~ck_read : 1'b0; 

assign oFLASH_TR = erase_tr | program_tr | verify_tr; 
assign oREAD_PRO_END = end_read & end_prog;
assign oVERIFY_TIME = ~end_read;

endmodule