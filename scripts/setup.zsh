#!/usr/bin/env zsh

setopt ERR_EXIT
setopt NO_UNSET


# ==============================================================================
# = Configuration                                                              =
# ==============================================================================

repo=$(realpath -- ${0:h}/..)

global_node_packages=(
    meteorite
)

pacman_packages=(
    git
    nodejs
    zsh
)


# ==============================================================================
# = Tasks                                                                      =
# ==============================================================================

function install_pacman_packages()
{
    sudo pacman --noconfirm --sync --needed --refresh $pacman_packages
}

function install_meteor()
{
   curl https://install.meteor.com/ | sh
}

function install_global_node_packages()
{
    sudo --set-home npm install --global $global_node_packages
}

function install_meteorite_packages()
{(
    cd $repo/src
    mrt install
)}

function init_local()
{
    local config_dir=$repo/local/config
    local dev_dir=$config_dir/development

    mkdir --parents $dev_dir

    local config_name=meteor_settings.json
    if [[ ! -e $dev_dir/$config_name ]]; then
        cp $repo/templates/$config_name $dev_dir
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
    install_meteor
    install_global_node_packages
    install_meteorite_packages
    init_local
)

function usage()
{
    cat <<-'EOF'
		Set up a development environment

		Usage:

		    setup.zsh [TASK...]

		Tasks:
		    install_pacman_packages
		    install_meteor
		    install_global_node_packages
		    install_meteorite_packages
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

