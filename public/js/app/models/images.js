// Generated by CoffeeScript 1.3.3
(function() {

  define(["backbone", "app/models/image", "app/models/text"], function(Backbone, ImageModel, TextModel) {
    var ElementsCollection;
    ElementsCollection = Backbone.Collection.extend({
      model: function(attrs, options) {
        var type;
        type = attrs.type.split("/")[0];
        switch (type) {
          case "image":
            return new ImageModel(attrs, options);
          case "text":
            return new TextModel(attrs, options);
        }
      },
      comparator: function(image) {
        return image.get("order");
      }
    });
    return ElementsCollection;
  });

}).call(this);
