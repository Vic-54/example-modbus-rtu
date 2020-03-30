(*@PROPERTIES_EX@
TYPE: POU
LOCALE: 0
IEC_LANGUAGE: ST
PLC_TYPE: independent
PROC_TYPE: independent
*)
(*@KEY@:DESCRIPTION*)

(*@KEY@:END_DESCRIPTION*)
PROGRAM MockDevices

(*Group:Slaves*)


VAR
	SlaveDevice_01 :	SlaveDevice;
	SlaveDevice_02 :	SlaveDevice;
	xActivateSlave01 :	BOOL := TRUE;
	xActivateSlave02 :	BOOL := TRUE;
END_VAR


(*Group:Global*)


VAR_EXTERNAL
	udtRS485Line :	udtRS485Frame;
END_VAR


VAR
	xDebug :	BOOL;
END_VAR


(*@KEY@: WORKSHEET
NAME: MockDevices
IEC_LANGUAGE: ST
*)
(*	Slave 01 *)
SlaveDevice_01.xActivate		:= xActivateSlave01;
SlaveDevice_01.xDebug			:= xDebug;
SlaveDevice_01.strConsoleId		:= 'SLV_01';
SlaveDevice_01.uiSlaveAddress	:= UINT#01;
SlaveDevice_01.udtRS485Line		:= udtRS485Line;

SlaveDevice_01();

udtRS485Line					:= SlaveDevice_01.udtRS485Line;


(*	Slave 02 *)
SlaveDevice_02.xActivate		:= xActivateSlave02;
SlaveDevice_02.xDebug			:= xDebug;
SlaveDevice_02.strConsoleId		:= 'SLV_02';
SlaveDevice_02.uiSlaveAddress	:= UINT#02;
SlaveDevice_02.udtRS485Line		:= udtRS485Line;

SlaveDevice_02();

udtRS485Line					:= SlaveDevice_02.udtRS485Line;

(*@KEY@: END_WORKSHEET *)
END_PROGRAM
