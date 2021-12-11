#include <MsgBoxConstants.au3>
#include <File.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <StringConstants.au3>

$aTmp = _PathSplit(@ScriptFullPath,"", "", "", "")
$sINIFile = @ScriptDir & "\" & $aTmp[$PATH_FILENAME] & ".ini"

Check("89.184.82.91:80",300)

if FileExists($sINIFile) Then
   $aINISections = IniReadSectionNames($sINIFile)
   if IsArray($aINISections) Then
	  $iHostsSection=_ArraySearch($aINISections,"Hosts")
	  if $iHostsSection>0 Then
		 $iMaxLength = 0
		 $aHosts = IniReadSection($sINIFile,"Hosts")
		 if IsArray($aHosts) Then
			$iGlobalSection = _ArraySearch($aINISections,"Global")
			$iTextSize = 7
			$iIcoSize = 32
			$iIcoPage = 10
			$iBorder = 10
			$sIcoOk = "shell32.dll"
			$iIcoOk = ""
			$sIcoFail = "shell32.dll"
			$sIcoFail = ""
			$iTime = 400
			if $iGlobalSection>0 Then
			   $aGlobal = IniReadSection($sINIFile,"Global")
			   if IsArray($aGlobal) Then
				  for $i = 1 To $aGlobal[0][0]
					 if StringLower($aGlobal[$i][0])=StringLower("IconSize") Then $iIcoSize = Int($aGlobal[$i][1])
					 if StringLower($aGlobal[$i][0])=StringLower("IconPage") Then $iIcoPage = Int($aGlobal[$i][1])
					 if StringLower($aGlobal[$i][0])=StringLower("Border") Then $iBorder = Int($aGlobal[$i][1])
					 if StringLower($aGlobal[$i][0])=StringLower("TextSize") Then $iTextSize = Int($aGlobal[$i][1])
					 if StringLower($aGlobal[$i][0])=StringLower("Timeout") Then $iTime = Int($aGlobal[$i][1])
					 if StringLower($aGlobal[$i][0])=StringLower("IconOk") Then
						if IsString($aGlobal[$i][1]) Then
						   if StringInStr($aGlobal[$i][1],",")>0 Then
							  $aTmp = StringSplit($aGlobal[$i][1],",")
							  $sIcoOk = StringStripWS($aTmp[1],$STR_STRIPLEADING + $STR_STRIPTRAILING)
							  $iIcoOk = StringStripWS($aTmp[2],$STR_STRIPLEADING + $STR_STRIPTRAILING)
						   Else
							  $sIcoOk = $aGlobal[i][1]
						   EndIf
						EndIf
					 EndIf
					 if StringLower($aGlobal[$i][0])=StringLower("IconFail") Then
						if IsString($aGlobal[$i][1]) Then
						   if StringInStr($aGlobal[$i][1],",")>0 Then
							  $aTmp = StringSplit($aGlobal[$i][1],",")
							  $sIcoFail = StringStripWS($aTmp[1],$STR_STRIPLEADING + $STR_STRIPTRAILING)
							  $iIcoFail = StringStripWS($aTmp[2],$STR_STRIPLEADING + $STR_STRIPTRAILING)
						   Else
							  $sIcoFail = $aGlobal[i][1]
						   EndIf
						EndIf
					 EndIf
				  Next
			   EndIf
			EndIf
			;MsgBox($MB_SYSTEMMODAL, "Title", $sIcoOk &">"& $iIcoOk, 10)
			for $i = 1 To $aHosts[0][0]
			   if StringLen($aHosts[$i][1])> $iMaxLength Then $iMaxLength = StringLen($aHosts[$i][1])
			Next
			$iTextWidth = $iMaxLength * ($iTextSize-3)
			$guiHeighth = 2*$iBorder + $aHosts[0][0]*$iIcoSize + ($aHosts[0][0]-1)*$iIcoPage
			$guiWidth = 3*$iBorder + $iIcoSize + $iTextWidth
			$iColumn = int($guiHeighth/(@DeskTopHeight-100))+1
			$iRows = round($aHosts[0][0]/$iColumn,0)
			if $iColumn>1 Then
			   $guiHeighth = 2*$iBorder + $iRows*$iIcoSize + ($iRows-1)*$iIcoPage
			   $guiWidth = $iColumn*($iTextWidth + 3*$iBorder + $iIcoSize)
			EndIf
            GUICreate(" AZS Ping v.2.0 - " & @IPAddress1, $guiWidth, $guiHeighth,-1,-1,$WS_SYSMENU+$WS_CAPTION)
			;GUICreate(" AZS Ping v.2.0 " & @IPAddress1, @DesktopWidth, @DesktopHeight,-1,-1,$WS_SYSMENU+$WS_CAPTION)
			if $iColumn>1 Then
			   for $i=1 to $iColumn-1
				  GUICtrlCreateGraphic($iTextWidth*$i+$iIcoSize*$i+3*$iBorder*$i,$iBorder,1,$guiHeighth-2*$iBorder,$SS_BLACKRECT)
			   Next
			EndIf
			$iRow = 0
			$iCurCol = 1
			for $i = 1 To $aHosts[0][0]
			   $iRow = $iRow + 1
			   if $iRow>$iRows Then
				  $iRow = 1
				  $iCurCol = $iCurCol + 1
			   EndIf
			   ;MsgBox($MB_SYSTEMMODAL, "Title", $iColumn &">"& $aHosts[0][0] & " => " & $iRows, 10)
			   GUICtrlCreateLabel($aHosts[$i][1],$iBorder*$iCurCol+($iCurCol-1)*($iTextWidth+2*$iBorder+$iIcoSize),($iRow-1)*($iIcoSize+$iIcoPage)+$iBorder,$iTextWidth,$iIcoSize,$SS_CENTERIMAGE)
			   GUICtrlSetFont(-1, $iTextSize)
			   if Check($aHosts[$i][0],$iTime) Then
				  GUICtrlCreateIcon($sIcoOk, $iIcoOk, $iCurCol*($iTextWidth+$iIcoSize+3*$iBorder)-$iBorder-$iIcoSize, ($iRow-1)*($iIcoSize+$iIcoPage)+$iBorder,$iIcoSize,$iIcoSize)
			   Else
				  GUICtrlCreateIcon($sIcoFail, $iIcoFail, $iCurCol*($iTextWidth+$iIcoSize+3*$iBorder)-$iBorder-$iIcoSize, ($iRow-1)*($iIcoSize+$iIcoPage)+$iBorder,$iIcoSize,$iIcoSize)
			   EndIf
  			   ;GUICtrlCreateGraphic(10,($i-1)*$iIcoSize+($i-1)*$iIcoPage+10,$guiWidth-20,1,$SS_BLACKRECT)
			   ;GUICtrlCreateGraphic(10,$i*$iIcoSize+($i-1)*$iIcoPage+10,$guiWidth-20,1,$SS_BLACKRECT)
			Next
            GUISetState(@SW_SHOW)
			While 1
			   Switch GUIGetMsg()
				  Case $GUI_EVENT_CLOSE
					 ExitLoop
 			   EndSwitch
			WEnd
		    GUIDelete()
		 EndIf
	  EndIf
   EndIf
EndIf

Func Check($sHost,$iTmOut)
   if StringInStr($sHost,":")>0 Then
	  $aTmp = StringSplit($sHost,":")
	  Opt("TCPTimeout", $iTmOut)
	  TCPStartup()
	  $res = TCPConnect($aTmp[1],$aTmp[2])
	  TCPCloseSocket($res)
   Else
	  $res = Ping($sHost,$iTmOut)
   EndIf
   if $res>0 Then
	  Return True
   Else
	  Return False
   EndIf
EndFunc
