# MIPS Multicycle Processor – Easy Guide 👋

Welcome!   
This is Harshdeep Singh

This project shows how a classic 32-bit **MIPS -Multicycle-Processor**

---

## 📁 Folder Map (what’s where)

| Folder / file | What it is |
|---------------|------------|
| **src/**      | All Verilog modules that make the CPU work |
| **tb/**       | Testbench + `program.mem` (the code the CPU will run) |
| **docs/img/** |  Datapath and the control FSM |
| **MIPS_Multicycle.xpr** | *Optional* Vivado project if you like GUIs |
| **README.md** | This file |

---

## 🖼️ How the CPU Looks

### 1.  Datapath (wires & boxes)

![Multicycle Datapath](docs/img/datatapath.png)




*Blue* lines are data.  
*Orange* arrows are control signals.  


### 2.  Control FSM (the brain)

![Control FSM](docs/img/control_fsm.png)


## 🎛️ Control-Signal Reference

### 1-bit Control Signals

| Signal | **0** (de-asserted) | **1** (asserted) |
|--------|---------------------|------------------|
| **RegDst**   | Destination reg = **rt** (`instr[20:16]`) | Destination reg = **rd** (`instr[15:11]`) |
| **RegWrite** | No register write | Register file **write-enable** |
| **ALUSrcA**  | ALU input-A = **PC** | ALU input-A = **A** register |
| **MemRead**  | No memory read | Memory **read** at `Addr` |
| **MemWrite** | No memory write | Memory **write** at `Addr` |
| **MemtoReg** | RegWrite data = **ALUOut** | RegWrite data = **MDR** |
| **IorD**     | Memory address = **PC** (instr fetch) | Memory address = **ALUOut** (data) |
| **IRWrite**  | Don’t load `IR` | Load instruction into **IR** |
| **PCWrite**  | Don’t update PC | **PC ← PC_in** (unconditional) |
| **PCWriteCond** | No branch | Update PC **if `Zero` / `~Zero`** |
| **ExtSel**   | Zero-extend imm (for `sltiu`) | Sign-extend imm |
| **MemHalf**  | Access **word** | Access **half-word** (`lhu`) |
| **Bne**      | Compare **equal** (`beq`) | Compare **not equal** (`bne`) |
| **Jal**      | Normal write-back | `$ra ← PC+4` and jump |
| **A_Load**   | Hold old **A** | Latch **A ← Reg[rs]** |
| **B_Load**   | Hold old **B** | Latch **B ← Reg[rt]** |

---

### 2-bit Control Signals

| Signal | Bits | Action |
|--------|------|--------|
| **ALUOp** | `00` | ALU = **add** (for `lw`, `sw`, `addi…`) |
|           | `01` | ALU = **sub** (for `beq/bne` compare) |
|           | `10` | Function field (`funct[5:0]`) decides ALU op (R-type) |
|           | `11` | Force **SLTIU** compare (unsigned) |
| **ALUSrcB** | `00` | ALU input-B = **B** register |
|             | `01` | ALU input-B = **4** (PC+4 increment) |
|             | `10` | ALU input-B = sign/zero-extended **imm** |
|             | `11` | ALU input-B = sign/zero-extended imm **<< 2** (branch offset) |
| **PCSource** | `00` | PC input = **ALUOut** (`PC+4`) |
|              | `01` | PC input = **ALUOut** (`BranchTarget`) |
|              | `10` | PC input = **JumpAddr** (`{PC[31:28], instr[25:0]<<2}`) |


The CPU walks through **13 states (0 → 12)**.

| State Name | # | Purpose / Action | Control signals asserted (`1` unless noted) |
|------------|---|------------------|---------------------------------------------|
| **FETCH** | 0  | Fetch instruction from memory, PC ← PC+4 | `MemRead  IRWrite  PCWrite` / `ALUSrcA=0` `ALUSrcB=01` `ALUOp=00` `PCSource=00` |
| **DECODE** | 1  | Decode, sign/zero-extend imm, load **A/B** regs | `ALUSrcA=0` `ALUSrcB=11` `ALUOp=00` `A_Load  B_Load` + `ExtSel=0` (*sltiu*) or `1` |
| **MEM_ADDR** | 2 | Compute address for `lw / lhu / sw` | `ALUSrcA` `ALUSrcB=10` `ALUOp=00` |
| **MEM_READ** | 3 | Read data memory (`lw / lhu`) | `MemRead  IorD` + `MemHalf` (*only if lhu*) |
| **MEM_WRITEBACK** | 4 | Write loaded word/half to RegFile | `RegWrite  MemtoReg` (`RegDst=0`) |
| **MEM_WRITE** | 5 | Store word/half (`sw`) to memory| `MemWrite  IorD` |
| **EXECUTE** | 6 | R-type ALU op (`add, sub, and, or, slt, srl`) | `ALUSrcA` `ALUSrcB=00` `ALUOp=10` |
| **ALU_WRITEBACK** | 7 | Write ALU result to RegFile (R-type) | `RegDst=1  RegWrite` |
| **BRANCH** | 8 | Evaluate `beq / bne`, conditionally PC ← BranchTarget | `ALUSrcA` `ALUSrcB=00` `ALUOp=01` `PCSource=01` `PCWriteCond` (`Bne` if `bne`) |
| **JUMP** | 9 | Unconditional jump (`j`) | `PCWrite` `PCSource=10` |
| **JAL_WRITE_RA** | 10 | `$ra` ← PC+4, then jump (`jal`) | `Jal  RegWrite  PCWrite  PCSource=10` |
| **SLTIU_EXECUTE** | 11 | Unsigned compare (`sltiu`) | `ALUSrcA` `ALUSrcB=10` `ALUOp=11` |
| **SLTIU_WRITEBACK** | 12 | Write result of `sltiu` | `RegWrite` (`RegDst=0`) |





---

## 🔦 Quick Demo (see it run!)

> Needs **Icarus Verilog** or **ModelSim** / **Vivado** – pick one.

```bash
# inside repo
iverilog -g2012 -o run.vvp src/*.v tb/multi_cycle_processor_tb.v
vvp run.vvp
