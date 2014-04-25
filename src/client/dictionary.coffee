Meteor.startup ->
  HTTP.get '/dictionary.txt', (error, result) ->
    if not error and result.statusCode == 200
      makeDictionary result.content
    else
      Session.set 'error', "Sorry, I couldn't find the dictionary."

