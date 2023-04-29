#!/bin/bash
export PATH=":/usr/sbin:/usr/bin:/bin:/sbin:@buildpath@"
declare -r installdir="@buildpath@/output"
declare -r jobs="-j@jobs@"
export HOME="@buildpath@"
export DESTDIR="$installdir"
declare -r YMPVER="@VERSION@"
export NOCONFIGURE=1
export NO_COLOR=1
export VERBOSE=1
export FORCE_UNSAFE_CONFIGURE=1
export V=1
export CFLAGS="-s -DTURKMAN -L@DISTRODIR@ @CFLAGS@"
export CXXFLAGS="-s -DTURKMAN -L@DISTRODIR@ @CXXFLAGS@"
export CC="@CC@"
export LDFLAGS="@LDFLAGS@"

function _dump_variables(){
    set -o posix ; set  
}
function ymp_print_metadata(){
    echo "ymp:"
    echo "  source:"
    echo "    name: $name"
    echo "    version: $version"
    echo "    release: $release"
    echo "    description: $description"
    if [[ "${makedepends[@]}" != "" ]] ; then
        echo "    makedepends:"
        for dep in ${makedepends[@]} ; do
            echo "      - $dep"
        done
    fi
    if [[ "${arch[@]}" != "" ]] ; then
        echo "    arch:"
        for dep in ${arch[@]} ; do
            echo "      - $dep"
        done
    fi
    if [[ "${depends[@]}" != "" ]] ; then
        echo "    depends:"
        for dep in ${depends[@]} ; do
            echo "      - $dep"
        done
    fi
    if [[ "${source[@]}" != "" ]] ; then
        echo "    archive:"
        for src in ${source[@]} ; do
            echo "      - ${src}"
        done
    fi
    if [[ "${group[@]}" != "" ]] ; then
        echo "    group:"
        for grp in ${group[@]} ; do
            echo "      - ${grp}"
        done
    fi
    if [[ "${provides[@]}" != "" ]] ; then
        echo "    provides:"
        for pro in ${provides[@]} ; do
            echo "      - $pro"
        done
    fi
    if [[ "${replaces[@]}" != "" ]] ; then
        echo "    replaces:"
        for rep in ${replaces[@]} ; do
            echo "      - $rep"
        done
    fi
    if [[ "${uses[@]}" != "" || "${uses_extra[@]}" != "" ]] ; then
        echo "    use-flags:"
        for use in ${uses[@]} ; do
            echo "      - $use"
        done
        for flag in ${uses[@]} ${uses_extra[@]} ; do
            flag_dep="${flag}_depends"
            if [[ "$(eval echo \\${${flag_dep}[@]})" != "" ]] ; then
                echo "    ${flag}-depends:"
                for dep in $(eval echo \\${${flag_dep}[@]}) ; do
                    echo "      - $dep"
                done
            fi
        done
    fi
}
function use(){
    if ! echo ${uses[@]} ${uses_extra[@]} `uname -m` all extra | grep "$1" >/dev/null; then
        echo "Use flag \"$1\" is unknown!"
        exit 1
    fi
    if [[ "${use_all}" == "31" ]] ; then
        if echo ${uses[@]} | grep "$1" >/dev/null; then
            return 0
        fi
    fi
    if [[ "${use_extra}" == "31" ]] ; then
        if echo ${uses_extra[@]} | grep "$1" >/dev/null; then
            return 0
        fi
    fi
    for use in ${uses[@]} ${uses_extra[@]}; do
        if [[ "${use}" == "$1" ]] ; then
            flag="use_$1"
            [[ "${!flag}" == "31" ]]
            return $?
        fi
    done
}
function use_opt(){
    if use "$1" ; then
        echo $2
    else
        echo $3
    fi
}
function eapply(){
    for aa in $* ; do
        patch -Np1 "$aa"
    done
}