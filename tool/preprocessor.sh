output=$1
file=$2
shift 2
mkdir -p $(dirname $output/$file)
cat src/constants.h $file | gcc -E - $@ | sed "/^#.*/d"> $output/$file
