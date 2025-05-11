`timescale 1ns / 1ps

module multi_cycle_processor(
    input clk,
    input reset
);
   
    wire [31:0] instruction;
    wire [5:0]  opcode;
    wire [4:0]  rs, rt, rd, shamt;
    wire [5:0]  funct;
    wire [15:0] imm;
    wire [25:0] jump_addr;

    
    wire PCWrite, PCWriteCond, IorD, MemRead, MemWrite, IRWrite;
    wire RegDst, RegWrite, MemtoReg, ALUSrcA, ExtSel, Jal;
    wire A_Load, B_Load; 
    wire [1:0] ALUSrcB, PCSource, ALUOp;

  
    wire [31:0] pc_out, pc_in;
    wire [31:0] alu_result, alu_in_a, alu_in_b;
    wire [31:0] reg_data1, reg_data2, write_data;
    wire [31:0] mem_data_out, sign_ext_out;
    wire [31:0] alu_out_reg_out, mdr_out;
    wire [31:0] A, B;
    wire [31:0] branch_offset, jump_address;
    wire [2:0]  ALU_control;
    wire [4:0]  write_reg;
    wire        zero_flag;

   
   wire branch_taken;
assign branch_taken = PCWriteCond & (zero_flag ^ Bne); 

    pc PC (
    .clk(clk),
    .reset(reset),
    .pc_write(PCWrite | branch_taken), 
    .pc_in(pc_in),
    .pc_out(pc_out)
    );


   
    wire [31:0] mem_addr;
    mux_pc_alu ADDR_MUX (
        .pc_out(pc_out),
        .aluoutreg(alu_out_reg_out),
        .IorD(IorD),
        .address_out(mem_addr)
    );

    
    memory MEM (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .mem_mode({1'b0, MemHalf}),
        .address(mem_addr),
        .Data(B),
        .mem_data_out(mem_data_out)
    );

   
    IR instr_reg (
        .clk(clk),
        .reset(reset),
        .IRWrite(IRWrite),
        .mem_data_out(mem_data_out),
        .opcode(opcode),
        .funct(funct),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .shamt(shamt),
        .imm(imm),
        .address(jump_addr)
    );

    
    MDR MDR_reg (
        .clk(clk),
        .reset(reset),
        .mem_data_out(mem_data_out),
        .MDR_out(mdr_out)
    );

    
    reg_file REGFILE (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .rs(rs),
        .rt(rt),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

   
    A_reg A_register (
        .clk(clk),
        .reset(reset),
        .A_Load(A_Load),               
        .read_data1(reg_data1),
        .A_out(A)
    );

    B_reg B_register (
        .clk(clk),
        .reset(reset),
        .B_Load(B_Load),               
        .read_data2(reg_data2),
        .B_out(B)
    );

   
    sign_ext SE (
        .imm(imm),
        .ExtSel(ExtSel),
        .imm_ext(sign_ext_out)
    );

   
    shift_left_2 SHIFT_BRANCH (
        .imm_ext(sign_ext_out),
        .shift_left(branch_offset)
    );

    
    shift_left_2_jump SHIFT_JUMP (
        .address(jump_addr),
        .pc_out(pc_out),
        .jump_address(jump_address)
    );

    
    AlusrcA_mux ALU_SRC_A_MUX (
        .pc_out(pc_out),
        .A_out(A),
        .ALUSrcA(ALUSrcA),
        .alu_src_a_out(alu_in_a)
    );

    
    alusrcb_mux ALU_SRC_B_MUX (
        .B_out(B),
        .imm_ext(sign_ext_out),
        .shift_left(branch_offset),
        .const_4(32'd4),
        .ALUSrcB(ALUSrcB),
        .alu_src_b_out(alu_in_b)
    );

   
    alu_control ALU_CTRL (
        .ALUOp(ALUOp),
        .funct(funct),
        .ALU_control(ALU_control)
    );

    
    alu ALU (
        .alu_src_a_out(alu_in_a),
        .alu_src_b_out(alu_in_b),
        .ALU_control(ALU_control),
        .ALUOut(alu_result),
        .Zero(zero_flag)
    );

    
    alu_out_reg ALU_OUT_REG (
        .clk(clk),
        .reset(reset),
        .ALUOut(alu_result),
        .aluoutreg(alu_out_reg_out)
    );

    
    regdst_mux REGDST_MUX (
        .RegDst({Jal, RegDst}),
        .rt(rt),
        .rd(rd),
        .write_reg(write_reg)
    );

   
    memtoreg_mux MEMTOREG_MUX (
        .MemtoReg(MemtoReg),
        .alu_out_reg(alu_out_reg_out),
        .MDR_out(mdr_out),
        .write_data(write_data)
    );

   
    pc_source_mux PC_SRC_MUX (
        .PCSource(PCSource),
        .ALUOut(alu_result),
        .aluoutreg(alu_out_reg_out),
        .jump_address(jump_address),
        .pc_in(pc_in)
    );

    
    control_fsm FSM (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .zero(zero_flag),

        .PCWrite(PCWrite),
        .PCWriteCond(PCWriteCond),
        .IorD(IorD),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .IRWrite(IRWrite),
        .MemtoReg(MemtoReg),
        .RegDst(RegDst),
        .RegWrite(RegWrite),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ALUOp(ALUOp),
        .PCSource(PCSource),
        .ExtSel(ExtSel),
        .MemHalf(MemHalf),
        .Bne(Bne),
        .Jal(Jal),
        .A_Load(A_Load),     
        .B_Load(B_Load)      // 👈 NEW wire connected to FSM
    );

endmodule
