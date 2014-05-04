Template.word.helpers
  class: ->
    tick = Metronome.getTimeAtNextHalfBeat()

    cursor = Utterances.find
      wordId: @_id
      playbackStart:
        $lte: tick
      playbackEnd:
        $gt: tick

    if cursor.count() > 0
      'current-utterance'

