`timescale 1ns/1ps
`timescale 1ns/1ps
module  clock_inverter(
    input     rst,    
    input     clk_in,
    input     invert,
    output    clk_out
);
`ifdef SUPPORTED_BUFGCTRL_INVERION
    BUFGCTRL #(
        .INIT_OUT            (0),
        .IS_CE0_INVERTED     (1'b0),
        .IS_CE1_INVERTED     (1'b0),
        .IS_I0_INVERTED      (1'b1),
        .IS_I1_INVERTED      (1'b0),
        .IS_IGNORE0_INVERTED (1'b0),
        .IS_IGNORE1_INVERTED (1'b0),
        .IS_S0_INVERTED      (1'b1),
        .IS_S1_INVERTED      (1'b0),
        .PRESELECT_I0        ("TRUE"),
        .PRESELECT_I1        ("FALSE")
    ) BUFGCTRL_i (
        .O       (clk_out), 
        .CE0     (1'b1),    
        .CE1     (1'b1),    
        .I0      (clk_in),  
        .I1      (clk_in),  
        .IGNORE0 (1'b0),    
        .IGNORE1 (1'b0),    
        .S0      (invert),  
        .S1      (invert)   
    );
`else
    reg invert_r;
    reg pos_r;
    reg neg_r;
    always @ (posedge clk_in) begin
        invert_r <= invert;
        pos_r <= !rst && !pos_r;
    end
    always @ (negedge clk_in) begin
        neg_r <=    pos_r;
    end
    BUFGCTRL #(
        .INIT_OUT      (0),
        .PRESELECT_I0  ("TRUE"),
        .PRESELECT_I1  ("FALSE")
    ) BUFGCTRL_i (
        .O       (clk_out),        
        .CE0     (1'b1),           
        .CE1     (1'b1),           
        .I0      (pos_r ^ neg_r),  
        .I1      (pos_r == neg_r), 
        .IGNORE0 (1'b0),           
        .IGNORE1 (1'b0),           
        .S0      (!invert_r),      
        .S1      ( invert_r)       
    );
`endif
endmodule
