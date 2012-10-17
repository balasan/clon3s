define([
	'backbone',
  'app/models/module'
], function(Backbone,ModuleModel){
	ModuleCollection = Backbone.Collection.extend({
		model:ModuleModel,
		comparator : function(model) {
            return -model.get("order");
        }		
	})

	

	return  ModuleCollection;
})