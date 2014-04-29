class Dictionary
  constructor: (rawDictionary) ->
    @_words = {}
    @_make rawDictionary

  _make: (rawDictionary) ->
    for word in rawDictionary.split '\n'
      if word.length > 0
        @_words[word] = true
    return

  contains: (word) ->
    _.has @_words, word

dictionary = new Dictionary ''
dictionaryDep = new Deps.Dependency if Meteor.isClient

@getDictionary = ->
  dictionaryDep.depend() if Meteor.isClient
  dictionary

@makeDictionary = (rawDictionary) ->
  dictionary = new Dictionary rawDictionary
  dictionaryDep.changed() if Meteor.isClient
  return
