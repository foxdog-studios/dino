#!/usr/bin/env zsh

setopt ERR_EXIT
setopt NO_UNSET


# ==============================================================================
# = Configuration                                                              =
# ==============================================================================

repo=$(realpath -- ${0:h}/..)

aur_packages=(
    aseprite
)

global_node_packages=(
    meteorite
)

pacman_packages=(
    cracklib
    git
    nodejs
    python
    timidity++
    timidity-freepats
    zsh
)


# ==============================================================================
# = Tasks                                                                      =
# ==============================================================================

function add_archlinuxfr_repo()
{
    if grep --quiet '\[archlinuxfr\]' /etc/pacman.conf; then
        return
    fi

    sudo tee --append /etc/pacman.conf <<-'EOF'
		[archlinuxfr]
		Server = http://repo.archlinux.fr/$arch
		SigLevel = Never
	EOF
}

function install_pacman_packages()
{
    sudo pacman --noconfirm --sync --needed --refresh $pacman_packages
}

function install_aur_packages()
{
    local package

    for package in $aur_packages; do
        if ! pacman -Q $package &> /dev/null; then
            yaourt --noconfirm --sync $package
        fi
    done
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

function copy_timidity_config()
{
    sudo cp /etc/timidity++/timidity-freepats.cfg /etc/timidity++/timidity.cfg
}

function render_wavs()
{
    $repo/scripts/render_wavs.zsh
}

function build_dictionary()
{
    $repo/scripts/build_dictionary.py /usr/share/dict/cracklib-small
}

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
    add_archlinuxfr_repo
    install_pacman_packages
    install_aur_packages
    install_meteor
    install_global_node_packages
    install_meteorite_packages
    copy_timidity_config
    render_wavs
    build_dictionary
    init_local
)

function usage()
{
    cat <<-'EOF'
		Set up a development environment

		Usage:

		    setup.zsh [TASK...]

		Tasks:
		    add_archlinuxfr_repo
		    install_pacman_packages
		    install_aur_packages
		    install_meteor
		    install_global_node_packages
		    install_meteorite_packages
		    copy_timidity_config
		    render_wavs
		    build_dictionary
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

