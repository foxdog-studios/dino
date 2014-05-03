Meteor.startup ->
  reset()

Meteor.methods
  reset: ->
    reset()

reset = ->
  Meteor.users.remove {}
  Utterances.remove {}
  return

