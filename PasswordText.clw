!Someone at SV must have read an article that said putting passwords on the clipboard was a bad idea.
!They changed the ENTRY,PASSWORD so Paste would NOT work. The Right-Click popup has Paste enabled but it does notnhing.
!So a bad idea and a bad implementation, it confuses users. 
!I guess SV thought with frustraton uses will stop putting passwords on the clipboard.
!I think users learned to tell me paste is broken. I am the developer, I can decide this issue. No other dev tool does this
!
!Simple workaround is to put a Paste button next to Password ENTRY as shown in this example.
!
!This example shows using a TEXT,SINGLE control then using Win API to add the ES_PASSWORD style.
!Paste will work as it does for a C++ or C# or any other Windows programmer on this planet. 
!   Just change ENTRY,PASSWORD to TEXT,SINGLE.
!   Then call SetTextPropPassword(?Pwd) or SetTextPropPasswordDots(?Pwd)
!
!One advantage of TEXT is you can chnage to a Wingdings dot that looks better than the default Asterisks ******
!
!This same techinique allows a Clarion ENTRY to use Wingding Dots. It CANNOT turn On/Off Password on ENTRY. 
!I don't think this is worth doing so I did not build it into my INC file
!
  PROGRAM
  INCLUDE('KEYCODES.CLW')
  INCLUDE('CbWndPreview.INC'),ONCE  !Class Files on GitHub CarlTBarnes. Comment out if you don't have
  
  MAP 
    INCLUDE('CbPasswordText.INC'),ONCE  !<-- MUST be in the MAP
    
Test_PasswordPaste      PROCEDURE() !Try TEXT password and Clarion ENTRY Password
Test_CueBanner_Password PROCEDURE() !Try Text password with Cue Banner
HuntWingdingPossibles   PROCEDURE() !View all possible Wingdings as a replacemet for ***

PasswordEntryAsDots     PROCEDURE(LONG FEQ, BYTE TurnOffPassword=0, BYTE DotType=0)  !Regular ENTRY using Wingding dots instead of Asterisks ***
SetCueBanner            PROCEDURE(LONG TextSingleFEQ, STRING CueBannerText, BOOL OnFocusShows=0)
SetText_GWLStyle_Password  PROCEDURE(LONG TextSingleFEQ, BYTE TurnOffPassword=0)  !Alternative, not needed
ByteHex                   PROCEDURE(BYTE in),STRING

    module('win32')
GetWindowLong   PROCEDURE(LONG hWnd, LONG nIndex ),PASCAL,DLL(1),RAW,LONG,name('GetWindowLongA')
SetWindowLong   PROCEDURE(LONG hWnd, LONG nIndex, LONG NewLong  ),PASCAL,DLL(1),RAW,LONG,PROC,name('SetWindowLongA')
SendMessage     PROCEDURE(LONG hWnd, LONG nMsg, LONG wParam, LONG lParam),LONG,PASCAL,DLL(1),PROC,NAME('SendMessageA')
SendMessageW    PROCEDURE(LONG hWnd, LONG nMsg, LONG wParam, LONG lParam),LONG,PASCAL,DLL(1),PROC!,NAME('SendMessageW')
    END
  END
  
  CODE
  Test_PasswordPaste()

!=================================================================================================== 
!Change a Clarion ENTRY to use a character other than *Asterisk*
!This is overkill, pick one style and code for that like above TextDot
!Why bother doing this when you can use TEXT above and have Paste work???
!If you have implemented your own paste maybe this would likely be the least amount of code chnages.
!---------------------------------------------------- 
PasswordEntryAsDots  PROCEDURE(LONG FEQ, BYTE TurnOff=0, BYTE DotType=0 )  !Wingding dots instead of Asterisks ***
Dot BYTE   !12345678901      [11] put 2 or 3
Fnt STRING('Wingdings {32}')
ped_EM_SETPASSWORDCHAR  EQUATE(0CCh)  !WwParam is Character, if Zero then Turn OFF password.  lParam=0 always
    CODE
    IF TurnOff THEN
       SendMessage(FEQ{PROP:Handle}, ped_EM_SETPASSWORDCHAR,0,0)
       FEQ{PROP:Password}=''
       FEQ{PROP:FontName}=0{PROP:FontName}  !Window Font
       RETURN
    END
    FEQ{PROP:Password}='1'       !MUST be Clarion PASSWORD. Rememeber Paste will not work
    CASE DotType
    OF 1  ; Dot=6Ch                                   !Big DOT
    OF 2  ; Dot=6Eh                                   !Square
    OF 3  ; Dot=74h                                   !Diamond
    OF 4  ; Dot=0DCh     ; Fnt='Wingdings 2'          !Big asterisk
    OF 5  ; Dot=0D7h     ; Fnt[11]='2'                !5 point Star
    OF 6 ; Dot=VAL('*')  ; Fnt=0{PROP:FontName}
    OF 7 ; Dot=VAL('#')  ; Fnt=0{PROP:FontName}
    OF 8 ; Dot=VAL('+')  ; Fnt=0{PROP:FontName}
    OF 99 ; Dot=VAL('*') ; Fnt=0{PROP:FontName}       !99=Back to asterisk in window font
    ELSE  ; Dot=6Ch                                   !Default DOT 
    END
    FEQ{PROP:FontName}=Fnt
    SendMessage(FEQ{PROP:Handle}, ped_EM_SETPASSWORDCHAR, Dot,0)
    HIDE(FEQ) ; UNHIDE(FEQ)  !Repaint
    RETURN 
