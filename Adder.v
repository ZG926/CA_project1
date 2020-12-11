module Adder(
    data1_in, 	// 32 bits
    data2_in,	// 32 bits
    data_o		// 32 bits
);

// Ports
input 	[31:0]		data1_in;
input 	[31:0]		data2_in;
output 	[31:0]		data_o;

assign data_o = data1_in + data2_in;

endmodule
