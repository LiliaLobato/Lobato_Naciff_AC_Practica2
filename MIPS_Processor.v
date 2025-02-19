/******************************************************************
* Description
*	This is the top-level of a MIPS processor that can execute the next set of instructions:
*		add
*		addi
*		sub
*		ori
*		or
*		and
*		nor
* This processor is written Verilog-HDL. Also, it is synthesizable into hardware.
* Parameter MEMORY_DEPTH configures the program memory to allocate the program to
* be execute. If the size of the program changes, thus, MEMORY_DEPTH must change.
* This processor was made for computer architecture class at ITESO.
* Version:
*	1.5
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	2/09/2018
******************************************************************/


module MIPS_Processor
#(
	parameter MEMORY_DEPTH = 64,
	parameter PC_INCREMENT = 4
)

(
	// Inputs
	input clk,
	input reset,
	input [7:0] PortIn,
	// Output
	output [31:0] ALUResultOut,
	output [31:0] PortOut
);
//******************************************************************/
//******************************************************************/
assign  PortOut = 0;

//******************************************************************/
//******************************************************************/
// signals to connect modules
wire branch_eq_ne_wire;
wire reg_dst_wire;
wire not_zero_and_brach_ne;
wire zero_and_brach_eq;
wire or_for_branch;
wire alu_src_wire;
wire reg_write_wire;
wire zero_wire;
wire [2:0] aluop_wire;
wire [3:0] alu_operation_wire;
wire [4:0] write_register_wire;
wire [31:0] mux_pc_wire;
wire [31:0] pc_wire;
wire [31:0] instruction_bus_wire;
wire [31:0] read_data_1_wire;
wire [31:0] read_data_2_wire;
wire [31:0] Inmmediate_extend_wire;
wire [31:0] read_data_2_orr_inmmediate_wire;
wire [31:0] alu_result_wire;
wire [31:0] pc_plus_4_wire;
wire [31:0] pc_to_branch_wire;

// agregado en pract 2
wire MemRead_wire;
wire MemWrite_wire;
wire Jump_wire;
wire MemtoReg_wire;

wire PCSrc_wire;

wire JumpR_wire;
wire JumpJal_wire;

wire [04:0] MUX_Ra_WriteRegister_wire;
wire [31:0] ReadData_wire;
wire [31:0] MUX_ReadData_ALUResult_wire;
wire [31:0] PC_Shift2_wire;
wire [31:0] ShiftLeft2_SignExt_wire;
wire [31:0] Shifted28_wire;
wire [31:0] MUX_to_PC_wire;
wire [31:0] MUX_to_MUX_wire;
wire [31:0] MUX_ForRetJumpAndJump;
wire [31:0] MUX_Jal_ReadData_ALUResult_wire;

//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/

//Modificaciones 
Control // agregamos las señales faltantes
ControlUnit
(
	.OP(instruction_bus_wire[31:26]),
	.RegDst(reg_dst_wire),
	.BranchEQ_NE(branch_eq_ne_wire), //
	.MemRead (MemRead_wire), 
	.MemtoReg (MemtoReg_wire), //
	.MemWrite (MemWrite_wire), //
	.ALUOp(aluop_wire),
	.ALUSrc(alu_src_wire),
	.Jump (Jump_wire), //
	.RegWrite(reg_write_wire)
);

