' basic code to use the three main components I will
' use for this channel application
'   1) GridScreen -> show categories
'   2) PosterScreen -> Show list of course lectures
'   3) SpringboardScreen -> Show individual courses to be played
'

' Function to build a generic GridScreen
Function Main()
    port = CreateObject("roMessagePort")
    grid = CreateObject("roGridScreen")
    grid.SetMessagePort(port)

    rowTitles = CreateObject("roArray", 10, true)
    for j = 0 to 10
        rowTitles.Push("[Row Title "+j.toStr()+" ] ")
    end for

    grid.SetupLists(rowTitles.Count())
    grid.SetListNames(rowTitles)

    for j = 0 to 10
        list = CreateObject("roArray", 10, true)

        for i = 0 to 10 
            o = CreateObject("roAssociativeArray")
            o.ContentType = "episode"
            o.Title       = "[Title"+i.tostr+"]"
            o.ShortDescriptionLine1 = "[ShortDescriptionLine1]"
            o.ShortDescriptionLine2 = "[ShortDescriptionLine2]"
            o.Description = ""
            o.Description = "[Description] "
            o.Rating      = "NR"
            o.StarRating  = "75"
            o.ReleaseDate = "[<mm/dd/yyyy]"
            o.Length      = 5400
            o.Actors      = []
            o.Actors.Push("[Actor1]")
            o.Actors.Push("[Actor2]")
            o.Actors.Push("[Actor3]")
            o.Director = "[Director]"
            list.Push(o)
        end for

        grid.SetContentList(j, list)

    end for

    grid.Show()
    
    while true
        msg = wait(0, port)
        if type(msg) = "roGridScreenEvent" then
            if msg.isScreenClosed() then
                return -1
            elseif msg.isListItemFocused()
                print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
                print " col: ";msg.GetData()
            elseif msg.isListItemSelected()
                print "Selected msg: ";msg.GetMessage();"row: ;msg.GetIndex();
                print " col: ";msg.GetData()
            endif
        endif
    end while
End Function 


' Function to show a generic posterscreen
'Function Main()
'    port = CreateObject("roMessagePort")
'    poster = CreateObject("roPosterScreen")
'    poster.SetBreadcrumbText"[location1]", "[location2]")
'    poster.SetMessagePort(port)
'
'    list = CreateObject("roArray", 10, true)
'
'    for i = 0 to 10 
'        o = CreateObject("roAssociativeArray")
'        o.ContentType = "episode"
'        o.Title       = "[Title]"
'        o.ShortDescriptionLine1 = "[ShortDescriptionLine1]"
'        o.ShortDescriptionLine2 = "[ShortDescriptionLine2]"
'        o.Description = ""
'        o.Description = "[Description] "
'        o.Rating      = "NR"
'        o.StarRating  = "75"
'        o.ReleaseDate = "[<mm/dd/yyyy]"
'        o.Length      = 5400
'        o.Categories  = [] 
'        o.Categories.Push("[Category1]")
'        o.Categories.Push("[Category2]")
'        o.Categories.Push("[Category3]")
'        o.Actors      = []
'        o.Actors.Push("[Actor1]")
'        o.Actors.Push("[Actor2]")
'        o.Actors.Push("[Actor3]")
'        o.Director = "[Director]"
'        list.Push(o)
'    end for
'
'    poster.SetContentList(list)
'    poster.Show()
'
'    while true
'        msg = wait(0, port)
'        if msg.isScreenClosed() then
'            return -1
'        elseif msg.isButtonPressed()
'            print "msg: ";msg.GetMessage();"idx: ";msg.GetIndex()
'        endif
'    end while
'End Function

' Function to show a generic Springboard Screen
'Function Main()
'    port = CreateObject("roMessagePort")
'    springBoard = CreateObject("roSpringboardScreen")
'    springBoard.SetBreadcrumbText("[location 1]", "[location2]")
'    springBoard.SetMessagePort(port)
'
'    o = CreateObject("roAssociativeArray")
'    o.ContentType = "episode"
'    o.Title = "[Title]"
'    o.ShortDescriptionLine1 = "[ShortDescriptionLine1]"
'    o.ShortDescriptionLine2 = "[ShortDescriptionLine2]"
'    o.Description = ""
'    for i = 1 to 15 
'        o.Description = o.Description + "[Description] "
'    end for
'    o.SDPosterUrl = ""
'    o.HDPosterUrl = ""
'    o.Rating      = "NR"
'    o.StarRating  = "75"
'    o.ReleaseDate = "[mm/dd/yyyy]"
'    o.Length           = 5400
'    o.Categories       = CreateObject("roArray", 10, true) 
'    o.Categories.Push("[Category1]")
'    o.Categories.Push("[Category2]")
'    o.Categories.Push("[Category3]")
'    o.Actors           = CreateObject("roArray", 10, true)
'    o.Actors.Push("[Actor1]")
'    o.Actors.Push("[Actor2]")
'    o.Actors.Push("[Actor3]")
'    o.Director = "[Director]"
'
'    springBoard.SetContent(o)
'    springBoard.Show()
'
'    while true
'        msg = wait(0, port)
'        if msg.isScreenClosed() then
'            return -1
'        elseif msg.isButtonPressed() 
'            print "msg: "; msg.GetMessage(); "idx: "; msg.GetIndex()
'        endif
'    end while
'End Function
