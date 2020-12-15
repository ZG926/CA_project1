module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

// Wire
wire    [31:0]  instr_addr,four_instr_addr,branch_instr_addr,mux_instr_addr;
wire    [31:0]  instr;
wire    [31:0]  Four;
wire    [31:0]  Sign_Extend_data,ShiftLeft_data;
wire    Flush;
wire    pcwrite;
wire    Stall;
wire    NoOp;

wire    [31:0]  ALUResult;
wire    [3:0]   ALUCtrl;

wire    [31:0]  RS1Data,RS2Data;

wire    [1:0]   Ctrl_ALUOp;
wire    Ctrl_RegWrite,Ctrl_MemtoReg, Ctrl_MemRead, Ctrl_MemWrite,Ctrl_ALUSrc,Ctrl_Branch;

wire    [31:0]  MemRead_Data;

wire equal;

wire    [1:0]   Forward_A,Forward_B;

wire    [31:0]  MUX_ALUSrc_Result;
wire    [31:0]  MUX_MemtoReg_Result;

wire    [31:0]  Forward_MUX1_Result;
wire    [31:0]  Forward_MUX2_Result;

wire    [31:0]  IFID_instr,IFID_pc;

wire    [31:0]  IDEX_RS1Data,IDEX_RS2Data,IDEX_Sign_Extend_Data;
wire    [9:0]   IDEX_funct;
wire    [4:0]   IDEX_RS1_Addr,IDEX_RS2_Addr,IDEX_RD_Addr;
wire    [1:0]   IDEX_ALUOp;
wire    IDEX_RegWrite,IDEX_MemtoReg, IDEX_MemRead, IDEX_MemWrite,IDEX_ALUSrc;

wire    EXMEM_RegWrite,EXMEM_MemtoReg, EXMEM_MemRead, EXMEM_MemWrite;
wire    [31:0]  EXMEM_ALU_Result, EXMEM_MemWrite_Data;
wire    [4:0]   EXMEM_RD_Addr;

wire    [31:0]  MEMWB_ALU_Result,MEMWB_MemRead_Data;
wire    [4:0]   MEMWB_RD_Addr;
wire    MEMWB_RegWrite,MEMWB_MemtoReg;

assign Four = 32'd4;

Adder PC_Adder(
    .data1_i(instr_addr),
    .data2_i(Four),
    .data_o(four_instr_addr)  
);

Adder Branch_Adder(
    .data1_i(IFID_pc), 
    .data2_i(ShiftLeft_data),
    .data_o(branch_instr_addr)  
);

Instruction_Memory Instruction_Memory(
    .addr_i(instr_addr),
    .instr_o(instr)
);

MUX32 MUX_PC(
    .data1_i(four_instr_addr),    
    .data2_i(branch_instr_addr),    
    .select_i(Flush),   
    .data_o(mux_instr_addr)     
);

PC PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .start_i(start_i),
    .PCWrite_i(pcwrite),
    .pc_i(mux_instr_addr),
    .pc_o(instr_addr)
);

ALU ALU(
    .data1_i(Forward_MUX1_Result),    
    .data2_i(MUX_ALUSrc_Result),   
    .ALUCtrl_i(ALUCtrl),
    .data_o(ALUResult)     
);

ALU_Control ALU_Control(
    .funct_i(IDEX_funct),    
    .ALUOp_i(IDEX_ALUOp),    
    .ALUCtrl_o(ALUCtrl)   
);

And And(
    .data1_i(Ctrl_Branch),
    .data2_i(equal),
    .data_o(Flush)
);

Registers Registers(
    .clk_i(clk_i),
    .RS1addr_i(IFID_instr[19:15]),
    .RS2addr_i(IFID_instr[24:20]),
    .RDaddr_i(MEMWB_RD_Addr), 
    .RDdata_i(MUX_MemtoReg_Result),
    .RegWrite_i(MEMWB_RegWrite), 
    .RS1data_o(RS1Data), 
    .RS2data_o(RS2Data) 
);

Control Control(
    .Op_i(IFID_instr[6:0]),       
    .NoOp_i(NoOp), 
    .RegWrite_o(Ctrl_RegWrite),
    .MemtoReg_o(Ctrl_MemtoReg),
    .MemRead_o(Ctrl_MemRead),
    .MemWrite_o(Ctrl_MemWrite),
    .ALUOp_o(Ctrl_ALUOp),    
    .ALUSrc_o(Ctrl_ALUSrc),
    .Branch_o(Ctrl_Branch)
);

Data_Memory Data_Memory(
    .clk_i(clk_i), 
    .addr_i(EXMEM_ALU_Result), 
    .MemRead_i(EXMEM_MemRead),
    .MemWrite_i(EXMEM_MemWrite),
    .data_i(EXMEM_MemWrite_Data),
    .data_o(MemRead_Data)
);

Equal Equal(
    .data1_i(RS1Data),
    .data2_i(RS2Data),
    .equal_o(equal)
);

Forwarding_Unit Forwarding_Unit(
    .EX_Rs1_i(IDEX_RS1_Addr),
    .EX_Rs2_i(IDEX_RS2_Addr),
    .MEM_RegWrite_i(EXMEM_RegWrite),
    .MEM_Rd_i(EXMEM_RD_Addr),
    .WB_Rd_i(MEMWB_RD_Addr),
    .WB_RegWrite_i(MEMWB_RegWrite),
    .Forward_A_o(Forward_A),
    .Forward_B_o(Forward_B)
);

