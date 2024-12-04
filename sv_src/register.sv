module register
(
	input [7:0] data,
	input enable,
	input clk,
	input rst_,
	output reg [7:0] out
);

	timeunit 1ns;
	timeprecision 100ps;
	
	always_ff @(posedge clk or negedge rst_) begin
		
		if(rst_ == 0) begin
			out <= 0;
		end
		
		if(enable == 1) begin
			out <= data;
		end
		
	end
	
endmodule