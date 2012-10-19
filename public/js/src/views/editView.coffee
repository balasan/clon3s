
define ["backbone", "ich"], (Backbone, ich) ->

  $ = jQuery
  EditView = Backbone.View.extend(

    el: $('body'),

    events:
      "click": "editElement"

    editElement: (e) ->
      el = e.target
      requirejs ["aloha"], =>
        Aloha.ready =>
          if (($(el).text()?) and $(el).text() isnt "") or $(el).is('img') 
            # TODO document.write gets triggerd by Aloha init
            unless $(el).parent().text().match("document.write")
              if $(el).is('img') 
                editable = $(el).parent().addClass "editableClone"
              else if $(el).is('a')
                editable = $(el).addClass "editableClone"
              
              else
                editable = $(el).parent().addClass "editableClone"
                # $(el).unbind("click").addClass "editableClone"
              e.preventDefault()
              # Aloha.jQuery(el).aloha()
              # $('.editableClone').resizable()
              Aloha.jQuery(editable).aloha().focus()




    render: ->
      # $('body').html($('body').html().replace(/document.write/g, ""))
      # requirejs ["aloha"], =>
      #   Aloha.ready =>
      #     @$el.find("*").each ->
      #       if ($(this).text()?) and $(this).text() isnt ""
      #         # TODO document.write gets triggerd by Aloha init
      #         unless $(this).text().match("document.write")
      #           $(this).addClass "editableClone"
      #           $(this).unbind("click").addClass "editableClone"
      #           Aloha.jQuery(this).aloha()
      #         else
      #           console.log($(this).text())
      #     Aloha.jQuery('.editableClone').aloha()
    
    initialize: ->
      _.bindAll this, "render", "editElement"
      @render()
  )
  EditView