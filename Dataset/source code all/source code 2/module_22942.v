`timescale 1ns / 1ps
`timescale 1ns / 1ps
module NES(
    input CLK100MHz,
    input BTNC,
    output VGA_HS,
    output VGA_VS,
    output [3:0]VGA_R,
    output [3:0]VGA_G,
    output [3:0]VGA_B,
    input [5:0]SW,
    input BTNU,
    input BTNR,
    input BTNL,
    input BTND,
    output [10:0]LED
    );
    wire [31:0]w_frame; 
    wire [11:0]w_d; 
    wire [15:0]w_adr; 
    wire w_we; 
    wire [11:0]color; 
    wire [9:0]x; 
    wire [9:0]y; 
    reg [1:0]CLK25MHz; 
    wire CLK50MHz; 
    assign LED[7:0] = w_frame[7:0];
    assign VGA_R = x < 10'd512 ? color[3:0]  : 4'b0;
    assign VGA_G = x < 10'd512 ? color[7:4]  : 4'b0;
    assign VGA_B = x < 10'd512 ? color[11:8] : 4'b0;
    always@( posedge CLK100MHz or posedge BTNC)begin
        if( BTNC == 1'b1)begin
            CLK25MHz <= 2'b00;
        end else begin
            CLK25MHz <= CLK25MHz + 1'b1;
        end
    end
    assign CLK50MHz = CLK25MHz[0];
    vga640x480 vga_ctrl_inst(
        .dclk( CLK25MHz[1]), 
        .clr( BTNC),         
        .hsync( VGA_HS),     
        .vsync( VGA_VS),     
        .red( ),    
        .green( ),  
        .blue( ),   
        .x( x),
        .y( y)
    );
    reg NES_ap_start; 
    reg NES_buffer_page; 
    wire NES_ap_done; 
    always@( posedge CLK100MHz or posedge BTNC)begin
        if( BTNC == 1'b1)begin
            NES_ap_start    <= 1'b0;
            NES_buffer_page <= 1'b0;
        end else begin
            if( NES_ap_start == 1'b1)begin
                if( NES_ap_done == 1'b1)begin
                    NES_ap_start <= 1'b0;
                end
            end else begin
                if( VGA_HS == 1'b1 && VGA_VS == 1'b1)begin
                    NES_ap_start <= 1'b1;
                    NES_buffer_page <= ~NES_buffer_page;
                end
            end
        end
    end
    assign LED[10:8] = {NES_ap_start, NES_buffer_page, NES_ap_done};
    blk_mem_gen_0 buffer_mem(
      .clka( CLK50MHz),    
      .ena( 1'b1),      
      .wea( w_we),      
      .addra( { ~NES_buffer_page, w_adr[7:0], w_adr[15:8]}),  
      .dina( w_d),    
      .clkb( CLK25MHz),    
      .enb( 1'b1),      
      .addrb( { NES_buffer_page, x[8:1], y[8:1]}),  
      .doutb( color)  
    );
     mariones_top mariones_inst(
           .ap_clk(CLK25MHz),
           .ap_rst(BTNC),
           .ap_start( NES_ap_start | SW[0]),
           .ap_done( NES_ap_done),
           .ap_idle(),
           .ap_ready(),
           .reset( SW[1]),
           .bmp_address0( w_adr),
           .bmp_ce0(),
           .bmp_we0( w_we),
           .bmp_d0( w_d),
           .pad0({ BTNR,BTNL,BTND,BTNU,SW[5:2]}), 
           .pad1(8'b0), 
           .ap_return( w_frame)
   );
endmodule
