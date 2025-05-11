`timescale 1ns / 1ps

module control_fsm (
    input  clk,
    input  reset,
    input  [5:0] opcode,
    input  zero,

    output reg PCWrite,
    output reg PCWriteCond,
    output reg IorD,
    output reg MemRead,
    output reg MemWrite,
    output reg IRWrite,
    output reg MemtoReg,
    output reg RegDst,
    output reg RegWrite,
    output reg ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [1:0] ALUOp,
    output reg [1:0] PCSource,
    output reg ExtSel,
    output reg MemHalf,
    output reg Bne,
    output reg Jal,
    output reg A_Load,
    output reg B_Load
);

    localparam FETCH            = 4'd0;
    localparam DECODE           = 4'd1;
    localparam MEM_ADDR         = 4'd2;
    localparam MEM_READ         = 4'd3;
    localparam MEM_WRITEBACK    = 4'd4;
    localparam MEM_WRITE        = 4'd5;
    localparam EXECUTE          = 4'd6;
    localparam ALU_WRITEBACK    = 4'd7;
    localparam BRANCH           = 4'd8;
    localparam JUMP             = 4'd9;
    localparam JAL_WRITE_RA     = 4'd10;
    localparam SLTIU_EXECUTE    = 4'd11;
    localparam SLTIU_WRITEBACK  = 4'd12;

    reg [3:0] state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= FETCH;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            FETCH:             next_state = DECODE;
            DECODE: begin
                case (opcode)
                    6'b100011, 6'b100101: next_state = MEM_ADDR;
                    6'b101011:            next_state = MEM_ADDR;
                    6'b000000:            next_state = EXECUTE;
                    6'b001011:            next_state = SLTIU_EXECUTE;
                    6'b000100, 6'b000101: next_state = BRANCH;
                    6'b000010:            next_state = JUMP;
                    6'b000011:            next_state = JAL_WRITE_RA;
                    default:              next_state = FETCH;
                endcase
            end
            MEM_ADDR: begin
                case (opcode)
                    6'b100011, 6'b100101: next_state = MEM_READ;
                    6'b101011:            next_state = MEM_WRITE;
                    default:              next_state = FETCH;
                endcase
            end
            MEM_READ:         next_state = MEM_WRITEBACK;
            MEM_WRITEBACK:    next_state = FETCH;
            MEM_WRITE:        next_state = FETCH;
            EXECUTE:          next_state = ALU_WRITEBACK;
            ALU_WRITEBACK:    next_state = FETCH;
            SLTIU_EXECUTE:    next_state = SLTIU_WRITEBACK;
            SLTIU_WRITEBACK:  next_state = FETCH;
            BRANCH:           next_state = FETCH;
            JUMP:             next_state = FETCH;
            JAL_WRITE_RA:     next_state = FETCH;
            default:          next_state = FETCH;
        endcase
    end

    always @(*) begin
        PCWrite     = 0;
        PCWriteCond = 0;
        IorD        = 0;
        MemRead     = 0;
        MemWrite    = 0;
        IRWrite     = 0;
        MemtoReg    = 0;
        RegDst      = 0;
        RegWrite    = 0;
        ALUSrcA     = 0;
        ALUSrcB     = 2'b00;
        ALUOp       = 2'b00;
        PCSource    = 2'b00;
        ExtSel      = 1;
        MemHalf     = 0;
        Bne         = 0;
        Jal         = 0;
        A_Load      = 0;
        B_Load      = 0;

        case (state)
            FETCH: begin
                MemRead  = 1;
                IRWrite  = 1;
                ALUSrcA  = 0;
                ALUSrcB  = 2'b01;
                ALUOp    = 2'b00;
                PCWrite  = 1;
                PCSource = 2'b00;
            end
            DECODE: begin
                ALUSrcA  = 0;
                ALUSrcB  = 2'b11;
                ALUOp    = 2'b00;
                A_Load   = 1;
                B_Load   = 1;
                case (opcode)
                    6'b001011: ExtSel = 0;
                    default:   ExtSel = 1;
                endcase
            end
            MEM_ADDR: begin
                ALUSrcA = 1;
                ALUSrcB = 2'b10;
                ALUOp   = 2'b00;
            end
            MEM_READ: begin
                MemRead = 1;
                IorD    = 1;
                if (opcode == 6'b100101)
                    MemHalf = 1;
            end
            MEM_WRITEBACK: begin
                RegDst   = 0;
                RegWrite = 1;
                MemtoReg = 1;
            end
            MEM_WRITE: begin
                MemWrite = 1;
                IorD     = 1;
            end
            EXECUTE: begin
                ALUSrcA = 1;
                ALUSrcB = 2'b00;
                ALUOp   = 2'b10;
            end
            ALU_WRITEBACK: begin
                RegDst   = 1;
                ALUSrcA  = 1;
                RegWrite = 1;
                MemtoReg = 0;
            end
            SLTIU_EXECUTE: begin
                ALUSrcA = 1;
                ALUSrcB = 2'b10;
                ALUOp   = 2'b11;
            end
            SLTIU_WRITEBACK: begin
                RegDst   = 0;
                RegWrite = 1;
                MemtoReg = 0;
            end
            BRANCH: begin
                ALUSrcA     = 1;
                ALUSrcB     = 2'b00;
                ALUOp       = 2'b01;
                PCSource    = 2'b01;
                PCWriteCond = 1;
                if (opcode == 6'b000101)
                    Bne = 1;
            end
            JUMP: begin
                PCWrite  = 1;
                PCSource = 2'b10;
            end
            JAL_WRITE_RA: begin
                Jal      = 1;
                RegWrite = 1;
                PCWrite  = 1;
                PCSource = 2'b10;
            end
        endcase
    end
endmodule
