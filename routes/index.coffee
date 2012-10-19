
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
            if err? 
             console.log(err)
             # @exit err 
             @emit null
            else 
              body = $('body', $('*').context, true).innerHTML 
              head = $('head', $('*').context, true).innerHTML 
              # console.log($('body', $('*').context) ) 
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






