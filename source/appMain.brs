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

' CONSTANTS


' Main function that is called when the channel is selected
' This is the entry point for the application.
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

    categories = getCategories()
    rowTitles  = categories.rowTitles
    titleCount = rowTitles.count()

    grid.SetupLists(titleCount)
    grid.SetListNames(rowTitles)

    ' create urls 2d array to hold the urls for the courses
    dim courseUrls[titleCount - 1]

    for j = 0 to (titleCount - 1)
    	courses = getCourses(categories.categoryUrls[j])
        grid.SetContentList(j, courses.list)
        courseUrls[j] = courses.urls
    end for

    grid.Show()

    enterEventLoop(port, courseUrls)
EndFunction 

' Poster screen is the second level navigation that 
' displays all available lectures in a particular course
' selected from the GridScreen
Function displayPosterScreen( url as String )
    port = CreateObject("roMessagePort")
    poster = CreateObject("roPosterScreen")
    poster.SetBreadcrumbText("[location1]", "[location2]")
    poster.SetMessagePort(port)
    poster.setListStyle("flat-episodic")

    lectures = getLectureList(url)

    poster.SetContentList(lectures.list)
    poster.Show()

    enterEventLoop(port, lectures.urls)
EndFunction

' Springboard is the third level of navigation in the
' channel. This screen previews information specific to 
' a lecture selected from the Poster screen.  From here
' users can choose to launch the streaming video
Function displaySpringboardScreen(url as String)
    port = CreateObject("roMessagePort")
    springBoard = CreateObject("roSpringboardScreen")
    springBoard.SetBreadcrumbText("[location 1]", "[location2]")
    springBoard.SetMessagePort(port)

    springBoard.ClearButtons()
    springBoard.AddButton(1,"Play")
    springBoard.AddButton(2,"Go Back")
    springBoard.SetStaticRatingEnabled(true)
    springBoard.AllowUpdates(true)

    episode = getEpisodeContent(url)

    springBoard.SetContent(episode)
    springBoard.Show()

    enterEventLoop(port, episode)
EndFunction

' Display video starts the roVideoScreen component
' used to show streaming video through the roku device.
Function displayVideo(episode as Object)
    port = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(port)

    print episode
    video.SetContent(episode)
    video.show()

    urls = CreateObject("roArray", 1, True)

    enterEventLoop(port, urls)
EndFunction
