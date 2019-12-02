module top (input CLOCK_50,
	    input [3:0] KEY,
	    output [6:0] HEX7,HEX6,HEX5,HEX4,HEX3,HEX2,HEX1,HEX0);

	logic [55:0] segs;
	logic [31:0] GPIO_out;

	/*
	cpu mycpu(.clk(CLOCK_50),
		  .rst(~KEY[0]),
		  .GPIO_in(),
		  .GPIO_out(GPIO_out));

	*/

	assign {HEX7,HEX6,HEX5,HEX4,HEX3,HEX2,HEX1,HEX0} = segs;

	genvar i;
	generate
	for (i=0;i<8;i=i+1) begin : decoders
		hexdriver mydecoder(.val(GPIO_out[i*4+3:i*4]),.HEX(segs[i*7+6:i*7]));
	end
	endgenerate

endmodule
