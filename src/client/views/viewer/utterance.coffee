Template.utterance.helpers
  class: ->
    currentTime = Metronome.getCurrentTime()

    cursor = Utterances.find
      _id: @_id
      playbackStart:
        $lte: currentTime
      playbackEnd:
        $gt: currentTime
    ,
      sort:
        playbackStart: 1

    if cursor.count()
      'current-utterance'

