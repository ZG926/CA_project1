module Hazard_Detection
(
    RS1addr_i,
    RS2addr_i,
    MemRead, 
    rd,
    PCWrite,
    Stall_o,
    NoOp
);

// Ports
input   [4:0]       RS1addr_i;
input   [4:0]       RS2addr_i;
input MemRead;
input [4:0] rd;
output PCWrite;
output Stall_o;
output NoOp;
reg PCWrite;
reg Stall_o;
reg NoOp;
always @(RS1addr_i or RS2addr_i or MemRead or rd)
begin
	if (rd == RS1addr_i)begin
		PCWrite <= 0;
		Stall_o <= 1;
		NoOp <= 1;
		////$display(data_o);
	end
	else if (rd == RS2addr_i) begin
		PCWrite <= 0;
		Stall_o <= 1;
		NoOp <= 1;
		////$display(data_o);
	end
	else begin
		PCWrite <= 1;
		Stall_o <= 0;
		NoOp <= 0;
	end
	
end

endmodule
