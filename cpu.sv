/* MIPS CPU module implementation */

module cpu (

/**** inputs *****************************************************************/

	input [0:0 ] clk,			/* clock */
	input [0:0 ] rst,			/* reset */
	input [31:0] gpio_in,	/* GPIO input */

/**** outputs ****************************************************************/

	output [31:0] gpio_out	/* GPIO output */

);

	// Program memory, where we store our MIPS code
	logic [31:0] instruction_memory [4095:0];
	
	// Program counter, or address of insruction being fetched
	logic [11:0] PC_FETCH;
	
	// Current instruction being executed
	logic [31:0] instruction_EX;
	
	// ALU signals 
	logic [31:0] A_EX, B_EX, hi_EX, lo_EX;
	logic [4:0] shamt_EX;
	logic zero_EX;
	logic [3:0] op_EX;

	// Writeback signals
	logic regwrite_WB, regwrite_EX;
	logic [4:0] writeaddr_WB;
	logic [31:0] lo_WB;

	// Regfile signals
	logic [31:0] readdata2_EX;

	// CU signal for ALU , selects between regfile(rt) and signed 
	// or zero extended immediate for second ALU input
	// For I-Type instructions 
	logic [1:0] alu_src_EX;
	logic rdrt_EX;


	// Load MIPS program // TODO // Create actual .dat file for MIPS code //--------------------------------------//
	initial begin
		$readmemh("counter.dat", instruction_memory); 
	end

	// ALU mux
	assign B_EX = alu_src_EX == 2'b0 ? readdata2_EX : alu_src_EX == 2'b1 ? {{16{instruction_EX[15]}},instruction_EX[15:0]} : {16'b0,instruction_EX[15:0]};

	// PC control for Jump and Branch Instructions
	logic [1:0] pc_src_EX;
	logic stall_FETCH,stall_EX;


	// GPIO control from Control Unit
	logic GPIO_out_en;
	
	// Control Unit signal 
	logic [1:0] regsel_EX;
	
	
	always_ff @(posedge clk, posedge rst) begin
		if (rst) gpio_out <= 32'b0; else
			if (GPIO_out_en) gpio_out <= readdata2_EX;
	end

	/*
	always_ff @(posedge clk,posedge rst) begin
		if (rst) stall_EX <= 1'b0; else stall_EX <= stall_FETCH;
	end

	*/
	
	
	// FETCH stage----------------------------------------------------------------------------------
	always_ff @(posedge clk, posedge rst) begin

		if (rst) begin
			PC_FETCH <= 12'b0;
			instruction_EX <= 32'b0;
		end else begin
			instruction_EX <= instruction_memory[PC_FETCH]; 
			PC_FETCH <= PC_FETCH + 12'b1;  // for jump and branch-> pc_src_EX == 2'b0 ? PC_FETCH + 12'b1 : PC_FETCH + instruction_EX[11:0];
		end
	end
	
	// pipeline registers or Writeback stage-----------------------------------------------------------------------------
	always_ff @(posedge clk,posedge rst) begin

		if (rst) begin
			regwrite_WB <= 1'b0;
		end else begin
			regwrite_WB <= regwrite_EX;
			writeaddr_WB <= rdrt_EX == 1'b0 ? instruction_EX[15:11] : instruction_EX[20:16];
			lo_WB <= lo_EX;
		end
	end
	
	// Register
	regfile myregfile (.clk(clk),
				
				.rst(rst),

				// execute (decode)
				.readaddr1(instruction_EX[25:21]), // RS address
				.readaddr2(instruction_EX[20:16]), // RT address
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


	//Execute Stage----------------------------------------------------------------------------------	
	// Control Unit (Decode Instructions) 	
	controlUnit CU (.shamt(instruction_EX[10:6]), 
					.function_code(instruction_EX[5:0]),
					.i_type(instruction_EX[31:26]),
					.alu_operation(op_EX),
					.shamt_EX(shamt_EX),
					.enhilo_EX(enhilo_EX),
					.regsel_EX(regsel_EX),
					.regwrite_EX(regwrite_EX)
					.GPIO_OUT(GPIO_out_en));

		

endmodule
