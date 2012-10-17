define(['backbone'

  ], function(Backbone){

	ImageView = Backbone.View.extend({

        tagName: 'li',
        className: 'imageBox',

        events:{
        	'click': 'play'
          ,'click .deleteElement' : 'deleteImage'
          ,'mouseenter': function(){ if(!UI) return; this.$el.find('.uiHidden').stop(true,true).fadeIn() }
          ,'mouseleave': function(){ this.$el.find('.uiHidden').stop(true,true).fadeOut() }
        },

        play:function(){

        	if(this.$el.find(".freeze").is(':hidden')){
        		freeze_gif(this.$el.find(".play")[0],null,this.$el.find(".freeze")[0])
        	}
        	else{
        		this.$el.find(".freeze").toggle()
        		this.$el.find(".play").toggle()
        	}
        },

        deleteImage : function(){

          var answer = confirm("Are you shure you want to delete this image?")
            if(answer){
              this.model.clear({silent:true});
              this.model.destroy();
              this.$el.remove()
            }

        },

       	render:function(margin){

       		this.el.id = this.model.get('_id')

       		//this.$el.resizable({
				  //aspectRatio: $(this).width()/$(this).width() 
			    //});


       	  this.$el.html(ich.imageTemp(this.model.toJSON()))

    			var self=this;

          if(this.model.get('size'))
            this.$el.height(Math.round(this.model.get('size')*scale))
          else
            this.$el.height(Math.round(200*scale))

          if(margin)
            this.$el.css('margin', margin)

           var ratio = this.model.get('width')/this.model.get('height')
    			//var ratio = self.$el.width()/ self.$el.height()

          //if(loggedIn){

      			// this.$el.resizable({
      			// 	aspectRatio: 4/3,
         //      grid: 50,
         //      stop: function(event, ui) { 

         //        self.model.set('height',Math.round(self.$el.height()/(scale*50))*50)
         //        $(this).parent().masonry('reload');

         //      },
         //      resize: function(event, ui){
         //         $(this).parent().masonry('reload');
         //      }

      			// })
          // }
    						
    			this.$el.find('img').hide();

    			this.$el.find('img')[0].onload=function(){
    				$(this).show()
            var aspect =  $(this).width()/$(this).height()

            console.log($(this).width() + " " + aspect + " " +self.$el.height()*aspect)
            
            self.$el.width(self.$el.height()*aspect)


            if(loggedIn){
              self.$el.resizable({
      					aspectRatio: aspect,
                grid: [50*aspect*scale, 50*scale],
                create:function(event, ui){

                  // $('.ui').parent().masonry('reload');

                },
                stop: function(event, ui) { 

                  self.model.set('size',Math.round(self.$el.height()/(scale*50))*50)
                  $(this).parent().masonry('reload');

                },
                // resize: function(event, ui){
                //     $(this).parent().masonry('reload');
                // }
      				})
            }
    				freeze_gif(this)
            //self.$el.parent().parent().masonry('reload');
            if(UI==false)
              hideUI(true)

            // $(this).hide()
            self.$el.parent().masonry('reload')
            // $(this.fadeIn)
            setTimeout(function(){self.$el.parent().masonry('reload');},2000)

          }

    			return this.$el;


       	},

		initialize: function(){
            
            _.bindAll(this, 'render', 'deleteImage');
            
            this.model.bind('render', this.render); 
        }
	})

	return ImageView
})