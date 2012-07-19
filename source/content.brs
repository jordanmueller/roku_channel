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
Function getCourses(url as String)

    http = NewHttp(url)
    rsp = http.GetToStringWithRetry()
    json = BSJSON()
    courses = json.JsonDecode(rsp)


    coursesObject = CreateObject("roAssociativeArray")
    coursesObject.list = CreateObject("roArray", courses.count() - 1, true)
    coursesObject.urls = CreateObject("roArray", courses.count() - 1, true)

    for i = 0 to (courses.count() - 1)
        o = CreateObject("roAssociativeArray")
        o.ContentType = "series"
        o.Title       = courses[i].title
        o.Description = "[Description] "
        o.StarRating  = "50"
        o.ReleaseDate = "[mm/dd/yyyy]"
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
        o.Description = "[Description] "
        o.Rating      = "NR"
        o.StarRating  = "75"
        o.ReleaseDate = "[mm/dd/yyyy]"
        o.Length      = 5400
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
    episode.Title = lecture.title
    episode.Description = lecture.description
    episode.SDPosterUrl = ""
    episode.HDPosterUrl = ""
    episode.Rating      = "NR"
    episode.StarRating  = "75"
    episode.ReleaseDate = lecture.release_date
    episode.Length      = lecture.length
    episode.StreamUrls  = [lecture.stream_url]
    episode.StreamFormat = lecture.stream_format
    episode.StreamQualities   = lecture.stream_qualities
    episode.StreamBitrates    = [lecture.stream_bitrate]

    return episode
EndFunction
