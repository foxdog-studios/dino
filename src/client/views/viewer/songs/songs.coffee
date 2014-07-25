Template.songs.rendered = ->
  $(window).keyup (e) ->
    switch e.keyCode
      when KeyCodes.ESCAPE
        Session.set('showSongs', not Session.get('showSongs'))

Template.songs.helpers
  showSongs: ->
    Session.get('showSongs')

  songs: ->
    Songs.find()

