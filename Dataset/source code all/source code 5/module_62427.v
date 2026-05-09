module load_data_translator(
    d_readdatain,
    d_address,
    load_size,
    load_sign_ext,
    d_loadresult);
parameter WIDTH=32;
input [WIDTH-1:0] d_readdatain;
input [1:0] d_address;
input [1:0] load_size;
input load_sign_ext;
output [WIDTH-1:0] d_loadresult;
reg [WIDTH-1:0] d_loadresult;
always @(d_readdatain or d_address or load_size or load_sign_ext)
begin
    case (load_size)
        2'b11:
        begin
            case (d_address[1:0])
                0: d_loadresult[7:0]=d_readdatain[31:24];
                1: d_loadresult[7:0]=d_readdatain[23:16];
                2: d_loadresult[7:0]=d_readdatain[15:8];
                default: d_loadresult[7:0]=d_readdatain[7:0];
            endcase
            d_loadresult[31:8]={24{load_sign_ext&d_loadresult[7]}};
        end
        2'b01:
        begin
            case (d_address[1])
                0: d_loadresult[15:0]=d_readdatain[31:16];
                default: d_loadresult[15:0]=d_readdatain[15:0];
            endcase
            d_loadresult[31:16]={16{load_sign_ext&d_loadresult[15]}};
        end
        default:
            d_loadresult=d_readdatain;
    endcase
end
endmodule
module data_mem( clk, resetn, en,
                d_writedata,
                d_address,
                boot_daddr, boot_ddata, boot_dwe, 
                op,
                d_loadresult,
		d_wr,
		d_byteena,
		d_writedatamem,
		d_readdatain
		);
parameter D_ADDRESSWIDTH=32;
parameter DM_DATAWIDTH=32;
parameter DM_BYTEENAWIDTH=4;             
parameter DM_ADDRESSWIDTH=16;
parameter DM_SIZE=16384;
input clk;
input resetn;
input en;
input [31:0] boot_daddr;
input [31:0] boot_ddata;
input boot_dwe;
input [D_ADDRESSWIDTH-1:0] d_address;
input [4-1:0] op;
input [DM_DATAWIDTH-1:0] d_writedata;
output [DM_DATAWIDTH-1:0] d_loadresult;
output [DM_BYTEENAWIDTH-1:0] d_byteena;
output d_wr;
output [31:0] d_writedatamem;
input [31:0] d_readdatain;
wire [DM_BYTEENAWIDTH-1:0] d_byteena;
wire [DM_DATAWIDTH-1:0] d_readdatain;
wire [DM_DATAWIDTH-1:0] d_writedatamem;
wire d_write;
wire [1:0] d_address_registered;
wire [2:0] op_registered;
assign d_write=op[3];
assign d_wr = d_write & en & ~d_address[31];
register d_address_reg(d_address[1:0],clk,resetn,en,d_address_registered);
    defparam d_address_reg.WIDTH=2;
register op_reg(op[2:0],clk,resetn,en,op_registered);
    defparam op_reg.WIDTH=3;
store_data_translator sdtrans_inst(
    .write_data(d_writedata),
    .d_address(d_address[1:0]),
    .store_size(op[1:0]),
    .d_byteena(d_byteena),
    .d_writedataout(d_writedatamem));
load_data_translator ldtrans_inst(
    .d_readdatain(d_readdatain),
    .d_address(d_address_registered[1:0]),
    .load_size(op_registered[1:0]),
    .load_sign_ext(op_registered[2]),
    .d_loadresult(d_loadresult));
endmodule
module store_data_translator(
    write_data,             
    d_address,
    store_size,
    d_byteena,
    d_writedataout);        
parameter WIDTH=32;
input [WIDTH-1:0] write_data;
input [1:0] d_address;
input [1:0] store_size;
output [3:0] d_byteena;
output [WIDTH-1:0] d_writedataout;
reg [3:0] d_byteena;
reg [WIDTH-1:0] d_writedataout;
always @(write_data or d_address or store_size)
begin
    case (store_size)
        2'b11:
            case(d_address[1:0])
                0: 
                begin 
                    d_byteena=4'b1000; 
                    d_writedataout={write_data[7:0],24'b0}; 
                end
                1: 
                begin 
                    d_byteena=4'b0100; 
                    d_writedataout={8'b0,write_data[7:0],16'b0}; 
                end
                2: 
                begin 
                    d_byteena=4'b0010; 
                    d_writedataout={16'b0,write_data[7:0],8'b0}; 
                end
                default: 
                begin 
                    d_byteena=4'b0001; 
                    d_writedataout={24'b0,write_data[7:0]}; 
                end
            endcase
        2'b01:
            case(d_address[1])
                0: 
                begin 
                    d_byteena=4'b1100; 
                    d_writedataout={write_data[15:0],16'b0}; 
                end
                default: 
                begin 
                    d_byteena=4'b0011; 
                    d_writedataout={16'b0,write_data[15:0]}; 
                end
            endcase
        default:
        begin
            d_byteena=4'b1111;
            d_writedataout=write_data;
        end
    endcase
end
endmodule
module load_data_translator(
    d_readdatain,
    d_address,
    load_size,
    load_sign_ext,
    d_loadresult);
parameter WIDTH=32;
input [WIDTH-1:0] d_readdatain;
input [1:0] d_address;
input [1:0] load_size;
input load_sign_ext;
output [WIDTH-1:0] d_loadresult;
reg [WIDTH-1:0] d_loadresult;
always @(d_readdatain or d_address or load_size or load_sign_ext)
begin
    case (load_size)
        2'b11:
        begin
            case (d_address[1:0])
                0: d_loadresult[7:0]=d_readdatain[31:24];
                1: d_loadresult[7:0]=d_readdatain[23:16];
                2: d_loadresult[7:0]=d_readdatain[15:8];
                default: d_loadresult[7:0]=d_readdatain[7:0];
            endcase
            d_loadresult[31:8]={24{load_sign_ext&d_loadresult[7]}};
        end
        2'b01:
        begin
            case (d_address[1])
                0: d_loadresult[15:0]=d_readdatain[31:16];
                default: d_loadresult[15:0]=d_readdatain[15:0];
            endcase
            d_loadresult[31:16]={16{load_sign_ext&d_loadresult[15]}};
        end
        default:
            d_loadresult=d_readdatain;
    endcase
end
endmodule
