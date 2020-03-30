(*@PROPERTIES_EX@
TYPE: POU
LOCALE: 0
IEC_LANGUAGE: ST
PLC_TYPE: independent
PROC_TYPE: independent
*)
(*@KEY@:DESCRIPTION*)

(*@KEY@:END_DESCRIPTION*)
PROGRAM Main

(*Group:Master*)


VAR
	MB_IL_UNI07_Master :	MB_IL_UNI07_Master_5;
	MB_RTU_FC3 :	MB_RTU_FC3_5;
	R_TRIG_MASTER_ACTIVE :	R_TRIG;
	xActivateMaster :	BOOL := TRUE;
	xResetMaster :	BOOL;
	udtMbDataMaster :	udtModbus2_Data;
	arrInputAddressMaster :	MB2_RSUNI_ARR_B_1_14;
	arrOutputAddressMaster :	MB2_RSUNI_ARR_B_1_14;
	wDiagCodeFC3 :	WORD;
	wAddDiagCodeFC3 :	WORD;
	xStartOfPoll :	BOOL;
	xEndOfPoll :	BOOL;
END_VAR


(*Group:Global*)


VAR_EXTERNAL
	udtRS485Line :	udtRS485Frame;
END_VAR


VAR
	MB_RTU_FC6 :	MB_RTU_FC6_5;
	REQ_CNT :	REQ_CNT;
	ModbusControl :	udtModbusControl;
END_VAR


(*Group:Slave handlers*)


VAR
	xActivate01 :	BOOL := TRUE;
	ModbusDeviceHandler01 :	ModbusDeviceHandler;
	ModbusDeviceData01 :	udtModbusDevice;
	xConnectionBroken01 :	BOOL;
	diTimeDiff01 :	DINT;
	iRtcData01 :	INT;
	xActivate02 :	BOOL := TRUE;
	ModbusDeviceHandler02 :	ModbusDeviceHandler;
	ModbusDeviceData02 :	udtModbusDevice;
	xConnectionBroken02 :	BOOL;
	diTimeDiff02 :	DINT;
	iRtcData02 :	INT;
END_VAR


(*Group:Mock*)


VAR
	xDebug :	BOOL;
	IB_IL_RS_UNI_07_Master :	IL_UNI07;
END_VAR


(*@KEY@: WORKSHEET
NAME: Master
IEC_LANGUAGE: ST
*)
(*	Detect if Responce or Request Counters are not incrementing, and re-activate Master block *)
REQ_CNT.tTimeDelayRequests				:= T#5S;
REQ_CNT.tTimeDelayResponces				:= T#30S;
REQ_CNT.uiReqNo							:= MB_IL_UNI07_Master.uiRequestsCounter;
REQ_CNT.uiRespNo						:= MB_IL_UNI07_Master.uiResponsesCounter;

REQ_CNT();

xActivateMaster							:= NOT REQ_CNT.xOut;

(*	Start of request to first device in a line *)
xStartOfPoll							:= R_TRIG_MASTER_ACTIVE.Q OR xEndOfPoll;

R_TRIG_MASTER_ACTIVE.CLK				:= MB_IL_UNI07_Master.xActive;
R_TRIG_MASTER_ACTIVE();

(*
MB_Master block sends data to 
mocked IB IL RS UNI function block instead of Process data
*)

MB_IL_UNI07_Master.xActivate			:= xActivateMaster;
MB_IL_UNI07_Master.bSelectMode			:= BYTE#01;
MB_IL_UNI07_Master.diBaudrate			:= DINT#9600;
MB_IL_UNI07_Master.wDataWidth			:= WORD#4;
MB_IL_UNI07_Master.tTimeout				:= T#1S;
MB_IL_UNI07_Master.xReset				:= xResetMaster;
MB_IL_UNI07_Master.udtMBData			:= udtMbDataMaster;
MB_IL_UNI07_Master.arrInputAddress		:= arrInputAddressMaster;
MB_IL_UNI07_Master.arrOutputAddress		:= arrOutputAddressMaster;

MB_IL_UNI07_Master();

udtMbDataMaster							:= MB_IL_UNI07_Master.udtMBData;
arrInputAddressMaster					:= MB_IL_UNI07_Master.arrInputAddress;
arrOutputAddressMaster					:= MB_IL_UNI07_Master.arrOutputAddress;


(*	FC3 = Read multiple holding registers *)
MB_RTU_FC3.xActivate					:= MB_IL_UNI07_Master.xActive;
MB_RTU_FC3.xSendRequest					:= ModbusControl.xSendRequest_FC3;
MB_RTU_FC3.xEnablePoll					:= FALSE;
MB_RTU_FC3.uiSlaveAddress				:= ModbusControl.uiSlaveAddress;
MB_RTU_FC3.uiStartAddress				:= ModbusControl.uiStartAddress_FC3;
MB_RTU_FC3.iDataCount					:= ModbusControl.iDataCount_FC3;
MB_RTU_FC3.arrReadData					:= ModbusControl.arrReadData_FC3;
MB_RTU_FC3.udtMbData					:= udtMbDataMaster;

MB_RTU_FC3();