!=============================================================
!Cue Banner only works with TEXT,SINGLE.  Best to put call in Event:OpenWindow but I think works after Open Window
!e.g. SetCueBanner(?Text1,'Cue Banner Text', 1/0)   ! 1=Show Cue with focus, 0=clear cue on focus 
!You MUST have a MANIFEST !You MUST have a MANIFEST !You MUST have a MANIFEST
!-------------------------------------------------------------
SetCueBanner PROCEDURE(LONG FeqTextSL, STRING CueText, BOOL OnFocusShow=0)
BStrCue  BSTRING 
Cue_WStr LONG,OVER(BStrCue) !BSTRING is Pointer to WSTR
  CODE
  BStrCue=CLIP(CueText)   !BSTRING converts to UniCode.
  SendMessageW(FeqTextSL{PROP:Handle},1501h, OnFocusShow, Cue_WStr)      
  RETURN    !TB_SETCUEBANNER = EQUATE(1501h) !0x1501; //Textbox Integer

!===================================================================================!
!----- Test ----- Test ----- Test ----- Test ----- Test ----- Test ----- Test ----- !
!===================================================================================! 
   
Test_PasswordPaste    PROCEDURE()
bShowName STRING(1)
EntryUser STRING(20)  
EntryPwd  STRING(20)
TextUser  STRING(20)  
TextPwd   STRING(20)
P         BYTE 

Window WINDOW('Login - API TEXT Password versus Clarion ENTRY'),AT(,,307,113),CENTER,GRAY,SYSTEM,ICON(ICON:Paste), |
            FONT('Segoe UI',9)
        STRING('Password as TEXT,SINGLE + ES_Password'),AT(11,4),FONT(,10,,FONT:regular+FONT:underline)
        PROMPT('User Name:'),AT(11,21),USE(?TextUser:Pmt)
        TEXT,AT(51,21,50,11),USE(TextUser),SINGLE
        PROMPT('Password:'),AT(11,39),USE(?TextPwd:Pmt)
        TEXT,AT(51,39,50,11),USE(TextPwd),SINGLE
        PROMPT('Unmasked:'),AT(11,54),USE(?TextPwd:Pmt:2)
        TEXT,AT(51,54,50,11),USE(TextPwd,, ?TextPwd:Unmasked),SKIP,TIP('Password field w/o "ES_Password"'),READONLY,SINGLE
        CHECK('&Show Name'),AT(106,21),USE(bShowName),SKIP
        BUTTON('Login'),AT(25,73,35),USE(?LoginBtn)
        BUTTON('Cancel'),AT(63,73,35),USE(?CancelBtn),STD(STD:Close)
        BUTTON('Cue Banner'),AT(112,73,47,14),USE(?CueBannerBtn),FONT(,8)
        BUTTON('SetClipboard<13,10>to Clock()'),AT(112,39,47,24),USE(?TimeBtn),SKIP,FONT(,8),TIP('Put time on clipboard ' & |
                'to have something to paste')
        BUTTON('<0DCh>'),AT(238,55,14,14),USE(?PwdChar),SKIP,FONT('Wingdings 2'),TIP('Select different character for Pas' & |
                'swordEntryAsDots()')
        BUTTON('Hunt'),AT(255,55,23,14),USE(?HuntWingDingBtn),FONT(,8),TIP('See possible wingding characters')
        PANEL,AT(177,3,1,105),USE(?PANEL1),BEVEL(0,0,6000H)
        STRING('Clarion ENTRY + Password'),AT(193,4),FONT(,10,,FONT:regular+FONT:underline)
        PROMPT('User Name:'),AT(193,22,50,11),USE(?EntryName:Pmt)
        ENTRY(@s20),AT(233,22,50),USE(EntryUser),PASSWORD
        PROMPT('Password:'),AT(193,40,50,11),USE(?EntryPwd:Pmt)
        ENTRY(@s20),AT(233,40,50),USE(EntryPwd),PASSWORD
        BUTTON,AT(287,40,11,11),USE(?PastePwd),SKIP,ICON(ICON:Paste),TIP('Paste Password Button<13,10>A simple workaroun' & |
                'd to broken paste on Password ENTRY'),FLAT
        STRING('Paste will NOT work on ENTRY'),AT(193,83),USE(?PasteFYI:1)
        STRING('Neither Ctrl+V nor Right-Mouse'),AT(193,95),USE(?PasteFYI:2)
        STRING('Paste WILL work on an API Text with Password'),AT(11,95),USE(?PasteFYI:3)
    END
 
    COMPILE('!*** WndPrv D ***',_IFDef_CBWndPreview_)
