  MEMBER
  MAP
    module('win32')
SendMessageA PROCEDURE(LONG hWnd, LONG nMsg, LONG wParam, LONG lParam),LONG,PASCAL,DLL(1),PROC
    END
PasswordOnTextFontChar PROCEDURE(LONG FEQ, BOOL TurnOff, STRING FontName, BYTE Ch),PRIVATE
IsTextSingle           PROCEDURE(LONG FEQ, BOOL TurnOff),BOOL,PRIVATE
    INCLUDE('CBPasswordText.INC'),ONCE
  END
cbEM_SETPASSWORDCHAR  EQUATE(0CCh)  !WwParam is Character, if Zero then Turn OFF password.  lParam=0 always
!===========================================================
PasswordOnTextProp PROCEDURE(LONG FEQ, BOOL TurnOff)
    CODE
    IF ~IsTextSingle(FEQ,TurnOff) THEN RETURN.
    SendMessageA(FEQ{PROP:Handle}, cbEM_SETPASSWORDCHAR, CHOOSE(~TurnOff,VAL('*'),0) , 0)
    HIDE(FEQ) ; UNHIDE(FEQ)  !Repaint (could InvalidateRect)
    RETURN
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
    IF CONTENTS(FEQ)=CLIPBOARD() THEN
       SETCLIPBOARD('')
    END
    RETURN