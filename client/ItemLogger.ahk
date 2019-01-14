#NoEnv
SendMode Input
#MaxHotkeysPerInterval 1000
#IfWinActive,Path of Exile


sleep 1000

~F2::
	Send ^c
	
	sleep, 100
	
	WinHTTP := ComObjCreate("WinHTTP.WinHttpRequest.5.1")
	;~ WinHTTP.SetProxy(0)
	WinHTTP.Open("POST", "http://poe-logger.ngrok.io/items", 0)
	;WinHTTP.SetCredentials("item_string", clipboard, 0)
	WinHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	Body := "item_string=" . UriEncode(clipboard)
	WinHTTP.Send(Body)
	Result := WinHTTP.ResponseText
	Status := WinHTTP.Status
	
	if (status <> 200) {
		MsgBox, % Result
	}

Return

UriEncode(Uri)
{
	VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0)
	StrPut(Uri, &Var, "UTF-8")
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	While Code := NumGet(Var, A_Index - 1, "UChar")
		If (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
			|| Code >= 0x61 && Code <= 0x7A) ; a-z
			Res .= Chr(Code)
		Else
			Res .= "%" . SubStr(Code + 0x100, -1)
	SetFormat, IntegerFast, %f%
	Return, Res
}