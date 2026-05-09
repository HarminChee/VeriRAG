`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module step_curve
(
  input clk,
  output reg CAL,
  output CS,
  output IS1,
  output IS2,
  output reg LE,
  output reg R12,
  output reg RBI,
  output reg RESET,
  output reg RPHI1,
  output reg RPHI2,
  output reg SBI,
  output reg SEB,
  output reg SPHI1,
  output reg SPHI2,
  output SR,
  input reset_gen
);
reg [31:0]counter;
reg [7:0]stage;
reg [15:0]stage_iter;
reg ISSR;
assign IS1=ISSR;
assign IS2=ISSR;
assign SR=ISSR;
assign CS=1;
always @(posedge clk ) begin
  if(reset_gen == 1) begin
    counter <= 0;
    stage <= 0;
    stage_iter <= 0;
  end
  else begin
    if(stage == 0) begin
      if(counter == 0) begin
        CAL <= 1;
        SBI <= 1;
        SPHI1 <= 1;
        SPHI2 <= 1;
        SEB <= 0;
        ISSR <= 0;
        RESET <= 1;
        R12 <= 0;
        RBI <= 1;
        RPHI1 <= 1;
        RPHI2 <= 1;
        LE <= 1;
      end
      if(counter == 10) begin
        SBI <= 0;
        SEB <= 1;
        ISSR <= 1;
        R12 <= 1;
      end
      if(counter == 12) begin
        SPHI1 <= 0;
        SPHI2 <= 0;
      end
      if(counter == 18) begin
        SEB <= 0;
      end
      if(counter == 26) begin
        RESET <= 0;
      end
      if(counter == 34) begin
        SBI <= 1;
        SPHI1 <= 1;
      end
      if(counter == 35) begin
        SPHI1 <= 0;
      end
      if(counter == 36) begin
        SBI <= 0;
        SPHI2 <= 1;
      end
      if(counter == 37) begin
        SPHI2 <= 0;
      end
      if(counter == 38) begin
        SPHI1 <= 1;
      end
      if(counter == 39) begin
        SPHI1 <= 0;
      end
      if(counter == 40) begin
        SPHI2 <= 1;
      end
      if(counter == 41) begin
        SPHI2 <= 0;
      end
      if(counter == 42) begin
        SPHI1 <= 1;
      end
      if(counter == 43) begin
        SPHI1 <= 0;
      end
      if(counter == 44) begin
        SPHI2 <= 1;
      end
      if(counter == 45) begin
        SPHI2 <= 0;
      end
      if(counter == 46) begin
        SPHI1 <= 1;
      end
      if(counter == 47) begin
        SPHI1 <= 0;
      end
      if(counter == 48) begin
        SPHI2 <= 1;
      end
      if(counter == 49) begin
        SPHI2 <= 0;
      end
      if(counter == 50) begin
        SPHI1 <= 1;
      end
      if(counter == 51) begin
        SPHI1 <= 0;
      end
      if(counter == 52) begin
        SPHI2 <= 1;
      end
      if(counter == 53) begin
        SPHI2 <= 0;
      end
      if(counter == 54) begin
        SPHI1 <= 1;
      end
      if(counter == 55) begin
        SPHI1 <= 0;
      end
      if(counter == 56) begin
        SPHI2 <= 1;
      end
      if(counter == 57) begin
        SPHI2 <= 0;
      end
      if(counter == 58) begin
        SPHI1 <= 1;
      end
      if(counter == 59) begin
        SPHI1 <= 0;
      end
      if(counter == 60) begin
        SPHI2 <= 1;
      end
      if(counter == 61) begin
        SPHI2 <= 0;
      end
      if(counter == 62) begin
        SPHI1 <= 1;
      end
      if(counter == 63) begin
        SPHI1 <= 0;
      end
      if(counter == 64) begin
        SPHI2 <= 1;
      end
      if(counter == 65) begin
        SPHI2 <= 0;
      end
      if(counter == 66) begin
        SPHI1 <= 1;
      end
      if(counter == 67) begin
        SPHI1 <= 0;
      end
      if(counter == 68) begin
        SPHI2 <= 1;
      end
      if(counter == 69) begin
        SPHI2 <= 0;
      end
      if(counter == 70) begin
        SPHI1 <= 1;
      end
      if(counter == 71) begin
        SPHI1 <= 0;
      end
      if(counter == 72) begin
        SPHI2 <= 1;
      end
      if(counter == 73) begin
        SPHI2 <= 0;
      end
      if(counter == 74) begin
        SPHI1 <= 1;
      end
      if(counter == 75) begin
        SPHI1 <= 0;
      end
      if(counter == 76) begin
        SPHI2 <= 1;
      end
      if(counter == 77) begin
        SPHI2 <= 0;
      end
      if(counter == 78) begin
        SPHI1 <= 1;
      end
      if(counter == 79) begin
        SPHI1 <= 0;
      end
      if(counter == 80) begin
        SPHI2 <= 1;
      end
      if(counter == 81) begin
        SPHI2 <= 0;
      end
      if(counter == 82) begin
        SPHI1 <= 1;
      end
      if(counter == 83) begin
        SPHI1 <= 0;
      end
      if(counter == 84) begin
        SPHI2 <= 1;
      end
      if(counter == 85) begin
        SPHI2 <= 0;
      end
      if(counter == 86) begin
        SPHI1 <= 1;
      end
      if(counter == 87) begin
        SPHI1 <= 0;
      end
      if(counter == 88) begin
        SPHI2 <= 1;
      end
      if(counter == 89) begin
        SPHI2 <= 0;
      end
      if(counter == 90) begin
        SPHI1 <= 1;
      end
      if(counter == 91) begin
        SPHI1 <= 0;
      end
      if(counter == 92) begin
        SPHI2 <= 1;
      end
      if(counter == 93) begin
        SPHI2 <= 0;
      end
      if(counter == 94) begin
        SPHI1 <= 1;
      end
      if(counter == 95) begin
        SPHI1 <= 0;
      end
      if(counter == 96) begin
        SPHI2 <= 1;
      end
      if(counter == 97) begin
        SPHI2 <= 0;
      end
      if(counter == 98) begin
        SPHI1 <= 1;
      end
      if(counter == 99) begin
        SPHI1 <= 0;
      end
      if(counter == 100) begin
        SPHI2 <= 1;
      end
      if(counter == 101) begin
        SPHI2 <= 0;
      end
      if(counter == 102) begin
        SPHI1 <= 1;
      end
      if(counter == 103) begin
        SPHI1 <= 0;
      end
      if(counter == 104) begin
        SPHI2 <= 1;
      end
      if(counter == 105) begin
        SPHI2 <= 0;
      end
      if(counter == 106) begin
        SPHI1 <= 1;
      end
      if(counter == 107) begin
        SPHI1 <= 0;
      end
      if(counter == 108) begin
        SPHI2 <= 1;
      end
      if(counter == 109) begin
        SPHI2 <= 0;
      end
      if(counter == 110) begin
        SPHI1 <= 1;
      end
      if(counter == 111) begin
        SPHI1 <= 0;
      end
      if(counter == 112) begin
        SPHI2 <= 1;
      end
      if(counter == 113) begin
        SPHI2 <= 0;
      end
      if(counter == 114) begin
        SPHI1 <= 1;
      end
      if(counter == 115) begin
        SPHI1 <= 0;
      end
      if(counter == 116) begin
        SPHI2 <= 1;
      end
      if(counter == 117) begin
        SPHI2 <= 0;
      end
      if(counter == 118) begin
        SPHI1 <= 1;
      end
      if(counter == 119) begin
        SPHI1 <= 0;
      end
      if(counter == 120) begin
        SPHI2 <= 1;
      end
      if(counter == 121) begin
        SPHI2 <= 0;
      end
      if(counter == 122) begin
        SPHI1 <= 1;
      end
      if(counter == 123) begin
        SPHI1 <= 0;
      end
      if(counter == 124) begin
        SPHI2 <= 1;
      end
      if(counter == 125) begin
        SPHI2 <= 0;
      end
      if(counter == 126) begin
        SPHI1 <= 1;
      end
      if(counter == 127) begin
        SPHI1 <= 0;
      end
      if(counter == 128) begin
        SPHI2 <= 1;
      end
      if(counter == 129) begin
        SPHI2 <= 0;
      end
      if(counter == 130) begin
        SPHI1 <= 1;
      end
      if(counter == 131) begin
        SPHI1 <= 0;
      end
      if(counter == 132) begin
        SPHI2 <= 1;
      end
      if(counter == 133) begin
        SPHI2 <= 0;
      end
      if(counter == 134) begin
        SPHI1 <= 1;
      end
      if(counter == 135) begin
        SPHI1 <= 0;
      end
      if(counter == 136) begin
        SPHI2 <= 1;
      end
      if(counter == 137) begin
        SPHI2 <= 0;
      end
      if(counter == 138) begin
        SPHI1 <= 1;
      end
      if(counter == 139) begin
        SPHI1 <= 0;
      end
      if(counter == 140) begin
        SPHI2 <= 1;
      end
      if(counter == 141) begin
        SPHI2 <= 0;
      end
      if(counter == 142) begin
        SPHI1 <= 1;
      end
      if(counter == 143) begin
        SPHI1 <= 0;
      end
      if(counter == 144) begin
        SPHI2 <= 1;
      end
      if(counter == 145) begin
        SPHI2 <= 0;
      end
      if(counter == 146) begin
        SPHI1 <= 1;
      end
      if(counter == 147) begin
        SPHI1 <= 0;
      end
      if(counter == 148) begin
        SPHI2 <= 1;
      end
      if(counter == 149) begin
        SPHI2 <= 0;
      end
      if(counter == 150) begin
        SPHI1 <= 1;
      end
      if(counter == 151) begin
        SPHI1 <= 0;
      end
      if(counter == 152) begin
        SPHI2 <= 1;
      end
      if(counter == 153) begin
        SPHI2 <= 0;
      end
      if(counter == 154) begin
        SPHI1 <= 1;
      end
      if(counter == 155) begin
        SPHI1 <= 0;
      end
      if(counter == 156) begin
        SPHI2 <= 1;
      end
      if(counter == 157) begin
        SPHI2 <= 0;
      end
      if(counter == 158) begin
        SPHI1 <= 1;
      end
      if(counter == 159) begin
        SPHI1 <= 0;
      end
      if(counter == 160) begin
        SPHI2 <= 1;
      end
      if(counter == 161) begin
        SPHI2 <= 0;
      end
      if(counter == 162) begin
        SBI <= 1;
        SPHI1 <= 1;
      end
      if(counter == 163) begin
        SPHI1 <= 0;
      end
      if(counter == 164) begin
        SBI <= 0;
        SPHI2 <= 1;
      end
      if(counter == 165) begin
        SPHI2 <= 0;
      end
      if(counter == 166) begin
        SPHI1 <= 1;
      end
      if(counter == 167) begin
        SPHI1 <= 0;
      end
      if(counter == 168) begin
        SPHI2 <= 1;
      end
      if(counter == 169) begin
        SPHI2 <= 0;
      end
      if(counter == 170) begin
        SPHI1 <= 1;
      end
      if(counter == 171) begin
        SPHI1 <= 0;
      end
      if(counter == 172) begin
        SPHI2 <= 1;
      end
      if(counter == 173) begin
        SPHI2 <= 0;
      end
      if(counter == 174) begin
        SPHI1 <= 1;
      end
      if(counter == 175) begin
        SPHI1 <= 0;
      end
      if(counter == 176) begin
        SPHI2 <= 1;
      end
      if(counter == 177) begin
        SPHI2 <= 0;
      end
      if(counter == 178) begin
        SPHI1 <= 1;
      end
      if(counter == 179) begin
        SPHI1 <= 0;
      end
      if(counter == 180) begin
        SPHI2 <= 1;
      end
      if(counter == 181) begin
        SPHI2 <= 0;
      end
      if(counter == 182) begin
        SPHI1 <= 1;
      end
      if(counter == 183) begin
        SPHI1 <= 0;
      end
      if(counter == 184) begin
        SPHI2 <= 1;
      end
      if(counter == 185) begin
        SPHI2 <= 0;
      end
      if(counter == 186) begin
        SPHI1 <= 1;
      end
      if(counter == 187) begin
        SPHI1 <= 0;
      end
      if(counter == 188) begin
        SPHI2 <= 1;
      end
      if(counter == 189) begin
        SPHI2 <= 0;
      end
      if(counter == 190) begin
        SPHI1 <= 1;
      end
      if(counter == 191) begin
        SPHI1 <= 0;
      end
      if(counter == 192) begin
        SPHI2 <= 1;
      end
      if(counter == 193) begin
        SPHI2 <= 0;
      end
      if(counter == 194) begin
        SPHI1 <= 1;
      end
      if(counter == 195) begin
        SPHI1 <= 0;
      end
      if(counter == 196) begin
        SPHI2 <= 1;
      end
      if(counter == 197) begin
        SPHI2 <= 0;
      end
      if(counter == 198) begin
        SPHI1 <= 1;
      end
      if(counter == 199) begin
        SPHI1 <= 0;
      end
      if(counter == 200) begin
        SPHI2 <= 1;
      end
      if(counter == 201) begin
        SPHI2 <= 0;
      end
      if(counter == 202) begin
        SPHI1 <= 1;
      end
      if(counter == 203) begin
        SPHI1 <= 0;
      end
      if(counter == 204) begin
        SPHI2 <= 1;
      end
      if(counter == 205) begin
        SPHI2 <= 0;
      end
      if(counter == 206) begin
        SPHI1 <= 1;
      end
      if(counter == 207) begin
        SPHI1 <= 0;
      end
      if(counter == 208) begin
        SPHI2 <= 1;
      end
      if(counter == 209) begin
        SPHI2 <= 0;
      end
      if(counter == 210) begin
        SPHI1 <= 1;
      end
      if(counter == 211) begin
        SPHI1 <= 0;
      end
      if(counter == 212) begin
        SPHI2 <= 1;
      end
      if(counter == 213) begin
        SPHI2 <= 0;
      end
      if(counter == 214) begin
        SPHI1 <= 1;
      end
      if(counter == 215) begin
        SPHI1 <= 0;
      end
      if(counter == 216) begin
        SPHI2 <= 1;
      end
      if(counter == 217) begin
        SPHI2 <= 0;
      end
      if(counter == 218) begin
        SPHI1 <= 1;
      end
      if(counter == 219) begin
        SPHI1 <= 0;
      end
      if(counter == 220) begin
        SPHI2 <= 1;
      end
      if(counter == 221) begin
        SPHI2 <= 0;
      end
      if(counter == 222) begin
        SPHI1 <= 1;
      end
      if(counter == 223) begin
        SPHI1 <= 0;
      end
      if(counter == 224) begin
        SPHI2 <= 1;
      end
      if(counter == 225) begin
        SPHI2 <= 0;
      end
      if(counter == 226) begin
        SPHI1 <= 1;
      end
      if(counter == 227) begin
        SPHI1 <= 0;
      end
      if(counter == 228) begin
        SPHI2 <= 1;
      end
      if(counter == 229) begin
        SPHI2 <= 0;
      end
      if(counter == 230) begin
        SPHI1 <= 1;
      end
      if(counter == 231) begin
        SPHI1 <= 0;
      end
      if(counter == 232) begin
        SPHI2 <= 1;
      end
      if(counter == 233) begin
        SPHI2 <= 0;
      end
      if(counter == 234) begin
        SPHI1 <= 1;
      end
      if(counter == 235) begin
        SPHI1 <= 0;
      end
      if(counter == 236) begin
        SPHI2 <= 1;
      end
      if(counter == 237) begin
        SPHI2 <= 0;
      end
      if(counter == 238) begin
        SPHI1 <= 1;
      end
      if(counter == 239) begin
        SPHI1 <= 0;
      end
      if(counter == 240) begin
        SPHI2 <= 1;
      end
      if(counter == 241) begin
        SPHI2 <= 0;
      end
      if(counter == 242) begin
        SPHI1 <= 1;
      end
      if(counter == 243) begin
        SPHI1 <= 0;
      end
      if(counter == 244) begin
        SPHI2 <= 1;
      end
      if(counter == 245) begin
        SPHI2 <= 0;
      end
      if(counter == 246) begin
        SPHI1 <= 1;
      end
      if(counter == 247) begin
        SPHI1 <= 0;
      end
      if(counter == 248) begin
        SPHI2 <= 1;
      end
      if(counter == 249) begin
        SPHI2 <= 0;
      end
      if(counter == 250) begin
        SPHI1 <= 1;
      end
      if(counter == 251) begin
        SPHI1 <= 0;
      end
      if(counter == 252) begin
        SPHI2 <= 1;
      end
      if(counter == 253) begin
        SPHI2 <= 0;
      end
      if(counter == 254) begin
        SPHI1 <= 1;
      end
      if(counter == 255) begin
        SPHI1 <= 0;
      end
      if(counter == 256) begin
        SPHI2 <= 1;
      end
      if(counter == 257) begin
        SPHI2 <= 0;
      end
      if(counter == 258) begin
        SPHI1 <= 1;
      end
      if(counter == 259) begin
        SPHI1 <= 0;
      end
      if(counter == 260) begin
        SPHI2 <= 1;
      end
      if(counter == 261) begin
        SPHI2 <= 0;
      end
      if(counter == 262) begin
        SPHI1 <= 1;
      end
      if(counter == 263) begin
        SPHI1 <= 0;
      end
      if(counter == 264) begin
        SPHI2 <= 1;
      end
      if(counter == 265) begin
        SPHI2 <= 0;
      end
      if(counter == 266) begin
        SPHI1 <= 1;
      end
      if(counter == 267) begin
        SPHI1 <= 0;
      end
      if(counter == 268) begin
        SPHI2 <= 1;
      end
      if(counter == 269) begin
        SPHI2 <= 0;
      end
      if(counter == 270) begin
        SPHI1 <= 1;
      end
      if(counter == 271) begin
        SPHI1 <= 0;
      end
      if(counter == 272) begin
        SPHI2 <= 1;
      end
      if(counter == 273) begin
        SPHI2 <= 0;
      end
      if(counter == 274) begin
        SPHI1 <= 1;
      end
      if(counter == 275) begin
        SPHI1 <= 0;
      end
      if(counter == 276) begin
        SPHI2 <= 1;
      end
      if(counter == 277) begin
        SPHI2 <= 0;
      end
      if(counter == 278) begin
        SPHI1 <= 1;
      end
      if(counter == 279) begin
        SPHI1 <= 0;
      end
      if(counter == 280) begin
        SPHI2 <= 1;
      end
      if(counter == 281) begin
        SPHI2 <= 0;
      end
      if(counter == 282) begin
        SPHI1 <= 1;
      end
      if(counter == 283) begin
        SPHI1 <= 0;
      end
      if(counter == 284) begin
        SPHI2 <= 1;
      end
      if(counter == 285) begin
        SPHI2 <= 0;
      end
      if(counter == 286) begin
        SPHI1 <= 1;
      end
      if(counter == 287) begin
        SPHI1 <= 0;
      end
      if(counter == 288) begin
        SPHI2 <= 1;
      end
      if(counter == 289) begin
        SPHI2 <= 0;
      end
      if(counter == 290) begin
        SBI <= 1;
        SPHI1 <= 1;
      end
      if(counter == 291) begin
        SPHI1 <= 0;
      end
      if(counter == 292) begin
        SBI <= 0;
        SPHI2 <= 1;
      end
      if(counter == 293) begin
        SPHI2 <= 0;
      end
      if(counter == 294) begin
        SPHI1 <= 1;
      end
      if(counter == 295) begin
        SPHI1 <= 0;
      end
      if(counter == 296) begin
        SPHI2 <= 1;
      end
      if(counter == 297) begin
        SPHI2 <= 0;
      end
      if(counter == 298) begin
        SPHI1 <= 1;
      end
      if(counter == 299) begin
        SPHI1 <= 0;
      end
      if(counter == 300) begin
        SPHI2 <= 1;
      end
      if(counter == 301) begin
        SPHI2 <= 0;
      end
      if(counter == 302) begin
        SPHI1 <= 1;
      end
      if(counter == 303) begin
        SPHI1 <= 0;
      end
      if(counter == 304) begin
        SPHI2 <= 1;
      end
      if(counter == 305) begin
        SPHI2 <= 0;
      end
      if(counter == 306) begin
        SPHI1 <= 1;
      end
      if(counter == 307) begin
        SPHI1 <= 0;
      end
      if(counter == 308) begin
        SPHI2 <= 1;
      end
      if(counter == 309) begin
        SPHI2 <= 0;
      end
      if(counter == 310) begin
        SPHI1 <= 1;
      end
      if(counter == 311) begin
        SPHI1 <= 0;
      end
      if(counter == 312) begin
        SPHI2 <= 1;
      end
      if(counter == 313) begin
        SPHI2 <= 0;
      end
      if(counter == 314) begin
        SPHI1 <= 1;
      end
      if(counter == 315) begin
        SPHI1 <= 0;
      end
      if(counter == 316) begin
        SPHI2 <= 1;
      end
      if(counter == 317) begin
        SPHI2 <= 0;
      end
      if(counter == 318) begin
        SPHI1 <= 1;
      end
      if(counter == 319) begin
        SPHI1 <= 0;
      end
      if(counter == 320) begin
        SPHI2 <= 1;
      end
      if(counter == 321) begin
        CAL <= 0;
        SPHI2 <= 0;
      end
      if(counter == 322) begin
        SPHI1 <= 1;
      end
      if(counter == 323) begin
        SPHI1 <= 0;
      end
      if(counter == 324) begin
        SPHI2 <= 1;
      end
      if(counter == 325) begin
        SPHI2 <= 0;
      end
      if(counter == 326) begin
        SPHI1 <= 1;
      end
      if(counter == 327) begin
        SPHI1 <= 0;
      end
      if(counter == 328) begin
        SPHI2 <= 1;
      end
      if(counter == 329) begin
        SPHI2 <= 0;
      end
      if(counter == 330) begin
        SPHI1 <= 1;
      end
      if(counter == 331) begin
        SPHI1 <= 0;
      end
      if(counter == 332) begin
        SPHI2 <= 1;
      end
      if(counter == 333) begin
        SPHI2 <= 0;
      end
      if(counter == 334) begin
        SPHI1 <= 1;
      end
      if(counter == 335) begin
        SPHI1 <= 0;
      end
      if(counter == 336) begin
        SPHI2 <= 1;
      end
      if(counter == 337) begin
        SPHI2 <= 0;
      end
      if(counter == 338) begin
        SPHI1 <= 1;
      end
      if(counter == 339) begin
        SPHI1 <= 0;
      end
      if(counter == 340) begin
        SPHI2 <= 1;
      end
      if(counter == 341) begin
        SPHI2 <= 0;
      end
      if(counter == 342) begin
        SPHI1 <= 1;
      end
      if(counter == 343) begin
        SPHI1 <= 0;
      end
      if(counter == 344) begin
        SPHI2 <= 1;
      end
      if(counter == 345) begin
        SPHI2 <= 0;
      end
      if(counter == 346) begin
        SPHI1 <= 1;
      end
      if(counter == 347) begin
        SPHI1 <= 0;
      end
      if(counter == 348) begin
        SPHI2 <= 1;
      end
      if(counter == 349) begin
        SPHI2 <= 0;
      end
      if(counter == 350) begin
        SPHI1 <= 1;
      end
      if(counter == 351) begin
        SPHI1 <= 0;
      end
      if(counter == 352) begin
        SPHI2 <= 1;
      end
      if(counter == 353) begin
        SPHI2 <= 0;
      end
      if(counter == 354) begin
        SPHI1 <= 1;
      end
      if(counter == 355) begin
        SPHI1 <= 0;
      end
      if(counter == 356) begin
        SPHI2 <= 1;
      end
      if(counter == 357) begin
        SPHI2 <= 0;
      end
      if(counter == 358) begin
        SPHI1 <= 1;
      end
      if(counter == 359) begin
        SPHI1 <= 0;
      end
      if(counter == 360) begin
        SPHI2 <= 1;
      end
      if(counter == 361) begin
        SPHI2 <= 0;
      end
      if(counter == 362) begin
        SPHI1 <= 1;
      end
      if(counter == 363) begin
        SPHI1 <= 0;
      end
      if(counter == 364) begin
        SPHI2 <= 1;
      end
      if(counter == 365) begin
        SPHI2 <= 0;
      end
      if(counter == 366) begin
        SPHI1 <= 1;
      end
      if(counter == 367) begin
        SPHI1 <= 0;
      end
      if(counter == 368) begin
        SPHI2 <= 1;
      end
      if(counter == 369) begin
        SPHI2 <= 0;
      end
      if(counter == 370) begin
        SPHI1 <= 1;
      end
      if(counter == 371) begin
        SPHI1 <= 0;
      end
      if(counter == 372) begin
        SPHI2 <= 1;
      end
      if(counter == 373) begin
        SPHI2 <= 0;
      end
      if(counter == 374) begin
        SPHI1 <= 1;
      end
      if(counter == 375) begin
        SPHI1 <= 0;
      end
      if(counter == 376) begin
        SPHI2 <= 1;
      end
      if(counter == 377) begin
        SPHI2 <= 0;
      end
      if(counter == 378) begin
        SPHI1 <= 1;
      end
      if(counter == 379) begin
        SPHI1 <= 0;
      end
      if(counter == 380) begin
        SPHI2 <= 1;
      end
      if(counter == 381) begin
        SPHI2 <= 0;
      end
      if(counter == 382) begin
        SPHI1 <= 1;
      end
      if(counter == 383) begin
        SPHI1 <= 0;
      end
      if(counter == 384) begin
        SPHI2 <= 1;
      end
      if(counter == 385) begin
        SPHI2 <= 0;
      end
      if(counter == 386) begin
        SPHI1 <= 1;
      end
      if(counter == 387) begin
        SPHI1 <= 0;
      end
      if(counter == 388) begin
        SPHI2 <= 1;
      end
      if(counter == 389) begin
        SPHI2 <= 0;
      end
      if(counter == 390) begin
        SPHI1 <= 1;
      end
      if(counter == 391) begin
        SPHI1 <= 0;
      end
      if(counter == 392) begin
        SPHI2 <= 1;
      end
      if(counter == 393) begin
        SPHI2 <= 0;
      end
      if(counter == 394) begin
        SPHI1 <= 1;
      end
      if(counter == 395) begin
        SPHI1 <= 0;
      end
      if(counter == 396) begin
        SPHI2 <= 1;
      end
      if(counter == 397) begin
        SPHI2 <= 0;
      end
      if(counter == 398) begin
        SPHI1 <= 1;
      end
      if(counter == 399) begin
        SPHI1 <= 0;
      end
      if(counter == 400) begin
        SPHI2 <= 1;
      end
      if(counter == 401) begin
        SPHI2 <= 0;
      end
      if(counter == 402) begin
        SPHI1 <= 1;
      end
      if(counter == 403) begin
        SPHI1 <= 0;
      end
      if(counter == 404) begin
        SPHI2 <= 1;
      end
      if(counter == 405) begin
        SPHI2 <= 0;
      end
      if(counter == 406) begin
        SPHI1 <= 1;
      end
      if(counter == 407) begin
        SPHI1 <= 0;
      end
      if(counter == 408) begin
        SPHI2 <= 1;
      end
      if(counter == 409) begin
        SPHI2 <= 0;
      end
      if(counter == 410) begin
        SPHI1 <= 1;
      end
      if(counter == 411) begin
        SPHI1 <= 0;
      end
      if(counter == 412) begin
        SPHI2 <= 1;
      end
      if(counter == 413) begin
        SPHI2 <= 0;
      end
      if(counter == 414) begin
        SPHI1 <= 1;
      end
      if(counter == 415) begin
        SPHI1 <= 0;
      end
      if(counter == 416) begin
        SPHI2 <= 1;
      end
      if(counter == 417) begin
        SPHI2 <= 0;
      end
      if(counter == 418) begin
        RESET <= 1;
      end
      if(counter == 421) begin
        SEB <= 1;
        ISSR <= 0;
        R12 <= 0;
      end
      if(counter == 428) begin
        SPHI1 <= 1;
        SPHI2 <= 1;
      end
      if(counter == 432) begin
        SPHI1 <= 0;
        SPHI2 <= 0;
      end
      if(counter == 445) begin
        SBI <= 1;
        SPHI1 <= 1;
      end
      if(counter == 446) begin
        SPHI1 <= 0;
      end
      if(counter == 447) begin
        SPHI2 <= 1;
      end
      if(counter == 448) begin
        SBI <= 0;
        SPHI2 <= 0;
      end
      if(counter == 449) begin
        SPHI1 <= 1;
      end
      if(counter == 450) begin
        SPHI1 <= 0;
      end
      if(counter == 451) begin
        SPHI2 <= 1;
      end
      if(counter == 452) begin
        SPHI2 <= 0;
      end
      if(counter == 453) begin
        SPHI1 <= 1;
      end
      if(counter == 454) begin
        SPHI1 <= 0;
      end
      if(counter == 455) begin
        SPHI2 <= 1;
      end
      if(counter == 456) begin
        SPHI2 <= 0;
      end
      if(counter == 457) begin
        SPHI1 <= 1;
      end
      if(counter == 458) begin
        SPHI1 <= 0;
      end
      if(counter == 459) begin
        SPHI2 <= 1;
      end
      if(counter == 460) begin
        SPHI2 <= 0;
      end
      if(counter == 461) begin
        SPHI1 <= 1;
      end
      if(counter == 462) begin
        SPHI1 <= 0;
      end
      if(counter == 463) begin
        SPHI2 <= 1;
      end
      if(counter == 464) begin
        SPHI2 <= 0;
      end
      if(counter == 465) begin
        SPHI1 <= 1;
      end
      if(counter == 466) begin
        SPHI1 <= 0;
      end
      if(counter == 467) begin
        SPHI2 <= 1;
      end
      if(counter == 468) begin
        SPHI2 <= 0;
      end
      if(counter == 469) begin
        SPHI1 <= 1;
      end
      if(counter == 470) begin
        SPHI1 <= 0;
      end
      if(counter == 471) begin
        SPHI2 <= 1;
      end
      if(counter == 472) begin
        SPHI2 <= 0;
      end
      if(counter == 473) begin
        SPHI1 <= 1;
      end
      if(counter == 474) begin
        SPHI1 <= 0;
      end
      if(counter == 475) begin
        SPHI2 <= 1;
      end
      if(counter == 476) begin
        SPHI2 <= 0;
      end
      if(counter == 477) begin
        LE <= 0;
      end
      if(counter == 483) begin
        RESET <= 0;
      end
      if(counter == 500) begin
        SEB <= 0;
      end
      if(counter == 504) begin
        SEB <= 1;
      end
      if(counter == 532) begin
        RBI <= 0;
      end
      if(counter == 933) begin
        RPHI1 <= 0;
        RPHI2 <= 0;
      end
      if(counter == 937) begin
        LE <= 1;
      end
      if(counter == 958) begin
        RBI <= 1;
        RPHI1 <= 1;
      end
      if(counter == 963) begin
        RPHI1 <= 0;
      end
      if(counter == 964) begin
        RBI <= 0;
      end
      if(counter == 965) begin
        if(stage_iter == 0) begin
          stage <= (stage + 1) % 2;
          stage_iter <= 0;
        end
        else begin
          stage_iter <= stage_iter + 1;
        end
        counter <= 0;
      end
      else begin
        counter <= counter + 1;
      end
    end
    if(stage == 1) begin
      if(counter == 0) begin
        CAL <= 0;
        SBI <= 0;
        SPHI1 <= 0;
        SPHI2 <= 0;
        SEB <= 1;
        ISSR <= 0;
        RESET <= 0;
        R12 <= 0;
        RBI <= 0;
        RPHI1 <= 0;
        RPHI2 <= 1;
        LE <= 1;
      end
      if(counter == 26) begin
        RPHI2 <= 0;
      end
      if(counter == 27) begin
        RPHI1 <= 1;
      end
      if(counter == 30) begin
        RPHI1 <= 0;
      end
      if(counter == 30) begin
        if(stage_iter == 128) begin
          stage <= (stage + 1) % 2;
          stage_iter <= 0;
        end
        else begin
          stage_iter <= stage_iter + 1;
        end
        counter <= 0;
      end
      else begin
        counter <= counter + 1;
      end
    end
  end
end
endmodule
