// example CPU

module cpu(input clk,
		   input rst,
		   input [31:0] GPIO_in,
		   output logic [31:0] GPIO_out);

	// program memory, where we store our MIPS code
	logic [31:0] instruction_memory [4095:0];
	
	// program counter, or address of insruction being fetched
	logic [11:0] PC_FETCH;
	
	// current instruction being executed
	logic [31:0] instruction_EX;
	
	// ALU signals inputs and outputs
	logic [31:0] A_EX,B_EX,hi_EX,lo_EX;
	logic [4:0] shamt_EX;
	logic zero_EX;
	logic [3:0] op_EX;

	// writeback signals
	logic regwrite_WB,regwrite_EX;
	logic [4:0] writeaddr_WB;
	logic [31:0] lo_WB;

	// regfile signals
	logic [31:0] readdata2_EX;
	logic rdrt_EX;

	// ALU signals
	logic [1:0] alu_src_EX;

	// load MIPS program
	initial begin
		$readmemh("counter.dat",instruction_memory);
	end

	// ALU mux
	assign B_EX = alu_src_EX == 2'b0 ? readdata2_EX :
		      alu_src_EX == 2'b1 ?
			{{16{instruction_EX[15]}},instruction_EX[15:0]} :
			{16'b0,instruction_EX[15:0]};

	// PC control
	logic [1:0] pc_src_EX;
	logic stall_FETCH,stall_EX;

	// GPIO control
	logic GPIO_out_en;

	always_ff @(posedge clk,posedge rst) begin
		if (rst) GPIO_out <= 32'b0; else
			if (GPIO_out_en) GPIO_out <= readdata2_EX;
	end

	always_ff @(posedge clk,posedge rst) begin
		if (rst) stall_EX <= 1'b0; else stall_EX <= stall_FETCH;
	end

	// FETCH stage
	always_ff @(posedge clk,posedge rst) begin
		if (rst) begin
			PC_FETCH <= 12'b0;
			instruction_EX <= 32'b0;
		end else begin
			instruction_EX <= instruction_memory[PC_FETCH];
			PC_FETCH <= pc_src_EX == 2'b0 ? PC_FETCH + 12'b1 : PC_FETCH + instruction_EX[11:0];
		end
	end
	
	// pipeline registers
	always_ff @(posedge clk,posedge rst) begin
		if (rst) begin
			regwrite_WB <= 1'b0;
		end else begin
			regwrite_WB <= regwrite_EX;
			writeaddr_WB <= rdrt_EX == 1'b0 ? instruction_EX[15:11] : instruction_EX[20:16];
			lo_WB <= lo_EX;
		end
	end
	
	// register file
	regfile32x32 myregfile (.clk(clk),
	
				// execute (decode)
				.readaddr1(instruction_EX[25:21]),
				.readaddr2(instruction_EX[20:16]),
				.readdata1(A_EX),
				.readdata2(readdata2_EX),
				
				// writeback
				.we(regwrite_WB),
				.writeaddr(writeaddr_WB),
				.writedata(lo_WB));
	
	// ALU (execute stage)
	alu myalu (.a(A_EX),
		   .b(B_EX),
		   .shamt(shamt_EX),
		   .op(op_EX),
		   .lo(lo_EX),
		   .hi(hi_EX),
		   .zero(zero_EX));

	// control unit
	always_comb begin
		op_EX = 4'b0100;		 // add
		regwrite_EX = 1'b0;		 // don't write a register
		shamt_EX = instruction_EX[10:6]; // default shamt
		alu_src_EX = 2'b0;
		rdrt_EX = 1'b0;
		pc_src_EX = 2'b0;
		stall_FETCH = 1'b0;
		GPIO_out_en = 1'b0;

		if (~stall_EX) begin

			// add
			if (instruction_EX[31:26] == 6'b0 &&
				instruction_EX[5:0] == 6'b100000) begin
				regwrite_EX = 1'b1;

			// addi, addiu
			end else if (instruction_EX[31:26]==6'b001000 ||
				instruction_EX[31:26]==6'b001001) begin
				regwrite_EX = 1'b1;
				alu_src_EX = 2'b1;
				rdrt_EX = 1'b1;
				
			// lui
			end else if (instruction_EX[31:26]==6'b001111) begin
				regwrite_EX = 1'b1;
				alu_src_EX = 2'b1;
				shamt_EX = 5'd16;
				op_EX = 4'b1000; // sll
				rdrt_EX = 1'b1;
				
			// ori
			end else if (instruction_EX[31:26]==6'b001101) begin
				regwrite_EX = 1'b1;
				alu_src_EX = 2'b10;
				op_EX = 4'b0001;
				rdrt_EX = 1'b1;
				
			// bne
			end else if (instruction_EX[31:26]==6'b000101) begin
				op_EX = 4'b0101; // sub
				if (~zero_EX) begin
					stall_FETCH = 1'b1;
					pc_src_EX = 2'b1;
				end
			
			// srl (gpio write)
			end else if (instruction_EX[31:26]==6'b0 &&
					instruction_EX[5:0]==6'b000010 &&
					instruction_EX[10:6]==5'b0) begin
					GPIO_out_en = 1'b1;
			end

		end
			
	end

endmodule

