# MIPS Multicycle Processor – Harshdeep Singh

Welcome!  
I’m **Harshdeep Singh**, and this repository implements a classic **32-bit MIPS Multicycle Processor** in Verilog.  
It re-uses one ALU and one memory port over **13 micro-cycles** (states 0–12) to execute exactly **14 instructions**:

1. `add`  
2. `sub`  
3. `and`  
4. `or`  
5. `lw`  
6. `sw`  
7. `slt`  
8. `srl`  
9. `beq`  
10. `bne`  
11. `j`  
12. `jal`  
13. `sltiu`  
14. `lhu`  

---

## 📁 Repository Layout

```text
MIPS_Multicycle/
├── src/                          # All synthesizable Verilog modules
│   ├── pc.v                      # Program Counter register
│   ├── mux_pc_alu.v              # IorD MUX: selects PC or ALUOut for memory address
│   ├── memory.v                  # Combined instruction/data memory + mem_mode
│   ├── IR.v                      # Instruction Register
│   ├── MDR.v                     # Memory Data Register
│   ├── reg_file.v                # 32×32 register file
│   ├── A_reg.v                   # A register (latches rs data)
│   ├── B_reg.v                   # B register (latches rt data)
│   ├── sign_ext.v                # Sign/zero-extender
│   ├── shift_left_2.v            # Branch-offset shifter
│   ├── shift_left_2_jump.v       # Jump-address shifter
│   ├── alusrcA_mux.v             # ALUSrcA MUX (PC or A)
│   ├── alusrcB_mux.v             # ALUSrcB MUX (B, 4, imm, imm<<2)
│   ├── alu_control.v             # ALUOp + funct → 3-bit ALU_control
│   ├── alu.v                     # ALU core: AND/OR/ADD/SUB/SLT/SRL/SLTIU
│   ├── alu_out_reg.v             # ALUOut pipeline register
│   ├── regdst_mux.v              # RegDst MUX (rt, rd, $ra for jal)
│   ├── memtoreg_mux.v            # MemtoReg MUX (ALUOut, MDR, PC+4 for jal)
│   ├── pc_source_mux.v           # PCSource MUX (PC+4, branch target, jump addr)
│   └── control_fsm.v             # Finite-State Machine (13 states)
├── tb/                           # Testbench & program memory
│   ├── multi_cycle_processor_tb.v  # Stimulus driver & waveform logger
│   └── program.mem               # 14×32-bit instruction hex words
├── docs/
│   └── img/
│       ├── datapath.png          # Multicycle datapath diagram
│       └── control_fsm.png       # Control FSM diagram
└── README.md                     # This file
```

## 🖼️ Architecture Diagrams

### Multicycle Datapath

![Multicycle Datapath](docs/img/datatapath.png)

Blue arrows = data flow | Orange arrows = control signals

### Control FSM

![Control FSM](docs/img/control_fsm.png)

Walks through **13 states** (0–12), asserting only the needed control signals each cycle.

## 🎛️ Control-Signals Used

### 1-bit Signals

| Signal       | **0** Description                         | **1** Description                                           |
|--------------|-------------------------------------------|-------------------------------------------------------------|
| **RegDst**   | Write register = `rt`                     | Write register = `rd` (or `$ra` if `Jal = 1`)               |
| **RegWrite** | No register write                         | Enable register-file write                                  |
| **ALUSrcA**  | ALU A input = `PC`                        | ALU A input = latched A register                            |
| **MemRead**  | No memory read                            | Read from memory at selected address                        |
| **MemWrite** | No memory write                           | Write to memory at selected address                         |
| **IorD**     | Address = `PC` (instruction fetch)        | Address = `ALUOut` (data access)                            |
| **IRWrite**  | Do not load IR                            | Load fetched instruction into IR                            |
| **MemtoReg** | Write-back data = `ALUOut`                | Write-back data = `MDR` (memory output)                     |
| **PCWrite**  | Do not update PC                          | Unconditional PC ← PC_in                                    |
| **PCWriteCond** | Do not update PC                      | Conditional PC ← PC_in if (`Zero` ⊕ `Bne`)                   |
| **ExtSel**   | Zero-extend immediate                     | Sign-extend immediate                                       |
| **MemHalf**  | Word access (`lw`/`sw`)                   | Half-word access (`lhu`), zero-extended                     |
| **Bne**      | Compare equal (for `beq`)                 | Compare not equal (for `bne`)                               |
| **Jal**      | Normal write-back                         | `$ra ← PC+4`, then jump                                      |
| **A_Load**   | Hold previous A                           | Latch `A ← Reg[rs]`                                         |
| **B_Load**   | Hold previous B                           | Latch `B ← Reg[rt]`                                         |

### 2-bit Signals

| Signal      | **00**                                    | **01**                           | **10**                                | **11**                       |
|-------------|-------------------------------------------|----------------------------------|---------------------------------------|------------------------------|
| **ALUOp**   | ADD (PC+4, `lw`/`sw`/`jal`)               | SUB (for `beq`/`bne`)            | Use `funct` field (R-type)            | SLTIU (unsigned compare)     |
| **ALUSrcB** | ALU B input = B register                  | ALU B input = constant `4`       | ALU B input = sign/zero-extended imm  | ALU B input = imm << 2 (branch) |
| **PCSource**| PC_in = `ALUOut` (PC+4)                   | PC_in = `ALUOut` (branch target) | PC_in = jump address `{PC[31:28],instr<<2}` | —                            |

