@Progress = new Meteor.Collection 'progress'

Progress.get = ->
  Progress.findOne()?.progress ? 0

