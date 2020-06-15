  MEMBER
  MAP
    module('win32')
GetWindowLongA   PROCEDURE(LONG hWnd, LONG nIndex ),PASCAL,DLL(1),RAW,LONG
SetWindowLongA   PROCEDURE(LONG hWnd, LONG nIndex, LONG NewLong  ),PASCAL,DLL(1),RAW,LONG,PROC
SendMessageA     PROCEDURE(LONG hWnd, LONG nMsg, LONG wParam, LONG lParam),LONG,PASCAL,DLL(1),PROC
SendMessageW    PROCEDURE(LONG hWnd, LONG nMsg, LONG wParam, LONG lParam),LONG,PASCAL,DLL(1),PROC
    END
PasswordOnTextFontChar PROCEDURE(LONG FEQ, BOOL TurnOff, STRING FontName, BYTE Ch),PRIVATE
IsTextSingle           PROCEDURE(LONG FEQ, BOOL TurnOff),BOOL,PRIVATE
    INCLUDE('CBPasswordText.INC'),ONCE
  END
cbEM_SetPasswordChar  EQUATE(0CCh)  !WwParam is Character, if Zero then Turn OFF password.  lParam=0 always
!===========================================================
PasswordOnText_SetGwlStyle PROCEDURE(LONG FEQ, BYTE TurnOff=0)
!This works to get the Black Dot for Password on the Clarion ANSI Edit Control if there is a Manifest.
WLS LONG
Hnd LONG
tp_GWL_STYLE   EQUATE(-16) 
tp_ES_PASSWORD EQUATE(20h) 
tp_ES_RIGHT    EQUATE(2) 
ErrWnd WINDOW('PasswordSetWithGwlStyle Bug'),AT(,,280,40),CENTER,GRAY,SYSTEM
        STRING('Bug! PasswordSetWithGwlStyle() requires a TEXT,SINGLE control.'),AT(1,15,280), |
                USE(?StrErr1),CENTER
    END
    CODE
    IF FEQ{PROP:Type}<>CREATE:singleline THEN
       DISPLAY ; OPEN(ErrWnd) ; ACCEPT ; END ; CLOSE(ErrWnd)  !Message would not show w/o DISPLAY ... odd?  
       FEQ{PROP:Password}=CHOOSE(~TurnOff)      !In case ENTRY
       RETURN
    END
    Hnd=FEQ{PROP:Handle}
    WLS=GetWindowLongA(Hnd, tp_GWL_STYLE)
    IF ~TurnOff THEN 
        WLS=BOR(WLS,tp_ES_PASSWORD)
    ELSIF TurnOff THEN 
        WLS=BAND(WLS,BXOR(-1,tp_ES_PASSWORD))
    END
    WLS=BOR(WLS,tp_ES_RIGHT)                !Right align with API so PROP:Right below not needed
    SetWindowLongA(Hnd, tp_GWL_STYLE, WLS)  !Password Style change on existing control will NOT happen
!    FEQ{PROP:Right}=1                      !Alignment change forces RTL to Destroy and Create Control
    FEQ{PROP:Left}=1                        !RTL will retain my GwlStyle. I want it LEFT not RIGHT.
    RETURN

!=============================================================
!Cue Banner only works with TEXT,SINGLE.  
!e.g. TextSetCueBanner(?Text1,'Cue Banner Text', 1/0)   ! 1=Show Cue with focus, 0=clear cue on focus 
!You MUST have a MANIFEST !You MUST have a MANIFEST !You MUST have a MANIFEST
!Yu MUST call this after PasswordOnText_SetGwlStyle() 
!-------------------------------------------------------------
CueBanner_SetForText PROCEDURE(LONG FeqTextSL, STRING CueText, BOOL OnFocusShow=0)
BStrCue  BSTRING 
Cue_WStr LONG,OVER(BStrCue) !BSTRING is Pointer to WSTR
  CODE
  BStrCue=CLIP(CueText)   !BSTRING converts to UniCode.
  SendMessageW(FeqTextSL{PROP:Handle},1501h, OnFocusShow, Cue_WStr)      
  RETURN    !TB_SETCUEBANNER = EQUATE(1501h) !0x1501; //Textbox Integer

!===========================================================
PasswordOnTextProp PROCEDURE(LONG FEQ, BOOL TurnOff)
    CODE
    IF ~IsTextSingle(FEQ,TurnOff) THEN RETURN.
    SendMessageA(FEQ{PROP:Handle}, cbEM_SETPASSWORDCHAR, CHOOSE(~TurnOff,VAL('*'),0) , 0)
    HIDE(FEQ) ; UNHIDE(FEQ)  !Repaint (could InvalidateRect)
    RETURN
    !Clarion has ANSI Edit Control so you CANNOT SendMessageW 25CFh the Unicode Circle
!------------------------
PasswordOnTextDots PROCEDURE(LONG FEQ, BOOL TurnOff=0)
Ch LONG
    CODE
    PasswordOnTextFontChar(FEQ,TurnOff,'Wingdings',6Ch) !Fat Dot, 6Eh is square
!------------------------
PasswordOnTextStars  PROCEDURE(LONG FEQ, BOOL TurnOff=0)  !Wingding Big Asterisk instead of text asterisks
    CODE
    PasswordOnTextFontChar(FEQ,TurnOff,'Wingdings 2',0DCh)
!------------------------
PasswordOnTextFontChar PROCEDURE(LONG FEQ, BOOL TurnOff, STRING FontName, BYTE Ch) !Private
    CODE
    IF ~IsTextSingle(FEQ,TurnOff) THEN RETURN.
    Ch=CHOOSE(~TurnOff,Ch,0)
    FEQ{PROP:FontName}=CHOOSE(~TurnOff,FontName,0{PROP:FontName})
    SendMessageA(FEQ{PROP:Handle}, cbEM_SETPASSWORDCHAR, Ch, 0)
    HIDE(FEQ) ; UNHIDE(FEQ)
    RETURN
!------------------------
IsTextSingle PROCEDURE(LONG FEQ, BOOL TurnOff)!,BOOL Private
    CODE
    DISPLAY
    IF FEQ{PROP:Type}=CREATE:singleline THEN RETURN True.
    DISPLAY
    MESSAGE('Bug!||CBPasswordText requires a TEXT,SINGLE control. ' & FEQ,'CBPasswordText.CLW')
    FEQ{PROP:Password}=CHOOSE(~TurnOff)      !In case ENTRY make Password work
    RETURN False
!------------------------
PasswordAcceptedClipClean PROCEDURE(LONG FEQ=0) !Clear Clipboard if it contains password
    CODE
    IF FEQ=0 THEN FEQ=ACCEPTED().
    IF UPPER(CONTENTS(FEQ))=UPPER(CLIPBOARD()) THEN
       SETCLIPBOARD('')
    END
    RETURN