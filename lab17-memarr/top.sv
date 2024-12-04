///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : top.sv
// Title       : top module for Memory labs 
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Defines the top module for memory labs
// Notes       :
// Memory Lab - top-level 
// A top-level module which instantiates the memory and mem_test modules
// 
///////////////////////////////////////////////////////////////////////////

module top;
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

logic clk = 0;

memi memia(clk);

mem_test test (.memi_test(memia));

mem memory (.memi_mod(memia));

always #5 clk = ~clk;
endmodule