ModbusControl.xDone_FC3					:= MB_RTU_FC3.xDone;
ModbusControl.xError_FC3				:= MB_RTU_FC3.xError;
wDiagCodeFC3							:= MB_RTU_FC3.wDiagCode;
wAddDiagCodeFC3							:= MB_RTU_FC3.wAddDiagCode;

ModbusControl.arrReadData_FC3			:= MB_RTU_FC3.arrReadData;
udtMbDataMaster							:= MB_RTU_FC3.udtMbData;

ModbusControl.Master_iFunctionCode		:= udtMbDataMaster.iFunctionCode;
ModbusControl.Master_uiRcvDataCount		:= udtMbDataMaster.uiRcvdDataCount;
ModbusControl.Master_uiSlaveAddress		:= udtMbDataMaster.uiSlaveAddress;
ModbusControl.Master_uiStartAddress		:= udtMbDataMaster.uiStartAddress;

(*	FC6 = Write holding register*)
MB_RTU_FC6.xActivate					:= MB_IL_UNI07_Master.xActive;
MB_RTU_FC6.xSendRequest					:= ModbusControl.xSendRequest_FC6;
MB_RTU_FC6.xEnablePoll					:= FALSE;
MB_RTU_FC6.uiSlaveAddress				:= ModbusControl.uiSlaveAddress;
MB_RTU_FC6.uiStartAddress				:= ModbusControl.uiStartAddress_FC6;
MB_RTU_FC6.wValue						:= ModbusControl.wValue_FC6;
MB_RTU_FC6.udtMbData					:= udtMbDataMaster;

MB_RTU_FC6();

ModbusControl.xDone_FC6				    := MB_RTU_FC6.xDone;
ModbusControl.xError_FC6				:= MB_RTU_FC6.xError;
wDiagCodeFC3							:= MB_RTU_FC6.wDiagCode;
wAddDiagCodeFC3							:= MB_RTU_FC6.wAddDiagCode;

udtMbDataMaster							:= MB_RTU_FC6.udtMbData;

(*@KEY@: END_WORKSHEET *)
(*@KEY@: WORKSHEET
NAME: MockMasterModule
IEC_LANGUAGE: ST
*)
(*	IB IL RS UNI (Proceess data 7 words) software replacement *)
IB_IL_RS_UNI_07_Master.xConsoleLog		:= xDebug;
IB_IL_RS_UNI_07_Master.strConsoleId		:= 'MAS';
IB_IL_RS_UNI_07_Master.udtRS485Line		:= udtRS485Line;
IB_IL_RS_UNI_07_Master.arrInputAddress	:= arrOutputAddressMaster;
IB_IL_RS_UNI_07_Master.arrOutputAddress	:= arrInputAddressMaster;

IB_IL_RS_UNI_07_Master();

udtRS485Line							:= IB_IL_RS_UNI_07_Master.udtRS485Line;
arrOutputAddressMaster					:= IB_IL_RS_UNI_07_Master.arrInputAddress;
arrInputAddressMaster					:= IB_IL_RS_UNI_07_Master.arrOutputAddress;

(*@KEY@: END_WORKSHEET *)
(*@KEY@: WORKSHEET
NAME: Devices
IEC_LANGUAGE: ST
*)
(* ModbusDeviceHandler01	*)
ModbusDeviceHandler01.xActivate				:= xActivate01;
ModbusDeviceHandler01.xSendRequest_IN		:= xStartOfPoll;
ModbusDeviceHandler01.uiSlaveAddress		:= UINT#01;
ModbusDeviceHandler01.ModbusDeviceData		:= ModbusDeviceData01;
ModbusDeviceHandler01.tTimeout				:= T#2S;
ModbusDeviceHandler01.udtModbusControl		:= ModbusControl;

ModbusDeviceHandler01();

ModbusDeviceData01							:= ModbusDeviceHandler01.ModbusDeviceData;
ModbusControl								:= ModbusDeviceHandler01.udtModbusControl;

xConnectionBroken01							:= ModbusDeviceHandler01.xConnectionBroken;
diTimeDiff01								:= ModbusDeviceHandler01.diTimeDiff;
iRtcData01									:= ModbusDeviceData01.DataValues.iRtcMinutes;


(* ModbusDeviceHandler02	*)
ModbusDeviceHandler02.xActivate				:= xActivate02;
ModbusDeviceHandler02.xSendRequest_IN		:= ModbusDeviceHandler01.xSendRequest_OUT;
ModbusDeviceHandler02.uiSlaveAddress		:= UINT#02;
ModbusDeviceHandler02.ModbusDeviceData		:= ModbusDeviceData02;
ModbusDeviceHandler02.tTimeout				:= T#2S;
ModbusDeviceHandler02.udtModbusControl		:= ModbusControl;

ModbusDeviceHandler02();

ModbusDeviceData02							:= ModbusDeviceHandler02.ModbusDeviceData;
ModbusControl								:= ModbusDeviceHandler02.udtModbusControl;

xConnectionBroken02							:= ModbusDeviceHandler02.xConnectionBroken;
diTimeDiff02								:= ModbusDeviceHandler02.diTimeDiff;
iRtcData02									:= ModbusDeviceData02.DataValues.iRtcMinutes;


(*	End of device bus*)
xEndOfPoll									:= ModbusDeviceHandler02.xSendRequest_OUT;


(*@KEY@: END_WORKSHEET *)
END_PROGRAM
