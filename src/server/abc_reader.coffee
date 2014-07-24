abcnode =  Meteor.require 'abcnode'

@parseAbcFile = (assetName) ->
  abcText = Assets.getText(assetName)
  abcnode.parse(abcText)

