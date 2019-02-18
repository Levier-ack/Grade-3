`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file(
	input wire clk,
	input wire rst,
	input wire [`ADDR_WIDTH - 1:0] waddr,
	input wire [`ADDR_WIDTH - 1:0] raddr1,
	input wire [`ADDR_WIDTH - 1:0] raddr2,
	input wire wen,
	input wire [`DATA_WIDTH - 1:0] Wdata,
	output wire [`DATA_WIDTH - 1:0] rdata1,
	output wire [`DATA_WIDTH - 1:0] rdata2
);

	
	reg [`DATA_WIDTH - 1:0] r [`DATA_WIDTH - 1:0];
	always@(posedge clk)
	begin
		if(rst)
		begin 
         r[0] <= 32'b0;
         r[1] <= 32'b0;
         r[2] <= 32'b0;
         r[3] <= 32'b0;
         r[4] <= 32'b0;
         r[5] <= 32'b0;
         r[6] <= 32'b0;
         r[7] <= 32'b0;
         r[8] <= 32'b0;
         r[9] <= 32'b0;
         r[10] <= 32'b0;
         r[11] <= 32'b0;
         r[12] <= 32'b0;
         r[13] <= 32'b0;
         r[14] <= 32'b0;
         r[15] <= 32'b0;
         r[16] <= 32'b0;
         r[17] <= 32'b0;
         r[18] <= 32'b0;
         r[19] <= 32'b0;
         r[20] <= 32'b0;
         r[21] <= 32'b0;
         r[22] <= 32'b0;
         r[23] <= 32'b0;
         r[24] <= 32'b0;
         r[25] <= 32'b0;
         r[26] <= 32'b0;
         r[27] <= 32'b0;
         r[28] <= 32'b0;
         r[29] <= 32'b0;
         r[30] <= 32'b0;
         r[31] <= 32'b0;

		end
		else
			begin
				if(wen)
				r[waddr] <= Wdata;
				else
					;
			end
	end


	assign rdata1 = (raddr1 == 0)?0:r[raddr1];
	assign rdata2 = (raddr2 == 0)?0:r[raddr2];
endmodule