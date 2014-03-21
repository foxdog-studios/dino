Router.configure
  layoutTemplate: 'layout'
  notFoundTemplate: 'notFound'

Router.map ->
  @route 'dinoPen', path: '/viewer'
  @route 'texter', path: '/'

