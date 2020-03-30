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
FUNCTION_BLOCK TIME_DIFF

(*Group:Default*)


VAR_INPUT
	xReset :	BOOL;
	xIN1 :	BOOL;
	xIN2 :	BOOL;
END_VAR


VAR_OUTPUT
	diSystemTickDiff :	DINT;
END_VAR


VAR
	diSystemTick_IN1 :	DINT;
	diSystemTick_IN2 :	DINT;
	R_TRIG_1 :	R_TRIG;
	R_TRIG_2 :	R_TRIG;
	R_TRIG_3 :	R_TRIG;
END_VAR


VAR_EXTERNAL
	PLC_SYS_TICK_CNT :	DINT;(*Number of system ticks*)
END_VAR


(*@KEY@: WORKSHEET
NAME: TIME_DIFF
IEC_LANGUAGE: ST
*)
R_TRIG_1(CLK:=xIN1);

R_TRIG_2(CLK:=xIN2);

R_TRIG_3(CLK:=xReset);

IF R_TRIG_1.Q THEN
	diSystemTick_IN1 := PLC_SYS_TICK_CNT;
END_IF;

IF R_TRIG_2.Q THEN
	diSystemTick_IN2 := PLC_SYS_TICK_CNT;
	diSystemTickDiff := diSystemTick_IN2 - diSystemTick_IN1;
END_IF;

IF R_TRIG_3.Q THEN
	diSystemTick_IN1 := DINT#0;
	diSystemTick_IN2 := DINT#0;
	diSystemTickDiff := DINT#0;
END_IF;

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
