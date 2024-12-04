module scale_mux #(WIDTH = 1)
				  (input logic [WIDTH-1:0] in_a, 
				   input logic [WIDTH-1:0] in_b,
				   input logic sel_a,
				   output logic [WIDTH-1:0] out);

	timeunit 1ns;
	timeprecision 1ns;
	
	always_comb begin
		
		unique case(sel_a)
			1'b0: out = in_b;
			1'b1: out = in_a;
			default: out = 'x;
		endcase

	end

endmodule