### 🧩 FSM State Control Matrix

| #  | State            | Purpose / Action                                 | Signals asserted                                                                                         |
|----|------------------|--------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| 0  | **FETCH**        | Fetch instruction, compute PC+4                  | `MemRead=1`, `IRWrite=1`, `PCWrite=1`, **ALUSrcA=0**, **ALUSrcB=01**, **ALUOp=00**, **PCSource=00**      |
| 1  | **DECODE**       | Decode, extend imm, latch A/B                    | `A_Load=1`, `B_Load=1`, **ALUSrcA=0**, **ALUSrcB=11**, **ALUOp=00**, `ExtSel=0` (only for `sltiu`)     |
| 2  | **MEM_ADDR**     | Compute address for `lw`/`sw`/`lhu`              | **ALUSrcA=1**, **ALUSrcB=10**, **ALUOp=00**                                                               |
| 3  | **MEM_READ**     | Read data (`lw`/`lhu`)                           | `MemRead=1`, `IorD=1`, `MemHalf=1` (if `lhu`)                                                            |
| 4  | **MEM_WB**       | Write loaded data back to RF                     | `RegWrite=1`, `MemtoReg=1`, `RegDst=0`                                                                   |
| 5  | **MEM_WRITE**    | Store register data to memory (`sw`)             | `MemWrite=1`, `IorD=1`                                                                                   |
| 6  | **EXECUTE**      | Perform ALU op for R-type                        | **ALUSrcA=1**, **ALUSrcB=00**, **ALUOp=10**                                                               |
| 7  | **ALU_WB**       | Write ALU result back to RF (R-type)             | `RegDst=1`, `RegWrite=1`, `MemtoReg=0`                                                                   |
| 8  | **BRANCH**       | Evaluate `beq`/`bne`, conditionally update PC    | **ALUSrcA=1**, **ALUSrcB=00**, **ALUOp=01**, **PCSource=01**, `PCWriteCond=1`, `Bne=1` (if `bne`)           |
| 9  | **JUMP**         | Unconditional jump (`j`)                         | `PCWrite=1`, **PCSource=10**                                                                             |
| 10 | **JAL_WRITE_RA** | `$ra ← PC+4`, then jump (`jal`)                  | `Jal=1`, `RegWrite=1`, `PCWrite=1`, **PCSource=10**                                                       |
| 11 | **SLTIU_EXEC**   | Perform unsigned compare (`sltiu`)               | **ALUSrcA=1**, **ALUSrcB=10**, **ALUOp=11**                                                               |
| 12 | **SLTIU_WB**     | Write `sltiu` result back to RF                  | `RegWrite=1`, `MemtoReg=0`, `RegDst=0`                                                                   |


## 📝 Sample Program & Testbench

### Instruction file: `tb/program.mem`

```text
01095020    // add $t2, $t0, $t1       $t2 = $t0 + $t1
01095822    // sub $t3, $t0, $t1       $t3 = $t0 - $t1
01096024    // and $t4, $t0, $t1       $t4 = $t0 & $t1
01096825    // or  $t5, $t0, $t1       $t5 = $t0 | $t1
2D0A0001    // sltiu $t2, $t0, 1       $t2 = ($t0 < 1) ? 1 : 0 (unsigned)                       
AD0B0004    // sw  $t3, 4($t0)         Memory[$t0 + 4] = $t3                      
8D0C0004    // lw  $t4, 4($t0)         $t4 = Memory[$t0 + 4]
0109702A    // slt $t6, $t0, $t1       $t6 = ($t0 < $t1) ? 1 : 0
950C0002    // lhu $t4, 2($t0)         $t4 = zero-extended MEM[$t0 + 2] (16-bit load)
11090002    // beq $t0, $t1, +2        if ($t0 == $t1) PC += 8 
15090002    // bne $t0, $t1, +2        if ($t0 != $t1) PC += 8 
0C00000D    // jal 0x0000000D          $ra = PC+4, PC = 0x0000000D
0800000C    // j   0x0000000C          PC = 0x0000000C
```

### Testbench: `tb/multi_cycle_processor_tb.v`

```verilog
initial begin
    // 1) Reset & clock
    clk   = 0;
    reset = 1;
    #10   reset = 0;

    // 2) Preload register file
    uut.REGFILE.registers[8]  = 32'd5;    // $t0
    uut.REGFILE.registers[9]  = 32'd3;    // $t1
    uut.REGFILE.registers[11] = 32'd99;   // $t3

    // 3) Preload data memory
    uut.MEM.memory[0] = 32'h0000ABCD;
    uut.MEM.memory[1] = 32'hDEADBEEF;

    // 4) Load instructions into memory[0..13]
    $readmemh("program.mem", uut.MEM.memory);

    // Run for ~200 cycles; summary printed each time FSM returns to FETCH
    for (i = 0; i < 200; i = i + 1) begin
        @(posedge clk);
        if (prev_state != 4'd0 && uut.FSM.state == 4'd0)
            display_cycle_info();
        prev_state = uut.FSM.state;
    end

    $finish;
end

// Clock generation: toggle every 5 ns
always #5 clk = ~clk;
```
Clock toggles every 5 ns, and the testbench runs ~200 cycles, printing a summary each time the FSM re-enters **FETCH**.


