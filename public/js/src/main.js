
requirejs.config({

	baseUrl : 'javascripts/lib/',

    paths: {
        app: '../app',
        '_jquery': "require-jquery",
    	'backbone': 'backbone-min',
    	'underscore': 'underscore-min',
    	'icanHaz':'ICanHaz.min',
    	'jqueryui' : 'jquery-ui-1.8.19.custom.min',
    	'bootstrap': 'bootstrap/js/bootstrap.min',
    	'masonry': 'jquery.masonry.min',
    	'json2' : 'json2',
    	'fileupload': 'file.upload',
    	// 'ich': 'ICanHaz.min',
    	'aloha' : 'aloha/lib/aloha-full',
    	'fileUploader': 'file_uploader/fileuploader',
      'drag':'jquery.drag'

    },

    shim: {

      // 'ich':{
      //   exports: 'ich'
      // },

    	'bootstrap':{
    		deps: ['jqueryui'],
    		exports: 'bootstrap'
    	},

	    'underscore': {
	      exports: '_'
	    },
	    'backbone': {
	      deps: ["underscore", "jquery"],
	      exports: "Backbone"
	    }
	}

});


var UI = false;
var scale;
var space;


if (window.Aloha === undefined || window.Aloha === null) {
	var Aloha = window.Aloha = {};
}

define(
    'core',
    [
        'jquery',
        'drag',
        'masonry',
        'jqueryui',
        'bootstrap',

    ],
    function ( $ ) {
        return $;
       	// Aloha.settings.predefinedModules = {'jquery': window.jQuery, 'jqueryui': window.jQuery.ui};

    }
);


Aloha.settings = {
	// predefinedModules : {'jquery': window.jQuery, 'jqueryui': window.jQuery.ui},
	locale: 'en',
	sidebar: {disabled: true},
	plugins: {
		load: 'common/format, common/link, common/image',
		 format: {
		 	config : [  'b', 'i', 'p', 'h1', 'h2', 'h3', 'pre', 'removeFormat' ],
		 }
	}
}






requirejs(['core', 'app/views/mediaView'], function($,MediaView){

})


requirejs([
	'core',
	'app/views/pageView',
	], function ($, PageView){

	var windowWidth = $('body').width()
	scale = windowWidth/1600

	var vent = _.extend({}, Backbone.Events);
  var currentPage = new PageView({vent:vent})


 // Backbone.sync = function(method, model, options) {
 //    var type = methodMap[method];

 //    // Default options, unless specified.
 //    options || (options = {});

 //    // Default JSON-request options.
 //    var params = {type: type, dataType: 'json'};

 //    // Ensure that we have a URL.
 //    if (!options.url) {
 //      params.url = _.result(model, 'url') || urlError();
 //    }

 //    // Ensure that we have the appropriate request data.
 //    if (!options.data && model && (method === 'create' || method === 'update' || method === 'delete')) {
 //      params.contentType = 'application/json';
 //      params.data = JSON.stringify(model);
 //    }

 //    // For older servers, emulate JSON by encoding the request into an HTML-form.
 //    if (Backbone.emulateJSON) {
 //      params.contentType = 'application/x-www-form-urlencoded';
 //      params.data = params.data ? {model: params.data} : {};
 //    }

 //    // For older servers, emulate HTTP by mimicking the HTTP method with `_method`
 //    // And an `X-HTTP-Method-Override` header.
 //    if (Backbone.emulateHTTP) {
 //      if (type === 'PUT' || type === 'DELETE') {
 //        if (Backbone.emulateJSON) params.data._method = type;
 //        params.type = 'POST';
 //        params.beforeSend = function(xhr) {
 //          xhr.setRequestHeader('X-HTTP-Method-Override', type);
 //        };
 //      }
 //    }

 //    // Don't process data on a non-GET request.
 //    if (params.type !== 'GET' && !Backbone.emulateJSON) {
 //      params.processData = false;
 //    }

 //    var success = options.success;
 //    options.success = function(resp, status, xhr) {
 //      if (success) success(resp, status, xhr);
 //      model.trigger('sync', model, resp, options);
 //    };

 //    var error = options.error;
 //    options.error = function(xhr, status, thrown) {
 //      if (error) error(model, xhr, options);
 //      model.trigger('error', model, xhr, options);
 //    };

 //    // Make the request, allowing the user to override any Ajax options.
 //    return Backbone.ajax(_.extend(params, options));
 //  };



  myRoutes = Backbone.Router.extend({
      routes: {
        'login':'login'
      },
      login: function(){

          $('#login').modal('show')
          $('#login').on('hide', function () {
              router.navigate()
          })

      },
  })

  var router = new myRoutes();



  // Backbone.history.start()
  Backbone.history.start({pushState: true})

  // router.navigate('login')


	$('.ui, .ui-icon, .ui-resizable-handle').hide()


})

function hideUI(action){

	if(action){
		$('.ui, .ui-icon, .uiHidden .ui-resizable-handle').hide()
		$('.masonry').css('margin-top','0px')
		$('.module').css('border','none')

	}
	else{
		$('.ui, .ui-icon, .ui-resizable-handle').show()
		$('.masonry').css('margin-top','40px')
		$('.module').css('border','1px solid lightgrey')

	}
	
}

function freeze_gif(i,div,c) {
  if (c==undefined){
	  c = document.createElement('canvas');
	}
  var h = c.height = $(i.parentNode).height();
  var w = c.width = i.width;
  c.getContext('2d').drawImage(i, 0, 0, w, h);
  
  //c.style.height='100%';
  //c.height='100%';

  //c.style.display="block";
  //c.id=i.id;

  //$(c).width(i.width);
  //$(c).height(i.height);
  
  $(c).show();

  try {
    i.src = c.toDataURL("image/gif"); // if possible, retain all css aspects
  } catch(e) { // cross-domain -- mimic original with all its tag attributes
    for (var j = 0, a; a = i.attributes[j]; j++)
    	if(a.name=='style')
     	 c.setAttribute(a.name, a.value);
    
    $(c).addClass('freeze')
    $(c).height('100%')
    $(i).addClass('play')
    $(i.parentNode).append(c)
    $(i).hide();

    //i.parentNode.replaceChild(c, i);

  }
}