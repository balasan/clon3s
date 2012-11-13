

requirejs.config
  baseUrl: "js/lib/"
  paths:
    app: "../app"
    jquery: "jquery-1.7.1.min"
    backbone: "backbone-min"
    underscore: "underscore-min"
    jqueryui: "jquery-ui-1.8.19.custom.min"
    bootstrap: "bootstrap/js/bootstrap.min"
    ich : "ICanHaz.min"
    masonry: "jquery.masonry.min"
    json2: "json2"
    fileupload: "file.upload"
    aloha: "aloha/lib/aloha"
    fileUploader: "file_uploader/fileuploader"
    drag: "jquery.drag"
  map:
    '*':
      'jquery': 'jquery.nc'
    'jquery.nc':
      'jquery': 'jquery'

  shim:

    ich : 
      exports: "ich"

    bootstrap:
      deps: ["jqueryui"]
      exports: "bootstrap"

    underscore:
      exports: "_"

    jqueryui: ['jquery']
    masonry: ['jquery']

    aloha:
      deps: ["jquery"]
      exprots: "Aloha"

    backbone:
      deps: ["underscore", "jquery"]
      exports: "Backbone"
      # init: (_,$)->
      #   @Backbone.noConflict()



define 'jquery.nc', ['jquery'], ($) ->
    $.noConflict()


Aloha = window.Aloha = {}  if window.Aloha is `undefined` or window.Aloha is null

# define "core", ["jquery", "drag", "masonry", "jqueryui", "bootstrap"], (_$) ->
#   _$

Aloha.settings =
  locale: "en"

  sidebar:
    disabled: true

  plugins:
    load: "common/format, common/link, common/image"
    format:
      config: ["b", "i", "p", "h1", "h2", "h3", "pre", "removeFormat"]


#this is for the media upload library - tbd
# requirejs ["core", "app/views/mediaView"], ($, MediaView) ->


requirejs ["jquery", "ich", "app/views/mainView", "app/views/editView"], ($, ich, mainView, editView) ->

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
      editPage = new editView()
    main: ->
      mainPage = new mainView()
    login: ->
      $("#login").modal "show"
      $("#login").on "hide", ->
        router.navigate()

  )

  router = new myRoutes()

  Backbone.history.start pushState: true

