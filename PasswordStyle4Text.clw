! Password Entry using TEXT with a Manifest for Visual Styles
!------------------------------------------------------------------------------
!04/09/21
!   Added a "Eye Peek" Icon (Webdings N) next to the password field.
!   The EYE has a REGION over it so when the user hovers the Mouse over
!   the EYE the Password displays.
!
!06/11/20 
! 
! >>> If you have a Manifest for Visual Styles then THIS IS THE CODE YOU WANT to use. <<<
!
! First example PasswordText.CLW was using SendMessageA(FEQ{PROP:Handle}, cbEM_SETPASSWORDCHAR, Ch, 0) 
! because it was very small code, BUT that has a limitation that it can only do Dots by changing to 
! Wingdings font and that breaks Cue. Without a Manufest the prior code is the way to get Dots not Asterisks.
!
! If SetWindowLong() on GWLStyle is used to add ES_Password style (call PasswordOnText_SetGwlStyle())
!    and you have a Manifest for Visual Styles you get Dots without having to change to Wingdings
!    and you still can have Cue Banner
!    and Paste works
!

!This example shows using a TEXT,SINGLE control then using Win API SetWindowLong() to add the ES_PASSWORD style.
!Paste will work as it does for a C++ or C# or any other Windows programmer on this planet. 
!   Just change ENTRY,PASSWORD to TEXT,SINGLE.
!   Then call SetText_GWLStyle_Password(?Pwd), call (?,1) to turn off password.

  PROGRAM
  INCLUDE('KEYCODES.CLW')
  
  MAP 
    INCLUDE('CbPasswordText.INC'),ONCE  !<-- MUST be in the MAP
Test_CueBanner_Password  PROCEDURE()                        !TEXT,SINGLE plus GwlStyle Change can Paste
Test_ENTRY_Password      PROCEDURE(STRING XPo, STRING YPo)  !Standard Clarion ENTRY with Password has NO Paste

  END
  
  CODE
  !IF START(Test_ENTRY_Password). 
  Test_CueBanner_Password()
!=======================================================
Test_CueBanner_Password  PROCEDURE()
bShowName STRING(1)
TextUser  STRING(20)  
TextPwd   STRING(20)
P         BYTE 
PeekFEQ LONG   !Clone Password TEXT CREATE()'d to show the Password

