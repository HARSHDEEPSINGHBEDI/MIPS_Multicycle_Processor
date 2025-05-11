`timescale 1ns/1ps

module multi_cycle_processor_tb;

    reg clk;
    reg reset;
    integer i;
    reg [3:0] prev_state;

    multi_cycle_processor uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        $display("\n==== Multicycle MIPS Processor Test ====\n");

        clk = 0;
        reset = 1;
        prev_state = 4'd15;

        #10 reset = 0;
        
        
        // here i have initialized some reg and mem values to test my isntructions 
        
        uut.REGFILE.registers[8]  = 32'd5;
        uut.REGFILE.registers[9]  = 32'd3;
        uut.REGFILE.registers[11] = 32'd99;

        uut.MEM.memory[0] = 32'h0000ABCD;
        uut.MEM.memory[1] = 32'hDEADBEEF;
        
        
        // to load instructions i have used the program.mem file that includes all 14 unatructions as told 
        $readmemh("program.mem", uut.MEM.memory);

        $display("Loaded Instructions:");
        for (i = 0; i < 14; i = i + 1)
            $display("  memory[%0d] = 0x%h", i, uut.MEM.memory[i]);

        for (i = 0; i < 200; i = i + 1) begin
            @(posedge clk);

            if (prev_state != 4'd0 && uut.FSM.state == 4'd0)
                display_cycle_info();

            prev_state = uut.FSM.state;
        end

        display_final_state();
        $finish;
    end

    task display_cycle_info;
        reg [31:0] instr;
        reg [5:0] opcode, funct;
        reg [4:0] rs, rt, rd;
        begin
            instr  = uut.instruction;
            opcode = instr[31:26];
            rs     = instr[25:21];
            rt     = instr[20:16];
            rd     = instr[15:11];
            funct  = instr[5:0];

            $display("\n[Instr Done @ %0t ns] | PC = %0d | Instruction = 0x%h", $time, uut.pc_out, instr);

            case (opcode)
                6'b000000: begin
                    case (funct)
                        6'b100000: $display("   [ADD]   R%0d = R%0d + R%0d", rd, rs, rt);
                        6'b100010: $display("   [SUB]   R%0d = R%0d - R%0d", rd, rs, rt);
                        6'b100100: $display("   [AND]   R%0d = R%0d & R%0d", rd, rs, rt);
                        6'b100101: $display("   [OR]    R%0d = R%0d | R%0d", rd, rs, rt);
                        6'b101010: $display("   [SLT]   R%0d = (R%0d < R%0d)", rd, rs, rt);
                        6'b000010: $display("   [SRL]   R%0d = R%0d >> shamt", rt, rt);
                        default:   $display("   [UNKNOWN R-TYPE] funct = %b", funct);
                    endcase
                end
                6'b100011: $display("   [LW]    R%0d <- MEM[R%0d + offset]", rt, rs);
                6'b100101: $display("   [LHU]   R%0d <- MEM[R%0d + offset] (halfword, zero-extend)", rt, rs);
                6'b101011: $display("   [SW]    MEM[R%0d + offset] <- R%0d", rs, rt);
                6'b001011: $display("   [SLTIU] R%0d = (R%0d < imm)? 1 : 0 (unsigned)", rt, rs);
                6'b000100: $display("   [BEQ]   if (R%0d == R%0d) branch", rs, rt);
                6'b000101: $display("   [BNE]   if (R%0d != R%0d) branch", rs, rt);
                6'b000010: $display("   [JUMP]  PC <- jump address");
                6'b000011: $display("   [JAL]   $ra <- PC+4; PC <- jump address");
                default:   $display("   [UNKNOWN OPCODE] = %b", opcode);
            endcase

            if (uut.RegWrite) begin
                if (uut.Jal)
                    $display("   => $ra (R31) updated with: %h", uut.REGFILE.registers[31]);
                else if (uut.RegDst && opcode == 6'b000000)
                    $display("   => R%0d updated with: %h", rd, uut.REGFILE.registers[rd]);
                else
                    $display("   => R%0d updated with: %h", rt, uut.REGFILE.registers[rt]);
            end
        end
    endtask

    task display_final_state;
        begin
            $display("\n==== Final Register + Memory State ====");
            $display("   $t0 = %d | $t1 = %d | $t2 = %d | $t3 = %d",
                     uut.REGFILE.registers[8],  uut.REGFILE.registers[9],
                     uut.REGFILE.registers[10], uut.REGFILE.registers[11]);
            $display("   $t4 = %d | $t5 = %d | $t6 = %d | $ra = %d",
                     uut.REGFILE.registers[12], uut.REGFILE.registers[13],
                     uut.REGFILE.registers[14], uut.REGFILE.registers[31]);
            $display("   Mem[0] = 0x%h | Mem[1] = 0x%h",
                     uut.MEM.memory[0], uut.MEM.memory[1]);
            $display("==== Simulation Complete ====\n");
        end
    endtask

endmodule
