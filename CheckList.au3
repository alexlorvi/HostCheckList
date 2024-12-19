#include <MsgBoxConstants.au3>
#include <File.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <StringConstants.au3>

$aTmp = _PathSplit(@ScriptFullPath,"", "", "", "")
Global $sINIfile = @ScriptDir & "\" & $aTmp[$PATH_FILENAME] & ".ini"

; Global config parameters
Global $iTextSize = 7
Global $iIcoSize = 32
Global $iIcoPage = 10
Global $iBorder = 10
Global $sIcoOk = "shell32.dll"
Global $iIcoOk = ""
Global $sIcoFail = "shell32.dll"
Global $iIcoFail = ""
Global $iTime = 400
Global $MouseMoveClose=0

If Not FileExists($sINIfile) Then Exit

$aINISections = IniReadSectionNames($sINIfile)

If IsArray($aINISections) Then
  $iHostsSection=_ArraySearch($aINISections,"Hosts")
  If $iHostsSection>0 Then
    $aHosts = IniReadSection($sINIfile,"Hosts")
    If IsArray($aHosts) Then
      ReadGlobalParams($aINISections)
      ; Calculate Max hostName length
      $iMaxLength = 0
      For $i = 1 To $aHosts[0][0]
        If StringLen($aHosts[$i][1])> $iMaxLength Then $iMaxLength = StringLen($aHosts[$i][1])
      Next
      $iTextWidth = $iMaxLength * ($iTextSize-3)
      ; Calculate GUI size and columns count
      $guiHeighth = 2*$iBorder + $aHosts[0][0]*$iIcoSize + ($aHosts[0][0]-1)*$iIcoPage
      $guiWidth = 3*$iBorder + $iIcoSize + $iTextWidth
      $iColumn = int($guiHeighth/(@DeskTopHeight-100))+1
      $iRows = round($aHosts[0][0]/$iColumn,0)
      If $iColumn>1 Then
        $guiHeighth = 2*$iBorder + $iRows*$iIcoSize + ($iRows-1)*$iIcoPage
        $guiWidth = $iColumn*($iTextWidth + 3*$iBorder + $iIcoSize)
      EndIf
      ; Create Form
      GUICreate(" AZS Ping v.2.0 - " & @IPAddress1, $guiWidth, $guiHeighth,-1,-1,$WS_SYSMENU+$WS_CAPTION)
      If $iColumn>1 Then
        For $i=1 To $iColumn-1
          GUICtrlCreateGraphic($iTextWidth*$i+$iIcoSize*$i+3*$iBorder*$i,$iBorder,1,$guiHeighth-2*$iBorder,$SS_BLACKRECT)
        Next
      EndIf
      $iRow = 0
      $iCurCol = 1
      For $i = 1 To $aHosts[0][0]
        $iRow = $iRow + 1
        If $iRow>$iRows Then
          $iRow = 1
          $iCurCol = $iCurCol + 1
        EndIf
        $iLeft = $iBorder*$iCurCol+($iCurCol-1)*($iTextWidth+2*$iBorder+$iIcoSize)
        $iTop = ($iRow-1)*($iIcoSize+$iIcoPage)+$iBorder
        GUICtrlCreateLabel($aHosts[$i][1], $iLeft, $iTop, $iTextWidth, $iIcoSize, $SS_CENTERIMAGE)
        GUICtrlSetFont(-1, $iTextSize)
        $iLeftCheck = $iCurCol*($iTextWidth+$iIcoSize+3*$iBorder)-$iBorder-$iIcoSize
        If Check($aHosts[$i][0],$iTime) Then
          GUICtrlCreateIcon($sIcoOk, $iIcoOk, $iLeftCheck, $iTop, $iIcoSize, $iIcoSize)
        Else
          GUICtrlCreateIcon($sIcoFail, $iIcoFail, $iLeftCheck, $iTop, $iIcoSize, $iIcoSize)
        EndIf
      Next
      GUISetState(@SW_SHOW)
      ; Run cycle until close
      While 1
        Switch GUIGetMsg()
          Case $GUI_EVENT_CLOSE
            ExitLoop
          Case $GUI_EVENT_MOUSEMOVE
            If $MouseMoveClose=1 Then ExitLoop
        EndSwitch
      WEnd
      GUIDelete()
    EndIf
  EndIf
EndIf

; --------------------------------------

Func ReadGlobalParams($aINISections)
  $iGlobalSection = _ArraySearch($aINISections,"Global")
  If $iGlobalSection>0 Then
    $aGlobal = IniReadSection($sINIfile,"Global")
  If IsArray($aGlobal) Then
    For $i = 1 To $aGlobal[0][0]
      Switch StringLower($aGlobal[$i][0])
        Case StringLower("IconSize")
          $iIcoSize = Int($aGlobal[$i][1])
        Case StringLower("IconPage")
          $iIcoPage = Int($aGlobal[$i][1])
        Case StringLower("Border") 
          $iBorder = Int($aGlobal[$i][1])
        Case StringLower("TextSize") 
          $iTextSize = Int($aGlobal[$i][1])
        Case StringLower("Timeout") 
          $iTime = Int($aGlobal[$i][1])
        Case StringLower("MouseMoveClose")
          $MouseMoveClose = Int($aGlobal[$i][1])
        Case StringLower("IconOk")
          If IsString($aGlobal[$i][1]) Then
            If StringInStr($aGlobal[$i][1],",")>0 Then
              $aTmp = StringSplit($aGlobal[$i][1],",")
              $sIcoOk = StringStripWS($aTmp[1],$STR_STRIPLEADING + $STR_STRIPTRAILING)
              $iIcoOk = StringStripWS($aTmp[2],$STR_STRIPLEADING + $STR_STRIPTRAILING)
            Else
              $sIcoOk = $aGlobal[i][1]
            EndIf
          EndIf
        Case StringLower("IconFail")
          If IsString($aGlobal[$i][1]) Then
            If StringInStr($aGlobal[$i][1],",")>0 Then
              $aTmp = StringSplit($aGlobal[$i][1],",")
              $sIcoFail = StringStripWS($aTmp[1],$STR_STRIPLEADING + $STR_STRIPTRAILING)
              $iIcoFail = StringStripWS($aTmp[2],$STR_STRIPLEADING + $STR_STRIPTRAILING)
            Else
              $sIcoFail = $aGlobal[i][1]
            EndIf
          EndIf
        EndSwitch
      Next
    EndIf
  EndIf
EndFunc

Func Check($sHost,$iTmOut)
  If StringInStr($sHost,":")>0 Then
    $aTmp = StringSplit($sHost,":")
    Opt("TCPTimeout", $iTmOut)
    TCPStartup()
    $res = TCPConnect($aTmp[1],$aTmp[2])
    TCPCloseSocket($res)
  Else
    $res = Ping($sHost,$iTmOut)
  EndIf
  If $res>0 Then
    Return True
  Else
    Return False
  EndIf
EndFunc
