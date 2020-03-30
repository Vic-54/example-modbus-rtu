(*@PROPERTIES_EX@
TYPE: POU
LOCALE: 0
IEC_LANGUAGE: ST
PLC_TYPE: independent
PROC_TYPE: independent
GROUP: Modbus
*)
(*@KEY@:DESCRIPTION*)
(*
FB generate a boolean output if:
	uiReqNo
	uiRespNo
do not counting up longer than specified delay time

*)
************
Versioning
************

15.01.2016	KONOPKOV Inital Version

(*@KEY@:END_DESCRIPTION*)
FUNCTION_BLOCK REQ_CNT

(*Group:outputs*)


VAR_OUTPUT
	xOut :	BOOL;
END_VAR


(*Group:internal*)


VAR
	uiReqNo_Registered :	UINT {RDT};
	uiRespNo_Registered :	UINT {RDT};
	TON_1 :	TON;
	TON_2 :	TON;
END_VAR


(*Group:inputs*)


VAR_INPUT
	xDisable :	BOOL;
	tTimeDelayRequests :	TIME;
	tTimeDelayResponces :	TIME;
	uiReqNo :	UINT;
	uiRespNo :	UINT;
END_VAR


VAR
	R_TRIG_1 :	R_TRIG;
END_VAR


(*@KEY@: WORKSHEET
NAME: REQ_CNT
IEC_LANGUAGE: ST
*)
(*
FB generate a boolean output if:
	uiReqNo
	uiRespNo
do not counting up longer than specified delay time

*)


TON_1.IN := (uiReqNo = uiReqNo_Registered AND NOT xDisable AND NOT xOut);
TON_1.PT := tTimeDelayRequests;
TON_1(); (*uiReqNo*)


TON_2.IN := (uiRespNo = uiRespNo_Registered AND NOT xDisable AND NOT xOut);
TON_2.PT := tTimeDelayResponces;
TON_2(); (*uiRespNo*)


R_TRIG_1.CLK 	:= TON_1.Q OR TON_2.Q;
R_TRIG_1();
xOut			:= R_TRIG_1.Q;

IF uiReqNo <> uiReqNo_Registered THEN
	uiReqNo_Registered := uiReqNo;
END_IF;

IF uiRespNo <> uiRespNo_Registered THEN
	uiRespNo_Registered := uiRespNo;
END_IF;




(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
