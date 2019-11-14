module hexdriver (input [3:0] val, output reg [6:0] HEX);
// displays are active low

	always_comb
		case(val)
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
/*
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
*/
