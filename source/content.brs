' Functions that get/create content for the different 
' roku channel screens

Function getRowTitles()

    rowTitles = CreateObject("roArray", 10, true)
    for j = 0 to 10
        rowTitles.Push("[Row Title "+j.toStr()+" ] ")
    end for
    return rowTitles

End Function 

Function getContentList()

    list = CreateObject("roArray", 10, true)

    for i = 0 to 10 
        o = CreateObject("roAssociativeArray")
        o.ContentType = "series"
        o.Title       = "[Title" + i.tostr() + "]"
        o.Description = "[Description] "
        o.StarRating  = "50"
        o.ReleaseDate = "[mm/dd/yyyy]"
        list.Push(o)
    end for

    return list

End Function 

Function getEpisodesList()

    list = CreateObject("roArray", 10, true)

    for i = 0 to 10 
        o = CreateObject("roAssociativeArray")
        o.ContentType = "episode"
        o.Title       = "[Title" + i.tostr() + "]"
        o.Description = "[Description] "
        o.Rating      = "NR"
        o.StarRating  = "75"
        o.ReleaseDate = "[mm/dd/yyyy]"
        o.Length      = 5400
        list.Push(o)
    end for

    return list

End Function

Function getEpisodeContent()

    o = CreateObject("roAssociativeArray")
    o.ContentType = "episode"
    o.Title = "[Title]"
    o.Description = ""
    for i = 1 to 15 
        o.Description = o.Description + "[Description] "
    end for
    o.SDPosterUrl = ""
    o.HDPosterUrl = ""
    o.Rating      = "NR"
    o.StarRating  = "75"
    o.ReleaseDate = "[mm/dd/yyyy]"
    o.Length           = 5400
    o.Categories       = CreateObject("roArray", 10, true) 
    o.Categories.Push("[Category1]")
    o.Categories.Push("[Category2]")
    o.Categories.Push("[Category3]")
    o.Actors           = CreateObject("roArray", 10, true)
    o.Actors.Push("[Actor1]")
    o.Actors.Push("[Actor2]")
    o.Actors.Push("[Actor3]")
    o.Director = "[Director]"

    return o
End Function

Function getVideoContent()

    content = CreateObject("roAssociativeArray")
    content.StreamUrls = ["http://podcast.dce.harvard.edu/2012/01/13669/L01/13669-20110901-L01-1-mp4-av1000-16x9.mp4"]
    content.Title = "Paul Farmer"
    content.StreamFormat = "mp4"
    content.StreamQualities = "SD"
    content.StreamBitrates = [0]

    return content

End Function
