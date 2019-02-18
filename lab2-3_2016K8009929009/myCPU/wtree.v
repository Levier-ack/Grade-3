`timescale 1ns / 1ps
module wtree(
    input [16:0] num_bit,
    input [13:0] c_in,
    output c,
    output s,
    output [13:0] c_out
);

    wire c_out_0 = num_bit[16]&num_bit[15] | num_bit[16]&num_bit[14] | num_bit[15]&num_bit[14];
    wire c_out_1 = num_bit[13]&num_bit[12] | num_bit[13]&num_bit[11] | num_bit[12]&num_bit[11];
    wire c_out_2 = num_bit[10]&num_bit[9]  | num_bit[10]&num_bit[8]  | num_bit[9]&num_bit[8];
    wire c_out_3 = num_bit[7]&num_bit[6]   | num_bit[7]&num_bit[5]   | num_bit[6]&num_bit[5];
    wire c_out_4 = num_bit[4]&num_bit[3]   | num_bit[4]&num_bit[2]   | num_bit[3]&num_bit[2];
    
    wire s_0 = ~num_bit[16]&~num_bit[15]&num_bit[14] | ~num_bit[16]&num_bit[15]&~num_bit[14] | num_bit[16]&~num_bit[15]&~num_bit[14] | num_bit[16]&num_bit[15]&num_bit[14];
    wire s_1 = ~num_bit[13]&~num_bit[12]&num_bit[11] | ~num_bit[13]&num_bit[12]&~num_bit[11] | num_bit[13]&~num_bit[12]&~num_bit[11] | num_bit[13]&num_bit[12]&num_bit[11];
    wire s_2 = ~num_bit[10]&~num_bit[9]&num_bit[8]   | ~num_bit[10]&num_bit[9]&~num_bit[8]   | num_bit[10]&~num_bit[9]&~num_bit[8]   | num_bit[10]&num_bit[9]&num_bit[8];
    wire s_3 = ~num_bit[7]&~num_bit[6]&num_bit[5]    | ~num_bit[7]&num_bit[6]&~num_bit[5]    | num_bit[7]&~num_bit[6]&~num_bit[5]    | num_bit[7]&num_bit[6]&num_bit[5];
    wire s_4 = ~num_bit[4]&~num_bit[3]&num_bit[2]    | ~num_bit[4]&num_bit[3]&~num_bit[2]    | num_bit[4]&~num_bit[3]&~num_bit[2]    | num_bit[4]&num_bit[3]&num_bit[2];


    wire c_out_5 = s_0&s_1 | s_0&s_2 | s_1&s_2;
    wire c_out_6 = s_3&s_4 | s_3&num_bit[1] | s_4&num_bit[1];
    wire c_out_7 = num_bit[0]&c_in[0] | num_bit[0]&c_in[1] | c_in[0]&c_in[1];
    wire c_out_8 = c_in[2]&c_in[3] | c_in[2]&c_in[4] | c_in[3]&c_in[4];

    wire s_5 = ~s_0&~s_1&s_2 | ~s_0&s_1&~s_2 | s_0&~s_1&~s_2 | s_0&s_1&s_2;
    wire s_6 = ~s_3&~s_4&num_bit[1] | ~s_3&s_4&~num_bit[1] | s_3&~s_4&~num_bit[1] | s_3&s_4&num_bit[1];
    wire s_7 = ~num_bit[0]&~c_in[0]&c_in[1] | ~num_bit[0]&c_in[0]&~c_in[1] | num_bit[0]&~c_in[0]&~c_in[1] | num_bit[0]&c_in[0]&c_in[1];
    wire s_8 = ~c_in[2]&~c_in[3]&c_in[4] | ~c_in[2]&c_in[3]&~c_in[4] | c_in[2]&~c_in[3]&~c_in[4] | c_in[2]&c_in[3]&c_in[4];

    
    wire c_out_9 = s_5&s_6 | s_5&s_7 | s_6&s_7;
    wire c_out_10 = s_8&c_in[5] | s_8&c_in[6] | c_in[5]&c_in[6];

    wire s_9 = ~s_5&~s_6&s_7 | ~s_5&s_6&~s_7 | s_5&~s_6&~s_7 | s_5&s_6&s_7;
    wire s_10 = ~s_8&~c_in[5]&c_in[6] | ~s_8&c_in[5]&~c_in[6] | s_8&~c_in[5]&~c_in[6] | s_8&c_in[5]&c_in[6];

    
    wire c_out_11 = s_9&s_10 | s_9&c_in[7] | s_10&c_in[7];
    wire c_out_12 = c_in[8]&c_in[9] | c_in[8]&c_in[10] | c_in[9]&c_in[10];

    wire s_11 = ~s_9&~s_10&c_in[7] | ~s_9&s_10&~c_in[7] | s_9&~s_10&~c_in[7] | s_9&s_10&c_in[7];
    wire s_12 = ~c_in[8]&~c_in[9]&c_in[10] | ~c_in[8]&c_in[9]&~c_in[10] | c_in[8]&~c_in[9]&~c_in[10] | c_in[8]&c_in[9]&c_in[10];


    wire c_out_13 = s_11&s_12 | s_11&c_in[11] | s_12&c_in[11];

    wire s_13 = ~s_11&~s_12&c_in[11] | ~s_11&s_12&~c_in[11] | s_11&~s_12&~c_in[11] | s_11&s_12&c_in[11];


    assign c = s_13&c_in[12] | s_13&c_in[13] | c_in[12]&c_in[13];

    assign s = ~s_13&~c_in[12]&c_in[13] | ~s_13&c_in[12]&~c_in[13] | s_13&~c_in[12]&~c_in[13] | s_13&c_in[12]&c_in[13];
    assign c_out = {c_out_13,c_out_12,c_out_11,c_out_10,c_out_9,c_out_8,c_out_7,c_out_6,c_out_5,c_out_4,c_out_3,c_out_2,c_out_1,c_out_0};

endmodule