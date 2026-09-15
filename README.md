# sol-rv32i

A 32-bit, 5-stage pipelined RISC-V processor based on the **RV32I ISA**. The main goal of this project is to understand and explore the principles of pipelined CPU microarchitecture, including **data hazard resolution** and **control hazard handling**.

## Microarchitecture

The processor implements a classic 5-stage pipeline:

**IF → ID → EX → MEM → WB**

Pipelining improves instruction throughput by allowing multiple instructions to execute concurrently. However, this introduces **data and control hazards** that must be handled by the processor.

### Data Hazards

Data hazards can be avoided statically by inserting NOPs between dependent instructions, but this introduces unnecessary pipeline stalls and reduces performance.

To resolve common **RAW (Read After Write) hazards** dynamically, the datapath contains a **forwarding unit**. It detects register dependencies for instructions in the EX stage and forwards the required data from either the **EX/MEM** or **MEM/WB** pipeline registers directly to the ALU inputs.

Load-use hazards, where the required data is not yet available for forwarding, are detected in ID stage and handled separately by introducing a 1-cycle pipeline stall and then forwarding the data to the ALU.

### Control Hazards

Control hazards occur because branch instructions are resolved in the EX stage. By this point, two subsequent instructions have already entered the pipeline because we always predict that the **branch is not taken.**

If a branch is taken, these instructions belong to the incorrect execution path and must be flushed. This is handled by clearing the IF/ID and ID/EX pipeline registers, effectively replacing the incorrectly fetched instructions with NOPs. This introduces a **2-cycle penalty.**

