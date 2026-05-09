`timescale 1ns / 1ps
`timescale 1ns / 1ps
module xadcModule #
(
    parameter   max_packet_size	= 10'b1001011000 
)
(
    input           clk125,
    input           rst,
    input           VP_0,
    input           VN_0,
    input           Vaux0_v_n,
    input           Vaux0_v_p,
    input           Vaux1_v_n,
    input           Vaux1_v_p,
    input           Vaux2_v_n,
    input           Vaux2_v_p,
    input           Vaux3_v_n,
    input           Vaux3_v_p,
    input           Vaux8_v_n,
    input           Vaux8_v_p,
    input           Vaux9_v_n,
    input           Vaux9_v_p,
    input           Vaux10_v_n,
    input           Vaux10_v_p,
    input           Vaux11_v_n,
    input           Vaux11_v_p,
    input           data_in_rdy,
    input [15:0]    vmm_id,
    input [10:0]    sample_size,
    input [17:0]    delay_in,
    input           UDPDone,
    output          MuxAddr0,
    output          MuxAddr1,
    output          MuxAddr2,
    output          MuxAddr3_p,
    output          MuxAddr3_n,
    output          end_of_data,
    output [15:0]   fifo_bus,
    output          data_fifo_enable,
    output [11:0]   packet_len,
    output          xadc_busy
);
wire            rst_pkt;
wire            rst_pkt2;
wire [6:0]      daddr;
wire            den;
wire [15:0]     di;
wire            dwe;
wire            rst_xadc;
wire            busy_xadc;
wire [4:0]      channel;
wire [15:0]     do_out;
wire            drdy;
wire            eoc;
wire            eos;
wire            convst;
wire            start;
wire [3:0]      mux_select;
wire [4:0]      ch_sel;
wire [4:0]      ch_request;
wire            xadc_done;
wire [11:0]     result;
wire [3:0]      mux_request;
wire            configuring;
wire            conf_done;
wire            init_chan;
wire            chan_done;
wire            init_type;
wire            save;
wire            fifo_done;
wire            full_pkt;
reg [3:0]       st;
reg             rst_pkt_r;
reg             rst_pkt2_r;
reg [3:0]       st_chan;
reg [3:0]       st_type;
reg [3:0]       st_pkt;
reg             write_start;
reg [3:0]       st_wr;
reg [15:0]      fifo_bus_r;
reg             data_fifo_enable_r;
reg [2:0]       cnt_fifo;
reg [4:0]       cnt_delay;
reg [11:0]       packet_len_r;
reg             xadc_start_r;
reg [4:0]       ch_sel_r;
reg [10:0]      cnt;
reg [17:0]      delay; 
reg             configuring_r;
reg [11:0]      xadc_result_r;
reg             save_r;
reg             chan_done_r;
reg             init_chan_r;
reg             type_done_r;
reg [63:0]      packet; 
reg [9:0]       pkt_cnt;
reg [2:0]       read_cnt;
reg [15:0]      vmm_id_r;
reg [2:0]       vmm_id_sel;
reg [2:0]       cmd_cnt;
reg             init_type_r;
reg             fifo_done_r;
reg             end_of_data_r;
reg             full_pkt_r;
reg [11:0]      test_counter = 0; 
reg             xadc_busy_r;
parameter idle = 4'b0, st1 = 4'b1, st2 = 4'b10, st3 = 4'b11, st4 = 4'b100, st5 = 4'b101, st6 = 4'b110, st7 = 4'b111;
parameter st8 = 4'b1000, st9 = 4'b1001, st10 = 4'b1010, st11 = 4'b1011, st12 = 4'b1100, st13 = 4'b1101;
parameter st14 = 4'b1110, st15 = 4'b1111;
assign MuxAddr0 = mux_select[0];
assign MuxAddr1 = mux_select[1];
assign MuxAddr2 = mux_select[2];
assign MuxAddr3_p = mux_select[3];
assign MuxAddr3_n = -1 * mux_select[3];
assign data_fifo_enable = data_fifo_enable_r;
assign fifo_bus = fifo_bus_r;
assign packet_len = packet_len_r;
assign xadc_start = xadc_start_r;
assign ch_sel = ch_sel_r;
assign configuring = configuring_r;
assign init_chan = init_chan_r;
assign chan_done = chan_done_r;
assign type_done = type_done_r;
assign save = save_r;
assign init_type = init_type_r;
assign fifo_done = fifo_done_r;
assign rst_pkt = rst_pkt_r;
assign rst_pkt2 = rst_pkt2_r;
assign end_of_data = end_of_data_r;
assign full_pkt = full_pkt_r;
assign xadc_busy = xadc_busy_r;
always @(posedge clk125)
begin
    if (rst == 1'b1)
        begin
            test_counter <= 12'b0;
        end
    else if (data_fifo_enable == 1'b1)
        test_counter <= test_counter + 1'b1;
end
always @(posedge clk125)
begin
    if (rst == 1'b1)
        begin
            st <= idle;
            cmd_cnt <= 3'b0;
            cnt <= 11'b0;
            delay <= 18'b0;
            vmm_id_sel <= 3'b0;
            xadc_busy_r <= 1'b0;
        end
    else
        begin
        case(st)
            idle :
                begin
                    if (data_in_rdy == 1'b1)
                        begin
                            xadc_busy_r <= 1'b1;
                            if (vmm_id_r[3:0] > 4'b111) 
                                vmm_id_sel <= 3'b0; 
                            else
                                vmm_id_sel <= vmm_id_r[2:0];
                            st <= st1;
                        end
                    else
                        st <= idle;
                end
            st1 : 
                begin
                    st <= st2;
                    init_type_r <= 1'b1;
                    cnt <= cnt + 1'b1;
                    delay <= 18'b0;
                end
            st2 : 
                begin
                    init_type_r <= 1'b0;
                    if (type_done == 1'b1)
                        begin
                            if (cnt == sample_size)
                                begin
                                    st <= st4;
                                    write_start <= 1'b1;
                                end
                            else 
                                st <= st3;
                        end
                    else
                        st <= st2;
                end
            st3 : 
                begin
                    delay <= delay + 1'b1;
                    if (delay == delay_in)
                        begin
                            delay <= 18'b0;
                            st <= st1; 
                        end
                    else
                        st <= st3;
                end
            st4 : 
                begin
                    if (fifo_done == 1'b1) 
                        begin
                            write_start <= 1'b0;
                            cnt <= 11'b0;
                            if (vmm_id_r[3:0] > 4'b111 && vmm_id_sel != 3'b111) 
                                begin
                                    vmm_id_sel <= vmm_id_sel + 1'b1; 
                                    st <= st1;
                                end
                            else    
                                st <= st5; 
                        end
                    else
                        st <= st4;
                end
            st5 : 
                begin
                    if (data_in_rdy == 1'b0 & UDPDone == 1'b1)
                        begin
                            xadc_busy_r <= 1'b0;
                            st <= idle;
                        end
                    else
                        st <= st5;
                end
            default : st <= idle;
        endcase
        end
end
always @(posedge clk125)
begin
    if (data_in_rdy == 1'b1)
        vmm_id_r <= vmm_id - 1'b1; 
end
always @(posedge clk125)
begin
    if (rst)
        begin
            st_type <= idle;
            type_done_r <= 1'b0;
            init_chan_r <= 1'b0;
        end
    else
        begin
        case(st_type)
            idle : 
                begin
                    type_done_r <= 1'b0;
                    if (init_type == 1'b1)
                        st_type <= st1;
                    else
                        st_type <= idle;
                end
            st1 : 
                begin
                    init_chan_r <= 1'b1;
                    st_type <= st2;
                end
            st2 : 
                begin
                    init_chan_r <= 1'b0;
                    if (chan_done == 1'b1)
                        begin
                            type_done_r <= 1'b1;
                            st_type <= idle;
                        end
                    else
                        st_type <= st2;
                end
            default : st_type <= idle;
        endcase
        end
end
always @(posedge clk125)
begin
    if (rst)
        begin
            st_chan <= idle;
            xadc_start_r <= 1'b0;
            save_r <= 1'b0;
            xadc_result_r <= 12'b0;
        end
    else
        begin
        case(st_chan)
            idle :
                begin
                    chan_done_r <= 1'b0;
                    if (init_chan == 1'b1)
                        st_chan <= st1;
                    else
                        st_chan <= idle;
                end
            st1 : 
                begin
                    ch_sel_r <= {2'b00, vmm_id_sel}; 
                    st_chan <= st2;
                end
            st2 : 
                begin
                    xadc_start_r <= 1'b1;
                    st_chan <= st3;
                end
            st3 : 
                begin
                    xadc_start_r <= 1'b0;
                    if (xadc_done == 1'b1)
                        begin
                            xadc_result_r <= result;
                            save_r <= 1'b1; 
                            st_chan <= st4;
                        end
                end
            st4 : 
                begin
                    save_r <= 1'b0;
                    chan_done_r <= 1'b1;
                    st_chan <= idle;
                end
            default : st_chan <= idle;
        endcase
        end
end
always @(posedge clk125)
begin
    if(rst)
        begin
            st_pkt <= idle;
            read_cnt <= 3'b0;
            packet <= 64'b0;
            full_pkt_r <= 1'b0;
            pkt_cnt <= 9'b0;
        end
    if(rst_pkt)
        begin
            st_pkt <= idle;
            read_cnt <= 3'b0;
            packet <= 64'b0;
            full_pkt_r <= 1'b0;
        end
    else if (rst_pkt2 == 1'b1)
        pkt_cnt <= 9'b0;
    else
        begin
        case(st_pkt)
            idle :
                begin
                    if (save == 1'b1)
                        begin
                            st_pkt <= st1;
                        end
                    else
                        st_pkt <= idle;
                end
            st1 : 
                begin
                    packet[63:60] <= {1'b0, vmm_id_sel}; 
                    if (read_cnt == 3'b000) packet[11:0] <= xadc_result_r;
                    else if (read_cnt == 3'b001) packet[23:12] <= xadc_result_r;
                    else if (read_cnt == 3'b010) packet[35:24] <= xadc_result_r;
                    else if (read_cnt == 3'b011) packet[47:36] <= xadc_result_r;
                    else if (read_cnt == 3'b100) packet[59:48] <= xadc_result_r;
                    if (read_cnt == 3'b100) 
                        begin
                            read_cnt <= 3'b0;
                            full_pkt_r <= 1'b1;
                        end
                    else if (read_cnt == 3'b000) 
                        begin
                            pkt_cnt <= pkt_cnt + 3'b100; 
                            read_cnt <= read_cnt + 1'b1;
                        end
                    else
                        read_cnt <= read_cnt + 1'b1;
                    st_pkt <= st2;
                end
            st2 : 
                begin
                    full_pkt_r <= 1'b0;
                    if (save == 1'b0) 
                        st_pkt <= idle;
                    else
                        st_pkt <= st2;
                end
            default : st_pkt <= idle;
        endcase
        end
end
always @(posedge clk125)
begin
    if (rst)
        begin
            st_wr       <= idle;
            cnt_fifo    <= 3'b0;
            rst_pkt_r   <= 1'b1; 
        end
    else
        begin
        case (st_wr)
            idle :
                begin
                    data_fifo_enable_r  <= 1'b0; 
                    rst_pkt_r           <= 1'b0;
                    if (full_pkt == 1'b1 || write_start == 1'b1) 
                        begin
                            st_wr           <= st1;
                            packet_len_r    <= {3'b0, pkt_cnt};
                        end
                    else
                        st_wr <= idle;
                end
            st1 : 
                begin
                    data_fifo_enable_r <= 1'b1;
                    st_wr              <= st2;
                    fifo_bus_r         <= packet[63:48];
                end
            st2 : 
                begin
                    data_fifo_enable_r <= 1'b1;
                    st_wr              <= st3;
                    fifo_bus_r         <= packet[47:32];
                end
            st3 : 
                begin
                    data_fifo_enable_r <= 1'b1;
                    st_wr              <= st4;
                    fifo_bus_r         <= packet[31:16];
                end
            st4 : 
                begin
                    data_fifo_enable_r <= 1'b1;
                    st_wr              <= st5;
                    fifo_bus_r         <= packet[15:0];
                    if (pkt_cnt == max_packet_size || write_start == 1'b1) 
                        begin
                            end_of_data_r   <= 1'b1;
                            fifo_done_r     <= 1'b1;
                            rst_pkt2_r      <= 1'b1; 
                        end
                end
            st5 : 
                begin
                    rst_pkt2_r          <= 1'b0;
                    fifo_done_r         <= 1'b0;
                    data_fifo_enable_r  <= 1'b0;
                    rst_pkt_r           <= 1'b1;
                    end_of_data_r       <= 1'b0;
                    st_wr               <= st6;
                end
            st6 : 
                begin
                    st_wr           <= idle;
                end
            default :
                st_wr <= idle;
        endcase
    end
end
xadc_wiz_0 xadc
(
    .convst_in(convst),
    .daddr_in(daddr),
    .dclk_in(clk125),
    .den_in(den),
    .di_in(di),
    .dwe_in(dwe),
    .reset_in(rst_xadc),
    .vp_in(VP_0),
    .vn_in(VN_0),
    .vauxp0(Vaux0_v_p),
    .vauxn0(Vaux0_v_n),
    .vauxp1(Vaux1_v_p),
    .vauxn1(Vaux1_v_n),
    .vauxp2(Vaux2_v_p),
    .vauxn2(Vaux2_v_n),
    .vauxp3(Vaux3_v_p),
    .vauxn3(Vaux3_v_n),
    .vauxp8(Vaux8_v_p),
    .vauxn8(Vaux8_v_n),
    .vauxp9(Vaux9_v_p),
    .vauxn9(Vaux9_v_n),
    .vauxp10(Vaux10_v_p),
    .vauxn10(Vaux10_v_n),
    .vauxp11(Vaux11_v_p),
    .vauxn11(Vaux11_v_n),
    .busy_out(busy_xadc),
    .channel_out(channel),
    .do_out(do_out),
    .drdy_out(drdy),
    .eoc_out(eoc),
    .eos_out(eos),
    .alarm_out()
);
xadc_read XADC
(
    .clk125(clk125),
    .rst(rst),
    .start(xadc_start),
    .ch_sel(ch_sel),
    .busy_xadc(busy_xadc),
    .drdy(drdy),
    .channel(channel),
    .do_out(do_out),
    .eoc(eoc),
    .eos(eos),
    .done(xadc_done),
    .result(result),
    .convst(convst),
    .daddr(daddr),
    .den(den),
    .dwe(dwe),
    .di(di),
    .rst_xadc(rst_xadc),
    .mux_select(mux_select)
);
endmodule
