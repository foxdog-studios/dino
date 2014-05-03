Meteor.startup ->
  reset()

Meteor.methods
  reset: ->
    reset()

reset = ->
  Utterances.remove {}
  return

