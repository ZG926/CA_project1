module Register_EXMEM (
    clk_i,
    start_i,

    // ALU Result & Data & Instruction Address
    ALU_Result_i,
    MemWrite_Data_i,
    Rd_Addr_i,

    ALU_Result_o,
    MemWrite_Data_o,
    Rd_Addr_o,

	// Control 
    RegWrite_i, 
    MemToReg_i, 
    MemRead_i,  
    MemWrite_i, 

    RegWrite_o, 
    MemToReg_o, 
    MemRead_o,  
    MemWrite_o
     
);
input               clk_i,start_i;
input   [31:0]      ALU_Result_i, MemWrite_Data_i;
input   [4:0]       Rd_Addr_i;
input RegWrite_i, MemToReg_i, MemRead_i, MemWrite_i;  

output   [31:0]      ALU_Result_o, MemWrite_Data_o;
output   [4:0]       Rd_Addr_o;
output RegWrite_o, MemToReg_o, MemRead_o, MemWrite_o;  

reg   [31:0]      ALU_Result_o, MemWrite_Data_o;
reg   [4:0]       Rd_Addr_o;
reg RegWrite_o, MemToReg_o, MemRead_o, MemWrite_o;  

always @(posedge clk_i) begin
    if(start_i) begin
        ALU_Result_o        <= ALU_Result_i; 
        MemWrite_Data_o     <= MemWrite_Data_i;  
        Rd_Addr_o           <= Rd_Addr_i;   

        RegWrite_o          <= RegWrite_i; 
        MemToReg_o          <= MemToReg_i;
        MemRead_o           <= MemRead_i; 
        MemWrite_o          <= MemWrite_i;

    end
    else begin
        ALU_Result_o        <= ALU_Result_o; 
        MemWrite_Data_o     <= MemWrite_Data_o;  
        Rd_Addr_o           <= Rd_Addr_o;   

        RegWrite_o          <= RegWrite_o; 
        MemToReg_o          <= MemToReg_o;
        MemRead_o           <= MemRead_o; 
        MemWrite_o          <= MemWrite_o;

    end 
end

endmodule
