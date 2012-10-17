
define ["backbone", "ich"], (Backbone, ich) ->

  MainView = Backbone.View.extend(

    el: $('body'),
    
    # events:
      # "click #cloneSite": "cloneSite"

    cloneSite: ->
      url = $('#urlInput').val()
      


      $(document).load("/grabsite",url: url
          
        ).done (data) =>

          $data = $(data[0])
          # $('body').append($data)


          $html = $data
          nonscripts = $html.filter(->
            not $(this).is("script")
          )
          scripts = $html.filter(->
            $(this).is("script")
          )
          
          # $("body").append(nonscripts).append scripts


          $data.each ->
            $('body').append(this)

          $html = $(data)
          html = data
          $data = String(html).replace(/<\!DOCTYPE[^>]*>/i, "").replace(/<(script)([\s\>])/g, "<div class=\"document-$1\"$2").replace /<\/(script)\>/g, "</div>"
          $data = $($data)
          $scripts = $data.find('.document-script')
          $scripts.each ->
            $script = $(this)
            if $script.parent() != $('head') then $script.detach()
          if $scripts.length then $scripts.detach()

          $scripts.each ->
            $script = $(this)
            if $script.parent() is $('head')
              scriptText = $script.html()
              scriptNode = document.createElement("script")
              contentNode = $($script.data('parent'))
              try
                # doesn't work on ie...
                scriptNode.appendChild document.createTextNode(scriptText)
                $('head').append(scriptNode)

              catch e
                # IE has funky script nodes
                scriptNode.text = scriptText
                $('head').append(scriptNode)
              scriptNode.setAttribute "src", ($(this).attr("src"))  if $(this).attr("src")?

          $("body").html($data)

          $scripts.each ->
            $script = $(this)
            if $script.parent() is $('head')
              scriptText = $script.html()
              scriptNode = document.createElement("script")
              contentNode = $($script.data('parent'))
              try
                # doesn't work on ie...
                scriptNode.appendChild document.createTextNode(scriptText)
                $('head').append(scriptNode)

              catch e
                # IE has funky script nodes
                scriptNode.text = scriptText
                $('head').append(scriptNode)


              scriptNode.setAttribute "src", ($(this).attr("src"))  if $(this).attr("src")?

          $("body").append(nonscripts).append scripts



    render: ->
      ich.grabTemplates()
      @$el.html('').append(ich.inputTemp())
    
    initialize: ->
      _.bindAll this, "render", "cloneSite"
      @render()
  )
  MainView