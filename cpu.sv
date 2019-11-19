/* MIPS CPU module implementation */

module cpu (

/**** inputs ******************************/

	input [0:0 ] clk,			/* clock */
	input [0:0 ] rst,			/* reset */
	input logic [31:0] gpio_in,	/* GPIO input */

/**** outputs *****************************/

	output logic [31:0] gpio_out	/* GPIO output */

);

	// Program memory, where we store our MIPS code
	logic [31:0] instruction_memory [4095:0];
	
	// Program counter, or address of insruction being fetched
	logic [11:0] PC_FETCH;
	
	// Current instruction being executed
	logic [31:0] instruction_FETCH, instruction_EX;
	
	// ALU signals 
	logic [31:0] A_EX, B_EX, hi_EX, hi_WB, lo_EX,lo_WB, r_WB;
	logic [4:0] shamt_EX;
	logic zero_EX;
	logic [3:0] op_EX;

	// Writeback signals
	logic regwrite_WB, regwrite_EX;
	logic [4:0] writeaddr_WB;
	//integer i;
	logic iterate;
	logic [31:0] sign_ext, sign_fetch, zero_ext, zero_fetch , regdata_WB;

	// Regfile signals
	logic [31:0] readdata2_EX;

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
	logic enhilo_EX,enhilo_WB;

	// Input to write to REG file
	logic [31:0] regdatain_WB;
	always_ff @(posedge clk,posedge rst) begin
		if (rst) stall_EX <= 1'b0; else stall_EX <= stall_FETCH;
	end
	initial begin
		$readmemh("instmem.dat", instruction_memory); // rename to instmem.dat later
		pc_src_EX = 2'd0;
		stall_FETCH = 1'b0;
		A_EX = 32'd0;
		
		//regwrite_EX = 1'b1;
		//writeaddr_WB = 5'd0;
		//regdata_WB = 32'd0;
		//regwrite_WB = 1'b0; 	
		//regwrite_EX = 1'b0;
	end

	
	

	


		
	/*
	always_ff @(posedge clk, posedge rst) begin
		iterate = 1'b1;
	end
	*/

	// FETCH stage-------------------------------
	always_ff @(posedge clk, posedge rst) begin
		if (rst) begin
			PC_FETCH <= 12'd0;
			instruction_EX <= 32'd0;
		end else begin	 
		PC_FETCH <=  pc_src_EX == 2'd0 ? PC_FETCH + 12'd1 : PC_FETCH + instruction_EX[11:0];
		instruction_FETCH <= instruction_memory[PC_FETCH]; 
		end							//^jump/branch
	end
	//-------------------FETCH -> EX
	
	assign sign_ext = {{16{instruction_EX[15]}},instruction_EX[15:0]};
	assign zero_ext = {16'd0,instruction_EX[15:0]};
	assign B_EX = alu_src_EX == 2'b00 ? readdata2_EX : alu_src_EX == 2'b01 ? sign_ext : zero_ext;


	//Sign extend
	always_ff @(posedge clk, posedge rst) begin
	if (~rst) begin
		instruction_EX = instruction_FETCH;
		//sign_ext = sign_fetch; //ext holds the ex stage val of sign
		//zero_ext = zero_fetch; //ext holds the ex stage val of zero
		
		//shamt_ALU = shamt_EX;
		//op_ALU = op_EX;
	//Save sign extend from fetch stage to bring to EX stage
	end
	end
	//Set alu input for B


	
				//---------------------------------EX -> WB
	// REG MUX that writes to Regfile
	always @(*) begin //always_ff @(posedge clk, posedge rst) begin // always @(*) begin
		r_WB = lo_EX;		
		if (enhilo_WB == 1'b1) begin
			lo_WB = lo_EX; 
			hi_WB = hi_EX; 
		end
		enhilo_WB = enhilo_EX;
		//Ex has to wait on FEtch so constantly update writedata_WB
		//writeaddr_WB <= rdrt_EX == 1'b0 ? instruction_EX[15:11] : instruction_EX[20:16];
	end
	// Pipeline Registers or Writeback Stage-------------------
	always_ff @(posedge clk,posedge rst) begin
		if (rst) begin
			/*
			if (iterate == 1'b1) begin			
				i = 0;
			end else if(i < 5'd32) begin //&& iterate == 1'b1) begin
				writeaddr_WB = i;
				i++;
			end 
			//if(iterate = 1'b1)
			*/


			regwrite_EX = 1'b0;
			regdata_WB = 32'd0;
		end else begin
			regwrite_WB = regwrite_EX; //hopefully nonblocking delays this till wB
			regsel_WB <= regsel_EX;
		// write addr is one cycle behind execute in the below line
		writeaddr_WB <= rdrt_EX == 1'b0 ? instruction_EX[15:11] : instruction_EX[20:16]; 
			// 0 =rd, 1 = rt
			if (GPIO_in_en == 1'b1) regdata_WB <= gpio_in;
			else if (regsel_EX == 2'b00) regdata_WB <= r_WB;
			else if (regsel_EX == 2'b01) regdata_WB <= hi_WB;
			else if (regsel_EX == 2'b10) regdata_WB <= lo_WB;
		end
	end
	
	// GPIO_out logic
	always_ff @(posedge clk, posedge rst) begin
		if (rst) gpio_out <= 32'd0; else
			if (GPIO_out_en) gpio_out <= readdata2_EX;
	end	


	// Register
	regfile myregfile (.clk(clk),
						.rst(rst),
		// execute (decode) //maybe RS shouldn't be set here if lui,mflo,mfhi is happening
						.readaddr1(instruction_EX[25:21]), // RS address
						.readaddr2(instruction_EX[20:16]), // RT address
						.readdata1(A_EX),
						.readdata2(readdata2_EX),
				
						// writeback
						.we(regwrite_EX),
						.writeaddr(writeaddr_WB),
						.writedata(regdata_WB));  	
	// ALU 				EXECUTE
	alu myalu (.a(A_EX),
		   		.b(B_EX), //{16'd0,B_EX[15:0]}),
		   		.shamt({3'b000,shamt_EX}),//shamt_EX}), //needs to be 8 bits
		   		.op(op_EX),
		   		.hi(hi_EX),
		   		.lo(lo_EX),
		   		.zero(zero_EX));


	//Execute Stage-------------------	
	// Control Unit 			Fetched-> to DECODED	
	controlUnit CU (		.clk(clk),
					.rst(rst),
					.i_type(instruction_EX[31:26]),
					.shamt(instruction_EX[10:6]), 
					.function_code(instruction_EX[5:0]),
					//---------------------------------
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
					//---------------------------------
					.stall_FETCH(stall_EX));

		

endmodule



