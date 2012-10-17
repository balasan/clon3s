
requirejs.config
  baseUrl: "js/lib/"
  paths:
    app: "../app"
    _jquery: "require-jquery"
    backbone: "backbone-min"
    underscore: "underscore-min"
    jqueryui: "jquery-ui-1.8.19.custom.min"
    bootstrap: "bootstrap/js/bootstrap.min"
    ich : "ICanHaz.min"
    masonry: "jquery.masonry.min"
    json2: "json2"
    fileupload: "file.upload"
    aloha: "aloha/lib/aloha-full"
    fileUploader: "file_uploader/fileuploader"
    drag: "jquery.drag"

  shim:

    ich : 
      exports: "ich"

    bootstrap:
      deps: ["jqueryui"]
      exports: "bootstrap"

    underscore:
      exports: "_"

    backbone:
      deps: ["underscore", "jquery"]
      exports: "Backbone"


Aloha = window.Aloha = {}  if window.Aloha is `undefined` or window.Aloha is null

define "core", ["jquery", "drag", "masonry", "jqueryui", "bootstrap"], ($) ->
  $

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

requirejs ["core", "ich", "app/views/mainView"], ($, ich, mainView) ->

  #ToDo: in case we need global backbone events
  #vent = _.extend({}, Backbone.Events)

  #Todo: need this?
  mainPage = new mainView()

  myRoutes = Backbone.Router.extend(
    routes:
      login: "login"

    login: ->
      $("#login").modal "show"
      $("#login").on "hide", ->
        router.navigate()

  )

  router = new myRoutes()

  Backbone.history.start pushState: true
  $(".ui, .ui-icon, .ui-resizable-handle").hide()

