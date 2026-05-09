`timescale 1ns / 1ps
`timescale 1ns / 1ps
module PCIEBus_gtp_pipe_drp #
(
    parameter LOAD_CNT_MAX     = 2'd1,                      
    parameter INDEX_MAX        = 1'd0                       
)
(
    input               DRP_CLK,
    input               DRP_RST_N,
    input               DRP_X16,
    input               DRP_START,
    input       [15:0]  DRP_DO,
    input               DRP_RDY,
    output      [ 8:0]  DRP_ADDR,
    output              DRP_EN,  
    output      [15:0]  DRP_DI,   
    output              DRP_WE,
    output              DRP_DONE,
    output      [ 2:0]  DRP_FSM
);
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 x16_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 start_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [15:0]  do_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rdy_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 x16_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 start_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [15:0]  do_reg2;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                 rdy_reg2;
    reg         [ 1:0]  load_cnt =  2'd0;
    reg         [ 4:0]  index    =  5'd0;
    reg         [ 8:0]  addr_reg =  9'd0;
    reg         [15:0]  di_reg   = 16'd0;
    reg                 done     =  1'd0;
    reg         [ 2:0]  fsm      =  0;      
    localparam          ADDR_RX_DATAWIDTH  = 9'h011;              
    localparam          MASK_RX_DATAWIDTH  = 16'b1111011111111111;  
    localparam          X16_RX_DATAWIDTH   = 16'b0000000000000000;  
    localparam          X20_RX_DATAWIDTH   = 16'b0000100000000000;  
    wire        [15:0]  data_rx_datawidth;                 
    localparam          FSM_IDLE  = 0;  
    localparam          FSM_LOAD  = 1;                           
    localparam          FSM_READ  = 2;
    localparam          FSM_RRDY  = 3;
    localparam          FSM_WRITE = 4;
    localparam          FSM_WRDY  = 5;    
    localparam          FSM_DONE  = 6;   
always @ (posedge DRP_CLK)
begin
    if (!DRP_RST_N)
        begin
        x16_reg1   <=  1'd0;
        do_reg1    <= 16'd0;
        rdy_reg1   <=  1'd0;
        start_reg1 <=  1'd0;
        x16_reg2   <=  1'd0;
        do_reg2    <= 16'd0;
        rdy_reg2   <=  1'd0;
        start_reg2 <=  1'd0;
        end
    else
        begin
        x16_reg1   <= DRP_X16;
        do_reg1    <= DRP_DO;
        rdy_reg1   <= DRP_RDY;
        start_reg1 <= DRP_START;
        x16_reg2   <= x16_reg1;
        do_reg2    <= do_reg1;
        rdy_reg2   <= rdy_reg1;
        start_reg2 <= start_reg1;
        end
end  
assign data_rx_datawidth = x16_reg2 ? X16_RX_DATAWIDTH : X20_RX_DATAWIDTH;
always @ (posedge DRP_CLK)
begin
    if (!DRP_RST_N)
        load_cnt <= 2'd0;
    else
        if ((fsm == FSM_LOAD) && (load_cnt < LOAD_CNT_MAX))
            load_cnt <= load_cnt + 2'd1;
        else if ((fsm == FSM_LOAD) && (load_cnt == LOAD_CNT_MAX))
            load_cnt <= load_cnt;
        else
            load_cnt <= 2'd0;
end 
always @ (posedge DRP_CLK)
begin
    if (!DRP_RST_N)
        begin
        addr_reg <=  9'd0;
        di_reg   <= 16'd0;
        end
    else
        begin
        case (index)
        1'd0 :
            begin        
            addr_reg <= ADDR_RX_DATAWIDTH;
            di_reg   <= (do_reg2 & MASK_RX_DATAWIDTH) | data_rx_datawidth;
            end              
        default : 
            begin
            addr_reg <=  9'd0;
            di_reg   <= 16'd0;
            end
        endcase
        end
end  
always @ (posedge DRP_CLK)
begin
    if (!DRP_RST_N)
        begin
        fsm   <= FSM_IDLE;
        index <= 5'd0;
        done  <= 1'd0;
        end
    else
        begin
        case (fsm)
        FSM_IDLE :  
            begin
            if (start_reg2)
                begin
                fsm   <= FSM_LOAD;
                index <= 5'd0;
                done  <= 1'd0; 
                end
            else       
                begin
                fsm   <= FSM_IDLE;
                index <= 5'd0;
                done  <= 1'd1;
                end 
            end    
        FSM_LOAD :
            begin
            fsm   <= (load_cnt == LOAD_CNT_MAX) ? FSM_READ : FSM_LOAD;
            index <= index;
            done  <= 1'd0;
            end  
        FSM_READ :
            begin
            fsm   <= FSM_RRDY;
            index <= index;
            done  <= 1'd0;
            end
        FSM_RRDY :    
            begin
            fsm   <= rdy_reg2 ? FSM_WRITE : FSM_RRDY;
            index <= index;
            done  <= 1'd0;
            end
        FSM_WRITE :    
            begin
            fsm   <= FSM_WRDY;
            index <= index;
            done  <= 1'd0;
            end       
        FSM_WRDY :    
            begin
            fsm   <= rdy_reg2 ? FSM_DONE : FSM_WRDY;
            index <= index;
            done  <= 1'd0;
            end        
        FSM_DONE :
            begin
            if (index == INDEX_MAX)
                begin
                fsm   <= FSM_IDLE;
                index <= 5'd0;
                done  <= 1'd0;
                end
            else       
                begin
                fsm   <= FSM_LOAD;
                index <= index + 5'd1;
                done  <= 1'd0;
                end
            end     
        default :
            begin      
            fsm   <= FSM_IDLE;
            index <= 5'd0;
            done  <= 1'd0;
            end
        endcase
        end
end 
assign DRP_ADDR = addr_reg;
assign DRP_EN   = (fsm == FSM_READ) || (fsm == FSM_WRITE);
assign DRP_DI   = di_reg;
assign DRP_WE   = (fsm == FSM_WRITE);
assign DRP_DONE = done;
assign DRP_FSM  = fsm;
endmodule
