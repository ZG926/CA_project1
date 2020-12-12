module Register_MEMWB (
	clk_i, 
	start_i,

	// Address & Data & Instruction  
	ALU_Result_i,
	MemRead_Data_i,
	Rd_Addr_i,

	ALU_Result_o,
	MemRead_Data_o,
	Rd_Addr_o,

	//Control 
	RegWrite_i,
	MemtoReg_i,

	RegWrite_o,
	MemtoReg_o
);

input clk_i,start_i;
input 	[31:0] 		ALU_Result_i,MemRead_Data_i;
input 	[4:0]		Rd_Addr_i;
input RegWrite_i, MemtoReg_i;

output 	[31:0] 		ALU_Result_o,MemRead_Data_o;
output 	[4:0]		Rd_Addr_o;
output RegWrite_o, MemtoReg_o;

reg 	[31:0] 		ALU_Result_o,MemRead_Data_o;
reg 	[4:0]		Rd_Addr_o;
reg RegWrite_o, MemtoReg_o;



always @(posedge clk_i) begin
	if(start_i)	begin
		ALU_Result_o		<= ALU_Result_i;		
		MemRead_Data_o		<= MemRead_Data_i;		
		Rd_Addr_o			<= Rd_Addr_i;		
		
		RegWrite_o          <= RegWrite_i; 
        MemtoReg_o          <= MemtoReg_i;

	end
	else begin
		ALU_Result_o		<= ALU_Result_o;		
		MemRead_Data_o		<= MemRead_Data_o;		
		Rd_Addr_o			<= Rd_Addr_o;		
		
		RegWrite_o          <= RegWrite_o; 
        MemtoReg_o          <= MemtoReg_o;

	end
end

endmodule
