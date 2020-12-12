module Sign_Extend(
    data_i,	
    MemWrite_i,
    Branch_i,
    data_o	  
);

// Ports
input 	[31:0] 		data_i;
input MemWrite_i, Branch_i;

output 	[31:0] 		data_o;

reg 	[31:0]		data_i;
reg 	[31:0] 		data_o;

always @ (data_i or MemWrite_i or Branch_i) begin
	// Store
	if (MemWrite_i) begin
		data_o = $signed({{20{data_i[31]}},data_i[31:25],data_i[11:7]});
	end

	// Branch
	else if (Branch_i) begin
		data_o = $signed({{20{data_i[31]}},data_i[31],data_i[7],data_i[30:25],data_i[11:8]});
	end
	// ADDI SRAI LW
	else begin
		data_o = $signed({{20{data_i[11]}},data_i[11:0]});
	end
end

	
endmodule
