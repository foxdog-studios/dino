Router.configure
  layoutTemplate: 'layout'

Router.map ->
  @route 'editor',
    path: '/'

  @route 'viewer',
    path: '/viewer'

    waitOn: ->
      Meteor.subscribe 'progress'
      Meteor.subscribe 'rooms'
      Meteor.subscribe 'songs'
      Meteor.subscribe 'utterances'
      Meteor.subscribe 'words'