CbWndPrv CBWndPreviewClass
             !*** WndPrv D ***
    CODE
 !   stop('SetTextPropPassword_HIDE(' & ?EntryPwd)
    OPEN(Window)
    COMPILE('!*** WndPrv I ***',_IFDef_CBWndPreview_)
    CbWndPrv.Init(2)
             !*** WndPrv I ***

    PasswordOnTextPROP(?TextUser)
    PasswordOnTextDots(?TextPwd)
    ! tried ?TextPwd{PROP:Password}=1 did NOT work to set TEXT at runtime on a TEXT ... So RTL does NOT support TEXT Password
    
    !Make Clarion Password Entry look better by changing **** to Wingdings
    PasswordEntryAsDots(?EntryPwd,,4)  !4=Big asterisks
    ?EntryPwd{PROP:Tip}='Uses PasswordEntryAsDots() to have Wingdings instead of plain *** Asterisk ***'

    TextUser='TheDude'; EntryUser='Lebowski'
    TextPwd ='Abides' ; EntryPwd ='Jeffery'
    ACCEPT
        CASE ACCEPTED()
        OF ?TextPwd   !Security Tip - Clear Password on Clipboard after Paste .. here afetr they tab out
                      PasswordAcceptedClipClean(?) 
!                      IF TextPwd=CLIPBOARD() THEN
!                         SETCLIPBOARD('')
!                      END
                      DISPLAY(?TextPwd:Unmasked)

        OF ?bShowName ; ?EntryUser{PROP:Password}=1-bShowName 
                        PasswordOnTextPROP(?TextUser, bShowName) 
                        DISPLAY

        OF ?PastePwd   !Paste Password button ... the Simple way to workaround to RTL preventing Paste
                        EntryPwd=CLIPBOARD() ; SETCLIPBOARD('') ; DISPLAY
        
        OF ?PwdChar   ; P=POPUP('Default|Dot|Square|Diamond|Big Asterisk Star|5 Pt Star|-|Segoe ***|Segoe ###|Segoe +++') 
                        IF P THEN PasswordEntryAsDots(?EntryPwd,,P-1). 
        
        OF ?TimeBtn   ; SETCLIPBOARD(FORMAT(CLOCK(),@t04)&'.'& CLOCK()%100)
        OF ?LoginBtn  ; Message('TextUser<9>=' & TextUser & '|TextPwd<9>=' & TextPwd & |
                                '||EntryUser<9>=' & EntryUser & '|EntryPwd<9>=' & EntryPwd)
        OF ?HuntWingDingBtn ; HuntWingdingPossibles()
        OF ?CueBannerBtn    ; Test_CueBanner_Password()
        END
    END 
  
!===================================================================================! 
   
Test_CueBanner_Password  PROCEDURE()
bShowName STRING(1)
TextUser  STRING(20)  
TextPwd   STRING(20)
P         BYTE 

