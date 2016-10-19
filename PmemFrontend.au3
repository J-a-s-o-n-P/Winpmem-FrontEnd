#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <Constants.au3>
#include <GuiEdit.au3>
#include <ScrollBarsConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <ProgressConstants.au3>
#include <StringConstants.au3>
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>



GUI2()





Func getpcinfo()
   Global $result
   $osinfo = (	"OS Version: " & @TAB & @TAB & "   " & @OSVersion & @CRLF & _
			   "CPU: " & @TAB & @TAB & @TAB &  "   " & @CPUArch & @CRLF & _
			   "OS Build: " & @TAB & @TAB &  "   " & @OSBuild & @CRLF & _
			   "Computername " & @TAB & @TAB &  "   " & @ComputerName & @CRLF & @CRLF)
   $result = $osinfo
   Local $foo = Run(@ComSpec & " /c date /T && time /T && systeminfo && ipconfig /all && netstat -ano && ipconfig /displaydns && arp -a && tasklist /v && wmic.exe os get name && wmic.exe computersystem && wmic.exe group && wmic.exe baseboard && set", "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

   While 1
	  $line = StdoutRead($foo)
	  $result &= $line
	  If @error Then ExitLoop
   Wend

   While 1
	  $line = StderrRead($foo)

	  If @error Then ExitLoop
	  $result &= & @CRLF "========================================== Failed Command ==========================================" & @CRLF & $line & "====================================================================================================" & @CRLF
   Wend

   $sFilePath = @ScriptDir & "\" & @ComputerName & "_Info.txt"
   If Not FileWrite($sFilePath, $result & @CRLF) Then
	  MsgBox($MB_SYSTEMMODAL, "", "An error occurred whilst writing the temporary file.")
	  Return False
   EndIf
EndFunc






Func GUI2()
   Global $gui2edit, $msg

   Global $GUI2 = GUICreate("WinPmem FrontEnd", 400, 350)
   $gui2edit = GUICtrlCreateEdit("" & @CRLF, 10, 40, 380, 240, $ES_AUTOVSCROLL + $WS_VSCROLL)
   $btn2 = GUICtrlCreateButton("Start", 60, 5, 70, 30)
   Global $btn3 = GUICtrlCreateButton("Stop", 250, 5, 70, 30)
   Global $idprogressbar = GUICtrlCreateProgress(10, 285, 380, 30)
   Global $test = GUICtrlCreateLabel("", 10, 325, 380, 20)

   GUISetState(@SW_SHOW)

   While 1
	  Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE
	  GUISetState(@SW_ENABLE, $hGuiWin)
	  GUIDelete($GUI2)
	  ExitLoop

	  case $btn2
		 GUICtrlSetData($test, "Getting Machine info...")
		 getpcinfo()
		 GUICtrlSetData($test, "Done!")
		 Sleep(2000)
		 GUICtrlSetData($test, "")
		 sshISAMVportCHECKER()

	  case $btn3
		 GUICtrlSetData($gui2edit, "")
		 GUICtrlSetData($idprogressbar, 0)
		 GUICtrlSetData($test, "")
	  EndSwitch
   WEnd
EndFunc






Func sshISAMVportCHECKER()
   $line = ""
   $var = 1
   $percent = 1
   $completed = 0
   $totalmb = 0
   $loopy = 1
   $loopnumber = 1
   $outputdir = @ScriptDir & "\" & @ComputerName & "_MemDump\"
   DirCreate( $outputdir)
   Global $foo = Run("winpmem-2.1.post4.exe --format raw -o " & $outputdir, @ScriptDir, @SW_HIDE,$STDIN_CHILD + $STDERR_MERGED)

   While 1
	  If $loopnumber = 1 Then
		 GUICtrlSetData($gui2edit, "Attempting Memory Acquisition..."  )
		 Sleep(1000)
	  EndIf

	  If GUIGetMsg() = $btn3 Then
		 GUICtrlSetData($gui2edit, "Process Stopped!")
		 Sleep(1000)
		 GUICtrlSetData($gui2edit, "")
		 GUICtrlSetData($test, "")
		 ExitLoop
	  EndIf
	  Sleep(500)
	  If GUIGetMsg() = $btn3 Then
		 GUICtrlSetData($gui2edit, "Process Stopped!")
		 Sleep(1000)
		 GUICtrlSetData($gui2edit, "")
		 GUICtrlSetData($test, "")
		 ExitLoop
	  EndIf

	  $line = $line & StdoutRead($foo)
	  If @error Then
		 ExitLoop
	  EndIf

	  GUICtrlSetData($gui2edit, $line)

	  _GUICtrlEdit_Scroll($gui2edit,  $SB_SCROLLCARET )

	  $line = StringReplace($line, "Driver Unloaded.", "Driver Unloaded.")
	  $finoccurnaces = @extended
	  if $finoccurnaces = 2 Then
		 GUICtrlSetData($gui2edit, "Process Finished!")
		 GUICtrlSetData($idprogressbar, 100)
		 GUICtrlSetData($test, "")
		 Sleep(2000)
		 GUICtrlSetData($idprogressbar, 0)
		 ExitLoop
	  EndIf

	  $searchline = $line

	  Local $aArray = StringSplit($searchline, @CR, $STR_ENTIRESPLIT)

	  For $i = 1 To $aArray[0]
		 $arrayline = $aArray[$i]
		 if StringInStr( $arrayline, "reading" , 0) AND $loopy = 1 Then
			GUICtrlSetData($test, "Dumping Memory...")
			$loopy = 2
		 EndIf
		 if StringInStr( $arrayline, "reading" , 0) AND $loopy = 2 Then
			$iPosition = StringInStr($arrayline, "  ")
			$arrayline2 = StringTrimLeft($arrayline, $iPosition)
			$iPosition2 = StringInStr($arrayline2, "MiB", 1, 2)
			$arraynlen = StringLen ($arrayline2)


			#cs
			If GUIGetMsg() = $btn3 Then
			   GUICtrlSetData($gui2edit, "Process Stopped!")
			   Sleep(1000)
			   GUICtrlSetData($gui2edit, "")
			   ExitLoop
			EndIf
			Sleep(500)
			If GUIGetMsg() = $btn3 Then
			   GUICtrlSetData($gui2edit, "Process Stopped!")
			   Sleep(1000)
			   GUICtrlSetData($gui2edit, "")
			   ExitLoop
			EndIf
			#ce

			$arrayline3 = StringTrimRight($arrayline2, $arraynlen - $iPosition2 + 1)
			$array3split = StringSplit($arrayline3, "/")
			$completed = $array3split[1]
			$completed = StringReplace($completed, "MiB", "")
			$totalmb = $array3split[2]
			$percent = $completed / $totalmb * 100
			$percent = Round($percent, 2)
		 EndIf
		 If StringInStr( $arrayline, "adding" , 0) AND $loopy = 2 Then
			   $loopy = 3
			   GUICtrlSetData($test, "Extracting Drivers...")
		 EndIf
	  Next

	  ConsoleWrite($percent & @CRLF)
	  $percent = $completed / $totalmb * 100 - 20
	  GUICtrlSetData($idprogressbar, $percent)
	  $loopnumber = $loopnumber + 1
   WEnd

   ProcessClose($foo)

EndFunc


