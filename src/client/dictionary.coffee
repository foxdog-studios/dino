Meteor.startup ->
  if Meteor.settings.public?.lyrics?.dictionary
    loadDictionary()

loadDictionary = ->
  HTTP.get '/dictionary.txt', (error, result) ->
    if not error and result.statusCode == 200
      makeDictionary result.content

