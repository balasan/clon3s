
module.exports = (app, db) ->

  url = require 'url'


  nodeio = require "node.io"

  index : (req, res) ->
    res.render "index",
      title: 'clone this plz'
      user: req.user


  grabsite : (req, res) ->
    siteUrl = req.body.url
    unless siteUrl.match("http:")
      siteUrl = "http://"+siteUrl  
    siteHost = url.parse(siteUrl).hostname
    class SavePage extends nodeio.JobClass
        input: false 
        run: () -> 
          url = @options.url
          @getHtml url, (err, $)  =>
            if err? 
             console.log(err)
             # @exit err 
             @emit null
            else
              body = $('body', $('*').context, true).innerHTML 
              head = $('head', $('*').context, true).innerHTML 

              # this would be much easier, but does not work... why?
              # adSence = $("script:contains(google_ad_client)")
              $('script').each (el) ->
                if el.raw.match('google_ad_client')
                  newAd = el.raw.replace(/google_ad_client = [^/]+/i, "google_ad_client = 'OURSTUFF'"); 
                  newAd = newAd.replace(/google_ad_slot = [^/]+/i, "google_ad_slot = 'OURSTUFF'"); 
                  body = body.replace(el.raw, newAd)
                if el.children
                  for child in el.children
                    if child.raw.match('google_ad_client')
                      newAd = child.raw.replace(/google_ad_client = [^/]+/i, "google_ad_client = 'OURSTUFF'");
                      newAd = newAd.replace(/google_ad_slot = [^/]+/i, "google_ad_slot = 'OURSTUFF'");  
                      body = body.replace(child.raw, newAd)
              #bodyChildren = $('body', $('*').context, true).children
              body = swapLinks(body, siteHost)
              head = swapLinks(head, siteHost)
              head = swapStyle(head, siteHost, $)
              @emit 
                body : body 
                head : head

    @class = SavePage
    Scrape = new SavePage()

    nodeio.start(Scrape,{redirects:100, url:siteUrl},(err, output) ->
      if err? then console.log(err)
      else
        if output[0].head? then head = output[0].head
        if output[0].body? then head = output[0].body

        # res.contentType 'json'
        # res.send output
        # console.log output
        res.render "index",
          head: output[0].head
          body: output[0].body
          ,title: "clone this plz"
    
    ,true)


    swapLinks =  (bdy, siteHost, src = "src") =>
      linkType  = src+'="(\/|\w|\W|[^"]*)"'
      re = new RegExp(linkType,"g");
      #allSrc  =  bdy.match(/src="\/(\w|\W|[^"]*)"/g)
      allSrc  =  bdy.match(re)
      if allSrc
        cont = {}
        for mtch in allSrc
          unless mtch.match(/(facebook\.com|twitter\.com|facebook\.net|www\.|\/{2}|ftp\.)/)
            cont[mtch] = mtch.replace(src+'="', src+'="http://'+siteHost+"/")
        for k,v of cont
          bdy = bdy.replace(k, v)      
        console.log(cont, "REPLACED LINKS")
      if src == "src"
        bdy = swapLinks(bdy, siteHost, "href") 
      else
        bdy

    swapStyle = (bdy, siteHost, $) =>
      style = $('style', $('*').context, true).innerHTML 
      if style
        allSrc  =  style.match(/url\((\/|\w|\W|[^"]*)\)/g)
        if allSrc
          cont = {}
          for mtch in allSrc
            unless mtch.match(/(facebook\.com|twitter\.com|facebook\.net|www\.|\/{2}|ftp\.)/)
              cont[mtch] = mtch.replace('url(', 'url(http://'+siteHost+"/")
          for k,v of cont
            bdy = bdy.replace(k, v)      
          console.log(cont, "REPLACED LINKS IN STYLE")
      bdy

