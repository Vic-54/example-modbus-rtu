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
FUNCTION_BLOCK MB_RTU_FC6_ABSTRACT

(*Group:Default*)


VAR
	iStep :	INT;
END_VAR


(*Group:Input*)


VAR_INPUT
	xActivate :	BOOL;
	xSendRequest :	BOOL;
	xTimeout :	BOOL;
	uiSlaveAddress :	UINT;
	uiStartAddress :	UINT;
	wValue :	WORD;
END_VAR


(*Group:Output*)


VAR_OUTPUT
	xDone :	BOOL;
	xError :	BOOL;
	xBusy :	BOOL;
END_VAR


(*Group:Inout*)


VAR_IN_OUT
	udtModbusControl :	udtModbusControl;
END_VAR


(*@KEY@: WORKSHEET
NAME: MB_RTU_FC6_ABSTRACT
IEC_LANGUAGE: ST
*)
IF xActivate THEN

	CASE iStep OF

		0:

			xDone	:= FALSE;
			xError	:= FALSE;

			IF xSendRequest THEN

				udtModbusControl.uiSlaveAddress 		:= uiSlaveAddress;
				udtModbusControl.uiStartAddress_FC6		:= uiStartAddress;
				udtModbusControl.wValue_FC6				:= wValue;
				udtModbusControl.xSendRequest_FC6		:= TRUE;

				xBusy	:= TRUE;

				iStep := 1;

			END_IF;

		1:

			udtModbusControl.xSendRequest_FC6      := FALSE;
			udtModbusControl.uiSlaveAddress 		:= uiSlaveAddress;
			udtModbusControl.uiStartAddress_FC6		:= uiStartAddress;
			udtModbusControl.wValue_FC6				:= wValue;

			IF 	(
				(udtModbusControl.xDone_FC6 OR 
	        	udtModbusControl.xError_FC6) AND
	      		(udtModbusControl.Master_uiSlaveAddress  = uiSlaveAddress) AND
	      		(udtModbusControl.Master_uiStartAddress = uiStartAddress) AND
	      		(udtModbusControl.Master_iFunctionCode = 6)
				)
				OR 
				xTimeout


		  	THEN

					xDone	:= udtModbusControl.xDone_FC6;
					xError	:= udtModbusControl.xError_FC6 OR xTimeout;

					xBusy	:= FALSE;

					iStep := 0;

				END_IF;

	END_CASE;
 
ELSE

	xDone	:= FALSE;
	xError	:= FALSE;
	xBusy	:= FALSE;
	iStep	:= 0;

END_IF;

(*@KEY@: END_WORKSHEET *)
END_FUNCTION_BLOCK
