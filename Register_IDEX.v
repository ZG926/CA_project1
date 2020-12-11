module Register_IDEX (
	clk_i, 
	start_i,

	// Instruction Data & Immediate & funct & Instruction Address 
	RS1Data_i, 
	RS2Data_i,
	SignExtended_i,	
	funct_i,		// 10bits instr[31:25,14:12]	funct 3 and funct 7	 
	RS1_Addr_i,		// 5 bits instr[19:15]			rs1 					
	RS2_Addr_i,		// 5 bits instr[24:20]			rs2 					
	Rd_Addr_i,		// 5 bits instr[11:7]			rd

	RS1Data_o,
	RS2Data_o,
	SignExtended_o,
	funct_o,
	RS1_Addr_o,		
	RS2_Addr_o,
	Rd_Addr_o,

	// Control 
	RegWrite_i,	
	MemToReg_i,	
	MemRead_i,	
	MemWrite_i,	
	ALUOp_i,	//2 bits
	ALUSrc_i,	

	RegWrite_o,
	MemToReg_o,
	MemRead_o,
	MemWrite_o,
	ALUOp_o,
	ALUSrc_o
);

input clk_i, start_i;
input [31:0] RS1Data_i, RS2Data_i, SignExtended_i;
input [9:0] funct_i;
input [4:0] RS1Addr_i, RS2Addr_i,Rd_Addr_i;

input [1:0] ALUOp_i;
input RegWrite_i, MemToReg_i, MemRead_i, MemWrite_i, ALUSrc_i;	

output [31:0] RS1Data_o, RS2Data_o, SignExtended_o;
output [9:0] funct_o;
output [4:0] RS1Addr_o, RS2Addr_o,Rd_Addr_o;

output [1:0] ALUOp_o;
output RegWrite_o, MemToReg_o, MemRead_o, MemWrite_o, ALUSrc_o;	

reg [31:0] RS1Data_o, RS2Data_o, SignExtended_o;
reg [9:0] funct_o;
reg [4:0] RS1Addr_o, RS2Addr_o,Rd_Addr;

reg [1:0] ALUOp_o;
reg RegWrite_o, MemToReg_o, MemRead_o, MemWrite_o, ALUSrc_o;	

always @(posedge clk_i) begin
	if (start_i) begin 
		RS1Data_o 		    <= RS1Data_i;
		RS2Data_o 		    <= RS2Data_i;
		SignExtended_o 	    <= SignExtended_i;
		RS1Addr_o			<= RS1Addr_i;
		RS2Addr_o			<= RS2Addr_i;
		funct_o				<= funct_i;
		Rd_Addr_o       	<= Rd_Addr_i;
	
		RegWrite_o          <= RegWrite_i; 
		MemToReg_o          <= MemToReg_i;
		MemRead_o           <= MemRead_i; 
		MemWrite_o          <= MemWrite_i;
		ALUOp_o             <= ALUOp_i;
		ALUSrc_o            <= ALUSrc_i;

	end 
	else begin
		RS1Data_o 		    <= RS1Data_o;
		RS2Data_o 		    <= RS2Data_o;
		SignExtended_o 	    <= SignExtended_o;
		RS1Addr_o			<= RS1Addr_o;
		RS2Addr_o			<= RS2Addr_o;
		funct_o				<= funct_o;
		Rd_Addr_o           <= Rd_Addr_o;
	
		RegWrite_o          <= RegWrite_o; 
		MemToReg_o          <= MemToReg_o;
		MemRead_o           <= MemRead_o; 
		MemWrite_o          <= MemWrite_o;
		ALUOp_o             <= ALUOp_o;
		ALUSrc_o            <= ALUSrc_o;
	end 
end

endmodule


