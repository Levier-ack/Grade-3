`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/04 13:56:51
// Design Name: 
// Module Name: div
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


module div(
    input div_clk,
    input resetn,
    input div,
    input div_signed,
    input [31:0] x,
    input [31:0] y,
    output reg [31:0] s,
    output reg [31:0] r,
    output reg complete
    );
    //取绝对�?�和信号初始�???**************************************************************
    wire [31:0] x_abs; 
    wire [31:0] y_abs;
    reg [31:0] s_abs;
    wire [31:0] r_abs;
    reg [5:0]  div_count;
    reg [63:0] div_beichu;
    wire [31:0] div_chu;
    wire [32:0] sub;
    reg [32:0] sub_save;
    always@(posedge div_clk)begin
      if(~resetn)begin
        div_count <= (~div)?6'd0: 6'd0;
      end
      else begin
        div_count <= (~div | complete)?6'd0: div_count + 1;
      end
    end

    assign x_abs = (div_signed)?((x[31])?~x+1:x):x;
    assign y_abs = (div_signed)?((y[31])?~y+1:y):y;
    assign div_chu    = y_abs;
    assign sub   =  div_beichu[63:31] - {1'b0,div_chu};

    
    always@(posedge div_clk)begin
        if(!resetn)begin
            s_abs <= 32'b0;
            div_beichu <= 64'b0;
            sub_save <= 1'b0;
        end
        else if(div && ~complete)begin
            s_abs <= (div_count != 6'd0)?{s_abs[30:0],((sub[32])?1'b0:1'b1)}:32'b0;
            div_beichu <= (div_count == 6'b0)?{32'b0,x_abs}:((sub[32])?div_beichu:{sub,div_beichu[30:0]}) << 1;
            sub_save <= sub;
        end
    end
//迭代结束******************************************************************
    wire wire_complete = (div_count == 6'd33);
    always@(posedge div_clk)begin
        if(!resetn)begin
            complete <= 1'b0;
        end
        else if(div_count == 6'd0)begin
            complete <= 1'b0;
        end
        else if(div_count == 6'd33)begin
            complete <= 1'b1;
        end
    end
    assign r_abs    = (sub_save[32])?div_beichu[63:32]:sub_save[31:0];
    //�???终结�???******************************************************************
    // assign s = (div_signed)?((x[31]^y[31])?~(s_abs-1):s_abs):s_abs;
    // assign r = (div_signed)?((x[31])?~(r_abs-1):r_abs):r_abs;
    always@(posedge div_clk)begin
        if(!resetn)begin
            s <= 32'b0;
        end
        else if(wire_complete)begin
            s <= (div_signed)?((x[31]^y[31])?~(s_abs-1):s_abs):s_abs;
        end
    end
    always@(posedge div_clk)begin
        if(!resetn)begin
            r <= 32'b0;
        end
        else if(wire_complete)begin
            r <= (div_signed)?((x[31])?~(r_abs-1):r_abs):r_abs;
        end
    end
endmodule
