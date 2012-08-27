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
Function displayGridScreen(msg="" as String)
    port = CreateObject("roMessagePort") 
    grid = CreateObject("roGridScreen")
    grid.SetMessagePort(port)

    categories = getCategories()
    categories.rowTitles.unshift("Search")
    if msg = "" then
        categories.categoryUrls.unshift("search")
    else
        categories.categoryUrls.unshift(msg)
    end if
    rowTitles  = categories.rowTitles
    titleCount = rowTitles.count()

    grid.SetupLists(titleCount)
    grid.SetListNames(rowTitles)

    ' create urls 2d array to hold the urls for the courses
    dim courseUrls[titleCount - 1]

    for j = 0 to (titleCount - 1)
    	search_row = false
    	if j = 0 then
    		search_row = true
        end if
        courses = getCourses(categories.categoryUrls[j], search_row)
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
    poster.SetMessagePort(port)
    poster.setListStyle("flat-episodic")

    lectures = getLectureList(url)

    poster.SetBreadcrumbText(lectures.list[0].course_title, "")
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
    springBoard.SetMessagePort(port)

    springBoard.ClearButtons()
    springBoard.AddButton(1,"Play")
    springBoard.AddButton(2,"Go Back")
    springBoard.SetStaticRatingEnabled(false)
    springBoard.AllowUpdates(true)

    episode = getEpisodeContent(url)
    springBoard.SetBreadcrumbText(episode.course_title, "")

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

' Display the search screen
Function displaySearchScreen()
    print "starting search"

    history = CreateObject("roArray", 1, true)

    port = CreateObject("roMessagePort")
    screen = CreateObject("roSearchScreen")

    'commenting out SetBreadcrumbText() hides breadcrumb on screen
    screen.SetBreadcrumbText("", "search")
    screen.SetMessagePort(port)

    screen.SetSearchTermHeaderText("Suggestions:")
    screen.SetSearchButtonText("search")
    screen.SetClearButtonEnabled(false)

    print "Doing show screen..."
    screen.Show()

    enterEventLoop(port, screen)
EndFunction
