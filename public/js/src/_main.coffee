
# Aloha = window.Aloha = {}  if window.Aloha is `undefined` or window.Aloha is null

# Aloha = window.Aloha

# Aloha.settings =
#   locale: "en"

#   sidebar:
#     disabled: true

#   plugins:
#     load: "common/format, common/link, common/image"
#     format:
#       config: ["b", "i", "p", "h1", "h2", "h3", "pre", "removeFormat"]






((window) ->

  $ = _$


  #this is for the media upload library - tbd
  # requirejs ["core", "app/views/mediaView"], ($, MediaView) ->


  # TODO move this to a ui view
  $(document).ready ->
    # FB fix
    if window.location.hash and window.location.hash is "#_=_"
      if window.history and history.pushState
        #if (Modernizr.history) {
        window.history.pushState "", document.title, window.location.pathname
      else
        scroll =
          top: document.body.scrollTop
          left: document.body.scrollLeft
        window.location.hash = ""
        document.body.scrollTop = scroll.top
        document.body.scrollLeft = scroll.left


    # signinWin = undefined
    # $("#FacebookBtn").live 'click', () ->
    #   pos = 
    #     x : $(window).width()/2 -  300 
    #     y: $(window).height()/2 - 150
    #   signinWin = window.open("/auth/facebook", "SignIn", "width=600,height=300,toolbar=0,scrollbars=0,status=0,resizable=0,location=0,menuBar=0,left=" + pos.x + ",top=" + pos.y)
    #   signinWin.handler = () ->
    #     console.log('logged in!')

    #   $(signinWin).on 'close', () ->
    #     console.log('logged in!')
    #   signinWin.focus()
    #   false


  
    #ToDo: in case we need global backbone events
    #vent = _.extend({}, Backbone.Events)


    #Todo: need this?
    myRoutes = Backbone.Router.extend(
      routes:
        "" : "main"
        grabsite : "grabsite"
        login: "login"

      grabsite: ->
        editPage = new window.EditView()
      main: ->
        mainPage = new window.MainView()
      login: ->
        $("#login").modal "show"
        $("#login").on "hide", ->
          router.navigate()

    )

    router = new myRoutes()

    Backbone.history.start pushState: true
) window