Hazard_Detection Hazard_Detection(
    .RS1addr_i(IFID_instr[19:15]),
    .RS2addr_i(IFID_instr[24:20]),
    .MemRead(IDEX_MemRead), 
    .rd(IDEX_RD_Addr),
    .PCWrite(pcwrite),
    .Stall_o(Stall),
    .NoOp(NoOp)
);

Sign_Extend Sign_Extend(
    .data_i(IFID_instr), 
    .MemWrite_i(Ctrl_MemWrite),
    .Branch_i(Ctrl_Branch),
    .data_o(Sign_Extend_data)    
);

MUX32 MUX_ALUSrc(
    .data1_i(Forward_MUX2_Result),    
    .data2_i(IDEX_Sign_Extend_Data),    
    .select_i(IDEX_ALUSrc),   
    .data_o(MUX_ALUSrc_Result)     
);

MUX32 MUX_MemtoReg(
    .data1_i(MEMWB_ALU_Result),    
    .data2_i(MEMWB_MemRead_Data),    
    .select_i(MEMWB_MemtoReg),   
    .data_o(MUX_MemtoReg_Result)     
);

MUX32_4 Forward_MUX1(
    .Forward_i(Forward_A),
    .EX_RS_Data_i(IDEX_RS1Data),
    .MEM_ALU_Result_i(EXMEM_ALU_Result),
    .WB_WriteData_i(MUX_MemtoReg_Result),
    .MUX_Result_o(Forward_MUX1_Result)
);

MUX32_4 Forward_MUX2(
    .Forward_i(Forward_B),
    .EX_RS_Data_i(IDEX_RS2Data),
    .MEM_ALU_Result_i(EXMEM_ALU_Result),
    .WB_WriteData_i(MUX_MemtoReg_Result),
    .MUX_Result_o(Forward_MUX2_Result)
);

Register_IFID IFID(
    .clk_i(clk_i),
    .start_i(start_i),
    
    .pc_i(instr_addr),
    .Stall_i(Stall),
    .Flush_i(Flush),
    .instr_i(instr),

    .pc_o(IFID_instr),
    .instr_o(IFID_pc)
);

Register_IDEX IDEX(
    .clk_i(clk_i),
    .start_i(start_i),

    .RS1Data_i(RS1Data), 
    .RS2Data_i(RS2Data),
    .SignExtended_i(Sign_Extend_data), 
    .funct_i({IFID_instr[31:25],IFID_instr[14:12]}),      
    .RS1_Addr_i(IFID_instr[19:15]),              
    .RS2_Addr_i(IFID_instr[24:20]),                      
    .Rd_Addr_i(IFID_instr[11:7]),     

    .RS1Data_o(IDEX_RS1Data),
    .RS2Data_o(IDEX_RS2Data),
    .SignExtended_o(IDEX_Sign_Extend_Data),
    .funct_o(IDEX_funct),
    .RS1_Addr_o(IDEX_RS1_Addr),     
    .RS2_Addr_o(IDEX_RS2_Addr),
    .Rd_Addr_o(IDEX_RD_Addr),

    .RegWrite_i(Ctrl_RegWrite), 
    .MemToReg_i(Ctrl_MemtoReg), 
    .MemRead_i(Ctrl_MemRead),  
    .MemWrite_i(Ctrl_MemWrite), 
    .ALUOp_i(Ctrl_ALUOp),   
    .ALUSrc_i(Ctrl_ALUSrc),   

    .RegWrite_o(IDEX_RegWrite),
    .MemToReg_o(IDEX_MemtoReg),
    .MemRead_o(IDEX_MemRead),
    .MemWrite_o(IDEX_MemWrite),
    .ALUOp_o(IDEX_ALUOp),
    .ALUSrc_o(IDEX_ALUSrc)
);

Register_EXMEM EXMEM(
    .clk_i(clk_i),
    .start_i(start_i),

    .ALU_Result_i(ALUResult),
    .MemWrite_Data_i(Forward_MUX2_Result),
    .Rd_Addr_i(IDEX_RD_Addr),

    .ALU_Result_o(EXMEM_ALU_Result),
    .MemWrite_Data_o(EXMEM_MemWrite_Data),
    .Rd_Addr_o(EXMEM_RD_Addr),

    .RegWrite_i(IDEX_RegWrite), 
    .MemToReg_i(IDEX_MemtoReg), 
    .MemRead_i(IDEX_MemRead),  
    .MemWrite_i(IDEX_MemWrite), 

    .RegWrite_o(EXMEM_RegWrite), 
    .MemToReg_o(EXMEM_MemtoReg), 
    .MemRead_o(EXMEM_MemRead),  
    .MemWrite_o(EXMEM_MemWrite)

);

Register_MEMWB MEMWB(
    .clk_i(clk_i),
    .start_i(start_i),

    .ALU_Result_i(EXMEM_ALU_Result),
    .MemRead_Data_i(MemRead_Data),
    .Rd_Addr_i(EXMEM_RD_Addr),

    .ALU_Result_o(MEMWB_ALU_Result),
    .MemRead_Data_o(MEMWB_MemRead_Data),
    .Rd_Addr_o(MEMWB_RD_Addr),

    .RegWrite_i(EXMEM_RegWrite),
    .MemtoReg_i(EXMEM_MemtoReg),

    .RegWrite_o(MEMWB_RegWrite),
    .MemtoReg_o(MEMWB_MemtoReg)
);

Shift_Left Shift_Left(
    .data_i(Sign_Extend_data),
    .data_o(ShiftLeft_data)
);

endmodule
