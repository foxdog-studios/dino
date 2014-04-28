@Notes = new Meteor.Collection 'notes'

Utterances.allow
  update: ->
    true

