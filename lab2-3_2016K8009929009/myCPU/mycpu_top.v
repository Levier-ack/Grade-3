`timescale 10ns / 1ns


module mycpu_top(
    input resetn,
    input clk,

    //Instruction channel
    output inst_sram_en,
    output [3:0] inst_sram_wen,
    output [31:0] inst_sram_addr,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    //data channel
    output data_sram_en,
    output [3:0] data_sram_wen,
    output [31:0] data_sram_addr,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,
    //debug channel
    output [31:0] debug_wb_pc,
    output [3:0] debug_wb_rf_wen,
    output [4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);


    parameter IF  = 5'b00001;
    parameter ID  = 5'b00010;
    parameter EX  = 5'b00100;
    parameter MEM = 5'b01000;
    parameter WB  = 5'b10000;
//ID寄存器组*************************************************************************
    //reg [4:0] ID_rs;
    //reg [4:0] ID_rt;
//EX寄存器组*************************************************************************
    reg E_datafromM;
    reg E_write_reg;
    reg E_acs_mem;
    reg [4:0] E_rd;
    reg [3:0] E_aluop;
    reg [31:0] E_rdata_1;
    reg [31:0] E_rdata_2; 
    reg E_reg_imte;
    reg [31:0] E_sw_data;
    reg E_write_mem;
    reg [4:0] Eraddr_1;
    reg [4:0] Eraddr_2; 
    reg E_lw_use;
    reg E_inst_beq;
    reg E_inst_bne;  
    reg [31:0] E_branch_reg_1;
    reg [31:0] E_branch_reg_2;
    reg [31:0] E_branch_reg;
    reg [31:0] E_alu_left;
    reg [31:0] E_alu_right;
    reg E_reg_ra;
    reg E_div;
    reg E_mul;
    reg E_mul_sign;
    reg E_f_HI;
    reg E_f_LO;
    reg E_t_hi;
    reg E_t_lo;
    reg E_lb;
    reg E_lbu;
    reg E_lh;
    reg E_lhu;
    reg E_lwl;
    reg E_lwr;
    reg E_sb;
    reg E_sh;
    reg E_swl;
    reg E_swr;
    reg [31:0] Erdata_2;
//MEM寄存器组************************************************************************
    reg M_datafromM;
    reg M_write_reg;
    reg M_reg_ra;
    reg [4:0] M_rd;
    reg [31:0] M_ra_result;
    reg [31:0] M_write_result;
    reg M_lw_use;
    reg [31:0] M_alu_result;
    reg M_div;
    reg M_mul;
    reg M_complete;
    reg M_f_hi;
    reg M_f_lo;
    reg M_t_hi;
    reg M_t_lo;
    reg [1:0] M_ea;
    reg M_lw_lw;
    reg M_lb;
    reg M_lbu;
    reg M_lh;
    reg M_lhu;
    reg M_lwl;
    reg M_lwr;
    reg M_sb;
    reg M_sh;
    reg M_swl;
    reg M_swr;
    reg [31:0] Mrdata_2;
//WB寄存器组**************************************************************************
    reg [4:0] W_rd;
    reg W_write_reg;
    reg W_datafromM;
    reg [31:0] W_write_data;
    reg [31:0] W_write_result;
    reg [31:0] W_ra_data;
    reg [31:0] W_M_data;
    reg W_reg_ra;
    reg W_div;
    reg W_complete;
    reg W_mul;
//PC计数�???????????????????????????????????????????????????????????????????**************************************************************************
    reg [31:0] PC;
    reg [31:0] PC_1;
    reg [31:0] PC_2;
    reg [31:0] PC_3;
    reg [31:0] PC_4;
    reg [31:0] PC_5;
//指令寄存�???????????????????????????????????????????????????????????????????*************************************************************************
    wire [5:0] instr_1;
    wire [5:0] instr_2;
    wire [4:0] instr_3;
    wire [4:0] instr_4;
    wire [9:0] instr_5;
    reg [31:0] Instruction;
//ALU端口*****************************************************************************
    //wire [31:0] data_A;
    //wire [31:0] data_B;
    wire  [31:0] result;
    wire  [3:0] aluop;
    wire  [31:0] alu_left;
    wire  [31:0] alu_right;
//regfile端口*************************************************************************
    wire rst;
    wire [4:0] waddr;
    wire [4:0] raddr_1;
    wire [4:0] raddr_2;
    wire reg_write;
    wire [31:0] write_data;
    wire [31:0] rdata_1;
    wire [31:0] rdata_2;
//HI和LO寄存�??????************************************************************************
    reg [31:0] HI;
    reg [31:0] LO;
    wire [31:0] wire_hi;
    wire [31:0] wire_lo;
//乘法器端�??????**************************************************************************
    wire cpu_mul    = inst_mult | inst_multu;
    wire mul_sign   = cpu_mul & inst_mult;
    wire [63:0] mul_result;
//除法器端�??????**************************************************************************
    wire cpu_div    = inst_div | inst_divu;
    wire div_sign   = cpu_div & inst_div;
    wire complete;
    wire [31:0] cpu_beichu;
    wire [31:0] cpu_chu;
    wire [31:0] s;
    wire [31:0] r;
//调用ALU和regfile和乘法器和除法器
    reg_file reg_file(.clk(clk),.rst(rst),.waddr(waddr),.raddr1(raddr_1),.raddr2(raddr_2),.wen(reg_write),.wdata(write_data),.rdata1(rdata_1),.rdata2(rdata_2));
	  alu alu(.A(E_rdata_1),.B(E_rdata_2),.ALUop(E_aluop),.Result(result)); 
    div div(.div_clk(clk),.resetn(resetn),.div(cpu_div),.div_signed(div_sign),.x(cpu_beichu),.y(cpu_chu),.s(s),.r(r),.complete(complete));
    mul mul(.mul_clk(clk),.resetn(resetn),.mul_signed(E_mul_sign),.x(E_rdata_1),.y(E_rdata_2),.result(mul_result));
//debug信号
    assign debug_wb_pc = (M_div && E_div)?PC_3:PC_4;
    assign debug_wb_rf_wdata = ((W_reg_ra)?PC_4 + 8:(W_datafromM)?W_M_data:W_write_data);
    assign debug_wb_rf_wen   = (W_div)?4'b0:{4{W_write_reg}};
    assign debug_wb_rf_wnum  = W_rd;

//写使能和写数据为0
    assign inst_sram_en     = (rst)?0:1;
    assign inst_sram_wen    = 4'b0;
    assign inst_sram_wdata  = 32'b0;
//端口信号
    wire [31:0] data_sram_rdata_true;
    wire [31:0] data_sram_half;
    wire [3:0] data_strb_half;
    wire [3:0] data_strb_b;
    wire [31:0] data_write_half;
    wire [31:0] data_write_b;
    wire [1:0] ea;
    assign inst_sram_addr   = PC;
    assign data_sram_wdata  = (data_sram_en && E_write_mem)?(E_swl | E_swr)?data_write_half:((E_sb | E_sh)?data_write_b:E_branch_reg):32'b0;
    assign data_sram_wen    = (data_sram_en && E_write_mem)?((E_sb | E_sh)?data_strb_b:((E_swl | E_swr)?data_strb_half:4'b1111)):4'b0;
    assign data_sram_addr   = (data_sram_en)?(((E_write_mem)?E_rdata_1 + E_alu_right:((M_lw_lw)?write_data + E_alu_right:result))):32'b0;
    assign ea = data_sram_addr[1:0];
    assign data_sram_en     = E_acs_mem;
    assign data_sram_rdata_true = (M_lb | M_lbu)?((M_lb)?((M_ea==2'd0)?{{24{data_sram_rdata[7]}},data_sram_rdata[7:0]}:((M_ea==2'd1)?{{24{data_sram_rdata[15]}},data_sram_rdata[15:8]}:((M_ea==2'd2)?{{24{data_sram_rdata[23]}},data_sram_rdata[23:16]}:{{24{data_sram_rdata[31]}},data_sram_rdata[31:24]}))):((M_ea==2'd0)?{24'b0,data_sram_rdata[7:0]}:((M_ea==2'd1)?{24'b0,data_sram_rdata[15:8]}:((M_ea==2'd2)?{24'b0,data_sram_rdata[23:16]}:{24'b0,data_sram_rdata[31:24]})))):
                                  (M_lh | M_lhu)?((M_lh)?(M_ea[1]?{{16{data_sram_rdata[31]}},data_sram_rdata[31:16]}:{{16{data_sram_rdata[15]}},data_sram_rdata[15:0]}):(M_ea[1]?{16'b0,data_sram_rdata[31:16]}:{16'b0,data_sram_rdata[15:0]})):
                                  data_sram_rdata;
    assign rst = ~resetn;
    assign data_strb_half = (E_swl | E_swr)?((E_swl)?((ea==2'd0)?4'b0001:((ea==2'd1)?4'b0011:((ea==2'd2)?4'b0111:4'b1111))):((ea==2'd0)?4'b1111:((ea==2'd1)?4'b1110:((ea==2'd2)?4'b1100:4'b1000)))):4'b0;
    assign data_write_half = (E_swl | E_swr)?((E_swl)?((ea==2'd0)?{24'b0,E_branch_reg[31:24]}:((ea==2'd1)?{16'b0,E_branch_reg[31:16]}:((ea==2'd2)?{8'b0,E_branch_reg[31:8]}:E_branch_reg))):((ea==2'd0)?E_branch_reg:((ea==2'd1)?{E_branch_reg[23:0],8'b0}:((ea==2'd2)?{E_branch_reg[15:0],16'b0}:{E_branch_reg[7:0],24'b0})))):E_branch_reg;
    assign data_strb_b    = (E_sb | E_sh)?((E_sb)?((ea==2'd0)?4'b0001:((ea==2'd1)?4'b0010:((ea==2'd2)?4'b0100:4'b1000))):((ea[1])?4'b1100:4'b0011)):4'b0;
    assign data_write_b   = (E_sb | E_sh)?((E_sb)?((ea==2'd0)?{24'b0,E_branch_reg[7:0]}:((ea==2'd1)?{16'b0,E_branch_reg[7:0],8'b0}:((ea==2'd2)?{8'b0,E_branch_reg[7:0],16'b0}:{E_branch_reg[7:0],24'b0}))):((ea[1])?{E_branch_reg[15:0],16'b0}:{16'b0,E_branch_reg[15:0]})):E_branch_reg;
    //*******************************************************************************
    wire [31:0] branch_reg_1;
    wire [31:0] branch_reg_2;
    reg IF_valid;
    reg ID_valid;
    reg EX_valid;
    reg MEM_valid;
    reg WB_valid;
    //IF*****************************************************************************
    wire IF_allowin;
    wire IF_readygo;
    wire IFtoID_valid;
    assign IF_allowin = ~rst;
    assign IF_readygo = IF_valid;
    assign IFtoID_valid = IF_valid && IF_readygo;
    always@(posedge clk)begin
      if(!resetn)begin
        IF_valid <= 1'b0;
      end
      else if(IF_allowin)begin
        IF_valid <= inst_sram_en;
      end

      if(!resetn)begin
        Instruction <= 32'b0;
      end
      else if(inst_sram_en && IF_allowin)begin
        Instruction <= inst_sram_rdata;
        //ID_rs <= raddr_1;
        //ID_rt <= raddr_2;
      end
    end
    //ID*****************************************************************************
    wire ID_allowin;
    wire ID_readygo;
    wire IDtoEX_valid;
    //assign ID_allowin = ~rst && (ID_rs != E_rd) && (ID_rs != M_rd) && (ID_rs != M_rd) && (ID_rt != E_rd) && (ID_rt != M_rd) && (ID_rt != W_rd);阻塞
    assign ID_allowin = ~rst & (((inst_beq | inst_bne) & E_datafromM & (E_rd == instr_5[4:0] | E_rd == instr_5[9:5]))? 1'b0: 1'b1);
    assign ID_readygo = ID_valid;
    assign IDtoEX_valid = ID_valid && ID_readygo;
    //assign IDtoEX_valid = ID_valid && ID_readygo;
    always@(posedge clk)begin
      if(!resetn)begin
        ID_valid <= 1'b0;
      end
      else if(ID_allowin)begin
        ID_valid <= IFtoID_valid;
      end

      if(!resetn)begin
        E_datafromM <= 1'b0;
        E_rd        <= 5'b0;
        E_aluop     <= 4'b0;
        E_rdata_1   <= 32'b0;
        E_rdata_2   <= 32'b0;
        E_sw_data   <= 32'b0;
        E_reg_imte <= 1'b0;
        E_write_mem <= 1'b0;
        E_alu_left  <= 32'b0;
        E_alu_right <= 32'b0;
      end
      else if(IFtoID_valid && ID_allowin)begin
        E_datafromM <= datafromM;
        E_rd <= (reg_ra)?5'd31:((reg_rt) ?instr_5[4:0]:((~write_reg)?5'b0:instr_4));
        E_aluop <= aluop;
        //E_rdata_1 <= alu_left;
        E_rdata_1 <= (raddr_1 == E_rd && raddr_1 != 5'b0)?((E_f_HI | E_f_LO)?((E_f_HI)?wire_hi:wire_lo):result):
                      (raddr_1 == M_rd && raddr_1 != 5'b0)?((M_datafromM)?data_sram_rdata_true:((M_reg_ra)?W_ra_data:((M_f_lo | M_f_hi)?((M_f_lo)?LO:HI):M_alu_result))):
                      alu_left;
        //E_rdata_2 <= alu_right;
        E_rdata_2 <= (raddr_2 == E_rd && raddr_2 != 5'b0 && ~reg_rt)?((E_f_HI | E_f_LO)?((E_f_HI)?wire_hi:wire_lo):result):
                      (raddr_2 == M_rd && raddr_2 != 5'b0 && ~reg_rt && ~write_mem)?((M_datafromM)?data_sram_rdata_true:((M_f_hi | M_f_lo)?((M_f_hi)?HI:LO):M_alu_result)):
                      alu_right;
        //E_sw_data <= (write_mem)?rdata_2:32'b0;
        E_reg_imte <= reg_imte;
        E_write_mem <= write_mem;
        E_alu_left  <= (raddr_1 == E_rd && raddr_1 != 5'b0)?M_alu_result:
                      (raddr_1 == M_rd && raddr_1 != 5'b0)?((M_datafromM)?data_sram_rdata_true:M_alu_result):
                      alu_left;
        E_alu_right <= alu_right;
      end

      if(!resetn)begin
        E_lw_use <= 1'b0;
        Eraddr_1    <= 5'b0;
        Eraddr_2    <= 5'b0;
        E_inst_bne  <= 1'b0;
        E_acs_mem   <= 1'b0;
        E_inst_beq  <= 1'b0;
        E_branch_reg_1    <= 32'b0;
        E_branch_reg_2    <= 32'b0;
        E_write_reg <= 1'b0;
        E_div <= 1'b0;
        E_mul <= 1'b0;
        E_mul_sign <= 1'b0;
        E_f_HI <= 1'b0;
        E_f_LO <= 1'b0;
        E_t_hi      <= 1'b0;
        E_t_lo      <= 1'b0;
        E_lb <= 1'b0;
        E_lbu <= 1'b0;
        E_lh <= 1'b0;
        E_lhu <= 1'b0;
        E_lwl <= 1'b0;
        E_lwr <= 1'b0;
        E_sb <= 1'b0;
        E_sh <= 1'b0;
        E_swl <= 1'b0;
        E_swr <= 1'b0;
        Erdata_2 <= 32'b0;
      end
      else begin
        E_lw_use <= lw_use;
        Eraddr_1 <= raddr_1;
        Eraddr_2 <= raddr_2;
        E_inst_beq <= inst_beq;
        E_inst_bne <= inst_bne;
        E_branch_reg_1 <= branch_reg_1;
        E_branch_reg_2 <= branch_reg_2;
        E_branch_reg <= (inst_beq | inst_bne) & E_datafromM & (E_rd == instr_5[4:0] | E_rd == instr_5[9:5])?data_sram_rdata_true:
                        ((E_f_HI | E_f_LO)?((E_f_HI)?wire_hi:wire_lo):branch_reg_2);
        E_acs_mem <= acs_mem;
        E_write_reg <= write_reg;
        E_div <= cpu_div;
        E_mul <= cpu_mul;
        E_mul_sign <= mul_sign;
        E_f_HI <= inst_mfhi;
        E_f_LO <= inst_mflo;
        E_t_hi <= inst_mthi;
        E_t_lo <= inst_mtlo;
        E_lb <= inst_lb;
        E_lbu <= inst_lbu;
        E_lh <= inst_lh;
        E_lhu <= inst_lhu;
        E_lwl <= inst_lwl;
        E_lwr <= inst_lwr;
        E_sb <= inst_sb;
        E_sh <= inst_sh;
        E_swl <= inst_swl;
        E_swr <= inst_swr;
        Erdata_2 <= rdata_2;
      end
    end

    //EX*****************************************************************************
    wire EX_allowin;
    wire EX_readygo;
    wire EXtoMEM_valid;
    assign EX_allowin = ~rst;
    assign EX_readygo = EX_valid;
    assign EXtoMEM_valid = EX_valid && EX_readygo && IDtoEX_valid;
    always@(posedge clk)begin
      if(!resetn)begin
        EX_valid <= 1'b0;
      end
      else if(EX_allowin)begin
        EX_valid <= IDtoEX_valid;
      end

      if(!resetn)begin
        M_datafromM <= 1'b0;
        M_write_reg <= 1'b0;
        M_rd        <= 1'b0;
        M_ra_result <= 32'b0;
        M_write_result <= 32'b0;
        E_reg_ra  <= 1'b0;
        M_alu_result  <= 32'b0;
        M_complete <= 1'b0;
        M_f_hi <= 1'b0;
        M_f_lo <= 1'b0;
        M_mul <= 1'b0;
        M_div <= 1'b0;
        M_t_hi  <= 1'b0;
        M_t_lo  <= 1'b0;
        M_lb <= 1'b0;
        M_lbu <= 1'b0;
        M_lh <= 1'b0;
        M_lhu <= 1'b0;
        M_lwl <= 1'b0;
        M_lwr <= 1'b0;
        M_sb <= 1'b0;
        M_sh <= 1'b0;
        M_swl <= 1'b0;
        M_swr <= 1'b0;
        M_ea <= 2'b0;
        M_lw_lw <= 1'b0;
        Mrdata_2 <= 32'b0;
      end
      else if(IDtoEX_valid && EX_allowin)begin
        M_datafromM <= E_datafromM;
        M_write_reg <= E_write_reg;
        M_rd <= (M_div)?5'b0:E_rd;
        M_ra_result <= PC_1+8; 
        M_write_result <= (E_reg_imte | ~datafromM | E_write_mem | (E_aluop != 4'd12))?result:E_rdata_2;
        E_reg_ra <= reg_ra; 
        M_alu_result <= result;
        M_div <= E_div;
        M_mul <= E_mul;
        M_complete <= complete;
        M_f_hi <= E_f_HI;
        M_f_lo <= E_f_LO; 
        M_t_hi <= E_t_hi;
        M_t_lo <= E_t_lo;
        M_lb <= E_lb;
        M_lbu <= E_lbu;
        M_lh <= E_lh;
        M_lhu <= E_lhu;
        M_lwl <= E_lwl;
        M_lwr <= E_lwr;
        M_sb <= E_sb;
        M_sh <= E_sh;
        M_swl <= E_swl;
        M_swr <= E_swr;
        M_ea <= ea;
        M_lw_lw <= lw_lw;
        Mrdata_2 <= Erdata_2;
      end

      if(!resetn)begin
        M_lw_use <= 1'b0;
      end
      else begin
        M_lw_use <= E_lw_use;
      end
    end
    //MEM****************************************************************************
    wire MEM_allowin;
    wire MEM_readygo;
    wire MEMtoWB_valid;
    assign MEM_allowin = ~rst;
    assign MEM_readygo = MEM_valid;
    assign MEMtoWB_valid = MEM_valid && MEM_readygo && EXtoMEM_valid;
    always@(posedge clk)begin
      if(!resetn)begin
        MEM_valid <= 1'b0;
      end
      else if(MEM_allowin)begin
        MEM_valid <= EXtoMEM_valid;
      end

      if(!resetn)begin
        W_rd        <= 1'b0;
        W_write_reg <= 1'b0;
        W_ra_data   <= 32'b0;
        W_write_data <= 32'b0;
        W_datafromM <= 1'b0;
        M_reg_ra  <= 1'b0;
        W_M_data    <= 32'b0;
        W_div <= 1'b0;
        W_complete <= 1'b0;
        HI <= 32'b0;
        LO <= 32'b0;
        W_mul <= 1'b0;
      end
      else if(EXtoMEM_valid && MEM_allowin)begin
        W_rd <= M_rd;
        W_write_reg <= M_write_reg;
        W_ra_data <= M_ra_result;
        W_write_data <= (M_f_hi | M_f_lo)?((M_f_hi)?HI:LO):M_write_result;
        W_write_result <= M_write_result;
        W_datafromM <= M_datafromM;
        M_reg_ra <= E_reg_ra;
        W_M_data <= (M_lwl | M_lwr)?data_sram_half:data_sram_rdata_true;
        HI <= wire_hi;
        LO <= wire_lo;
        W_div <= M_div;
        W_complete <= M_complete;
        W_mul <= M_mul;
      end
    end
    //WB*****************************************************************************
    wire WB_allowin;
    wire WB_readygo;

    assign WB_allowin = ~rst;
    assign WB_readygo = WB_valid;

    always@(posedge clk)begin
      if(!resetn)begin
        WB_valid <= 1'b0;
      end
      else if(WB_allowin)begin
        WB_valid <= MEMtoWB_valid;
      end

      if(!resetn)begin
        W_reg_ra <= 1'b0;
      end
      else if(MEMtoWB_valid && MEM_valid)begin
        W_reg_ra <= M_reg_ra;
      end
    end
//PC更新*****************************************************************************
    always@(posedge clk)begin
      if(!resetn)begin
        PC <= 32'hbfc00000;
      end
      else if(IF_allowin)begin
        //PC <= (!pc_offset)? PC + 4:
        //                  (inst_beq)?((rdata_1 == rdata_2)?{{14{instr_4[4]}},instr_3,instr_2,2'b00} + PC + 4:PC + 4):
        //                    (inst_bne)?((rdata_1 != rdata_2)?{{14{instr_4[4]}},instr_3,instr_2,2'b00} + PC + 4:PC + 4):
        //                    (inst_jal)?{instr_1[5:2],instr_5,instr_4,instr_3,instr_2,2'b00}:rdata_1;
            if(pc_offset | E_lw_use)begin
              if(inst_beq | E_inst_beq)begin
                  if(inst_beq)begin
                    PC <= ((inst_beq | inst_bne) & E_datafromM & (E_rd == instr_5[4:0] | E_rd == instr_5[9:5]))?PC:((branch_reg_1 == branch_reg_2)?{{14{instr_4[4]}},instr_4,instr_3,instr_2,2'b00}+PC_1+4:PC + 4);
                  end
                  else begin
                    PC <= ((Instruction[25:21] == M_rd && branch_reg_1 != E_branch_reg_2) || (Instruction[20:16] == M_rd && E_branch_reg_1 != branch_reg_2))?{{14{Instruction[15]}},Instruction[15:0],2'b00}+PC_2+4:PC_1+4;
                  end
              end
              else if(inst_bne | E_inst_bne)begin
                  if(inst_bne)begin
                    PC <= ((inst_beq | inst_bne) & E_datafromM & (E_rd == instr_5[4:0] | E_rd == instr_5[9:5]))?PC:((branch_reg_1 != branch_reg_2)?{{14{instr_4[4]}},instr_4,instr_3,instr_2,2'b00}+PC_1+4:PC + 4);
                  end
                  else begin
                    PC <= ((Instruction[25:21] == M_rd && branch_reg_1 != E_branch_reg_2) || (Instruction[20:16] == M_rd && E_branch_reg_1 != branch_reg_2))?{{14{Instruction[15]}},Instruction[15:0],2'b00}+PC_2+4:PC_1+4; 
                  end
              end
              else if(inst_j)begin
                PC <= {PC_1[31:28],instr_5,instr_4,instr_3,instr_2,2'b00}; 
              end
              else if(inst_jal)begin
                PC <= {PC_1[31:28],instr_5,instr_4,instr_3,instr_2,2'b00};
              end
              else if(inst_jalr | inst_jr)begin
                PC <= branch_reg_1;
              end
              else begin     
                PC <= (inst_bgez | inst_bgezal)?((branch_reg_1[31]==1'b0)?{{14{instr_4[4]}},instr_4,instr_3,instr_2,2'b00}+PC_1+4:PC+4):
                                  (inst_bgtz)?((branch_reg_1[31]==1'b0 && branch_reg_1!=32'b0)?{{14{instr_4[4]}},instr_4,instr_3,instr_2,2'b00}+PC_1+4:PC+4):
                                  (inst_blez)?((branch_reg_1[31]==1'b1 || branch_reg_1==32'b0)?{{14{instr_4[4]}},instr_4,instr_3,instr_2,2'b00}+PC_1+4:PC+4):
                                  ((branch_reg_1[31]==1'b1)?{{14{instr_4[4]}},instr_4,instr_3,instr_2,2'b00}+PC_1+4:PC+4);
              end
            end
            else if(cpu_div | E_div)begin
              PC <= (complete | M_complete | W_complete)?((complete)?PC_5:((M_complete)?PC_5:PC+4)):((E_div)?PC:PC_1);
            end
            else begin
              PC <= PC + 4;
            end
      end
      else 
        ;
    end

    always@(posedge clk)begin
      if(!resetn)begin
        PC_1 <= 32'hbfc00000;
        PC_2 <= 32'hbfc00000;
        PC_3 <= 32'hbfc00000;
        PC_4 <= 32'hbfc00000;
      end
      //else if(IFtoID_valid && ID_allowin)begin
      else if(IFtoID_valid)begin
        PC_1 <= PC;
        PC_2 <= PC_1;
        PC_3 <= PC_2;
        PC_4 <= PC_3;
      end
    end

    always@(posedge clk)begin
      if(E_div && ~W_div)
        PC_5 <= PC_4;
      else
        PC_5 <= PC_5;
    end

//指令判断***************************************************************************
    wire inst_lui   = (inst_sram_rdata [31:26] == 6'b001111);
    wire inst_addu  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b100001);
    wire inst_addiu = (inst_sram_rdata [31:26] == 6'b001001);
    wire inst_subu  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b100011);
    wire inst_slt   = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b101010);
    wire inst_sltu  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b101011);
    wire inst_and   = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b100100);
    wire inst_or    = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b100101);
    wire inst_xor   = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b100110);
    wire inst_nor   = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b100111);
    wire inst_sll   = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b0);
    wire inst_srl   = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b000010);
    wire inst_sra   = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b000011);
    wire inst_lw    = (inst_sram_rdata [31:26] == 6'b100011);
    wire inst_sw    = (inst_sram_rdata [31:26] == 6'b101011);
    wire inst_beq   = (inst_sram_rdata [31:26] == 6'b000100);
    wire inst_bne   = (inst_sram_rdata [31:26] == 6'b000101);
    wire inst_jal   = (inst_sram_rdata [31:26] == 6'b000011);
    wire inst_jr    = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b001000);
    wire inst_add   = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b100000);
    wire inst_addi  = (inst_sram_rdata [31:26] == 6'b001000);
    wire inst_sub   = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b100010);
    wire inst_slti  = (inst_sram_rdata [31:26] == 6'b001010);
    wire inst_sltiu = (inst_sram_rdata [31:26] == 6'b001011);
    wire inst_andi  = (inst_sram_rdata [31:26] == 6'b001100);
    wire inst_ori   = (inst_sram_rdata [31:26] == 6'b001101);
    wire inst_xori  = (inst_sram_rdata [31:26] == 6'b001110);
    wire inst_sllv  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b000100);
    wire inst_srav  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b000111);
    wire inst_srlv  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b000110);
    wire inst_div   = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b011010);
    wire inst_divu  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b011011);
    wire inst_mult  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b011000);
    wire inst_multu = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b011001);
    wire inst_mfhi  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b010000);
    wire inst_mflo  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b010010);
    wire inst_mthi  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b010001);
    wire inst_mtlo  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b010011);
    wire inst_nop   =  inst_sram_rdata == 32'b0;
    wire inst_j     = (inst_sram_rdata [31:26] == 6'b000010);
    wire inst_bgez  = (inst_sram_rdata [31:26] == 6'b000001 && inst_sram_rdata [20:16] == 5'b00001);
    wire inst_bltz  = (inst_sram_rdata [31:26] == 6'b000001 && inst_sram_rdata [20:16] == 5'b00000);
    wire inst_bltzal= (inst_sram_rdata [31:26] == 6'b000001 && inst_sram_rdata [20:16] == 5'b10000);
    wire inst_bgezal= (inst_sram_rdata [31:26] == 6'b000001 && inst_sram_rdata [20:16] == 5'b10001);
    wire inst_bgtz  = (inst_sram_rdata [31:26] == 6'b000111);
    wire inst_blez  = (inst_sram_rdata [31:26] == 6'b000110);
    wire inst_jalr  = (inst_sram_rdata [31:26] == 6'b0 && inst_sram_rdata [5:0] == 6'b001001);
    wire inst_lb    = (inst_sram_rdata [31:26] == 6'b100000);
    wire inst_lbu   = (inst_sram_rdata [31:26] == 6'b100100);
    wire inst_lh    = (inst_sram_rdata [31:26] == 6'b100001);
    wire inst_lhu   = (inst_sram_rdata [31:26] == 6'b100101);
    wire inst_lwl   = (inst_sram_rdata [31:26] == 6'b100010);
    wire inst_lwr   = (inst_sram_rdata [31:26] == 6'b100110);
    wire inst_sb    = (inst_sram_rdata [31:26] == 6'b101000);
    wire inst_sh    = (inst_sram_rdata [31:26] == 6'b101001);
    wire inst_swl   = (inst_sram_rdata [31:26] == 6'b101010);
    wire inst_swr   = (inst_sram_rdata [31:26] == 6'b101110);
//control信号************************************************************************
    wire pc_offset  = inst_beq | inst_bne | inst_jal | inst_jr | inst_j | inst_jalr | inst_bgez | inst_bgtz | inst_bltzal | inst_bgezal | inst_bltz | inst_blez;
    wire reg_imte   = inst_addiu | inst_lui | inst_lw | inst_addi | inst_slti | inst_sltiu | inst_andi | inst_ori | inst_xori | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lwl | inst_lwr;//data_B数据来自立即�????????????????????????????????????????????????????????????????????
    wire datafromM  = inst_lw | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lwl | inst_lwr;//寄存器写入的数据不来自ALU
    wire reg_rt     = inst_addiu | inst_lw | inst_lui | inst_addi | inst_slti | inst_sltiu | inst_andi | inst_ori  | inst_xori | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lwl | inst_lwr;//目标寄存器是rt
    wire reg_ra     = inst_jal | inst_jalr | inst_bltzal | inst_bgezal;//目标寄存器是ra
    wire write_reg  = ~(inst_bltz | inst_blez | inst_bgtz | inst_bgez | inst_j | inst_beq | inst_bne | inst_sw | inst_nop | inst_div | inst_divu | inst_mult | inst_multu | inst_mthi | inst_mtlo | inst_sb | inst_sh | inst_swl | inst_swr);
    wire write_mem  = inst_sw | inst_sb | inst_sh | inst_swl | inst_swr;
    wire acs_mem    = inst_lw | inst_sw | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lwl | inst_lwr | inst_sb | inst_sh | inst_swl | inst_swr; 
    wire inst_move  = inst_sll | inst_sra | inst_srl | inst_andi | inst_ori | inst_xori;
    wire extend_u   = inst_andi | inst_ori | inst_xori;
    wire lw_use     = (inst_beq | inst_bne) & E_datafromM & (E_rd == instr_5[4:0] | E_rd == instr_5[9:5]);
    wire lw_lw      = E_datafromM & datafromM & (E_rd == instr_5[9:5]);
//ALU端口****************************************************************************
    assign aluop[0] = inst_lui | inst_subu | inst_sltu | inst_xor | inst_nor | inst_srl | inst_sub  | inst_sltiu | inst_xori | inst_srlv;
    assign aluop[1] = inst_lui | inst_slt  | inst_sltu | inst_or  | inst_xor | inst_sra | inst_slti | inst_sltiu | inst_ori  | inst_xori | inst_srav;
    assign aluop[2] = inst_and | inst_or   | inst_xor  | inst_nor | inst_beq | inst_bne | inst_jal  | inst_jr    | inst_andi | inst_ori  | inst_xori | inst_mfhi | inst_mflo | inst_mthi | inst_mtlo | inst_div | inst_divu | inst_mult | inst_multu | inst_j | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bltzal | inst_bgezal | inst_jalr;
    assign aluop[3] = inst_lui | inst_sll  | inst_srl  | inst_sra | inst_beq | inst_bne | inst_jal  | inst_jr    | inst_sllv | inst_srav | inst_srlv | inst_mfhi | inst_mflo | inst_mthi | inst_mtlo | inst_div | inst_divu | inst_mult | inst_multu | inst_j | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bltzal | inst_bgezal | inst_jalr;
    assign alu_left = (inst_move)?((extend_u)?rdata_1:instr_3):rdata_1;
    assign alu_right = (reg_imte || write_mem)?((extend_u)?{16'b0,instr_4,instr_3,instr_2}:{{16{instr_4[4]}},instr_4,instr_3,instr_2}):rdata_2;
     //assign data_A   = rdata_1;
    //assign data_B   = (reg_imte)?{{16{instr_4[4]}},instr_4,instr_3,instr_2}:rdata_2;
//regfile端口************************************************************************
    assign raddr_1  = instr_5[9:5];
    assign raddr_2  = instr_5[4:0]; 
    assign waddr    = M_rd;
    assign reg_write  = M_write_reg;
    //assign write_data = (reg_ra_2 )?W_ra_data:((W_datafromM)?data_sram_rdata_true:M_write_result);
    assign write_data = (M_datafromM)?((M_lwl | M_lwr)?data_sram_half:data_sram_rdata_true):
                        (M_reg_ra)?W_ra_data:((M_f_hi | M_f_lo)?((M_f_hi)?HI:LO):M_write_result);
                        //(W_mul)?((M_f_lo)?LO:HI):
    assign data_sram_half = (M_lwl | M_lwr)?((M_lwl)?((M_ea==2'd0)?{data_sram_rdata_true[7:0],Mrdata_2[23:0]}:((M_ea==2'd1)?{data_sram_rdata_true[15:0],Mrdata_2[15:0]}:((M_ea==2'd2)?{data_sram_rdata_true[23:0],Mrdata_2[7:0]}:data_sram_rdata_true))):((M_ea==2'd0)?data_sram_rdata_true:((M_ea==2'd1)?{Mrdata_2[31:24],data_sram_rdata_true[31:8]}:((M_ea==2'd2)?{Mrdata_2[31:16],data_sram_rdata_true[31:16]}:{Mrdata_2[31:8],data_sram_rdata_true[31:24]})))):
                            32'b0;
//Instruction分割********************************************************************
    assign instr_1[5:0] = (M_lw_use | W_complete)?6'b0:inst_sram_rdata[31:26];
    assign instr_2[5:0] = (M_lw_use | W_complete)?6'b0:inst_sram_rdata[5:0];
    assign instr_3[4:0] = (M_lw_use | W_complete)?5'b0:inst_sram_rdata[10:6];
    assign instr_4[4:0] = (M_lw_use | W_complete)?5'b0:inst_sram_rdata[15:11];
    assign instr_5[9:0] = (M_lw_use | W_complete)?10'b0:inst_sram_rdata[25:16];
//branch跳转比较寄存�?????????????????????????????????????****************************************************************
    assign  branch_reg_1 = (E_lw_use)?((Eraddr_1 == M_rd)?data_sram_rdata_true:W_M_data):
                        (raddr_1 == E_rd && raddr_1 != 5'b0)?((E_f_HI|E_f_LO)?((E_f_HI)?HI:LO):result):
                        (raddr_1 == M_rd && raddr_1 != 5'b0)?((M_datafromM)?data_sram_rdata_true:((M_f_hi | M_f_lo)?((M_f_hi)?HI:LO):((M_reg_ra)?W_ra_data:M_alu_result))):
                        rdata_1;
    assign  branch_reg_2 = (E_lw_use)?((Eraddr_2 == M_rd)?data_sram_rdata_true:W_M_data):
                            (raddr_2 == E_rd && raddr_2 != 5'b0 && ~reg_rt)?((E_f_HI|E_f_LO)?((E_f_HI)?HI:LO):result):
                        (raddr_2 == M_rd && raddr_2 != 5'b0 && ~reg_rt)?((M_datafromM)?data_sram_rdata_true:((M_f_hi | M_f_lo)?((M_f_hi)?HI:LO):M_alu_result)):
                        rdata_2;
//除法器端�?????**********************************************************************************************************
    assign  cpu_beichu = (raddr_1 == E_rd && raddr_1 != 5'b0)?result:
                      (raddr_1 == M_rd && raddr_1 != 5'b0)?((M_datafromM)?data_sram_rdata_true:((M_reg_ra)?W_ra_data:M_alu_result)):
                      alu_left;
    assign cpu_chu     = (raddr_2 == E_rd && raddr_2 != 5'b0 && ~reg_rt)?result:
                      (raddr_2 == M_rd && raddr_2 != 5'b0 && ~reg_rt && ~E_write_mem)?((M_datafromM)?data_sram_rdata_true:M_alu_result):
                      alu_right;
    assign wire_hi = (M_t_hi)?W_write_data:
                      (M_mul)?mul_result[63:32]:((complete)?r:HI);
    assign wire_lo = (M_t_lo)?W_write_data:
                      (M_mul)?mul_result[31:0]:((complete)?s:LO);

endmodule