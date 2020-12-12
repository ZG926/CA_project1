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
wire    [31:0]      instr_addr,next_instr_addr,instr,RS2data,RS1data,Mux_data,ALU_data,Sign_Extend_data,Four, lastmux;
wire    [1:0]       ALUOp;
wire    [3:0]       ALUCtrl;
wire                RegWrite,ALUSrc;

//Added Wire
wire flush;                 
wire stall;                

wire MemtoReg;    
wire MemRead;      
wire MemWrite;     
wire Branch;            

wire NoOp;              
wire PCWrite;           

wire [1:0] ForwardA, ForwardB;  
wire [31:0] muxA_o,muxB_o;     

//wires needed for IF/ID
wire [31:0] IFID_instr;
wire [31:0] IFID_instr_addr;  

//wires needed for ID/EX
wire IDEX_ALUSrc, IDEX_RegWrite, IDEX_MemWrite, IDEX_MemRead, IDEX_MemtoReg;
wire [31:0] IDEX_RS1data, IDEX_RS2data, IDEX_Sign_Extend_data;
wire [4:0]  ExRs1, ExRs2, ExRd;                                   
//wire [9:0]  IDEX_instr[31:25],14:12];                                  
wire [9:0]  IDEX_instr;                                 
wire [1:0]  IDEX_ALUOp;  

//wires needed for EX/MEM 
wire EXMEM_RegWrite, EXMEM_MemtoReg;
wire [31:0] EXMEM_ALU_data;
wire EXMEM_MemRead, EXMEM_MemWrite;
wire [31:0] EXMEM_muxB_o;
wire [4:0] EXMEM_rd;

//wires needed in MEM/WB
wire [31:0] MEMWB_EXMEM_ALU_data; 
wire MEMWB_RegWrite,MEMWB_MemtoReg;
wire [4:0] MEMWB_rd;
wire [31:0] MEMWB_Data_Memory_result;
///////////////////////

assign Four = 32'd4;

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
    .RS1addr_i      (IFID_instr[19:15]),         
    .RS2addr_i      (IFID_instr[24:20]),         
    .RDaddr_i       (MEMWB_rd),         
    .RDdata_i       (lastmux),            
    .RegWrite_i     (RegWrite),             
    .RS1data_o      (RS1data),              
    .RS2data_o      (RS2data)               
);

MUX32 MUX_ALUSrc(   
    .data1_i        (muxB_o),          
    .data2_i        (IDEX_Sign_Extend_data),    
    .select_i       (IDEX_ALUSrc),               
    .data_o         (Mux_data)              
);

ALU ALU(
    .data1_i        (RS1data),                  
    .data2_i        (Mux_data),
    .ALUCtrl_i      (ALUCtrl),                
    .data_o         (ALU_data)            
);

ALU_Control ALU_Control(
    .funct_i        (IDEX_instr),  
    .ALUOp_i        (ALUOp),                        
    .ALUCtrl_o      (ALUCtrl)                       
);

PC PC(
    .clk_i          (clk_i),     
    .rst_i          (rst_i),     
    .start_i        (start_i),  
    .PCWrite_i      (PCWrite),   
    .pc_i           (next_instr_addr),     
    .pc_o           (instr_addr)           
);

Control Control(
    .Op_i           (IFID_instr[6:0]),       
    .NoOp_i         (NoOp), 
    .RegWrite_o     (RegWrite),
    .MemtoReg_o     (MemtoReg),
    .MemRead_o      (MemRead),
    .MemWrite_o     (MemWrite),
    .ALUOp_o        (ALUOp),    
    .ALUSrc_o       (ALUSrc),
    .Branch_o       (Branch)
);

Sign_Extend Sign_Extend(
    .data_i         (IFID_instr[31:0]),        
    .MemWrite_i     (MemWrite),    //need to rename (?)
    .Branch_i       (Branch),      // need to rename (?)   
    .data_o         (Sign_Extend_data) 
);



// *************** Load/Store *************** //
Data_Memory Data_Memory(
    .clk_i          (clk_i),
    .addr_i         (EXMEM_ALU_data),
    .MemRead_i      (EXMEM_MemRead),
    .MemWrite_i     (EXMEM_MemWrite),
    .data_i         (EXMEM_muxB_o),
    .data_o         (Data_Memory_result)
);

MUX32 MUX_MemtoReg(     
    .data1_i        (MEMWB_EXMEM_ALU_data),          
    .data2_i        (MEMWB_Data_Memory_result),    
    .select_i       (MEMWB_MemToReg),               
    .data_o         (lastmux)              
);

// *************** Pipeline Register *************** //


Register_IFID IFID(
    .clk_i          (clk_i),
    .start_i        (start_i),     

    // PC & HAzard & Instruction
    .pc_i           (instr_addr),
    .Stall_i        (stall),
    .Flush_i        (flush),
    .instr_i        (instr),

    .pc_o           (IFID_instr_addr),
    .instr_o        (IFID_instr)
);

