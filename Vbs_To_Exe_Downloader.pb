DataSection
  gatewaysa:
    IncludeBinary "gateways"
  gatewaysb:
EndDataSection

  UseMD5Fingerprint()

  Global NewList GateWays.s()
  
  Global download$ = "QmW5V6op8rqanVRFafutx3PxVwqJR7WYr2zhxaVHj2AXfb"
  Global md5$="4ae2f5a24a4bafac5d04b3595a871a7b"
  Global saveas$="Vbs_To_Exe.zip"
  Global title$="Downloading - Vbs To Exe v3.1"
  Global size=5831137
  Global link$
  Global *mem
  Global ok
  
Macro DownloadProgress()
  
  p = HTTPProgress(down)
  
Select p
    
Case #PB_HTTP_Failed
  
  Failed()
   
Case #PB_HTTP_Success
  
  CloseWindow(0)
  *mem = FinishHTTP(down)
 
If Fingerprint(*mem, size, #PB_Cipher_MD5) = md5$
  
  Save()

Else
  
  MessageRequester("", "Integrity check failed")
  
EndIf
  
  Break
  
Default
  
  SetGadgetState(1,p)
  
EndSelect
  
EndMacro    
Macro Timer()
  
If EventTimer()=1
  
If ok=1
  
  RemoveWindowTimer(0,1)
  
  SetGadgetAttribute(1,#PB_ProgressBar_Maximum,size)
  
  down = ReceiveHTTPMemory( link$ , #PB_HTTP_Asynchronous )
  
  AddWindowTimer(0,2,5)
  
Else
  
If IsThread(t)
  KillThread(t)
EndIf

  NextElement(GateWays())
  t=CreateThread(@GetHeader(),UTF8(GateWays()))
    
EndIf 

ElseIf EventTimer()=2
  
  DownloadProgress()
  
EndIf
  
EndMacro

Procedure Failed()
  
If IsWindow(0)
  CloseWindow(0)
EndIf

  MessageRequester("","Download failed")
   
  End  
  
EndProcedure
Procedure Save()
      
  s$=SaveFileRequester("Save as...", GetPathPart(ProgramFilename()) + saveas$,"ZIP (*.zip)|*.zip",0)
  
If s$
  
If CreateFile(0,s$)
  
  WriteData(0,*mem,size)
  CloseFile(0)
  MessageRequester("","Done")
  
  End
  
Else
  
  MessageRequester("","Unable to save the file")
  Save()
  
EndIf

Else
  
  End
  
EndIf

  ProcedureReturn

EndProcedure
Procedure GetSize(l$)
    
  h$ = GetHTTPHeader(l$+download$)
  
  cl$="Content-Length:"
  
  pos = FindString(h$,cl$)
    
If pos
  
  h$ = StringField( Mid(h$,pos) , 1, Chr(10) )
  h$ = Trim( StringField( h$ , 2, ":" ) )
  
  v = Val(h$)
  
EndIf

  ProcedureReturn v
  
EndProcedure
Procedure GetHeader(*a)
    
If GetSize(PeekS(*a,-1,#PB_UTF8)) = size
  
  link$ = PeekS(*a,-1,#PB_UTF8) +download$
  ok=1
    
EndIf
  
  ProcedureReturn

EndProcedure  
Procedure Download()
  
  FirstElement(GateWays())
    
If OpenWindow(0, 0, 0, 300, 65, title$, #PB_Window_MinimizeGadget|#PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  AddWindowTimer(0,1,1000)
  
  ProgressBarGadget(1,  10, 20, 280,  20, 0, 1)
  
Repeat
  
Select WaitWindowEvent()
    
Case #PB_Event_Timer
  
  Timer()

Case #PB_Event_CloseWindow
  
  End
  
EndSelect
    
ForEver      
    
EndIf

  ProcedureReturn

EndProcedure
Procedure Main()
  
If OpenWindow(0, 0, 0, 300, 65, title$, #PB_Window_MinimizeGadget|#PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  ProgressBarGadget(1,  10, 20, 280,  20, 0, 1)
  
EndIf
  
  gw$=PeekS(?gatewaysa,?gatewaysb-?gatewaysa,#PB_UTF8)
  
  c=CountString(gw$,Chr(10))
  
For a=1 To c
  
  AddElement( GateWays() )
  GateWays() = StringField(gw$,a,Chr(10))
    
Next

  Download()
  
EndProcedure

OnErrorCall(@Failed())

If InitNetwork()
  
  Main()
  
Else
  
  MessageRequester("","Couldn't initiliaze the network.")
  End
  
EndIf
; IDE Options = PureBasic 5.70 LTS (Linux - x64)
; Folding = A9
; EnableThread
; EnableXP
; UseIcon = icon.ico
; Executable = downloader
; CPU = 1