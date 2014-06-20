#!/usr/bin/env zsh

setopt ERR_EXIT
setopt NO_UNSET


# ==============================================================================
# = Command line interface                                                     =
# ==============================================================================

function usage()
{
    cat <<-'EOF'
		Build the Meteor application.

		Usage:

		    build.zsh
	EOF
    exit 1
}

if [[ $# -ne 0 ]]; then
    usage
fi


# ==============================================================================
# = Configuration                                                              =
# ==============================================================================

repo=$(realpath "$(dirname "$(realpath -- $0)")/..")

bundle_name=bundle
build_dir=$repo/local/build
bundle_archive=$build_dir/$bundle_name.tgz
bundle_dir=$build_dir/$bundle_name


# ==============================================================================
# = Build                                                                      =
# ==============================================================================

# Remove old build
rm --force --recursive $build_dir
mkdir --parents $build_dir

# Create bundle
cd $repo/src
mrt bundle $bundle_archive

# Extract
cd $build_dir
tar --extract --file $bundle_archive

