`include "math.sv"
module dpi();
	import "DPI-C" function int system(input string comm);
	import "DPI-C" function string getenv(input string nam);
	import "DPI-C" function real sin(input real num);
	
	int ok;
	real curPi, resSin;
	initial begin
		ok = system("echo 'Hello World!'");
		ok = system("date");
		$display("PATH = %s", getenv("PATH"));

		for(int i=0;i<8;i++) begin
			curPi = `M_PI_4 * i;
			resSin = sin(curPi);
			$display("sin(%f) = %f", curPi, resSin);
		end
	end
endmodule
