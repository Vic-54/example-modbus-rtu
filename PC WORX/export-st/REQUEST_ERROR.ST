(*@PROPERTIES_EX@
TYPE: POU
LOCALE: 0
IEC_LANGUAGE: ST
PLC_TYPE: independent
PROC_TYPE: independent
GROUP: Modbus
*)
(*@KEY@:DESCRIPTION*)
**************************************************************************

Copyright © 2016 Phoenix Contact Russia
All rights reserved

**************************************************************************
Name	:	 REQUEST_ERROR

State	:	[ ] evaluation  [x] released

Develop Environment	:
	PC WORX 	:	6.30.1668 (AX SW Suite 2016 Hotfix1)
	Controller	:	AXC 1050 FW v2.10
	Devices		: 	No

**************************************************************************


Change Notes:

Date		Version		Author		Description
--------------------------------------------------------------------------
08.08.16	1.00		konopkov	initial version

**************************************************************************
Description:
Индикация ошибки отсутствия обмена данными при достижении заданного количества 
импульсов на вход Ошибка.

(*@KEY@:END_DESCRIPTION*)
FUNCTION_BLOCK REQUEST_ERROR

(*Group:Input*)


VAR_INPUT
	xReq :	BOOL;(*???? ??????*)
	xDone :	BOOL;(*???? ????? ??*)
	xError :	BOOL;(*???? ????? ??????*)
	iMaxErrorCnt :	INT := 5;(*???????????? ?????????? ????????? ?????? ? ??????????? ??????????????????*)
	tTimeout :	TIME;
END_VAR


(*Group:Output*)


VAR_OUTPUT
	xConnectBroken :	BOOL;(*??????? ??????????????? ?????? ?????*)
	xTimeout :	BOOL;
END_VAR


(*Group:Internal*)


VAR_OUTPUT
	iErrorCnt :	INT;(*??????? ??????*)
END_VAR


(*Group:Instances*)


VAR
	R_TRIG_DONE :	R_TRIG;
	R_TRIG_ERROR :	R_TRIG;
	R_TRIG_REQUEST :	R_TRIG;
	RS_REQUEST :	RS;
	TON_REQUEST :	TON;
END_VAR


(*@KEY@: WORKSHEET
NAME: REQUEST_ERROR
IEC_LANGUAGE: ST
*)
(*
xConnectBroken
xDone
xError
iMaxErrorCnt
*)

IF R_TRIG_ERROR.Q OR TON_REQUEST.Q THEN
	iErrorCnt := iErrorCnt + 1;
END_IF;

IF R_TRIG_DONE.Q THEN
	iErrorCnt := 0;
END_IF;

IF iErrorCnt >= iMaxErrorCnt THEN
	xConnectBroken := TRUE;
ELSE
	xConnectBroken := FALSE;
END_IF;

R_TRIG_DONE(CLK:=xDone);
R_TRIG_ERROR(CLK:=xError);
R_TRIG_REQUEST(CLK:=xReq);


RS_REQUEST.SET 		:= R_TRIG_REQUEST.Q;
RS_REQUEST.RESET1	:= R_TRIG_DONE.Q OR R_TRIG_ERROR.Q OR TON_REQUEST.Q;
RS_REQUEST();

TON_REQUEST.IN		:= RS_REQUEST.Q1;
TON_REQUEST.PT		:= tTimeout;
TON_REQUEST();
xTimeout 			:= TON_REQUEST.Q;


(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