Window WINDOW('Cue Banner Login with TEXT Password'),AT(,,229,94),GRAY,SYSTEM,ICON(ICON:Paste), |
            FONT('Segoe UI',9)
        STRING('Password as TEXT,SINGLE + ES_Password + Cue Banner'),AT(11,4),FONT(,10,,FONT:regular+FONT:underline)
        PROMPT('Login:'),AT(11,21),USE(?TextUser:Pmt)
        TEXT,AT(47,21,110,11),USE(TextUser),SINGLE
        PROMPT('Password:'),AT(11,39),USE(?TextPwd:Pmt)
        TEXT,AT(47,39,110,11),USE(TextPwd),SINGLE
        CHECK('&Show Name'),AT(169,21),USE(bShowName),SKIP
        BUTTON('Login'),AT(67,60,43),USE(?LoginBtn)
        BUTTON('Cancel'),AT(118,60,43),USE(?CancelBtn),STD(STD:Close)
        STRING('CueBanner uses Control Font so cannot use Wingdings for password Dots'),AT(3,83),USE(?CueBFYI:3)
    END
 
    COMPILE('!*** WndPrv D ***',_IFDef_CBWndPreview_)
CbWndPrv CBWndPreviewClass
             !*** WndPrv D ***
    CODE
    OPEN(Window)
    COMPILE('!*** WndPrv I ***',_IFDef_CBWndPreview_)
    CbWndPrv.Init(2)
             !*** WndPrv I ***

    SetCueBanner(?TextUser,'User Name or Email Address',1)
    SetCueBanner(?TextPwd,'Password or Reset Code'     ,0)             
    PasswordOnTextPROP(?TextUser)
    PasswordOnTextPROP(?TextPwd)   
    !SetTextPropPasswordDots(?TextPwd) !Must NOT change Font or CueBanner uses that font which Wingdings is not readable
    ACCEPT
        CASE ACCEPTED()
        OF ?TextPwd  ; PasswordAcceptedClipClean(?)   
        OF ?bShowName ; PasswordOnTextPROP(?TextUser, bShowName) ;  DISPLAY

        OF ?LoginBtn  ; Message('TextUser<9>=' & TextUser & '|TextPwd<9>=' & TextPwd )
        END
    END 
!=============================================================================
HuntWingdingPossibles PROCEDURE() 
Sample     STRING('12345678 {9}')
SampleLEN         EQUATE(08)       !How many characters to show in Sample
Sam6Ch    STRING('<06Ch>{08}   ')  !Fat Dot
Sam6Eh    STRING('<06Eh>{08}   ')  !Square
Sam74h    STRING('<074h>{08}   ')  !Diamond
SamD7hw2  STRING('<0D7h>{08}   ')  !Asterisk big
SamD8hw2  STRING('<0D8h>{08}   ')  !Asterisk big bold
SamDChw2  STRING('<0DCh>{08}   ')  !6 pt Star
Window WINDOW('Hunt Wingdings'),AT(,,420,400),CENTER,GRAY,SYSTEM,FONT('Segoe UI',9),RESIZE,STATUS
        TEXT,AT(3,2,50,11),USE(Sample),SINGLE,TIP('Sample in Segoe 9 - 5 DLUs wide - Probably should be 100')
        TEXT,AT(3+52*1,2,50,11),USE(Sam6Ch),SINGLE,FONT('Wingdings'),TIP('Wingdings 6Ch Dots')
        TEXT,AT(3+52*2,2,50,11),USE(Sam6Eh),SINGLE,FONT('Wingdings'),TIP('Wingdings 6Eh Squares')
        TEXT,AT(3+52*3,2,50,11),USE(Sam74h),SINGLE,FONT('Wingdings'),TIP('Wingdings 74h Diamonds')
        TEXT,AT(3+52*4,2,50,11),USE(SamDChw2),SINGLE,FONT('Wingdings 2'),TIP('Wingdings 2 DCh')
        TEXT,AT(3+52*5,2,50,11),USE(SamD7hw2),SINGLE,FONT('Wingdings 2'),TIP('Wingdings 2 D7h')
        TEXT,AT(3+52*6,2,50,11),USE(SamD8hw2),SINGLE,FONT('Wingdings 2'),TIP('Wingdings 2 D8h')
    END    
