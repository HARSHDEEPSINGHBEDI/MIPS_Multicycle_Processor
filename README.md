# MIPS Multicycle Processor – Harshdeep Singh

Welcome!  
I’m **Harshdeep Singh**, and this repo demonstrates a 32-bit **MIPS Multicycle Processor**—one ALU, one memory port, 13 control states.

---

## 📁 Folder Map

| Path | Contents |
|------|----------|
| **src/** | All synthesizable Verilog modules |
| **tb/** | Test-bench &nbsp;+&nbsp;`program.mem` sample program |
| **docs/img/** | Architecture figures (datapath & FSM) |
| **MIPS_Multicycle.xpr** | *(optional)* Vivado project |
| **README.md** | You’re reading it |

---

## 🖼️ Architecture Diagrams

### Datapath

![Multicycle Datapath](docs/img/datatapath.png)

*Blue = data* | *Orange = control*

### Control FSM

![Control FSM](docs/img/control_fsm.png)

---

## 🎛️ Control-Signal Reference

### 1-bit Signals

| Signal | **0** | **1** |
|--------|-------|-------|
| **RegDst** | Dest reg = `rt` | Dest reg = `rd` |
| **RegWrite** | No RF write | Register-file **write** |
| **ALUSrcA** | ALU A = `PC` | ALU A = `A` reg |
| **MemRead** | No read | Memory **read** |
| **MemWrite** | No write | Memory **write** |
| **MemtoReg** | WB data = `ALUOut` | WB data = `MDR` |
| **IorD** | Addr = `PC` | Addr = `ALUOut` |
| **IRWrite** | Hold IR | Load instruction into IR |
| **PCWrite** | Hold PC | **PC ← PC_in** |
| **PCWriteCond** | No branch | Cond. branch (uses `Zero/Bne`) |
| **ExtSel** | **Zero-extend** imm | **Sign-extend** imm |
| **MemHalf** | Word access | Half-word (`lhu`) |
| **Bne** | Compare equal | Compare **not** equal |
| **Jal** | Normal WB | `$ra ← PC+4`, jump |
| **A_Load** | Hold A | `A ← Reg[rs]` |
| **B_Load** | Hold B | `B ← Reg[rt]` |

### 2-bit Signals

| Signal | 00 | 01 | 10 | 11 |
|--------|----|----|----|----|
| **ALUOp** | **add** | **sub** | Use `funct` (R-type) | **SLTIU** compare |
| **ALUSrcB** | `B` | **4** | **imm** | `imm << 2` |
| **PCSource** | `ALUOut` (PC+4) | `ALUOut` (branch target) | Jump addr |

---

## 🧩 State-by-State Control Matrix (13 States)

| # | State | Purpose / Action | Signals asserted |
|---|-------|------------------|------------------|
| 0 | **FETCH** | Fetch instr, PC+4 | `MemRead IRWrite PCWrite`, `ALUSrcB=01 ALUOp=00 PCSource=00` |
| 1 | **DECODE** | Decode, extend imm, load A/B | `ALUSrcB=11 ALUOp=00 A_Load B_Load`, `ExtSel=0` (only for `sltiu`) |
| 2 | **MEM_ADDR** | Addr calc for `lw/lhu/sw` | `ALUSrcA ALUSrcB=10 ALUOp=00` |
| 3 | **MEM_READ** | Read data (`lw/lhu`) | `MemRead IorD`, `MemHalf` *(if lhu)* |
| 4 | **MEM_WB** | WB loaded data | `RegWrite MemtoReg` |
| 5 | **MEM_WRITE** | Store word/half (`sw`) | `MemWrite IorD` |
| 6 | **EXECUTE** | R-type ALU op | `ALUSrcA ALUSrcB=00 ALUOp=10` |
| 7 | **ALU_WB** | WB ALU result (R-type) | `RegDst RegWrite` |
| 8 | **BRANCH** | `beq/bne` compare | `ALUSrcA ALUSrcB=00 ALUOp=01 PCSource=01 PCWriteCond`, `Bne` *(if bne)* |
| 9 | **JUMP** | Jump (`j`) | `PCWrite PCSource=10` |
| 10 | **JAL_WB** | `$ra` ← PC+4, jump | `Jal RegWrite PCWrite PCSource=10` |
| 11 | **SLTIU_EXE** | Unsigned compare | `ALUSrcA ALUSrcB=10 ALUOp=11` |
| 12 | **SLTIU_WB** | WB result of `sltiu` | `RegWrite` |

---

## 🔧 Running the Testbench

```bash
# Icarus example
iverilog -g2012 -o build/run.vvp src/*.v tb/multi_cycle_processor_tb.v
vvp build/run.vvp
