module acl_ll_fifo(clk, reset, data_in, write, data_out, read, empty, full, almost_full);
parameter WIDTH = 32;
parameter DEPTH = 32;
parameter ALMOST_FULL_VALUE = 0;
input clk;
input reset;
input [WIDTH-1:0] data_in;
input write;
output [WIDTH-1:0] data_out;
input read;
output empty;
output full;
output almost_full;
reg [DEPTH:0] wptr;
reg [DEPTH:0] wptr_copy ;
reg [DEPTH-1:0][WIDTH-1:0] data;
wire wptr_hold; 
wire wptr_dir;  
wire [DEPTH-1:0] data_hold;     
wire [DEPTH-1:0] data_new;      
assign wptr_hold = !(read ^ write);
assign wptr_dir = read;
genvar i;
generate
for(i = 0; i < DEPTH; i++)
begin : data_mux
    assign data_hold[i] = !(read | (write & wptr[i]));
    assign data_new[i] = !read | wptr[i+1];
end
endgenerate
generate
for(i = 0; i < DEPTH-1; i++)
begin : data_reg
    always@(posedge clk or posedge reset)
    begin
        if(reset == 1'b1)
            data[i] <= {WIDTH{1'b0}};
        else
            data[i] <= data_hold[i] ? data[i] : 
                       data_new[i] ? data_in : data[i+1];
    end
end
endgenerate
always@(posedge clk or posedge reset)
begin
    if(reset == 1'b1)
        data[DEPTH-1] <= {WIDTH{1'b0}};
    else
        data[DEPTH-1] <= data_hold[DEPTH-1] ? data[DEPTH-1] : data_in;
end
always@(posedge clk or posedge reset)
begin
    if(reset == 1'b1)
    begin
        wptr <= {{DEPTH{1'b0}}, 1'b1};
        wptr_copy <= {{DEPTH{1'b0}}, 1'b1};
    end
    else
    begin
        wptr <= wptr_hold ? wptr : 
                wptr_dir ? {1'b0, wptr[DEPTH:1]} : {wptr[DEPTH-1:0], 1'b0};
        wptr_copy <= wptr_hold ? wptr_copy : 
                wptr_dir ? {1'b0, wptr_copy[DEPTH:1]} : {wptr_copy[DEPTH-1:0], 1'b0};
    end
end
assign empty = wptr_copy[0];
assign full = wptr_copy[DEPTH];
assign almost_full = wptr_copy[DEPTH - ALMOST_FULL_VALUE];
assign data_out = data[0];
endmodule
