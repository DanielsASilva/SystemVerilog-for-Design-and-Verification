///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : counter.sv
// Title       : Simple class
// Project     : SystemVerilog Training
// Created     : 2013-4-8
// Description : Simple counter class
// Notes       :
// 
///////////////////////////////////////////////////////////////////////////

module counterclass;

	class counter;
		int count, max, min;
		
		function new(input int c, valmax, valmin);
			check_limit(valmax, valmin);
			check_set(c);
		endfunction

		function void load(input int c);
			check_set(c);
		endfunction

		function int getcount();
			return count;
		endfunction
	
		function void check_limit(input int limit1, limit2);
			if(limit1 > limit2) begin
				max = limit1;
				min = limit2;
			end else begin
				max = limit2;
				min = limit2;
			end
		endfunction

		function void check_set(input int val);
			if(val > max || val < min) begin
				$display("[WARNING] value out of bonds, usign value of min (%0d)", min);
				count = min;
			end else begin
				count = val;
			end

		endfunction

 	endclass

	class upcounter extends counter;
		bit carry;
		static int iunum = 0;	
		
		function new(input int c, valmax, valmin);
			super.new(c, valmax, valmin);
			carry = 0;
			iunum++;
		endfunction

		function void next();
			count++;
			carry = 0;
			if(count > max) begin
				count = min;
				carry = 1;
			end
			//$display("count = %0d carry = %b", getcount(), carry);
		endfunction

		static function int getupinstance();
			return iunum;
		endfunction

	endclass

	class downcounter extends counter;
		bit borrow = 0;		
		static int idnum = 0;
		
		function new(input int c, valmax, valmin);
			super.new(c, valmax, valmin);
			borrow = 0;
			idnum++;
		endfunction
	
		function void next();
			count--;
			borrow = 0;
			if(count < min) begin
				count = max;
				borrow = 1;
			end
			$display("count = %0d borrow = %b", getcount(), borrow);
		endfunction

		static function int getdowninstance();
			return idnum;
		endfunction

	endclass
	
	class timer;
		upcounter hours, minutes, seconds;
		
		function new(input int hourst, minutest, secondst);
			hours = new(hourst, 23, 0);
			minutes = new(minutest, 59, 0);
			seconds = new(secondst, 59, 0);
		endfunction

		function void load(input int hourst, minutest, secondst);
			hours.load(hourst);
			minutes.load(minutest);
			seconds.load(secondst);
		endfunction

		function void showval();
			$display("%0d:%0d:%0d", hours.getcount(), minutes.getcount(), seconds.getcount());
		endfunction

		function void next();
			seconds.next();
			if(seconds.carry == 1) begin
				minutes.next();
				if(minutes.carry == 1) begin
					hours.next();
				end
			end
		endfunction

	endclass

	timer timer1 = new(0, 0, 0);
	
	initial begin
		
		$display("the number of upcounter instances is %0d", upcounter::getupinstance());
		$display("the number of downcounter instances is %0d", downcounter::getdowninstance());
		
		$display("00:00:00 to 00:01:00 test");
		timer1.showval();
		repeat(60) begin			
			timer1.next();
			timer1.showval();
		end

		$display("00:59:00 to 01:00:00 test");
		timer1.load(0,59,0);
		timer1.showval();
		repeat(60) begin			
			timer1.next();
			timer1.showval();
		end

		$display("23:59:00 to 00:00:00 test");
		timer1.load(23,59,0);		
		timer1.showval();
		repeat(60) begin			
			timer1.next();
			timer1.showval();
		end

	end

endmodule
