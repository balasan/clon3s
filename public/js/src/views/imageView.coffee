
define ["backbone"], (Backbone) ->

  ImageView = Backbone.View.extend(

    tagName: "li"
    className: "imageBox"
    events:
      click: "play"
      "click .deleteElement": "deleteImage"
      mouseenter: ->
        return  unless UI
        @$el.find(".uiHidden").stop(true, true).fadeIn()

      mouseleave: ->
        @$el.find(".uiHidden").stop(true, true).fadeOut()

    play: ->
      if @$el.find(".freeze").is(":hidden")
        freeze_gif @$el.find(".play")[0], null, @$el.find(".freeze")[0]
      else
        @$el.find(".freeze").toggle()
        @$el.find(".play").toggle()

    deleteImage: ->
      answer = confirm("Are you shure you want to delete this image?")
      if answer
        @model.clear silent: true
        @model.destroy()
        @$el.remove()

    render: (margin) ->
      @el.id = @model.get("_id")
      
      #this.$el.resizable({
      #aspectRatio: $(this).width()/$(this).width() 
      #});
      @$el.html ich.imageTemp(@model.toJSON())
      self = this
      if @model.get("size")
        @$el.height Math.round(@model.get("size") * scale)
      else
        @$el.height Math.round(200 * scale)
      @$el.css "margin", margin  if margin
      ratio = @model.get("width") / @model.get("height")
      
      #var ratio = self.$el.width()/ self.$el.height()
      
      #if(loggedIn){
      
      # this.$el.resizable({
      # 	aspectRatio: 4/3,
      #      grid: 50,
      #      stop: function(event, ui) { 
      
      #        self.model.set('height',Math.round(self.$el.height()/(scale*50))*50)
      #        $(this).parent().masonry('reload');
      
      #      },
      #      resize: function(event, ui){
      #         $(this).parent().masonry('reload');
      #      }
      
      # })
      # }
      @$el.find("img").hide()
      @$el.find("img")[0].onload = ->
        $(this).show()
        aspect = $(this).width() / $(this).height()
        console.log $(this).width() + " " + aspect + " " + self.$el.height() * aspect
        self.$el.width self.$el.height() * aspect
        if loggedIn
          self.$el.resizable
            aspectRatio: aspect
            grid: [50 * aspect * scale, 50 * scale]
            create: (event, ui) ->

            
            # $('.ui').parent().masonry('reload');
            stop: (event, ui) ->
              self.model.set "size", Math.round(self.$el.height() / (scale * 50)) * 50
              $(this).parent().masonry "reload"

        
        # resize: function(event, ui){
        #     $(this).parent().masonry('reload');
        # }
        freeze_gif this
        
        #self.$el.parent().parent().masonry('reload');
        hideUI true  if UI is false
        
        # $(this).hide()
        self.$el.parent().masonry "reload"
        
        # $(this.fadeIn)
        setTimeout (->
          self.$el.parent().masonry "reload"
        ), 2000

      @$el

    initialize: ->
      _.bindAll this, "render", "deleteImage"
      @model.bind "render", @render
  )
  ImageView

