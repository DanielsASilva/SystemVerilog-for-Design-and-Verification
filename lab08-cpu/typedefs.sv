package typedefs;
	typedef enum bit[2:0] {HLT, SKZ, ADD, AND, XOR, LDA, STO, JMP} opcode_t;
	typedef enum {inst_addr, inst_fetch, inst_load, idle, op_addr, op_fetch, alu_op, store} state_t;
endpackage : typedefs
