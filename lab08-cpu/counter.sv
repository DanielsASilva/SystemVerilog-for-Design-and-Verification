module counter
(input logic [4:0] data,
input load,
input enable,
input clk,
input rst_,
output logic [4:0] count);

	timeunit 1ns;
	timeprecision 1ns;
	
	always_ff @(posedge clk, negedge rst_) begin
		
		if(rst_ == 1'b0) begin
			count = 5'b0;
		end
		
		if(load == 1'b1) begin
			count = data;
		end else if(enable == 1'b1) begin
			count = ++count;
		end else begin
			count = count;
		end
		
	end
	
endmodule
