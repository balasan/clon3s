
module.exports = (app, db) ->

  url = require 'url'


  nodeio = require "node.io"

  index : (req, res) ->
    res.render "index",
      title: 'clone this plz'

  grabsite : (req, res) ->
    siteUrl = req.body.url
    console.log(siteUrl)
    class SavePage extends nodeio.JobClass
        input: false 
        run: () -> 
          url = @options.url
          @get url, (err, body, headers, response)  =>
            if err? then @exit console.log(err); err else @emit body          
    @class = SavePage
    Scrape = new SavePage()

    nodeio.start(Scrape,{redirects:100, url:siteUrl},(err, output) ->
      if err? then console.log(err)

      # res.contentType 'json'
      # res.send output

      res.render "index",
        site: output
        ,title: "cone this plz"
    
    ,true)


rel_to_abs = (url, baseUrl) ->
  
  # Only accept commonly trusted protocols:
  #     * Only data-image URLs are accepted, Exotic flavours (escaped slash,
  #     * html-entitied characters) are not supported to keep the function fast 
  
  return url  if /^(https?|file|ftps?|mailto|javascript|data:image\/[^;]{2,9};):/i.test(url) #Url is already absolute
  
  base_url = baseUrl + '/'  
  
  if url.substring(0, 2) is "//"
    return location.protocol + url
  else if url.charAt(0) is "/"
    return location.protocol + "//" + location.host + url
  else if url.substring(0, 2) is "./"
    url = "." + url
  else if /^\s*$/.test(url)
    return "" #Empty = Return nothing
  else
    url = "../" + url
  
  url = base_url + url
  i=0
  # while /\/\.\.\//.test(url = url.replace(/[^\/]+\/+\.\.\//g, ""))
  
  # Escape certain characters to prevent XSS 
  url = url.replace(/\.$/, "").replace(/\/\./g, "").replace(/"/g, "%22").replace(/'/g, "%27").replace(/</g, "%3C").replace(/>/g, "%3E")
  url


replace_all_rel_by_abs = (html) ->
  
  #HTML/XML Attribute may not be prefixed by these characters (common 
  #       attribute chars.  This list is not complete, but will be sufficient
  #       for this function (see http://www.w3.org/TR/REC-xml/#NT-NameChar). 
  
  # Placeholders to filter obfuscations 
  #Short-hand for common use
  
  # ^ Important: Must be pre- and postfixed by < and >.
  #     *   This RE should match anything within a tag!  
  
  #
  #      @name ae
  #      @description  Converts a given string in a sequence of the original
  #                      input and the HTML entity
  #      @param String string  String to convert
  #      
  ae = (string) ->
    all_chars_lowercase = string.toLowerCase()
    return ents[string]  if ents[string]
    all_chars_uppercase = string.toUpperCase()
    RE_res = ""
    i = 0

    while i < string.length
      char_lowercase = all_chars_lowercase.charAt(i)
      if charMap[char_lowercase]
        RE_res += charMap[char_lowercase]
        continue
      char_uppercase = all_chars_uppercase.charAt(i)
      RE_sub = [char_lowercase]
      RE_sub.push "&#0*" + char_lowercase.charCodeAt(0) + entityEnd
      RE_sub.push "&#x0*" + char_lowercase.charCodeAt(0).toString(16) + entityEnd
      unless char_lowercase is char_uppercase
        
        # Note: RE ignorecase flag has already been activated 
        RE_sub.push "&#0*" + char_uppercase.charCodeAt(0) + entityEnd
        RE_sub.push "&#x0*" + char_uppercase.charCodeAt(0).toString(16) + entityEnd
      RE_sub = "(?:" + RE_sub.join("|") + ")"
      RE_res += (charMap[char_lowercase] = RE_sub)
      i++
    ents[string] = RE_res
  
  #
  #      @name by
  #      @description  2nd argument for replace().
  #      
  by_ = (match, group1, group2, group3) ->
    
    # Note that this function can also be used to remove links:
    #         * return group1 + "javascript://" + group3; 
    group1 + rel_to_abs(group2, baseUrl) + group3
  
  #
  #      @name by2
  #      @description  2nd argument for replace(). Parses relevant HTML entities
  #      
  by2 = (match, group1, group2, group3) ->
    
    #Note that this function can also be used to remove links:
    #         * return group1 + "javascript://" + group3; 
    group2 = group2.replace(slashRE, "/").replace(dotRE, ".")
    group1 + rel_to_abs(group2, baseUrl) + group3
  
  #
  #      @name cr
  #      @description            Selects a HTML element and performs a
  #                                search-and-replace on attributes
  #      @param String selector  HTML substring to match
  #      @param String attribute RegExp-escaped; HTML element attribute to match
  #      @param String marker    Optional RegExp-escaped; marks the prefix
  #      @param String delimiter Optional RegExp escaped; non-quote delimiters
  #      @param String end       Optional RegExp-escaped; forces the match to end
  #                              before an occurence of <end>
  #     
  cr = (selector, attribute, marker, delimiter, end) ->
    selector = new RegExp(selector, "gi")  if typeof selector is "string"
    attribute = att + attribute
    marker = (if typeof marker is "string" then marker else "\\s*=\\s*")
    delimiter = (if typeof delimiter is "string" then delimiter else "")
    end = (if typeof end is "string" then "?)(" + end else ")(")
    re1 = new RegExp("(" + attribute + marker + "\")([^\"" + delimiter + "]+" + end + ")", "gi")
    re2 = new RegExp("(" + attribute + marker + "')([^'" + delimiter + "]+" + end + ")", "gi")
    re3 = new RegExp("(" + attribute + marker + ")([^\"'][^\\s>" + delimiter + "]*" + end + ")", "gi")
    html = html.replace(selector, (match) ->
      match.replace(re1, by_).replace(re2, by_).replace re3, by_
    )
  
  # 
  #      @name cri
  #      @description            Selects an attribute of a HTML element, and
  #                                performs a search-and-replace on certain values
  #      @param String selector  HTML element to match
  #      @param String attribute RegExp-escaped; HTML element attribute to match
  #      @param String front     RegExp-escaped; attribute value, prefix to match
  #      @param String flags     Optional RegExp flags, default "gi"
  #      @param String delimiter Optional RegExp-escaped; non-quote delimiters
  #      @param String end       Optional RegExp-escaped; forces the match to end
  #                                before an occurence of <end>
  #     
  cri = (selector, attribute, front, flags, delimiter, end) ->
    selector = new RegExp(selector, "gi")  if typeof selector is "string"
    attribute = att + attribute
    flags = (if typeof flags is "string" then flags else "gi")
    re1 = new RegExp("(" + attribute + "\\s*=\\s*\")([^\"]*)", "gi")
    re2 = new RegExp("(" + attribute + "\\s*=\\s*')([^']+)", "gi")
    at1 = new RegExp("(" + front + ")([^\"]+)(\")", flags)
    at2 = new RegExp("(" + front + ")([^']+)(')", flags)
    if typeof delimiter is "string"
      end = (if typeof end is "string" then end else "")
      at3 = new RegExp("(" + front + ")([^\"'][^" + delimiter + "]*" + ((if end then "?)(" + end + ")" else ")()")), flags)
      handleAttr = (match, g1, g2) ->
        g1 + g2.replace(at1, by2).replace(at2, by2).replace(at3, by2)
    else
      handleAttr = (match, g1, g2) ->
        g1 + g2.replace(at1, by2).replace(at2, by2)
    html = html.replace(selector, (match) ->
      match.replace(re1, handleAttr).replace re2, handleAttr
    )
  att = "[^-a-z0-9:._]"
  entityEnd = "(?:;|(?!\\d))"
  ents =
    " ": "(?:\\s|&nbsp;?|&#0*32" + entityEnd + "|&#x0*20" + entityEnd + ")"
    "(": "(?:\\(|&#0*40" + entityEnd + "|&#x0*28" + entityEnd + ")"
    ")": "(?:\\)|&#0*41" + entityEnd + "|&#x0*29" + entityEnd + ")"
    ".": "(?:\\.|&#0*46" + entityEnd + "|&#x0*2e" + entityEnd + ")"

  charMap = {}
  s = ents[" "] + "*"
  any = "(?:[^>\"']*(?:\"[^\"]*\"|'[^']*'))*?[^>]*"
  slashRE = new RegExp(ae("/"), "g")
  dotRE = new RegExp(ae("."), "g")
  
  # <meta http-equiv=refresh content="  ; url= " > 
  cri "<meta" + any + att + "http-equiv\\s*=\\s*(?:\"" + ae("refresh") + "\"" + any + ">|'" + ae("refresh") + "'" + any + ">|" + ae("refresh") + "(?:" + ae(" ") + any + ">|>))", "content", ae("url") + s + ae("=") + s, "i"
  cr "<" + any + att + "href\\s*=" + any + ">", "href" # Linked elements
  cr "<" + any + att + "src\\s*=" + any + ">", "src" # Embedded elements
  cr "<object" + any + att + "data\\s*=" + any + ">", "data" # <object data= >
  cr "<applet" + any + att + "codebase\\s*=" + any + ">", "codebase" # <applet codebase= >
  
  # <param name=movie value= >
  cr "<param" + any + att + "name\\s*=\\s*(?:\"" + ae("movie") + "\"" + any + ">|'" + ae("movie") + "'" + any + ">|" + ae("movie") + "(?:" + ae(" ") + any + ">|>))", "value"
  cr /<style[^>]*>(?:[^"']*(?:"[^"]*"|'[^']*'))*?[^'"]*(?:<\/style|$)/g, "url", "\\s*\\(\\s*", "", "\\s*\\)" # <style>
  cri "<" + any + att + "style\\s*=" + any + ">", "style", ae("url") + s + ae("(") + s, 0, s + ae(")"), ae(")") #< style=" url(...) " >
  html



