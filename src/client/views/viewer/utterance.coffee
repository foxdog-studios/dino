Template.utterance.helpers
  class: ->
    tick = Metronome.getTimeAtNextHalfBeat()

    cursor = Utterances.find
      _id: @_id
      playbackStart:
        $lte: tick
      playbackEnd:
        $gt: tick
    ,
      sort:
        playbackStart: 1

    if cursor.count() > 0
      'current-utterance'

