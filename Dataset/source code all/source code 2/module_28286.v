module musb_div(
    input           clk,            
    input           rst,            
    input           op_divs,        
    input           op_divu,        
    input   [31:0]  dividend,       
    input   [31:0]  divisor,        
    output  [31:0]  quotient,       
    output  [31:0]  remainder,      
    output          stall           
    );
    reg             active;             
    reg             neg_result;         
    reg     [4:0]   cycle;              
    reg     [31:0]  result;             
    reg     [31:0]  denominator;        
    reg     [31:0]  residual;           
    wire    [32:0]  partial_sub;        
    assign quotient    = !neg_result ? result : -result;
    assign remainder   = residual;
    assign stall       = active;
    assign partial_sub = {residual[30:0], result[31]} - denominator;            
    always @(posedge clk) begin
        if (rst) begin
            active      <= 1'b0;
            neg_result  <= 1'b0;
            cycle       <= 5'b0;
            result      <= 32'b0;
            denominator <= 32'b0;
            residual    <= 32'b0;
        end
        else begin
            if(op_divs) begin
                cycle       <= 5'd31;
                result      <= (dividend[31] == 1'b0) ? dividend : -dividend;
                denominator <= (divisor[31] == 1'b0) ? divisor : -divisor;
                residual    <= 32'b0;
                neg_result  <= dividend[31] ^ divisor[31];
                active      <= 1'b1;
            end
            else if (op_divu) begin
                cycle       <= 5'd31;
                result      <= dividend;
                denominator <= divisor;
                residual    <= 32'b0;
                neg_result  <= 1'b0;
                active      <= 1'b1;
            end
            else if (active) begin
                if(partial_sub[32] == 1'b0) begin
                    residual <= partial_sub[31:0];
                    result   <= {result[30:0], 1'b1};
                end
                else begin
                    residual <= {residual[30:0], result[31]};
                    result   <= {result[30:0], 1'b0};
                end
                if (cycle == 5'b0) begin
                    active <= 1'b0;
                end
                cycle <= cycle - 5'd1;
            end
        end
    end
endmodule
