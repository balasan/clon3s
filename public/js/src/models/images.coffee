define ["backbone", "app/models/image", "app/models/text"], (Backbone, ImageModel, TextModel) ->
  ElementsCollection = Backbone.Collection.extend(
    model: (attrs, options) ->
      type = attrs.type.split("/")[0]
      switch type
        when "image"
          return new ImageModel(attrs, options)
        when "text"
          return new TextModel(attrs, options)

    comparator: (image) ->
      image.get "order"
  )
  ElementsCollection

