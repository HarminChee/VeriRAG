`timescale 1ns / 1ps
`timescale 1ns / 1ps
module xadc_read
(
    input           clk125,
    input           rst,
    input           start,
    input   [4:0]   ch_sel,
    input           busy_xadc,
    input           drdy,
    input   [4:0]   channel,
    input   [15:0]  do_out,
    input           eoc,
    input           eos,
    output          done,
    output  [11:0]  result,
    output          convst,
    output  [6:0]   daddr,
    output          den,
    output          dwe,
    output  [15:0]  di,
    output          rst_xadc,
    output  [3:0]   mux_select
);
wire [1:0]      rw; 
wire [6:0]      drp_addr;
wire            drp_done;
reg [3:0]       st_drp;
reg [3:0]       st;
reg             drp_done_r;
reg             den_r;
reg             dwe_r;
reg [6:0]       daddr_r;
reg [1:0]       rw_r;
reg [6:0]       drp_addr_r;
reg [15:0]      drp_data_out_r;
reg [15:0]      drp_data_in_r;
reg [15:0]      di_r;
reg [15:0]      config_reg_r;
reg             convst_r;
reg             done_r;
reg [11:0] result_r;
reg         first;
reg [5:0]   cnt_delay;
reg         rst_xadc_r;
reg [4:0]   config_in_r;
reg [4:0]   input_select_r;
reg [3:0]   mux_select_r;
parameter idle = 4'b0, st1 = 4'b1, st2 = 4'b10, st3 = 4'b11, st4 = 4'b100, st5 = 4'b101, st6 = 4'b110, st7 = 4'b111;
parameter st8 = 4'b1000, st9 = 4'b1001, st10 = 4'b1010, st11 = 4'b1011, st12 = 4'b1100, st13 = 4'b1101;
parameter st14 = 4'b1110, st15 = 4'b1111;
assign den = den_r;
assign dwe = dwe_r;
assign daddr = daddr_r;
assign drp_done = drp_done_r;
assign rw = rw_r;
assign drp_addr = drp_addr_r;
assign di = di_r;
assign convst = convst_r;
assign done = done_r;
assign result = result_r;
assign rst_xadc = rst_xadc_r;
assign mux_select = mux_select_r;
always @(posedge clk125)
begin
    if (start == 1'b1)
        config_in_r <= ch_sel;
    else
        config_in_r <= config_in_r;
end
always @(config_in_r)
begin
    case (config_in_r)
        5'b00000 : begin input_select_r <= 5'h18; mux_select_r <= 4'b1000; end 
        5'b00001 : begin input_select_r <= 5'h11; mux_select_r <= 4'b1000; end 
        5'b00010 : begin input_select_r <= 5'h12; mux_select_r <= 4'b1000; end 
        5'b00011 : begin input_select_r <= 5'h13; mux_select_r <= 4'b1000; end 
        5'b00100 : begin input_select_r <= 5'h18; mux_select_r <= 4'b1000; end 
        5'b00101 : begin input_select_r <= 5'h19; mux_select_r <= 4'b1000; end 
        5'b00110 : begin input_select_r <= 5'h1a; mux_select_r <= 4'b1000; end 
        5'b00111 : begin input_select_r <= 5'h1b; mux_select_r <= 4'b1000; end 
        5'b10000 : begin input_select_r <= 5'h03; mux_select_r <= 4'b0000; end 
        5'b10001 : begin input_select_r <= 5'h03; mux_select_r <= 4'b0001; end 
        5'b10010 : begin input_select_r <= 5'h03; mux_select_r <= 4'b0010; end 
        5'b10011 : begin input_select_r <= 5'h03; mux_select_r <= 4'b0011; end 
        5'b10100 : begin input_select_r <= 5'h03; mux_select_r <= 4'b0100; end 
        5'b10101 : begin input_select_r <= 5'h03; mux_select_r <= 4'b0101; end 
        5'b10110 : begin input_select_r <= 5'h03; mux_select_r <= 4'b0110; end 
        5'b10111 : begin input_select_r <= 5'h03; mux_select_r <= 4'b0111; end 
        5'b11000 : begin input_select_r <= 5'h03; mux_select_r <= 4'b1000; end 
        5'b11001 : begin input_select_r <= 5'h03; mux_select_r <= 4'b1001; end 
        5'b11010 : begin input_select_r <= 5'h03; mux_select_r <= 4'b1010; end 
        5'b11011 : begin input_select_r <= 5'h03; mux_select_r <= 4'b1011; end 
        5'b11100 : begin input_select_r <= 5'h03; mux_select_r <= 4'b1100; end 
        5'b11101 : begin input_select_r <= 5'h03; mux_select_r <= 4'b1101; end 
        5'b11110 : begin input_select_r <= 5'h03; mux_select_r <= 4'b1110; end 
        5'b11111 : begin input_select_r <= 5'h03; mux_select_r <= 4'b1111; end 
        default : begin input_select_r <= 5'h03; mux_select_r <= 4'b1111; end 
    endcase
end
always @(posedge clk125)
begin
    if (rst)
        begin
            st <= idle;
            done_r <= 1'b0;
            first <= 1'b0;
            cnt_delay <= 6'b0;
        end
    else if (1'b1)
    begin
    case (st)
        idle :
            begin
                done_r <= 1'b0;
                if (start == 1'b1) 
                    begin
                        if (first == 1'b1) 
                            begin
                                st <= st4;
                                rw_r <= 2'b01; 
                                drp_addr_r <= 7'h40; 
                            end
                        else 
                            begin
                                st <= st1;
                                rw_r <= 2'b01; 
                                drp_addr_r <= 7'h41; 
                            end
                    end
                else
                    st <= idle;
            end
        st1 : 
            begin
                rw_r <= 2'b0;
                if (drp_done == 1'b1)
                    begin
                        config_reg_r <= drp_data_out_r; 
                        st <= st2;
                    end
                else
                    st <= st1;
            end
        st2 : 
            begin
                rw_r <= 2'b10; 
                drp_addr_r <= 7'h41; 
                drp_data_in_r <= {4'b0011, config_reg_r[11:0]}; 
                st <= st3;
            end
        st3 : 
            begin
                rw_r <= 2'b0;
                if (drp_done == 1'b1)
                    begin
                        first <= 1'b1;
                        st <= st4;
                    end
                else
                    st <= st3;
            end
        st4 : 
            begin
                if (busy_xadc == 1'b0)
                    begin
                        rw_r <= 2'b01; 
                        drp_addr_r <= 7'h40; 
                        st <= st5;
                    end
                else
                    st <= st4;
            end
        st5 : 
            begin
                rw_r <= 2'b0;
                if (drp_done == 1'b1)
                    begin
                        config_reg_r <= drp_data_out_r; 
                        st <= st6;
                    end
                else
                    st <= st5;
            end
        st6 : 
            begin
                rw_r <= 2'b10; 
                drp_addr_r <= 7'h40;
                drp_data_in_r <= {config_reg_r[15:5], input_select_r};
                st <= st7;
            end
        st7 : 
            begin
                rw_r <= 2'b0;
                if (drp_done == 1'b1)
                    begin
                        st <= st15;
                    end
                else
                    st <= st7;
            end
        st8 : 
            begin
                if (busy_xadc == 1'b0)
                    begin
                        convst_r <= 1'b1; 
                        st <= st9;
                    end
                else
                    st <= st8;
            end
        st9 : 
            begin
                convst_r <= 1'b0;
                if (eoc == 1'b1) 
                    begin
                        if (channel != input_select_r) 
                            st <= st8;
                        else
                            begin
                                drp_addr_r <= {2'b0, input_select_r};
                                rw_r <= 2'b01; 
                                st <= st10;
                            end
                    end
                else
                    st <= st9;
            end
        st10 : 
            begin
                rw_r <= 2'b0;
                if (drp_done == 1'b1)
                    begin
                        result_r <= drp_data_out_r[15:4]; 
                        st <= st11;
                    end
                else
                    st <= st10;
            end
        st11 : 
            begin
                if (start == 1'b0)
                    begin
                        st <= idle;
                        done_r <= 1'b1;
                    end
                else
                    st <= st11;
            end
        st15 : 
            begin
                if (busy_xadc == 1'b0)
                    begin
                        if (cnt_delay == 6'b111111)
                            st <= st8;
                        else
                            st <= st15;
                        cnt_delay <= cnt_delay + 1'b1;
                    end
            end
    default :
        st <= idle;
    endcase
    end
end
always @(posedge clk125)
begin
    if (rst)
        begin
            st_drp <= idle;
            drp_done_r <= 1'b0;
        end
    else if (1'b1)
        begin
        case (st_drp)
            idle :
                begin
                    if (rw == 2'b01) 
                        begin
                            drp_done_r <= 1'b0;
                            daddr_r <= drp_addr;
                            den_r <= 1'b1;
                            st_drp <= st1;
                        end
                    else if (rw == 2'b10) 
                        begin
                            drp_done_r <= 1'b0;
                            daddr_r <= drp_addr;
                            den_r <= 1'b1;
                            dwe_r <= 1'b1;
                            di_r <= drp_data_in_r;
                            st_drp <= st2;
                        end
                    else
                        begin
                            drp_done_r <= 1'b0;
                            st_drp <= idle;
                        end
                end
            st1 :
                begin
                    den_r <= 1'b0;
                    if (drdy == 1'b1) 
                        begin
                            drp_data_out_r <= do_out;
                            drp_done_r <= 1'b1;
                            st_drp <= idle;
                        end
                    else
                        st_drp <= st1;
                end
            st2 :
                begin
                    den_r <= 1'b0;
                    dwe_r <= 1'b0;
                    if (drdy == 1'b1) 
                        begin
                            drp_done_r <= 1'b1;
                            st_drp <= idle;
                        end
                    else
                        st_drp <= st2;
                end
        default :
            st_drp <= idle;
        endcase
        end
end
endmodule
