'Copyright (c) 2010 Chris Hoffman
'
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
'
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
'
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
 
Function BSJSON() As Object
    this = CreateObject("roAssociativeArray")
    
    'Constants
    this.TOKEN_NONE = 0 
    this.TOKEN_CURLY_OPEN = 1
    this.TOKEN_CURLY_CLOSE = 2
    this.TOKEN_SQUARED_OPEN = 3
    this.TOKEN_SQUARED_CLOSE = 4
    this.TOKEN_COLON = 5
    this.TOKEN_COMMA = 6
    this.TOKEN_STRING = 7
    this.TOKEN_NUMBER = 8
    this.TOKEN_TRUE = 9
    this.TOKEN_FALSE = 10
    this.TOKEN_NULL = 11
    
    'Functions
    this.JsonDecode = json_decode
    this.ParseObject = json_parse_object
    this.ParseArray = json_parse_array
    this.ParseValue = json_parse_value
    this.ParseString = json_parse_string
    this.ParseNumber = json_parse_number
    this.EatWhitespace = json_eat_whitespace
    this.GetLastIndexOfNumber = json_get_last_index_number
    this.LookAhead = json_look_ahead
    this.NextToken = json_next_token
    print "Created BSJSON object"
    
    return this
End Function

Function json_decode(json As String)
    success = [True] 'In list to pass as reference
    if json.Len() > 0 then
        charArray = CreateObject("roArray", json.Len(), false)
        for i=0 to json.Len() - 1
            charArray.Push(json.Mid(i,1))
        end for
        
        index = [0] 'In list to pass as reference
        value = m.ParseValue(charArray, index, success)
        print success[0]
        if success[0] then return value
    end if
    
    return invalid
End Function

Function json_parse_object(json As Object, index As Object, success As Object)
    aa = CreateObject("roAssociativeArray")
    
    ' {
    m.NextToken(json, index)
    
    while (true)
        token = m.LookAhead(json, index)
        if token = m.TOKEN_NONE then
            success[0] = false
            return invalid
        else if token = m.TOKEN_COMMA then
            m.NextToken(json, index)
        else if token = m.TOKEN_CURLY_CLOSE then
            m.NextToken(json, index)
            return aa
        else
            ' name
            name = m.ParseString(json, index, success)
            if not success[0] then
                return invalid
            end if
            
            ' :
            token = m.NextToken(json, index)
            if token <> m.TOKEN_COLON then
                return invalid
            end if
            
            ' value
            value = m.ParseValue(json, index, success)
            if not success[0] then
                return invalid
            end if
            
            aa[name] = value
        end if
    end while
End Function

Function json_parse_array(json As Object, index As Object, success As Object)
    array = CreateObject("roArray",1,true)
    
    ' [
    m.NextToken(json, index)
    
    while (true)
        token = m.LookAhead(json, index)
        if token = m.TOKEN_NONE then
            success[0] = false
            return invalid
        else if token = m.TOKEN_COMMA then
            m.NextToken(json, index)
        else if token = m.TOKEN_SQUARED_CLOSE then
            m.NextToken(json, index)
            return array
        else
            value = m.ParseValue(json, index, success)
            if not success[0] then
                return invalid
            end if
            
            array.Push(value)
        end if
    end while
End Function

Function json_parse_value(json As Object, index As Object, success As Object)
    next_token = m.LookAhead(json, index)
    
    if next_token = m.TOKEN_STRING then
        return m.ParseString(json, index, success)
    else if next_token = m.TOKEN_NUMBER then
        return m.ParseNumber(json, index)
    else if next_token = m.TOKEN_CURLY_OPEN then
        return m.ParseObject(json, index, success)
    else if next_token = m.TOKEN_SQUARED_OPEN then
        return m.ParseArray(json, index, success)
    else if next_token = m.TOKEN_TRUE then
        m.NextToken(json, index)
        return True
    else if next_token = m.TOKEN_FALSE then
        m.NextToken(json, index)
        return False
    else if next_token = m.TOKEN_NULL then
        m.NextToken(json, index)
        return invalid 'No null in BRS
    else 
        success[0] = false
        return invalid
    end if
End Function

Function json_parse_string(json As Object, index As Object, success As Object)
    s = ""
    
    m.EatWhitespace(json, index)
    
    ' "
    c = json[index[0]]
    index[0] = index[0] + 1
    
    complete = false
    valid = true
    while not complete and index[0] < json.Count()
        c = json[index[0]]
        index[0] = index[0] + 1
        
        if c = CHR(34) then 'Double quote
            complete = true
            exit while
        else if c = "\" then
            if index[0] >= json.Count() then
                exit while
            end if
            
            c = json[index[0]]
            index[0] = index[0] + 1
            if c = CHR(34) then
                s = s + CHR(34)
            else if c = "\" then
                s = s + "\"
            else if c = "/" then
                s = s + "/"
            else if c = "b" then
                s = s + CHR(8) 'Backspace
            else if c = "f" then
                s = s + CHR(12) 'Formfeed
            else if c = "n" then
                s = s + CHR(11) 'Newline
            else if c = "r" then
                s = s + CHR(13) 'Carriage return
            else if c = "t" then
                s = s + CHR(9) 'Tab
            else if c = "u" then
                remainingLength = json.Count() - index[0] - 1
                if remainingLength >= 4 then
                    'Brightscript does not support unicode, invalidate string
                    valid = false 
                    index[0] = index[0] + 4
                else
                    exit while
                end if
            end if
        else
            s = s + c
        end if
    end while
    
    if not complete then
        success[0] = false
        return invalid
    end if
    
    if not valid then 
        return invalid
    end if
    
    return s
