PHONEME_CONVERSIONS =
  AA: 'aa'
  AE: 'ae'
  AH: 'ah'
  AO: 'ao'
  AW: 'aw'
  AY: 'ay'
  B:  'b'
  CH: 'ch'
  D:  'd'
  DH: 'dh'
  EH: 'eh'
  ER: 'er'
  EY: 'ey'
  F:  'f'
  G:  'g'
  HH: 'h'
  IH: 'ih'
  IY: 'i'
  JH: 'jh'
  K:  'k'
  L:  'l'
  M:  'm'
  N:  'n'
  NG: 'ng'
  OW: 'ow'
  OY: 'oy'
  P:  'p'
  R:  'r'
  S:  's'
  SH: 'sh'
  T:  't'
  TH: 'th'
  UH: 'uh'
  UW: 'uw'
  V:  'v'
  W:  'w'
  Y:  'j'
  Z:  'z'
  ZH: 'zh'

@renderProsody = (text, frequency) ->
  """<prosody pitch="#{ frequency }Hz">#{ text }</prosody>"""

@renderLexicon = (word, syllable) ->
    "#{ word } 0 #{ renderPhonmes syllable }"

renderPhonmes = (syllable) ->
  phonemes = for {phoneme: phoneme, stress: stress} in syllable
    phoneme = convertPhoneme phoneme
    phoneme += convertStress stress if stress?
    phoneme
  phonemes.join ' '

convertPhoneme = (phoneme) ->
  PHONEME_CONVERSIONS[phoneme]

convertStress = (stress) ->
  switch stress
    when 0 then 0
    when 1 then 1
    when 2 then 1

