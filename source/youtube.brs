
Function LoadYouTube() As Object
    ' global singleton
    return m.youtube
End Function

Function InitYouTube() As Object
    ' constructor
    this = CreateObject("roAssociativeArray")
    this.oauth_prefix = "https://www.google.com/accounts"
    this.link_prefix = "http://roku.toasterdesigns.net"
    this.protocol = "http"
    this.scope = this.protocol + "://gdata.youtube.com"
    this.prefix = this.scope + "/feeds/api"
    REM this.FieldsToInclude = "&fields=entry(title,author,link,gd:rating,media:group(media:category,media:description,media:thumbnail,yt:videoid))"
    
    this.CurrentPageTitle = ""

    'API Calls
    this.ExecServerAPI = youtube_exec_api
    
    'Search
    this.SearchYouTube = youtube_search

    'History
    this.BrowseHistory = youtube_history

    'Featured
    this.BrowseFeatured = youtube_featured

    'Favorites
    this.BrowseFavorites = youtube_browse_favorites

    'Videos
    this.DisplayVideoList = youtube_display_video_list
    this.FetchVideoList = youtube_fetch_video_list
    this.VideoDetails = youtube_display_video_springboard
    this.newVideoListFromXML = youtube_new_video_list
    this.newVideoFromXML = youtube_new_video

    'Settings
    this.BrowseSettings = youtube_browse_settings
    this.DelinkPlayer = youtube_delink
    this.About = youtube_about 
    
    print "YouTube: init complete"
    return this
End Function


Function youtube_exec_api(url_stub="" As String, username="default" As Dynamic)
    oa = Oauth()
    
    if username=invalid then
        username=""
    else
        username="users/"+username+"/"
    end if

    version = "2"

    if Instr(0, url_stub, "http://") then
        http = NewHttp(url_stub)
    else
        http = NewHttp(m.prefix + "/" + username + url_stub)
    end if


    oa.sign(http,true)
    http.AddParam("v", version)

    REM print "----------------------------------"
    REM print http
    xml=http.getToStringWithTimeout(10)
    REM print "----------------------------------"
    REM print xml
    REM print "----------------------------------"
    rsp=ParseXML(xml)
    if rsp=invalid then
        ShowErrorDialog("API return invalid. Try again later","Bad response")
    end if
    
    return rsp
End Function




















REM ********************************************************************
REM ********************************************************************
REM ***** YouTube
REM ***** Search
REM ********************************************************************
REM ********************************************************************
Sub youtube_search()
    port=CreateObject("roMessagePort") 
    screen=CreateObject("roSearchScreen")
    screen.SetMessagePort(port)
    
    history=CreateObject("roSearchHistory")
    screen.SetSearchTerms(history.GetAsArray())
    
    screen.Show()
    
    while true
        msg = wait(0, port)
        
        if type(msg) = "roSearchScreenEvent" then
            print "Event: "; msg.GetType(); " msg: "; msg.GetMessage()
            if msg.isScreenClosed() then
                return
            else if msg.isFullResult()
                keyword=msg.GetMessage()
                dialog=ShowPleaseWait("Please wait","Searching YouTube for "+Quote()+keyword+Quote())
                rsp=m.ExecServerAPI("videos?q="+keyword,invalid)
                if not isxmlelement(rsp) then dialog.Close():ShowConnectionFailed():return
                videos=m.newVideoListFromXML(rsp.entry)
                if videos.Count() > 0 then
                    history.Push(keyword)
                    screen.AddSearchTerm(keyword)
                    dialog.Close()
                    m.DisplayVideoList(videos, "Search", rsp.link, invalid)
                else
                    dialog.Close():ShowErrorDialog("No videos match your search","Search results")
                end if
            else if msg.isCleared() then
                history.Clear()
            end if
        end if
    end while
End Sub


REM ********************************************************************
REM ********************************************************************
REM ***** YouTube
REM ***** Favorites
REM ********************************************************************
REM ********************************************************************
Sub youtube_browse_favorites()
    m.FetchVideoList("favorites", "Favorites", "default")
End Sub


REM ********************************************************************
REM ********************************************************************
REM ***** YouTube
REM ***** History
REM ********************************************************************
REM ********************************************************************
Sub youtube_history()
    
End Sub


REM ********************************************************************
REM ********************************************************************
REM ***** YouTube
REM ***** Featured
REM ********************************************************************
REM ********************************************************************
Sub youtube_featured()
    m.FetchVideoList("standardfeeds/recently_featured", "Featured", invalid)
End Sub


REM ********************************************************************
REM ********************************************************************
REM ***** YouTube
REM ***** Poster/Video List Utils
REM ********************************************************************
REM ********************************************************************
Sub youtube_fetch_video_list(APIRequest As String, title As String, username As Dynamic)
    
    REM fields = m.FieldsToInclude
    REM if Instr(0, APIRequest, "?") = 0 then
    REM     fields = "?"+Mid(fields, 2)
    REM end if

    screen=uitkPreShowPosterMenu(title,"Videos")
    screen.showMessage("Loading...")

    rsp=m.ExecServerAPI(APIRequest, username)
    if not isxmlelement(rsp) then ShowConnectionFailed():return
    
    videos=m.newVideoListFromXML(rsp.entry)
    m.DisplayVideoList(videos, title, rsp.link, screen)

