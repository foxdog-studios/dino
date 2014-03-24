Meteor.methods
  'sendText': (text) ->
    return unless Meteor.user()
    console.log text