Register_IDEX IDEX(
    .clk_i          (clk_i),
    .start_i        (start_i),     

    // Instruction & Data
    .RS1Data_i          (RS1data),
    .RS2Data_i          (RS2data),
    .SignExtended_i     (Sign_Extend_data),
    .funct_i            ({IFID_instr[31:25],IFID_instr[14:12]}),     // 10bits instr[31:25,14:12]    funct 3 and funct 7  
    .RS1_Addr_i         (IFID_instr[19:15]),     // 5 bits instr[19:15]          rs1                     
    .RS2_Addr_i         (IFID_instr[24:20]),     // 5 bits instr[24:20]          rs2                     
    .Rd_Addr_i          (IFID_instr[11:7]),      // 5 bits instr[11:7]           rd

    .RS1Data_o          (IDEX_RS1data),
    .RS2Data_o          (IDEX_RS2data),
    .SignExtended_o     (IDEX_Sign_Extend_data),
    .funct_o            (IDEX_instr),
    .RS1_Addr_o         (ExRs1),     
    .RS2_Addr_o         (ExRs2),
    .Rd_Addr_o          (ExRd),

    // Control 
    .RegWrite_i         (RegWrite), 
    .MemToReg_i         (MemtoReg),
    .MemRead_i          (MemRead), 
    .MemWrite_i         (MemWrite), 
    .ALUOp_i            (ALUOp),   
    .ALUSrc_i           (ALUSrc),   

    .RegWrite_o         (IDEX_RegWrite),
    .MemToReg_o         (IDEX_MemtoReg),
    .MemRead_o          (IDEX_MemRead),
    .MemWrite_o         (IDEX_MemWrite),
    .ALUOp_o            (IDEX_ALUOp),
    .ALUSrc_o           (IDEX_ALUSrc)
);

Register_EXMEM EXMEM(
    .clk_i          (clk_i),
    .start_i        (start_i),     //not sure this line need or not

    // Instruction & Data
    .ALU_Result_i       (ALU_data),
    .Write_Data_i       (muxB_o),
    .Rd_Addr_i          (ExRd),

    .ALU_Result_o       (EXMEM_ALU_data),
    .Write_Data_o       (EXMEM_muxB_o),
    .Rd_Addr_o          (EXMEM_rd),

    // Control 
    .RegWrite_i         (IDEX_RegWrite),
    .MemToReg_i         (IDEX_MemToReg),
    .MemRead_i          (IDEX_MemRead),  
    .MemWrite_i         (IDEX_MemWrite), 

    .RegWrite_o         (EXMEM_RegWrite), 
    .MemToReg_o         (EXMEM_MemToReg), 
    .MemRead_o          (EXMEM_MemRead),  
    .MemWrite_o         (EXMEM_MemWrite)
);

Register_MEMWB MEMWB(
    .clk_i          (clk_i),
    .start_i        (start_i),     //not sure this one need or not

    // Address & Data & Instruction  
    .MemAddr_i          (EXMEM_ALU_data),
    .MemRead_Data_i     (Data_Memory_result),
    .Rd_Addr_i          (EXMEM_rd),

    .MemAddr_o          (MEMWB_EXMEM_ALU_data),
    .MemRead_Data_o     (MEMWB_Data_Memory_result),
    .Rd_Addr_o          (MEMWB_rd),

    //Control 
    .RegWrite_i         (EXMEM_RegWrite),
    .MemToReg_i         (EXMEM_MemToReg),

    .RegWrite_o         (MEMWB_RegWrite),
    .MemToReg_o         (MEMWB_MemToReg)
);

// *************** Branch *************** //
Equal Equal(
    .data1_i    (RS1data),
    .data2_i    (RS2data),
    .equal_o    (Equal_result)
);

Shift_Left ShiftLeft(
    .data_i     (Sign_Extend_data), 
    .data_o     (instr_addr)
);

Adder Branch_Adder(
    .data1_in       (instr_addr),       
    .data2_in       (IFID_instr_addr),            
    .data_o         (next_instr_addr)   
);

MUX32 MUX_PC(       //left mux32
    .data1_i        (next_instr_addr),          
    .data2_i        (next_instr_addr),    
    .select_i       (flush),               
    .data_o         (next_instr_addr)              
);


Hazard_Detection Hazard_Detection(
    .MemRead (IDEX_MemRead),   
    .rd  (IDEX_instr[11:7]),    
    .RS1addr_i (IFID_instr[19:15]), 
    .RS2addr_i (IFID_instr[24:20]), 
    .NoOp   (NoOp),         
    .PCWrite (PCWrite),       
    .Stall_o   (stall)          
);

Forwarding_Unit Forward_Unit(
    //from ID/EX
    .EX_Rs1_i       (ExRs1),
    .EX_Rs2_i       (ExRs1),
    .MEM_Rd_i       (EXMEM_IDEX_instr[11:7]),     
    .MEM_Regwrite_i (EXMEM_RegWrite),    
    .WB_Rd_i        (MEMWB_EXMEM_IDEX_instr[11:7]),      
    .WB_RegWrite_i  (MEMWB_RegWrite),
    .Forward_A_o    (ForwardA),     
    .Forward_B_o    (ForwardB)      
);

MUX32_4 Forward_MUX1(      //for ForwardA    //top MUX4    ok
    .read_data_i    (IDEX_RS1data),         //read_data1 00
    .WB_Write_Data_i(WB_Write_Data),         //01
    .MEM_ALU_Result (EXMEM_ALU_data),         //10
    .select_i       (ForwardA),         //from Forwarding Unit
    .mux_o          (muxA_o)          //mux output -> alu
);    

MUX32_4 Forward_MUX2(      //for ForwardB     //bottom MUX4    ok
    .read_data_i    (IDEX_RS2data),         //read_data1 00
    .WB_Write_Data_i(lastmux),         //01
    .MEM_ALU_Result (EXMEM_ALU_data),         //10
    .select_i       (ForwardB),         //from Forwarding Unit
    .mux_o          (muxB_o)          //mux output -> center mux32 & EX/MEM 
);    
////////////////////////////////////////////////////////
endmodule
