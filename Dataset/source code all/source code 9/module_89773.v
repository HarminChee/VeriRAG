`timescale 1ns / 1ps
`timescale 1ns / 1ps
module completion_timeout(
          input clk, 
          input rst, 
          input [31:0] pending_req,
          output reg comp_timeout
  );
`ifdef ML505
reg [15:0] count;
`else
reg [17:0] count;  
`endif
wire [31:0] pending_req_rise;
wire [31:0] pending_req_fall;
reg [31:0] shift_in = 0;
reg [4:0] reset_count[31:0];
wire [31:0] srl_reset;
wire [31:0] comp_timeout_vector;
reg [31:0]  comp_timeout_vector_d1;
wire        comp_timeout_or;
wire        comp_timeout_one;
reg         comp_timeout_d1;
    always@(posedge clk)begin
            if(rst)
              count <= 0;
            else 
              count <= count + 1;
     end
    assign timer = (count == 0) ? 1'b1 : 1'b0;
    genvar i;
    generate
    for(i=0;i<32;i=i+1)begin: replicate
        edge_detect edge_detect_inst(
          .clk(clk),
          .rst(rst),
          .in(pending_req[i]),
          .rise_out(pending_req_rise[i]),
          .fall_out(pending_req_fall[i])
         );
        always@(posedge clk)begin
           if(pending_req_rise[i]) 
              shift_in[i] <= 1'b1;
           else if(timer || pending_req_fall[i])    
              shift_in[i] <= 1'b0;
        end
         always@(posedge clk)begin
             if(rst)
                reset_count[i][4:0] <= 5'b00000;
             else if (pending_req_fall[i] == 1'b1)
                reset_count[i][4:0] <= 5'b11001;
             else if (reset_count[i][4:0] == 5'b00000)
                reset_count[i][4:0] <= 5'b00000;
             else 
                reset_count[i][4:0] <= reset_count[i][4:0] - 1;
         end
         assign srl_reset[i] = | reset_count[i][4:0];    
         SRLC32E #(
           .INIT(32'h00000000)
         ) SRLC32E_inst (
            .Q(comp_timeout_vector[i]),     
            .Q31(), 
            .A(5'b11000),  
            .CE((srl_reset[i]) ? srl_reset[i] : timer),   
            .CLK(clk), 
            .D((srl_reset[i]) ? ~srl_reset[i] : shift_in[i]) 
          );
    end
    endgenerate
    always@(posedge clk)begin
            comp_timeout_vector_d1[31:0] <= comp_timeout_vector[31:0];
    end
    assign  comp_timeout_or = |comp_timeout_vector_d1[31:0];
rising_edge_detect comp_timeout_one_inst(
                .clk(clk),
                .rst(rst),
                .in(comp_timeout_or),
                .one_shot_out(comp_timeout_one)
                );
    always@(posedge clk)begin
        comp_timeout_d1 <= comp_timeout_one;
        comp_timeout <= comp_timeout_d1;
    end
endmodule
