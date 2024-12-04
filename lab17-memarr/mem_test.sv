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
	
	randpolicy_t randpolicy;

	constraint c1 {randpolicy == ASCII -> randdata >= 8'h20; randdata <= 8'h7F;
		       randpolicy == AZ -> randdata inside {[8'h41:8'h5a]};
		       randpolicy == az -> randdata inside {[8'h61:8'h7a]};
		       randpolicy == weightedASCII -> randdata dist {[8'h41:8'h5a] := 80, [8'h61:8'h7a] := 20}; }
	
	function new(logic[4:0]addr = 0, logic[7:0]data = 0);
		randaddr = addr;
		randdata = data;
	endfunction

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
// data structures
logic [7:0] dynarr[];

logic [7:0] assarr [logic [5:0]];
logic [5:0] index; // associative array index
bit firstExists;

logic [12:0] queue[$];
initial
  begin: memtest
   
   int errorstatus;
	
   $display("Dynamic Array");
   
   dynarr = new[32];
   myrandmem.randpolicy = weightedASCII;
   
   // write
   for (int i = 0; i < 32; i++) begin
	ok = myrandmem.randomize();
	memi_test.write_mem(debug, myrandmem.randdata, myrandmem.randaddr);
	dynarr[myrandmem.randaddr] = myrandmem.randdata;
   end

   // read
   for (int i = 0; i < 32; i++) begin
	if(dynarr[i] === 8'hxx)
		$display("unwritten address [%5b]", i);
	else begin	
		memi_test.read_mem(debug, rdata, i);
		errorstatus = check_exp(i, rdata, dynarr[i]);
	end
   end

  $display("Associative Array");
   
   // write
   for (int i = 0; i < 32; i++) begin
	ok = myrandmem.randomize();
	memi_test.write_mem(debug, myrandmem.randdata, myrandmem.randaddr);
	assarr[myrandmem.randaddr] = myrandmem.randdata;
   end


   // read
   firstExists = assarr.first(index);
   $display("positions to read: %0d", assarr.size());
   do begin
   	memi_test.read_mem(debug, rdata, index);  
	errorstatus = check_exp(index, rdata, assarr[index]);
	assarr.delete(index); 
   end
   while(assarr.next(index));

   $display("Queue");
   
   dynarr = new[32];
   myrandmem.randpolicy = weightedASCII;
   
   // write
   for (int i = 0; i < 32; i++) begin
	ok = myrandmem.randomize();
	memi_test.write_mem(debug, myrandmem.randdata, i);
	queue.push_front(myrandmem.randdata);
   end

   // read
   for (int i = 0; i < 32; i++) begin	
	myrandmem.randdata = queue.pop_back();	
	memi_test.read_mem(debug, rdata, i);
	errorstatus = check_exp(i, rdata, myrandmem.randdata);
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
