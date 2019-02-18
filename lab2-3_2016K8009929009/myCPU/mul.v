`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/04 13:53:17
// Design Name: 
// Module Name: mul
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mul(
    input mul_clk,
    input resetn,
    input mul_signed,
    input [31:0] x,
    input [31:0] y,

    output wire signed [63:0] result
    );

    wire [63:0] x_extend;
    wire [33:0] y_extend;
    assign x_extend = (mul_signed)?{{32{x[31]}},x}:{32'b0,x};
    assign y_extend = (mul_signed)?{{2{y[31]}},y}:{2'b0,y};
    //第一个部分积
    wire [63:0] P_0;
    wire [63:0] P0;
    wire S_0_x_0  = ~y_extend[1] & y_extend[0];
    wire S_0_x_1  = y_extend[1] & y_extend[0];
    wire S_0_2x_1 = y_extend[1] & ~y_extend[0];
    wire S_0_2x_0 = 0;
    wire C_0   = S_0_2x_1 | S_0_x_1;
    assign P_0 = ~(~({64{S_0_x_1}} & ~x_extend) & ~({64{S_0_2x_1}} & ~{x_extend[62:0],1'b0}) & ~({64{S_0_x_0}} & x_extend) & ~({64{S_0_2x_0}} & {x_extend[62:0],1'b0}));
    assign P0  = P_0;
    //第二个部分积
    wire [63:0] P_1;
    wire [63:0] P1;
    wire S_2_x_1  = ~(~(y_extend[3]&y_extend[2]&~y_extend[1]) & ~(y_extend[3]&~y_extend[2]&y_extend[1]));
    wire S_2_x_0  = ~(~(~y_extend[3]&y_extend[2]&~y_extend[1]) & ~(~y_extend[3]&~y_extend[2]&y_extend[1]));
    wire S_2_2x_1 = y_extend[3]&~y_extend[2]&~y_extend[1];
    wire S_2_2x_0 = ~y_extend[3]&y_extend[2]&y_extend[1];
    wire C_1   = S_2_2x_1 | S_2_x_1;
    assign P_1 = ~(~({64{S_2_x_1}} & ~{x_extend[61:0],2'b0}) & ~({64{S_2_2x_1}} & ~{x_extend[60:0],3'b0}) & ~({64{S_2_x_0}} & {x_extend[61:0],2'b0}) & ~({64{S_2_2x_0}} & {x_extend[60:0],3'b0}));
    assign P1  = P_1;
    //部分�???????3
    wire [63:0] P_2;
    wire [63:0] P2;
    wire S_4_x_1  = ~(~(y_extend[5]&y_extend[4]&~y_extend[3]) & ~(y_extend[5]&~y_extend[4]&y_extend[3]));
    wire S_4_x_0  = ~(~(~y_extend[5]&y_extend[4]&~y_extend[3]) & ~(~y_extend[5]&~y_extend[4]&y_extend[3]));
    wire S_4_2x_1 = y_extend[5]&~y_extend[4]&~y_extend[3];
    wire S_4_2x_0 = ~y_extend[5]&y_extend[4]&y_extend[3];
    wire C_2   = S_4_2x_1 | S_4_x_1;
    assign P_2 = ~(~({64{S_4_x_1}} & ~{x_extend[59:0],4'b0}) & ~({64{S_4_2x_1}} & ~{x_extend[58:0],5'b0}) & ~({64{S_4_x_0}} & {x_extend[59:0],4'b0}) & ~({64{S_4_2x_0}} & {x_extend[58:0],5'b0}));
    assign P2  = P_2;
    //部分�???????4
    wire [63:0] P_3;
    wire [63:0] P3;
    wire S_6_x_1  = ~(~(y_extend[7]&y_extend[6]&~y_extend[5]) & ~(y_extend[7]&~y_extend[6]&y_extend[5]));
    wire S_6_x_0  = ~(~(~y_extend[7]&y_extend[6]&~y_extend[5]) & ~(~y_extend[7]&~y_extend[6]&y_extend[5]));
    wire S_6_2x_1 = y_extend[7]&~y_extend[6]&~y_extend[5];
    wire S_6_2x_0 = ~y_extend[7]&y_extend[6]&y_extend[5];
    wire C_3   = S_6_2x_1 | S_6_x_1;
    assign P_3 = ~(~({64{S_6_x_1}} & ~{x_extend[57:0],6'b0}) & ~({64{S_6_2x_1}} & ~{x_extend[56:0],7'b0}) & ~({64{S_6_x_0}} & {x_extend[57:0],6'b0}) & ~({64{S_6_2x_0}} & {x_extend[56:0],7'b0}));
    assign P3  = P_3;
    //部分�???????5
    wire [63:0] P_4;
    wire [63:0] P4;
    wire S_8_x_1  = ~(~(y_extend[9]&y_extend[8]&~y_extend[7]) & ~(y_extend[9]&~y_extend[8]&y_extend[7]));
    wire S_8_x_0  = ~(~(~y_extend[9]&y_extend[8]&~y_extend[7]) & ~(~y_extend[9]&~y_extend[8]&y_extend[7]));
    wire S_8_2x_1 = y_extend[9]&~y_extend[8]&~y_extend[7];
    wire S_8_2x_0 = ~y_extend[9]&y_extend[8]&y_extend[7];
    wire C_4   = S_8_2x_1 | S_8_x_1;
    assign P_4 = ~(~({64{S_8_x_1}} & ~{x_extend[55:0],8'b0}) & ~({64{S_8_2x_1}} & ~{x_extend[54:0],9'b0}) & ~({64{S_8_x_0}} & {x_extend[55:0],8'b0}) & ~({64{S_8_2x_0}} & {x_extend[54:0],9'b0}));
    assign P4  = P_4;
    //部分�???????6
    wire [63:0] P_5;
    wire [63:0] P5;
    wire S_10_x_1  = ~(~(y_extend[11]&y_extend[10]&~y_extend[9]) & ~(y_extend[11]&~y_extend[10]&y_extend[9]));
    wire S_10_x_0  = ~(~(~y_extend[11]&y_extend[10]&~y_extend[9]) & ~(~y_extend[11]&~y_extend[10]&y_extend[9]));
    wire S_10_2x_1 = y_extend[11]&~y_extend[10]&~y_extend[9];
    wire S_10_2x_0 = ~y_extend[11]&y_extend[10]&y_extend[9];
    wire C_5   = S_10_2x_1 | S_10_x_1; 
    assign P_5 = ~(~({64{S_10_x_1}} & ~{x_extend[53:0],10'b0}) & ~({64{S_10_2x_1}} & ~{x_extend[52:0],11'b0}) & ~({64{S_10_x_0}} & {x_extend[53:0],10'b0}) & ~({64{S_10_2x_0}} & {x_extend[52:0],11'b0}));
    assign P5  = P_5;
    //部分�???????7
    wire [63:0] P_6;
    wire [63:0] P6;
    wire S_12_x_1 = ~(~(y_extend[13]&y_extend[12]&~y_extend[11]) & ~(y_extend[13]&~y_extend[12]&y_extend[11]));
    wire S_12_x_0  = ~(~(~y_extend[13]&y_extend[12]&~y_extend[11]) & ~(~y_extend[13]&~y_extend[12]&y_extend[11]));
    wire S_12_2x_1 = y_extend[13]&~y_extend[12]&~y_extend[11];
    wire S_12_2x_0 = ~y_extend[13]&y_extend[12]&y_extend[11];
    wire C_6   = S_12_2x_1 | S_12_x_1;
    assign P_6 = ~(~({64{S_12_x_1}} & ~{x_extend[51:0],12'b0}) & ~({64{S_12_2x_1}} & ~{x_extend[50:0],13'b0}) & ~({64{S_12_x_0}} & {x_extend[51:0],12'b0}) & ~({64{S_12_2x_0}} & {x_extend[50:0],13'b0}));
    assign P6  = P_6;
    //部分�???????8
    wire [63:0] P_7;
    wire [63:0] P7;
    wire S_14_x_1  = ~(~(y_extend[15]&y_extend[14]&~y_extend[13]) & ~(y_extend[15]&~y_extend[14]&y_extend[13]));
    wire S_14_x_0  = ~(~(~y_extend[15]&y_extend[14]&~y_extend[13]) & ~(~y_extend[15]&~y_extend[14]&y_extend[13]));
    wire S_14_2x_1 = y_extend[15]&~y_extend[14]&~y_extend[13];
    wire S_14_2x_0 = ~y_extend[15]&y_extend[14]&y_extend[13];
    wire C_7   = S_14_2x_1 | S_14_x_1;
    assign P_7 = ~(~({64{S_14_x_1}} & ~{x_extend[49:0],14'b0}) & ~({64{S_14_2x_1}} & ~{x_extend[48:0],15'b0}) & ~({64{S_14_x_0}} & {x_extend[49:0],14'b0}) & ~({64{S_14_2x_0}} & {x_extend[48:0],15'b0}));
    assign P7  = P_7;
    //部分�???????9
    wire [63:0] P_8;
    wire [63:0] P8;
    wire S_16_x_1  = ~(~(y_extend[17]&y_extend[16]&~y_extend[15]) & ~(y_extend[17]&~y_extend[16]&y_extend[15]));
    wire S_16_x_0  = ~(~(~y_extend[17]&y_extend[16]&~y_extend[15]) & ~(~y_extend[17]&~y_extend[16]&y_extend[15]));
    wire S_16_2x_1 = y_extend[17]&~y_extend[16]&~y_extend[15];
    wire S_16_2x_0 = ~y_extend[17]&y_extend[16]&y_extend[15];
    wire C_8   = S_16_2x_1 | S_16_x_1;
    assign P_8 = ~(~({64{S_16_x_1}} & ~{x_extend[47:0],16'b0}) & ~({64{S_16_2x_1}} & ~{x_extend[46:0],17'b0}) & ~({64{S_16_x_0}} & {x_extend[47:0],16'b0}) & ~({64{S_16_2x_0}} & {x_extend[46:0],17'b0}));
    assign P8  = P_8;
    //部分�???????10
    wire [63:0] P_9;
    wire [63:0] P9;
    wire S_18_x_1  = ~(~(y_extend[19]&y_extend[18]&~y_extend[17]) & ~(y_extend[19]&~y_extend[18]&y_extend[17]));
    wire S_18_x_0  = ~(~(~y_extend[19]&y_extend[18]&~y_extend[17]) & ~(~y_extend[19]&~y_extend[18]&y_extend[17]));
    wire S_18_2x_1 = y_extend[19]&~y_extend[18]&~y_extend[17];
    wire S_18_2x_0 = ~y_extend[19]&y_extend[18]&y_extend[17];
    wire C_9   = S_18_2x_1 | S_18_x_1;
    assign P_9 = ~(~({64{S_18_x_1}} & ~{x_extend[45:0],18'b0}) & ~({64{S_18_2x_1}} & ~{x_extend[44:0],19'b0}) & ~({64{S_18_x_0}} & {x_extend[45:0],18'b0}) & ~({64{S_18_2x_0}} & {x_extend[44:0],19'b0}));
    assign P9 = P_9;
    //部分�???????11
    wire [63:0] P_10;
    wire [63:0] P10;
    wire S_20_x_1  = ~(~(y_extend[21]&y_extend[20]&~y_extend[19]) & ~(y_extend[21]&~y_extend[20]&y_extend[19]));
    wire S_20_x_0  = ~(~(~y_extend[21]&y_extend[20]&~y_extend[19]) & ~(~y_extend[21]&~y_extend[20]&y_extend[19]));
    wire S_20_2x_1 = y_extend[21]&~y_extend[20]&~y_extend[19];
    wire S_20_2x_0 = ~y_extend[21]&y_extend[20]&y_extend[19];
    wire C_10   = S_20_2x_1 | S_20_x_1;
    assign P_10 = ~(~({64{S_20_x_1}} & ~{x_extend[43:0],20'b0}) & ~({64{S_20_2x_1}} & ~{x_extend[42:0],21'b0}) & ~({64{S_20_x_0}} & {x_extend[43:0],20'b0}) & ~({64{S_20_2x_0}} & {x_extend[42:0],21'b0}));
    assign P10  = P_10;
    //部分�???????12
    wire [63:0] P_11;
    wire [63:0] P11;
    wire S_22_x_1  = ~(~(y_extend[23]&y_extend[22]&~y_extend[21]) & ~(y_extend[23]&~y_extend[22]&y_extend[21]));
    wire S_22_x_0  = ~(~(~y_extend[23]&y_extend[22]&~y_extend[21]) & ~(~y_extend[23]&~y_extend[22]&y_extend[21]));
    wire S_22_2x_1 = y_extend[23]&~y_extend[22]&~y_extend[21];
    wire S_22_2x_0 = ~y_extend[23]&y_extend[22]&y_extend[21];
    wire C_11   = S_22_2x_1 | S_22_x_1;
    assign P_11 = ~(~({64{S_22_x_1}} & ~{x_extend[41:0],22'b0}) & ~({64{S_22_2x_1}} & ~{x_extend[40:0],23'b0}) & ~({64{S_22_x_0}} & {x_extend[41:0],22'b0}) & ~({64{S_22_2x_0}} & {x_extend[40:0],23'b0}));
    assign P11  = P_11;
    //部分�???????13
    wire [63:0] P_12;
    wire [63:0] P12;
    wire S_24_x_1  = ~(~(y_extend[25]&y_extend[24]&~y_extend[23]) & ~(y_extend[25]&~y_extend[24]&y_extend[23]));
    wire S_24_x_0  = ~(~(~y_extend[25]&y_extend[24]&~y_extend[23]) & ~(~y_extend[25]&~y_extend[24]&y_extend[23]));
    wire S_24_2x_1 = y_extend[25]&~y_extend[24]&~y_extend[23];
    wire S_24_2x_0 = ~y_extend[25]&y_extend[24]&y_extend[23];
    wire C_12   = S_24_2x_1 | S_24_x_1;
    assign P_12 = ~(~({64{S_24_x_1}} & ~{x_extend[39:0],24'b0}) & ~({64{S_24_2x_1}} & ~{x_extend[38:0],25'b0}) & ~({64{S_24_x_0}} & {x_extend[39:0],24'b0}) & ~({64{S_24_2x_0}} & {x_extend[38:0],25'b0}));
    assign P12  = P_12;
    //部分�???????14
    wire [63:0] P_13;
    wire [63:0] P13;
    wire S_26_x_1  = ~(~(y_extend[27]&y_extend[26]&~y_extend[25]) & ~(y_extend[27]&~y_extend[26]&y_extend[25]));
    wire S_26_x_0  = ~(~(~y_extend[27]&y_extend[26]&~y_extend[25]) & ~(~y_extend[27]&~y_extend[26]&y_extend[25]));
    wire S_26_2x_1 = y_extend[27]&~y_extend[26]&~y_extend[25];
    wire S_26_2x_0 = ~y_extend[27]&y_extend[26]&y_extend[25];
    wire C_13   = S_26_2x_1 | S_26_x_1;
    assign P_13 = ~(~({64{S_26_x_1}} & ~{x_extend[37:0],26'b0}) & ~({64{S_26_2x_1}} & ~{x_extend[36:0],27'b0}) & ~({64{S_26_x_0}} & {x_extend[37:0],26'b0}) & ~({64{S_26_2x_0}} & {x_extend[36:0],27'b0}));
    assign P13  = P_13;
    //部分�???????15
    wire [63:0] P_14;
    wire [63:0] P14;
    wire S_28_x_1  = ~(~(y_extend[29]&y_extend[28]&~y_extend[27]) & ~(y_extend[29]&~y_extend[28]&y_extend[27]));
    wire S_28_x_0  = ~(~(~y_extend[29]&y_extend[28]&~y_extend[27]) & ~(~y_extend[29]&~y_extend[28]&y_extend[27]));
    wire S_28_2x_1 = y_extend[29]&~y_extend[28]&~y_extend[27];
    wire S_28_2x_0 = ~y_extend[29]&y_extend[28]&y_extend[27];
    wire C_14   = S_28_2x_1 | S_28_x_1;
    assign P_14 = ~(~({64{S_28_x_1}} & ~{x_extend[35:0],28'b0}) & ~({64{S_28_2x_1}} & ~{x_extend[34:0],29'b0}) & ~({64{S_28_x_0}} & {x_extend[35:0],28'b0}) & ~({64{S_28_2x_0}} & {x_extend[34:0],29'b0}));
    assign P14  = P_14;
    //部分�???????16
    wire [63:0] P_15;
    wire [63:0] P15;
    wire S_30_x_1  = ~(~(y_extend[31]&y_extend[30]&~y_extend[29]) & ~(y_extend[31]&~y_extend[30]&y_extend[29]));
    wire S_30_x_0  = ~(~(~y_extend[31]&y_extend[30]&~y_extend[29]) & ~(~y_extend[31]&~y_extend[30]&y_extend[29]));
    wire S_30_2x_1 = y_extend[31]&~y_extend[30]&~y_extend[29];
    wire S_30_2x_0 = ~y_extend[31]&y_extend[30]&y_extend[29];
    wire C_15   = S_30_2x_1 | S_30_x_1;
    assign P_15 = ~(~({64{S_30_x_1}} & ~{x_extend[33:0],30'b0}) & ~({64{S_30_2x_1}} & ~{x_extend[32:0],31'b0}) & ~({64{S_30_x_0}} & {x_extend[33:0],30'b0}) & ~({64{S_30_2x_0}} & {x_extend[32:0],31'b0}));
    assign P15 = P_15;
    //部分�???????17
    wire [63:0] P_16;
    wire [63:0] P16;
    wire S_32_x_1  = ~(~(y_extend[33]&y_extend[32]&~y_extend[31]) & ~(y_extend[33]&~y_extend[32]&y_extend[31]));
    wire S_32_x_0  = ~(~(~y_extend[33]&y_extend[32]&~y_extend[31]) & ~(~y_extend[33]&~y_extend[32]&y_extend[31]));
    wire S_32_2x_1 = y_extend[33]&~y_extend[32]&~y_extend[31];
    wire S_32_2x_0 = ~y_extend[33]&y_extend[32]&y_extend[31];
    wire C_16   = S_32_2x_1 | S_32_x_1;
    assign P_16 = ~(~({64{S_32_x_1}} & ~{x_extend[31:0],32'b0}) & ~({64{S_32_2x_1}} & ~{x_extend[30:0],33'b0}) & ~({64{S_32_x_0}} & {x_extend[31:0],32'b0}) & ~({64{S_32_2x_0}} & {x_extend[30:0],33'b0}));
    assign P16  = P_16;

//Switch转换部分*************************************************************************************************************************************************************************
    reg [16:0] temp_0,temp_1,temp_2,temp_3,temp_4,temp_5,temp_6,temp_7,temp_8,temp_9,temp_10,temp_11,temp_12,temp_13,temp_14,temp_15,temp_16;
    reg [16:0] temp_17,temp_18,temp_19,temp_20,temp_21,temp_22,temp_23,temp_24,temp_25,temp_26,temp_27,temp_28,temp_29,temp_30,temp_31,temp_32;
    reg [16:0] temp_33,temp_34,temp_35,temp_36,temp_37,temp_38,temp_39,temp_40,temp_41,temp_42,temp_43,temp_44,temp_45,temp_46,temp_47,temp_48;
    reg [16:0] temp_49,temp_50,temp_51,temp_52,temp_53,temp_54,temp_55,temp_56,temp_57,temp_58,temp_59,temp_60,temp_61,temp_62,temp_63;
    
    always@(posedge mul_clk)begin
      if(!resetn)begin
        temp_0 <= 17'b0;
        temp_1 <= 17'b0;
        temp_2 <= 17'b0;
        temp_3 <= 17'b0;
        temp_4 <= 17'b0;
        temp_5 <= 17'b0;
        temp_6 <= 17'b0;
        temp_7 <= 17'b0;
        temp_8 <= 17'b0;
        temp_9 <= 17'b0;
        temp_10 <= 17'b0;
        temp_11 <= 17'b0;
        temp_12 <= 17'b0;
        temp_13 <= 17'b0;
        temp_14 <= 17'b0;
        temp_15 <= 17'b0;
        temp_16 <= 17'b0;
        temp_17 <= 17'b0;
        temp_18 <= 17'b0;
        temp_19 <= 17'b0;
        temp_20 <= 17'b0;
        temp_21 <= 17'b0;
        temp_22 <= 17'b0;
        temp_23 <= 17'b0;
        temp_24 <= 17'b0;
        temp_25 <= 17'b0;
        temp_26 <= 17'b0;
        temp_27 <= 17'b0;
        temp_28 <= 17'b0;
        temp_29 <= 17'b0;
        temp_30 <= 17'b0;
        temp_31 <= 17'b0;
        temp_32 <= 17'b0;
        temp_33 <= 17'b0;
        temp_34 <= 17'b0;
        temp_35 <= 17'b0;
        temp_36 <= 17'b0;
        temp_37 <= 17'b0;
        temp_38 <= 17'b0;
        temp_39 <= 17'b0;
        temp_40 <= 17'b0;
        temp_41 <= 17'b0;
        temp_42 <= 17'b0;
        temp_43 <= 17'b0;
        temp_44 <= 17'b0;
        temp_45 <= 17'b0;
        temp_46 <= 17'b0;
        temp_47 <= 17'b0;
        temp_48 <= 17'b0;
        temp_49 <= 17'b0;
        temp_50 <= 17'b0;
        temp_51 <= 17'b0;
        temp_52 <= 17'b0;
        temp_53 <= 17'b0;
        temp_54 <= 17'b0;
        temp_55 <= 17'b0;
        temp_56 <= 17'b0;
        temp_57 <= 17'b0;
        temp_58 <= 17'b0;
        temp_59 <= 17'b0;
        temp_60 <= 17'b0;
        temp_61 <= 17'b0;
        temp_62 <= 17'b0;
        temp_63 <= 17'b0;
      end
     else begin
           temp_0 <= {P16[0],P15[0],P14[0],P13[0],P12[0],P11[0],P10[0],P9[0],P8[0],P7[0],P6[0],P5[0],P4[0],P3[0],P2[0],P1[0],P0[0]};
           temp_1 <= {P16[1],P15[1],P14[1],P13[1],P12[1],P11[1],P10[1],P9[1],P8[1],P7[1],P6[1],P5[1],P4[1],P3[1],P2[1],P1[1],P0[1]};
           temp_2 <= {P16[2],P15[2],P14[2],P13[2],P12[2],P11[2],P10[2],P9[2],P8[2],P7[2],P6[2],P5[2],P4[2],P3[2],P2[2],P1[2],P0[2]};
           temp_3 <= {P16[3],P15[3],P14[3],P13[3],P12[3],P11[3],P10[3],P9[3],P8[3],P7[3],P6[3],P5[3],P4[3],P3[3],P2[3],P1[3],P0[3]};
           temp_4 <= {P16[4],P15[4],P14[4],P13[4],P12[4],P11[4],P10[4],P9[4],P8[4],P7[4],P6[4],P5[4],P4[4],P3[4],P2[4],P1[4],P0[4]};
           temp_5 <= {P16[5],P15[5],P14[5],P13[5],P12[5],P11[5],P10[5],P9[5],P8[5],P7[5],P6[5],P5[5],P4[5],P3[5],P2[5],P1[5],P0[5]};
           temp_6 <= {P16[6],P15[6],P14[6],P13[6],P12[6],P11[6],P10[6],P9[6],P8[6],P7[6],P6[6],P5[6],P4[6],P3[6],P2[6],P1[6],P0[6]};
           temp_7 <= {P16[7],P15[7],P14[7],P13[7],P12[7],P11[7],P10[7],P9[7],P8[7],P7[7],P6[7],P5[7],P4[7],P3[7],P2[7],P1[7],P0[7]};
           temp_8 <= {P16[8],P15[8],P14[8],P13[8],P12[8],P11[8],P10[8],P9[8],P8[8],P7[8],P6[8],P5[8],P4[8],P3[8],P2[8],P1[8],P0[8]};
           temp_9 <= {P16[9],P15[9],P14[9],P13[9],P12[9],P11[9],P10[9],P9[9],P8[9],P7[9],P6[9],P5[9],P4[9],P3[9],P2[9],P1[9],P0[9]};
           temp_10 <= {P16[10],P15[10],P14[10],P13[10],P12[10],P11[10],P10[10],P9[10],P8[10],P7[10],P6[10],P5[10],P4[10],P3[10],P2[10],P1[10],P0[10]};
           temp_11 <= {P16[11],P15[11],P14[11],P13[11],P12[11],P11[11],P10[11],P9[11],P8[11],P7[11],P6[11],P5[11],P4[11],P3[11],P2[11],P1[11],P0[11]};
           temp_12 <= {P16[12],P15[12],P14[12],P13[12],P12[12],P11[12],P10[12],P9[12],P8[12],P7[12],P6[12],P5[12],P4[12],P3[12],P2[12],P1[12],P0[12]};
           temp_13 <= {P16[13],P15[13],P14[13],P13[13],P12[13],P11[13],P10[13],P9[13],P8[13],P7[13],P6[13],P5[13],P4[13],P3[13],P2[13],P1[13],P0[13]};
           temp_14 <= {P16[14],P15[14],P14[14],P13[14],P12[14],P11[14],P10[14],P9[14],P8[14],P7[14],P6[14],P5[14],P4[14],P3[14],P2[14],P1[14],P0[14]};
           temp_15 <= {P16[15],P15[15],P14[15],P13[15],P12[15],P11[15],P10[15],P9[15],P8[15],P7[15],P6[15],P5[15],P4[15],P3[15],P2[15],P1[15],P0[15]};
           temp_16 <= {P16[16],P15[16],P14[16],P13[16],P12[16],P11[16],P10[16],P9[16],P8[16],P7[16],P6[16],P5[16],P4[16],P3[16],P2[16],P1[16],P0[16]};
           temp_17 <= {P16[17],P15[17],P14[17],P13[17],P12[17],P11[17],P10[17],P9[17],P8[17],P7[17],P6[17],P5[17],P4[17],P3[17],P2[17],P1[17],P0[17]};
           temp_18 <= {P16[18],P15[18],P14[18],P13[18],P12[18],P11[18],P10[18],P9[18],P8[18],P7[18],P6[18],P5[18],P4[18],P3[18],P2[18],P1[18],P0[18]};
           temp_19 <= {P16[19],P15[19],P14[19],P13[19],P12[19],P11[19],P10[19],P9[19],P8[19],P7[19],P6[19],P5[19],P4[19],P3[19],P2[19],P1[19],P0[19]};
           temp_20 <= {P16[20],P15[20],P14[20],P13[20],P12[20],P11[20],P10[20],P9[20],P8[20],P7[20],P6[20],P5[20],P4[20],P3[20],P2[20],P1[20],P0[20]};
           temp_21 <= {P16[21],P15[21],P14[21],P13[21],P12[21],P11[21],P10[21],P9[21],P8[21],P7[21],P6[21],P5[21],P4[21],P3[21],P2[21],P1[21],P0[21]};
           temp_22 <= {P16[22],P15[22],P14[22],P13[22],P12[22],P11[22],P10[22],P9[22],P8[22],P7[22],P6[22],P5[22],P4[22],P3[22],P2[22],P1[22],P0[22]};
           temp_23 <= {P16[23],P15[23],P14[23],P13[23],P12[23],P11[23],P10[23],P9[23],P8[23],P7[23],P6[23],P5[23],P4[23],P3[23],P2[23],P1[23],P0[23]};
           temp_24 <= {P16[24],P15[24],P14[24],P13[24],P12[24],P11[24],P10[24],P9[24],P8[24],P7[24],P6[24],P5[24],P4[24],P3[24],P2[24],P1[24],P0[24]};
           temp_25 <= {P16[25],P15[25],P14[25],P13[25],P12[25],P11[25],P10[25],P9[25],P8[25],P7[25],P6[25],P5[25],P4[25],P3[25],P2[25],P1[25],P0[25]};
           temp_26 <= {P16[26],P15[26],P14[26],P13[26],P12[26],P11[26],P10[26],P9[26],P8[26],P7[26],P6[26],P5[26],P4[26],P3[26],P2[26],P1[26],P0[26]};
           temp_27 <= {P16[27],P15[27],P14[27],P13[27],P12[27],P11[27],P10[27],P9[27],P8[27],P7[27],P6[27],P5[27],P4[27],P3[27],P2[27],P1[27],P0[27]};
           temp_28 <= {P16[28],P15[28],P14[28],P13[28],P12[28],P11[28],P10[28],P9[28],P8[28],P7[28],P6[28],P5[28],P4[28],P3[28],P2[28],P1[28],P0[28]};
           temp_29 <= {P16[29],P15[29],P14[29],P13[29],P12[29],P11[29],P10[29],P9[29],P8[29],P7[29],P6[29],P5[29],P4[29],P3[29],P2[29],P1[29],P0[29]};
           temp_30 <= {P16[30],P15[30],P14[30],P13[30],P12[30],P11[30],P10[30],P9[30],P8[30],P7[30],P6[30],P5[30],P4[30],P3[30],P2[30],P1[30],P0[30]};
           temp_31 <= {P16[31],P15[31],P14[31],P13[31],P12[31],P11[31],P10[31],P9[31],P8[31],P7[31],P6[31],P5[31],P4[31],P3[31],P2[31],P1[31],P0[31]};
           temp_32 <= {P16[32],P15[32],P14[32],P13[32],P12[32],P11[32],P10[32],P9[32],P8[32],P7[32],P6[32],P5[32],P4[32],P3[32],P2[32],P1[32],P0[32]};
           temp_33 <= {P16[33],P15[33],P14[33],P13[33],P12[33],P11[33],P10[33],P9[33],P8[33],P7[33],P6[33],P5[33],P4[33],P3[33],P2[33],P1[33],P0[33]};
           temp_34 <= {P16[34],P15[34],P14[34],P13[34],P12[34],P11[34],P10[34],P9[34],P8[34],P7[34],P6[34],P5[34],P4[34],P3[34],P2[34],P1[34],P0[34]};
           temp_35 <= {P16[35],P15[35],P14[35],P13[35],P12[35],P11[35],P10[35],P9[35],P8[35],P7[35],P6[35],P5[35],P4[35],P3[35],P2[35],P1[35],P0[35]};
           temp_36 <= {P16[36],P15[36],P14[36],P13[36],P12[36],P11[36],P10[36],P9[36],P8[36],P7[36],P6[36],P5[36],P4[36],P3[36],P2[36],P1[36],P0[36]};
           temp_37 <= {P16[37],P15[37],P14[37],P13[37],P12[37],P11[37],P10[37],P9[37],P8[37],P7[37],P6[37],P5[37],P4[37],P3[37],P2[37],P1[37],P0[37]};
           temp_38 <= {P16[38],P15[38],P14[38],P13[38],P12[38],P11[38],P10[38],P9[38],P8[38],P7[38],P6[38],P5[38],P4[38],P3[38],P2[38],P1[38],P0[38]};
           temp_39 <= {P16[39],P15[39],P14[39],P13[39],P12[39],P11[39],P10[39],P9[39],P8[39],P7[39],P6[39],P5[39],P4[39],P3[39],P2[39],P1[39],P0[39]};
           temp_40 <= {P16[40],P15[40],P14[40],P13[40],P12[40],P11[40],P10[40],P9[40],P8[40],P7[40],P6[40],P5[40],P4[40],P3[40],P2[40],P1[40],P0[40]};
           temp_41 <= {P16[41],P15[41],P14[41],P13[41],P12[41],P11[41],P10[41],P9[41],P8[41],P7[41],P6[41],P5[41],P4[41],P3[41],P2[41],P1[41],P0[41]};
           temp_42 <= {P16[42],P15[42],P14[42],P13[42],P12[42],P11[42],P10[42],P9[42],P8[42],P7[42],P6[42],P5[42],P4[42],P3[42],P2[42],P1[42],P0[42]};
           temp_43 <= {P16[43],P15[43],P14[43],P13[43],P12[43],P11[43],P10[43],P9[43],P8[43],P7[43],P6[43],P5[43],P4[43],P3[43],P2[43],P1[43],P0[43]};
           temp_44 <= {P16[44],P15[44],P14[44],P13[44],P12[44],P11[44],P10[44],P9[44],P8[44],P7[44],P6[44],P5[44],P4[44],P3[44],P2[44],P1[44],P0[44]};
           temp_45 <= {P16[45],P15[45],P14[45],P13[45],P12[45],P11[45],P10[45],P9[45],P8[45],P7[45],P6[45],P5[45],P4[45],P3[45],P2[45],P1[45],P0[45]};
           temp_46 <= {P16[46],P15[46],P14[46],P13[46],P12[46],P11[46],P10[46],P9[46],P8[46],P7[46],P6[46],P5[46],P4[46],P3[46],P2[46],P1[46],P0[46]};
           temp_47 <= {P16[47],P15[47],P14[47],P13[47],P12[47],P11[47],P10[47],P9[47],P8[47],P7[47],P6[47],P5[47],P4[47],P3[47],P2[47],P1[47],P0[47]};
           temp_48 <= {P16[48],P15[48],P14[48],P13[48],P12[48],P11[48],P10[48],P9[48],P8[48],P7[48],P6[48],P5[48],P4[48],P3[48],P2[48],P1[48],P0[48]};
           temp_49 <= {P16[49],P15[49],P14[49],P13[49],P12[49],P11[49],P10[49],P9[49],P8[49],P7[49],P6[49],P5[49],P4[49],P3[49],P2[49],P1[49],P0[49]};
           temp_50 <= {P16[50],P15[50],P14[50],P13[50],P12[50],P11[50],P10[50],P9[50],P8[50],P7[50],P6[50],P5[50],P4[50],P3[50],P2[50],P1[50],P0[50]};
           temp_51 <= {P16[51],P15[51],P14[51],P13[51],P12[51],P11[51],P10[51],P9[51],P8[51],P7[51],P6[51],P5[51],P4[51],P3[51],P2[51],P1[51],P0[51]};
           temp_52 <= {P16[52],P15[52],P14[52],P13[52],P12[52],P11[52],P10[52],P9[52],P8[52],P7[52],P6[52],P5[52],P4[52],P3[52],P2[52],P1[52],P0[52]};
           temp_53 <= {P16[53],P15[53],P14[53],P13[53],P12[53],P11[53],P10[53],P9[53],P8[53],P7[53],P6[53],P5[53],P4[53],P3[53],P2[53],P1[53],P0[53]};
           temp_54 <= {P16[54],P15[54],P14[54],P13[54],P12[54],P11[54],P10[54],P9[54],P8[54],P7[54],P6[54],P5[54],P4[54],P3[54],P2[54],P1[54],P0[54]};
           temp_55 <= {P16[55],P15[55],P14[55],P13[55],P12[55],P11[55],P10[55],P9[55],P8[55],P7[55],P6[55],P5[55],P4[55],P3[55],P2[55],P1[55],P0[55]};
           temp_56 <= {P16[56],P15[56],P14[56],P13[56],P12[56],P11[56],P10[56],P9[56],P8[56],P7[56],P6[56],P5[56],P4[56],P3[56],P2[56],P1[56],P0[56]};
           temp_57 <= {P16[57],P15[57],P14[57],P13[57],P12[57],P11[57],P10[57],P9[57],P8[57],P7[57],P6[57],P5[57],P4[57],P3[57],P2[57],P1[57],P0[57]};
           temp_58 <= {P16[58],P15[58],P14[58],P13[58],P12[58],P11[58],P10[58],P9[58],P8[58],P7[58],P6[58],P5[58],P4[58],P3[58],P2[58],P1[58],P0[58]};
           temp_59 <= {P16[59],P15[59],P14[59],P13[59],P12[59],P11[59],P10[59],P9[59],P8[59],P7[59],P6[59],P5[59],P4[59],P3[59],P2[59],P1[59],P0[59]};
           temp_60 <= {P16[60],P15[60],P14[60],P13[60],P12[60],P11[60],P10[60],P9[60],P8[60],P7[60],P6[60],P5[60],P4[60],P3[60],P2[60],P1[60],P0[60]};
           temp_61 <= {P16[61],P15[61],P14[61],P13[61],P12[61],P11[61],P10[61],P9[61],P8[61],P7[61],P6[61],P5[61],P4[61],P3[61],P2[61],P1[61],P0[61]};
           temp_62 <= {P16[62],P15[62],P14[62],P13[62],P12[62],P11[62],P10[62],P9[62],P8[62],P7[62],P6[62],P5[62],P4[62],P3[62],P2[62],P1[62],P0[62]};
           temp_63 <= {P16[63],P15[63],P14[63],P13[63],P12[63],P11[63],P10[63],P9[63],P8[63],P7[63],P6[63],P5[63],P4[63],P3[63],P2[63],P1[63],P0[63]};
        end
    end

    reg C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15;

    always@(posedge mul_clk)begin
        if(!resetn)begin
            C0 <= 1'b0;
            C1 <= 1'b0;
            C2 <= 1'b0;
            C3 <= 1'b0;
            C4 <= 1'b0;
            C5 <= 1'b0;
            C6 <= 1'b0;
            C7 <= 1'b0;
            C8 <= 1'b0;
            C9 <= 1'b0;
            C10 <= 1'b0;
            C11 <= 1'b0;
            C12 <= 1'b0;
            C13 <= 1'b0;
            C14 <= 1'b0;
            C15 <= 1'b0;
        end
        else begin
            C0 <= C_0;
            C1 <= C_1;
            C2 <= C_2;
            C3 <= C_3;
            C4 <= C_4;
            C5 <= C_5;
            C6 <= C_6;
            C7 <= C_7;
            C8 <= C_8;
            C9 <= C_9;
            C10 <= C_10;
            C11 <= C_11;
            C12 <= C_12;
            C13 <= C_13;
            C14 <= C_14;
            C15 <= C_15;
        end
    end
//华莱士树****************************************************************************************************************************************************
    wire [13:0] c_0_in,c_0_out,c_1_in,c_1_out,c_2_in,c_2_out,c_3_in,c_3_out;
    wire [13:0] c_4_in,c_4_out,c_5_in,c_5_out,c_6_in,c_6_out,c_7_in,c_7_out;
    wire [13:0] c_8_in,c_8_out,c_9_in,c_9_out,c_10_in,c_10_out,c_11_in,c_11_out;
    wire [13:0] c_12_in,c_12_out,c_13_in,c_13_out,c_14_in,c_14_out,c_15_in,c_15_out;
    wire [13:0] c_16_in,c_16_out,c_17_in,c_17_out,c_18_in,c_18_out,c_19_in,c_19_out;
    wire [13:0] c_20_in,c_20_out,c_21_in,c_21_out,c_22_in,c_22_out,c_23_in,c_23_out;
    wire [13:0] c_24_in,c_24_out,c_25_in,c_25_out,c_26_in,c_26_out,c_27_in,c_27_out;
    wire [13:0] c_28_in,c_28_out,c_29_in,c_29_out,c_30_in,c_30_out,c_31_in,c_31_out;
    wire [13:0] c_32_in,c_32_out,c_33_in,c_33_out,c_34_in,c_34_out,c_35_in,c_35_out;
    wire [13:0] c_36_in,c_36_out,c_37_in,c_37_out,c_38_in,c_38_out,c_39_in,c_39_out;
    wire [13:0] c_40_in,c_40_out,c_41_in,c_41_out,c_42_in,c_42_out,c_43_in,c_43_out;
    wire [13:0] c_44_in,c_44_out,c_45_in,c_45_out,c_46_in,c_46_out,c_47_in,c_47_out;
    wire [13:0] c_48_in,c_48_out,c_49_in,c_49_out,c_50_in,c_50_out,c_51_in,c_51_out;
    wire [13:0] c_52_in,c_52_out,c_53_in,c_53_out,c_54_in,c_54_out,c_55_in,c_55_out;
    wire [13:0] c_56_in,c_56_out,c_57_in,c_57_out,c_58_in,c_58_out,c_59_in,c_59_out;
    wire [13:0] c_60_in,c_60_out,c_61_in,c_61_out,c_62_in,c_62_out,c_63_in,c_63_out;

    wire c_0,s_0,c_1,s_1,c_2,s_2,c_3,s_3,c_4,s_4,c_5,s_5,c_6,s_6,c_7,s_7,c_8,s_8,c_9,s_9,c_10,s_10,c_11,s_11,c_12,s_12,c_13,s_13,c_14,s_14,c_15,s_15;
    wire c_16,s_16,c_17,s_17,c_18,s_18,c_19,s_19,c_20,s_20,c_21,s_21,c_22,s_22,c_23,s_23,c_24,s_24,c_25,s_25,c_26,s_26,c_27,s_27,c_28,s_28,c_29,s_29,c_30,s_30,c_31,s_31;
    wire c_32,s_32,c_33,s_33,c_34,s_34,c_35,s_35,c_36,s_36,c_37,s_37,c_38,s_38,c_39,s_39,c_40,s_40,c_41,s_41,c_42,s_42,c_43,s_43,c_44,s_44,c_45,s_45,c_46,s_46,c_47,s_47;
    wire c_48,s_48,c_49,s_49,c_50,s_50,c_51,s_51,c_52,s_52,c_53,s_53,c_54,s_54,c_55,s_55,c_56,s_56,c_57,s_57,c_58,s_58,c_59,s_59,c_60,s_60,c_61,s_61,c_62,s_62,c_63,s_63;
    
    assign c_0_in[13:0] = {C13,C12,C11,C10,C9,C8,C7,C6,C5,C4,C3,C2,C1,C0};
    //assign c_0_in = 14'b0;
//华莱士树00
    wtree wtree_0(.num_bit(temp_0),.c_in(c_0_in),.c(c_0),.s(s_0),.c_out(c_0_out));
    assign c_1_in = c_0_out;
//华莱士树01
    wtree wtree_1(.num_bit(temp_1),.c_in(c_1_in),.c(c_1),.s(s_1),.c_out(c_1_out));
    assign c_2_in = c_1_out;
//华莱士树02
    wtree wtree_2(.num_bit(temp_2),.c_in(c_2_in),.c(c_2),.s(s_2),.c_out(c_2_out));
    assign c_3_in = c_2_out;
//华莱士树03
    wtree wtree_3(.num_bit(temp_3),.c_in(c_3_in),.c(c_3),.s(s_3),.c_out(c_3_out));
    assign c_4_in = c_3_out;
//华莱士树04
    wtree wtree_4(.num_bit(temp_4),.c_in(c_4_in),.c(c_4),.s(s_4),.c_out(c_4_out));
    assign c_5_in = c_4_out;
//华莱士树05
    wtree wtree_5(.num_bit(temp_5),.c_in(c_5_in),.c(c_5),.s(s_5),.c_out(c_5_out));
    assign c_6_in = c_5_out;
//华莱士树06
    wtree wtree_6(.num_bit(temp_6),.c_in(c_6_in),.c(c_6),.s(s_6),.c_out(c_6_out));
    assign c_7_in = c_6_out;
//华莱士树07
    wtree wtree_7(.num_bit(temp_7),.c_in(c_7_in),.c(c_7),.s(s_7),.c_out(c_7_out));
    assign c_8_in = c_7_out;
//华莱士树08
    wtree wtree_8(.num_bit(temp_8),.c_in(c_8_in),.c(c_8),.s(s_8),.c_out(c_8_out));
    assign c_9_in = c_8_out;
//华莱士树09
    wtree wtree_9(.num_bit(temp_9),.c_in(c_9_in),.c(c_9),.s(s_9),.c_out(c_9_out));
    assign c_10_in = c_9_out;
//华莱士树10
    wtree wtree_10(.num_bit(temp_10),.c_in(c_10_in),.c(c_10),.s(s_10),.c_out(c_10_out));
    assign c_11_in = c_10_out;
//华莱士树11
    wtree wtree_11(.num_bit(temp_11),.c_in(c_11_in),.c(c_11),.s(s_11),.c_out(c_11_out));
    assign c_12_in = c_11_out;
//华莱士树12
    wtree wtree_12(.num_bit(temp_12),.c_in(c_12_in),.c(c_12),.s(s_12),.c_out(c_12_out));
    assign c_13_in = c_12_out;
//华莱士树13
    wtree wtree_13(.num_bit(temp_13),.c_in(c_13_in),.c(c_13),.s(s_13),.c_out(c_13_out));
    assign c_14_in = c_13_out;
//华莱士树14
    wtree wtree_14(.num_bit(temp_14),.c_in(c_14_in),.c(c_14),.s(s_14),.c_out(c_14_out));
    assign c_15_in = c_14_out;
//华莱士树15
    wtree wtree_15(.num_bit(temp_15),.c_in(c_15_in),.c(c_15),.s(s_15),.c_out(c_15_out));
    assign c_16_in = c_15_out;
//华莱士树16
    wtree wtree_16(.num_bit(temp_16),.c_in(c_16_in),.c(c_16),.s(s_16),.c_out(c_16_out));
    assign c_17_in = c_16_out;
//华莱士树17
    wtree wtree_17(.num_bit(temp_17),.c_in(c_17_in),.c(c_17),.s(s_17),.c_out(c_17_out));
    assign c_18_in = c_17_out;
//华莱士树18
    wtree wtree_18(.num_bit(temp_18),.c_in(c_18_in),.c(c_18),.s(s_18),.c_out(c_18_out));
    assign c_19_in = c_18_out;
//华莱士树19
    wtree wtree_19(.num_bit(temp_19),.c_in(c_19_in),.c(c_19),.s(s_19),.c_out(c_19_out));
    assign c_20_in = c_19_out;
//华莱士树20
    wtree wtree_20(.num_bit(temp_20),.c_in(c_20_in),.c(c_20),.s(s_20),.c_out(c_20_out));
    assign c_21_in = c_20_out;
//华莱士树21
    wtree wtree_21(.num_bit(temp_21),.c_in(c_21_in),.c(c_21),.s(s_21),.c_out(c_21_out));
    assign c_22_in = c_21_out; 
//华莱士树22
    wtree wtree_22(.num_bit(temp_22),.c_in(c_22_in),.c(c_22),.s(s_22),.c_out(c_22_out));
    assign c_23_in = c_22_out;
//华莱士树23
    wtree wtree_23(.num_bit(temp_23),.c_in(c_23_in),.c(c_23),.s(s_23),.c_out(c_23_out));
    assign c_24_in = c_23_out;
//华莱士树24
    wtree wtree_24(.num_bit(temp_24),.c_in(c_24_in),.c(c_24),.s(s_24),.c_out(c_24_out));
    assign c_25_in = c_24_out;
//华莱士树25
    wtree wtree_25(.num_bit(temp_25),.c_in(c_25_in),.c(c_25),.s(s_25),.c_out(c_25_out));
    assign c_26_in = c_25_out;
//华莱士树26
    wtree wtree_26(.num_bit(temp_26),.c_in(c_26_in),.c(c_26),.s(s_26),.c_out(c_26_out));
    assign c_27_in = c_26_out;
//华莱士树27
    wtree wtree_27(.num_bit(temp_27),.c_in(c_27_in),.c(c_27),.s(s_27),.c_out(c_27_out));
    assign c_28_in = c_27_out;
//华莱士树28
    wtree wtree_28(.num_bit(temp_28),.c_in(c_28_in),.c(c_28),.s(s_28),.c_out(c_28_out));
    assign c_29_in = c_28_out;
//华莱士树29
    wtree wtree_29(.num_bit(temp_29),.c_in(c_29_in),.c(c_29),.s(s_29),.c_out(c_29_out));
    assign c_30_in = c_29_out;
//华莱士树30
    wtree wtree_30(.num_bit(temp_30),.c_in(c_30_in),.c(c_30),.s(s_30),.c_out(c_30_out));
    assign c_31_in = c_30_out;
//华莱士树31
    wtree wtree_31(.num_bit(temp_31),.c_in(c_31_in),.c(c_31),.s(s_31),.c_out(c_31_out));
    assign c_32_in = c_31_out;
//华莱士树32
    wtree wtree_32(.num_bit(temp_32),.c_in(c_32_in),.c(c_32),.s(s_32),.c_out(c_32_out));
    assign c_33_in = c_32_out;
//华莱士树33
    wtree wtree_33(.num_bit(temp_33),.c_in(c_33_in),.c(c_33),.s(s_33),.c_out(c_33_out));
    assign c_34_in = c_33_out;
//华莱士树34
    wtree wtree_34(.num_bit(temp_34),.c_in(c_34_in),.c(c_34),.s(s_34),.c_out(c_34_out));
    assign c_35_in = c_34_out;
//华莱士树35
    wtree wtree_35(.num_bit(temp_35),.c_in(c_35_in),.c(c_35),.s(s_35),.c_out(c_35_out));
    assign c_36_in = c_35_out;
//华莱士树36
    wtree wtree_36(.num_bit(temp_36),.c_in(c_36_in),.c(c_36),.s(s_36),.c_out(c_36_out));
    assign c_37_in = c_36_out;
//华莱士树37
    wtree wtree_37(.num_bit(temp_37),.c_in(c_37_in),.c(c_37),.s(s_37),.c_out(c_37_out));
    assign c_38_in = c_37_out;
//华莱士树38
    wtree wtree_38(.num_bit(temp_38),.c_in(c_38_in),.c(c_38),.s(s_38),.c_out(c_38_out));
    assign c_39_in = c_38_out;
//华莱士树39
    wtree wtree_39(.num_bit(temp_39),.c_in(c_39_in),.c(c_39),.s(s_39),.c_out(c_39_out));
    assign c_40_in = c_39_out;
//华莱士树40
    wtree wtree_40(.num_bit(temp_40),.c_in(c_40_in),.c(c_40),.s(s_40),.c_out(c_40_out));
    assign c_41_in = c_40_out;
//华莱士树41
    wtree wtree_41(.num_bit(temp_41),.c_in(c_41_in),.c(c_41),.s(s_41),.c_out(c_41_out));
    assign c_42_in = c_41_out;
//华莱士树42
    wtree wtree_42(.num_bit(temp_42),.c_in(c_42_in),.c(c_42),.s(s_42),.c_out(c_42_out));
    assign c_43_in = c_42_out;
//华莱士树43
    wtree wtree_43(.num_bit(temp_43),.c_in(c_43_in),.c(c_43),.s(s_43),.c_out(c_43_out));
    assign c_44_in = c_43_out;
//华莱士树44
    wtree wtree_44(.num_bit(temp_44),.c_in(c_44_in),.c(c_44),.s(s_44),.c_out(c_44_out));
    assign c_45_in = c_44_out;
//华莱士树45
    wtree wtree_45(.num_bit(temp_45),.c_in(c_45_in),.c(c_45),.s(s_45),.c_out(c_45_out));
    assign c_46_in = c_45_out;
//华莱士树46
    wtree wtree_46(.num_bit(temp_46),.c_in(c_46_in),.c(c_46),.s(s_46),.c_out(c_46_out));
    assign c_47_in = c_46_out;
//华莱士树47
    wtree wtree_47(.num_bit(temp_47),.c_in(c_47_in),.c(c_47),.s(s_47),.c_out(c_47_out));
    assign c_48_in = c_47_out;
//华莱士树48
    wtree wtree_48(.num_bit(temp_48),.c_in(c_48_in),.c(c_48),.s(s_48),.c_out(c_48_out));
    assign c_49_in = c_48_out;
//华莱士树49
    wtree wtree_49(.num_bit(temp_49),.c_in(c_49_in),.c(c_49),.s(s_49),.c_out(c_49_out));
    assign c_50_in = c_49_out;
//华莱士树50
    wtree wtree_50(.num_bit(temp_50),.c_in(c_50_in),.c(c_50),.s(s_50),.c_out(c_50_out));
    assign c_51_in = c_50_out;
//华莱士树51
    wtree wtree_51(.num_bit(temp_51),.c_in(c_51_in),.c(c_51),.s(s_51),.c_out(c_51_out));
    assign c_52_in = c_51_out;
//华莱士树52
    wtree wtree_52(.num_bit(temp_52),.c_in(c_52_in),.c(c_52),.s(s_52),.c_out(c_52_out));
    assign c_53_in = c_52_out;
//华莱士树53
    wtree wtree_53(.num_bit(temp_53),.c_in(c_53_in),.c(c_53),.s(s_53),.c_out(c_53_out));
    assign c_54_in = c_53_out;
//华莱士树54
    wtree wtree_54(.num_bit(temp_54),.c_in(c_54_in),.c(c_54),.s(s_54),.c_out(c_54_out));
    assign c_55_in = c_54_out;
//华莱士树55
    wtree wtree_55(.num_bit(temp_55),.c_in(c_55_in),.c(c_55),.s(s_55),.c_out(c_55_out));
    assign c_56_in = c_55_out;
//华莱士树56
    wtree wtree_56(.num_bit(temp_56),.c_in(c_56_in),.c(c_56),.s(s_56),.c_out(c_56_out));
    assign c_57_in = c_56_out;
//华莱士树57
    wtree wtree_57(.num_bit(temp_57),.c_in(c_57_in),.c(c_57),.s(s_57),.c_out(c_57_out));
    assign c_58_in = c_57_out;
//华莱士树58
    wtree wtree_58(.num_bit(temp_58),.c_in(c_58_in),.c(c_58),.s(s_58),.c_out(c_58_out));
    assign c_59_in = c_58_out;
//华莱士树59
    wtree wtree_59(.num_bit(temp_59),.c_in(c_59_in),.c(c_59),.s(s_59),.c_out(c_59_out));
    assign c_60_in = c_59_out;
//华莱士树60
    wtree wtree_60(.num_bit(temp_60),.c_in(c_60_in),.c(c_60),.s(s_60),.c_out(c_60_out));
    assign c_61_in = c_60_out;
//华莱士树61
    wtree wtree_61(.num_bit(temp_61),.c_in(c_61_in),.c(c_61),.s(s_61),.c_out(c_61_out));
    assign c_62_in = c_61_out;
//华莱士树62
    wtree wtree_62(.num_bit(temp_62),.c_in(c_62_in),.c(c_62),.s(s_62),.c_out(c_62_out));
    assign c_63_in = c_62_out;
//华莱士树63
    wtree wtree_63(.num_bit(temp_63),.c_in(c_63_in),.c(c_63),.s(s_63),.c_out(c_63_out));

//加法器的输入
    wire [63:0] left_num;
    wire [63:0] right_num;
    assign left_num = {c_62,c_61,c_60,c_59,c_58,c_57,c_56,c_55,c_54,c_53,c_52,c_51,c_50,c_49,c_48,c_47,c_46,c_45,c_44,c_43,c_42,c_41,c_40,c_39,c_38,c_37,c_36,c_35,c_34,c_33,c_32,c_31,c_30,c_29,c_28,c_27,c_26,c_25,c_24,c_23,c_22,c_21,c_20,c_19,c_18,c_17,c_16,c_15,c_14,c_13,c_12,c_11,c_10,c_9,c_8,c_7,c_6,c_5,c_4,c_3,c_2,c_1,c_0,C14};
    assign right_num = {s_63,s_62,s_61,s_60,s_59,s_58,s_57,s_56,s_55,s_54,s_53,s_52,s_51,s_50,s_49,s_48,s_47,s_46,s_45,s_44,s_43,s_42,s_41,s_40,s_39,s_38,s_37,s_36,s_35,s_34,s_33,s_32,s_31,s_30,s_29,s_28,s_27,s_26,s_25,s_24,s_23,s_22,s_21,s_20,s_19,s_18,s_17,s_16,s_15,s_14,s_13,s_12,s_11,s_10,s_9,s_8,s_7,s_6,s_5,s_4,s_3,s_2,s_1,s_0};
//计算�???????终结�???????
    //assign result = (!resetn)?64'b0:(left_num + right_num +{C15,1'b0,C14,1'b0,C13,1'b0,C12,1'b0,C11,1'b0,C10,1'b0,C9,1'b0,C8,1'b0,C7,1'b0,C6,1'b0,C5,1'b0,C4,1'b0,C3,1'b0,C2,1'b0,C1,1'b0,C0,1'b0});
    assign result = (!resetn)?64'b0:(left_num + right_num + C15);
endmodule
