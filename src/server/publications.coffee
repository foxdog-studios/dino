Meteor.publish 'utterances', ->
  Utterances.find {},
    order: [['createdAt', 'asc']]

PROGRESS_ID = 'progress'

Meteor.publish 'progress', ->
  count = 0
  initializing = true

  getProgress = ->
    count / Melody.numNotes() * 100

  handle = Utterances.find({}).observeChanges
    added: (id) =>
      count++
      return if initializing
      @changed 'progress', PROGRESS_ID, progress: getProgress()
    removed: =>
      count--
      @changed 'progress', PROGRESS_ID, progress: getProgress()

  initializing = false
  @added 'progress', PROGRESS_ID, progress: getProgress()
  @ready()

  @onStop ->
    handle.stop()