WinWd LONG
Ch LONG
X LONG
Y LONG
W LONG
H LONG
NwFEQ LONG
NwStr &STRING
Fnt STRING(64)
FSz LONG
FCo LONG
FSt LONG
FCs LONG
    CODE
    OPEN(Window) ; DISPLAY
    GETFONT(?Sample,Fnt,FSz,FCo,FSt,FCs)  
    EXECUTE POPUP('Select Font to View...|-|Wingdings|Wingdings 2|Wingdings 3|Webdings|Symbol|Segoe UI',0,0,1)
      BEGIN 
            IF ~FONTDIALOG('Select Font to Test',Fnt,FSz,FCo,FSt,FCs) THEN RETURN.  
            SETFONT(?Sample,Fnt,FSz,FCo,FSt,FCs)
      END
      Fnt='Wingdings  '
      Fnt='Wingdings 2'
      Fnt='Wingdings 3'
      Fnt='Webdings   '
      Fnt='Symbol     '
      Fnt='Segoe UI'
    ELSE ; RETURN
    END
    0{PROP:Text}='Hunt Password Characters in Font "' & CLIP(Fnt) &'" ' & FSz &' - Tooltip shows CHR()'
    HIDE(0)
    GETPOSITION(0,,,WinWd)
    GETPOSITION(?Sample,x,y,w,h)  ; W += 2 ; H += 2 
    Y += H + 2 ; X -= W
    LOOP Ch=20h TO 255 
        X += W 
        IF X+W > WinWd THEN
           X=3
           Y += H
        END
        NwFEQ=CLONE(0,?Sample)
        SETPOSITION(NwFEQ,X,Y)
        NwFEQ{PROP:FontName}=Fnt
        NwStr &= NEW(STRING(12))   !no dispose so leaks
        NwStr=ALL(CHR(Ch),SampleLEN)
        NwFEQ{PROP:Use}=NwStr 
        NwFEQ{PROP:Tip}=ByteHex(Ch) & ' = CHR( ' & Ch & ' ) = "' & CHR(Ch) & '"' 
        UNHIDE(NwFEQ)
    END
!    ?Sample{PROP:Tip}='My Sample in Segoe'
    SETPOSITION(0,,,,Y+H+4)
    UnHIDE(0)
    X=0
    LOOP ; X=0{PROP:NextField,X} ; IF ~X THEN BREAK. 
        X{PROP:Msg}=X{PROP:Tip}   !Tips on my surface show for a microsecond
    END 
    SYSTEM{PROP:TipDisplay}=6000  !Does not work
    SELECT(?Sample,1)
    ACCEPT
    END
!-------------------------    
ByteHex PROCEDURE(BYTE in)
Out  STRING(3),AUTO
HEX  STRING('0123456789ABCDEF')
  CODE
  Out[1] = HEX[BSHIFT(in, -4) + 1]
  Out[2] = HEX[BAND(in, 0FH) + 1]  ; Out[3]='h'
  RETURN Out

!=========================================================== 
!Change can also be made to GWL_Style but takes more code. 
!Code like this can be used for ES_NOHIDESEL to show selected text when control loses focus. Good for spell check.
!
SetText_GWLStyle_Password PROCEDURE(LONG FEQ, BYTE TurnOff=0)  
!                       (LONG TextSingleFEQ, BYTE TurnOffPassword=0)
WLS LONG
Hnd LONG
tp_GWL_STYLE   EQUATE(-16) 
tp_ES_PASSWORD EQUATE(20h)
    CODE
    IF FEQ{PROP:Type}<>CREATE:singleline THEN
       MESSAGE('Bug! SetText_GWLStyle_Password() requires a TEXT,SINGLE control.')
       FEQ{PROP:Password}=CHOOSE(~TurnOff)      !In case ENTRY
       RETURN
    END
    Hnd=FEQ{PROP:Handle}
    WLS=GetWindowLong(Hnd, tp_GWL_STYLE)
    IF ~TurnOff THEN 
        WLS=BOR(WLS,tp_ES_PASSWORD)
    ELSIF TurnOff THEN 
        WLS=BAND(WLS,BXOR(-1,tp_ES_PASSWORD))
    END
    SetWindowLong(Hnd, tp_GWL_STYLE, WLS)
    FEQ{PROP:Right}=1
    FEQ{PROP:Left}=1 !forces RTL to Destroy  and Re-Create control to have new style with Password 
    RETURN
!ES_PASSWORD
!Displays an asterisk (*) for each character typed into the edit control. This style is valid only for single-line edit controls.
!To change the character that is displayed, or set or clear this style, use the EM_SETPASSWORDCHAR message. 
  