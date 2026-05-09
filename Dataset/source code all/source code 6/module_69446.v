module a23_coprocessor
(
input                       i_clk,
input                       i_fetch_stall,    
input       [2:0]           i_copro_opcode1,
input       [2:0]           i_copro_opcode2,
input       [3:0]           i_copro_crn,      
input       [3:0]           i_copro_crm,
input       [3:0]           i_copro_num,
input       [1:0]           i_copro_operation,
input       [31:0]          i_copro_write_data,
input                       i_fault,          
input       [7:0]           i_fault_status,
input       [31:0]          i_fault_address,  
output reg  [31:0]          o_copro_read_data,
output                      o_cache_enable,
output                      o_cache_flush,
output      [31:0]          o_cacheable_area 
);
reg [2:0]  cache_control = 3'b000;
reg [31:0] cacheable_area = 32'h0;
reg [31:0] updateable_area = 32'h0;
reg [31:0] disruptive_area = 32'h0;
reg [7:0]  fault_status  = 'd0;
reg [31:0] fault_address = 'd0;  
wire       copro15_reg1_write;
assign o_cache_enable   = cache_control[0];
assign o_cache_flush    = copro15_reg1_write;
assign o_cacheable_area = cacheable_area;
always @ ( posedge i_clk )
    if ( !i_fetch_stall )
        begin
        if ( i_fault )
            begin
            `ifdef A23_COPRO15_DEBUG    
            $display ("Fault status  set to 0x%08x", i_fault_status);
            $display ("Fault address set to 0x%08x", i_fault_address);
            `endif        
            fault_status    <= i_fault_status;
            fault_address   <= i_fault_address;
            end
        end
always @ ( posedge i_clk )
    if ( !i_fetch_stall )         
        begin
        if ( i_copro_operation == 2'd2 )
            case ( i_copro_crn )
                4'd2: cache_control   <= i_copro_write_data[2:0];
                4'd3: cacheable_area  <= i_copro_write_data[31:0];
                4'd4: updateable_area <= i_copro_write_data[31:0];
                4'd5: disruptive_area <= i_copro_write_data[31:0];
            endcase
        end
assign copro15_reg1_write = !i_fetch_stall && i_copro_operation == 2'd2 && i_copro_crn == 4'd1;
always @ ( posedge i_clk )        
    if ( !i_fetch_stall )
        case ( i_copro_crn )
            4'd0:    o_copro_read_data <= 32'h4156_0300;
            4'd2:    o_copro_read_data <= {29'd0, cache_control}; 
            4'd3:    o_copro_read_data <= cacheable_area; 
            4'd4:    o_copro_read_data <= updateable_area; 
            4'd5:    o_copro_read_data <= disruptive_area; 
            4'd6:    o_copro_read_data <= {24'd0, fault_status };
            4'd7:    o_copro_read_data <= fault_address;
            default: o_copro_read_data <= 32'd0;
        endcase
`ifdef A23_COPRO15_DEBUG    
reg [1:0]  copro_operation_d1;
reg [3:0]  copro_crn_d1;
always @( posedge i_clk )
    if ( !i_fetch_stall )
        begin
        copro_operation_d1  <= i_copro_operation;
        copro_crn_d1        <= i_copro_crn;
        end
always @( posedge i_clk )
    if ( !i_fetch_stall )
        begin
        if ( i_copro_operation == 2'd2 )  
            case ( i_copro_crn )
                4'd 1: begin `TB_DEBUG_MESSAGE $display ("Write 0x%08h to   Co-Pro 15 #1, Flush Cache", i_copro_write_data); end
                4'd 2: begin `TB_DEBUG_MESSAGE $display ("Write 0x%08h to   Co-Pro 15 #2, Cache Control", i_copro_write_data); end
                4'd 3: begin `TB_DEBUG_MESSAGE $display ("Write 0x%08h to   Co-Pro 15 #3, Cacheable area", i_copro_write_data); end
                4'd 4: begin `TB_DEBUG_MESSAGE $display ("Write 0x%08h to   Co-Pro 15 #4, Updateable area", i_copro_write_data); end
                4'd 5: begin `TB_DEBUG_MESSAGE $display ("Write 0x%08h to   Co-Pro 15 #5, Disruptive area", i_copro_write_data); end
            endcase
        if ( copro_operation_d1 == 2'd1 ) 
            case ( copro_crn_d1 )
                4'd 0: begin `TB_DEBUG_MESSAGE $display ("Read  0x%08h from Co-Pro 15 #0, ID Register", o_copro_read_data); end
                4'd 2: begin `TB_DEBUG_MESSAGE $display ("Read  0x%08h from Co-Pro 15 #2, Cache control", o_copro_read_data); end
                4'd 3: begin `TB_DEBUG_MESSAGE $display ("Read  0x%08h from Co-Pro 15 #3, Cacheable area", o_copro_read_data); end
                4'd 4: begin `TB_DEBUG_MESSAGE $display ("Read  0x%08h from Co-Pro 15 #4, Updateable area", o_copro_read_data); end
                4'd 5: begin `TB_DEBUG_MESSAGE $display ("Read  0x%08h from Co-Pro 15 #4, Disruptive area", o_copro_read_data); end
                4'd 6: begin `TB_DEBUG_MESSAGE $display ("Read  0x%08h from Co-Pro 15 #6, Fault Status Register", o_copro_read_data); end
                4'd 7: begin `TB_DEBUG_MESSAGE $display ("Read  0x%08h from Co-Pro 15 #7, Fault Address Register", o_copro_read_data); end
            endcase
    end
`endif
endmodule
