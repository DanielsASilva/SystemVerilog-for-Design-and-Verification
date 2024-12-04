module alu import typedefs::*; (input logic [8:0] accum,
									   input logic [8:0] data,
									   input opcode_t opcode,
									   input clk,
									   output logic [8:0]  out,
									   output logic zero);
	timeunit 1ns;
	timeprecision 100ps;
	
	always_comb begin
		if(accum == 8'b0)
			zero = 1;
		else
			zero = 0;
	end
	
	always_ff @(negedge clk) begin
	
		case(opcode)
			HLT: out = accum;
			SKZ: out = accum;
			ADD: out = data + accum;
			AND: out = data & accum;
			XOR: out = data ^ accum;
			LDA: out = data;
			STO: out = accum;
			JMP: out = accum;
		endcase
		
	end
endmodule
