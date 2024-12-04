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

module mem_test ( input logic clk, 
                  output logic read, 
                  output logic write, 
                  output logic [4:0] addr, 
                  output logic [7:0] data_in,     // data TO memory
                  input  wire [7:0] data_out     // data FROM memory
                );
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: new data types - bit ,logic
bit         debug = 1;
logic [7:0] rdata;      // stores data read from memory for checking

// Monitor Results
  initial begin
      $timeformat ( -9, 0, " ns", 9 );
// SYSTEMVERILOG: Time Literals
      #40000ns $display ( "MEMORY TEST TIMEOUT" );
      $finish;
    end

initial
  begin: memtest
  int error_status;

    $display("Clear Memory Test");

    for (int i = 0; i< 32; i++)
       // Write data = 'h00 to every address location
       write_mem(debug, 0, i);
   
    for (int i = 0; i<32; i++)
      begin 
       // Read every address location
       read_mem(debug, rdata, i);
	
       // check each memory location for data = 'h00
       error_status = check_exp(i, rdata, 0);

      end
 
    // print results of test
    printstatus(error_status);

    $display("Data = Address Test");

    for (int i = 0; i< 32; i++)
       // Write data = address to every address location
       write_mem(debug, i, i);

    for (int i = 0; i<32; i++)
      begin
       // Read every address location
       read_mem(debug, rdata, i);
	
       // check each memory location for data = address
       error_status = check_exp(i, rdata, i);
      end
  
   // print results of test
   printstatus(error_status);

    $finish;
  end

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
		$display("read - memory[%b] = %b", raddr, rdata);

endtask : read_mem

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
