    PROGRAM
!09/29/25 verified 11.1.13815 can paste with Control+V and Right-Click     
!09/29/25 verified 12.0.13941 can paste with Control+V and Right-Click     
    MAP
MainTest  PROCEDURE()
    END
    CODE
    MainTest()
    RETURN
!----------------------------
MainTest    PROCEDURE
Password1   STRING(32)
Entry1      STRING(32)
Window WINDOW('RTL Can Paste Password?'),AT(,,218,81),CENTER,GRAY,IMM,SYSTEM,FONT('Segoe UI',9)
        PROMPT('Password1'),AT(9,12),USE(?PROMPT1)
        ENTRY(@s32),AT(46,11),USE(Password1),PASSWORD
        PROMPT('Entry1'),AT(23,32),USE(?PROMPT2)
        ENTRY(@s32),AT(46,31),USE(Entry1)
        BUTTON,AT(183,30,13,12),USE(?CopyBtn),ICON(ICON:Copy),TIP('Copy Entry1'),FLAT
        BUTTON('Show Password1'),AT(76,55),USE(?ShowPwd)
    END
    CODE
    Entry1=format(today(),@d12) &' @ '& format(clock(),@t06)
    OPEN(WINDOW)
    0{PROP:text}=clip(0{PROP:text}) &' - Library ' & system{PROP:LibVersion,2} &'.'& system{PROP:LibVersion,3}
    ACCEPT
        CASE ACCEPTED()
        OF ?ShowPwd ; MESSAGE('Password1='& Password1 ) 
        OF ?CopyBtn ; SetClipboard(Entry1)
        END
    END
    CLOSE(WINDOW)
