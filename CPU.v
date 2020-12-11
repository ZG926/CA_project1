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

// Wire/Reg
wire    [31:0]      instr_addr,next_instr_addr,instr,RS2data,RS1data,Mux_data,ALU_data,Sign_Extend_data,Four;
wire    [1:0]       ALUOp;
wire    [3:0]       ALUCtrl;
wire                RegWrite,ALUSrc;

assign Four = 32'd4;

// Unchanged (10/12 JT)
Adder PC_Adder(
    .data1_in       (instr_addr),       
    .data2_in       (Four),            
    .data_o         (next_instr_addr)   
);

Instruction_Memory Instruction_Memory(
    .addr_i         (instr_addr),     
    .instr_o        (instr)            
);

Registers Registers(
    .clk_i          (clk_i),    
    .RS1addr_i      (instr[19:15]),         
    .RS2addr_i      (instr[24:20]),         
    .RDaddr_i       (instr[11:7]),         
    .RDdata_i       (ALU_data),            
    .RegWrite_i     (RegWrite),             
    .RS1data_o      (RS1data),              
    .RS2data_o      (RS2data)               
);

MUX32 MUX_ALUSrc(
    .data1_i        (RS2data),          
    .data2_i        (Sign_Extend_data),    
    .select_i       (ALUSrc),               
    .data_o         (Mux_data)              
);

ALU ALU(
    .data1_i        (RS1data),                  
    .data2_i        (Mux_data),
    .ALUCtrl_i      (ALUCtrl),                
    .data_o         (ALU_data)            
);

ALU_Control ALU_Control(
    .funct_i        ({instr[31:25],instr[14:12]}),  
    .ALUOp_i        (ALUOp),                        
    .ALUCtrl_o      (ALUCtrl)                       
);

// Changed & Need Connect Wire (10/12 JT)
PC PC(
    .clk_i          (clk_i),     
    .rst_i          (rst_i),     
    .start_i        (start_i),  
    .PCWrite_i      (),   
    .pc_i           (next_instr_addr),     
    .pc_o           (instr_addr)           
);

Control Control(
    .Op_i           (instr[31:0]),       
    .NoOp_i         (), 
    .RegWrite_o     (RegWrite),
    .MemtoReg_o     (),
    .MemRead_o      (),
    .MemWrite_o     (),
    .ALUOp_o        (ALUOp),    
    .ALUSrc_o       (ALUSrc),
    .Branch_o       ()
);

Sign_Extend Sign_Extend(
    .data_i         (instr[31:0]),        
    .MemWrite_i     (),
    .Branch_i       (),                       
    .data_o         (Sign_Extend_data) 
);



// *************** Load/Store *************** //
Data_Memory Data_Memory(
    .clk_i          (),
    .addr_i         (),
    .MemRead_i      (),
    .MemWrite_i     (),
    .data_i         (),
    .data_o         ()
);

MUX32 MUX_MemtoReg(
    .data1_i        (),          
    .data2_i        (),    
    .select_i       (),               
    .data_o         ()              
);

// *************** Pipeline Register *************** //

Register_IFID IFID(
    .clk_i          (),
    .start_i        (),

    // PC & HAzard & Instruction
    .pc_i           (),
    .Stall_i        (),
    .Flush_i        (),
    .instr_i        (),

    .pc_o           (),
    .instr_o        ()
);

Register_IDEX IDEX(
    .clk_i              (),
    .start_i            (),

    // Instruction & Data
    .RS1Data_i          (),
    .RS2Data_i          (),
    .SignExtended_i     (),
    .funct_i            (),     // 10bits instr[31:25,14:12]    funct 3 and funct 7  
    .RS1_Addr_i         (),     // 5 bits instr[19:15]          rs1                     
    .RS2_Addr_i         (),     // 5 bits instr[24:20]          rs2                     
    .Rd_Addr_i          (),      // 5 bits instr[11:7]           rd

    .RS1Data_o          (),
    .RS2Data_o          (),
    .SignExtended_o     (),
    .funct_o            (),
    .RS1_Addr_o         (),     
    .RS2_Addr_o         (),
    .Rd_Addr_o          (),

    // Control 
    .RegWrite_i         (), 
    .MemToReg_i         (),
    .MemRead_i          (), 
    .MemWrite_i         (), 
    .ALUOp_i            (),   
    .ALUSrc_i           (),   

    .RegWrite_o         (),
    .MemToReg_o         (),
    .MemRead_o          (),
    .MemWrite_o         (),
    .ALUOp_o            (),
    .ALUSrc_o           ()
);

Register_EXMEM EXMEM(
    .clk_i              (),
    .start_i            (),

    // Instruction & Data
    .ALU_Result_i       (),
    .Write_Data_i       (),
    .Rd_Addr_i          (),

    .ALU_Result_o       (),
    .Write_Data_o       (),
    .Rd_Addr_o          (),

    // Control 
    .RegWrite_i         (),
    .MemToReg_i         (),
    .MemRead_i          (),  
    .MemWrite_i         (), 

    .RegWrite_o         (), 
    .MemToReg_o         (), 
    .MemRead_o          (),  
    .MemWrite_o         ()
);

Register_MEMWB MEMWB(
    .clk_i              (),
    .start_i            (),

    // Address & Data & Instruction  
    .MemAddr_i          (),
    .MemRead_Data_i     (),
    .Rd_Addr_i          (),

    .MemAddr_o          (),
    .MemRead_Data_o     (),
    .Rd_Addr_o          (),

    //Control 
    .RegWrite_i         (),
    .MemToReg_i         (),

    .RegWrite_o         (),
    .MemToReg_o         ()
);

// *************** Branch *************** //
Equal Equal(
    .data1_i    (),
    .data2_i    (),
    .equal_o    ()
);

Shift_Left ShiftLeft(
    .data_i     (), 
    .data_o     ()
);

Adder Branch_Adder(
    .data1_in       (instr_addr),       
    .data2_in       (),            
    .data_o         (next_instr_addr)   
);

MUX32 MUX_PC(
    .data1_i        (),          
    .data2_i        (),    
    .select_i       (),               
    .data_o         ()              
);

endmodule

