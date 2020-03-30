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
FUNCTION_BLOCK ModbusDeviceHandler

(*Group:POU`s*)


VAR
	TIME_DIFF :	TIME_DIFF;
	REQUEST_ERROR :	REQUEST_ERROR;
	MB_RTU_FC3_ABSTRACT :	MB_RTU_FC3_ABSTRACT;
END_VAR


(*Group:INTERNAL*)


VAR
	arrReadData_FC3 :	arrModbus2_W_1_125;
	xBusy_FC3 :	BOOL;
	xDone_FC3 :	BOOL;
	xError_FC3 :	BOOL;
	xTimeout_FC3 :	BOOL;
END_VAR


(*Group:INPUT*)


VAR_INPUT
	xActivate :	BOOL;
	xSendRequest_IN :	BOOL;
	uiSlaveAddress :	UINT;
END_VAR


(*Group:OUTPUT*)


VAR_OUTPUT
	xConnectionBroken :	BOOL;
	diTimeDiff :	DINT;
	xSendRequest_OUT :	BOOL;
END_VAR


(*Group:IN - OUT*)


VAR_INPUT
	ModbusDeviceData :	udtModbusDevice;
END_VAR


VAR_IN_OUT
	udtModbusControl :	udtModbusControl;
END_VAR


(*Group:Default*)


VAR_INPUT
	tTimeout :	TIME;
END_VAR


VAR
	RS_REQUEST_IN_PROGRESS :	RS;
END_VAR


(*@KEY@: WORKSHEET
NAME: ModbusDeviceHandler
IEC_LANGUAGE: ST
*)
(*	Request in progress *)
RS_REQUEST_IN_PROGRESS.SET					:= xActivate AND xSendRequest_IN;
RS_REQUEST_IN_PROGRESS.RESET1				:= NOT xActivate OR (xDone_FC3 OR xError_FC3);
RS_REQUEST_IN_PROGRESS();


(*	FC 3 *)
MB_RTU_FC3_ABSTRACT.xActivate				:= xActivate;
MB_RTU_FC3_ABSTRACT.xSendRequest			:= RS_REQUEST_IN_PROGRESS.Q1;
MB_RTU_FC3_ABSTRACT.xTimeout				:= xTimeout_FC3;
MB_RTU_FC3_ABSTRACT.uiSlaveAddress			:= uiSlaveAddress;
MB_RTU_FC3_ABSTRACT.uiStartAddress			:= UINT#1;
MB_RTU_FC3_ABSTRACT.iDataCount				:= INT#1;
MB_RTU_FC3_ABSTRACT.udtModbusControl		:= udtModbusControl;

MB_RTU_FC3_ABSTRACT();

xDone_FC3									:= MB_RTU_FC3_ABSTRACT.xDone;
xError_FC3									:= MB_RTU_FC3_ABSTRACT.xError;
xBusy_FC3									:= MB_RTU_FC3_ABSTRACT.xBusy;
arrReadData_FC3								:= MB_RTU_FC3_ABSTRACT.arrReadData;
udtModbusControl							:= MB_RTU_FC3_ABSTRACT.udtModbusControl;

(*	Pass the request to the next device handler *)
xSendRequest_OUT							:= RS_REQUEST_IN_PROGRESS.Q1 AND (xDone_FC3 OR xError_FC3);

(*	Detect errors *)
REQUEST_ERROR.xReq							:= xBusy_FC3;
REQUEST_ERROR.xDone							:= xDone_FC3;
REQUEST_ERROR.xError						:= xError_FC3;
REQUEST_ERROR.iMaxErrorCnt					:= 5;
REQUEST_ERROR.tTimeout						:= tTimeout;

REQUEST_ERROR();

xTimeout_FC3								:= REQUEST_ERROR.xTimeout;
ModbusDeviceData.DiagValues.Modbus.xError	:= REQUEST_ERROR.xConnectBroken;
xConnectionBroken							:= REQUEST_ERROR.xConnectBroken;

(*	Measure request time *)
TIME_DIFF.xIN1								:= xSendRequest_IN;
TIME_DIFF.xIN2								:= xSendRequest_OUT;
TIME_DIFF();
diTimeDiff									:= TIME_DIFF.diSystemTickDiff;


(*	Handle data values *)
ModbusDeviceData.DataValues.iRtcMinutes		:= WORD_TO_INT(arrReadData_FC3[1]);

(*	Handle diag values *)
IF ModbusDeviceData.DiagValues.Modbus.xError THEN

	ModbusDeviceData.DiagValues.xError		:=	TRUE;
	ModbusDeviceData.DiagValues.strDiagCode	:=	'RS-485 connection error';

ELSE
	ModbusDeviceData.DiagValues.xError		:=	FALSE;
	ModbusDeviceData.DiagValues.strDiagCode	:=	'OK';
END_IF;

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
