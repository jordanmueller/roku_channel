' basic code to use the three main components I will
' use for this channel application
'   1) GridScreen -> show categories
'   2) PosterScreen -> Show list of course lectures
'   3) SpringboardScreen -> Show individual courses to be played
'

Function Main()
    
    displayGridScreen()

End Function

' Function to build a generic GridScreen
Function displayGridScreen()
    port = CreateObject("roMessagePort")
    grid = CreateObject("roGridScreen")
    grid.SetMessagePort(port)

    rowTitles = getRowTitles()
    titleCount = rowTitles.count()

    grid.SetupLists(titleCount)
    grid.SetListNames(rowTitles)

    for j = 0 to titleCount
    	contentList = getContentList()
        grid.SetContentList(j, contentList)
    end for

    grid.Show()

    enterEventLoop(port)
End Function 

Function displayPosterScreen()
    port = CreateObject("roMessagePort")
    poster = CreateObject("roPosterScreen")
    poster.SetBreadcrumbText("[location1]", "[location2]")
    poster.SetMessagePort(port)
    poster.setListStyle("flat-episodic")

    list = getEpisodesList()

    poster.SetContentList(list)
    poster.Show()

    enterEventLoop(port)
End Function

Function displaySpringboardScreen()
    port = CreateObject("roMessagePort")
    springBoard = CreateObject("roSpringboardScreen")
    springBoard.SetBreadcrumbText("[location 1]", "[location2]")
    springBoard.SetMessagePort(port)

    springBoard.ClearButtons()
    springBoard.AddButton(1,"Play")
    springBoard.AddButton(2,"Go Back")
    springBoard.SetStaticRatingEnabled(false)
    springBoard.AllowUpdates(true)

    episodeContent = getEpisodeContent()

    springBoard.SetContent(episodeContent)
    springBoard.Show()

    enterEventLoop(port)
End Function

Function displayVideo()
    port = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(port)

    videoContent = getVideoContent()
    video.SetContent(videoContent)
    video.show()

    enterEventLoop(port)
End Function
