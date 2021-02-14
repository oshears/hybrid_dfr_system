`timescale 1ns / 1ps
module mackey_glass_block
(
    input [32 - 1 : 0] din,
    output reg [32 - 1 : 0] dout
);

always @(din) 
begin
    if (din <= 32'h0000_0000) dout <= 32'h0000_0008;
    else if (din <= 32'h016C_16C1) dout <= 32'h0000_0014;
    else if (din <= 32'h02D8_2D83) dout <= 32'h0000_0046;
    else if (din <= 32'h0444_4444) dout <= 32'h0000_0073;
    else if (din <= 32'h05B0_5B06) dout <= 32'h0000_0093;
    else if (din <= 32'h071C_71C7) dout <= 32'h0000_00C1;
    else if (din <= 32'h0888_8889) dout <= 32'h0000_00EE;
    else if (din <= 32'h09F4_9F4A) dout <= 32'h0000_010E;
    else if (din <= 32'h0B60_B60B) dout <= 32'h0000_013B;
    else if (din <= 32'h0CCC_CCCD) dout <= 32'h0000_016D;
    else if (din <= 32'h0E38_E38E) dout <= 32'h0000_0189;
    else if (din <= 32'h0FA4_FA50) dout <= 32'h0000_01BA;
    else if (din <= 32'h1111_1111) dout <= 32'h0000_01DF;
    else if (din <= 32'h127D_27D2) dout <= 32'h0000_0208;
    else if (din <= 32'h13E9_3E94) dout <= 32'h0000_0235;
    else if (din <= 32'h1555_5555) dout <= 32'h0000_0256;
    else if (din <= 32'h16C1_6C17) dout <= 32'h0000_0283;
    else if (din <= 32'h182D_82D8) dout <= 32'h0000_02B0;
    else if (din <= 32'h1999_999A) dout <= 32'h0000_02D1;
    else if (din <= 32'h1B05_B05B) dout <= 32'h0000_02FE;
    else if (din <= 32'h1C71_C71C) dout <= 32'h0000_032F;
    else if (din <= 32'h1DDD_DDDE) dout <= 32'h0000_034C;
    else if (din <= 32'h1F49_F49F) dout <= 32'h0000_037D;
    else if (din <= 32'h20B6_0B61) dout <= 32'h0000_03AA;
    else if (din <= 32'h2222_2222) dout <= 32'h0000_03C7;
    else if (din <= 32'h238E_38E4) dout <= 32'h0000_03F8;
    else if (din <= 32'h24FA_4FA5) dout <= 32'h0000_0414;
    else if (din <= 32'h2666_6666) dout <= 32'h0000_0446;
    else if (din <= 32'h27D2_7D28) dout <= 32'h0000_0473;
    else if (din <= 32'h293E_93E9) dout <= 32'h0000_0493;
    else if (din <= 32'h2AAA_AAAB) dout <= 32'h0000_04C1;
    else if (din <= 32'h2C16_C16C) dout <= 32'h0000_04EE;
    else if (din <= 32'h2D82_D82E) dout <= 32'h0000_0537;
    else if (din <= 32'h2EEE_EEEF) dout <= 32'h0000_053B;
    else if (din <= 32'h305B_05B0) dout <= 32'h0000_0568;
    else if (din <= 32'h31C7_1C72) dout <= 32'h0000_0589;
    else if (din <= 32'h3333_3333) dout <= 32'h0000_05BA;
    else if (din <= 32'h349F_49F5) dout <= 32'h0000_05D7;
    else if (din <= 32'h360B_60B6) dout <= 32'h0000_0608;
    else if (din <= 32'h3777_7777) dout <= 32'h0000_0635;
    else if (din <= 32'h38E3_8E39) dout <= 32'h0000_0656;
    else if (din <= 32'h3A4F_A4FA) dout <= 32'h0000_0683;
    else if (din <= 32'h3BBB_BBBC) dout <= 32'h0000_06B0;
    else if (din <= 32'h3D27_D27D) dout <= 32'h0000_06D1;
    else if (din <= 32'h3E93_E93F) dout <= 32'h0000_06FE;
    else if (din <= 32'h4000_0000) dout <= 32'h0000_072B;
    else if (din <= 32'h416C_16C1) dout <= 32'h0000_074C;
    else if (din <= 32'h42D8_2D83) dout <= 32'h0000_0779;
    else if (din <= 32'h4444_4444) dout <= 32'h0000_079A;
    else if (din <= 32'h45B0_5B06) dout <= 32'h0000_07C7;
    else if (din <= 32'h471C_71C7) dout <= 32'h0000_07F4;
    else if (din <= 32'h4888_8889) dout <= 32'h0000_0814;
    else if (din <= 32'h49F4_9F4A) dout <= 32'h0000_0842;
    else if (din <= 32'h4B60_B60B) dout <= 32'h0000_086F;
    else if (din <= 32'h4CCC_CCCD) dout <= 32'h0000_088F;
    else if (din <= 32'h4E38_E38E) dout <= 32'h0000_08BC;
    else if (din <= 32'h4FA4_FA50) dout <= 32'h0000_08E9;
    else if (din <= 32'h5111_1111) dout <= 32'h0000_090A;
    else if (din <= 32'h527D_27D2) dout <= 32'h0000_0937;
    else if (din <= 32'h53E9_3E94) dout <= 32'h0000_0954;
    else if (din <= 32'h5555_5555) dout <= 32'h0000_0981;
    else if (din <= 32'h56C1_6C17) dout <= 32'h0000_09AE;
    else if (din <= 32'h582D_82D8) dout <= 32'h0000_09CB;
    else if (din <= 32'h5999_999A) dout <= 32'h0000_09F8;
    else if (din <= 32'h5B05_B05B) dout <= 32'h0000_0A21;
    else if (din <= 32'h5C71_C71C) dout <= 32'h0000_0A42;
    else if (din <= 32'h5DDD_DDDE) dout <= 32'h0000_0A6A;
    else if (din <= 32'h5F49_F49F) dout <= 32'h0000_0A93;
    else if (din <= 32'h60B6_0B61) dout <= 32'h0000_0AB0;
    else if (din <= 32'h6222_2222) dout <= 32'h0000_0AD9;
    else if (din <= 32'h638E_38E4) dout <= 32'h0000_0AF2;
    else if (din <= 32'h64FA_4FA5) dout <= 32'h0000_0B17;
    else if (din <= 32'h6666_6666) dout <= 32'h0000_0B3B;
    else if (din <= 32'h67D2_7D28) dout <= 32'h0000_0B54;
    else if (din <= 32'h693E_93E9) dout <= 32'h0000_0B75;
    else if (din <= 32'h6AAA_AAAB) dout <= 32'h0000_0B91;
    else if (din <= 32'h6C16_C16C) dout <= 32'h0000_0BA6;
    else if (din <= 32'h6D82_D82E) dout <= 32'h0000_0BBE;
    else if (din <= 32'h6EEE_EEEF) dout <= 32'h0000_0BD7;
    else if (din <= 32'h705B_05B0) dout <= 32'h0000_0BE3;
    else if (din <= 32'h71C7_1C72) dout <= 32'h0000_0BF0;
    else if (din <= 32'h7333_3333) dout <= 32'h0000_0BF8;
    else if (din <= 32'h749F_49F5) dout <= 32'h0000_0C00;
    else if (din <= 32'h760B_60B6) dout <= 32'h0000_0C00;
    else if (din <= 32'h7777_7777) dout <= 32'h0000_0C00;
    else if (din <= 32'h78E3_8E39) dout <= 32'h0000_0BF4;
    else if (din <= 32'h7A4F_A4FA) dout <= 32'h0000_0BE3;
    else if (din <= 32'h7BBB_BBBC) dout <= 32'h0000_0BD3;
    else if (din <= 32'h7D27_D27D) dout <= 32'h0000_0BBA;
    else if (din <= 32'h7E93_E93F) dout <= 32'h0000_0B96;
    else if (din <= 32'h8000_0000) dout <= 32'h0000_0B7D;
    else if (din <= 32'h816C_16C1) dout <= 32'h0000_0B4C;
    else if (din <= 32'h82D8_2D83) dout <= 32'h0000_0B2B;
    else if (din <= 32'h8444_4444) dout <= 32'h0000_0AEE;
    else if (din <= 32'h85B0_5B06) dout <= 32'h0000_0AAC;
    else if (din <= 32'h871C_71C7) dout <= 32'h0000_0A7B;
    else if (din <= 32'h8888_8889) dout <= 32'h0000_0A31;
    else if (din <= 32'h89F4_9F4A) dout <= 32'h0000_09DF;
    else if (din <= 32'h8B60_B60B) dout <= 32'h0000_09A2;
    else if (din <= 32'h8CCC_CCCD) dout <= 32'h0000_0948;
    else if (din <= 32'h8E38_E38E) dout <= 32'h0000_08E5;
    else if (din <= 32'h8FA4_FA50) dout <= 32'h0000_08A0;
    else if (din <= 32'h9111_1111) dout <= 32'h0000_0835;
    else if (din <= 32'h927D_27D2) dout <= 32'h0000_07C3;
    else if (din <= 32'h93E9_3E94) dout <= 32'h0000_0775;
    else if (din <= 32'h9555_5555) dout <= 32'h0000_06FE;
    else if (din <= 32'h96C1_6C17) dout <= 32'h0000_06A8;
    else if (din <= 32'h982D_82D8) dout <= 32'h0000_0629;
    else if (din <= 32'h9999_999A) dout <= 32'h0000_05A2;
    else if (din <= 32'h9B05_B05B) dout <= 32'h0000_0548;
    else if (din <= 32'h9C71_C71C) dout <= 32'h0000_04BC;
    else if (din <= 32'h9DDD_DDDE) dout <= 32'h0000_042D;
    else if (din <= 32'h9F49_F49F) dout <= 32'h0000_03CB;
    else if (din <= 32'hA0B6_0B61) dout <= 32'h0000_033F;
    else if (din <= 32'hA222_2222) dout <= 32'h0000_02BC;
    else if (din <= 32'hA38E_38E4) dout <= 32'h0000_0273;
    else if (din <= 32'hA4FA_4FA5) dout <= 32'h0000_021D;
    else if (din <= 32'hA666_6666) dout <= 32'h0000_01F0;
    else if (din <= 32'hA7D2_7D28) dout <= 32'h0000_01B6;
    else if (din <= 32'hA93E_93E9) dout <= 32'h0000_0191;
    else if (din <= 32'hAAAA_AAAB) dout <= 32'h0000_0175;
    else if (din <= 32'hAC16_C16C) dout <= 32'h0000_0158;
    else if (din <= 32'hAD82_D82E) dout <= 32'h0000_013F;
    else if (din <= 32'hAEEE_EEEF) dout <= 32'h0000_012B;
    else if (din <= 32'hB05B_05B0) dout <= 32'h0000_011F;
    else if (din <= 32'hB1C7_1C72) dout <= 32'h0000_010A;
    else if (din <= 32'hB333_3333) dout <= 32'h0000_0102;
    else if (din <= 32'hB49F_49F5) dout <= 32'h0000_00F6;
    else if (din <= 32'hB60B_60B6) dout <= 32'h0000_00EE;
    else if (din <= 32'hB777_7777) dout <= 32'h0000_00E1;
    else if (din <= 32'hB8E3_8E39) dout <= 32'h0000_00D9;
    else if (din <= 32'hBA4F_A4FA) dout <= 32'h0000_00CD;
    else if (din <= 32'hBBBB_BBBC) dout <= 32'h0000_00C9;
    else if (din <= 32'hBD27_D27D) dout <= 32'h0000_00C1;
    else if (din <= 32'hBE93_E93F) dout <= 32'h0000_00BC;
    else if (din <= 32'hC000_0000) dout <= 32'h0000_00B4;
    else if (din <= 32'hC16C_16C1) dout <= 32'h0000_00B0;
    else if (din <= 32'hC2D8_2D83) dout <= 32'h0000_00AC;
    else if (din <= 32'hC444_4444) dout <= 32'h0000_00A4;
    else if (din <= 32'hC5B0_5B06) dout <= 32'h0000_00A0;
    else if (din <= 32'hC71C_71C7) dout <= 32'h0000_009C;
    else if (din <= 32'hC888_8889) dout <= 32'h0000_0098;
    else if (din <= 32'hC9F4_9F4A) dout <= 32'h0000_0093;
    else if (din <= 32'hCB60_B60B) dout <= 32'h0000_0093;
    else if (din <= 32'hCCCC_CCCD) dout <= 32'h0000_008B;
    else if (din <= 32'hCE38_E38E) dout <= 32'h0000_008B;
    else if (din <= 32'hCFA4_FA50) dout <= 32'h0000_0087;
    else if (din <= 32'hD111_1111) dout <= 32'h0000_0083;
    else if (din <= 32'hD27D_27D2) dout <= 32'h0000_0083;
    else if (din <= 32'hD3E9_3E94) dout <= 32'h0000_007F;
    else if (din <= 32'hD555_5555) dout <= 32'h0000_007B;
    else if (din <= 32'hD6C1_6C17) dout <= 32'h0000_007B;
    else if (din <= 32'hD82D_82D8) dout <= 32'h0000_0077;
    else if (din <= 32'hD999_999A) dout <= 32'h0000_0077;
    else if (din <= 32'hDB05_B05B) dout <= 32'h0000_0073;
    else if (din <= 32'hDC71_C71C) dout <= 32'h0000_006F;
    else if (din <= 32'hDDDD_DDDE) dout <= 32'h0000_006F;
    else if (din <= 32'hDF49_F49F) dout <= 32'h0000_006A;
    else if (din <= 32'hE0B6_0B61) dout <= 32'h0000_006A;
    else if (din <= 32'hE222_2222) dout <= 32'h0000_006A;
    else if (din <= 32'hE38E_38E4) dout <= 32'h0000_0066;
    else if (din <= 32'hE4FA_4FA5) dout <= 32'h0000_0062;
    else if (din <= 32'hE666_6666) dout <= 32'h0000_0062;
    else if (din <= 32'hE7D2_7D28) dout <= 32'h0000_0062;
    else if (din <= 32'hE93E_93E9) dout <= 32'h0000_0062;
    else if (din <= 32'hEAAA_AAAB) dout <= 32'h0000_005E;
    else if (din <= 32'hEC16_C16C) dout <= 32'h0000_005E;
    else if (din <= 32'hED82_D82E) dout <= 32'h0000_005E;
    else if (din <= 32'hEEEE_EEEF) dout <= 32'h0000_005A;
    else if (din <= 32'hF05B_05B0) dout <= 32'h0000_005A;
    else if (din <= 32'hF1C7_1C72) dout <= 32'h0000_005A;
    else if (din <= 32'hF333_3333) dout <= 32'h0000_0056;
    else if (din <= 32'hF49F_49F5) dout <= 32'h0000_0056;
    else if (din <= 32'hF60B_60B6) dout <= 32'h0000_0056;
    else if (din <= 32'hF777_7777) dout <= 32'h0000_0056;
    else if (din <= 32'hF8E3_8E39) dout <= 32'h0000_0052;
    else if (din <= 32'hFA4F_A4FA) dout <= 32'h0000_0052;
    else if (din <= 32'hFBBB_BBBC) dout <= 32'h0000_0052;
    else if (din <= 32'hFD27_D27D) dout <= 32'h0000_0052;
    else if (din <= 32'hFE93_E93F) dout <= 32'h0000_004E;
    else if (din <= 32'hFFFF_FFFF) dout <= 32'h0000_004E;
    else dout <= 32'h0000_0000;
end


endmodule