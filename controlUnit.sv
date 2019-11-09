module controlUnit (

input clk, rst,

input [5:0] i_type;

input [4:0] shamt /* <-instruction_EX[10:6] */ , function_code /* <-instruction_EX[5:0] */ , 

output [3:0] alu_operation, // op_EX

output [4:0] shamt_EX, // shamt_EX[4:0] 

output [1:0] regsel_EX, 

output enhilo_EX,

output regwrite_EX,

output GPIO_OUT


);




// enhilo_EX // Assert for mult / multu instructions

// regsel_EX // 1 for mfhi, 2 for mflo, 0 for everything else



// control unit logic
	always_comb begin
		//op_EX = 4'b0100;				// ADD
		//regwrite_EX = 1'b0;			// don't write a register
		//shamt_EX = instruction_EX[10:6]; // default shamt
		//alu_src_EX = 2'b0;
		//rdrt_EX = 1'b0;
		
		//GPIO_out_en = 1'b0;
		
		// For Jump and Branch Instructions
		//pc_src_EX = 2'b0;
		//stall_FETCH = 1'b0;
		
		// Testing file merge to github

		if (~stall_FETCH) begin

			// add
			if (i_type == 6'b0 && function_code == 6'b100000) begin
				regwrite_EX = 1'b1;
				alu_operation = 4'b0100;
				
			// addi, addiu
			end else if (i_type == 6'b001000 || i_type == 6'b001001) begin
				regwrite_EX = 1'b1;
				alu_src_EX = 2'b1;
				rdrt_EX = 1'b1;
				
			// lui
			end else if (i_type == 6'b001111) begin
				regwrite_EX = 1'b1;
				alu_src_EX = 2'b1;
				shamt_EX = 5'd16;
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
