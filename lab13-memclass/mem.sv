///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : mem.sv
// Title       : Memory Module
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the memory module
// Notes       :
// Synchronous 8x32 Memory Design
// Specification:
//  Memory is 8-bits wide and address range is 0 to 31.
//  Memory access is synchronous.
//  Write data into the memory on posedge of clk when write=1
//  Place memory[addr] onto data bus on posedge of clk when read=1
//  The read and write signals should not be simultaneously high.
// 
///////////////////////////////////////////////////////////////////////////

module mem (memi.memi_module memi_mod);
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: logic data type
logic [7:0] memory [0:31] ;
  
  always @(posedge memi_mod.clk)
    if (memi_mod.write && !memi_mod.read)
// SYSTEMVERILOG: time literals
      #1 memory[memi_mod.addr] <= memi_mod.data_in;

// SYSTEMVERILOG: always_ff and iff event control
  always_ff @(posedge memi_mod.clk iff ((memi_mod.read == '1)&&(memi_mod.write == '0)) )
       memi_mod.data_out <= memory[memi_mod.addr];

endmodule
