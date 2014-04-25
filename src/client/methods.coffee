class @Methods
  @reset: (callback) ->
    Meteor.call 'reset', callback

  @submitLyrics: (lyrics, callback) ->
    check lyrics, String
    Meteor.call 'submitLyrics', lyrics, callback

