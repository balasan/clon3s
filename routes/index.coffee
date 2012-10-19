
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
          @getHtml url, (err, $)  =>
            if err? then @exit console.log(err) err else 
              @emit 
                body : $('body').innerHTML 
                head : $('head').innerHTML       
    @class = SavePage
    Scrape = new SavePage()

    nodeio.start(Scrape,{redirects:100, url:siteUrl},(err, output) ->
      if err? then console.log(err)

      # output = String(output).replace(/document.write\((.*?)\)/g,"jQuery(\"#masthead\").append( $1 );  ")
      
      console.log(output[0].body)
      # output = String(output).replace(/document.write\((.*?)\)/g," jQuery('body').append(''); console.log(navigator.userAgent)") #.replace(/\<noscript\>/g,"").replace(/\<\/noscript\>/g,"")

      # res.contentType 'json'
      # res.send output
      # console.log output
      res.render "index",
        head: output[0].head
        body: output[0].body
        ,title: "cone this plz"
    
    ,true)






