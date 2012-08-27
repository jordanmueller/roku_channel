' Functions that get/create content for the different 
' roku channel screens
'
' Right now it creates and sends back a bunch of generic
' data, but eventually these functions will pass back
' real content data to the main roku channel screens.

' get the titles for the Categories in the GridScreen 


Function getCategories()

    http = NewHttp("http://sjxm9203.xen.prgmr.com:8080/library/category/")
    rsp = http.GetToStringWithRetry()
    json = BSJSON()
    categories = json.JsonDecode(rsp)

    o = CreateObject("roAssociativeArray")

    o.rowTitles     = CreateObject("roArray", categories.count(), true)
    o.categoryUrls = CreateObject("roArray", categories.count(), true)
    for i = 0 to (categories.count() - 1)
        o.rowTitles.push(categories[i].name)
        o.categoryUrls.push(categories[i].url)
    end for

    return o
EndFunction 

' build an array of content objects for a row in
' the grid screen
Function getCourses(url as String, search_row=false as Boolean)

    coursesObject = CreateObject("roAssociativeArray")
    coursesObject.list = []
    coursesObject.urls = []


    if search_row then
        coursesObject.list.push({
        	                     title : "Course Search",
                                 description : "Search for courses by name, category or number.", 
                                 SDPosterUrl : "pkg:/images/search.png",
                                 HDPosterUrl : "pkg:/images/search.png"
                                })
        coursesObject.urls.push("search")
        if url = "search"
    	    return coursesObject
    	end if
        url = replace_string(url, " ", "%20")
        url = "http://sjxm9203.xen.prgmr.com:8080/library/search/" + url
    end if

    print url

    http = NewHttp(url)
    rsp = http.GetToStringWithRetry()
    json = BSJSON()
    courses = json.JsonDecode(rsp)

    for i = 0 to (courses.count() - 1)
        o = CreateObject("roAssociativeArray")
        o.ContentType = "series"
        if search_row
            o.Title = courses[i].title
        else
            o.Title = courses[i].number + ": " + courses[i].title
        end if
        o.Description = courses[i].description
        o.ReleaseDate = courses[i].release_date
        o.SDPosterUrl = courses[i].SDPosterUrl
        coursesObject.list.Push(o)
        coursesObject.urls.Push(courses[i].url)
    end for

    return coursesObject
EndFunction 

' Build an array of episodes for a specific course to
' be displayed in the poster screen navigation
Function getLectureList( url as String )

    print "Getting the Course info with: ";url;
    http = NewHttp(url)
    rsp = http.GetToStringWithRetry()
    json = BSJSON()
    course = json.JsonDecode(rsp)


    lecturesObject = CreateObject("roAssociativeArray")
    lecturesObject.list = CreateObject("roArray", course.lectures.count() - 1, true)
    lecturesObject.urls = CreateObject("roArray", course.lectures.count() - 1, true)

    for i = 0 to (course.lectures.count() - 1)
        o = CreateObject("roAssociativeArray")
        o.ContentType = "episode"
        o.Title       = course.lectures[i].title
        o.Description = course.lectures[i].title + " - " + course.lectures[i].description
        o.course_title = course.number + ": " + course.title
        o.SDPosterUrl = course.lectures[i].SDPosterUrl
        lecturesObject.list.Push(o)
        lecturesObject.urls.Push(course.lectures[i].url)
    end for

    return lecturesObject
EndFunction

' build up the content object for the springboard screen
Function getEpisodeContent(url)

    print "Getting the Lecture info: ";url;
    http = NewHttp(url)
    rsp = http.GetToStringWithRetry()
    json = BSJSON()
    lecture = json.JsonDecode(rsp)

    episode = CreateObject("roAssociativeArray")
    episode.ContentType = "episode"
    episode.SDPosterURL = lecture.SDPosterURL
    episode.Title = lecture.title 
    episode.Course_title = lecture.course_number + ": " + lecture.course_title 
    episode.Description = lecture.description
    episode.ReleaseDate = lecture.lecture_date
    episode.Length      = lecture.length
    episode.Categories  = lecture.categories
    episode.StreamUrls  = [lecture.stream_url]
    episode.StreamFormat = lecture.stream_format
    episode.StreamQualities   = lecture.stream_qualities
    episode.StreamBitrates    = [lecture.stream_bitrate]

    return episode
EndFunction

'Recursively replace values in a string.  There seems to be no
' string replace function in the brightscript librbary.
Function replace_string( my_string as String, search_value as String, replace_value as String )
    found_string_index = instr(1, my_string, search_value)
    if found_string_index = 0 then
    	return my_string
    else
    	left_string = left( my_string, (found_string_index - 1) )
    	right_string = right( my_string, (len(my_string) - (found_string_index)))
    	return left_string + replace_value + replace_string(right_string, search_value, replace_value)
    end if
EndFunction
