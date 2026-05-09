module fetch (
    mio_data_vld,
    mio_data_rdata,
    mio_instr_vld,
    mio_instr_rdata,
    pc_p_4,
    branch_p_4,
    clr,
    clk,
    pen,
    ra1,
    ra2,
    rad,
    ra1_zero,
    ra2_zero,
    rad_zero,
    rd1,
    rd2,
    rdd,
    rdm,
    imm,
    pc,
    instr,
    insn,
    trap,
    lui,
    auipc,
    jal,
    jalr,
    bra,
    ld,
    st,
    opi,
    opr,
    fen,
    sys,
    rdc,
    rdco,
    f3,
    f7,
    branch,
    rwe,
    mio_instr_addr,
    mio_instr_wdata,
    mio_instr_req,
    mio_instr_rw,
    mio_instr_wmask,
    mio_data_addr,
    mio_data_wdata,
    mio_data_req,
    mio_data_rw,
    mio_data_wmask,
    junk
);
    input mio_data_vld;
    input [31:0] mio_data_rdata;
    input mio_instr_vld;
    input [31:0] mio_instr_rdata;
    input [31:0] pc_p_4;
    input branch_p_4;
    input clr;
    input clk;
    output pen;
    output [4:0] ra1;
    output [4:0] ra2;
    output [4:0] rad;
    output ra1_zero;
    output ra2_zero;
    output rad_zero;
    output [31:0] rd1;
    output [31:0] rd2;
    output [31:0] rdd;
    output [31:0] rdm;
    output [31:0] imm;
    output [31:0] pc;
    output [31:0] instr;
    output [47:0] insn;
    output trap;
    output lui;
    output auipc;
    output jal;
    output jalr;
    output bra;
    output ld;
    output st;
    output opi;
    output opr;
    output fen;
    output sys;
    output rdc;
    output [2:0] rdco;
    output [2:0] f3;
    output f7;
    output branch;
    output rwe;
    output [31:0] mio_instr_addr;
    output [31:0] mio_instr_wdata;
    output mio_instr_req;
    output mio_instr_rw;
    output [3:0] mio_instr_wmask;
    output [31:0] mio_data_addr;
    output [31:0] mio_data_wdata;
    output mio_data_req;
    output mio_data_rw;
    output [3:0] mio_data_wmask;
    output junk;
    wire _2170 = 1'b0;
    wire _2171 = 1'b0;
    // Wires related to _1814 OR reduction removed
    reg _2172;
    wire [3:0] _2166 = 4'b0000;
    wire [3:0] _2167 = 4'b0000;
    wire [3:0] _1951 = 4'b0000;
    reg [3:0] _2168;
    wire _2162 = 1'b0;
    wire _2163 = 1'b0;
    wire _1952 = 1'b0;
    reg _2164;
    wire _2158 = 1'b0;
    wire _2159 = 1'b0;
    wire _1953 = 1'b0;
    reg _2160;
    wire [31:0] _2154 = 32'b00000000000000000000000000000000;
    wire [31:0] _2155 = 32'b00000000000000000000000000000000;
    wire [31:0] _1954 = 32'b00000000000000000000000000000000;
    reg [31:0] _2156;
    wire [31:0] _2150 = 32'b00000000000000000000000000000000;
    wire [31:0] _2151 = 32'b00000000000000000000000000000000;
    wire [31:0] _1955 = 32'b00000000000000000000000000000000;
    reg [31:0] _2152;
    wire [3:0] _2146 = 4'b0000;
    wire [3:0] _2147 = 4'b0000;
    wire [3:0] _1994 = 4'b0000;
    reg [3:0] _2148;
    wire _2142 = 1'b0;
    wire _2143 = 1'b0;
    reg _2144;
    wire _2138 = 1'b0;
    wire _2139 = 1'b0;
    wire _1995 = 1'b0;
    reg _1996;
    reg _2140;
    wire [31:0] _2134 = 32'b00000000000000000000000000000000;
    wire [31:0] _2135 = 32'b00000000000000000000000000000000;
    wire [31:0] _1997 = 32'b00000000000000000000000000000000;
    reg [31:0] _2136;
    wire [31:0] _2130 = 32'b00000000000000000000000000000000;
    wire [31:0] _2131 = 32'b00000000000000000000000000000000;
    reg [31:0] _2132;
    wire _2126 = 1'b0;
    wire _2127 = 1'b0;
    wire _1961 = 1'b0;
    reg _2128;
    wire _2122 = 1'b0;
    wire _2123 = 1'b0;
    wire _1962 = 1'b0;
    reg _2124;
    wire _2118 = 1'b0;
    wire _2119 = 1'b0;
    wire _1963 = 1'b0;
    reg _2120;
    wire [2:0] _2114 = 3'b000;
    wire [2:0] _2115 = 3'b000;
    wire [2:0] _1964 = 3'b000;
    reg [2:0] _2116;
    wire [2:0] _2110 = 3'b000;
    wire [2:0] _2111 = 3'b000;
    wire [2:0] _1965 = 3'b000;
    reg [2:0] _2112;
    wire _2106 = 1'b0;
    wire _2107 = 1'b0;
    wire _1966 = 1'b0;
    reg _2108;
    wire _2102 = 1'b0;
    wire _2103 = 1'b0;
    wire _1967 = 1'b0;
    reg _2104;
    wire _2098 = 1'b0;
    wire _2099 = 1'b0;
    wire _1968 = 1'b0;
    reg _2100;
    wire _2094 = 1'b0;
    wire _2095 = 1'b0;
    wire _1969 = 1'b0;
    reg _2096;
    wire _2090 = 1'b0;
    wire _2091 = 1'b0;
    wire _1970 = 1'b0;
    reg _2092;
    wire _2086 = 1'b0;
    wire _2087 = 1'b0;
    wire _1971 = 1'b0;
    reg _2088;
    wire _2082 = 1'b0;
    wire _2083 = 1'b0;
    wire _1972 = 1'b0;
    reg _2084;
    wire _2078 = 1'b0;
    wire _2079 = 1'b0;
    wire _1973 = 1'b0;
    reg _2080;
    wire _2074 = 1'b0;
    wire _2075 = 1'b0;
    wire _1974 = 1'b0;
    reg _2076;
    wire _2070 = 1'b0;
    wire _2071 = 1'b0;
    wire _1975 = 1'b0;
    reg _2072;
    wire _2066 = 1'b0;
    wire _2067 = 1'b0;
    wire _1976 = 1'b0;
    reg _2068;
    wire _2062 = 1'b0;
    wire _2063 = 1'b0;
    wire _1977 = 1'b0;
    reg _2064;
    wire _2058 = 1'b0;
    wire _2059 = 1'b0;
    wire _1978 = 1'b0;
    reg _2060;
    wire [47:0] _2054 = 48'b000000000000000000000000000000000000000000000000;
    wire [47:0] _2055 = 48'b000000000000000000000000000000000000000000000000;
    wire [47:0] _1979 = 48'b000000000000000000000000000000000000000000000000;
    reg [47:0] _2056;
    wire [31:0] _2050 = 32'b00000000000000000000000000000000;
    wire [31:0] _2051 = 32'b00000000000000000000000000000000;
    wire [31:0] _1980 = 32'b00000000000000000000000000000000;
    reg [31:0] _2052;
    wire [31:0] _2046 = 32'b00000000000000000000000000000000;
    wire [31:0] _2047 = 32'b00000000000000000000000000000000;
    wire [31:0] _1807 = 32'b00000000000000000000000000010000;
    wire [31:0] _1809 = 32'b00000000000000000000000000000000;
    wire [31:0] _876 = 32'b00000000000000000000000000000000;
    wire [31:0] _877 = 32'b00000000000000000000000000000000;
    reg [31:0] _878;
    wire [31:0] _1811 = 32'b00000000000000000000000000000100;
    wire [31:0] _1812;
    wire _800 = 1'b0;
    wire _801 = 1'b0;
    reg _802;
    wire [31:0] _1813;
    wire [31:0] _1808;
    reg [31:0] _1810;
    reg [31:0] _2048;
    wire [31:0] _2042 = 32'b00000000000000000000000000000000;
    wire [31:0] _2043 = 32'b00000000000000000000000000000000;
    wire [31:0] _1982 = 32'b00000000000000000000000000000000;
    reg [31:0] _2044;
    wire [31:0] _2038 = 32'b00000000000000000000000000000000;
    wire [31:0] _2039 = 32'b00000000000000000000000000000000;
    wire [31:0] _1983 = 32'b00000000000000000000000000000000;
    reg [31:0] _2040;
    wire [31:0] _2034 = 32'b00000000000000000000000000000000;
    wire [31:0] _2035 = 32'b00000000000000000000000000000000;
    wire [31:0] _1984 = 32'b00000000000000000000000000000