
# sol-rv32i

A 32-bit, 5 stage pipelined RISC-V processor based on the RV32I ISA. The main goal of this project was to understand and explore the principles of pipelined CPU microarchitecture, including handling data hazards through forwarding and control hazards through branch prediction/pipelining flushing.


## Microarchitecture

It has a 5-stage pipeline IF-ID-EX-MEM-WB, with register at the boundary of each stage.











