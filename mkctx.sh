> ctx.vala
for i in $@ ; do
    name=$(echo $i | cut -f1 -d=)
    value=$(echo $i | cut -f2 -d=)
    echo "public string $name;" >> ctx.vala
done
echo "public void ctx_init(){" >> ctx.vala
for i in $@ ; do
    name=$(echo $i | cut -f1 -d=)
    value=$(echo $i | cut -f2 -d=)
    echo "    $name=\"$value\";" >> ctx.vala
done
echo "}" >> ctx.vala
### Operation function build
cat >> ctx.vala << EOF
public int operation_main(string name,string[] args){
    switch(name){
EOF
find src/operations -type f | while read file ; do
    op_name=$(basename $file| sed "s/\..*//g")
    echo "        case \"${op_name}\":"
    echo "            return ${op_name}_main(args);"
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
### help function build
cat >> ctx.vala << EOF
public void help(){
EOF
find src/operations -type f | while read file ; do
    op_name=$(basename $file| sed "s/\..*//g")
    echo "    ${op_name}_help();"
done >> ctx.vala
cat >> ctx.vala << EOF
}
EOF

