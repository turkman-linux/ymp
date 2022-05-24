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
