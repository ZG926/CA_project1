# CA_project1

 CPU.v 裏面的module name照著我在Hackmd裏面寫的改， 至於各個module裏面的 .input_i() 和 .output_o() 你可以開我們寫好的module.v去查
 ## CPU.v Module 名稱
```
*.v File             Module Name
------------------------------------
Adder.v              Adder  
ALU.v                ALU
ALU_Control          ALU_Control  
Control              Control   
Data_Memory          Data_Memory
Instruction_Memory   Instruction_Memory
Equal                Equal
MUX32                MUX32   
PC                   PC
Register_IFID        Register_IFID    
Register_IDEX        Register_IDEX     
Register_EXMEM       Register_EXMEM     
Register_MEMWB       Register_MEMWB     
Register             Registers
Shift_Left           Shift_Left
Sign_Extend          Sign_Extend  

//Forwarding related
Forwarding_Unit.v    Forwarding_Unit
MUX32_4.v            MUX32_4

** MUX32 會用到三次（ALUSrc，MemtoReg，Branch）
** Adder 會用到兩次(PC + 4 , PC + immediate)

```
 有提到會重複利用的module，就用同一個module，但名字必須不同
 
## 如何寫CPU.v的接線
格式
```
[module name] [actual Unit neme](
    .[io_wire_name1 in the module] (wire1 from outside)
    .[io_wire_name2 in the module] (wire2 from outside)
    .[io_wire_name3 in the module] (wire3 from outside)
    以此類推
);

這裏面的module_name就好像C裏面的
struct list{

}

而call_name就好像 first_list,second_list
struct list first_list;
struct list second_list;

```
example
```
MUX32 MUX_ALUSrc(
    .data1_i        (RS2data),          
    .data2_i        (Sign_Extend_data),    
    .select_i       (ALUSrc),               
    .data_o         (Mux_data)              
);

MUX32 MUX_MemtoReg(
    .data1_i        (),          
    .data2_i        (),    
    .select_i       (),               
    .data_o         ()              
);


  		
MUX32 MUX_PC(
    .data1_i        (),          
    .data2_i        (),    
    .select_i       (),               
    .data_o         ()              
);

```

 
 
 
