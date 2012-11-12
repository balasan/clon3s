
module.exports = (app, db) ->

  url_module = require 'url'
  
  phantom = require 'phantom'


  nodeio = require "node.io"

# $('body').html2canvas({
# onrendered: function( canvas ) {
# img = canvas.toDataURL()}})

  index : (req, res) ->
    res.render "index",
      title: 'clone this plz'
      user: req.user


  grabsite : (req, res) ->
    siteUrl = req.body.url
    # console.log(siteUrl, 'url')
    unless siteUrl.match("http:")
      siteUrl = "http://"+siteUrl  
    siteHost = url_module.parse(siteUrl).hostname
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
              allPage = $('html', $('*').context, true).innerHTML 
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
              grabPage(siteUrl, $)
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
          ,title: "cone this plz"
    
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


    grabPage = (siteUrl, $) =>
      siteU = siteUrl.replace("http://","")
      phantom.create (ph) =>
        ph.createPage (page) =>
          page.set('viewportSize', {width:1024, height: 768})                            
          page.set('clipRect', {top: 0, left: 0, width: 1024, height: 768 })
          page.open(siteUrl, (status)->
            console.log(status)
            page.render(siteU+".png", ->
              ph.exit());
            )
          
          
          

