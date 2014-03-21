#!/usr/bin/env zsh

setopt ERR_EXIT
setopt NO_UNSET

repo=$(realpath -- ${0:h}/..)

if (( $+METEOR_SETTINGS )); then
    METEOR_SETTINGS=$(realpath -- $METEOR_SETTINGS)
else
    METEOR_SETTINGS=$repo/local/config/default/meteor_settings.json
fi

if [[ $# -eq 0 ]]; then
    args=( --settings $METEOR_SETTINGS )
else
    args=( $@ )
fi

cd $repo/src
exec mrt $args

