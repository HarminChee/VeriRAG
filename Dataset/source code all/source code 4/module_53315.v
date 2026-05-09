`timescale 1ns/1ns
`timescale 1ns/1ns
module input_ctrl(
    clk,
    reset,
    crc_check_wrreq,
    crc_check_data,
    crc_usedw,
    crc_result_wrreq,
    crc_result,
    um2cdp_tx_enable,
    cdp2um_data_valid,
    cdp2um_data,
    input2output_wrreq,
    input2output_data,
    input2output_usedw,
	 um2cdp_path
  );
    input clk;
    input reset;
    input crc_check_wrreq;
    input [138:0]crc_check_data;
    output [7:0]crc_usedw;
    input crc_result_wrreq;
    input crc_result;
    input um2cdp_tx_enable;
    output cdp2um_data_valid;
    output [138:0]cdp2um_data;
    output input2output_wrreq;
    output [138:0]input2output_data;
    input [7:0]input2output_usedw;
	 input um2cdp_path;		
    wire [7:0]crc_usedw;
    reg cdp2um_data_valid;
    reg [138:0]cdp2um_data;
    reg input2output_wrreq;
    reg [138:0]input2output_data;
    reg [138:0]data_reg;
    reg level2_fifo_rdreq;
    wire [138:0]level2_fifo_q;
    reg flag_fifo_rdreq;
    wire flag_fifo_q;
    wire flag_fifo_empty;
    reg [1:0]current_state;
    parameter idle=2'b0,
              transmit=2'b01,
              discard=2'b10,
              over_4byte=2'b11;
always@(posedge clk or negedge reset)
    if(!reset)
      begin
          level2_fifo_rdreq<=1'b0;
          flag_fifo_rdreq<=1'b0;
          cdp2um_data_valid<=1'b0;
          current_state<=idle;
      end
    else
      begin
          case(current_state)
              idle:
                  begin
                      flag_fifo_rdreq<=1'b0;
                      level2_fifo_rdreq<=1'b0;
                      cdp2um_data_valid<=1'b0;
                      input2output_wrreq<=1'b0;
                      if(um2cdp_tx_enable)
                        begin
                            if((um2cdp_path == 1'b1 && input2output_usedw<8'd161) || um2cdp_path == 1'b0)
                              begin
                                  if(!flag_fifo_empty)
                                    begin
                                        if(flag_fifo_q==1'b1)
                                          begin
                                              flag_fifo_rdreq<=1'b1;
                                              level2_fifo_rdreq<=1'b1;
                                              current_state<=transmit;
                                          end
                                        else
                                          begin
                                              flag_fifo_rdreq<=1'b1;
                                              level2_fifo_rdreq<=1'b1;
                                              current_state<=discard;
                                          end
                                    end
                                  else
                                    begin
                                        current_state<=idle;
                                    end
                              end
                            else
                              begin
                                  current_state<=idle;
                              end
                        end
                      else
                        begin
                            current_state<=idle;
                        end
                  end
              transmit:
                  begin
                      flag_fifo_rdreq<=1'b0;
                      level2_fifo_rdreq<=1'b0;
                      cdp2um_data_valid<=1'b0;
                      input2output_wrreq<=1'b0;
                      data_reg<=level2_fifo_q;
                      if(level2_fifo_q[138:136]==3'b101)
                        begin
                            level2_fifo_rdreq<=1'b1;
                            cdp2um_data_valid<=1'b0;
                            cdp2um_data<=data_reg;
                            input2output_wrreq<=1'b0;
                            input2output_data<=data_reg;
                            current_state<=transmit;
                        end
                      else if(level2_fifo_q[138:136]==3'b110)
                        begin
                            level2_fifo_rdreq<=1'b0;
                            if(level2_fifo_q[135:132]>4'b0011)
                              begin
                                  cdp2um_data_valid<=1'b1;
                                  cdp2um_data<=data_reg;
                                  input2output_wrreq<=1'b1;
                                  input2output_data<=data_reg;
                                  current_state<=over_4byte;
                              end
                            else if(level2_fifo_q[135:132]==4'b0011)
                              begin
                                   cdp2um_data_valid<=1'b1;
                                   cdp2um_data<=data_reg;
                                   cdp2um_data[138:136]<=3'b110;
                                   cdp2um_data[135:132]<=4'b1111;
                                   input2output_wrreq<=1'b1;
                                   input2output_data<=data_reg;
                                   input2output_data[138:136]<=3'b110;
                                   input2output_data[135:132]<=4'b1111;
                                   current_state<=idle;
                               end
                             else
                               begin
                                   cdp2um_data_valid<=1'b1;
                                   cdp2um_data<=data_reg;
                                   cdp2um_data[138:136]<=3'b110;
                                   cdp2um_data[135:132]<=4'b1111-(4'b0011-level2_fifo_q[135:132]);
                                   input2output_wrreq<=1'b1;
                                   input2output_data<=data_reg;
                                   input2output_data[138:136]<=3'b110;
                                   input2output_data[135:132]<=4'b1111-(4'b0011-level2_fifo_q[135:132]);
                                   current_state<=idle;
                               end
                        end
                      else
                        begin
                            level2_fifo_rdreq<=1'b1;
                            cdp2um_data_valid<=1'b1;
                            cdp2um_data<=data_reg;
                            input2output_wrreq<=1'b1;
                            input2output_data<=data_reg;
                            current_state<=transmit;
                        end
                  end
              discard:
                  begin
                      flag_fifo_rdreq<=1'b0;
                      level2_fifo_rdreq<=1'b0;
                      if(level2_fifo_q[138:136]==3'b110)
                        begin
                            current_state<=idle;
                        end
                      else
                        begin
                            level2_fifo_rdreq<=1'b1;
                            current_state<=discard;
                        end
                  end
              over_4byte:
                  begin
                      cdp2um_data_valid<=1'b1;
                      cdp2um_data<=data_reg;
                      cdp2um_data[135:132]<=data_reg[135:132]-4'b0100;
                      input2output_wrreq<=1'b1;
                      input2output_data<=data_reg;
                      input2output_data[135:132]<=data_reg[135:132]-4'b0100;
                      current_state<=idle;
                  end
              default:
                  begin
                      current_state<=idle;
                  end    
          endcase
      end
level2_256_139 level2_256_139(
	.aclr(!reset),
	.clock(clk),
	.data(crc_check_data),
	.rdreq(level2_fifo_rdreq),
	.wrreq(crc_check_wrreq),
	.q(level2_fifo_q),
	.usedw(crc_usedw)
  );
rx_64_1 rx_64_1(
	.aclr(!reset),
	.clock(clk),
	.data(crc_result),
	.rdreq(flag_fifo_rdreq),
	.wrreq(crc_result_wrreq),
	.empty(flag_fifo_empty),
	.q(flag_fifo_q)
   );
endmodule
