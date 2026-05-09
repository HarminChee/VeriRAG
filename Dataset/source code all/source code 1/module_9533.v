`timescale 1ns / 1ps
`timescale 1ns / 1ps
module frequency_counter #
(
    parameter ADC_WIDTH = 14,
    parameter AXIS_TDATA_WIDTH = 32,
    parameter COUNT_WIDTH = 32,
    parameter HIGH_THRESHOLD = -100,
    parameter LOW_THRESHOLD = -150
)
(
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
    input [AXIS_TDATA_WIDTH-1:0]   S_AXIS_IN_tdata,
    input                          S_AXIS_IN_tvalid,
    input                          clk,
    input                          rst,
    input [COUNT_WIDTH-1:0]        Ncycles,
    output [AXIS_TDATA_WIDTH-1:0]  M_AXIS_OUT_tdata,
    output                         M_AXIS_OUT_tvalid,
	output [COUNT_WIDTH-1:0]       counter_output
);
    wire signed [ADC_WIDTH-1:0]    data;
    reg                            state, state_next;
    reg [COUNT_WIDTH-1:0]          counter=0, counter_next=0;
    reg [COUNT_WIDTH-1:0]          counter_output=0, counter_output_next=0;
    reg [COUNT_WIDTH-1:0]          cycle=0, cycle_next=0;
    assign  M_AXIS_OUT_tdata[ADC_WIDTH-1:0] = S_AXIS_IN_tdata[ADC_WIDTH-1:0];
    assign  M_AXIS_OUT_tvalid = S_AXIS_IN_tvalid;
    assign  data = S_AXIS_IN_tdata[ADC_WIDTH-1:0];
    always @(posedge clk) 
    begin
        if (~rst) 
            state <= 1'b0;
        else
            state <= state_next;
    end
    always @*            
    begin
        if (data > HIGH_THRESHOLD)
            state_next = 1;
        else if (data < LOW_THRESHOLD)
            state_next = 0;
        else
            state_next = state;
    end
    always @(posedge clk) 
    begin
        if (~rst) 
        begin
            counter <= 0;
            counter_output <= 0;
            cycle <= 0;
        end
        else
        begin
            counter <= counter_next;
            counter_output <= counter_output_next;
            cycle <= cycle_next;
        end
    end
    always @* 
    begin
        counter_next = counter + 1; 
        counter_output_next = counter_output;
        cycle_next = cycle;
        if (state < state_next) 
        begin
            cycle_next = cycle + 1; 
            if (cycle >= Ncycles-1) 
            begin
                counter_next = 0;
                counter_output_next = counter;
                cycle_next = 0;
            end
        end
   end
endmodule
