## Clarion Password Entry Cannot Paste

Someone at SoftVelocity decided pasting into an ENTRY,PASSWORD was a security risk so changed Paste to simply not work?! This confuses users. It makes it hard for the user to use complex passwords. C++, VB, C#, Delphi do not have this restriction. 

One workaround is to `Alert(CtrlV)` and when the key is pressed `CHANGE(?Pwd,ClipBoard())` so paste works. You also need to `Alert(MouseRight)` then `Popup('Paste')` and handle that. A bonus is you can clear the password from the Clipboard as a good security thing. 

The project in this repository shows an easier workaround and some other tricks and tips, plus a better looking password control.

<img src="readme_win.png" width="640"/>

## TEXT Control with Win32 ES_PASSWORD can Paste

The easy way to fix Paste is to use the Windows API. The Clarion TEXT control is the Win32 Edit Control so responds to API calls. Instead of a Clarion ENTRY use a TEXT, it must have the SINGLE line attribute. Send it one message and it becomes a Password Edit control, plus Paste works!
```clarion
!---- Change TEXT,SINGLE to PASSWORD so Paste works ----
PasswordOnTextPROP PROCEDURE(LONG TextFEQ, BYTE TurnOff) 
EM_SETPASSWORDCHAR EQUATE(00CCh)
    CODE
    SendMessage(TextFEQ{PROP:Handle}, EM_SETPASSWORDCHAR, CHOOSE(~TurnOff,VAL('*'),0) , 0)  !Send Zero for Off
    HIDE(TextFEQ) ; UNHIDE(TextFEQ)  !Repaint 
    RETURN
```

- [ ] Add `PasswordOnTextPROP() PROCEDURE` to your APP with `INCLUDE('CBPasswordText.inc'),ONCE` in the MAP
- [ ] Change `ENTRY,PASSWORD` to `TEXT,SINGLE`
- [ ] Call `PasswordOnTextPROP(?Pwd)` to make it a password &ast;&ast;&ast;&ast;&ast; style Edit Control
- [ ] Change any code with `?{PROP:Password}=1/0` to `PasswordOnTextPROP(?,0/1)`

## Password Control Asterisks [&ast;&ast;&ast;&ast;&ast;] are Ugly

The default password control shows all typed characters as Asterisks &ast;&ast;&ast;&ast; which is an ugly and small superscript character. The API allows any character. Change the Font to Wingdings and you can have a big dots  &#9679;&#9679;&#9679;&#9679; or a big asterisks (above capture left/right). The included project shows several characters.

```clarion
PasswordOnTextDots PROCEDURE(LONG FEQ, BYTE TurnOff=0)
PwdChar LONG
EM_SETPASSWORDCHAR EQUATE(00CCh)
    CODE
    PwdChar=CHOOSE(~TurnOff,6Ch,0) !Wingdings 6C is fat dot
    FEQ{PROP:FontName}=CHOOSE(~TurnOff,'Wingdings',0{PROP:FontName}) 
    SendMessage(FEQ{PROP:Handle}, EM_SETPASSWORDCHAR, PwdChar, 0)
    IF FEQ{PROP:Type}=CREATE:Entry THEN
       FEQ{PROP:Password}=TurnOff  !Must use Prop: for ENTRY
    END
    HIDE(TextFEQ) ; UNHIDE(TextFEQ)  !Repaint
    RETURN  
```
    
## Clarion Entry change Password Character

The Clarion ENTRY responds to the EM_SETPASSWORDCHAR message and changes the password character. The API message will NOT correctly turn on/off the password feature, so you must still use the PROP:Password property for something like "Show user name" (as show in the code in the section above). In the example see `PasswordEntryAsDots()`. Paste still will not work, so why bother with this? Change to TEXT. 

## Simplest Workaround - a Paste Button

The simplest workaround to the crippled Entry Password Paste is to add a Paste button next to the ENTRY control. The user may still be confused but at least he can paste. (See the screen shot password right side.)

## Remove Password from Clipboard

One feature of alerting keys and handling paste is the cliboard can be cleared of the password. This can still be done by putting code like below in EVENT:Accepted for the password to check if it matches the clipboard. This delays the clearing until after the user tabs out of the control, but that should not be long. The INC file includes function `PasswordAcceptedClipClean()` to handle this simply.
```clarion
      CASE ACCEPTED()
      OF ?TextPwd  !Clear Password on Clipboard after Paste
                   IF TextPwd=CLIPBOARD() THEN
                      SETCLIPBOARD('')
                   END
```

## TEXT Control can have Cue Banner

If you change the password to a TEXT,SINGLE you can use a Cue Banner as shown below.

<img src="readme_cue.png" width="480"/>

The cue uses the font of the control so the password cannot use Wingding Dots. To set a Cue Banner just requires sending one wide string message as shown below:

```clarion
SetCueBanner PROCEDURE(LONG FeqTextSL, STRING CueText, BOOL OnFocusShow=0)
BStrCue  BSTRING 
Cue_WStr LONG,OVER(BStrCue) !BSTRING is Pointer to WSTR
  CODE
  BStrCue=CLIP(CueText)   !BSTRING converts to UniCode.
  SendMessageW(FeqTextSL{PROP:Handle},1501h, OnFocusShow, Cue_WStr)      
  RETURN    !TB_SETCUEBANNER = EQUATE(1501h)
```

## Wingdings Character Hunter

Click the Hunt button, pick a font and every possible character shows in an Entry to see if it would make a good password character.

<img src="readme_hunt.png" width="800"/>

A poem with a special character ...
   > Little Mary took her skates,  
   > upon the ice to frisk.  
   > Wasn't she a little fool,  
   > her little *


