@Notes = new Meteor.Collection 'notes'
@Utterances = new Meteor.Collection 'utterances'
Utterances.allow
  update: ->
    true

