`define AND		4'b0000
`define XOR		4'b0001
`define SLL		4'b0010
`define ADD 	4'b0011
`define SUB		4'b0100
`define MUL 	4'b0101
`define ADDI 	4'b0110
`define SRAI 	4'b0111
`define LW		4'b0011 	// Load use ADD for Addressing
`define SW		4'b0011 	// Store use ADD for Addressing
`define BEQ		4'b0100 	// No Branch Operation in ALU


module ALU(
    data1_i,  	// 32 bits
    data2_i,  	// 32 bits
    ALUCtrl_i,	// 3 bits
    data_o,   	// 32 bits
    );

// Ports
input 	[31:0] 		data1_i;
input 	[31:0] 		data2_i;
input 	[3:0] 		ALUCtrl_i;

output 	[31:0] 		data_o;

reg 	[31:0]		data_o;

always @(data1_i or data2_i or ALUCtrl_i) begin
	case(ALUCtrl_i)
		`AND 	: data_o <= $signed(data1_i) & $signed(data2_i);
		`XOR	: data_o <= $signed(data1_i) ^ $signed(data2_i);
		`SLL 	: data_o <= $signed(data1_i) << data2_i;
		`ADD 	: data_o <= $signed(data1_i) + $signed(data2_i);
		`SUB 	: data_o <= $signed(data1_i) - $signed(data2_i);
		`MUL 	: data_o <= $signed(data1_i) * $signed(data2_i);
		`ADDI 	: data_o <= $signed(data1_i) + $signed(data2_i);
		`SRAI 	: data_o <= $signed(data1_i) >>> data2_i[4:0]; 
		`LW		: data_o <= $signed(data1_i) + $signed(data2_i);
		`SW		: data_o <= $signed(data1_i) + $signed(data2_i);
		`BEQ	: data_o <= 0;
		default : data_o <= 0;
	endcase
end
endmodule
