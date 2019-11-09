module controlUnit (

input clk, rst,

input [5:0] i_type;

input [4:0] shamt /* <-instruction_EX[10:6] */ , function_code /* <-instruction_EX[5:0] */ , 

output [3:0] alu_op, // op_EX

output [4:0] shamt_EX, // shamt_EX[4:0] 

output [1:0] regsel_EX, 

output enhilo_EX,

output regwrite_EX,

output GPIO_OUT


);

// enhilo_EX // Assert for mult / multu instructions

// regsel_EX // 1 for mfhi, 2 for mflo, 0 for everything else

// Control Unit Logic
	always_comb begin
		// alu_op = 4'b0000; // '0000' is op code for AND
		// regsel_EX = 2'b00;
		// regwrite_EX = 1'b0;			   // don't write a register
		// shamt_EX = instruction_EX[10:6]; // For sll, srl, sra, 'X' for everything else
		// enhilo = 1'b0;

		// GPIO_out_en = 1'b0;
		
		// For Jump and Branch Instructions (I-Type)
		// pc_src_EX = 2'b0;
		// alu_src_EX = 2'b0;
		// rdrt_EX = 1'b0;
		// stall_FETCH = 1'b0;


		// if (~stall_FETCH) begin // -> Was before I-Type instructions 

			// ADD
			if (i_type == 6'b0 && function_code == 6'b100000 |
				function_code == 6'b100001) begin
				alu_op = 4'b0100; // op_EX
				shamt_EX = 5'bX;
				regsel_EX = 2'b00;       
				enhilo_EX = 1'b0;
				regwrite_EX = 1'b1;
				//rdrt_EX = 1'b0;
			
			// SUB
			end else if (i_type == 6'b0 && function_code == 6'b100010 |
				function_code == 6'b100011) begin
				alu_op = 4'b0101;
				shamt_EX = 5'bX;
				enhilo_EX = 1'b0;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b1;
				//rdrt_EX = 1'b0;

			// MULT (signed)
			end else if (function_code == 6'b011000) begin
				alu_op = 4'b0110;
				shamt_EX = 5'bX;
				enhilo_EX = 1'b1;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b0;
				//rdrt_EX = 1'b0;

			// MULTU (unsigned)
			end else if (function_code == 6'b011001) begin
				alu_op = 4'b0111;
				shamt_EX = 5'bX;
				enhilo_EX = 1'b1;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b0;
				//rdrt_EX = 1'b0;
				
			// AND 
			end else if (function_code == 6'b100100) begin 
				alu_op = 4'b0000;
				shamt_EX = 5'bX;
				enhilo_EX = 1'b0;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b1;
				//rdrt_EX = 1'b0;

			// OR 
			end else if (function_code == 6'b100101) begin 
				alu_op = 4'b0001;
				shamt_EX = 5'bX;
				enhilo_EX = 1'b0;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b1;
				//rdrt_EX = 1'b0;

			// NOR
			end else if (function_code == 6'b100111) begin 
				alu_op = 4'b0010;
				shamt_EX = 5'bX;
				enhilo_EX = 1'b0;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b1;
				//rdrt_EX = 1'b0;

			// XOR
			end else if (function_code == 6'b100110) begin 
				alu_op = 4'b0011;
				shamt_EX = 5'bX;
				enhilo_EX = 1'b0;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b1;	
				//rdrt_EX = 1'b0;

			// SLL
			end else if (function_code == 6'b000000) begin 
				alu_op = 4'b1000;
				shamt_EX = shamt;
				enhilo_EX = 1'b0;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b1;	
				//rdrt_EX = 1'b0;

			// SRL
			end else if (function_code == 6'b000010) begin 
				alu_op = 4'b1001;
				shamt_EX = shamt;
				enhilo_EX = 1'b0;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b1;
				//rdrt_EX = 1'b0;

			// SRA
			end else if (function_code == 6'b000011) begin 
				alu_op = 4'b1010;
				shamt_EX = shamt;
				enhilo_EX = 1'b0;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b1;	
				//rdrt_EX = 1'b0;


			// MFHI 
			end else if (function_code == 6'b010000) begin 
				alu_op = 4'b1000;
				shamt_EX = 5'bX;
				enhilo_EX = 1'b0;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b1;
				//rdrt_EX = 1'b0;

			// MFLO
			end else if (function_code == 6'b010010) begin 
				alu_op = 4'b1000;
				shamt_EX = 5'bX;
				enhilo_EX = 1'b0;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b1;	
				//rdrt_EX = 1'b0;

			// NOP
			end else if (function_code == 6'b000000) begin 
				alu_op = 4'bXXXX;
				shamt_EX = 5'bX;
				enhilo_EX = 1'b0;
				regsel_EX = 2'b00;
				regwrite_EX = 1'b0;	
				//rdrt_EX = 1'b0;

				
			

			// TODO // -> SLT & SLTU


	//------------------------- I-TYPE -------------------------//


			// addi, addiu
			end else if (i_type == 6'b001000 || i_type == 6'b001001) begin
				regwrite_EX = 1'b1;
				alu_src_EX = 2'b1;
				rdrt_EX = 1'b1;
				
			// lui
			end else if (i_type == 6'b001111) begin
				regwrite_EX = 1'b1;
				alu_src_EX = 2'b1;
				shamt_EX = 5'd16; // ?? -> what should this be
				alu_operation = 4'b1000; // sll
				rdrt_EX = 1'b1;
				
			// ori
			end else if (i_type == 6'b001101) begin
				regwrite_EX = 1'b1;
				alu_src_EX = 2'b10;
				alu_operation = 4'b0001;
				rdrt_EX = 1'b1;
				
			// bne
			end else if (i_type == 6'b000101) begin
				op_EX = 4'b0101; // sub
				if (~zero_EX) begin
					stall_FETCH = 1'b1;
					pc_src_EX = 2'b1;
				end
			
			// srl (gpio write)
			end else if (i_type == 6'b0 &&
					function_code == 6'b000010 &&
					shamt == 5'b0) begin
					GPIO_out_en = 1'b1;
			end

		end
			
	end


endmodule
