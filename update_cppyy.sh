#! /bin/bash

help_function()
{
   echo ""
   echo "Usage: $0 -C cppyy branch -CB cppyy-backend branch -CP CPyCppyy branch"
   echo "If no arguments are specified, master is picked as default"
   exit 1 # Exit script after printing help
}

# globals
c_repo="https://bitbucket.org/wlav/cppyy.git"
cb_repo="https://bitbucket.org/wlav/cppyy-backend.git"
cp_repo="https://bitbucket.org/wlav/cpycppyy.git"

c_local="/tmp/cppyy"
cb_local="/tmp/cppyy-backend"
cp_local="/tmp/CPyCppyy"

clone_directories()
{
    local c_branch=$1
    local cb_branch=$2
    local cp_branch=$3

    mkdir $c_local
    mkdir $cb_local
    mkdir $cp_local

    git clone --branch $c_branch $c_repo $c_local
    git clone --branch $cb_branch $cb_repo $cb_local
    git clone --branch $cp_branch $cp_repo $cp_local
}

copy_objects()
{
    # cppyy
    cp -r $c_local/* bindings/pyroot_experimental/cppyy/cppyy/

    # cppyy-backend
    cp -r $cb_local/!(cling) bindings/pyroot_experimental/cppyy/cppyy-backend/
    cp -r $cb_local/cling/!(patches) bindings/pyroot_experimental/cppyy/cppyy-backend/cling/

    # CPyCppyy
    cp -r $cp_local/!(include|CMakeLists.txt) bindings/pyroot_experimental/cppyy/CPyCppyy/
    cp -r $cp_local/include/* bindings/pyroot_experimental/cppyy/CPyCppyy/inc/
}

cleanup()
{
    rm -rf $c_local
    rm -rf $cb_local
    rm -rf $cp_local
}

apply_patches()
{
    git apply CppyyPatches/string_view_backport.patch
    git apply CppyyPatches/tstring_converter.patch
    git apply CppyyPatches/signaltrycatch.diff
}

# main

# get branches passed as arguments
while getopts "C:CB:CP:" opt
do
    case "$opt" in
        C ) Cbranch="$OPTARG" ;;
        CB ) CBbranch="$OPTARG" ;;
        CP ) CPbranch="$OPTARG" ;;
        ? ) help_function ;; # Print help_function in case parameter is non-existent
    esac
done

# default to master if the values are empty
if [ -z $Cbranch ]
then
    Cbranch="master"
fi
if [ -z $CBbranch ]
then
    CBbranch="master"
fi
if [ -z $CPbranch ]
then
    CPbranch="master"
fi

clone_directories $Cbranch $CBbranch $CPbranch
copy_objects
cleanup
apply_patches
