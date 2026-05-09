Here's the corrected Verilog code:


`timescale 1ns / 1ps

module master_cnt(
    input wire clk,
    output wire [17:0] cnt
);
    wire [8:0] ca;
    wire [8:0] cb;
    assign cnt = {cb,ca};
    clineas cnta (clk, ca);
    cframes cntb (clk, cb);
endmodule

module gensync(
    input wire clk,
    input wire [17:0] cnt,
    output wire intr,
    output wire sync
);
    wire line, field;
    assign line = ~(cnt[5] | cnt[7]) & cnt[6] & cnt[8];
    assign field = cnt[12] & cnt[13] & cnt[14] & cnt[15] & cnt[16];
    assign sync = ~(line | field);
    assign intr = ~field;
endmodule

module io(
    input wire clk, 
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
    always @(posedge clk) begin
        ear_y_teclado <= {ear,kbd};
        if (!en254w)
            ffmic <= d3;
        if (!en254r)
            ffspk <= 1;
        else if (!en254w)
            ffspk <= 0;
    end
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
    always @(posedge clk) begin
        if (vhold)
            envramab <= vramdec;
        else
            envramab <= vramdec | envramab;
        if (&cnt[2:0])
            ffvideoi <= (videoinverso & viden);
        if (shld)
            shiftreg <= shiftreg << 1;
        else
            shiftreg <= DinShiftR;
    end
    assign cramce = ~(a[11] | envramab);
    assign sramce = ~(envramab | cramce);
    assign scramwr = envramab | wr;
    assign scramoe = ~scramwr;
    assign ASRAMVideo = {cnt[16:12],cnt[7:3]};
    assign ACRAMVideo = cnt[11:9];
    assign shld = ~(&cnt[2:0] & viden);
    assign video = (shiftreg[7] ^ ffvideoi);
endmodule    

module jace(
    input wire clk,
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
    master_cnt cont (clk, c);
    gensync gsync (clk, c, intr, sync);
    io modulo_io (
        .clk(clk),
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

module clineas(
    input wire clk,
    output wire [8:0] cnt
);
    reg [8:0] contador = 9'b0;
    assign cnt = contador;
    always @(posedge clk)
        contador <= (contador==9'h19f)? 9'b0 : contador+1;
endmodule

module cframes(
    input wire clk,
    output wire [8:0] cnt
);
    reg [8:0] contador = 9'b0;
    assign cnt = contador;
    always @(posedge clk)
        contador <= (contador==9'h137)? 9'b0 : contador+1;
endmodule