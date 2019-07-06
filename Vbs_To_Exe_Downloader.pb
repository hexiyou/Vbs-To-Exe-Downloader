DataSection
  gatewaysa:
    IncludeBinary "gateways"
  gatewaysb:
EndDataSection

  UseMD5Fingerprint()

  Global NewList GateWays.s()
  
  Global download$ = "QmW5V6op8rqanVRFafutx3PxVwqJR7WYr2zhxaVHj2AXfb"
  Global md5$="4ae2f5a24a4bafac5d04b3595a871a7b"
  Global size=5831137
  Global saveas$="Vbs_To_Exe.zip"
  Global *mem
  
Procedure GetSize(link$)
    
  h$ = GetHTTPHeader(link$+download$)
  cl$="Content-Length:"
  
  pos = FindString(h$,cl$)
  
If pos
  
  h$ = StringField( Mid(h$,pos) , 1, Chr(10) )
  h$ = Trim( StringField( h$ , 2, ":" ) )
  
  v = Val(h$)
  
EndIf

  ProcedureReturn v
  
EndProcedure
Procedure Progress(down,v)
  
If OpenWindow(0, 0, 0, 270, 65, "Please wait", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  ProgressBarGadget(1,  10, 20, 250,  20, 0, v)
  
Repeat
  
  we = WindowEvent()
  
If we = #PB_Event_CloseWindow
  
  End
  
EndIf
  
  p = HTTPProgress(down)
  
Select p
    
Case #PB_HTTP_Failed
  
  CloseWindow(0)
  MessageRequester("","Download failed")
   
  End  
   
Case #PB_HTTP_Success
  
  CloseWindow(0)
  
  Break
  
Default
  
  SetGadgetState(1,p)
  
EndSelect
    
ForEver      
    
EndIf

  ProcedureReturn

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
Procedure Main()
  
  gw$=PeekS(?gatewaysa,?gatewaysb-?gatewaysa,#PB_UTF8)
  
  c=CountString(gw$,Chr(10))
  
For a=1 To c
  
  AddElement( GateWays() )
  GateWays() = StringField(gw$,a,Chr(10))
    
Next

ForEach GateWays()
  
If GetSize(GateWays()) = size
  
  down = ReceiveHTTPMemory( GateWays() + download$ , #PB_HTTP_Asynchronous )
  
  Progress(down,size)
  
  *mem = FinishHTTP(down)
  
If Fingerprint(*mem, size, #PB_Cipher_MD5) = md5$
  
  Save()

Else
  
  MessageRequester("", "Integrity check failed")
  
EndIf
  
  Break
  
EndIf
  
Next  
  
  
EndProcedure

If InitNetwork()
  
  Main()
  
Else
  
  MessageRequester("","Couldn't initiliaze the network.")
  End
  
EndIf
; IDE Options = PureBasic 5.70 LTS (Linux - x64)
; Folding = w
; EnableXP
; UseIcon = icon.ico
; Executable = downloader