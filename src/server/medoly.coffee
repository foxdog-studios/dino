Pitches =
  c0: 16.35
  cb0: 17.32
  d0: 18.35
  eb0: 19.45
  e0: 20.60
  f0: 21.83
  gb0: 23.12
  g0: 24.50
  ab0: 25.96
  a0: 27.50
  bb0: 29.14
  b0: 30.87
  c1: 32.70
  db1: 34.65
  d1: 36.71
  eb1: 38.89
  e1: 41.20
  f1: 43.65
  gb1: 46.25
  g1: 49.00
  ab1: 51.91
  a1: 55.00
  bb1: 58.27
  b1: 61.74
  c2: 65.41
  db2: 69.30
  d2: 73.42
  eb2: 77.78
  e2: 82.41
  f2: 87.31
  gb2: 92.50
  g2: 98.00
  ab2: 103.83
  a2: 110.00
  bb2: 116.54
  b2: 123.47
  c3: 130.81
  db3: 138.59
  d3: 146.83
  eb3: 155.56
  e3: 164.81
  f3: 174.61
  gb3: 185.00
  g3: 196.00
  ab3: 207.65
  a3: 220.00
  bb3: 233.08
  b3: 246.94
  c4: 261.63
  db4: 277.18
  d4: 293.66
  eb4: 311.13
  e4: 329.63
  f4: 349.23
  gb4: 369.99
  g4: 392.00
  ab4: 415.30
  a4: 440.00
  bb4: 466.16
  b4: 493.88
  c5: 523.25
  db5: 554.37
  d5: 587.33
  eb5: 622.25
  e5: 659.25
  f5: 698.46
  gb5: 739.99
  g5: 783.99
  ab5: 830.61
  a5: 880.00
  bb5: 932.33
  b5: 987.77
  c6: 1046.50
  db6: 1108.73
  d6: 1174.66
  eb6: 1244.51
  e6: 1318.51
  f6: 1396.91
  gb6: 1479.98
  g6: 1567.98
  ab6: 1661.22
  a6: 1760.00
  bb6: 1864.66
  b6: 1975.53
  c7: 2093.00
  db7: 2217.46
  d7: 2349.32
  eb7: 2489.02
  e7: 2637.02
  f7: 2793.83
  gb7: 2959.96
  g7: 3135.96
  ab7: 3322.44
  a7: 3520.00
  bb7: 3729.31
  b7: 3951.07
  c8: 4186.01
  db8: 4434.92
  d8: 4698.64
  eb8: 4978.03

noteRegex = /([abcdefg]b?[012345678]|r)(?:_(\d+)(?:\/(\d+))?)?/i

@parseMelody = (bpm, rawMelody) ->
  # Seconds per beat
  spb = 60 / bpm
  nextOffset = 0

  # Leading or trailing whitespace creates an empty raw notes when
  # split.
  rawMelody = rawMelody.trim()

  for rawNote in rawMelody.split /\s+/
    # Parse note
    match = rawNote.match noteRegex
    throw "Invalid note: #{ rawNote }" unless match

    # Duration
    get = (group) -> parseInt match[group] || 1
    numerator = get 2
    denomitator = get 3
    beats = numerator / denomitator
    duration = beats * spb

    # Offset
    offset = nextOffset
    nextOffset += duration

    # Pitch
    rawPitch = match[1].toLowerCase()
    continue if rawPitch == 'r'
    pitch = Pitches[rawPitch]

    pitch: pitch
    offset: offset
    duration: duration

