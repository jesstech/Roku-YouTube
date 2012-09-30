
Sub Init()
    if m.oa = invalid then m.oa = InitOauth("RokyouTube", "toasterdesigns.net", "Y6GQqc19mQ2Q5Ux4PFxMOUPk", "1.0")
    if m.youtube = invalid then m.youtube = InitYouTube()
End Sub

Sub RunUserInterface()
    'initialize theme attributes like titles, logos and overhang color
    initTheme()
    
	' Pop up start of UI for some instant feedback while we load the icon data
	screen=uitkPreShowPosterMenu()
	if screen=invalid then
		print "unexpected error in uitkPreShowPosterMenu"
		return
	end if    
    
    Init()
    oa = Oauth()
    youtube = LoadYouTube()
    
    if doRegistration() <> 0 then
        reason = "unknown"
        if not oa.linked() then reason = "unlinked"
        print "Main: exit due to error in registration, reason: "; reason
        'exit the app gently so that the screen doesn't flash to black
        sleep(25)
        return
    end if
    
    menudata=[
        {ShortDescriptionLine1:"Search",    ShortDescriptionLine2:"Search YouTube for videos",     HDPosterUrl:"pkg:/images/icon_search.jpg", SDPosterUrl:"pkg:/images/icon_search.jpg"},
        {ShortDescriptionLine1:"Featured",  ShortDescriptionLine2:"YouTube-selected videos",       HDPosterUrl:"pkg:/images/icon_user.jpg", SDPosterUrl:"pkg:/images/icon_user.jpg"},
        '{ShortDescriptionLine1:"History",   ShortDescriptionLine2:"Videos you’ve watched",         HDPosterUrl:"pkg:/images/icon_s.jpg", SDPosterUrl:"pkg:/images/icon_s.jpg"},
        {ShortDescriptionLine1:"Favorites", ShortDescriptionLine2:"Browse your YouTube favorites", HDPosterUrl:"pkg:/images/icon_favorites.jpg", SDPosterUrl:"pkg:/images/icon_favorites.jpg"},
        {ShortDescriptionLine1:"Settings",  ShortDescriptionLine2:"Edit channel settings",         HDPosterUrl:"pkg:/images/icon_settings.jpg", SDPosterUrl:"pkg:/images/icon_settings.jpg"},
    ]
    onselect=[0, m.youtube, "SearchYoutube", "BrowseFeatured", "BrowseFavorites", "BrowseSettings"]
    
    uitkDoPosterMenu(menudata, screen, onselect)
    
    sleep(25)
End Sub

'*************************************************************
'** Set the configurable theme attributes for the application
'** 
'** Configure the custom overhang and Logo attributes
'*************************************************************

Sub initTheme()
    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")
    
    theme.OverhangPrimaryLogoOffsetSD_X = "72"
    theme.OverhangPrimaryLogoOffsetSD_Y = "0"
    theme.OverhangSliceSD = "pkg:/images/Overhang_BackgroundSlice_SD.png"
    theme.OverhangPrimaryLogoSD  = "pkg:/images/Logo_Overhang_SD.png"
    
    theme.OverhangPrimaryLogoOffsetHD_X = "123"
    theme.OverhangPrimaryLogoOffsetHD_Y = "0"
    theme.OverhangSliceHD = "pkg:/images/Overhang_BackgroundSlice_HD.png"
    theme.OverhangPrimaryLogoHD  = "pkg:/images/Logo_Overhang_HD.png"
    
    'theme.BackgroundColor = "#999999"
    'theme.ParagraphBodyText = "#FFFFFF"
    'theme.ParagraphHeaderText = "#FFFFFF"
    theme.PosterScreenLine1Text = "#990000"
    theme.PosterScreenLine2Text = "#555555"
    'theme.BreadcrumbTextLeft = "#FFFFFF"
    'theme.BreadcrumbTextRight = "#FFFFFF"
    'theme.BreadcrumbDelimiter = "#FFFFFF"
    theme.RegistrationCodeColor = "#990000"
    'theme.RegistrationFocalColor = "#FFFFFF"
    theme.ParagraphHeaderText = "#990000"
    theme.SpringboardTitleText = "#990000"
    
    app.SetTheme(theme)
End Sub


