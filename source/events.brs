' Functions to handle event processing 
' for the roku channel


' enterEventLoop is called by each roku component screen.
' This sets up the event loop waiting for messages sent to the
' component through the attached message port
'
' The event loop performs different actions based on the
' type of event.
Function enterEventLoop( port as Object, urls as Object )
    while true
        msg = wait(0, port)
        if type(msg) = "roGridScreenEvent" then
        	leaveLoop = processGridEvent(msg, urls)
        	if leaveLoop = true then 
        		return -1
            endif
        elseif type(msg) = "roPosterScreenEvent" then
        	leaveLoop = processPosterEvent(msg,urls)
        	if leaveLoop = true then 
        		return -1
            endif
        elseif type(msg) = "roSpringboardScreenEvent" then
        	leaveLoop = processSpringboardEvent(msg,urls)
        	if leaveLoop = true then 
        		return -1
            endif
        elseif type(msg) = "roVideoScreenEvent"
            leaveLoop = processScreenEvent(msg)
            if leaveLoop = true then
        		return -1
            endif
        elseif type(msg) = "roSearchScreenEvent"
            leaveLoop = processSearchScreenEvent(msg, urls)
            if leaveLoop = true then
        		return -1
            endif
        elseif type(msg) = "Invalid" then
            print "invalid message, closing down"
            exit while
        endif
     end while
EndFunction 

Function processGridEvent( msg as Object, urls as Object)
    if msg.isScreenClosed() then
    	print "Grid Screen Closed. Exiting."
        return true
    elseif msg.isListItemFocused()
        print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
        print " col: ";msg.GetData()
    elseif msg.isListItemSelected()
        print "Selected msg: ";msg.GetMessage();"row: ";msg.GetIndex();
        print " col: ";msg.GetData()
        ' test for the search one
        if msg.GetIndex() = 0 and msg.GetData() = 0 then
            displaySearchScreen()
        else
            displayPosterScreen( urls[msg.GetIndex()][msg.GetData()] )
        endif
    endif
    
    return false
EndFunction 

Function processPosterEvent( msg as Object, urls as Object)
    if msg.isScreenClosed() then
    	print "Poster Screen Closed. Exiting."
        return true
    elseif msg.isButtonPressed()
        print "msg: ";msg.GetMessage();"idx: ";msg.GetIndex()
    elseif msg.isListItemSelected()
        print "msg: ";msg.GetMessage();"idx: ";msg.GetIndex()
        displaySpringboardScreen(urls[msg.GetIndex()])
    endif
    
    return false
EndFunction 

Function processSpringboardEvent( msg as Object, episode as Object)
    if msg.isScreenClosed() then
    	print "Springboard Screen Closed. Exiting."
        return true
    elseif msg.isButtonPressed() 
        print "msg: "; msg.GetMessage(); "idx: "; msg.GetIndex()
        if msg.GetIndex() = 1
            displayVideo(episode)
        else if msg.GetIndex() = 2
            print "go back"
            return true
        endif
    endif
    
    return false
EndFunction 

Function processSearchScreenEvent( msg as Object, screen as Object )
    if msg.isScreenClosed()
        print "screen closed"
        return true
    else if msg.isCleared()
        print "search terms cleared"
        history.Clear()
        return false 
    else if msg.isPartialResult()
        print "partial search: "; msg.GetMessage()

        if not msg.GetMessage() = ""
            searching = true
            results = getCourses(msg.getMessage(), searching)

            resultTitles = CreateObject("roArray", results.list.count(), true)
            for i = 1 to (results.list.count() - 1)
                resultTitles.push(results.list[i].title)
            end for

            screen.SetSearchTerms(resultTitles)
        endif
        return false
    else if msg.isFullResult()
        print "full search: "; msg.GetMessage()
        ' we want to relaunch the home screen with a search results line
        displayGridScreen(msg.GetMessage())
        return true
    else
        print "Unknown event: "; msg.GetType(); " msg: ";sg.GetMessage()
    endif
    return false
EndFunction

Function processScreenEvent( msg as Object )
    if msg.isScreenClosed() then 'ScreenClosed event
        print "Closing video screen"
        return true
    else if msg.isRequestFailed()
        print "play failed: "; msg.GetMessage()
    else
        print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
    endif
    
    return false
EndFunction
