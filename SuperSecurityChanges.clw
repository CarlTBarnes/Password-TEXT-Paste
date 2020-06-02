    OMIT('**Super Changes END**')

!--- Super Security SSEC::Logon Procedure Changes
!
!   Window Before
          WINDOW('Logon') ... FONT('MS Sans Serif',8)
          ENTRY(@S40),AT(77,7,91,10),USE(L::UserName),LEFT,CAP,REQ,#ORDINAL(3)
          ENTRY(@S8),AT(77,20,91,10),USE(L::Password),UPR,PASSWORD,#ORDINAL(5)
!   Window After 
          WINDOW('Logon ') ... FONT('Microsoft Sans Serif',9)
          TEXT,AT(77,7,91,10),USE(L::UserName),SINGLE,REQ
          TEXT,AT(77,20,91,10),USE(L::Password),SINGLE  
!
  OPEN(Window) 
      PasswordOnTextDots(?L::UserName)     !<--add line
      PasswordOnTextDots(?L::Password) 
!
!  [ ] Find any ?{PROP:PASSWORD and change to call PasswordOnTextDots(?, TurnOFF) so opposite 
       OF ?L::ShowUserName ;  PasswordOnTextDots(?L::UserName, L::ShowUserName)     !e.g. 

!
!  [ ] Remove any Paste Fixing code, this TEXT control works for Paste   

!  [ ] Can clean password off clipboard if in Accepted call
       OF ?L::Password ;  PasswordAcceptedClipClean()  !06/02/20 CB
!----------------------

    !end of OMIT('**Super Changes END**')



