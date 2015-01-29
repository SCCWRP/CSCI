setGeneric("nameMatch", function(object, effort = "SAFIT1")
  standardGeneric("nameMatch"))

setGeneric("subsample", function(object, rand = sample(10000, 1))
  standardGeneric("subsample"))

setGeneric("metrics", function(object)
  standardGeneric("metrics"))

setGeneric("rForest", function(object)
  standardGeneric("rForest"))

setGeneric("score", function(object, object2)
  standardGeneric("score"))