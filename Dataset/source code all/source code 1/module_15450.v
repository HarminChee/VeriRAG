module spi_clock_generator(
    input   i_clk,
    input   i_reset,
    input   i_spr0,
    input   i_spr1,
    input   i_cpol,
    input   i_cpha,
    input   i_mstr,
    output  o_sclk,
    output  o_sclk_rising_edge,
    output  o_sclk_falling_edge,
    output  o_sample_spi_data,
    output  o_setup_spi_data
    );
    reg [6:0] q_spi_sclk_cntr;
	wire w_sclk_internal;
	wire [1:0]w_clk_select;
	reg q_sclk_internal_d1;     
	wire w_sclk_rising_edge_internal;
	wire w_sclk_falling_edge_internal;
	wire w_sample_spi_data_internal;
	wire w_setup_spi_data;
	wire [1:0] w_sample_setup_select;
	always @(posedge i_clk) begin : SCLK_CNTR
		if (i_reset) begin
			q_spi_sclk_cntr <= 7'b0 ;
		end else  begin
			q_spi_sclk_cntr <= q_spi_sclk_cntr + 1;
		end
	end	
	assign w_clk_select={i_spr0,i_spr1};
	assign w_sclk_internal = (w_clk_select==0) ? q_spi_sclk_cntr[1] :
							 (w_clk_select==1) ? q_spi_sclk_cntr[3] :
							 (w_clk_select==2) ? q_spi_sclk_cntr[5] :
							 (w_clk_select==3) ? q_spi_sclk_cntr[6] :
							  0; 
	assign o_sclk = w_sclk_internal;	
	always @(posedge i_clk) begin : SCLK_EDGE_DETECT
		if (i_reset) begin
			q_sclk_internal_d1<=0;
		end
		else begin 
			q_sclk_internal_d1 <=w_sclk_internal;
		end
	end
	assign w_sclk_rising_edge_internal = (w_sclk_internal > q_sclk_internal_d1) ? 1:
										 0;												
	assign o_sclk_rising_edge = w_sclk_rising_edge_internal;
	assign w_sclk_falling_edge_internal = (w_sclk_internal < q_sclk_internal_d1) ? 1:
										 0;												
	assign o_sclk_falling_edge = w_sclk_falling_edge_internal;
	assign w_sample_setup_select={i_cpol,i_cpha};
	assign w_sample_spi_data_internal = (w_sample_setup_select==0) ? w_sclk_rising_edge_internal:
										(w_sample_setup_select==1) ? w_sclk_falling_edge_internal:
										(w_sample_setup_select==2) ? w_sclk_falling_edge_internal:
										(w_sample_setup_select==3) ? w_sclk_rising_edge_internal:
										0;
	assign o_sample_spi_data = w_sample_spi_data_internal;
	assign w_setup_spi_data = 	(w_sample_setup_select==0) ? w_sclk_falling_edge_internal:
								(w_sample_setup_select==1) ? w_sclk_rising_edge_internal:
								(w_sample_setup_select==2) ? w_sclk_rising_edge_internal:
								(w_sample_setup_select==3) ? w_sclk_falling_edge_internal:
								0;
	assign o_setup_spi_data = w_setup_spi_data;
endmodule