End Function

Function json_parse_number(json As Object, index As Object)
    m.EatWhitespace(json, index)
    lastIndex = m.GetLastIndexOfNumber(json, index)

    number_str = ""
    while index[0] <= lastIndex
        number_str = number_str + json[index[0]]
        index[0] = index[0] + 1
    end while
    
    index[0] = lastIndex + 1
    return Val(number_str)
End Function

Function json_get_last_index_number(json As Object, index As Object)
    regex = CreateObject("roRegex","\d|e|E|\.|-","")
    lastIndex = index[0]
    
    while lastIndex<json.Count()
        if not regex.IsMatch(json[lastIndex]) then
            exit while
        end if
        
        lastIndex = lastIndex + 1
    end while
    
    return lastIndex - 1
End Function

Sub json_eat_whitespace(json As Object, index As Object)
    regex = CreateObject("roRegex"," |\t|\n|\r","")
    while index[0]<json.Count()
        if not regex.IsMatch(json[index[0]]) then
            exit while
        end if
        
        index[0] = index[0] + 1
    end while
End Sub

Function json_look_ahead(json As Object, index As Object)
    saveIndex=[]
    saveIndex[0] = index[0]
    return m.NextToken(json, saveIndex)
End Function

Function json_next_token(json As Object, index As Object)
    m.EatWhitespace(json, index)
    
    if index[0] = json.Count() then
        'print "Index: " + str(index[0]) + " TOKEN NONE"
        return m.TOKEN_NONE
    end if
    
    c = json[index[0]]
    index[0] = index[0] + 1
    if c="{" then
        'print "Index: " + str(index[0]) + " TOKEN CURLY OPEN"
        return m.TOKEN_CURLY_OPEN
    else if c="}" then
        'print "Index: " + str(index[0]) + " TOKEN CURLY CLOSE"
        return m.TOKEN_CURLY_CLOSE
    else if c="[" then
        'print "Index: " + str(index[0]) + " TOKEN SQUARE OPEN"
        return m.TOKEN_SQUARED_OPEN
    else if c="]" then
        'print "Index: " + str(index[0]) + " TOKEN SQUARE CLOSE"
        return m.TOKEN_SQUARED_CLOSE
    else if c="," then
        'print "Index: " + str(index[0]) + " TOKEN COMMA"
        return m.TOKEN_COMMA
    else if c=CHR(34) then 'Double quote
        'print "Index: " + str(index[0]) + " TOKEN STRING"
        return m.TOKEN_STRING
    else if c="0" or c="1" or c="2" or c="3" or c="4" or c="5" or c="6" or c="7" or c="8" or c="9" or c="-" then 
        'print "Index: " + str(index[0]) + " TOKEN NUMBER"
        return m.TOKEN_NUMBER
    else if c=":" then
        'print "Index: " + str(index[0]) + " TOKEN COLON"
        return m.TOKEN_COLON
    end if
    index[0] = index[0] - 1
    
    remainingLength = json.Count() - index[0] - 1
    
    ' false
    if remainingLength >= 5 then
        if json[index[0]] = "f" and  json[index[0] + 1] = "a" and json[index[0] + 2] = "l" and json[index[0] + 3] = "s" and json[index[0] + 4] = "e" then
            index[0] = index[0] + 5
            'print "Index: " + str(index[0]) + " TOKEN FALSE"
            return m.TOKEN_FALSE
        end if
    end if
    
    ' true
    if remainingLength >= 4 then
        if json[index[0]] = "t" and json[index[0] + 1] = "r" and json[index[0] + 2] = "u" and json[index[0] + 3] = "e" then
            index[0] = index[0] + 4
            'print "Index: " + str(index[0]) + " TOKEN TRUE"
            return m.TOKEN_TRUE
        end if
    end if
    
    ' null
    if remainingLength >= 4 then
        if json[index[0]] = "n" and json[index[0] + 1] = "u" and json[index[0] + 2] = "l" and json[index[0] + 3] = "l" then
            index[0] = index[0] + 4
            'print "Index: " + str(index[0]) + " TOKEN NULL"
            return m.TOKEN_NULL
        end if
    end if
    
    'print "Index: " + str(index[0]) + " TOKEN NONE"
    return m.TOKEN_NONE
End Function
