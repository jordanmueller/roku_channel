' Main script of the basic roku channel used to 
' stream harvard lectures.
' the 4 component screens used in the channel are:
'   GridScreen: used to show all Courses organized by subject category
'   PosterScreen: used to navigate the individual lectures of a course
'   SpringboardScreen: used find more detail about individual lectures and
'                      launch videos
'   VideoScreen: used to stream the actual media content 
' 
' Users can navigate back and forth through each of these components
' with their roku remote.

' Main function that is called when the channel is selected
Function Main()
    
    displayGridScreen()

EndFunction

' Function to build a the GridScreen 
' This is the first screen of the channel that lists all
' available courses by subject type
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
EndFunction 

' Poster screen is the second level navigation that 
' displays all available lectures in a particular course
' selected from the GridScreen
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
EndFunction

' Springboard is the third level of navigation in the
' channel. This screen previews information specific to 
' a lecture selected from the Poster screen.  From here
' users can choose to launch the streaming video
Function displaySpringboardScreen()
    port = CreateObject("roMessagePort")
    springBoard = CreateObject("roSpringboardScreen")
    springBoard.SetBreadcrumbText("[location 1]", "[location2]")
    springBoard.SetMessagePort(port)

    springBoard.ClearButtons()
    springBoard.AddButton(1,"Play")
    springBoard.AddButton(2,"Go Back")
    springBoard.SetStaticRatingEnabled(true)
    springBoard.AllowUpdates(true)

    episodeContent = getEpisodeContent()

    springBoard.SetContent(episodeContent)
    springBoard.Show()

    enterEventLoop(port)
EndFunction

' Display video starts the roVideoScreen component
' used to show streaming video through the roku device.
Function displayVideo()
    port = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(port)

    videoContent = getVideoContent()
    video.SetContent(videoContent)
    video.show()

    enterEventLoop(port)
EndFunction
