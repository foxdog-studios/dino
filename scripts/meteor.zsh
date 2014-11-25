#!/usr/bin/env zsh

setopt ERR_EXIT
setopt NO_UNSET

repo=$(realpath "$(dirname -- "$(realpath $0)")/..")

if (( $+METEOR_SETTINGS )); then
    METEOR_SETTINGS=$(realpath -- $METEOR_SETTINGS)
else
    METEOR_SETTINGS=$repo/config/default/meteor_settings.json
fi

if [[ $# -eq 0 ]]; then
    args=( --settings $METEOR_SETTINGS )
else
    args=( $@ )
fi

cd $repo/dino
PYTHON=python2.7 exec meteor $args

