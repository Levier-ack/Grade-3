`timescale 10ns / 1ns

module mycpu_core(
    input resetn,
    input clk,

    output reg inst_req,
    output inst_wr,
    output [1:0] inst_size,
    output [31:0] inst_addr,
    output [31:0] inst_wdata,
    input  [31:0] inst_rdata,
    input         inst_addr_ok,
    input         inst_data_ok,

    output reg data_req,
    output reg data_wr,
    output reg [1:0] data_size,
    output reg [31:0] data_addr,
    output reg [31:0] data_wdata,
    input  [31:0] data_rdata,
    input         data_addr_ok,
    input         data_data_ok,
 
    output reg [31:0] debug_wb_pc,
    output reg [3:0] debug_wb_rf_wen,
    output reg [4:0] debug_wb_rf_wnum,
    output reg [31:0] debug_wb_rf_wdata
);    

    // reg reg_inst_addr_ok;
    // reg reg_data_addr_ok;
    // reg reg_data_req;
    reg [31:0] reg_inst_rdata;
    reg [31:0] reg_data_rdata;
    reg [31:0] reg_data_addr;
    reg time_irq;
    reg soft_irq;
    // reg [2:0] state_data_addr;
    // assign inst_req = (IFvalid)?inst_sram_en:1'b0;
    always@(posedge clk)begin
      if(!resetn)begin
        inst_req <= 1'b0;
      end
      else if(inst_addr_ok)begin
        inst_req <= 1'b0;
      end
      else if(next_IF_readygo == 3'd0)begin
        inst_req <= 1'b1;
      end
    end
    
    assign inst_wr = 1'b0;
    assign inst_size = 2'b10;
    assign inst_addr = PC;
    assign inst_wdata = 32'b0;
    // assign data_addr = (EX_valid)?data_sram_addr:32'b0;

    always@(posedge clk)begin
      if(!resetn)begin
        reg_inst_rdata <= 32'b0;
      end
      else if(inst_data_ok)begin
        reg_inst_rdata <= inst_rdata;
      end
    end

    always@(posedge clk)begin
      if(!resetn)begin
        reg_data_rdata <= 32'b0;
      end
      else if(data_data_ok)begin
        reg_data_rdata <= data_rdata;
      end
    end

    always@(posedge clk)begin
      if(!resetn)begin
        data_req <= 1'b0;
      end
      else if(data_addr_ok)begin
        data_req <= 1'b0;
      end
      else if(E_addr_l_excep || E_addr_s_excep)begin
        data_req <= 1'b0;
      end
      else if(EXtoMEM_valid && MEM_allowin)begin
        data_req <= E_acs_mem;
      end
    end
    always@(posedge clk)begin
      if(!resetn)begin
        data_wr <= 1'b0;
      end
      else if(data_addr_ok)begin
        data_wr <= 1'b0;
      end
      else if(EXtoMEM_valid && MEM_allowin)begin
        data_wr <= E_write_mem;
      end
    end
    always@(posedge clk)begin
      if(!resetn)begin
        data_size <= 2'b0;
      end
      else if(data_addr_ok)begin
        data_size <= 2'b0;
      end
      else if(EXtoMEM_valid && MEM_allowin)begin
        data_size <= (data_wen == 4'b1111)?2'b10:
                        ((data_wen == 4'b1100)||(data_wen == 4'b0011))?2'b01:
                        ((data_wen == 4'b1110)||(data_wen == 4'b0111))?2'b11:
                        2'b00;
      end
    end
    always@(posedge clk)begin
      if(!resetn)begin
        data_addr <= 32'b0;
      end
      else if(data_addr_ok)begin
        data_addr <= 32'b0;
      end
      else if(EXtoMEM_valid && MEM_allowin)begin
        data_addr <= data_sram_addr;
      end
    end

    always@(posedge clk)begin
      if(!resetn)begin
        reg_data_addr <= 32'b0;
      end
      else if(data_addr_ok)begin
        reg_data_addr <= data_addr;
      end
    end

    always@(posedge clk)begin
      if(!resetn)begin
        data_wdata <= 32'b0;
      end
      else if(data_addr_ok)begin
        data_wdata <= 32'b0;
      end
      else if(EXtoMEM_valid && MEM_allowin)begin
        data_wdata <= data_sram_wdata;
      end
    end

    always@(posedge clk)begin
      if(!resetn)begin
        time_irq <= 1'b0;
      end
      else if((COUNT == COMPARE) && COUNT != 32'b0 && !STATUS_EXL)begin
        time_irq <= 1'b1;
      end
      else if(IFtoID_valid && ID_allowin)begin
        time_irq <= 1'b0;
      end
    end
    always@(posedge clk)begin
      if(!resetn)begin
        soft_irq <= 1'b0;
      end
      else if((CAUSE_IP != 8'd0) && !STATUS_EXL)begin
        soft_irq <= 1'b1;
      end
      else if(IFtoID_valid && ID_allowin)begin
        soft_irq <= 1'b0;
      end
    end
//ID寄存器组*************************************************************************
    reg [5:0] instr_1;
    reg [5:0] instr_2;
    reg [4:0] instr_3;
    reg [4:0] instr_4;
    reg [9:0] instr_5;
    reg [31:0] Instruction;
    reg D_time_irq;
    reg D_soft_irq;
//EX寄存器组*************************************************************************
    reg E_datafromM;
    reg E_write_reg;
    reg E_acs_mem;
    reg [4:0] E_rd;
    reg [3:0] E_aluop;
    reg [4:0] E_raddr_1;
    reg [4:0] E_raddr_2;
    wire [31:0] E_rdata_1;
    wire [31:0] E_rdata_2; 
    reg E_reg_imte;
    reg E_reg_rt;
    reg E_write_mem; 
    reg E_lw_use;
    reg [31:0] E_branch_reg;
    reg [31:0] E_alu_left;
    reg [31:0] E_alu_right;
    reg E_reg_ra;
    reg E_inst_add;
    reg E_inst_addi;
    reg E_inst_sub;
    reg E_inst_beq;
    reg E_inst_bne;
    reg E_inst_j;
    reg E_inst_jal;
    reg E_inst_jalr;
    reg E_inst_jr;
    reg E_inst_bgez;
    reg E_inst_bgezal;
    reg E_inst_bgtz;
    reg E_inst_blez;
    reg E_inst_bltz;
    reg E_inst_bltzal;
    reg E_cpu_div;
    reg E_mul;
    reg E_mul_sign;
    reg E_f_HI;
    reg E_f_LO;
    reg E_t_hi;
    reg E_t_lo;
    reg E_sw;
    reg E_lw;
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
    reg E_div_sign;
    reg [31:0] E_cpu_beichu;
    reg [31:0] E_cpu_chu;
    reg [31:0] E_branch_reg_1;
    reg [31:0] E_branch_reg_2;
    reg [31:0] Erdata_2;
    reg E_inst_mfc0;
    reg [31:0] E_mfc0_reg;
    reg [31:0] E_mtc0_value;
    reg E_mtc0_wen_status;
    reg E_mtc0_wen_cause;
    reg E_mtc0_wen_count;
    reg E_mtc0_wen_epc;
    reg E_exception_commit;
    reg E_excep_pc;
    reg E_time_irq;
    reg E_soft_irq;
    reg E_eret_commit;
    reg E_mtc0_wen_compare;
    reg E_inst_in_ds;
    reg E_inst_syscall;
    reg E_inst_break;
    reg E_mtc0_wen;
    reg E_pc_offset;
    // reg [31:0] E_div_HI;
    // reg [31:0] E_div_LO;
    reg E_unknown_inst;
//MEM寄存器组************************************************************************
    reg M_datafromM;
    reg M_write_reg;
    reg M_reg_ra;
    reg [4:0] M_rd;
    reg [31:0] M_ra_data;
    reg [31:0] M_write_result;
    reg M_lw_use;
    reg [31:0] M_alu_result;
    reg M_cpu_div;
    reg M_mul;
    reg M_complete;
    reg M_f_hi;
    reg M_f_lo;
    reg M_t_hi;
    reg M_t_lo;
    reg [1:0] M_ea;
    // reg M_lw_lw;
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
    reg M_inst_mfc0;
    reg [31:0] M_mfc0_reg;
    reg [31:0] M_mtc0_value;
    reg M_mtc0_wen_status;
    reg M_mtc0_wen_cause;
    reg M_mtc0_wen_compare;
    reg M_mtc0_wen_count;
    reg M_mtc0_wen_epc;
    reg M_exception_commit;
    reg M_eret_commit;
    reg M_inst_in_ds;
    reg M_inst_syscall;
    reg M_inst_break;
    reg M_overflow;
    reg M_addr_l_excep;
    reg M_addr_s_excep;
    reg M_excep_pc;
    reg M_time_irq;
    reg M_soft_irq;
    reg M_mtc0_wen;
    reg [31:0] M_div_HI;
    reg [31:0] M_div_LO;
    reg [31:0] M_HI_LO;
    wire [31:0] wire_M_write_result;
    reg [31:0] M_data_sram_addr;
    reg M_unknown_inst;
//WB寄存器组**************************************************************************
    reg [4:0] W_rd;
    reg W_write_reg;
    // reg W_datafromM;
    reg [31:0] W_write_data;
    reg [31:0] W_write_result;
    reg [31:0] W_ra_data;
    reg [31:0] W_M_data;
    reg W_reg_ra;
    reg W_mtc0_wen;
    reg [31:0] W_mfc0_reg;
    reg W_inst_mfc0;
    reg W_inst_syscall;
    reg W_inst_break;
    reg W_exception_commit;
    reg W_eret_commit;
//PC计数�???????**************************************************************************
    reg [31:0] PC;
    reg [31:0] PC_1;
    reg [31:0] PC_2;
    reg [31:0] PC_3;
    reg [31:0] PC_4;
    reg [31:0] PC_5;
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
    wire [31:0] write_data_temp;
    wire [31:0] rdata_1;
    wire [31:0] rdata_2;
//HI和LO寄存�???????************************************************************************
    reg [31:0] HI;
    reg [31:0] LO;
    wire [31:0] wire_hi;
    wire [31:0] wire_lo;
//乘法器端�???????**************************************************************************
    wire cpu_mul    = inst_mult | inst_multu;
    wire mul_sign   = cpu_mul & inst_mult;
    wire [63:0] mul_result;
//除法器端�???????**************************************************************************
    wire cpu_div    = inst_div | inst_divu;
    wire div_sign   = cpu_div & inst_div;
    wire complete;
    wire [31:0] cpu_beichu;
    wire [31:0] cpu_chu;
    wire [31:0] s;
    wire [31:0] r;
//例外处理*********************************************************************************
    reg [31:0] EPC;
    wire [31:0] STATUS;
    wire STATUS_BEV;
    reg [7:0] STATUS_IM;
    reg STATUS_EXL;
    reg STATUS_IE;    
    wire  [31:0] CAUSE;
    reg CAUSE_BD;
    reg CAUSE_TI;
    reg [7:0] CAUSE_IP;
    reg [4:0] CAUSE_EXCODE;
    reg [31:0] BADVADDR;
    reg [31:0] COUNT;
    reg [31:0] COMPARE;
    reg count_step;
//调用ALU和regfile和乘法器和除法器
    reg_file reg_file(.clk(clk),.rst(rst),.waddr(waddr),.raddr1(raddr_1),.raddr2(raddr_2),.wen(reg_write),.Wdata(write_data),.rdata1(rdata_1),.rdata2(rdata_2));
	  alu alu(.A(E_rdata_1),.B(E_rdata_2),.ALUop(E_aluop),.Result(result)); 
    div div(.div_clk(clk),.resetn(resetn),.div(E_cpu_div),.div_signed(E_div_sign),.x(E_cpu_beichu),.y(E_cpu_chu),.s(s),.r(r),.complete(complete));
    mul mul(.mul_clk(clk),.resetn(resetn),.mul_signed(E_mul_sign),.x(E_rdata_1),.y(E_rdata_2),.result(mul_result));
//debug信号
    always@(posedge clk)
    begin
      if(!resetn)begin
        debug_wb_pc       <= 32'b0;
        debug_wb_rf_wdata <= 32'b0;
        debug_wb_rf_wen   <= 4'b0;
        debug_wb_rf_wnum  <= 5'b0;
      end
      else if(WB_valid)begin
        // debug_wb_pc       <= (W_mtc0_wen)?PC_3:PC_4;
        debug_wb_pc       <= PC_5;
        // debug_wb_rf_wdata <= (W_mfc0_reg)?W_mfc0_reg:((W_reg_ra)?PC_4 + 8:((M_datafromM)?((E_lw_use & ~lw_use)?data_sram_rdata_true:W_M_data):((W_mtc0_wen)?M_write_result:W_write_data)));
        debug_wb_rf_wdata <= W_write_data;
        debug_wb_rf_wen   <= {4{W_write_reg}};
        debug_wb_rf_wnum  <= W_rd;
      end
      else begin
        // debug_wb_pc       <= 32'b0;
        // debug_wb_rf_wdata <= 32'b0;
        debug_wb_rf_wen   <= 4'b0;
        // debug_wb_rf_wnum  <= 5'b0;
      end
    end
//端口信号
    wire [31:0] data_sram_rdata_true;
    wire [31:0] data_sram_half;
    wire [31:0] data_sram_addr;
    wire [3:0]  data_wen;
    wire [31:0] data_sram_wdata;
    wire [3:0]  data_strb_half;
    wire [3:0]  data_strb_b;
    wire [31:0] data_write_half;
    wire [31:0] data_write_b;
    wire [1:0]  ea;
    assign data_sram_wdata  = (E_write_mem)?(E_swl | E_swr)?data_write_half:((E_sb | E_sh)?data_write_b:E_branch_reg):32'b0;
    assign data_wen    = (E_write_mem)?((E_sb | E_sh)?data_strb_b:((E_swl | E_swr)?data_strb_half:4'b1111)):4'b0;
    assign data_sram_addr   = (EX_valid)?(E_write_mem)?result:((E_lw_use)?write_data + E_alu_right:result) : 32'b0;
    assign ea               = data_sram_addr[1:0];
    assign data_sram_rdata_true = (M_lb | M_lbu)?((M_lb)?((M_ea==2'd0)?{{24{reg_data_rdata[7]}},reg_data_rdata[7:0]}:((M_ea==2'd1)?{{24{reg_data_rdata[15]}},reg_data_rdata[15:8]}:((M_ea==2'd2)?{{24{reg_data_rdata[23]}},reg_data_rdata[23:16]}:{{24{reg_data_rdata[31]}},reg_data_rdata[31:24]}))):((M_ea==2'd0)?{24'b0,reg_data_rdata[7:0]}:((M_ea==2'd1)?{24'b0,reg_data_rdata[15:8]}:((M_ea==2'd2)?{24'b0,reg_data_rdata[23:16]}:{24'b0,reg_data_rdata[31:24]})))):
                                  (M_lh | M_lhu)?((M_lh)?(M_ea[1]?{{16{reg_data_rdata[31]}},reg_data_rdata[31:16]}:{{16{reg_data_rdata[15]}},reg_data_rdata[15:0]}):(M_ea[1]?{16'b0,reg_data_rdata[31:16]}:{16'b0,reg_data_rdata[15:0]})):
                                  reg_data_rdata;
    assign rst = ~resetn;
    assign data_strb_half   = (E_swl | E_swr)?((E_swl)?((ea==2'd0)?4'b0001:((ea==2'd1)?4'b0011:((ea==2'd2)?4'b0111:4'b1111))):((ea==2'd0)?4'b1111:((ea==2'd1)?4'b1110:((ea==2'd2)?4'b1100:4'b1000)))):4'b0;
    assign data_write_half  = (E_swl | E_swr)?((E_swl)?((ea==2'd0)?{24'b0,E_branch_reg[31:24]}:((ea==2'd1)?{16'b0,E_branch_reg[31:16]}:((ea==2'd2)?{8'b0,E_branch_reg[31:8]}:E_branch_reg))):((ea==2'd0)?E_branch_reg:((ea==2'd1)?{E_branch_reg[23:0],8'b0}:((ea==2'd2)?{E_branch_reg[15:0],16'b0}:{E_branch_reg[7:0],24'b0})))):E_branch_reg;
    assign data_strb_b      = (E_sb | E_sh)?((E_sb)?((ea==2'd0)?4'b0001:((ea==2'd1)?4'b0010:((ea==2'd2)?4'b0100:4'b1000))):((ea[1])?4'b1100:4'b0011)):4'b0;
    assign data_write_b     = (E_sb | E_sh)?((E_sb)?((ea==2'd0)?{24'b0,E_branch_reg[7:0]}:((ea==2'd1)?{16'b0,E_branch_reg[7:0],8'b0}:((ea==2'd2)?{8'b0,E_branch_reg[7:0],16'b0}:{E_branch_reg[7:0],24'b0}))):((ea[1])?{E_branch_reg[15:0],16'b0}:{16'b0,E_branch_reg[15:0]})):E_branch_reg;
//指令判断***************************************************************************
    wire inst_lui   = (instr_1 == 6'b001111);
    wire inst_addu  = (instr_1 == 6'b0 && instr_2 == 6'b100001);
    wire inst_addiu = (instr_1 == 6'b001001);
    wire inst_subu  = (instr_1 == 6'b0 && instr_2 == 6'b100011);
    wire inst_slt   = (instr_1 == 6'b0 && instr_2 == 6'b101010);
    wire inst_sltu  = (instr_1 == 6'b0 && instr_2 == 6'b101011);
    wire inst_and   = (instr_1 == 6'b0 && instr_2 == 6'b100100);
    wire inst_or    = (instr_1 == 6'b0 && instr_2 == 6'b100101);
    wire inst_xor   = (instr_1 == 6'b0 && instr_2 == 6'b100110);
    wire inst_nor   = (instr_1 == 6'b0 && instr_2 == 6'b100111);
    wire inst_sll   = (instr_1 == 6'b0 && instr_2 == 6'b0);
    wire inst_srl   = (instr_1 == 6'b0 && instr_2 == 6'b000010);
    wire inst_sra   = (instr_1 == 6'b0 && instr_2 == 6'b000011);
    wire inst_lw    = (instr_1 == 6'b100011);
    wire inst_sw    = (instr_1 == 6'b101011);
    wire inst_beq   = (instr_1 == 6'b000100);
    wire inst_bne   = (instr_1 == 6'b000101);
    wire inst_jal   = (instr_1 == 6'b000011);
    wire inst_jr    = (instr_1 == 6'b0 && instr_2 == 6'b001000);
    wire inst_add   = (instr_1 == 6'b0 && instr_2 == 6'b100000);
    wire inst_addi  = (instr_1 == 6'b001000);
    wire inst_sub   = (instr_1 == 6'b0 && instr_2 == 6'b100010);
    wire inst_slti  = (instr_1 == 6'b001010);
    wire inst_sltiu = (instr_1 == 6'b001011);
    wire inst_andi  = (instr_1 == 6'b001100);
    wire inst_ori   = (instr_1 == 6'b001101);
    wire inst_xori  = (instr_1 == 6'b001110);
    wire inst_sllv  = (instr_1 == 6'b0 && instr_2 == 6'b000100);
    wire inst_srav  = (instr_1 == 6'b0 && instr_2 == 6'b000111);
    wire inst_srlv  = (instr_1 == 6'b0 && instr_2 == 6'b000110);
    wire inst_div   = (instr_1 == 6'b0 && instr_2 == 6'b011010);
    wire inst_divu  = (instr_1 == 6'b0 && instr_2 == 6'b011011);
    wire inst_mult  = (instr_1 == 6'b0 && instr_2 == 6'b011000);
    wire inst_multu = (instr_1 == 6'b0 && instr_2 == 6'b011001);
    wire inst_mfhi  = (instr_1 == 6'b0 && instr_2 == 6'b010000);
    wire inst_mflo  = (instr_1 == 6'b0 && instr_2 == 6'b010010);
    wire inst_mthi  = (instr_1 == 6'b0 && instr_2 == 6'b010001);
    wire inst_mtlo  = (instr_1 == 6'b0 && instr_2 == 6'b010011);
    wire inst_j     = (instr_1 == 6'b000010);
    wire inst_bgez  = (instr_1 == 6'b000001 && instr_5 [4:0] == 5'b00001);
    wire inst_bltz  = (instr_1 == 6'b000001 && instr_5 [4:0] == 5'b00000);
    wire inst_bltzal= (instr_1 == 6'b000001 && instr_5 [4:0] == 5'b10000);
    wire inst_bgezal= (instr_1 == 6'b000001 && instr_5 [4:0] == 5'b10001);
    wire inst_bgtz  = (instr_1 == 6'b000111);
    wire inst_blez  = (instr_1 == 6'b000110);
    wire inst_jalr  = (instr_1 == 6'b0 && instr_2 == 6'b001001);
    wire inst_lb    = (instr_1 == 6'b100000);
    wire inst_lbu   = (instr_1 == 6'b100100);
    wire inst_lh    = (instr_1 == 6'b100001);
    wire inst_lhu   = (instr_1 == 6'b100101);
    wire inst_lwl   = (instr_1 == 6'b100010);
    wire inst_lwr   = (instr_1 == 6'b100110);
    wire inst_sb    = (instr_1 == 6'b101000);
    wire inst_sh    = (instr_1 == 6'b101001);
    wire inst_swl   = (instr_1 == 6'b101010);
    wire inst_swr   = (instr_1 == 6'b101110);
    wire inst_nop   = {instr_1,instr_5,instr_4,instr_3,instr_2} == 32'b0;
    wire inst_eret  = ({instr_1,instr_5[9]} == 7'b0100001);
    wire inst_mfc0  = ({instr_1,instr_5[9:5]} == 11'b01000000000);
    wire inst_mtc0  = ({instr_1,instr_5[9:5]} == 11'b01000000100);   
    wire inst_syscall = (instr_1 == 6'b0 && instr_2 == 6'b001100); 
    wire inst_break = (instr_1 == 6'b0 && instr_2 == 6'b001101);
    wire unknown_inst = ~E_excep_pc && ~(inst_add || inst_addi || inst_addiu || inst_addu || inst_and || inst_andi || inst_beq || inst_bgez || inst_bgezal || inst_bgtz || inst_blez || inst_bltz || inst_bltzal || inst_bne || inst_break || inst_div || inst_divu || inst_eret || inst_j || inst_jal || inst_jalr || inst_jr || inst_lb || inst_lbu || inst_lh || inst_lhu || inst_lui || inst_lw || inst_lwl || inst_lwr || inst_mfc0 || inst_mfhi || inst_mflo || inst_mthi || inst_mtc0 || inst_mtlo || inst_mult || inst_multu || inst_nor || inst_or || inst_ori || inst_sb || inst_sh || inst_sll || inst_sllv || inst_slt || inst_slti || inst_sltiu || inst_sltu || inst_sra || inst_srav || inst_srl || inst_srlv || inst_sub || inst_subu || inst_sw || inst_swl || inst_swr || inst_syscall || inst_xor || inst_xori);
    wire execp_lw   = E_lw && ((data_sram_addr[0] != 1'b0) || (data_sram_addr[1] != 1'b0));
    wire execp_lh   = (E_lh || E_lhu) && (data_sram_addr[0] != 1'b0);
    wire execp_sw   = E_sw && ((data_sram_addr[0] != 1'b0) || (data_sram_addr[1] != 1'b0));
    wire execp_sh   = E_sh && (data_sram_addr[0] != 1'b0);
    // wire excep_pc   = (E_exception_commit)?1'b0:(PC_3[0] != 1'b0) || (PC_3[1] != 1'b0);
    wire excep_pc     = ((PC_1[0] != 1'b0) || (PC_1[1] != 1'b0)) && (PC_3[0] == 1'b0) && (PC_3[1] == 1'b0);
    wire addr_l_excep = (EX_valid)?(execp_lh | execp_lw):1'b0;
    wire addr_s_excep = (EX_valid)?(execp_sh | execp_sw):1'b0;
    wire overflow_add   = (E_inst_add || E_inst_addi) && ((E_rdata_1[31] == 1)&&(E_rdata_2[31] == 1)&&(result[31] == 0)||(E_rdata_1[31] == 0)&&(E_rdata_2[31] == 0)&&(result[31] == 1));
    wire overflow_sub   = E_inst_sub  && ((E_rdata_1[31] == 0)&&(E_rdata_2[31] == 1)&&(result[31] == 1)||(E_rdata_1[31] == 1)&&(E_rdata_2[31] == 0)&&(result[31] == 0)); 
    wire overflow       = overflow_add || overflow_sub;
    wire E_addr_l_excep = addr_l_excep || (E_datafromM && M_addr_l_excep);
    wire E_addr_s_excep = addr_s_excep || (E_write_mem && M_addr_s_excep);
//control信号************************************************************************
    wire pc_offset  = inst_beq | inst_bne | inst_jal | inst_jr | inst_j | inst_jalr | inst_bgez | inst_bgtz | inst_bltzal | inst_bgezal | inst_bltz | inst_blez;
    wire reg_imte   = inst_addiu | inst_lui | inst_lw | inst_addi | inst_slti | inst_sltiu | inst_andi | inst_ori | inst_xori | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lwl | inst_lwr;//data_B数据来自立即�??????????????????????????????????????????????????????????????????????????????
    wire datafromM  = inst_lw | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lwl | inst_lwr;//寄存器写入的数据不来自ALU
    wire reg_rt     = inst_mfc0 | inst_addiu | inst_lw | inst_lui | inst_addi | inst_slti | inst_sltiu | inst_andi | inst_ori  | inst_xori | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lwl | inst_lwr;//目标寄存器是rt
    wire reg_ra     = inst_jal | inst_jalr | inst_bltzal | inst_bgezal;//目标寄存器是ra
    wire write_reg  = ~(inst_nop | exception_commit | inst_eret | inst_mtc0 | inst_bltz | inst_blez | inst_bgtz | inst_bgez | inst_j | inst_beq | inst_bne | inst_sw | inst_div | inst_divu | inst_mult | inst_multu | inst_mthi | inst_mtlo | inst_sb | inst_sh | inst_swl | inst_swr);
    wire write_mem  = inst_sw | inst_sb | inst_sh | inst_swl | inst_swr;
    wire acs_mem    = inst_lw | inst_sw | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lwl | inst_lwr | inst_sb | inst_sh | inst_swl | inst_swr; 
    wire inst_move  = inst_sll | inst_sra | inst_srl | inst_andi | inst_ori | inst_xori;
    wire extend_u   = inst_andi | inst_ori | inst_xori;
    wire lw_use     = (inst_beq | inst_bne) & E_datafromM & (E_rd == instr_5[4:0] | E_rd == instr_5[9:5]);
    wire lw_lw      = E_datafromM & datafromM & (E_rd == instr_5[9:5]);
    wire exception_commit = inst_syscall | inst_break | unknown_inst;
    wire eret_commit = inst_eret;
    wire mtc0_wen_cause   = inst_mtc0 & (instr_4 == 5'b01101);
    wire mtc0_wen_compare = inst_mtc0 & (instr_4 == 5'b01011);
    wire mtc0_wen_status  = inst_mtc0 & (instr_4 == 5'b01100);
    wire mtc0_wen_count   = inst_mtc0 & (instr_4 == 5'b01001);
    wire mtc0_wen_epc     = inst_mtc0 & (instr_4 == 5'b01110);
    wire mtc0_wen         = mtc0_wen_cause | mtc0_wen_compare | mtc0_wen_count | mtc0_wen_status | mtc0_wen_epc;
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
    // reg [2:0] cur_IF_readygo;
    reg [2:0] next_IF_readygo;
    wire IFtoID_valid;
    assign IF_allowin = !IF_valid || IF_readygo && ID_allowin;
    always@(posedge clk)begin
      if(!resetn)begin
        next_IF_readygo <= 3'd0;
      end
      else if(inst_addr_ok)begin
        next_IF_readygo <= 3'd1;
      end
      else if(next_IF_readygo == 3'd1)begin
        next_IF_readygo <= 3'd2;
      end
      else if(inst_data_ok && (next_IF_readygo == 3'd2))begin
        next_IF_readygo <= 3'd3;
      end
      else if(next_IF_readygo == 3'd3)begin
        next_IF_readygo <= 3'd0;
      end
    end
    assign IF_readygo = next_IF_readygo == 3'd3;
    assign IFtoID_valid = IF_valid && IF_readygo;
    // assign IF_valid = inst_data_ok;
    always@(posedge clk)begin
      if(!resetn)begin
        Instruction  <= 32'b0;
        IF_valid     <= 1'b0;
        PC_1         <= 32'hbfc00000;
      end
      else if(IF_allowin) begin
        IF_valid     <= inst_addr_ok;
        Instruction  <= reg_inst_rdata;
        PC_1 <= PC;
      end
    end
//ID*****************************************************************************
    wire ID_allowin;
    wire ID_readygo;
    wire IDtoEX_valid;
    reg [2:0] next_ID_readygo;
    assign ID_allowin = !ID_valid || ID_readygo && EX_allowin;
    // assign ID_readygo = (~(lw_use & ~E_lw_use) & ~cpu_div) | complete;
    always@(posedge clk)begin
      if(!resetn)begin
        next_ID_readygo <= 3'd0;
      end
      else if((next_ID_readygo == 3'd1)&&(data_data_ok))begin
        next_ID_readygo <= 3'd2;
      end
      else if(next_ID_readygo == 3'd2)begin
        next_ID_readygo <= 3'd0;
      end
      else if(lw_use)begin
        next_ID_readygo <= 3'd1;
      end
    end
    assign ID_readygo = ((next_ID_readygo == 3'd0) && ~lw_use) || (next_ID_readygo == 3'd2);
    assign IDtoEX_valid = ID_valid && ID_readygo;
    always@(posedge clk)begin
      if(!resetn)begin
        ID_valid <= 1'b0;
      end
      else if(ID_allowin)begin
        ID_valid <= IFtoID_valid;
      end
      if(!resetn)begin
        PC_2 <= 32'hbfc00000;
        {instr_1,instr_5,instr_4,instr_3,instr_2} <= 32'b0;
        D_time_irq          <= 1'b0;
        D_soft_irq          <= 1'b0;
      end
      else if(IFtoID_valid && ID_allowin)begin
        PC_2 <= PC_1;
        {instr_1,instr_5,instr_4,instr_3,instr_2} <= (cpu_div || E_exception_commit || E_time_irq || E_soft_irq || E_eret_commit || E_excep_pc || overflow || E_addr_l_excep || E_addr_s_excep)?32'b0:reg_inst_rdata;
        D_time_irq          <= time_irq;
        D_soft_irq          <= soft_irq;
      end
    end

//EX*****************************************************************************
    wire EX_allowin;
    wire EX_readygo;
    wire EXtoMEM_valid;
    reg [2:0] next_EX_readygo;
    reg reg_complete;
    assign EX_allowin = !EX_valid || EX_readygo && MEM_allowin;
    always@(posedge clk)begin
      if(!resetn)begin
        next_EX_readygo <= 3'd0;
      end
      else if(cpu_div)begin
        next_EX_readygo <= 3'd1;
      end
      else if((next_EX_readygo == 3'd1) && complete)begin
        next_EX_readygo <= 3'd2;
      end
      else if(next_EX_readygo == 3'd2)begin
        next_EX_readygo <= 3'd0;
      end
    end
    always@(posedge clk)begin
      if(!resetn)begin
        reg_complete <= 1'b0;
      end
      else if(complete)begin
        reg_complete <= 1'b1;
      end
      else if(EXtoMEM_valid && MEM_allowin)begin
        reg_complete <= 1'b0;
      end
    end
    assign EX_readygo = next_EX_readygo == 3'd0;
    assign EXtoMEM_valid = EX_valid && EX_readygo;
    always@(posedge clk)begin
      if(!resetn)begin
        EX_valid <= 1'b0;
      end
      else if(EX_allowin)begin
        EX_valid <= IDtoEX_valid;
      end
      if(!resetn)begin
        E_lw_use    <= 1'b0;
        E_cpu_div   <= 1'b0;
        E_datafromM <= 1'b0;
        E_rd        <= 5'b0;
        E_reg_rt    <= 1'b0;
        E_aluop     <= 4'b0;
        E_reg_imte  <= 1'b0;
        E_write_mem <= 1'b0;
        E_raddr_1   <= 5'b0;
        E_raddr_2   <= 5'b0;
        E_alu_left  <= 32'b0;
        E_alu_right <= 32'b0;
        E_acs_mem   <= 1'b0;
        E_write_reg <= 1'b0;
        E_reg_ra    <= 1'b0;
        E_mul       <= 1'b0;
        E_mul_sign  <= 1'b0;
        E_f_HI      <= 1'b0;
        E_f_LO      <= 1'b0;
        E_t_hi      <= 1'b0;
        E_t_lo      <= 1'b0;
        E_inst_add  <= 1'b0;
        E_inst_addi <= 1'b0;
        E_inst_sub  <= 1'b0;
        E_lw        <= 1'b0;
        E_sw        <= 1'b0;
        E_lb        <= 1'b0;
        E_lbu       <= 1'b0;
        E_lh        <= 1'b0;
        E_lhu       <= 1'b0;
        E_lwl       <= 1'b0;
        E_lwr       <= 1'b0;
        E_sb        <= 1'b0;
        E_sh        <= 1'b0;
        E_swl       <= 1'b0;
        E_swr       <= 1'b0;
        E_inst_beq  <= 1'b0;
        E_inst_bne  <= 1'b0;
        E_inst_j    <= 1'b0;
        E_inst_jalr <= 1'b0;
        E_inst_jr   <= 1'b0;
        E_inst_jal  <= 1'b0;
        E_inst_bgez <= 1'b0;
        E_inst_bgtz <= 1'b0;
        E_inst_bgezal <= 1'b0;
        E_inst_bltzal <= 1'b0;
        E_inst_blez <= 1'b0;
        E_inst_bltz <= 1'b0;
        Erdata_2    <= 32'b0;
        E_inst_mfc0 <= 1'b0;
        E_mfc0_reg  <= 32'b0;
        E_pc_offset <= 1'b0;
        E_div_sign  <= 1'b0;
        E_cpu_beichu        <= 32'b0;
        E_cpu_chu           <= 32'b0;
        E_mtc0_wen_status   <= 1'b0;
        E_mtc0_wen_cause    <= 1'b0;
        E_mtc0_wen_count    <= 1'b0;
        E_mtc0_wen_epc      <= 1'b0;
        E_exception_commit  <= 1'b0;
        E_excep_pc          <= 1'b0;
        E_eret_commit       <= 1'b0;
        E_mtc0_wen_compare  <= 1'b0;
        E_inst_in_ds        <= 1'b0;
        E_mtc0_value        <= 32'b0;
        E_inst_syscall      <= 1'b0;
        E_inst_break        <= 1'b0;
        E_unknown_inst      <= 1'b0;
        E_mtc0_wen          <= 1'b0;
        E_time_irq          <= 1'b0;
        E_soft_irq          <= 1'b0;
        PC_3                <= 32'hbfc00000;
      end
      else if(IDtoEX_valid && EX_allowin && excep_pc)begin
        E_lw_use    <= 1'b0;
        E_cpu_div   <= 1'b0;
        E_datafromM <= 1'b0;
        E_rd        <= 5'b0;
        E_reg_rt    <= 1'b0;
        E_aluop     <= 4'b0;
        E_reg_imte  <= 1'b0;
        E_write_mem <= 1'b0;
        E_raddr_1   <= 5'b0;
        E_raddr_2   <= 5'b0;
        E_alu_left  <= 32'b0;
        E_alu_right <= 32'b0;
        E_acs_mem   <= 1'b0;
        E_write_reg <= 1'b0;
        E_reg_ra    <= 1'b0;
        E_mul       <= 1'b0;
        E_mul_sign  <= 1'b0;
        E_f_HI      <= 1'b0;
        E_f_LO      <= 1'b0;
        E_t_hi      <= 1'b0;
        E_t_lo      <= 1'b0;
        E_inst_add  <= 1'b0;
        E_inst_addi <= 1'b0;
        E_inst_sub  <= 1'b0;
        E_lw        <= 1'b0;
        E_sw        <= 1'b0;
        E_lb        <= 1'b0;
        E_lbu       <= 1'b0;
        E_lh        <= 1'b0;
        E_lhu       <= 1'b0;
        E_lwl       <= 1'b0;
        E_lwr       <= 1'b0;
        E_sb        <= 1'b0;
        E_sh        <= 1'b0;
        E_swl       <= 1'b0;
        E_swr       <= 1'b0;
        E_inst_beq  <= 1'b0;
        E_inst_bne  <= 1'b0;
        E_inst_j    <= 1'b0;
        E_inst_jalr <= 1'b0;
        E_inst_jr   <= 1'b0;
        E_inst_jal  <= 1'b0;
        E_inst_bgez <= 1'b0;
        E_inst_bgtz <= 1'b0;
        E_inst_bgezal <= 1'b0;
        E_inst_bltzal <= 1'b0;
        E_inst_blez <= 1'b0;
        E_inst_bltz <= 1'b0;
        Erdata_2    <= 32'b0;
        E_inst_mfc0 <= 1'b0;
        E_mfc0_reg  <= 32'b0;
        E_pc_offset <= 1'b0;
        E_div_sign  <= 1'b0;
        E_cpu_beichu        <= 32'b0;
        E_cpu_chu           <= 32'b0;
        E_mtc0_wen_status   <= 1'b0;
        E_mtc0_wen_cause    <= 1'b0;
        E_mtc0_wen_count    <= 1'b0;
        E_mtc0_wen_epc      <= 1'b0;
        E_exception_commit  <= 1'b0;
        E_excep_pc          <= excep_pc;
        E_time_irq          <= D_time_irq;
        E_soft_irq          <= D_soft_irq;
        E_eret_commit       <= 1'b0;
        E_mtc0_wen_compare  <= 1'b0;
        E_inst_in_ds        <= E_pc_offset;
        E_mtc0_value        <= 32'b0;
        E_inst_syscall      <= 1'b0;
        E_inst_break        <= 1'b0;
        E_unknown_inst      <= 1'b0;
        E_mtc0_wen          <= 1'b0;
        // E_div_HI            <= 32'b0;
        // E_div_LO            <= 32'b0;
        PC_3                <= PC_2;
      end
      else if(IDtoEX_valid && EX_allowin)begin
        E_lw_use      <= lw_use || lw_lw;
        E_cpu_div     <= cpu_div;
        PC_3          <= PC_2;
        E_datafromM   <= datafromM;
        E_rd          <= (reg_ra)?5'd31:((reg_rt) ?instr_5[4:0]:((~write_reg)?5'b0:instr_4));
        E_reg_ra      <= reg_ra;
        E_reg_rt      <= reg_rt;
        E_aluop       <= aluop;
        E_reg_imte    <= reg_imte;
        E_write_mem   <= write_mem;
        E_raddr_1     <= raddr_1;
        E_raddr_2     <= raddr_2;
        E_alu_left    <= alu_left;
        E_alu_right   <= alu_right;
        E_inst_beq <= inst_beq;
        E_inst_bne <= inst_bne;
        E_inst_jalr<= inst_jalr;
        E_inst_j   <= inst_j;
        E_inst_jal <= inst_jal;
        E_inst_jr  <= inst_jr;
        E_inst_bgez<= inst_bgez;
        E_inst_bgtz<= inst_bgtz;
        E_inst_bgezal  <= inst_bgezal;
        E_inst_bltzal  <= inst_bltzal;
        E_inst_blez    <= inst_blez;
        E_inst_bltz    <= inst_bltz;
        E_branch_reg_1 <= branch_reg_1;
        E_branch_reg_2 <= branch_reg_2;
        E_branch_reg   <= (inst_beq | inst_bne) & E_datafromM & (E_rd == instr_5[4:0] | E_rd == instr_5[9:5])?data_sram_rdata_true:
                        ((E_f_HI | E_f_LO)?((E_f_HI)?wire_hi:wire_lo):branch_reg_2);
        E_acs_mem   <= acs_mem;
        E_write_reg <= write_reg;
        E_mul       <= cpu_mul;
        E_mul_sign  <= mul_sign;
        E_f_HI      <= inst_mfhi;
        E_f_LO      <= inst_mflo;
        E_t_hi      <= inst_mthi;
        E_t_lo      <= inst_mtlo;
        E_inst_add  <= inst_add;
        E_inst_addi <= inst_addi;
        E_inst_sub  <= inst_sub;
        E_lw        <= inst_lw;
        E_sw        <= inst_sw;
        E_lb        <= inst_lb;
        E_lbu       <= inst_lbu;
        E_lh        <= inst_lh;
        E_lhu       <= inst_lhu;
        E_lwl       <= inst_lwl;
        E_lwr       <= inst_lwr;
        E_sb        <= inst_sb;
        E_sh        <= inst_sh;
        E_swl       <= inst_swl;
        E_swr       <= inst_swr;
        E_div_sign  <= div_sign;
        Erdata_2    <= rdata_2;
        E_inst_mfc0 <= inst_mfc0;
        E_pc_offset <= pc_offset;
        E_cpu_beichu<= cpu_beichu;
        E_cpu_chu   <= cpu_chu;
        E_mfc0_reg  <= (instr_4 == 5'b01000 && inst_mfc0)?BADVADDR:
                        (instr_4 == 5'b01001 && inst_mfc0)?COUNT:
                        (instr_4 == 5'b01011 && inst_mfc0)?COMPARE:
                        (instr_4 == 5'b01100 && inst_mfc0)?STATUS:
                        (instr_4 == 5'b01101 && inst_mfc0)?CAUSE:
                        (instr_4 == 5'b01110 && inst_mfc0)?EPC:32'b0;
        E_mtc0_wen_status   <= mtc0_wen_status;
        E_mtc0_wen_cause    <= mtc0_wen_cause;
        E_mtc0_wen_compare  <= mtc0_wen_compare;
        E_mtc0_wen_count    <= mtc0_wen_count;
        E_mtc0_wen_epc      <= mtc0_wen_epc;
        E_exception_commit  <= exception_commit;
        E_excep_pc          <= excep_pc;
        E_eret_commit       <= eret_commit;
        E_time_irq          <= D_time_irq;
        E_soft_irq          <= D_soft_irq;
        E_inst_in_ds        <= E_pc_offset;
        E_mtc0_value        <= ((raddr_2 == M_rd) && (raddr_2 != 5'b0))?M_alu_result:rdata_2;
        E_inst_syscall      <= inst_syscall;
        E_inst_break        <= inst_break;
        E_unknown_inst      <= unknown_inst;
        E_mtc0_wen          <= mtc0_wen;
      end
    end
//MEM****************************************************************************
    wire MEM_allowin;
    wire MEM_readygo;
    // reg [2:0] cur_MEM_readygo;
    reg [2:0] next_MEM_readygo;
    wire MEMtoWB_valid;

    assign MEM_allowin = !MEM_valid || MEM_readygo && WB_allowin;
    always@(posedge clk)begin
      if(!resetn)begin
        next_MEM_readygo <= 3'd0;
      end
      else if(data_req && ~data_wr)begin//lw
        next_MEM_readygo <= 3'd1;
      end
      else if(data_req && data_wr)begin//sw
        next_MEM_readygo <= 3'd2;
      end
      else if(data_addr_ok && (next_MEM_readygo == 3'd1))begin
        next_MEM_readygo <= 3'd3;
      end
      else if((next_MEM_readygo == 3'd3) || (next_MEM_readygo == 3'd2))begin
        next_MEM_readygo <= 3'd4;
      end
      else if(data_data_ok)begin
        next_MEM_readygo <= 3'd5;
      end
      else if(next_MEM_readygo == 3'd5)begin
        next_MEM_readygo <= 3'd0;
      end
    end

    // assign MEM_readygo = (next_MEM_readygo == 3'd5) || ((next_MEM_readygo == 3'd0) && ~(data_req && ~data_wr));
    assign MEM_readygo = (next_MEM_readygo == 3'd0) && ~(data_req && ~data_wr);
    assign MEMtoWB_valid = MEM_valid && MEM_readygo;
    always@(posedge clk)begin
      if(!resetn)begin
        MEM_valid <= 1'b0;
      end
      else if(data_req)begin
        MEM_valid <= 1'b1;
      end
      else if(MEM_allowin)begin
        MEM_valid <= EXtoMEM_valid;
      end
      if(!resetn)begin
        M_datafromM     <= 1'b0;
        M_write_reg     <= 1'b0;
        M_rd            <= 1'b0;
        M_ra_data       <= 32'b0;
        M_write_result  <= 32'b0;
        M_reg_ra        <= 1'b0;
        M_alu_result    <= 32'b0;
        M_complete      <= 1'b0;
        M_f_hi          <= 1'b0;
        M_f_lo          <= 1'b0;
        M_mul           <= 1'b0;
        // M_cpu_div <= 1'b0;
        M_t_hi          <= 1'b0;
        M_t_lo          <= 1'b0;
        M_lb            <= 1'b0;
        M_lbu           <= 1'b0;
        M_lh            <= 1'b0;
        M_lhu           <= 1'b0;
        M_lwl           <= 1'b0;
        M_lwr           <= 1'b0;
        M_sb            <= 1'b0;
        M_sh            <= 1'b0;
        M_swl           <= 1'b0;
        M_swr           <= 1'b0;
        M_ea            <= 2'b0;
        M_addr_l_excep  <= 1'b0;
        M_addr_s_excep  <= 1'b0;
        // M_lw_lw         <= 1'b0;
        Mrdata_2        <= 32'b0;
        M_inst_mfc0     <= 1'b0;
        M_cpu_div       <= 1'b0;
        M_mfc0_reg      <= 32'b0;
        M_mtc0_wen_status   <= 1'b0;
        M_mtc0_wen_cause    <= 1'b0;
        M_mtc0_wen_compare  <= 1'b0;
        M_mtc0_wen_count    <= 1'b0;
        M_mtc0_wen_epc      <= 1'b0;
        M_exception_commit  <= 1'b0;
        M_eret_commit       <= 1'b0;
        M_inst_in_ds        <= 1'b0;
        M_mtc0_value        <= 32'b0;
        M_inst_syscall      <= 1'b0;
        M_inst_break        <= 1'b0;
        M_unknown_inst      <= 1'b0;
        M_overflow          <= 1'b0;   
        M_addr_l_excep      <= 1'b0;
        M_addr_s_excep      <= 1'b0;
        M_excep_pc          <= 1'b0;    
        M_time_irq          <= 1'b0; 
        M_soft_irq          <= 1'b0;
        M_mtc0_wen          <= 1'b0;
        M_lw_use            <= 1'b0;
        M_div_HI            <= 32'b0;
        M_div_LO            <= 32'b0;
        M_HI_LO             <= 32'b0;
        M_data_sram_addr    <= 32'b0;
        PC_4                <= 32'hbfc00000;
      end
      else if(EXtoMEM_valid && MEM_allowin)begin
        PC_4        <= PC_3;
        M_datafromM <= E_datafromM;
        M_write_reg <= E_write_reg;
        M_rd        <= (E_cpu_div || overflow)?5'b0:E_rd;
        M_ra_data   <= PC_3+8; 
        M_write_result <= (E_reg_imte | ~datafromM | E_write_mem | (E_aluop != 4'd12))?result:E_rdata_2;
        M_HI_LO     <= (E_t_hi | E_t_lo)?E_rdata_1:M_HI_LO;
        M_reg_ra    <= E_reg_ra; 
        M_alu_result <= result;
        M_cpu_div   <= E_cpu_div;
        M_mul       <= E_mul;
        M_complete  <= reg_complete;
        M_f_hi      <= E_f_HI;
        M_f_lo      <= E_f_LO; 
        M_t_hi      <= E_t_hi;
        M_t_lo      <= E_t_lo;
        M_lb        <= E_lb;
        M_lbu       <= E_lbu;
        M_lh        <= E_lh;
        M_lhu       <= E_lhu;
        M_lwl       <= E_lwl;
        M_lwr       <= E_lwr;
        M_sb        <= E_sb;
        M_sh        <= E_sh;
        M_swl       <= E_swl;
        M_swr       <= E_swr;
        M_ea        <= ea;
        // M_lw_lw     <= lw_lw;
        Mrdata_2    <= Erdata_2;
        M_inst_mfc0 <= E_inst_mfc0;
        M_mfc0_reg  <= E_mfc0_reg;
        M_mtc0_wen_status   <= E_mtc0_wen_status;
        M_mtc0_wen_cause    <= E_mtc0_wen_cause;
        M_mtc0_wen_compare  <= E_mtc0_wen_compare;
        M_mtc0_wen_count    <= E_mtc0_wen_count;
        M_mtc0_wen_epc      <= E_mtc0_wen_epc;
        M_exception_commit  <= E_exception_commit | overflow | E_addr_l_excep | E_addr_s_excep;
        M_eret_commit       <= E_eret_commit;
        M_inst_in_ds        <= E_inst_in_ds;
        M_mtc0_value        <= E_mtc0_value;
        M_inst_syscall      <= E_inst_syscall;
        M_inst_break        <= E_inst_break;
        M_unknown_inst      <= E_unknown_inst;
        M_overflow          <= overflow;
        M_excep_pc          <= E_excep_pc;
        M_time_irq          <= E_time_irq;
        M_soft_irq          <= E_soft_irq;
        M_mtc0_wen          <= E_mtc0_wen;
        M_lw_use            <= E_lw_use;
        M_addr_l_excep      <= addr_l_excep;
        M_addr_s_excep      <= addr_s_excep;
        // M_div_HI            <= E_div_HI;
        // M_div_LO            <= E_div_LO;
        M_data_sram_addr    <= data_sram_addr;
        M_div_HI            <= (reg_complete)?r:M_div_HI;
        M_div_LO            <= (reg_complete)?s:M_div_LO;
      end
    end
//WB*****************************************************************************
    wire WB_allowin;
    wire WB_readygo;

    assign WB_allowin = !WB_valid || WB_readygo;
    assign WB_readygo = 1;

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
      else if(MEMtoWB_valid)begin
        W_reg_ra <= M_reg_ra;
      end
      if(!resetn)begin
        W_rd        <= 1'b0;
        W_write_reg <= 1'b0;
        W_ra_data   <= 32'b0;
        W_write_data <= 32'b0;
        // W_datafromM <= 1'b0;
        W_reg_ra  <= 1'b0;
        W_M_data    <= 32'b0;
        W_mtc0_wen <= 1'b0;
        W_mfc0_reg <= 32'b0;
        W_inst_mfc0 <= 1'b0;
        W_inst_syscall <= 1'b0;
        W_inst_break <= 1'b0;
        W_exception_commit <= 1'b0;
        W_eret_commit <= 1'b0;
        // HI <= 32'b0;
        // LO <= 32'b0;
        PC_5 <= 32'hbfc00000;
      end
      else if(MEMtoWB_valid && WB_allowin)begin
        PC_5 <= PC_4;
        W_rd <= waddr;
        W_write_reg <= reg_write;
        W_ra_data <= M_ra_data;
        W_write_data <= write_data;
        W_write_result <= M_write_result;
        // W_datafromM <= M_datafromM;
        W_reg_ra <= M_reg_ra;
        W_M_data <= (M_lwl | M_lwr)?data_sram_half:data_sram_rdata_true;
        // W_complete <= M_complete;
        // W_mul <= M_mul;
        W_mtc0_wen <= M_mtc0_wen;
        W_mfc0_reg <= M_mfc0_reg;
        W_inst_mfc0 <= M_inst_mfc0;
        W_inst_syscall <= M_inst_syscall;
        W_inst_break <= M_inst_break;
        W_exception_commit <= M_exception_commit;
        W_eret_commit <= M_eret_commit;
        HI <= (M_t_hi)?M_HI_LO:
              (M_mul)?mul_result[63:32]:
              (M_complete)?M_div_HI:HI;
        LO <= (M_t_lo)?M_HI_LO:
              (M_mul)?mul_result[31:0]:
              (M_complete)?M_div_LO:LO;
      end
    end
//PC更新*****************************************************************************
    always@(posedge clk)begin
      if(!resetn)begin
        PC <= 32'hbfc00000;
      end
      else if(IFtoID_valid && ID_allowin)begin
        if(M_inst_syscall)begin
          PC <= 32'hbfc00380;
        end
        else if(M_inst_break)begin
          PC <= 32'hbfc00380;
        end
        else if(M_overflow)begin
          PC <= 32'hbfc00380;
        end
        else if(M_addr_l_excep || M_addr_s_excep)begin
          PC <= 32'hbfc00380;
        end
        else if(M_excep_pc)begin
          PC <= 32'hbfc00380;
        end
        else if(M_unknown_inst)begin
          PC <= 32'hbfc00380;
        end
        else if(M_soft_irq)begin
          PC <= 32'hbfc00380;
        end
        else if(M_time_irq)begin
          PC <= 32'hbfc00380;
        end
        else if(M_eret_commit)begin
          PC <= EPC;
        end
        else if(E_pc_offset)begin
          if(E_inst_beq)begin
            PC <= (E_branch_reg_1 == E_branch_reg_2)?{{14{Instruction[15]}},Instruction[15:0],2'b00} + PC:PC + 4;
          end
          else if(E_inst_bne)begin
            PC <= (E_branch_reg_1 != E_branch_reg_2)?{{14{Instruction[15]}},Instruction[15:0],2'b00} + PC:PC + 4;
          end
          else if(E_inst_j)begin
            PC <= {PC[31:28],Instruction[25:0],2'b00};
          end
          else if(E_inst_jal)begin
            PC <= {PC[31:28],Instruction[25:0],2'b00};
          end
          else if(E_inst_jalr || E_inst_jr)begin
            PC <= E_branch_reg_1;
          end
          else if(E_inst_bgez || E_inst_bgezal)begin
            PC <= (E_branch_reg_1[31]==1'b0)?{{14{Instruction[15]}},Instruction[15:0],2'b00}  + PC: PC+4;
          end
          else if(E_inst_bltz || E_inst_bltzal)begin
            PC <= (E_branch_reg_1[31]==1'b1)?{{14{Instruction[15]}},Instruction[15:0],2'b00}  + PC: PC+4;
          end
          else if(E_inst_bgtz)begin
            PC <= (E_branch_reg_1[31]==1'b0 && E_branch_reg_1!=32'b0)?{{14{Instruction[15]}},Instruction[15:0],2'b00} + PC: PC+4;
          end
          else if(E_inst_blez)begin
            PC <= (E_branch_reg_1[31]==1'b1 || E_branch_reg_1==32'b0)?{{14{Instruction[15]}},Instruction[15:0],2'b00} + PC: PC+4;
          end
        end
        else if(cpu_div)begin
          PC <= PC;
        end
        else begin
          PC <= PC + 4;
        end
      end
    end
//ALU端口****************************************************************************
    assign aluop[0] = inst_lui | inst_subu | inst_sltu | inst_xor | inst_nor | inst_srl | inst_sub  | inst_sltiu | inst_xori | inst_srlv;
    assign aluop[1] = inst_lui | inst_slt  | inst_sltu | inst_or  | inst_xor | inst_sra | inst_slti | inst_sltiu | inst_ori  | inst_xori | inst_srav;
    assign aluop[2] = inst_and | inst_or   | inst_xor  | inst_nor | inst_beq | inst_bne | inst_jal  | inst_jr    | inst_andi | inst_ori  | inst_xori | inst_mfhi | inst_mflo | inst_mthi | inst_mtlo | inst_div | inst_divu | inst_mult | inst_multu | inst_j | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bltzal | inst_bgezal | inst_jalr;
    assign aluop[3] = inst_lui | inst_sll  | inst_srl  | inst_sra | inst_beq | inst_bne | inst_jal  | inst_jr    | inst_sllv | inst_srav | inst_srlv | inst_mfhi | inst_mflo | inst_mthi | inst_mtlo | inst_div | inst_divu | inst_mult | inst_multu | inst_j | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bltzal | inst_bgezal | inst_jalr;
    assign alu_left = (inst_move)?((extend_u)?rdata_1:instr_3):rdata_1;
    assign alu_right = (reg_imte || write_mem)?((extend_u)?{16'b0,instr_4,instr_3,instr_2}:{{16{instr_4[4]}},instr_4,instr_3,instr_2}):rdata_2;
    // assign E_rdata_1 = (E_raddr_1 == E_rd && E_raddr_1 != 5'b0)?((E_f_HI | E_f_LO)?((E_f_HI)?wire_hi:wire_lo):((E_inst_mfc0)?E_mfc0_reg:result)):
                      // (E_raddr_1 == M_rd && E_raddr_1 != 5'b0)?W_write_data:
                      // E_alu_left;
    assign E_rdata_1 = (E_raddr_1 == M_rd && E_raddr_1 != 5'b0)?write_data:E_alu_left;
    assign E_rdata_2 = (E_raddr_2 == M_rd && E_raddr_2 != 5'b0 && ~E_reg_rt && ~E_write_mem)?write_data:E_alu_right;
    // assign E_rdata_2 = (E_raddr_2 == E_rd && E_raddr_2 != 5'b0 && ~reg_rt)?((E_f_HI | E_f_LO)?((E_f_HI)?wire_hi:wire_lo):result):
                      // (E_raddr_2 == M_rd && E_raddr_2 != 5'b0 && ~reg_rt && ~write_mem)?W_write_data:
                      // E_alu_right;
//regfile端口************************************************************************
    assign raddr_1  = instr_5[9:5];
    assign raddr_2  = instr_5[4:0]; 
    // assign waddr    = (M_overflow || M_addr_l_excep || M_excep_pc)?5'b0:M_rd;
    assign waddr      = (next_MEM_readygo != 3'd0 || M_addr_l_excep || (data_req && ~data_wr))?5'd0:M_rd;
    assign reg_write  = (~MEM_valid && (next_MEM_readygo == 3'd5 || next_MEM_readygo == 3'd0))?1'b0:M_write_reg;
    // assign wire_M_write_result = (E_reg_imte | ~datafromM | E_write_mem | (E_aluop != 4'd12))?result:M_write_result;
    assign wire_M_write_result = M_write_result;
    assign write_data_temp = (M_datafromM)?((M_lwl | M_lwr)?data_sram_half:data_sram_rdata_true):
                        (M_reg_ra)?M_ra_data:((M_f_hi | M_f_lo)?((M_f_hi)?HI:LO):wire_M_write_result);
                        //(W_mul)?((M_f_lo)?LO:HI)
    assign write_data =(M_inst_mfc0)?M_mfc0_reg:write_data_temp;
    assign data_sram_half = (M_lwl | M_lwr)?((M_lwl)?((M_ea==2'd0)?{data_sram_rdata_true[7:0],Mrdata_2[23:0]}:((M_ea==2'd1)?{data_sram_rdata_true[15:0],Mrdata_2[15:0]}:((M_ea==2'd2)?{data_sram_rdata_true[23:0],Mrdata_2[7:0]}:data_sram_rdata_true))):((M_ea==2'd0)?data_sram_rdata_true:((M_ea==2'd1)?{Mrdata_2[31:24],data_sram_rdata_true[31:8]}:((M_ea==2'd2)?{Mrdata_2[31:16],data_sram_rdata_true[31:16]}:{Mrdata_2[31:8],data_sram_rdata_true[31:24]})))):
                            32'b0;
//branch跳转比较寄存�???????????????????????????????????????????????****************************************************************
    assign  branch_reg_1 = (lw_use)?((raddr_1 == M_rd)?data_sram_rdata_true:rdata_1):
                        (raddr_1 == E_rd && raddr_1 != 5'b0)?((E_f_HI|E_f_LO)?((E_f_HI)?wire_hi:wire_lo):((E_inst_mfc0)?E_mfc0_reg:M_alu_result)):
                        (raddr_1 == M_rd && raddr_1 != 5'b0)?((M_datafromM)?data_sram_rdata_true:((M_f_hi | M_f_lo)?((M_f_hi)?HI:LO):((M_reg_ra)?W_ra_data:((E_inst_mfc0)?E_mfc0_reg:M_alu_result)))):
                        rdata_1;
    // assign branch_reg_1 = rdata_1;
    // assign branch_reg_2 = rdata_2;
    assign  branch_reg_2 = (lw_use)?((raddr_2 == M_rd)?data_sram_rdata_true:rdata_2):
                        (raddr_2 == E_rd && raddr_2 != 5'b0 && ~reg_rt)?((E_f_HI|E_f_LO)?((E_f_HI)?wire_hi:wire_lo):((E_inst_mfc0)?E_mfc0_reg:M_alu_result)):
                        (raddr_2 == M_rd && raddr_2 != 5'b0 && ~reg_rt)?((M_datafromM)?data_sram_rdata_true:((M_f_hi | M_f_lo)?((M_f_hi)?HI:LO):((E_inst_mfc0)?E_mfc0_reg:M_alu_result))):
                        rdata_2;
//除法器端�??????????**********************************************************************************************************
    assign  cpu_beichu = (raddr_1 == E_rd && raddr_1 != 5'b0)?result:
                      (raddr_1 == M_rd && raddr_1 != 5'b0)?((M_datafromM)?data_sram_rdata_true:((M_reg_ra)?W_ra_data:M_alu_result)):
                      alu_left;
    assign cpu_chu     = (raddr_2 == E_rd && raddr_2 != 5'b0 && ~reg_rt)?result:
                      (raddr_2 == M_rd && raddr_2 != 5'b0 && ~reg_rt && ~E_write_mem)?((M_datafromM)?data_sram_rdata_true:M_alu_result):
                      alu_right;
    assign wire_hi = (M_t_hi)?M_write_result:
                      (M_mul)?mul_result[63:32]:
                      (M_complete)?M_div_HI:HI;
    assign wire_lo = (M_t_lo)?M_write_result:
                      (M_mul)?mul_result[31:0]:
                      (M_complete)?M_div_LO:LO;

//例外处理*****************************************************************************************************************
    assign STATUS_BEV = 1'b1;
    assign STATUS = { {9{1'b0}} ,//31:23
                     STATUS_BEV ,//22
                     6'd0       ,//21:16
                     STATUS_IM  ,//15:8
                     6'd0       ,//7:2
                     STATUS_EXL ,
                     STATUS_IE  
                    }; 

    assign CAUSE = {CAUSE_BD  ,//31
                    CAUSE_TI  ,//30
                    14'd0     ,//29:16
                    CAUSE_IP  ,//15:8
                    1'd0      ,//7
                    CAUSE_EXCODE ,//6:2
                    2'd0      
                    };

    // assign mtc0_value = rdata_2;
    always@(posedge clk)
    begin
      if(!resetn)
      begin
        STATUS_IM <= 8'b11111111;
      end
      else if(M_mtc0_wen_status && MEMtoWB_valid && WB_allowin)
      begin
        STATUS_IM <= M_mtc0_value[15:8];
      end
      else
      begin
      end
    end

    always@(posedge clk)
    begin
      if(!resetn)
      begin
        STATUS_IE <= 1'b0;
      end
      else if(M_time_irq && MEMtoWB_valid && WB_allowin && !STATUS_EXL)
      begin
        STATUS_IE <= 1'b1;
      end
      else if(M_soft_irq && MEMtoWB_valid && WB_allowin && !STATUS_EXL)
      begin
        STATUS_IE <= 1'b1;
      end
      else if(M_mtc0_wen_status && MEMtoWB_valid && WB_allowin)
      begin
        STATUS_IE <= M_mtc0_value[0];
      end
      else 
      begin
      end
    end

    always@(posedge clk)
    begin
        if(!resetn)
        begin
            STATUS_EXL <= 1'b0;
        end
        else if(M_time_irq && MEMtoWB_valid && WB_allowin)
        begin
            STATUS_EXL <= 1'b1;
        end
        else if(M_soft_irq && MEMtoWB_valid && WB_allowin)
        begin
            STATUS_EXL <= 1'b1;
        end
        else if(M_mtc0_wen_status && MEMtoWB_valid && WB_allowin)
        begin
            STATUS_EXL <= M_mtc0_value[1];
        end
        else if(M_excep_pc && MEMtoWB_valid && WB_allowin)
        begin
            STATUS_EXL <= 1'b1;
        end
        else if((M_exception_commit || M_addr_l_excep || M_addr_s_excep) && MEMtoWB_valid && WB_allowin)
        begin
            STATUS_EXL <= 1'b1;
        end
        else if(M_eret_commit && MEMtoWB_valid && WB_allowin)
        begin
            STATUS_EXL <= 1'b0;
        end
        else
        begin
        end
    end 

    always@(posedge clk)
    begin
      if(!resetn)
      begin
        CAUSE_BD <= 1'b0;
      end
      else if(M_mtc0_wen_cause && MEMtoWB_valid && WB_allowin)
      begin
        CAUSE_BD <= M_mtc0_value[31];
      end
      else if((M_exception_commit || M_addr_l_excep || M_addr_s_excep) && !STATUS_EXL && MEMtoWB_valid && WB_allowin)
      begin
        CAUSE_BD <= M_inst_in_ds ? 1'b1:1'b0;
      end
      else
      begin
      end
    end

    always@(posedge clk)
    begin
        if(!resetn)
        begin
            CAUSE_TI <= 1'b0;
        end
        else if(M_mtc0_wen_cause && MEMtoWB_valid && WB_allowin)
        begin
            CAUSE_TI <= M_mtc0_value[30];
        end
        else if(M_time_irq && MEMtoWB_valid && WB_allowin && !STATUS_EXL)
        begin
            CAUSE_TI <= 1'b1;
        end
        else if(M_mtc0_wen_compare && MEMtoWB_valid && WB_allowin)
        begin
            CAUSE_TI <= 1'b0;
        end
        else
        begin
        end
    end 

    always@(posedge clk)
    begin
      if(!resetn)
      begin
        CAUSE_IP <= 8'b0;
      end
      else if(M_mtc0_wen_cause && MEMtoWB_valid && WB_allowin)
      begin
        CAUSE_IP <= M_mtc0_value[15:8];
      end
      else
      begin
      end
    end

    always@(posedge clk)
    begin
      if(!resetn)
      begin
        CAUSE_EXCODE <= 5'b0;
      end
      else if(M_time_irq && MEMtoWB_valid && WB_allowin && !STATUS_EXL)
      begin
        CAUSE_EXCODE <= 5'b0;
      end
      else if(M_soft_irq && MEMtoWB_valid && WB_allowin && !STATUS_EXL)
      begin
        CAUSE_EXCODE <= 5'b0;
      end
      else if(M_mtc0_wen_cause && MEMtoWB_valid && WB_allowin)
      begin
        CAUSE_EXCODE <= M_mtc0_value[6:2];
      end
      else if((M_inst_syscall) && !STATUS_EXL && MEMtoWB_valid && WB_allowin)
      begin
        CAUSE_EXCODE <= 5'b01000;
      end
      else if((M_inst_break) && !STATUS_EXL && MEMtoWB_valid && WB_allowin)
      begin
        CAUSE_EXCODE <= 5'b01001;
      end
      else if((M_overflow) && !STATUS_EXL && MEMtoWB_valid && WB_allowin)
      begin
        CAUSE_EXCODE <= 5'b01100;
      end
      else if((M_addr_l_excep || M_excep_pc) && !STATUS_EXL && MEMtoWB_valid && WB_allowin)
      begin
        CAUSE_EXCODE <= 5'b00100;
      end
      else if((M_addr_s_excep) && !STATUS_EXL && MEMtoWB_valid && WB_allowin)
      begin
        CAUSE_EXCODE <= 5'b00101;
      end
      else if((M_unknown_inst) && !STATUS_EXL && MEMtoWB_valid && WB_allowin)
      begin
        CAUSE_EXCODE <= 5'b01010;
      end
      else
      begin
      end
    end

    always@(posedge clk)
    begin
        if(!resetn)
        begin
            EPC <= 32'b0;
        end
        else if(M_mtc0_wen_epc && MEMtoWB_valid && WB_allowin)
        begin
            EPC <= M_mtc0_value;
        end
        else if(M_time_irq && MEMtoWB_valid && WB_allowin && !STATUS_EXL)
        begin
            EPC <= M_inst_in_ds ? PC_4-3'd4:PC_4;
        end
        else if(M_soft_irq && MEMtoWB_valid && WB_allowin && !STATUS_EXL)
        begin
            EPC <= PC_4;
        end
        else if(M_excep_pc && MEMtoWB_valid && WB_allowin && !STATUS_EXL)
        begin
            EPC <= PC_4;
        end
        else if((M_exception_commit || M_addr_l_excep || M_addr_s_excep) && MEMtoWB_valid && WB_allowin && !STATUS_EXL)
        begin
            EPC <= M_inst_in_ds ? PC_4-3'd4:PC_4;
        end
        else
        begin
        end
    end

    always@(posedge clk)
    begin
      if(!resetn)
      begin
        COUNT <= 32'b0;
        count_step <= 1'b0;
      end
      else if(M_mtc0_wen_count && MEMtoWB_valid && WB_allowin)
      begin
        COUNT <= M_mtc0_value;
        count_step <= 1'b0;
      end
      else if(count_step == 1'b0)
      begin
        COUNT <= COUNT;
        count_step <= count_step + 1'b1;
      end
      else if(count_step == 1'b1)
      begin
        COUNT <= COUNT + 1;
        count_step <= 1'b0;
      end
      else
      begin
      end
    end

    always@(posedge clk)
    begin
      if(!resetn)
      begin
        COMPARE <= 32'b0;
      end
      else if(M_mtc0_wen_compare && MEMtoWB_valid && WB_allowin)
      begin
        COMPARE <= M_mtc0_value;
      end
      else
      begin
      end
    end

    always@(posedge clk)
    begin
      if(!resetn)
      begin
        BADVADDR <= 32'b0;
      end
      else if((M_addr_l_excep || M_addr_s_excep) && MEMtoWB_valid && WB_allowin && !STATUS_EXL)
      begin
        BADVADDR <= M_data_sram_addr;
      end
      else if(M_excep_pc && MEMtoWB_valid && WB_allowin && !STATUS_EXL)
      begin
        BADVADDR <= PC_4;
      end
      else
      begin
      end
    end

endmodule