define([
  'backbone',
  'app/models/image',
  'app/models/text'
], function(Backbone, ImageModel,TextModel){
	ElementsCollection = Backbone.Collection.extend({

		model: function(attrs, options){

			var type = attrs.type.split('/')[0]

			switch (type){
				case 'image':
					 return new ImageModel(attrs, options)
					 break;
				case 'text':
					 return new TextModel(attrs,options)
					 break;
				}
		},

	  	comparator : function(image) {
            return image.get("order");
        }

	})
	return  ElementsCollection
})

