#!/bin/bash
> ctx.vala
### ctx_init variable build
chmod +x -R ./*
for i in $@ ; do
    name=$(echo $i | cut -f1 -d=)
    value=$(echo $i | cut -f2 -d=)
    echo "private string $name;"
done >> ctx.vala
echo "private string[] operation_names;" >> ctx.vala

function list_operations(){
    find src/operations -type f -exec basename {} \; | sed "s/\..*//g" | sort
}
function list_txt(){
    find src/shcode -type f -exec basename {} \; | sed "s/\..*//g" | sort
}
### ctx_init function build
echo "private void ctx_init(){" >> ctx.vala
for i in $@ ; do
    name=$(echo $i | cut -f1 -d=)
    value=$(echo $i | cut -f2 -d=)
    echo "    $name = \"$value\";"
done >> ctx.vala
echo -n "    operation_names = {" >> ctx.vala
for op_name in $(list_operations) ; do
    echo -n "\"${op_name}\", "
done >> ctx.vala
echo "};" >> ctx.vala
for op_name in $(list_operations) ; do
    echo "    ${op_name/-/_}_init();"
done >> ctx.vala
echo "}" >> ctx.vala
for i in $(list_txt) ; do
    echo -e "private string get_$i(){"
    echo -e  "    return \""
    cat src/shcode/$i.sh | sed 's/\\/\\\\/g;s/"/\\"/g'
    echo -e "\n    \";"
    echo -e "}"
done >> ctx.vala
