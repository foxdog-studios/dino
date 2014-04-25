#!/usr/bin/env zsh

setopt ERR_EXIT
setopt NO_UNSET

repo=${0:h:h}

if [[ $# -gt 0 ]]; then
    midis=$@
else
    midis=( $repo/tracks/*.mid )
fi

dst=$repo/src/public/tracks
mkdir --parents $dst

for midi in $midis; do
    timidity --output-file=$dst/${midi:t:r}.wav \
             --output-mode=w                    \
             $midi
done

