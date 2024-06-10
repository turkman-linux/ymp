function _ymp_help() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    if [[ "$prev" == ymp ]] ; then
        opts=$(command ymp help --no-color --allow-oem | cut -f1 -d" " | grep -v "Operation")
    elif [[ "$prev" == install ]] ; then
        opts=$(ymp list --no-color  --allow-oem | tr -s " " | cut -f2 -d" ")
    elif [[ "$prev" == remove ]] ; then
        opts=$(ymp list --installed --no-color  --allow-oem | tr -s " " | cut -f2 -d" ")
    fi
    opts=+$(ymp $prev --help --no-color |& grep -- "--[a-z]" | cut -f1 -d: | sed "s/ *//g")
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
complete -F _ymp_help ymp

