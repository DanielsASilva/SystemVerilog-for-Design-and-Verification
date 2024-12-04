///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : mem_test.sv
// Title       : Memory Testbench Module
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the Memory testbench module
// Notes       :
// 
///////////////////////////////////////////////////////////////////////////

module mem_test (memi.memi_testbench memi_test);
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: new data types - bit ,logic
bit         debug = 1;
logic [7:0] rdata;      // stores data read from memory for checking
logic [7:0] wdata;
typedef enum {ASCII, AZ, az, weightedASCII} randpolicy_t;

class randmem;
	rand logic[4:0] randaddr;
	rand logic[7:0] randdata;
	
	virtual interface memi memi_class;
	logic [7:0] rdata;
	
	function new(logic[4:0]addr = 0, logic[7:0]data = 0);
		randaddr = addr;
		randdata = data;
	endfunction	

	function void configure(virtual interface memi vif);
		memi_class = vif;
	endfunction

	task write_mem(integer debug = 0);
		
		@(negedge memi_class.clk); // Waits for the negedge to avoid race conditions
		memi_class.write <= 1;
		memi_class.read <= 0;
		memi_class.data_in <= randdata;
		memi_class.addr <= randaddr;
		
		@(negedge memi_class.clk); // Ensures that the write operation is held for a full clock cycle
		memi_class.write <= 0;
		if(debug == 1)
			$display("write - memory[%b] = %b", randaddr, randdata);

	endtask

	task read_mem(integer debug = 0);
		
		@(negedge memi_class.clk);
		memi_class.write <= 0;
		memi_class.read <= 1;
		memi_class.addr <= randaddr;

		@(negedge memi_class.clk)
		memi_class.read <= 0;
		rdata = memi_class.data_out; // Blocking assignment so the data is available immediately
		if(debug == 1)
			$display("read  - memory[%b] = %c", randaddr, rdata);
	endtask

	randpolicy_t randpolicy;
	
	constraint c1 {randpolicy == ASCII -> randdata >= 8'h20; randdata <= 8'h7F;
		       randpolicy == AZ -> randdata inside {[8'h41:8'h5a]};
		       randpolicy == az -> randdata inside {[8'h61:8'h7a]};
		       randpolicy == weightedASCII -> randdata dist {[8'h41:8'h5a] := 80, [8'h61:8'h7a] := 20}; }
	

endclass

// Monitor Results
  initial begin
      $timeformat ( -9, 0, " ns", 9 );
// SYSTEMVERILOG: Time Literals
      #40000ns $display ( "MEMORY TEST TIMEOUT" );
      $finish;
    end

randmem myrandmem = new();
int ok;

initial
  begin: memtest
   
   int errorstatus;
	
   myrandmem.configure(memi_test);
   $display("Random Data ASCII");
   
   for (int i = 0; i < 32; i++) begin
	myrandmem.randpolicy = ASCII;
	ok = myrandmem.randomize();
	myrandmem.write_mem(debug);
	myrandmem.read_mem(debug);
	errorstatus = check_exp(i, myrandmem.rdata, myrandmem.randdata);
   end

   $display("Random Data ASCII A-Z");
   
   for (int i = 0; i < 32; i++) begin
	myrandmem.randpolicy = AZ;
	ok = myrandmem.randomize();
	myrandmem.write_mem(debug);
	myrandmem.read_mem(debug);
	errorstatus = check_exp(i, myrandmem.rdata, myrandmem.randdata);
   end

   $display("Random Data ASCII a-z");
   
   for (int i = 0; i < 32; i++) begin
	myrandmem.randpolicy = az;
	ok = myrandmem.randomize();
	myrandmem.write_mem(debug);
	myrandmem.read_mem(debug);
	errorstatus = check_exp(i, myrandmem.rdata, myrandmem.randdata);
   end

   $display("Random Data ASCII 80%% A-Z / 20%% a-z");
   
   for (int i = 0; i < 32; i++) begin
	myrandmem.randpolicy = weightedASCII;
	ok = myrandmem.randomize();
	myrandmem.write_mem(debug);
	myrandmem.read_mem(debug);
	errorstatus = check_exp(i, myrandmem.rdata, myrandmem.randdata);
   end

   printstatus(errorstatus);	
	
    $finish;
  end
 
function int check_exp
	(input [4:0] caddr,
	 input [7:0] actualval,
	 input [7:0] expectedval);
	
	static int errors; // Static variable that keeps its value between calls
	if (actualval !== expectedval) begin // !== checks for mismatches including X and Z values
		$display("[ERROR] expected %b at %b but got %b", expectedval, caddr, actualval);
		errors++;
	end
	
	return (errors);

endfunction : check_exp

function void printstatus(input int status);
	
	if(status == 0)
		$display("TEST PASSED");
	else
		$display("TEST FAILED WITH %d ERRORS", status);

endfunction : printstatus
 
endmodule
