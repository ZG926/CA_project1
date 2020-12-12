module Register_IFID(
	clk_i,
	start_i,
	
	pc_i,
	Stall_i,
	Flush_i,
	instr_i,

	pc_o,
	instr_o
);

input			clk_i,start_i;
input	[31:0]	pc_i; 
input			Flush_i;	
input  			Stall_i;
input   [31:0]  instr_i;

output	[31:0] 	pc_o;
output	[31:0]	instr_o;

reg 	[31:0] 	instr_o;
reg		[31:0] 	pc_o;

always @(posedge clk_i) begin
	if (start_i) begin 
		if (Stall_i) begin
			if (Flush_i) begin
				instr_o <= 32'd0;
				pc_o <= pc_i;		
			end	
			else begin
				instr_o <= instr_i;
				pc_o <= pc_i;	
			end
		end
	end 
	else begin
		instr_o <= instr_o;
		pc_o <= pc_o; 
	end
end

endmodule
