`timescale 10 ns / 1 ns

`define DATA_WIDTH 32

module alu(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALUop,
    
    output [31:0] Result
);

    wire op_add;//加法
    wire op_sub;//减法
    wire op_slt;//有符号比�???
    wire op_sltu;//无符号比�???
    wire op_and;//按位�???
    wire op_nor;//按位或非
    wire op_or;//按位�???
    wire op_xor;//按位异或
    wire op_sll;//逻辑左移
    wire op_srl;//逻辑右移
    wire op_sra;//算术右移
    wire op_lui;//高位加载
    wire no_inst;

//ALU操作
    assign op_add  = (ALUop == 4'd0);
    assign op_sub  = (ALUop == 4'd1);
    assign op_slt  = (ALUop == 4'd2);
    assign op_sltu = (ALUop == 4'd3);
    assign op_and  = (ALUop == 4'd4);
    assign op_nor  = (ALUop == 4'd5);
    assign op_or   = (ALUop == 4'd6);
    assign op_xor  = (ALUop == 4'd7);
    assign op_sll  = (ALUop == 4'd8);
    assign op_srl  = (ALUop == 4'd9);
    assign op_sra  = (ALUop == 4'd10);
    assign op_lui  = (ALUop == 4'd11);
    assign no_inst = (ALUop[3] & ALUop[2]);
//result寄存�???
    wire [31:0] add_sub_result;
    wire [31:0] slt_result;
    wire [31:0] sltu_result;
    wire [31:0] and_result;
    wire [31:0] nor_result;
    wire [31:0] or_result;
    wire [31:0] xor_result;
    wire [31:0] sll_result;
    wire [63:0] sr64_result;
    wire [31:0] sr_result;
    wire [31:0] lui_result;

//逻辑运算
    assign and_result = A & B;
    assign or_result  = A | B;
    assign nor_result = ~(A | B);
    assign xor_result = A ^ B;
    assign lui_result = {B[15:0], 16'b0}; 

//加减运算
    wire [32:0] adder_a;
    wire [32:0] adder_b;
    wire adder_cin;
    wire [31:0] adder_result;
    wire adder_cout;

    assign adder_a = A;
    assign adder_b = B ^ {32{op_sub | op_slt | op_sltu}};
    assign adder_cin = op_sub|op_slt|op_sltu;
    assign {adder_cout,adder_result} = adder_a + adder_b + adder_cin;
//加减结果
    assign add_sub_result = adder_result;
//比较结果
    assign slt_result[31:1] = 31'b0;
    assign slt_result[0] = (A[31]&~B[31]) | (~(A[31]^B[31])) & adder_result[31];

    assign sltu_result[31:1] = 31'b0;
    assign sltu_result[0] = ~adder_cout;

//左移
    assign sll_result = B << A[4:0];
//右移
    assign sr64_result = {{32{op_sra & B[31]}},B[31:0]} >> A[4:0]; 
    assign sr_result = sr64_result[31:0];

//结果输出
    assign Result = ({32{op_add | op_sub}} & add_sub_result)
                |({32{op_slt}}         & slt_result)
                |({32{op_sltu}}        & sltu_result)
                |({32{op_and}}         & and_result)
                |({32{op_nor}}         & nor_result)
                |({32{op_or}}          & or_result)
                |({32{op_xor}}         & xor_result)
                |({32{op_sll}}         & sll_result)
                |({32{op_srl|op_sra}}  & sr_result)
                |({32{op_lui}}         & lui_result)
                |({32{no_inst}});

endmodule 