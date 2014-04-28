Router.configure
  layoutTemplate: 'layout'

Router.map ->
  @route 'editor',
    path: '/'

    onRun: ->
      Session.set 'submitting'

    onBeforeAction: ->
      if Meteor.loggingIn() or Meteor.user()
        return

      Accounts.createUser
        username: Random.hexString 32
        password: 'dummy'

    onStop: ->
      Session.set 'submitting'

  @route 'viewer',
    path: '/viewer'

    waitOn: ->
      Meteor.subscribe 'utterances'

