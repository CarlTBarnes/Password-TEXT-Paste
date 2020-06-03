    OMIT('**Super Changes END**')

!--- Super Security SSEC::Logon Procedure Changes
!
!   Window Before
          WINDOW('Logon') ... FONT('MS Sans Serif',8)               !Ugly Font
          ENTRY(@S40),AT(77,7,91,10),USE(L::UserName),LEFT,CAP,REQ  !Note CAP n/a for TEXT
          ENTRY(@S8),AT(77,20,91,10),USE(L::Password),UPR,PASSWORD
                                                     !^^^  Note UPR was on Password
!   Window After 
          WINDOW('Logon ') ... FONT('Microsoft Sans Serif',9)       !Better or FONT('Segoe UI',10)
          TEXT,AT(77,7,91,10),USE(L::UserName),SINGLE,REQ
          TEXT,AT(77,20,91,10),USE(L::Password),SINGLE,UPR  
                                                      !^^^  Should also UPPER(L::Password) in Accepted see below
!
  OPEN(Window) 
      PasswordOnTextDots(?L::UserName)     !<--add line
      PasswordOnTextDots(?L::Password) 
!
!  [ ] Find any ?{PROP:PASSWORD and change to call PasswordOnTextDots(?, TurnOFF) so opposite 
       OF ?L::ShowUserName ;  PasswordOnTextDots(?L::UserName, L::ShowUserName)     !e.g. 

!
!  [ ] Remove any Paste Fixing code, this TEXT control works for Paste. Look for ALRT(CtrlV)   

!  [ ] Can clean password off clipboard if in Accepted call
       OF ?L::Password
          PasswordAcceptedClipClean()           !Clear pwd if that's on clipboard
          L::Password=UPPER(LEFT(L::Password))  !SuperSecurity expects passwords in UPPER. LEFT in case Copy grabbed leading spaces
                                                !A Paste was UPPERed by UPR on TEXT in my tests, seems safest to be explicit 
!----------------------

    !end of OMIT('**Super Changes END**')



