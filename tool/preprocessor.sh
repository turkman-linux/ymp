output=$1
shift
for arg in $@ ; do
    mkdir -p $(dirname $output/$arg)
    cat src/constants.h $arg | gcc -E - | sed "/^#.*/d"> $output/$arg
done
