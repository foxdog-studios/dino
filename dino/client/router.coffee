'use strict'

Router.configure
  layoutTemplate: 'layout'


Router.route '/',
  name: 'editor'

Router.route '/viewer',
  name: 'viewer'

  waitOn: ->
    Meteor.subscribe 'progress'
    Meteor.subscribe 'utterances'
    Meteor.subscribe 'words'

