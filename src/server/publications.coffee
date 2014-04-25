Meteor.publish 'utterances', ->
  Utterances.find {},
    order: [['createdAt', 'asc']]