End Sub


Sub youtube_display_video_list(videos As Object, title As String, links=invalid, screen=invalid)
    if screen=invalid then
        screen=uitkPreShowPosterMenu(title,"Videos")
        screen.showMessage("Loading...")
    end if
    m.CurrentPageTitle = title

    if videos.Count() > 0 then
        metadata=GetVideoMetaData(videos)

        for each link in links
            if link@rel = "next" then 
                metadata.Push({shortDescriptionLine1: "More Results", action: "next", pageURL: link@href, HDPosterUrl:"pkg:/images/icon_next.jpg", SDPosterUrl:"pkg:/images/icon_next.jpg"})
            else if link@rel = "previous" then 
                metadata.Unshift({shortDescriptionLine1: "Back", action: "prev", pageURL: link@href, HDPosterUrl:"pkg:/images/icon_prev.jpg", SDPosterUrl:"pkg:/images/icon_prev.jpg"})
            end if
        end for
        
        onselect = [1, metadata, m, 
            function(video, youtube, set_idx)
                if video[set_idx]["action"]<>invalid then 
                    youtube.FetchVideoList(video[set_idx]["pageURL"], youtube.CurrentPageTitle, invalid)
                else
                    youtube.VideoDetails(video[set_idx])
                end if
            end function]
        uitkDoPosterMenu(metadata, screen, onselect)
    else
        uitkDoMessage("No videos found.", screen)
    end if
End Sub


REM ********************************************************************
REM ********************************************************************
REM ***** YouTube
REM ***** working with metadata for the poster/springboard screens
REM ********************************************************************
REM ********************************************************************
Function youtube_new_video_list(xmllist As Object) As Object
    print "youtube_new_video_list init"
    videolist=CreateObject("roList")
    for each record in xmllist
        video=m.newVideoFromXML(record)
        videolist.Push(video)
    next
    return videolist
End Function


Function youtube_new_video(xml As Object) As Object
    video = CreateObject("roAssociativeArray")
    video.youtube=m
    video.xml=xml
    video.GetID=function():return m.xml.GetNamedElements("media:group")[0].GetNamedElements("yt:videoid")[0].GetText():end function
    video.GetAuthor=function():return m.xml.GetNamedElements("media:group")[0].GetNamedElements("media:credit").GetText():end function
    video.GetTitle=function():return m.xml.title[0].GetText():end function
    video.GetCategory=function():return m.xml.GetNamedElements("media:group")[0].GetNamedElements("media:category")[0].GetText():end function
    video.GetDesc=function():return Left(m.xml.GetNamedElements("media:group")[0].GetNamedElements("media:description")[0].GetText(), 500):end function
    video.GetRating=get_Rating
    video.GetThumb=get_thumb
    'video.GetURL=video_get_url
    return video
End Function


Function GetVideoMetaData(videos As Object)
    metadata=[]
        
    for each video in videos
        meta=CreateObject("roAssociativeArray")
        meta.ContentType="movie"
        meta.ID=video.GetID()

        meta.Title=video.GetTitle()
        meta.Actors=video.GetAuthor()
        meta.Description=video.GetDesc()
        meta.Categories=video.GetCategory()
        meta.StarRating = video.GetRating()
        meta.ShortDescriptionLine1=meta.Title
        meta.SDPosterUrl=video.GetThumb()
        meta.HDPosterUrl=video.GetThumb()

        meta.StreamFormat="mp4"
        meta.Streams=[]
        'meta.StreamBitrates=[]
        'meta.StreamQualities=[]
        'meta.StreamUrls=[]
        
        metadata.Push(meta)
    end for
    
    return metadata
End Function

Function get_rating()
    if m.xml.GetNamedElements("gd:rating").Count()>0 then
        return m.xml.GetNamedElements("gd:rating").GetAttributes()["average"].toInt()*20
    end if

    return invalid
End Function

Function get_thumb()
    if m.xml.GetNamedElements("media:group")[0].GetNamedElements("media:thumbnail").Count()>0 then
        return m.xml.GetNamedElements("media:group")[0].GetNamedElements("media:thumbnail")[0].GetAttributes()["url"]
    end if
    
    return "pkg:/images/icon_s.jpg"
End Function


REM ********************************************************************
REM ********************************************************************
REM ***** YouTube
REM ***** video details screen
REM ********************************************************************
REM ********************************************************************
Sub youtube_display_video_springboard(video As Object)
    print "Displaying video springboard"
    p = CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")
    screen.SetMessagePort(p)

    screen.SetDescriptionStyle("movie")
    screen.AllowNavLeft(true)
    screen.AllowNavRight(true)
    screen.SetPosterStyle("rounded-rect-16x9-generic")
    screen.SetDisplayMode("zoom-to-fill")


    streamQualities = video_get_qualities(video.id)
    if streamQualities<>invalid
        video.Streams = streamQualities
        
        if streamQualities.Peek()["contentid"].toInt() > 18
            video.HDBranded = true
            video.FullHD = false
        else if streamQualities.Peek()["contentid"].toInt() = 37
            video.HDBranded = true
            video.FullHD = true
        end if

        screen.AddButton(0, "Play")
    end if

    print video.Categories,video.HDBranded

    screen.SetContent(video)
    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roSpringboardScreenEvent" then
            if msg.isScreenClosed()
                print "Closing springboard screen"
                exit while
            else if msg.isButtonPressed()
                print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
                DisplayVideo(video)
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif
        end If
    end while