Window WINDOW('Text Password Paste+Dots+Cue w/ Manifest & GWLStyle'),AT(,,270,105),GRAY,SYSTEM, |
            ICON(ICON:Paste),FONT('Segoe UI',9),CENTER
        STRING('Password as TEXT,SINGLE + ES_Password + Cue Banner + Manifest'),AT(11,4), |
                FONT(,10,,FONT:regular+FONT:underline)
        PROMPT('Login:'),AT(11,21),USE(?TextUser:Pmt)
        TEXT,AT(47,21,129,11),USE(TextUser),SINGLE
        PROMPT('Password:'),AT(11,39),USE(?TextPwd:Pmt)
        TEXT,AT(47,39,129,11),USE(TextPwd),SINGLE
        STRING('N'),AT(184,39),USE(?EyePeekPwd:String),FONT('Webdings',16)
        REGION,AT(183,38,14,14),USE(?EyePeekPwd:REGION),IMM
        CHECK('&Show Name'),AT(185,21),USE(bShowName),SKIP
        BUTTON('Login'),AT(46,60,43),USE(?LoginBtn)
        BUTTON('Cancel'),AT(98,60,43),USE(?CancelBtn),STD(STD:Close)
        BUTTON('ENTRY Test'),AT(185,60),USE(?EntryBtn),TIP('Open Window with ENTRY,PASSWORD')
        STRING('Password DOTS if SetWindowLong(,GWLStyle=ES_Password) and Manifest.'),AT(3,83), |
                USE(?CueBFYI:3)
        STRING('CueBanner works with Dots this way. Paste works.'),AT(3,93),USE(?CueBFYI:4)
    END

    CODE
    OPEN(Window)

    PasswordOnText_SetGwlStyle( ?TextUser    )  ! PasswordOnTextPROP(?TextUser) <-- change to ** Asterisk **
    PasswordOnText_SetGwlStyle( ?TextPwd     )  ! PasswordOnTextPROP(?TextPwd)   

    !MUST do above ES_Password FIRST, then Cue Banner or Style change destroys Cue
    CueBanner_SetForText(?TextUser,'User Name or Email Address',1)
    CueBanner_SetForText(?TextPwd,'Password or Reset Code'     ,0) 

    ACCEPT
        CASE ACCEPTED()
        OF ?TextPwd   ; PasswordAcceptedClipClean(?)   
        OF ?bShowName ; PasswordOnText_SetGwlStyle( ?TextUser, bShowName ) ; DISPLAY
        OF ?LoginBtn  ; Message('TextUser<9>=' & TextUser & '|TextPwd<9>=' & TextPwd )
        OF ?EntryBtn  ; START(Test_ENTRY_Password,,0{PROP:XPos},0{PROP:YPos}+0{PROP:Height}+20)
        END
        CASE FIELD()
        OF ?EyePeekPwd:REGION
           
           !This creates a CLONE of the Password control w/o the Password attribute
           !It seems kind of complicated but works and does not change cursor position in the Entry
           !I have this in my live code and its working 
           CASE EVENT()
           OF EVENT:MouseIn   
                PeekFEQ=CLONE(0,?TextPwd)    !Create a copy of our TEXT, it will have USE() variable
                PeekFEQ{PROP:Skip}=1         !Don't let it take focus
                PasswordOnText_SetGwlStyle(PeekFEQ, 1 )  !Remove Password ****
                UNHIDE(PeekFEQ)              !Make it visible, it should be on top on real Pwd
                !HIDE(?TextPwd)              !not needed, PeekFEQ TEXT is on top of password
           OF EVENT:MouseOut 
                HIDE(PeekFEQ) 
                DESTROY(PeekFEQ) 
                !UNHIDE(?TextPwd)            !not needed 
           END 

    OMIT('**END**')
           !With this method if the user has not tabbed out of the Control 
           !on Mouse Out the control takes focus and has all text selected. 
           !Possibly confusing but the code is simpler
           CASE EVENT()
           OF EVENT:MouseIn  ; PasswordOnText_SetGwlStyle( ?TextPwd, 1 )
           OF EVENT:MouseOut ; PasswordOnText_SetGwlStyle( ?TextPwd, 0 )
           END
    !end of OMIT('**END**')

        END 
    END 


!=======================================================
Test_ENTRY_Password  PROCEDURE(STRING XPo, STRING YPo)
bShowName STRING(1)
LoginUser  STRING(20)  
LoginPwd   STRING(20)
P         BYTE 

Window WINDOW('ENTRY + Password Dots with Manifest'),AT(,,229,110),GRAY,SYSTEM,ICON(ICON:Paste), |
            FONT('Segoe UI',9)
        STRING('ENTRY with Password has broken Paste in RTL'),AT(11,4),FONT(,10,, |
                FONT:regular+FONT:underline)
        PROMPT('Login:'),AT(11,21),USE(?LoginUser:Pmt)
        ENTRY(@s20),AT(47,21,110,11),USE(LoginUser),PASSWORD
        PROMPT('Password:'),AT(11,39),USE(?LoginPwd:Pmt)
        ENTRY(@s20),AT(47,39,110,11),USE(LoginPwd),PASSWORD
        CHECK('&Show Name'),AT(169,21),USE(bShowName),SKIP
        BUTTON('Login'),AT(67,60,43),USE(?LoginBtn)
        BUTTON('Cancel'),AT(118,60,43),USE(?CancelBtn),STD(STD:Close)
        STRING('CueBanner does NOT work on ENTRY'),AT(3,83), USE(?CueBFYI:3)
        STRING('With Manifest ENTRY+PASSWORD shows Dots'),AT(3,93), USE(?CueBFYI:4)
    END
 
    CODE
    OPEN(Window)
    SETPOSITION(0,XPo,YPo)
    ACCEPT
        CASE ACCEPTED()
        OF ?LoginPwd   ; PasswordAcceptedClipClean(?)   
        OF ?bShowName ; ?LoginUser{PROP:Password}=bShowName-1 ;  DISPLAY

        OF ?LoginBtn  ; Message('LoginUser<9>=' & LoginUser & '|LoginPwd<9>=' & LoginPwd )
        END
    END 


