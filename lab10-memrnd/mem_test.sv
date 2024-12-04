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
logic [7:0] wdata;      // stores randomized data to be written to memory
// Monitor Results
  initial begin
      $timeformat ( -9, 0, " ns", 9 );
// SYSTEMVERILOG: Time Literals
      #40000ns $display ( "MEMORY TEST TIMEOUT" );
      $finish;
    end

initial
  begin: memtest
   
   int errorstatus;

   $display("Random Data");
   
   for (int i = 0; i < 32; i++) begin
	randomize(wdata);
	memi_test.write_mem(debug, wdata, i);
	memi_test.read_mem(debug, rdata, i);
	errorstatus = check_exp(i, rdata, wdata);
   end

   $display("Random Data ASCII");
   
   for (int i = 0; i < 32; i++) begin
	randomize(wdata) with { wdata >= 8'h20; wdata <= 8'h7F; };
	memi_test.write_mem(debug, wdata, i);
	memi_test.read_mem_char(debug, rdata, i);
	errorstatus = check_exp(i, rdata, wdata);
   end

   $display("Random Data ASCII A-Z / a-z");
   
   for (int i = 0; i < 32; i++) begin
	randomize(wdata) with { wdata inside {[8'h41:8'h5a], [8'h61:8'h7a]}; };
	memi_test.write_mem(debug, wdata, i);
	memi_test.read_mem_char(debug, rdata, i);
	errorstatus = check_exp(i, rdata, wdata);
   end

   $display("Random Data ASCII 80%% A-Z / 20%% a-z");
   
   for (int i = 0; i < 32; i++) begin
	randomize(wdata) with { wdata dist {[8'h41:8'h5a] := 80, [8'h61:8'h7a] := 20}; };
	memi_test.write_mem(debug, wdata, i);
	memi_test.read_mem_char(debug, rdata, i);
	errorstatus = check_exp(i, rdata, wdata);
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
