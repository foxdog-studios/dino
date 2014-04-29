Template.dinoGrowing.rendered = ->
  if getProgress() > 0
    @data.sound.start()

Template.dinoGrowing.destroyed = ->
  @data.sound.stop()

Template.dinoGrowing.helpers
  progressPercent: ->
    progress = getProgress()
    progress.toFixed 1

  width: ->
    progressRatio = (getProgress() / 100)
    height = $(window).height() * progressRatio
    width = $(window).width() * progressRatio
    if width > height
      width *= height / width
    width

