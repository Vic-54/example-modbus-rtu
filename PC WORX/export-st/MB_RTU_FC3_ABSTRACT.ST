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
FUNCTION_BLOCK MB_RTU_FC3_ABSTRACT

(*Group:Input*)


VAR_INPUT
	xActivate :	BOOL;
	xSendRequest :	BOOL;
	xTimeout :	BOOL;
	uiSlaveAddress :	UINT;
	uiStartAddress :	UINT;
	iDataCount :	INT;
END_VAR


(*Group:Output*)


VAR_OUTPUT
	xDone :	BOOL;
	xError :	BOOL;
	xBusy :	BOOL;
	arrReadData :	arrModbus2_W_1_125;
END_VAR


(*Group:Inout*)


VAR_IN_OUT
	udtModbusControl :	udtModbusControl;
END_VAR


(*Group:Default*)


VAR
	iStep :	INT;
END_VAR


(*@KEY@: WORKSHEET
NAME: MB_RTU_FC3_ABSTRACT
IEC_LANGUAGE: ST
*)
IF xActivate THEN

	CASE iStep OF

		0:

			xDone	:= FALSE;
			xError	:= FALSE;

			IF xSendRequest THEN

				udtModbusControl.iDataCount_FC3 		:= iDataCount;
				udtModbusControl.uiSlaveAddress 		:= uiSlaveAddress;
				udtModbusControl.uiStartAddress_FC3		:= uiStartAddress;
				udtModbusControl.xSendRequest_FC3		:= TRUE;

				xBusy	:= TRUE;

				iStep := 1;

			END_IF;

		1:

	      udtModbusControl.xSendRequest_FC3     := FALSE;
		  udtModbusControl.iDataCount_FC3 		:= iDataCount;
		  udtModbusControl.uiSlaveAddress 		:= uiSlaveAddress;
		  udtModbusControl.uiStartAddress_FC3	:= uiStartAddress;

	      IF 	((udtModbusControl.xDone_FC3 OR 
	        	udtModbusControl.xError_FC3) AND 
	      		(udtModbusControl.Master_uiRcvDataCount = INT_TO_UINT(iDataCount * 2)) AND
	      		(udtModbusControl.Master_uiSlaveAddress  = uiSlaveAddress) AND
	      		(udtModbusControl.Master_uiStartAddress = uiStartAddress) AND
	      		(udtModbusControl.Master_iFunctionCode = 3))

				OR

				(*
				(xTimeout AND
				(udtModbusControl.Master_uiSlaveAddress  = uiSlaveAddress) AND
	      		(udtModbusControl.Master_uiStartAddress = uiStartAddress) AND
	      		(udtModbusControl.Master_iFunctionCode = 3))
				*)

				xTimeout

		  	THEN

					IF udtModbusControl.xDone_FC3 THEN
						arrReadData := udtModbusControl.arrReadData_FC3;
					END_IF;

					xDone	:= udtModbusControl.xDone_FC3;
					xError	:= udtModbusControl.xError_FC3 OR xTimeout;

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