//Agregado en pract 2
DataMemory //conectamos nuestra RAM
#(	 
	 .DATA_WIDTH(32),
	 .MEMORY_DEPTH(1024)

)
DataMemory
(
	//In
	.clk(clk),
	.WriteData(read_data_2_wire),
	.Address({20'b0,alu_result_wire[11:0]>>2}),
	.MemRead(MemRead_wire),
	.MemWrite(MemWrite_wire),
	//out
	.ReadData(ReadData_wire)
	
	
);

ShiftLeft2 //Mueve la direccion << 2 para poder accedar a memoria (lo haca multiplo de 4) 
Left2
( //Inmmediate_extend_wire
	.DataInput(Inmmediate_extend_wire), //Nos da un error así que concatenamos directamente
	.DataOutput(ShiftLeft2_SignExt_wire)
);

ShiftLeft2 //concatenamos la direccion de salto
ShiftLeft28
(
	.DataInput({6'b00000,instruction_bus_wire[25:0]}),

	.DataOutput(Shifted28_wire)
);

assign PCSrc_wire = branch_eq_ne_wire & zero_wire; //Define si es un salto u otra instruccion

Adder32bits //Agrega PC4 al JumpAddress para hacerla de 32 bits
PC_Adder_Shift2
(
	.Data0(pc_plus_4_wire),
	
	//.Data1(Inmmediate_extend_wire),
	.Data1({Inmmediate_extend_wire[29:0],2'b00}),
	
	.Result(PC_Shift2_wire) //queda PC4 + JumpAddress[25-0] + 00


);

//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/


PC_Register
ProgramCounter
(
	.clk(clk),
	.reset(reset),
	.NewPC(MUX_to_PC_wire), //se cambió para aumentar 4 o al salto
	.PCValue(pc_wire)
);

ProgramMemory
#(
	.MEMORY_DEPTH(MEMORY_DEPTH)
)
ROMProgramMemory
(
	.Address(pc_wire),
	.Instruction(instruction_bus_wire)
);

Adder32bits
PC_Puls_4
(
	.Data0(pc_wire),
	.Data1(PC_INCREMENT),
	
	.Result(pc_plus_4_wire)
);

//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/

Multiplexer2to1 //se selecciona el registro a escribir
#(
	.NBits(5)
)
MUX_ForRTypeAndIType
(
	.Selector(reg_dst_wire),
	.MUX_Data0(instruction_bus_wire[20:16]),
	.MUX_Data1(instruction_bus_wire[15:11]),
	
	.MUX_Output(write_register_wire)

);

RegisterFile // Modificado
Register_File
(
	.clk(clk),
	.reset(reset),
	.RegWrite(reg_write_wire),
	.WriteRegister(MUX_Ra_WriteRegister_wire), //elige escribir RA o dato
	.ReadRegister1(instruction_bus_wire[25:21]),
	.ReadRegister2(instruction_bus_wire[20:16]),
	.WriteData(MUX_Jal_ReadData_ALUResult_wire), //JumpAdress 
	.ReadData1(read_data_1_wire),
	.ReadData2(read_data_2_wire)
);

SignExtend
SignExtendForConstants
(   
	.DataInput(instruction_bus_wire[15:0]),
   .SignExtendOutput(Inmmediate_extend_wire)
);

Multiplexer2to1 //seleccionamos si vamos a leer de los registros o el valor de inmediato
#(
	.NBits(32)
)
MUX_ForReadDataAndInmediate
(
	.Selector(alu_src_wire),
	.MUX_Data0(read_data_2_wire),
	.MUX_Data1(Inmmediate_extend_wire),
	
	.MUX_Output(read_data_2_orr_inmmediate_wire)

);

ALUControl
ArithmeticLogicUnitControl
(
	.ALUOp(aluop_wire),
	.ALUFunction(instruction_bus_wire[5:0]),
	.ALUOperation(alu_operation_wire)

);

ALU
ArithmeticLogicUnit 
(
	.ALUOperation(alu_operation_wire),
	.A(read_data_1_wire),
	.B(read_data_2_orr_inmmediate_wire),
	.Zero(zero_wire),
	.shamt(instruction_bus_wire[10:6]),
	.ALUResult(alu_result_wire)
);

//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/

//MUX agregado en pract 2

//aiuda
Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForALUResultAndReadData //seleccionamos que resultado debemos enviar para escribir
(
	.Selector(MemtoReg_wire),
	.MUX_Data0(alu_result_wire),
	.MUX_Data1(ReadData_wire),

	.MUX_Output(MUX_ReadData_ALUResult_wire)
);

assign JumpR_wire = (alu_operation_wire == 4'b1110) ? 1'b1 : 1'b0; //vamos a ver si la instruccion fue JR
assign JumpJal_wire = ({instruction_bus_wire[31:26],Jump_wire} == 7) ? 1'b1 : 1'b0; // o vemos si es Jal

Multiplexer2to1
MUX_ForRJumpAndJump //seleccionamos la siguente instruccion del PC/jump
(
	.Selector(JumpR_wire),
	.MUX_Data0(MUX_ForRetJumpAndJump),
	.MUX_Data1(read_data_1_wire),

	.MUX_Output(MUX_to_PC_wire)
);


Multiplexer2to1 //vemos si vamos a hacer jal o ejecutaremos la siguiente instruccion
#(
	.NBits(32)
)
MUX_ForJalAndReadData_AlUResult
(
	.Selector(JumpJal_wire),
	.MUX_Data0(MUX_ReadData_ALUResult_wire),
	.MUX_Data1(pc_plus_4_wire),

	.MUX_Output(MUX_Jal_ReadData_ALUResult_wire)
);

Multiplexer2to1 //seleccionamos el registro en el que escribiremos RA/Registro N
#(
	.NBits(5)
)
MUX_WriteRegister_Ra
(
	.Selector(JumpJal_wire),
	.MUX_Data0(write_register_wire),
	.MUX_Data1(5'b11111),

	.MUX_Output(MUX_Ra_WriteRegister_wire)
);

Multiplexer2to1 //seleccionamos cual sera la siguiente instruccion 
#(
	.NBits(32)
)
PCShift_OR_PC
(
	.Selector(PCSrc_wire), //decide si la siguiente instruccion es de la direccion a la que saltamos o la que sigue en pc+4
	.MUX_Data0(pc_plus_4_wire),
	.MUX_Data1(PC_Shift2_wire),

	.MUX_Output(MUX_to_MUX_wire)
);


Multiplexer2to1 //seleccionamos entre pc o jump
#(
	.NBits(32)
)
MUX_PCJump
(
	.Selector(Jump_wire),
	.MUX_Data0(MUX_to_MUX_wire),
	.MUX_Data1({pc_plus_4_wire[31:28],Shifted28_wire[27:0]}),

	.MUX_Output(MUX_ForRetJumpAndJump)
);

assign ALUResultOut = alu_result_wire;

endmodule

