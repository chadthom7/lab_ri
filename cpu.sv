/* MIPS CPU module implementation */

module cpu (

/**** inputs *****************************************************************/

	input [0:0 ] clk,			/* clock */
	input [0:0 ] rst,			/* reset */
	input logic [31:0] gpio_in,	/* GPIO input */

/**** outputs ****************************************************************/

	output logic [31:0] gpio_out	/* GPIO output */

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
	logic [31:0] regdata_WB, r_WB,lo_WB, hi_WB;

	// Regfile signals
	logic [31:0] readdata2_EX;

	// CU signal for ALU , selects between regfile(rt) and signed 
	// or zero extended immediate for second ALU input
	// For I-Type instructions 
	logic [1:0] alu_src_EX;
	logic rdrt_EX;

	// PC control for Jump and Branch Instructions 
	logic [1:0] pc_src_EX;
	logic stall_FETCH, stall_EX;

	// GPIO control from Control Unit
	logic GPIO_out_en;
	logic GPIO_in_en;
	
	// Control Unit signal 
	logic [1:0] regsel_EX, regsel_WB;

	// Enable hi & lo
	logic enhilo_EX;

	// Writeback for typical cases (lo_WB)
	logic [31:0] R_WB_REG;
	logic [31:0] HI_WB_REG;
	logic [31:0] LO_WB_REG;
	logic [31:0] GPIO_IN_REG;

	// Input to write to REG file
	logic [31:0] regdatain_WB;
	

		// Load MIPS program // TODO // Create actual .dat file for MIPS code //--------------------------------------//
	initial begin
		$readmemh("instmem.dat", instruction_memory); // rename to instmem.dat later
		pc_src_EX = 2'd0;
		stall_FETCH = 1'b0;

	end

	// ALU MUX for input B 
	/* if alu_src == 2'b00:
		B_EX = readdata2_EX
	   else if alu_src == 2'b01:
		{{16{instruction_EX[15]}},instruction_EX[15:0]}
	   else
		{16'd0,instruction_EX[15:0]}

	*/
	assign B_EX = alu_src_EX == 2'b00 ? readdata2_EX : alu_src_EX == 2'b01 ? {{16{instruction_EX[15]}},instruction_EX[15:0]} : {16'd0,instruction_EX[15:0]};

	// REG MUX that writes to Regfile
	// Takes into account GPIO, enhilo_EX, and regsel_EX to determine output
	assign r_WB = lo_EX;
	always @(*) begin
		if (enhilo_EX == 1'b1) begin
			lo_WB = lo_EX; 
			hi_WB = hi_EX; 
		end
	end

	//assign regdata_WB = GPIO_in_en == 1'b1 ? gpio_in : regsel_WB == 2'b00 ? lo_EX : regsel_WB == 2'b01 ? hi_EX : lo_EX;
	// lo_EX is the output from the ALU when enhilo == 0 and GPIO_in_en == 0
	// lo_WB <= GPIO_in_en == 1'b0 ? lo_EX : gpio_in;  // Not needed
	// lo_WB and regdatain_WB are synonamous 
	// I removed regdatain_WB because it was unnecessary 


	// 
	always_ff @(posedge clk, posedge rst) begin
		if(~enhilo_EX) begin
			HI_WB_REG <= hi_EX;
			LO_WB_REG <= lo_EX;
			R_WB_REG <= lo_EX;
		end
		
	end	



	always_ff @(posedge clk,posedge rst) begin
		if (rst) stall_EX <= 1'b0; else stall_EX <= stall_FETCH;

		//if(stall_EX
	end
	
	
	// FETCH stage----------------------------------------------------------------------------------
	always_ff @(posedge clk, posedge rst) begin

		if (rst) begin
			PC_FETCH <= 12'd0;
			instruction_EX <= 32'd0;
		end else begin
			instruction_EX <= instruction_memory[PC_FETCH]; 
			PC_FETCH <=  pc_src_EX == 2'd0 ? PC_FETCH + 12'd1 : PC_FETCH + instruction_EX[11:0];
		end
	end

	
	
	// Pipeline Registers or Writeback Stage-----------------------------------------------------------------------------
	always_ff @(posedge clk,posedge rst) begin
		
		if (rst) begin
			regwrite_WB <= 1'b0;
		end else begin
			regwrite_WB <= regwrite_EX;
			regsel_WB <= regsel_EX;
			writeaddr_WB <= rdrt_EX == 1'b0 ? instruction_EX[15:11] : instruction_EX[20:16]; // 0 =rd, 1 = rt
			if (GPIO_in_en == 1'b1) regdata_WB = gpio_in;
			else if (regsel_WB == 2'b00) regdata_WB = r_WB;
			else if (regsel_WB == 2'b01) regdata_WB = hi_WB;
			else if (regsel_WB == 2'b10) regdata_WB = lo_WB;
		end
	end
	
	// GPIO_out logic
	always_ff @(posedge clk, posedge rst) begin
		if (rst) gpio_out <= 32'd0; else
			if (GPIO_out_en) gpio_out <= readdata2_EX;
	end	


	/*regdata_WB = 
	if statement using (regsel_WB,[r_WB,hi_WB,lo_WB,GPIO_in], and regwrite_WB, and regdest_WB)
	pg 37

	*/	

	// Register
	regfile myregfile (.clk(clk),
						.rst(rst),
						// execute (decode) //maybe RS shouldn't be set here if lui,mflo,mfhi is happening
						.readaddr1(instruction_EX[25:21]), // RS address
						.readaddr2(instruction_EX[20:16]), // RT address
						.readdata1(A_EX),
						.readdata2(readdata2_EX),
				
						// writeback
						.we(regwrite_WB),
						.writeaddr(writeaddr_WB),
						.writedata(regdata_WB));                // lo_WB is the output of REG MUX that we write to the regfile 
	
	// ALU (execute stage)
	alu myalu (.a(A_EX),
		   		.b(B_EX),
		   		.shamt({3'b000,shamt_EX}), //needs to be 8 bits
		   		.op(op_EX),
		   		.hi(hi_EX),
		   		.lo(lo_EX),
		   		.zero(zero_EX));


	//Execute Stage----------------------------------------------------------------------------------	
	// Control Unit (Decode Instructions) 	
	controlUnit CU (.clk(clk),
					.rst(rst),
					.i_type(instruction_EX[31:26]),
					.shamt(instruction_EX[10:6]), 
					.function_code(instruction_EX[5:0]),
					.alu_op(op_EX),
					.shamt_EX(shamt_EX),
					.enhilo_EX(enhilo_EX),
					.regsel_EX(regsel_EX),
					.regwrite_EX(regwrite_EX),
					.rdrt_EX(rdrt_EX),
					.memwrite_EX(memwrite_EX),
					.alu_src_EX(alu_src_EX),
					.GPIO_OUT(GPIO_out_en),
					.GPIO_IN(GPIO_in_en),
					.stall_FETCH(stall_EX));

		

endmodule
