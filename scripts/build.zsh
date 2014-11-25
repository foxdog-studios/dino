#!/usr/bin/env zsh

setopt ERR_EXIT
setopt NO_UNSET


usage() {
  cat <<-'EOF'
		Build dino

		Usage:

		    # build.zsh
	EOF
  exit 1
}

if [[ $# -ne 0 ]]; then
  usage
fi

repo=$(realpath "$(dirname "$(realpath -- $0)")/..")
build=$repo/local/build

rm --force --recursive $build
cd $repo/dino
meteor build $build --directory
cd $build/bundle/programs/server
npm install

