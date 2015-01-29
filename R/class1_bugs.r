setClass("bugs", representation(bugdata="data.frame",
                                predictors="data.frame"#,
                                #dbconn="SQLiteConnection"
                                ),
         #prototype=list(dbconn = dbConnect("SQLite", "hybridindex/data/bug_metadata.db"))
         )

setMethod("initialize", "bugs", function(.Object="bugs", bugdata=data.frame(), predictors=data.frame()){
  .Object@bugdata <- bugdata
  .Object@predictors <- predictors
  #.Object@dbconn <- dbConnect("SQLite", system.file("data", "bug_metadata.db", package="CSCI"))
  .Object
})

setMethod("show", "bugs", function(object){
  print(head(object@bugdata))
  cat("\n")
  print(head(object@predictors))
})
