> ctx.vala
### ctx_init variable build
for i in $@ ; do
    name=$(echo $i | cut -f1 -d=)
    value=$(echo $i | cut -f2 -d=)
    echo "public string $name;" >> ctx.vala
done
echo "public string[] operation_names;" >> ctx.vala

function list_operations(){
    find src/operations -type f -exec basename {} \; | sed "s/\..*//g" | sort
}
### ctx_init function build
echo "public void ctx_init(){" >> ctx.vala
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
echo "}" >> ctx.vala

### Operation function build
cat >> ctx.vala << EOF
public int operation_main(string name,string[] args){
    switch(name){
EOF
for op_name in $(list_operations) ; do
    echo "        case \"${op_name}\":"
    echo "            return ${op_name/-/_}_main(args);"
done >> ctx.vala
cat >> ctx.vala << EOF
        default :
            error_add("Invalid operation");
            error(1);
            break;
    }
    return 0;
}
EOF
### Operation function build
cat >> ctx.vala << EOF
public int operation_help(string name){
    print_stderr(colorize(name,blue)+":");
    switch(name){
EOF
for op_name in $(list_operations) ; do
    echo "        case \"${op_name}\":"
    echo "            ${op_name/-/_}_help();"
    echo "            break;"
done >> ctx.vala
cat >> ctx.vala << EOF
        default :
            error_add("Invalid operation");
            error(1);
            break;
    }
    return 0;
}
EOF
