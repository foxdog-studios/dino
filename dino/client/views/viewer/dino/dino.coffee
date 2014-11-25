Template.dino.rendered = ->
  @_sfx = Deps.autorun ->
    if (dino = getDino())?
      getSfx().play dino.sfx

Template.dino.helpers
  image: ->
    getDino()?.image

  width: ->
    progressRatio = Progress.get() / 100
    height = $(window).height() * progressRatio
    width = $(window).width() * progressRatio
    if width > height
      width *= height / width
    "#{ width }px"

Template.dino.destroyed = ->
  @_sfx.stop() if @_sfx?

getDino = ->
    progress = Progress.get()
    name = switch
      when progress <=   0 then null
      when progress <   33 then 'baby'
      when progress <   66 then 'kid'
      when progress <  100 then 'fat'
      else 'final'
    if name?
      image: name + '.gif'
      sfx: name

