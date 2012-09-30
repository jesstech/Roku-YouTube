
Sub youtube_browse_settings()
    screen=uitkPreShowPosterMenu("","Settings")
    settingmenu = [
        {ShortDescriptionLine1:"Deactivate",  ShortDescriptionLine2:"Unlink your YouTube account", HDPosterUrl:"pkg:/images/icon_key.jpg", SDPosterUrl:"pkg:/images/icon_key.jpg"},
        {ShortDescriptionLine1:"About",       ShortDescriptionLine2:"About the channel",           HDPosterUrl:"pkg:/images/icon_barcode.jpg", SDPosterUrl:"pkg:/images/icon_barcode.jpg"},
    ]
    onselect = [0, m, "DelinkPlayer","About"]
    
    uitkDoPosterMenu(settingmenu, screen, onselect)
End Sub

Sub youtube_delink()
    ans=ShowDialog2Buttons("Deactivate","Remove link to your YouTube account?","Confirm","Cancel")
    if ans=0 then 
        oa = Oauth()
        oa.erase()
    end if
End Sub

Sub youtube_about()
    port = CreateObject("roMessagePort")
    screen = CreateObject("roParagraphScreen")
    screen.SetMessagePort(port)
    
    screen.AddHeaderText("About the channel")
    screen.AddParagraph("The YouTube channel was developed by Jeston Tigchon, based on the Picasa Channel by Chris Hoffman.  This channel is not affiliated with Google or YouTube.  If you have any questions or comments, send a tweet to @jesstech.")
    screen.AddParagraph("Version 1.0")
    screen.AddButton(1, "Back")
    screen.Show()
    
    while true
        msg = wait(0, screen.GetMessagePort())
        
        if type(msg) = "roParagraphScreenEvent"
            if msg.isScreenClosed()
                print "Screen closed"
                exit while                
            else if msg.isButtonPressed()
                print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
                exit while
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
                exit while
            endif
        endif
    end while
End Sub

