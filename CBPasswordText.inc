!Password fix for Paste ... plus use characters other than asterisk
!By Carl Barnes June 2020 - Released under the MIT License on Github.
!-----------------------------------------------------------------
!To Implement inside MAP Embed add  <-- !!! Include inside MAP !!!
!
!   INCLUDE('CbPasswordText.INC'),ONCE  !Change TEXT,SINGLE to a Password control with Paste
!
!   [ ] Change ENTRY,PASSWORD to  TEXT,SINGLE
!   [ ] Add call PasswordOnTextPROP(?Password) after Open(Window) or Event:OpenWindow
!   [ ] Any ?{PROP:Password} changes you must call PasswordOnTextPROP(?, 1=TurnOff / 0=TurnOn= )
!         while opposite of Prop works well for a CHECK('Show Password'),USE(bShowPwd)
!
!-------------------------------------------------
    MODULE('CBPasswordText.CLW')

  !!! <summary>
  !!! Change TEXT,SINGLE control to Password style that hides typed value by displaying asterisks for each character.
  !!! </summary>
  !!! <param name="TextSingleFEQ">FEQ of a TEXT control with the SINGLE attirbute.</param>
  !!! <param name="TurnOffPassword">False (or omit) to add Password style. True to remove Password style and display actual characters typed.</param>
PasswordOnTextPROP   PROCEDURE(LONG TextSingleFEQ, BOOL TurnOffPassword=0)

  !!! <summary>
  !!! Change TEXT,SINGLE control to Password style that hides typed value by displaying Wingding DOTs for each character.
  !!! </summary>
  !!! <param name="TextSingleFEQ">FEQ of a TEXT control with the SINGLE attirbute.</param>
  !!! <param name="TurnOffPassword">False (or omit) to add Password style. True to remove Password style and display actual characters typed.</param>
PasswordOnTextDots   PROCEDURE(LONG TextSingleFEQ, BOOL TurnOffPassword=0)  !Wingding dots instead of asterisks

  !!! <summary>
  !!! Change TEXT,SINGLE control to Password style that hides typed value by displaying Wingding STARs for each character.
  !!! </summary>
  !!! <param name="TextSingleFEQ">FEQ of a TEXT control with the SINGLE attirbute.</param>
  !!! <param name="TurnOffPassword">False (or omit) to add Password style. True to remove Password style and display actual characters typed.</param>
PasswordOnTextStars  PROCEDURE(LONG TextSingleFEQ, BOOL TurnOffPassword=0)  !Wingding Big Asterisk instead of text asterisks

  !!! <summary>
  !!! Call in EVENT:Accepted to clear Clipboard if it contains the password entered.
  !!! </summary>
  !!! <param name="PasswordFEQ">FEQ of a TEXT or ENTRY control of a Password. Omit for ACCEPTED() control.</param>
PasswordAcceptedClipClean PROCEDURE(LONG PasswordFEQ=0) !Clear Clipboard if it contains password

    END

 PRAGMA('compile(CBPasswordText.CLW)')




