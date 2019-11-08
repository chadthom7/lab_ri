module hexdriver (input [3:0] hexnum, output reg [6:0] HEX);
// displays are active low

	always_comb
		case(hexnum)
		4'h0: begin
		HEX <= 7'b100_0000; // 0
		end
		// 01 ~
		4'h1: begin
		HEX <= 7'b111_1001; // 1
		end
		
		// 02 ~
		4'h2: begin
		HEX <= 7'b010_0100; // 2
		end
		
		// 03 ~
		4'h3: begin
		HEX <= 7'b011_0000; // 3
		end
		
		// 04 ~
		4'h4: begin
		HEX <= 7'b001_1001; // 4
		end
		
		// 05 ~
		4'h5: begin
		HEX <= 7'b001_0010; // 5
		end
		
		// 06 ~
		4'h6: begin
		HEX <= 7'b000_0010; // 6
		end
		
		// 07 ~
		4'h7: begin
		HEX <= 7'b111_1000; // 7
		end
		
		// 08 ~
		4'h8: begin
		HEX <= 7'b000_0000; // 8
		end
		
		// 09 ~
		4'h9: begin
		HEX <= 7'b001_1000; // 9
		end
		
		default : begin 
		HEX <= 7'b100_0000; // Default Required
		end
		endcase
endmodule

