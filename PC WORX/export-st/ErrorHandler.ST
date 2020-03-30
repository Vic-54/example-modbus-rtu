(*@PROPERTIES_EX@
TYPE: POU
LOCALE: 0
IEC_LANGUAGE: ST
PLC_TYPE: independent
PROC_TYPE: independent
GROUP: Modbus
*)
(*@KEY@:DESCRIPTION*)

(*@KEY@:END_DESCRIPTION*)
FUNCTION_BLOCK ErrorHandler

(*Group:Default*)


VAR_INPUT
	xError :	BOOL;
END_VAR


VAR
	wLastDiagCode :	WORD;
	wLastAddDiagCode :	WORD;
END_VAR


VAR_INPUT
	wDiagCode :	WORD;
	wAddDiagCode :	WORD;
END_VAR


(*@KEY@: WORKSHEET
NAME: ErrorHandler
IEC_LANGUAGE: ST
*)
IF xError THEN

	wLastDiagCode := wDiagCode;
	wLastAddDiagCode := wAddDiagCode;

END_IF;
(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
