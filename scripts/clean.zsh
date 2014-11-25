#!/usr/bin/env zsh

setopt ERR_EXIT
setopt NO_UNSET

repo=$(realpath "$(dirname "$(realpath -- $0)")/..")

clean() {
  rm --force --recursive --verbose $1
}

clean $repo/local
clean $repo/dino/.meteor/local
clean $repo/dino/packages/.build.tts
clean $repo/dino/packages/tts/.npm/package/node_modules

