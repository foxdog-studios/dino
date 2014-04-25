Router.configure
  layoutTemplate: 'layout'

Router.map ->
  @route 'editor',
    path: '/'

    onBeforeAction: ->
      if Meteor.loggingIn() or Meteor.user()
        return

      Accounts.createUser
        username: Random.hexString 32
        password: 'dummy'

  @route 'viewer',
    path: '/viewer'

    waitOn: ->
      Meteor.subscribe 'utterances'

