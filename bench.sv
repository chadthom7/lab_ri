/*
This testbench should read in binary numbers as GPIO_in from vector.dat 
and convert them into hexa_decimals  in GPIO_out

GPIO_in:
18 switches total, max val 2^28 - 1 = 268,435,456, cuz 2^4 -1 =1111 =15,
possible input for GPIO_in stops at bit 18
0000_0000_0000_00_00_0000_0000_0000_0000
example: 
0000_0000_0000_00_10_0110_0111_1000_1001
0_0_0_2_6_7_8_9
max of 4.5 hexadecimals as input

GPIO_out:
The display for the segments is 32 bits total
0000_0000_0000_0000_0000_0000_0000_0000
1000_0111_0110_0101_0100_0011_0010_0001
8_7_6_5_4_3_2_1
its in hex so every 4 bits i split into its hexadecimal
each hexadecimal will be sent to a segment through hexdriver
max displayable decimal has 8 tensplaces 87654321 so GPIO_in < 100,000,000, can equal 99,999,999 = 05F5_E0FF = 0000_0101_1111_0101_1110_0000_1111_1111
but GPIO_in can only be 18bits or 5  hexadecimals so GPIO_in <= 262,143    = 3_FFFF
*/
module bench;
//____________________________________________________________
	// Clk and rst are normal input, clk2 is used to download vector and check results 
	reg clk, clk2, rst;
//_____________________________________________________________
	// TESTBENCH DATA
	logic [64:0] vectors [149:0]; // 150 65 bit test vectors
	logic [31:0] error, vectornum; // error counter
//_____________________________________________________________
	// Input from switch
	reg [31:0] GPIO_in; //assign GPIO_in = {14'b0, SW}; // GPIO_in is 32 bits, switch is 18
	// Output
	reg [31:0] GPIO_out;
	// EXPECTED Output
	reg [31:0] GPIO_out_e;
	// vectors:
	// rst  GPIO_in GPIO_out_e
//_____________________________________________________________
	initial begin
		error = 0;	
	end
	cpu cpu(.clk(clk), .rst(rst), .GPIO_in(GPIO_in), .GPIO_out(GPIO_out));
	// RPNCALC CLOCK
	always begin
		clk = 1'b1; #5; clk = 1'b0; #5;
	end
	// CLOCK FOR DOWNLOADING VECTORS
	always begin
		//posedge at beginning switches to negedge for #5 to check results
		clk2 = 1'b1; #65; clk2 = 1'b0; #5; // was #75 #5
	end

	initial begin
		$readmemb("vectors.dat", vectors); // read as bits
		vectornum = 32'b0; 
		error = 32'b0;
		rst = 1'b1; #27; rst = 1'b0;		
	end

	always @(posedge clk2) begin
		{rst, GPIO_in, GPIO_out_e} = vectors[vectornum]; 
		//vector doesn't need clk, rst
		// size should be [1:0 ]+[3:0 ] +[15:0]+[15:0]+[15:0]+[7:0]
		// 2+ 4+ 16*3 + 8 =>  14 + 16*3 => 14 + 48 = 62 bits
		vectornum = vectornum + 1;
	end	

	always @(negedge clk2) begin
		if (~rst) begin
		if (GPIO_out!=GPIO_out_e) begin
			$display("---------------------------------------------------------");	
	$display("Error Detected: rst = %h GPIO_in = %h GPIO_out = %h GPIO_out_e = %h", 
				rst, GPIO_in, GPIO_out, GPIO_out_e);
			$display("");
			//$display("hi = %h(%h expected)", hi, hi_e);
			$display("  GPIO_out = %h", GPIO_out);
			$display("GPIO_out_e = %h", GPIO_out_e);	
			$display("");	
			error = error + 32'b1;
			
		end else begin
			$display("----------------------Passed-----------------------------------");	
			$display("rst = %h GPIO_in = %h GPIO_out = %h GPIO_out_e = %h",rst, GPIO_in, GPIO_out, GPIO_out_e);
		end
		end
	end
endmodule


