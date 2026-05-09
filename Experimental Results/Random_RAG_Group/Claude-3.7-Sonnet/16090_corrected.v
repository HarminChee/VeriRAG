`timescale 1ns / 1ps
module clineas(
    input wire clk,
	 input wire test_i,
    output wire [8:0] cnt
	 );
	reg [8:0] contador = 9'b0;
	assign cnt = contador;
	always @(negedge (test_i ? clk : clk))
		contador <= (contador==9'h19f)? 9'b0 : contador+1;
endmodule
module cframes(
    input wire clk,
	 input wire test_i,
    output wire [8:0] cnt
    );
	reg [8:0] contador = 9'b0;
	assign cnt = contador;
	always @(negedge (test_i ? clk : clk))
		contador <= (contador==9'h137)? 9'b0 : contador+1;
endmodule
module master_cnt(
	input wire clk,
	input wire test_i,
	output wire [17:0] cnt
	);
	wire [8:0] ca;
	wire [8:0] cb;
	assign cnt = {cb,ca};
	clineas cnta (clk,test_i, ca);
	cframes cntb (ca[8],test_i, cb);
endmodule
module gensync(
	input wire c5,
	input wire c6,
	input wire c7,
	input wire c8,
	input wire c12,
	input wire c13,
	input wire c14,
	input wire c15,
	input wire c16,
	output wire intr,
	output wire sync);
	wire line, field;
	assign line = ~(c5 | c7) & c6 & c8;
	assign field = c12 & c13 & c14 & c15 & c16;
	assign sync = ~(line | field);
	assign intr = ~field;
endmodule
module io(
   input wire clk,
	input wire test_i,
	input wire en254r,
	input wire en254w,
	input wire [4:0] kbd,
	input wire ear,
	input wire d3,
	output wire [5:0] dout,
	output wire mic,
	output wire spk
	);
	reg ffmic;
	reg ffspk;
	reg [5:0] ear_y_teclado;
	assign dout = (!en254r)? ear_y_teclado : 6'bzzzzzz;
	assign mic = ffmic;
	assign spk = ffspk;
	always @(posedge (test_i ? clk : clk))
		ear_y_teclado <= {ear,kbd};
	always @(posedge (test_i ? clk : clk))
		if (!en254w)
			ffmic <= d3;
	always @(posedge (test_i ? clk : clk))
		if (!en254r)
			ffspk <= 1;
		else if (!en254w)
			ffspk <= 0;
endmodule
module decodificador(
	input wire [15:0] a,
	input wire mreq,
	input wire iorq,
	input wire rd,
	input wire wr,
	output wire romce,
	output wire ramce,
	output wire xramce,
	output wire vramdec,
	output wire en254r,
	output wire en254w
	);
	wire en254;
	assign romce = mreq | a[15] | a[14] | a[13] | rd;
	assign ramce = mreq | a[15] | a[14] | ~a[13] | ~a[12]; 
	assign xramce = mreq | a[15] | ~a[14];  
	assign vramdec = mreq | a[15] | a[14] | ~a[13] | a[12]; 
	assign en254 = iorq | a[0]; 
	assign en254r = en254 | rd;
	assign en254w = en254 | wr;
endmodule
module videogen_and_cpuctrl(
	input wire clk,
	input wire test_i,
	input wire [15:0] a,  
	input wire wr,
	input wire vramdec,     
	input wire [17:0] cnt,  
	input wire [7:0] DinShiftR,  
	input wire videoinverso,      
	output wire cpuwait,    
	output wire [9:0] ASRAMVideo,  
	output wire [2:0] ACRAMVideo,  
	output wire sramce,     
	output wire cramce,     
	output wire scramoe,    
	output wire scramwr,    
	output wire video       
	);
	wire vhold;
	wire viden;
	wire shld;
	reg ffvideoi;     
	reg envramab;    
	reg [7:0] shiftreg;
	assign viden = ~(cnt[16] & cnt[15]) & (~(cnt[17] | cnt[8]));
	assign vhold = ~(a[10] & viden);
	assign cpuwait = vhold | vramdec;
	always @(posedge (test_i ? clk : clk))
		if (vhold)
			envramab <= vramdec;
		else
			envramab <= vramdec | envramab;
	assign cramce = ~(a[11] | envramab);
	assign sramce = ~(envramab | cramce);
	assign scramwr = envramab | wr;
	assign scramoe = ~scramwr;
	assign ASRAMVideo = {cnt[16:12],cnt[7:3]};
	assign ACRAMVideo = cnt[11:9];
	always @(posedge (test_i ? clk : clk))
		if (&cnt[2:0])
			ffvideoi <= (videoinverso & viden);
	assign shld = ~(&cnt[2:0] & viden);
	always @(posedge (test_i ? clk : clk))
		if (shld)
			shiftreg <= shiftreg<<1;
		else
			shiftreg <= DinShiftR;
	assign video = (shiftreg[7] ^ ffvideoi);
endmodule	
module jace(
   input wire clkm,
	input wire clk,
	input wire test_i,
	output wire cpuclk,
	input wire [15:0] a,  
	input wire d3,
	output wire [5:0] dout,   	
	input wire wr,
	input wire vramdec,
	output wire intr,
	output wire cpuwait,    
	input wire en254r,
	input wire en254w,
	output wire sramce,     
	output wire cramce,     
	output wire scramoe,    
	output wire scramwr,    
	input wire [7:0] DinShiftR,  
	input wire videoinverso,      
	output wire [9:0] ASRAMVideo,  
	output wire [2:0] ACRAMVideo,  
	input wire [4:0] kbd,
	input wire ear,
	output wire mic,
	output wire spk,
	output wire sync,
	output wire video       
	);
	wire [17:0] c;
	assign cpuclk = c[0];
	master_cnt cont (clk,test_i, c);
	gensync gsync (c[5],c[6],c[7],c[8],c[12],c[13],c[14],c[15],c[16],intr,sync);
	io modulo_io (
		.clk(clkm),
		.test_i(test_i),
		.en254r(en254r),
		.en254w(en254w),
		.kbd(kbd),
		.ear(ear),
		.d3(d3),
		.dout(dout),
		.mic(mic),
		.spk(spk)
	);
   videogen_and_cpuctrl arbitrador(
		.clk(clk),
		.test_i(test_i),
		.a(a),  
		.wr(wr),
		.vramdec(vramdec),     
		.cnt(c),  
		.DinShiftR(DinShiftR),  
		.videoinverso(videoinverso),      
		.cpuwait(cpuwait),    
		.ASRAMVideo(ASRAMVideo),  
		.ACRAMVideo(ACRAMVideo),  
		.sramce(sramce),     
		.cramce(cramce),     
		.scramoe(scramoe),    
		.scramwr(scramwr),    
		.video(video)       
		);
endmodule