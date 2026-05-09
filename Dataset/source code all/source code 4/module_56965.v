`timescale 1ns / 10ps
`define I2C_CMD_NOP   4'b0000
`define I2C_CMD_START 4'b0001
`define I2C_CMD_STOP  4'b0010
`define I2C_CMD_WRITE 4'b0100
`define I2C_CMD_READ  4'b1000
`timescale 1ns / 10ps
`define I2C_CMD_NOP   4'b0000
`define I2C_CMD_START 4'b0001
`define I2C_CMD_STOP  4'b0010
`define I2C_CMD_WRITE 4'b0100
`define I2C_CMD_READ  4'b1000
module i2c_master_bit_ctrl(
	clk, rst, nReset, 
	clk_cnt, ena, cmd, cmd_ack, busy, al, din, dout,
	scl_i, scl_o, scl_oen, sda_i, sda_o, sda_oen
	);
	input clk;
	input rst;
	input nReset;
	input ena;            
	input [15:0] clk_cnt; 
	input  [3:0] cmd;
	output       cmd_ack; 
	reg cmd_ack;
	output       busy;    
	reg busy;
	output       al;      
	reg al;
	input  din;
	output dout;
	reg dout;
	input  scl_i;         
	output scl_o;         
	output scl_oen;       
	reg scl_oen;
	input  sda_i;         
	output sda_o;         
	output sda_oen;       
	reg sda_oen;
	reg sSCL, sSDA;             
	reg dscl_oen;               
	reg sda_chk;                
	reg clk_en;                 
	wire slave_wait;
	reg [15:0] cnt;             
	reg [16:0] c_state; 
	always @(posedge clk)
	  dscl_oen <= #1 scl_oen;
	assign slave_wait = dscl_oen && !sSCL;
	always @(posedge clk or negedge nReset)
	  if(~nReset)
	    begin
	        cnt    <= #1 16'h0;
	        clk_en <= #1 1'b1;
	    end
	  else if (rst)
	    begin
	        cnt    <= #1 16'h0;
	        clk_en <= #1 1'b1;
	    end
	  else if ( ~|cnt || !ena)
	    begin
	        cnt    <= #1 clk_cnt;
	        clk_en <= #1 1'b1;
	    end
	  else if (slave_wait)
	    begin
	        cnt    <= #1 cnt;
	        clk_en <= #1 1'b0;    
	    end
	  else
	    begin
	        cnt    <= #1 cnt - 16'h1;
	        clk_en <= #1 1'b0;
	    end
	reg dSCL, dSDA;
	reg sta_condition;
	reg sto_condition;
	always @(posedge clk or negedge nReset)
	  if (~nReset)
	    begin
	        sSCL <= #1 1'b1;
	        sSDA <= #1 1'b1;
	        dSCL <= #1 1'b1;
	        dSDA <= #1 1'b1;
	    end
	  else if (rst)
	    begin
	        sSCL <= #1 1'b1;
	        sSDA <= #1 1'b1;
	        dSCL <= #1 1'b1;
	        dSDA <= #1 1'b1;
	    end
	  else
	    begin
	        sSCL <= #1 scl_i;
	        sSDA <= #1 sda_i;
	        dSCL <= #1 sSCL;
	        dSDA <= #1 sSDA;
	    end
	always @(posedge clk or negedge nReset)
	  if (~nReset)
	    begin
	        sta_condition <= #1 1'b0;
	        sto_condition <= #1 1'b0;
	    end
	  else if (rst)
	    begin
	        sta_condition <= #1 1'b0;
	        sto_condition <= #1 1'b0;
	    end
	  else
	    begin
	        sta_condition <= #1 ~sSDA &  dSDA & sSCL;
	        sto_condition <= #1  sSDA & ~dSDA & sSCL;
	    end
	always @(posedge clk or negedge nReset)
	  if(!nReset)
	    busy <= #1 1'b0;
	  else if (rst)
	    busy <= #1 1'b0;
	  else
	    busy <= #1 (sta_condition | busy) & ~sto_condition;
	reg cmd_stop;
	always @(posedge clk or negedge nReset)
	  if (~nReset)
	    cmd_stop <= #1 1'b0;
	  else if (rst)
	    cmd_stop <= #1 1'b0;
	  else if (clk_en)
	    cmd_stop <= #1 cmd == `I2C_CMD_STOP;
	always @(posedge clk or negedge nReset)
	  if (~nReset)
	    al <= #1 1'b0;
	  else if (rst)
	    al <= #1 1'b0;
	  else
	    al <= #1 (sda_chk & ~sSDA & sda_oen) | (|c_state & sto_condition & ~cmd_stop);
	always @(posedge clk)
	  if(sSCL & ~dSCL)
	    dout <= #1 sSDA;
	parameter idle    = 17'b0_0000_0000_0000_0000;
	parameter start_a = 17'b0_0000_0000_0000_0001;
	parameter start_b = 17'b0_0000_0000_0000_0010;
	parameter start_c = 17'b0_0000_0000_0000_0100;
	parameter start_d = 17'b0_0000_0000_0000_1000;
	parameter start_e = 17'b0_0000_0000_0001_0000;
	parameter stop_a  = 17'b0_0000_0000_0010_0000;
	parameter stop_b  = 17'b0_0000_0000_0100_0000;
	parameter stop_c  = 17'b0_0000_0000_1000_0000;
	parameter stop_d  = 17'b0_0000_0001_0000_0000;
	parameter rd_a    = 17'b0_0000_0010_0000_0000;
	parameter rd_b    = 17'b0_0000_0100_0000_0000;
	parameter rd_c    = 17'b0_0000_1000_0000_0000;
	parameter rd_d    = 17'b0_0001_0000_0000_0000;
	parameter wr_a    = 17'b0_0010_0000_0000_0000;
	parameter wr_b    = 17'b0_0100_0000_0000_0000;
	parameter wr_c    = 17'b0_1000_0000_0000_0000;
	parameter wr_d    = 17'b1_0000_0000_0000_0000;
	always @(posedge clk or negedge nReset)
	  if (!nReset)
	    begin
	        c_state <= #1 idle;
	        cmd_ack <= #1 1'b0;
	        scl_oen <= #1 1'b1;
	        sda_oen <= #1 1'b1;
	        sda_chk <= #1 1'b0;
	    end
	  else if (rst | al)
	    begin
	        c_state <= #1 idle;
	        cmd_ack <= #1 1'b0;
	        scl_oen <= #1 1'b1;
	        sda_oen <= #1 1'b1;
	        sda_chk <= #1 1'b0;
	    end
	  else
	    begin
	        cmd_ack   <= #1 1'b0; 
	        if (clk_en)
	          case (c_state) 
	            idle:
	            begin
	                case (cmd) 
	                  `I2C_CMD_START:
	                     c_state <= #1 start_a;
	                  `I2C_CMD_STOP:
	                     c_state <= #1 stop_a;
	                  `I2C_CMD_WRITE:
	                     c_state <= #1 wr_a;
	                  `I2C_CMD_READ:
	                     c_state <= #1 rd_a;
	                  default:
	                    c_state <= #1 idle;
	                endcase
	                scl_oen <= #1 scl_oen; 
	                sda_oen <= #1 sda_oen; 
	                sda_chk <= #1 1'b0;    
	            end
	            start_a:
	            begin
	                c_state <= #1 start_b;
	                scl_oen <= #1 scl_oen; 
	                sda_oen <= #1 1'b1;    
	                sda_chk <= #1 1'b0;    
	            end
	            start_b:
	            begin
	                c_state <= #1 start_c;
	                scl_oen <= #1 1'b1; 
	                sda_oen <= #1 1'b1; 
	                sda_chk <= #1 1'b0; 
	            end
	            start_c:
	            begin
	                c_state <= #1 start_d;
	                scl_oen <= #1 1'b1; 
	                sda_oen <= #1 1'b0; 
	                sda_chk <= #1 1'b0; 
	            end
	            start_d:
	            begin
	                c_state <= #1 start_e;
	                scl_oen <= #1 1'b1; 
	                sda_oen <= #1 1'b0; 
	                sda_chk <= #1 1'b0; 
	            end
	            start_e:
	            begin
	                c_state <= #1 idle;
	                cmd_ack <= #1 1'b1;
	                scl_oen <= #1 1'b0; 
	                sda_oen <= #1 1'b0; 
	                sda_chk <= #1 1'b0; 
	            end
	            stop_a:
	            begin
	                c_state <= #1 stop_b;
	                scl_oen <= #1 1'b0; 
	                sda_oen <= #1 1'b0; 
	                sda_chk <= #1 1'b0; 
	            end
	            stop_b:
	            begin
	                c_state <= #1 stop_c;
	                scl_oen <= #1 1'b1; 
	                sda_oen <= #1 1'b0; 
	                sda_chk <= #1 1'b0; 
	            end
	            stop_c:
	            begin
	                c_state <= #1 stop_d;
	                scl_oen <= #1 1'b1; 
	                sda_oen <= #1 1'b0; 
	                sda_chk <= #1 1'b0; 
	            end
	            stop_d:
	            begin
	                c_state <= #1 idle;
	                cmd_ack <= #1 1'b1;
	                scl_oen <= #1 1'b1; 
	                sda_oen <= #1 1'b1; 
	                sda_chk <= #1 1'b0; 
	            end
	            rd_a:
	            begin
	                c_state <= #1 rd_b;
	                scl_oen <= #1 1'b0; 
	                sda_oen <= #1 1'b1; 
	                sda_chk <= #1 1'b0; 
	            end
	            rd_b:
	            begin
	                c_state <= #1 rd_c;
	                scl_oen <= #1 1'b1; 
	                sda_oen <= #1 1'b1; 
	                sda_chk <= #1 1'b0; 
	            end
	            rd_c:
	            begin
	                c_state <= #1 rd_d;
	                scl_oen <= #1 1'b1; 
	                sda_oen <= #1 1'b1; 
	                sda_chk <= #1 1'b0; 
	            end
	            rd_d:
	            begin
	                c_state <= #1 idle;
	                cmd_ack <= #1 1'b1;
	                scl_oen <= #1 1'b0; 
	                sda_oen <= #1 1'b1; 
	                sda_chk <= #1 1'b0; 
	            end
	            wr_a:
	            begin
	                c_state <= #1 wr_b;
	                scl_oen <= #1 1'b0; 
	                sda_oen <= #1 din;  
	                sda_chk <= #1 1'b0; 
	            end
	            wr_b:
	            begin
	                c_state <= #1 wr_c;
	                scl_oen <= #1 1'b1; 
	                sda_oen <= #1 din;  
	                sda_chk <= #1 1'b1; 
	            end
	            wr_c:
	            begin
	                c_state <= #1 wr_d;
	                scl_oen <= #1 1'b1; 
	                sda_oen <= #1 din;
	                sda_chk <= #1 1'b1; 
	            end
	            wr_d:
	            begin
	                c_state <= #1 idle;
	                cmd_ack <= #1 1'b1;
	                scl_oen <= #1 1'b0; 
	                sda_oen <= #1 din;
	                sda_chk <= #1 1'b0; 
	            end
	          endcase
	    end
	assign scl_o = 1'b0;
	assign sda_o = 1'b0;
endmodule
