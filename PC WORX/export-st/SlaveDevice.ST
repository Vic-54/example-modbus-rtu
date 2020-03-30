(*@PROPERTIES_EX@
TYPE: POU
LOCALE: 0
IEC_LANGUAGE: ST
PLC_TYPE: independent
PROC_TYPE: independent
GROUP: Mock
*)
(*@KEY@:DESCRIPTION*)

(*@KEY@:END_DESCRIPTION*)
FUNCTION_BLOCK SlaveDevice

(*Group:Inouts*)


VAR_IN_OUT
	udtRS485Line :	udtRS485Frame;
END_VAR


(*Group:Inputs*)


VAR_INPUT
	xActivate :	BOOL;
	xDebug :	BOOL;
	strConsoleId :	STRING;
	uiSlaveAddress :	UINT := UINT#1;
END_VAR


(*Group:Mock*)


VAR
	IL_UNI07_Slave :	IL_UNI07;
END_VAR


(*Group:Global*)


VAR_EXTERNAL
	RTC_SECONDS :	INT;(*System time (seconds)*)
END_VAR


(*Group:Slave*)


VAR
	MB_IL_UNI07_Slave :	MB_IL_UNI07_Slave_3;
	udtHoldingRegisters :	arrModbus2_w_0_1999;
	udtInputRegisters :	arrModbus2_w_2000_2999;
	udtOutputBits :	arrModbus2_x_3000_3999;
	udtInputBits :	arrModbus2_x_4000_4999;
	arrInputAddressSlave :	MB2_RSUNI_ARR_B_1_14;
	arrOutputAddressSlave :	MB2_RSUNI_ARR_B_1_14;
END_VAR


(*@KEY@: WORKSHEET
NAME: SlaveDevice
IEC_LANGUAGE: ST
*)
(*	IB IL RS UNI (Proceess data 7 words) software replacement *)
IL_UNI07_Slave.xConsoleLog				:= xDebug;
IL_UNI07_Slave.strConsoleId				:= strConsoleId;
IL_UNI07_Slave.udtRS485Line				:= udtRS485Line;
IL_UNI07_Slave.arrInputAddress			:= arrOutputAddressSlave;
IL_UNI07_Slave.arrOutputAddress			:= arrInputAddressSlave;

IL_UNI07_Slave();

udtRS485Line							:= IL_UNI07_Slave.udtRS485Line;
arrOutputAddressSlave					:= IL_UNI07_Slave.arrInputAddress;
arrInputAddressSlave					:= IL_UNI07_Slave.arrOutputAddress;

(*
MB_Master block receives data from 
mocked IB IL RS UNI function block instead of Process data
*)

MB_IL_UNI07_Slave.xActivate				:= xActivate;
MB_IL_UNI07_Slave.bSelectMode			:= BYTE#01;
MB_IL_UNI07_Slave.diBaudrate			:= DINT#9600;
MB_IL_UNI07_Slave.wDataWidth			:= WORD#4;
MB_IL_UNI07_Slave.uiSlaveAddress		:= uiSlaveAddress;
MB_IL_UNI07_Slave.udtHoldingRegisters	:= udtHoldingRegisters;
MB_IL_UNI07_Slave.udtInputRegisters		:= udtInputRegisters;
MB_IL_UNI07_Slave.udtOutputBits			:= udtOutputBits;
MB_IL_UNI07_Slave.udtInputBits			:= udtInputBits;
MB_IL_UNI07_Slave.arrInputAddress		:= arrInputAddressSlave;
MB_IL_UNI07_Slave.arrOutputAddress		:= arrOutputAddressSlave;

MB_IL_UNI07_Slave();

udtHoldingRegisters         			:= MB_IL_UNI07_Slave.udtHoldingRegisters;
udtInputRegisters           			:= MB_IL_UNI07_Slave.udtInputRegisters;		
udtOutputBits           				:= MB_IL_UNI07_Slave.udtOutputBits;
udtInputBits            				:= MB_IL_UNI07_Slave.udtInputBits;
arrInputAddressSlave            		:= MB_IL_UNI07_Slave.arrInputAddress;
arrOutputAddressSlave           		:= MB_IL_UNI07_Slave.arrOutputAddress;

(*	Fill in register value *)
udtHoldingRegisters[1]					:= INT_TO_WORD(100 * UINT_TO_INT(uiSlaveAddress)+ RTC_SECONDS);

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
