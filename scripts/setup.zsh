#!/usr/bin/env zsh

setopt ERR_EXIT
setopt NO_UNSET


# ==============================================================================
# = Configuration                                                              =
# ==============================================================================

repo=$(realpath "$(dirname "$(realpath -- $0)")/..")

aur_packages=(
  aseprite
)

pacman_packages=(
  git
  zsh
)


# ==============================================================================
# = Tasks                                                                      =
# ==============================================================================

install_pacman_packages() {
  sudo pacman --noconfirm --sync --needed --refresh $pacman_packages
}

install_aur_packages() {
  local package

  for package in $aur_packages; do
    yaourt --noconfirm --sync --needed --refresh $package
  done
}


install_meteor() {
  if (( ! $+commands[meteor] )); then
    curl https://install.meteor.com | /bin/sh
  fi
}

init_local() {
  local config_dir=$repo/config
  local dev_dir=$config_dir/development

  mkdir --parents $dev_dir

  local config_name=meteor_settings.json
  if [[ ! -e $dev_dir/$config_name ]]; then
      cp $config_dir/template/$config_name $dev_dir
  fi

  local target=$config_dir/default
  if [[ ! -e $target ]]; then
      ln --force --symbolic $dev_dir:t $target
  fi
}


# ==============================================================================
# = Command line interface                                                     =
# ==============================================================================

tasks=(
  install_pacman_packages
  install_aur_packages
  install_meteor
  init_local
)

usage() {
    cat <<-'EOF'
		Set up a development environment

		Usage:

		    setup.zsh [TASK...]

		Tasks:
		    install_pacman_packages
		    install_aur_packages
		    install_meteor
		    init_local
	EOF
    exit 1
}

for task in $@; do
  if [[ ${tasks[(i)$task]} -gt ${#tasks} ]]; then
    usage
  fi
done

for task in ${@:-$tasks}; do
  print -P -- "%F{green}Task: $task%f"
  $task
done

