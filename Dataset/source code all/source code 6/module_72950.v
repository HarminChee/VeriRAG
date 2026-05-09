`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module alt_ddrx_wdata_fifo 
    #(parameter     WDATA_BEATS_WIDTH     = 9,
                    LOCAL_DATA_WIDTH      = 32, 
                    LOCAL_SIZE_WIDTH      = 6,
                    DWIDTH_RATIO          = 2,
                    FAMILY                = "Stratix"
     )(
        ctl_clk, 								
        ctl_reset_n,  
        write_req_to_wfifo,
        wdata_to_wfifo,
        be_to_wfifo, 
        wdata_fifo_read,
        wdata_fifo_full,
        wdata_fifo_wdata,
        wdata_fifo_be,
        beats_in_wfifo
    );
    localparam   LOCAL_BE_WIDTH         = LOCAL_DATA_WIDTH/8;
    localparam   LOCAL_WFIFO_Q_WIDTH    = LOCAL_DATA_WIDTH + LOCAL_BE_WIDTH;
    input                		            ctl_clk; 	    
    input                		            ctl_reset_n; 	
    input                                   write_req_to_wfifo;
    input                                   wdata_fifo_read;
    input   [LOCAL_DATA_WIDTH-1 : 0]        wdata_to_wfifo;
    input   [LOCAL_BE_WIDTH-1 : 0]          be_to_wfifo;
    output  [LOCAL_DATA_WIDTH-1 : 0]        wdata_fifo_wdata;
    output  [LOCAL_BE_WIDTH-1 : 0]          wdata_fifo_be;
    output                                  wdata_fifo_full;
    output  [WDATA_BEATS_WIDTH-1 : 0]       beats_in_wfifo;
    wire                		            ctl_clk; 	
    wire                		            ctl_reset_n;
    wire                                    reset;
    wire                                    write_req_to_wfifo;
    wire                                    wdata_fifo_read;
    wire    [LOCAL_DATA_WIDTH-1 : 0]        wdata_to_wfifo;
    wire    [LOCAL_BE_WIDTH-1 : 0]          be_to_wfifo;
    wire    [LOCAL_WFIFO_Q_WIDTH-1 : 0]     wfifo_data; 
    wire    [LOCAL_WFIFO_Q_WIDTH-1 : 0]     wfifo_q; 
    wire                                    wdata_fifo_full;
    wire    [LOCAL_DATA_WIDTH-1 : 0]        wdata_fifo_wdata;
    wire    [LOCAL_BE_WIDTH-1 : 0]          wdata_fifo_be;
    reg     [WDATA_BEATS_WIDTH-1 : 0]       beats_in_wfifo;
    assign wfifo_data = {be_to_wfifo,wdata_to_wfifo};    
    assign wdata_fifo_be = wfifo_q[LOCAL_WFIFO_Q_WIDTH-1 : LOCAL_DATA_WIDTH];    
    assign wdata_fifo_wdata = wfifo_q[LOCAL_DATA_WIDTH-1 : 0];
    assign reset = !ctl_reset_n;            
    scfifo #(
            .intended_device_family  (FAMILY),
            .lpm_width               (LOCAL_WFIFO_Q_WIDTH),          
            .lpm_numwords            (256),              
            .lpm_widthu              (log2 (256)),      
            .almost_full_value       (256-16),                       
            .lpm_type                ("scfifo"),
            .lpm_showahead           ("OFF"),                        
            .overflow_checking       ("OFF"),
            .underflow_checking      ("OFF"),
            .use_eab                 ("ON"),
            .add_ram_output_register ("ON")                          
    ) wdata_fifo (
            .rdreq                   (wdata_fifo_read),                          
            .aclr                    (reset),
            .clock                   (ctl_clk),
            .wrreq                   (write_req_to_wfifo),
            .data                    (wfifo_data),
            .full                    (),
            .q                       (wfifo_q),
            .sclr                    (1'b0),
            .usedw                   (),
            .empty                   (),           
            .almost_full             (wdata_fifo_full),
            .almost_empty            ()
   );
   always @(posedge ctl_clk or negedge ctl_reset_n) begin     
        if (~ctl_reset_n) begin                               
           beats_in_wfifo <= 0; 
        end
        else if(write_req_to_wfifo) begin
             if(wdata_fifo_read) begin
                 beats_in_wfifo <= beats_in_wfifo;
             end
             else begin
                 beats_in_wfifo <= beats_in_wfifo + 1'b1;
             end
        end
        else if(wdata_fifo_read) begin
            beats_in_wfifo <= beats_in_wfifo - 1'b1;
        end
   end
   function integer log2;
       input integer value;
       begin
           for (log2=0; value>0; log2=log2+1)
               value = value>>1;
           log2 = log2 - 1;
       end
   endfunction
endmodule
