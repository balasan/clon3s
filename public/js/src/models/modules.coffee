define ["backbone", "app/models/module"], (Backbone, ModuleModel) ->
  ModuleCollection = Backbone.Collection.extend(
    model: ModuleModel
    comparator: (model) ->
      -model.get("order")
  )
  ModuleCollection