End Sub


REM ********************************************************************
REM ********************************************************************
REM ***** YouTube
REM ***** The video playback screen
REM ********************************************************************
REM ********************************************************************
Sub DisplayVideo(content As Object)
    print "Displaying video: "
    p = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(p)
    
    video.SetContent(content)
    video.show()
    
    while true
        msg = wait(0, video.GetMessagePort())
        if type(msg) = "roVideoScreenEvent"
            if msg.isScreenClosed() then 'ScreenClosed event
                print "Closing video screen"
                video.Close()
                exit while
            else if msg.isRequestFailed()
                print "play failed: "; msg.GetMessage()
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            end if
        end if
    end while
End Sub


REM ********************************************************************
REM ********************************************************************
REM ***** YouTube
REM ***** Get direct MP4 video URLs from YouTube's formats map
REM ********************************************************************
REM ********************************************************************
Function parseVideoFormatsMap(videoInfo As String) As Object
    
    REM print "-----------------------------------------------"
    REM print videoInfo
    REM print "-----------------------------------------------"

    r = CreateObject("roRegex", "(?:|&"+CHR(34)+")url_encoded_fmt_stream_map=([^(&|\$)]+)", "")
    videoFormatsMatches = r.Match(videoInfo)

    if videoFormatsMatches[0]<>invalid then
        videoFormats = videoFormatsMatches[1]
    else
        print "parseVideoFormatsMap: didn't find any video formats"
        print "---------------------------------------------------"
        print videoInfo
        print "---------------------------------------------------"
        return invalid
    end if

    sep1 = CreateObject("roRegex", "%2C", "")
    sep2 = CreateObject("roRegex", "%26", "")
    sep3 = CreateObject("roRegex", "%3D", "")

    videoURL = CreateObject("roAssociativeArray")
    videoFormatsGroup = sep1.Split(videoFormats)

    for each videoFormat in videoFormatsGroup
        videoFormatsElem = sep2.Split(videoFormat)
        videoFormatsPair = CreateObject("roAssociativeArray")
        for each elem in videoFormatsElem
            pair = sep3.Split(elem)
            if pair.Count() = 2 then
                videoFormatsPair[pair[0]] = pair[1]
            end if
        end for

        if videoFormatsPair["url"]<>invalid then 
            r1=CreateObject("roRegex", "\\\/", ""):r2=CreateObject("roRegex", "\\u0026", "")
            url=URLDecode(URLDecode(videoFormatsPair["url"]))
            r1.ReplaceAll(url, "/"):r2.ReplaceAll(url, "&")
        end if
        if videoFormatsPair["itag"]<>invalid then
            itag = videoFormatsPair["itag"]
        end if
        if videoFormatsPair["sig"]<>invalid then 
            sig = videoFormatsPair["sig"]
            url = url + "&signature=" + sig
        end if

        if Instr(0, LCase(url), "http") = 1 then 
            videoURL[itag] = url
        end if
    end for

    qualityOrder = ["18","22","37"]
    bitrates = [768,2250,3750]
    isHD = [false,true,true]
    streamQualities = []

    for i=0 to qualityOrder.Count()-1
        qn = qualityOrder[i]
        if videoURL[qn]<>invalid then
            streamQualities.Push({url: videoURL[qn], bitrate: bitrates[i], quality: isHD[i], contentid: qn})
        end if
    end for

    return streamQualities

End Function


Function video_get_qualities(videoID as String) As Object

    'http = NewHttp("http://www.youtube.com/watch?v="+videoID)
    http = NewHttp("http://www.youtube.com/get_video_info?video_id="+videoID)
    rsp = http.getToStringWithTimeout(10)
    if rsp<>invalid then

        videoFormats = parseVideoFormatsMap(rsp)
        if videoFormats<>invalid then
            if videoFormats.Count()>0 then
                return videoFormats
            end if
        else
            'try again with full youtube page
            dialog=ShowPleaseWait("Looking for compatible videos...","")
            http = NewHttp("http://www.youtube.com/watch?v="+videoID)
            rsp = http.getToStringWithTimeout(30)
            if rsp<>invalid then
                videoFormats = parseVideoFormatsMap(rsp)
                if videoFormats<>invalid then
                    if videoFormats.Count()>0 then
                        dialog.Close()
                        return videoFormats
                    end if
                else
                    dialog.Close()
                    ShowErrorDialog("Having trouble finding YouTube's video formats map...")
                end if
            end if
            dialog.Close()
        end if

    else
        ShowErrorDialog("HTTP Request for get_video_info failed!")
    end if
    
    return invalid
End Function