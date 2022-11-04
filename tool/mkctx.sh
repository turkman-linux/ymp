#!/bin/bash
> ctx.vala
### ctx_init variable build
for i in $@ ; do
    name=$(echo $i | cut -f1 -d=)
    value=$(echo $i | cut -f2 -d=)
    echo "private string $name;" >> ctx.vala
done
echo "private string[] operation_names;" >> ctx.vala

function list_operations(){
    find src/operations -type f -exec basename {} \; | sed "s/\..*//g" | sort
}
### ctx_init function build
echo "private void ctx_init(){" >> ctx.vala
for i in $@ ; do
    name=$(echo $i | cut -f1 -d=)
    value=$(echo $i | cut -f2 -d=)
    echo "    $name = \"$value\";" >> ctx.vala
done
echo -n "    operation_names = {" >> ctx.vala
for op_name in $(list_operations) ; do
    echo -n "\"${op_name}\", " >> ctx.vala
done >> ctx.vala
echo "};" >> ctx.vala
for op_name in $(list_operations) ; do
    echo "    ${op_name/-/_}_init();"
done >> ctx.vala
echo "}" >> ctx.vala
