Template.word.helpers
  class: ->
    tick = DinoMetronome.getTimeAtNextHalfBeat()

    cursor = Utterances.find
      wordId: @_id
      playbackStart:
        $lte: tick
      playbackEnd:
        $gte: tick

    if cursor.count() > 0
      'current-utterance'

