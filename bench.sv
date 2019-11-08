/*
This testbench should read in binary numbers as GPIO_in from vector.dat 
and convert them into hexa_decimals  in GPIO_out

18 switches total, max val 2^28 - 1, cuz 2^4 -1 =1111 =15,
example: 0000_0000_0000_0000_0000_0000_0000_0000
0000_0000_0000_0000_0000_0000_0000_1001
0_0_0_0_0_0_0_9
The display for the segments is 32 bits total

HEX1 <= 7'b100_0000; // 0
HEX2 <= 7'b111_1001; // 1
HEX2 <= 7'b010_0100; // 2
HEX2 <= 7'b011_0000; // 3
HEX2 <= 7'b001_1001;
HEX2 <= 7'b001_0010; // 5
HEX2 <= 7'b000_0010; // 6
HEX2 <= 7'b111_1000; // 7
HEX2 <= 7'b000_0000; // 8
HEX2 <= 7'b001_1000; // 9
		//                 gfe_dcba
		4'b0000000000000000 : HEX = 7'b100_0000; // 0
		4'b0001 : HEX = 7'b111_1001; // 1
		4'b0010 : HEX = 7'b010_0100; // 2
		4'b0011 : HEX = 7'b011_0000; // 3
		4'b0100 : HEX = 7'b001_1001; // 4    
		4'b0101 : HEX = 7'b001_0010; // 5
		4'b0110 : HEX = 7'b000_0010; // 6
		4'b0111 : HEX = 7'b111_1000; // 7
		4'b1000 : HEX = 7'b000_0000; // 8
		4'b1001 : HEX = 7'b001_1000; // 9
		4'b1010 : HEX = 7'b000_1000; // A -> 10
		4'b1011 : HEX = 7'b000_0011; // B -> 11
		4'b1100 : HEX = 7'b100_0110; // C -> 12
		4'b1101 : HEX = 7'b010_0001; // D -> 13      
		4'b1110 : HEX = 7'b000_0110; // E -> 14
		4'b1111 : HEX = 7'b000_1110; // F -> 15
		default : HEX = 7'b000_0000; // Default Required
*/
module bench;
//____________________________________________________________
	// Clk and rst are normal input, clk2 is used to download vector and check results 
	reg clk, clk2, rst;
//_____________________________________________________________
	// TESTBENCH DATA
	logic [61:0] vectors [149:0]; // 150 62 bit test vectors
	logic [31:0] error, vectornum; // error counter
//_____________________________________________________________
	// Input from switch
	reg [31:0] GPIO_in,
	// Output
	reg [31:0] GPIO_out;
	// EXPECTED Output
	reg [31:0] GPIO_out_e;
	// vectors:
	// rst  GPIO_in  GPIO_out  GPIO_out_e
//_____________________________________________________________


	initial begin
		//key   = 4'b1111; // making sure keys start out as unpressed (being pressed is active low)
		error = 0;	
	end
	/* instantiate the ALU we plan to test */
	rpncalc rpncalc(.clk(clk), .rst(rst), .mode(mode), .key(key), .val(val), .top(top), .next(next), .counter(counter));
	cpu cpu(.clk(clk), .rst(rst), .GPIO_in(GPIO_in), .GPIO_out(GPIO_out));
	// RPNCALC CLOCK
	always begin
		clk = 1'b1; #5; clk = 1'b0; #5;
	end

	// CLOCK FOR DOWNLOADING VECTORS
	always begin
		//posedge at beginning switches to negedge for #5 to check results
		clk2 = 1'b1; #65; clk2 = 1'b0; #5; // was #75 #5
		//clk2 = 1'b1; #30; clk2 = 1'b0; #30; // completes cycle 6 posedges of clk later
		//clk2 = 1'b1; #25; clk2 = 1'b0; #25; // completes cycle 5 posedges of clk later
	end

	initial begin
		$readmemb("vectors.dat", vectors); // read as bits
		vectornum = 32'b0; 
		error = 32'b0;
		rst = 1'b1; #27; rst = 1'b0;		
	end

	always @(posedge clk2) begin
		{mode, key, val, top_expected, next_expected, counter_expected} = vectors[vectornum]; 
		//vector doesn't need clk, rst
		// size should be [1:0 ]+[3:0 ] +[15:0]+[15:0]+[15:0]+[7:0]
		// 2+ 4+ 16*3 + 8 =>  14 + 16*3 => 14 + 48 = 62 bits
		vectornum = vectornum + 1;
	end	

	always @(negedge clk2) begin
		if (~rst && key!= 4'b1111) begin
		if (top!=top_expected || next != next_expected || counter != counter_expected) begin
	$display("Error Detected: mode = %h key = %h val = %h top_expected = %h next_expected = %h counter_expected = %h", 
				mode, key, val, top_expected, next_expected, counter_expected);
			$display("");
			//$display("hi = %h(%h expected)", hi, hi_e);
			$display("         top = %h", top);
			$display("top_expected = %h", top_expected);	
			$display("");
			//$display("lo = %h(%h expected)", lo, lo_e);
			$display("         next = %h", next);
			$display("next_expected = %h", next_expected);
			$display("");
			//$display("zero = %h(%h expected)", zero, zero_e);
			$display("         counter = %h", counter);
			$display("counter_expected = %h", counter_expected);	
			error = error + 32'b1;
			$display("---------------------------------------------------------");
		end else begin
			$display("----------------------Passed-----------------------------------");
/*		
		$display("mode = %b key = %b val = %b top_expected = %b next_expected = %b counter_expected = %b", 
				mode, key, val, top_expected, next_expected, counter_expected);
		*/	
			$display("mode = %h key = %h val = %h",mode, key, val);
			$display("top_expected = %h, top = %h", top_expected, top);
			$display("next_expected = %h, next = %h", next_expected, next);	
			$display("counter_expected = %h, counter = %h", counter_expected, counter);
		end
		end
	end
endmodule


