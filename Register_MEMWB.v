module Register_MEMWB (
	clk_i, 
	start_i,

	// Address & Data & Instruction  
	MemAddr_i,
	MemRead_Data_i,
	Rd_Addr_i,

	MemAddr_o,
	MemRead_Data_o,
	Rd_Addr_o,

	//Control 
	RegWrite_i,
	MemToReg_i,

	RegWrite_o,
	MemToReg_o
);

input clk_i,start_i;
input 	[31:0] 		MemAddr_i,MemRead_Data_i;
input 	[4:0]		Rd_Addr_i;
input RegWrite_i, MemToReg_i;

output 	[31:0] 		MemAddr_i,MemRead_Data_i;
output 	[4:0]		Rd_Addr_i;
output RegWrite_i, MemToReg_i;

reg 	[31:0] 		MemAddr_i,MemRead_Data_i;
reg 	[4:0]		Rd_Addr_i;
reg RegWrite_i, MemToReg_i;



always @(posedge clk_i) begin
	if(start_i)	begin
		MemAddr_o			<= MemAddr_i;		
		MemRead_Data_o		<= MemRead_Data_i;		
		Rd_Addr_o			<= Rd_Addr_i;		
		
		RegWrite_o          <= RegWrite_i; 
        MemToReg_o          <= MemToReg_i;

	end
	else begin
		MemAddr_i			<= MemAddr_o;		
		MemRead_Data_i		<= MemRead_Data_o;		
		Rd_Addr_i			<= Rd_Addr_o;		
		
		RegWrite_o          <= RegWrite_o; 
        MemToReg_o          <= MemToReg_o;

	end
end

endmodule