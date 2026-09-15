# sol-rv32i

A 32-bit, 5-stage pipelined RISC-V processor based on the **RV32I ISA**. The main goal of this project is to understand and explore the principles of pipelined CPU microarchitecture, including **data hazard resolution** and **control hazard handling**.

## Microarchitecture

The processor implements a classic 5-stage pipeline:

**IF → ID → EX → MEM → WB**

Pipelining improves instruction throughput by allowing multiple instructions to execute concurrently. However, this introduces **data and control hazards** that must be handled by the processor.

### Data Hazards

Data hazards can be avoided statically by inserting NOPs between dependent instructions, but this introduces unnecessary pipeline stalls and reduces performance.

To resolve common **RAW (Read After Write) hazards** dynamically, the datapath contains a **forwarding unit**. It detects register dependencies for the instruction currently in EX and forwards the required operand from either the **EX/MEM** or **MEM/WB** pipeline register directly to the ALU inputs. When both stages hold a matching destination register, EX/MEM is prioritized, since it corresponds to the more recently issued instruction.

Load-use hazards, where the required data is not yet available for forwarding, are detected in the ID stage and handled separately by introducing a 1-cycle pipeline stall before forwarding the data to the ALU.

We also handle the case where an instruction in ID reads a register that another instruction in WB is writing to in the same cycle. This is resolved in the register file itself by writing on the negative edge of the clock and reading on the positive edge, ensuring the write completes before the read occurs.

### Control Hazards

Control hazards occur because branch instructions are resolved in the EX stage. By this point, two subsequent instructions have already entered the pipeline, since we always predict that the **branch is not taken.**

Branch resolution is performed in EX rather than ID to avoid adding a dedicated comparator earlier in the pipeline because moving it to ID would place register file access and comparison logic on the same critical path, increasing the clock period.

If a branch is taken, these instructions belong to the incorrect execution path and must be flushed. This is handled by clearing the IF/ID and ID/EX pipeline registers, effectively replacing the incorrectly fetched instructions with NOPs. This introduces a **2-cycle penalty.**