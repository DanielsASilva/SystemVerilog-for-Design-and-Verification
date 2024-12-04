interface memi(input clk);
	timeunit 1ns;
	timeprecision 1ns;
	
	logic read, write;
	logic [4:0] addr;
	logic [7:0] data_in, data_out;

	modport memi_module(input clk, data_in, addr, read, write, output data_out);
	modport memi_testbench(output data_in, addr, read, write, input clk, data_out, import write_mem, read_mem, read_mem_char);

	task write_mem
		(integer debug = 0,
		 input [7:0] value,
		 input [4:0] waddr);
		
		@(negedge clk); // Waits for the negedge to avoid race conditions
		write <= 1;
		read <= 0;
		data_in <= value;
		addr <= waddr;
		
		@(negedge clk); // Ensures that the write operation is held for a full clock cycle
		write <= 0;
		if(debug == 1)
			$display("write - memory[%b] = %b", waddr, value);

	endtask : write_mem

	task read_mem
		(integer debug = 0,
		 output [7:0] rdata,
		 input [4:0] raddr);
		
		@(negedge clk);
		write <= 0;
		read <= 1;
		addr <= raddr;

		@(negedge clk)
		read <= 0;
		rdata = data_out; // Blocking assignment so the data is available immediately
		if(debug == 1)
			$display("read  - memory[%b] = %b", raddr, rdata);

	endtask : read_mem

	task read_mem_char
		(integer debug = 0,
		 output [7:0] rdata,
		 input [4:0] raddr);
		
		@(negedge clk);
		write <= 0;
		read <= 1;
		addr <= raddr;

		@(negedge clk)
		read <= 0;
		rdata = data_out; // Blocking assignment so the data is available immediately
		if(debug == 1)
			$display("read  - memory[%b] = %c", raddr, rdata);

	endtask : read_mem_char

endinterface : memi
